#! /usr/bin/perl -w

#################################################################################
# No part of this program may be reproduced or transmitted in any form or by any
# means, electronic or mechanical, including photocopying, recording, or
# information storage and retrieval systems, for any purpose other than the
# purchaser's personal use, without the express written permission of F5
# Networks, Inc.
#
# F5 Networks and BIG-IP (c) Copyright 2008, 2012-2018. All rights reserved.
#################################################################################

# set the version of this script
my $program = $0;
$program = `basename $program`;
chomp $program;
my $version = "v2.4.1";

## BIG-IQ SUPPORT 5.4 up to 6.0.1
## CHANGE QUEUE
# rewritten for BIG-IQ 5.0
# modified for BIG-IQ 5.2 to include re-discoveries
# modified to add BIG-IQ password prompt and fix uri bug
# modified to add option to enable stats
# Add pollTask function & correct option -t description
#
## DESCRIPTION
# This script reads a CSV file containing a list of BIG-IPs and then:
# - Establishes trust with the device
# - Discovers the device for each specified module
# - Imports the configuration for each specified module
# If the -m option is used, the trust step is skipped and the modules will be re-discovered/re-imported.
# The -m option must be used for re-discovery if any BIG-IP requires a framework upgrade.
# If a failure is encountered the script logs the error and continues.
# If conflicts are detected, the BIG-IQ version is selected by default, the CSV and -o option can override this.
# NOTE: For the Access module re-import, the "Device specific configuration" option will be used.
#
# A summary of activity, errors, and device counts is given at the end of the script.
#
# CSV file format:
# - with creds:                        big_ip_adr,admin_user,admin_pw
# - creds from command line:           big_ip_adr
# - cluster with creds:                big_ip_adr,admin_user,admin_pw,ha-name
# - cluster, creds from command line:  big_ip_adr,,,ha-name
# - cluster, creds from command line, resolution:  big_ip_adr,,,ha-name,,,, USE_BIGIP
# Framework
# - skip check (viprion):              big_ip_adr,admin_user,admin_pw,ha-name, skip
# - upgrade:                           big_ip_adr,admin_user,admin_pw,ha-name, upgrade, root_user, root_pw

use JSON;     # a Perl library for parsing JSON - supports encode_json, decode_json, to_json, from_json
use Time::HiRes qw(gettimeofday);
use Data::Dumper qw(Dumper);    # for debug
use File::Temp qw(tempfile);
use LWP;

#use strict;
#use warnings;

my $section_head = "###########################################################################################";
my $table_head = "#------------------------------------------------------------------------------------------";
my $overallStartTime = gettimeofday();

# some globals
my $token = "";
my $tokenExp = "";
my $refreshToken = "";

my $col1Fmt = "%-18s";
my $colFmt = "%-15s";

# log file
my $log = "bulkDiscovery.$$.log";
open (LOG, ">$log") || die "Unable to write the log file, '$log'\n";
&printAndLog(STDOUT, 1, "#\n# Program: $program  Version: $version\n");

# get input from the caller
use Getopt::Std;

my %usage = (
    "h" =>  "Help",
    "c" =>  "Path to CSV file with all BIG-IP devices - REQUIRED, if it doesn't exist and -m is used, a new one is generated.",
    "q" =>  "BIG-IQ admin credentials in form admin:password - REQUIRED if not using default, pass just user, and password will be prompted for",
    "a" =>  "Admin credentials for every BIG-IP (such as admin:admin) - overrides any creds in CSV",
    "r" =>  "Root credentials for every BIG-IP (such as root:default) - overrides root creds in CSV",
    "u" =>  "Update framework if needed, CSV value overrides this value if CSV value is not null",
    "t" =>  "Disable Stats Collection",
    "g" =>  "access group name if needed, not required for re-discovery",
    "l" =>  "Discover LTM, this must be included for initial discovery and import of services",
    "p" =>  "Discover APM",
    "s" =>  "Discover ASM",
    "f" =>  "Discover AFM",
    "d" =>  "Discover DNS",
    "v" =>  "Verbose screen output",
    "m" =>  "Perform a re-discovery and re-import, do not perform trust operation. Also include with -c to generate a new file.",
    "o" =>  "USE_BIGIP for conflict resolution for any module conflict def: USE_BIGIQ, CSV value overrides this value if CSV value is not null",
    "n" =>  "Do not import the service, only discover the service, the service import will be done manually",
);
# Use this to determine the order of the arg help output
my @usage = ("h","c","q","a","r","u","t","g","l","p","s","f","d","v","m","o","n");
our($opt_h,$opt_c,$opt_q,$opt_a,$opt_r,$opt_u,$opt_t,$opt_g);
our($opt_l,$opt_p,$opt_s,$opt_f,$opt_d,$opt_v,$opt_m,$opt_o,$opt_n);
getopts('hc:q:a:r:t:g:lpsfdvumon');
if (defined $opt_h && $opt_h) {
    print "Discover or rediscover multiple BIG-IP devices.\n";
    print "If the csv file does not exist and the -m option is passed, the script will generate a file based\n";
    print "on the existing discovered BIG-IPs on the BIG-IQ. This new csv file can then be edited\n";
    print "and used for subsequent re-discoveries and re-imports.\n";
    print "\nAdditional important notes:\n";
    print "The -l option must be included when performing initial trust, discovery and import of services.\n";
    print "The -m option must be used for re-discovery if any BIG-IP requires a framework upgrade.\n";
    print "The -n option can be used to skip service import, this is recommended if there are outstanding changes to be deployed\n";
    print "The -t option can be used to disable stats collection on the device, do not use if DCD is present.\n";
    print "If a framework upgrade is required for any device, that device requires the administrator\n";
    print "and root credentials passed either in the CSV file or using the -a and -r options.\n";
    print "If a failure is encountered, the script logs the error and continues.\n";
    print "If conflicts are detected, the BIG-IQ version is selected by default, the CSV and -o option can override this.\n";
    print "For the Access module re-import, the 'Device specific configuration' option will be used.\n";
    print "\nAllowed command line options:\n";
    foreach my $opt (@usage) {
        print ("\t-$opt\t$usage{$opt}\n");
    }
    print "\nCSV file format: ip, user, pw, cluster-name, framework-action, root-user, root-pw, resolution\n";
    print "  ip: ip address of the BIG-IP to discover.\n";
    print "  user, pw: username & password of the BIG-IP.  Will be overridden if -a is specified on the command line.\n";
    print "  cluster-name: the cluster name that will group the BIG-IP DSC cluster pair\n";
    print "  framework-action: upgrade - upgrade framework if needed, skip - skip framework update check, blank - do not attempt to update\n";
    print "  root-user, root-password: only needed for framework update of 11.5.x through 11.6.x devices.\
                            Will be overridden if -r is specified on the command line\n";
    print "  conflict resolution: can either be USE_BIGIQ or USE_BIGIP, defaults to USE_BIGIP if '-o' option is specified else USE_BIGIQ\n";

    print "\nexample lines:\n";
    print "  1.2.3.4\n";
    print "  1.2.3.4, admin, pw\n";
    print "  1.2.3.4, admin, pw, cluster-name\n";
    print "  1.2.3.4,,, cluster-name,,,, USE_BIGIP\n";
    print "  1.2.3.4, admin, pw,, skip,,, USE_BIGIP\n";
    print "  1.2.3.4, admin, pw,, upgrade, root, root-pw\n";
    print "  1.2.3.4, admin, pw,, upgrade, root, root-pw, USE_BIGIP\n";
    exit;
}


# useful stuff for JSON
my $contType = "Content-Type: application/json";
my $bigiqCreds = "admin:admin";
if (defined $opt_q) {
    $bigiqCreds = $opt_q;
}

# Possible conflict resolution override
my $conflict_resolution = "USE_BIGIQ";
if (defined $opt_o) {
    $conflict_resolution = "USE_BIGIP";
}

# create browser for LWP requests
my $browser = LWP::UserAgent->new;

# See if we got the input we needed, bail with an error if we didn't
my $bailOut = 0;
if (!defined $opt_c) {
    &printAndLog(STDERR, 1, "Please use -c to provide the path to the .csv file.\n");
    $bailOut = 1;
} elsif (!(-e $opt_c)) {
    if (defined $opt_m) {
        print "Generating a new CSV file based on existing imported BIGIPs\n";
        &generateCsv($opt_c, $conflict_resolution);
    } else {
        &printAndLog(STDERR, 1, "Could not find the .csv file, '$opt_c'.\n");
        &printAndLog(STDERR, 1, "  Please use the -c option to provide a path to a valid .csv file.\n");
        &printAndLog(STDERR, 1, "  Or use the -c and -m options to generate a new .csv file.\n");
    }
    $bailOut = 1;
}
if ($bailOut) {
    &gracefulExit(1);
}

# ======================================================
# Import the .csv file, validate it, and (if optional
# credentials were supplied) override the credentials for Device.
# ======================================================
# parse the user-supplied creds
my ($bigIPadmin, $bigIPadminPW, $bigIProot, $bigIProotPW);
if (defined $opt_a) {
    if ($opt_a =~ /^([^:]+):(\S+)$/) {
        ($bigIPadmin, $bigIPadminPW) = ($1, $2);
    } else {
        &printAndLog(STDERR, 1, "## ERROR - '-a $opt_a' is invalid.  Please use the format, <username>:<password>.\n");
        &gracefulExit(1);
    }
}
if (defined $opt_r) {
    if ($opt_r =~ /^([^:]+):(\S+)$/) {
        ($bigIProot, $bigIProotPW) = ($1, $2);
    } else {
        &printAndLog(STDERR, 1, "## ERROR - '-r $opt_r' is invalid.  Please use the format, <username>:<password>.\n");
        &gracefulExit(1);
    }
}

# read the CSV file, and replace creds with the user-supplied creds as needed
open (CSV, "$opt_c") || die "## ERROR: Unable to read the .csv file, '$opt_c'\n";
my @csvLns = <CSV>;
close CSV;
my @bigips;

my $index = 0;
foreach my $ln (@csvLns) {
    chomp $ln;
    $ln =~ s/[\cM\cJ]+//g;  # some editors tack multiple such chars at the end of each line
    $ln =~ s/^\s+//;        # trim leading whitespace
    $ln =~ s/\s+$//;        # trim trailing whitespace

    # skip blank lines
    if ($ln eq '') {
        next;
    }

    # skip comments
    if ($ln =~ /^\s*#/) {
        next;
    }

    # parse line
    my ($mip, $aname, $apw, $haname, $fwUpg, $ruser, $rpwd, $cr) = split(/\s*,\s*/, $ln);

    if ($opt_a) {
        $aname = $bigIPadmin;
        $apw = $bigIPadminPW;
    }

    # if it's a re-discovery creds aren't necessary, otherwise exit out
    if ((not defined $opt_m) and ((not defined $aname) or (not defined $apw))) {
        print "$ln\n";
        print "missing credentials. Must specify in command line args if not a rediscovery\n";
        &gracefulExit(1);
    }

    if (defined $fwUpg) {
        if (($fwUpg ne "upgrade") and ($fwUpg ne "skip") and ($fwUpg ne "")) {
            print "$ln\n";
            print "invalid framework option: $fwUpg. Must be upgrade, skip, or blank\n";
            &gracefulExit(1);
        }
        if ($fwUpg eq "upgrade") {
            if ($opt_r) {
                $ruser = $bigIProot;
                $rpwd = $bigIProotPW;
            }
            if ((not defined $ruser) or (not defined $rpwd)) {
                print "$ln\n";
                print "missing root credentials for framework update\n";
                &gracefulExit(1);
            }
        }
    }
    if (defined $cr) {
        if (($cr ne "USE_BIGIQ") and ($cr ne "USE_BIGIP")) {
            print "$ln\n";
            print "invalid resolution option: $cr. Must be USE_BIGIQ or USE_BIGIP or not passed\n";
            &gracefulExit(1);
        }
    } else {
        $cr = $conflict_resolution;
    }

    # remember parameters for each device (in file order)
    $bigips[$index]{"mip"} = $mip;
    $bigips[$index]{"aname"} = $aname;
    $bigips[$index]{"apw"} = $apw;
    $bigips[$index]{"haname"} = $haname;
    $bigips[$index]{"fwUpg"} = $fwUpg;
    $bigips[$index]{"ruser"} = $ruser;
    $bigips[$index]{"rpwd"} = $rpwd;
    $bigips[$index]{"cr"} = $cr;

    $index++;
}

#======================================================
# Make sure the BIG-IQ API is available
# Check for available over timeout period (120 sec)
# Exit if not available during this period
#======================================================
my $timeout = 120;
my $perform_check4life = 1;
my $check4lifeStart = gettimeofday();

while($perform_check4life) {
    my $timestamp = getTimeStamp();
    my $response = $browser->get("https://localhost/info/system");
    if ($response->is_success && $response->content_type eq "application/json") {
        my $jsonWorker = JSON->new->allow_nonref;
        my $isAlive = $jsonWorker->decode($response->content);

        # Check for API availability
        if ((defined $isAlive->{"available"}) && ($isAlive->{"available"} eq "true")) {
            &printAndLog(STDOUT, 1, "#\n# BIG-IQ UI is available:         $timestamp\n");
            $perform_check4life = 0;
            last;
        } else {
            &printAndLog(STDOUT, 1, "# BIG-IQ UI is not yet available: $timestamp\n");
        }
    }

    # Exit on timeout
    if ((gettimeofday() - $check4lifeStart) > $timeout) {
        &printAndLog(STDERR, 1, "## ERROR: The BIG-IQ UI is still not available.  Try again later...\n");
        &gracefulExit(1);
    }
    sleep 10;
}

#======================================================
# login to BIG-IQ.  Sets $token global used in future requests
#======================================================

login();

#======================================================
# Check the BIG-IQ version
#======================================================

$url = 'https://localhost/mgmt/shared/resolver/device-groups/cm-shared-all-big-iqs/devices?$select=version';
$resp = getRequest($url, "check version");
my $bqVersion = $resp->{"items"}[0]->{"version"};

&printAndLog(STDOUT, 1, "BIG-IQ version: $bqVersion\n");

if ($bqVersion lt "5.2.0") {
        &printAndLog(STDERR, 1, "## ERROR: not supported in version '$bqVersion'.\n");
        &gracefulExit(1);
}

#======================================================
# Log start time
#======================================================

my $overallStart = gettimeofday();
&printAndLog(STDOUT, 1, "#\n# $section_head\n");
my $timestamp = getTimeStamp();
&printAndLog(STDOUT, 1, "#\n# Start overall discovery: $timestamp\n");
&printAndLog(STDOUT, 1, "#\n# Imports will use default conflict resolution: $conflict_resolution\n");


# Initialize Device status table
my %DeviceStatus;
$DeviceStatus{"all"}{"success"} = 0;
$DeviceStatus{"all"}{"already"} = 0;
$DeviceStatus{"all"}{"failure"} = 0;
$DeviceStatus{"all"}{"conflict"} = 0;

#======================================================
# Main loop
# Process trust, discovery, and imports
#======================================================

for $bigip (@bigips) {

    my $mip = $bigip->{"mip"};
    my $user = $bigip->{"aname"};
    my $pw = $bigip->{"apw"};
    # This will track if a device has a conflict in any module
    # and also the conflict resolution for the device for all modules
    $DeviceStatus{$mip}{"conflict"} = 0;
    my $confRes = $DeviceStatus{$mip}{"confRes"} = $bigip->{"cr"};

    my $deviceStart = gettimeofday();
    my $timestamp = getTimeStamp();
    &printAndLog(STDOUT, 1, "\n$mip Started:  $timestamp  Conflict Resolution: $confRes\n");

    # Skip the trust phase for re-discoveries if requested
    if (not defined $opt_m)
    {
        my %postBodyHash = ("address"=>$mip, "userName"=>$user, "password"=>$pw, "clusterName"=>"", "useBigiqSync"=>"false", "name"=>"trust_$mip");
        if (defined $bigip->{"haname"})
        {
            $postBodyHash{"clusterName"} = $bigip->{"haname"};
        }

        my $postBody = encode_json(\%postBodyHash);
        my $url = 'http://localhost:8100/mgmt/cm/global/tasks/device-trust';
        my $trustTask = postRequest($url, $postBody, "Establish trust with $mip");
        my $trustStatus = $trustTask->{"status"};
        $trustLink = $trustTask->{"selfLink"};
        &printAndLog(STDOUT, 1, "$mip   Establish trust $trustStatus\n");
    }
    # while loop, in case extra steps are needed for the framework
    my $done = 0;
    my $loopCount = 0;
    my $successStatus = 0;
    while (not $done)
    {
        if ($loopCount++ > 5)
        {
            &printAndLog(STDOUT, 1, "$mip     Exiting trust with max tries\n");
            last;
        }
        # Skip the trust phase for re-discoveries if requested
        if (not defined $opt_m)
        {
            $trustTask = &pollTask($bigiqCreds, $trustLink, $opt_v);
            $trustStatus = $trustTask->{"status"};
            $currentStep = $trustTask->{"currentStep"};

            $DeviceStatus{$mip}{"trust_status"} = $trustStatus;
            $DeviceStatus{$mip}{"discover_status"} = "";
            my $trustEnd = gettimeofday();
            $et = sprintf("%d", $trustEnd - $deviceStart);
        } else {
            $trustStatus = "SKIPPED";
        }
        $successStatus = 0;
        if ($trustStatus eq "SKIPPED")
        {
            &printAndLog(STDOUT, 1, "$mip   Establish trust skipped as requested\n");
            $DeviceStatus{$mip}{"trust_status"} = "SKIPPED";
            my $machineId = getMachineId($mip);
            $DeviceStatus{$mip}{"machineId"} = $machineId;
            if (discoverModules($mip, $machineId))
            {
                if (importModules($mip))
                {
                    $successStatus = 1;
                }
            }
            $done = 1;
        }
        elsif ($trustStatus eq "FAILED")
        {
            &printAndLog(STDOUT, 1, "$mip   Establish trust $trustStatus, $et seconds \n");

            my $errorMessage = $trustTask->{"errorMessage"};
            &printAndLog(STDOUT, 1, "$mip   $errorMessage\n");

            # handle already discovered devices
            if ($errorMessage =~ m/has already discovered/)
            {
                $DeviceStatus{$mip}{"trust_status"} = "ALREADY";
                my $machineId = getMachineId($mip);
                $DeviceStatus{$mip}{"machineId"} = $machineId;

                if (discoverModules($mip, $machineId))
                {
                    if (importModules($mip))
                    {
                        $successStatus = 1;
                    }
                }
            }
            else
            {
                $DeviceStatus{$mip}{"trust_error"} = $errorMessage;
                $successStatus = 0;
            }
            $done = 1;
        }
        elsif ($trustStatus eq "FINISHED")
        {
            # normal case
            if ($currentStep eq "DONE")
            {

                &printAndLog(STDOUT, 1, "$mip   Establish trust $trustStatus, $et seconds\n");
                my $machineId = $trustTask->{"machineId"};
                $DeviceStatus{$mip}{"machineId"} = $machineId;

                if (discoverModules($mip, $machineId))
                {
                    if (importModules($mip))
                    {
                        $successStatus = 1;
                    }
                }
                $done = 1;
            }
            # framework needs attention
            elsif ($currentStep eq "PENDING_FRAMEWORK_UPGRADE_CONFIRMATION")
            {
                # upgrade the framewwork
                if (handleFrameworkUpgrade ($trustTask, $bigip))
                {
                    # finish the trust task
                    $done = 0;
                }
                else
                {
                    $successStatus = 0;
                    $done = 1;
                }
            }
        }
        else
        {
            $DeviceStatus{$mip}{"trust_error"} = "  trust task finished with status $trustStatus, currentStep $currentStep";
            $successStatus = 0;
            $done = 1;
        }
    }  #end while task

    # We need trust, discovery, and all imports to be successful before we increment the success count
    if ($successStatus eq 1)
    {
        $DeviceStatus{"all"}{"success"}++;
    }
    else
    {
        $DeviceStatus{"all"}{"failure"}++;
    }

    # Enable Stats Collection
    if (not defined $opt_t)
    {
        my $statsTask;
        my $postBodyJson;
        my %postBodyHash = ();
        my $machineId = getMachineId($mip);
        $postBodyHash{"enabled"} = "true";
        $postBodyHash{"targetDeviceReference"}{"link"} = "https://localhost/mgmt/shared/resolver/device-groups/cm-bigip-allBigIpDevices/devices/$machineId";
        $postBodyHash{"modules"}[0]{"module"} = "DEVICE";
        $postBodyHash{"modules"}[1]{"module"} = "LTM";
        $postBodyHash{"modules"}[2]{"module"} = "DNS";
        $postBodyJson = encode_json(\%postBodyHash);
        $url = "https://localhost/mgmt/cm/shared/stats-mgmt/agent-install-and-config-task";
        $statsTask = postRequest($url, $postBodyJson, "Enabling Stat Collection for $mip");
        my $statsTaskSelfLink = $statsTask->{"selfLink"};
        $statsTask = &pollTask($bigiqCreds, $statsTaskSelfLink, $opt_v);
        my $statsStatus = $statsTask->{"status"};
        &printAndLog(STDOUT, 1, "$mip Stats Collection $statsStatus\n");
    }

    my $deviceEnd = gettimeofday();
    my $et = sprintf("%d", $deviceEnd - $deviceStart);
    $timestamp = getTimeStamp();
    &printAndLog(STDOUT, 1, "$mip Finished:  $timestamp\n");
    &printAndLog(STDOUT, 1, "$mip Elapsed time:  $et seconds\n");

} # end for devices

$timestamp = getTimeStamp();
&printAndLog(STDOUT, 1, "\n# End overall discovery:  $timestamp\n");

my $overallEnd = gettimeofday();
my $et = $overallEnd - $overallStart;
my $hours = ($et / 3600) % 24;
my $minutes = ($et / 60) % 60;
my $seconds = $et % 60;
my $et_fmt = sprintf ("%d hours, %d minutes, %d seconds\n", $hours, $minutes, $seconds);
&printAndLog(STDOUT, 1, "# Overall elapsed time:  $et_fmt\n");

#======================================================
# Show results.
#======================================================

showSummary();

showErrors();

showTotals();


#======================================================
# Finish up
#======================================================
&gracefulExit(0);

#======================================================
# Login
#======================================================

sub login {
    my ($bigIQuser, $bigIQpassword) = ("", "");
    if ($bigiqCreds =~ /^([^:]+):(\S+)$/) {
        ($bigIQuser, $bigIQpassword) = ($1, $2);
    }
    if ($bigIQuser eq "" && $bigiqCreds ne "") {
        $bigIQuser = $bigiqCreds;
        &printAndLog(STDOUT, 1, "Username: $bigIQuser\n");
    }
    if ($bigIQpassword eq "") {
        &printAndLog(STDOUT, 1, "Please enter your password: ");
        $stty_orig = `stty -g`;
        system('stty -echo');
        chomp($bigIQpassword = <STDIN>);
        system("stty $stty_orig");
        &printAndLog(STDOUT, 1, "\n");
    }

    $timestamp = getTimeStamp();
    &printAndLog(STDOUT, 1, "Login to BIG-IQ  $timestamp\n");

    my $loginUrl = "https://localhost/mgmt/shared/authn/login";
    my %postData = (
        "username" => $bigIQuser,
        "password" => $bigIQpassword
    );
    my $json = encode_json \%postData;

    my $req = HTTP::Request->new('POST', $loginUrl);
    $req->header('Content-Type' => 'application/json', 'Connection' => 'keep-alive' );
    $req->content($json);

    my $response = $browser->request($req);

    if ($response->is_success && ($response->content_type eq "application/json")) {
        rememberToken($response);
    }
    else
    {
        &printAndLog(STDERR, 1, "BIG-IQ login failed\n");
        &printAndLog(STDERR, 1, $response->status_line . "\n");
        &gracefulExit(1);
    }
}

#======================================================
# Refresh Token
#======================================================

sub refreshToken {
    my $url = "https://localhost/mgmt/shared/authn/exchange";
    my $jsonPostData = "{\"refreshToken\":{\"token\":\"$refreshToken\"}}";

    my $req = HTTP::Request->new('POST', $url);
    $req->header('Content-Type' => 'application/json', 'Connection' => 'keep-alive' );
    $req->content($jsonPostData);

    my $response = $browser->request($req);
    &printAndLog(STDOUT, 1, "refresh token\n");

    if ($response->is_success && ($response->content_type eq "application/json")) {
        rememberToken($response);
    }
    else
    {
        &printAndLog(STDERR, 1, "BIG-IQ refresh token failed\n");
        &printAndLog(STDERR, 1, $response->status_line . "\n");
        &gracefulExit(1);
    }
}

sub rememberToken {
    my ($response) = @_;
    my $jsonWorker = JSON->new->allow_nonref;
    my $loginResp = $jsonWorker->decode($response->content);

    $token = $loginResp->{"token"}->{"token"};
    $tokenExp = $loginResp->{"token"}->{"exp"};
    $refreshToken = $loginResp->{"refreshToken"}->{"token"};
}

#======================================================
# getReqest - A subroutine for making GET requests
#======================================================

sub getRequest {
    my ($url, $message) = @_;

    # check if our token expired
    my $tokenTime = $tokenExp - int(gettimeofday());
    if ($tokenTime < 0) {
        refreshToken();         # sets global token
        $tokenTime = $tokenExp - int(gettimeofday());
    }

    # log the URL
    print LOG "GET $url\n";

    # make the get request, including the auth header with the valid token
    my %headers = (
        'User-Agent' => 'bulkDiscovery',
        'Connection' => 'keep-alive',
        'X-F5-Auth-Token' => $token
    );
    my $response = $browser->get($url, %headers);

    # log status
    print LOG $response->status_line . "\n";

    # check for 401 in case token expired, and then retry
    if ($response->code eq "401") {
        refreshToken();

        # try again with new token
        $headers {'X-F5-Auth-Token'} = $token;
        $response = $browser->get($url, %headers);
        print LOG $response->status_line . "\n";
    }

    # if non-auth error - exit
    if ($response->is_error)
    {
        &printAndLog(STDERR, 1, "GET request failed, exiting\n");
        &gracefulExit(1);
    }

    if ($response->content_type eq "application/json") {
        my $jsonWorker = JSON->new->allow_nonref;                  # create a new JSON object which converts non-references into their values for encoding
        my $jsonHash = $jsonWorker->decode($response->content);    # converts JSON string into Perl hash(es)
        my $showRet = $jsonWorker->pretty->encode($jsonHash);      # re-encode the hash just so we can then pretty print it (hack-tacular!)
        return $jsonHash;
    }
    else
    {
        &printAndLog(STDERR, 1, "GET request - unknown response - exiting\n");
        &printAndLog(STDERR, 1, $response->content_type . "\n");
        &printAndLog(STDERR, 1, $response->content . "\n");
        &gracefulExit(1);
    }
}

#======================================================
# deleteRequest - A subroutine for making DELETE requests
#======================================================

sub deleteRequest {
    my ($url, $message) = @_;

    # check if our token expired
    my $tokenTime = $tokenExp - int(gettimeofday());
    if ($tokenTime < 0) {
        refreshToken();         # sets global token
        $tokenTime = $tokenExp - int(gettimeofday());
    }

    # log the URL
    print LOG "DELETE $url\n";

    # make the delete request, including the auth header with the valid token
    my %headers = (
        'User-Agent' => 'blukDiscovery',
        'X-F5-Auth-Token' => $token,
        'Connection' => 'keep-alive'
    );

    my $req = HTTP::Request->new('DELETE', $url);
    $req->header(%headers);
    my $response = $browser->request($req);

    # log status
    print LOG $response->status_line . "\n";

    # check for 401 in case token expired, and then retry
    if ($response->code eq "401") {
        refreshToken();

        # try again with new token
        $headers {'X-F5-Auth-Token'} = $token;
        $response = $browser->get($url, %headers);
        print LOG $response->status_line . "\n";
    }

    # if non-auth error - exit
    if ($response->is_error)
    {
        &printAndLog(STDERR, 1, "DELETE request failed, exiting\n");
        &gracefulExit(1);
    }
}

#======================================================
# postRequest - A subroutine for making POST requests
#======================================================

sub postRequest {
    my ($url, $jsonPostData, $message) = @_;
    return postOrPatchRequest ($url, "POST", $jsonPostData, $message);
}

#======================================================
# patchRequest - A subroutine for making PATCH requests
#======================================================

sub patchRequest {
    my ($url, $jsonPostData, $message) = @_;
    return postOrPatchRequest ($url, "PATCH", $jsonPostData, $message);
}

sub postOrPatchRequest {
    my ($url, $verb, $jsonPostData, $message) = @_;

    # check if our token expired
    my $tokenTime = $tokenExp - int(gettimeofday());
    if ($tokenTime < 0) {
        refreshToken();         # sets global token
        $tokenTime = $tokenExp - int(gettimeofday());
    }

    #log the url & post data
    print LOG "$verb $url\n";
    print LOG maskPasswords("$jsonPostData\n");

    my %headers = (
        'User-Agent' => 'blukDiscovery',
        'X-F5-Auth-Token' => $token,
        'Connection' => 'keep-alive'
    );

    my $req = HTTP::Request->new($verb, $url);
    $req->header(%headers);
    $req->content($jsonPostData);
    my $response = $browser->request($req);

    # check for 401 in case token expired, and then retry
    if ($response->code eq "401") {
        refreshToken();

        $headers {'X-F5-Auth-Token'} = $token;
        $response = $browser->post($url, $jsonPostData, %headers);
    }

    # if non-auth error - exit
    if ($response->is_error)
    {
        print STDERR "$verb $url\n";
        print STDERR maskPasswords("$jsonPostData\n");

        &printAndLog(STDERR, 1, "$verb error - exiting\n");
        if ($response->content_type eq "application/json") {
            &prettyPrintAndLogJson (STDERR, 1, $response->content);
        }
        else {
            &printAndLog(STDERR, 1, $response->content);
    }
        &gracefulExit(1);	# should it really exit?
    }

    if ($response->content_type eq "application/json") {
        my $jsonWorker = JSON->new->allow_nonref;                  # create a new JSON object which converts non-references into their values for encoding
        my $jsonHash = $jsonWorker->decode($response->content);    # converts JSON string into Perl hash(es)

        my $showRet = $jsonWorker->pretty->encode($jsonHash);      # re-encode the hash just so we can then pretty print it (hack-tacular!)
        my $maskln = &maskPasswords($showRet);                     # remove any passwords before logging
	print LOG $maskln;

        return $jsonHash;
    }
    else
    {
        &printAndLog(STDERR, 1, "$verb Request - unknown response - exiting\n");
        &printAndLog(STDERR, 1, $response->content_type . "\n");
        &printAndLog(STDERR, 1, $response->content);
        &gracefulExit(1);	# should it really exit?
    }
}

#======================================================
# A subroutine to get the machine id.
#======================================================

sub getMachineId {
    my ($mip) = @_;

    # get the machine id for the already trusted device using the finished trust task
    my $url = "https://localhost/mgmt/shared/resolver/device-groups/cm-bigip-allDevices/devices?\$filter=address+eq+'$mip'";
    my $trustTask = getRequest($url, "Get machinedId for $mip");

    my $machineId;
    if (defined $trustTask->{"items"}[0])
    {
        $machineId = $trustTask->{"items"}[0]->{"machineId"};
    }
    return $machineId;
}

#======================================================
# Get list of desired modules for discovery.
#======================================================
sub getModuleList {

    my @moduleList = ();

    if (defined $opt_l) {
        push @moduleList, {"module" => "adc_core"};
    }
    if (defined $opt_p) {
        push @moduleList, {"module" => "access"};
    }
    my $haveShared = 0;
    if (defined $opt_s) {
        push @moduleList, {"module" => "asm"};
        push @moduleList, {"module" => "security_shared"};
        $haveShared = 1;
    }
    if (defined $opt_f) {
        push @moduleList, {"module" => "firewall"};
        if ($haveShared == 0)
        {
            push @moduleList, {"module" => "security_shared"};
        }
    }
    if (defined $opt_d) {
        push @moduleList, {"module" => "dns"};
    }
    return @moduleList;
}

#======================================================
# handle framework
#======================================================
sub handleFrameworkUpgrade {
    my ($trustTask, $bigip) = @_;

    my $mip =  $bigip->{"mip"};
    my $needUpdate = 0;
    my $continue = 0;

    my $trustLink = $trustTask->{"selfLink"};

    my %patchBodyHash = ("status"=>"STARTED");
    my $patchBody;
    my $trustPatchCmd;

    if (defined $bigip->{"fwUpg"})
    {
        # if the csv file defines the action
        $fwUpg = $bigip->{"fwUpg"};

        if (lc($fwUpg) eq "skip")
        {
            &printAndLog(STDOUT, 1, "$mip   Skip framework upgrade\n");
            $patchBodyHash{"ignoreFrameworkUpgrade"} = "true";
            $patchBody = encode_json(\%patchBodyHash);

            $trustTask = patchRequest($trustLink, $patchBody, "framework action $fwUpg");
            $trustLink = $trustTask->{"selfLink"};
            $continue = 1;
        }
        else
        {
            # action is upgrade
            $needUpdate = 1;
        }
    }
    else
    {
        # if no action in the csv file, use the default based on the -u flag
        if (defined opt_u and opt_u)
        {
            $needUpdate = 1;
        }
        else
        {
            &printAndLog(STDOUT, 1, "$mip   Framework needs updating.  Must specity skip or upgrade in csv file, or use -u on command line\n");
            $continue = 0;
        }
    }

    if ($needUpdate)
    {
        &printAndLog(STDOUT, 1, "$mip   Upgrade the framework\n");
        $patchBodyHash{"confirmFrameworkUpgrade"} = "true";
        if ($trustTask->{"requireRootCredential"})
        {
            $patchBodyHash{"rootUser"} = $bigip->{"ruser"};
            $patchBodyHash{"rootPassword"} = $bigip->{"rpwd"};
        }
        $patchBody = encode_json(\%patchBodyHash);
        $trustTask = patchRequest($trustLink, $patchBody, "update framework");

        $continue = 1;
    }

    return $continue;
}

#======================================================
# Upgrade specified framework.
#======================================================
sub upgradeFrameworkForRediscovery {

    my ($mip, $machineId) = @_;
    my $upgradeStart = gettimeofday();
    my $success = 0;

    my $upgradeTask;
    my $postBodyJson;
    # POST a new upgrade task
    $postBodyHash{"adminUser"} = $bigip->{"aname"};
    $postBodyHash{"adminPassword"} = $bigip->{"apw"};
    $postBodyHash{"rootUser"} = $bigip->{"ruser"};
    $postBodyHash{"rootPassword"} = $bigip->{"rpwd"};
    $postBodyHash{"deviceReferences"}[0]{"link"} = "/cm/system/machineid-resolver/$machineId";
    $postBodyJson = encode_json(\%postBodyHash);

    $url = "https://localhost/mgmt/shared/framework-upgrade-tasks";
    $upgradeTask = postRequest($url, $postBodyJson, "Create upgrade task for $mip");
    &printAndLog(STDOUT, 1, "$mip   Upgrade task " . $upgradeTask->{"status"} . "\n");

    my $newUpgradeTaskSelfLink = $upgradeTask->{"selfLink"};
    $upgradeTask = &pollTask($bigiqCreds, $newUpgradeTaskSelfLink, $opt_v);

    # process overall results
    my $upgradeStatus = $upgradeTask->{"status"};
    $DeviceStatus{$mip}{"upgrade_status"} = $upgradeStatus;
    my $upgradeEnd = gettimeofday();
    my $et = sprintf("%d", $upgradeEnd - $upgradeStart);
    &printAndLog(STDOUT, 1, "$mip   Upgrade task $upgradeStatus, $et seconds\n");

    if ($upgradeStatus eq "FAILED")
    {
        $DeviceStatus{$mip}{"upgrade_error"} = $upgradeTask->{"errorMessage"};
        &printAndLog(STDOUT, 1, "$mip     Upgrade Failed: " . $upgradeTask->{"errorMessage"} . "\n");
        $success = 0;
    }
    elsif ($upgradeStatus ne "FINISHED")
    {
        $success = 0;
    }
    else
    {
        $success = 1;
    }
    return $success;
}

#======================================================
# Discover specified modules.
#======================================================
sub discoverModules {

    my ($mip, $machineId) = @_;
    my $discoverStart = gettimeofday();
    my $success = 0;

    # If upgrade is listed in the CSV file and this is a re-discovery, perform framework
    # upgrade here since the trust did not perform it
    if (defined $bigip->{"fwUpg"} and $bigip->{"fwUpg"} eq "upgrade" and defined $opt_m)
    {
        $success = upgradeFrameworkForRediscovery($mip, $machineId);
        if (!$success)
        {
            $DeviceStatus{$mip}{"discover_status"} = "FW_UPGRADE_FAILED";
            return 0
        }
    }

    # get the list of modules to discover
    my @moduleList = getModuleList();
    if (scalar @moduleList eq 0)
    {
        return 0;
    }

    my %postBodyHash = ("moduleList" => \@moduleList, "status" => "STARTED");

    # get the discovery task based on the machineId
    my $url = "https://localhost/mgmt/cm/global/tasks/device-discovery?\$filter=deviceReference/link+eq+'*$machineId*'+and+status+eq+'FINISHED'";
    my $discoveryTask = getRequest($url, "Find discovery task for $mip $machineId");

    my @discoveryTaskItems = $discoveryTask->{"items"};
    my $discoverTask;
    my $postBodyJson;
    if (defined $discoveryTask->{"items"}[0])
    {
        # PATCH the existing discovery task
        my $discoveryTaskSelfLink = $discoveryTask->{"items"}[0]->{"selfLink"};
        $postBodyJson = encode_json(\%postBodyHash);
    	$discoverTask = patchRequest($discoveryTaskSelfLink, $postBodyJson, "Patch discovery task for $mip");
        &printAndLog(STDOUT, 1, "$mip   Discover task " . $discoverTask->{"status"} . "\n");
        $discoverTask = &pollTask($bigiqCreds, $discoveryTaskSelfLink, $opt_v);
    }
    else
    {
        # POST a new discovery task
        $postBodyHash{"deviceReference"}{"link"} = "/cm/system/machineid-resolver/$machineId";
        $postBodyJson = encode_json(\%postBodyHash);

        $url = "https://localhost/mgmt/cm/global/tasks/device-discovery";
    	$discoverTask = postRequest($url, $postBodyJson, "Create discovery task for $mip");
        &printAndLog(STDOUT, 1, "$mip   Discover task " . $discoverTask->{"status"} . "\n");

        my $newDiscoverTaskSelfLink = $discoverTask->{"selfLink"};
        $discoverTask = &pollTask($bigiqCreds, $newDiscoverTaskSelfLink, $opt_v);
    }

    # process overall results
    my $discoverStatus = $discoverTask->{"status"};
    $DeviceStatus{$mip}{"discover_status"} = $discoverStatus;
    my $discoverEnd = gettimeofday();
    my $et = sprintf("%d", $discoverEnd - $discoverStart);
    &printAndLog(STDOUT, 1, "$mip   Discover task $discoverStatus, $et seconds\n");

    if ($discoverStatus eq "FAILED")
    {
        $DeviceStatus{$mip}{"discover_error"} = $discoverTask->{"errorMessage"};
        &printAndLog(STDOUT, 1, "$mip     " . $discoverTask->{"errorMessage"} . "\n");
        $success = 0;
    }
    else
    {
        $success = 1;
    }

    # process module results
    my @discoveredModuleList = @{$discoverTask->{"moduleList"}};
    foreach my $module (@discoveredModuleList)
    {
        my $moduleName = $module->{"module"};
        my $moduleStatus = $module->{"status"};
        $DeviceStatus{$mip}{"discover_$moduleName"} = $moduleStatus;

        if ($moduleStatus eq "FAILED")
        {
            &printAndLog(STDOUT, 1,  "$mip     " . $moduleName . ": " . $module->{"errorMsg"} . "\n");
        }
    }
    return $success;
}

sub getImportParms {
    my %postBodyHash = ("skipDiscovery"=>"true", "snapshotWorkingConfig"=>"false", "useBigiqSync"=>"false" );
    if (defined $bigip->{"haname"})
    {
        $postBodyHash{"clusterName"} = $bigip->{"haname"};
        $postBodyHash{"useBigiqSync"} = "true";
    }
    return %postBodyHash;
}

#======================================================
# Import Modules for specified device
#======================================================
sub importModules {
    my ($mip) = @_;
    my $machineId = $DeviceStatus{$mip}{"machineId"};

    if ((defined $opt_l) and (defined $DeviceStatus{$mip}{"discover_adc_core"}))
    {
        $ltmSuccess = 0;
        if ($DeviceStatus{$mip}{"discover_adc_core"} eq "FINISHED")
        {
            %postBodyHash = getImportParms();
            $postBodyHash{"name"} = "import-adc_core_$mip";
            $postBodyHash{"createChildTasks"} = "false";
            $ltmSuccess = importModule($mip, "ltm", "https://localhost/mgmt/cm/adc-core/tasks/declare-mgmt-authority", %postBodyHash);
        }
    }

    if ((defined $opt_p) and (defined $DeviceStatus{$mip}{"discover_access"}))
    {
        $apmSuccess = 0;
        if ($DeviceStatus{$mip}{"discover_access"} eq "FINISHED")
        {
            # APM import is special case due to access groups
            $apmSuccess = importApm($mip, "https://localhost/mgmt/cm/access/tasks/declare-mgmt-authority");
        }
    }

    if ((defined $opt_s) and (defined $DeviceStatus{$mip}{"discover_asm"}))
    {
        $asmSuccess = 0;
        if ($DeviceStatus{$mip}{"discover_asm"} eq "FINISHED")
        {
            %postBodyHash = getImportParms();
            $postBodyHash{"name"}="import-asm_$mip";
            $postBodyHash{"createChildTasks"} = "true";
            $asmSuccess = importModule($mip, "asm", "https://localhost/mgmt/cm/asm/tasks/declare-mgmt-authority", %postBodyHash);
        }
    }

    if ((defined $opt_f) and (defined $DeviceStatus{$mip}{"discover_firewall"}))
    {
        $afmSuccess = 0;
        if ($DeviceStatus{$mip}{"discover_firewall"} eq "FINISHED")
        {
            %postBodyHash = getImportParms();
            $postBodyHash{"name"}="import-afm_$mip";
            $postBodyHash{"createChildTasks"} = "true";
            $afmSuccess = importModule($mip, "afm", "https://localhost/mgmt/cm/firewall/tasks/declare-mgmt-authority", %postBodyHash);
        }
    }

    if ((defined $opt_d) and (defined $DeviceStatus{$mip}{"discover_dns"}))
    {
        $dnsSuccess = 0;
        if ($DeviceStatus{$mip}{"discover_dns"} eq "FINISHED")
        {
            %postBodyHash = getImportParms();
            $postBodyHash{"name"}="import-dns_$mip";
            $postBodyHash{"createChildTasks"} = "false";
            $dnsSuccess = importModule($mip, "dns", "https://localhost/mgmt/cm/dns/tasks/declare-mgmt-authority", %postBodyHash);
        }
    }

    # only report success if all requested modules were successful
    if ((defined $ltmSuccess) and ($ltmSuccess eq 0))
    {
        return 0;
    }
    if ((defined $apmSuccess) and ($apmSuccess eq 0))
    {
        return 0;
    }
    if ((defined $asmSuccess) and ($asmSuccess eq 0))
    {
        return 0;
    }
    if ((defined $afmSuccess) and ($afmSuccess eq 0))
    {
        return 0;
    }
    if ((defined $dnsSuccess) and ($dnsSuccess eq 0))
    {
        return 0;
    }
    return 1;
}

#======================================================
# A subroutine for importing individual module.
#======================================================
sub importModule {
    my ($mip, $module, $dmaUrl, %postBodyHash) = @_;
    # if the -n option was passed, then we skip the import and return success
    if (defined $opt_n)
    {
        &printAndLog(STDOUT, 1, "$mip   $module import skipped as requested\n");
        $DeviceStatus{$mip}{"import_${module}_status"} = "SKIPPED";
        if ($module eq "afm" or $module eq "asm")
        {
            $DeviceStatus{$mip}{"import_security-shared_status"} = "SKIPPED";
        }
        return 1;
    }
    my $importStart = gettimeofday();
    my $machineId = $DeviceStatus{$mip}{"machineId"};

    my $url = $dmaUrl . "?\$filter=deviceReference/link+eq+'*$machineId*'";
    my $findImportTask = getRequest($url, "Find $module import task for $mip $machineId ");
    my @findImportTaskItems = $findImportTask->{"items"};
    my $importTask;
    my $success = 0;
    my $postBodyJson;
    my $importTaskLink;

    if (defined $findImportTask->{"items"}[0])
    {
        $importTaskLink = $findImportTask->{"items"}[0]->{"selfLink"};
        $importTask = deleteRequest($importTaskLink, "Delete $module existing import task for $mip");
        &printAndLog(STDOUT, 1, "$mip   $module existing import task deleted\n");
    }
    # POST a new import task
    $postBodyHash{"deviceReference"}{"link"} = "/cm/system/machineid-resolver/$machineId";
    $postBodyJson = encode_json(\%postBodyHash);

    $importTask = postRequest($dmaUrl, $postBodyJson, "Create $module import task for $mip");
    &printAndLog(STDOUT, 1, "$mip   $module import task " . $importTask->{"status"} . "\n");
    $importTaskLink = $importTask->{"selfLink"};

    # The task may finish but be pending conflicts (asm/afm) or child task conflicts (shared-security)
    # if we get conflicts, we mark then to use BIG-IQ, patch the task back to started, and poll again
    my $done = 0;
    my $loopCount = 0;
    my $importStatus = "";
    while (not $done)
    {
        $importTask = &pollTask($bigiqCreds, $importTaskLink, $opt_v);

        if ($loopCount++ > 5)
        {
            &printAndLog(STDOUT, 1, "$mip     Exiting import with max tries\n");
            last;
        }

        $importStatus = $importTask->{"status"};
        $DeviceStatus{$mip}{"import_${module}_status"} = $importStatus;

        my $currentStep = $importTask->{"currentStep"};
        my $importSelfLink = $importTask->{"selfLink"};

        if ($importStatus eq "FINISHED")
        {
            if (($currentStep eq "PENDING_CONFLICTS") or ($currentStep eq "PENDING_CHILD_CONFLICTS"))
            {
                &printAndLog(STDOUT, 1, "$mip     $currentStep\n");

                my @conflicts = @{$importTask->{"conflicts"}};
                if (resolveConflicts($mip, $module, $currentStep, $importSelfLink, @conflicts))
                {
                    $done = 0;
                }
                else
                {
                    # error resolving conflicts, give up
                    print "$mip     Import had error resolving conflicts, we are done\n";    # debug
                    $done = 1;
                    $success = 0;
                }
            }
            elsif (($currentStep eq "DONE") or ($currentStep eq "COMPLETE"))
            {
                # normal compleation
                $done = 1;
                $success = 1;
            }
            else
            {
                # finished at unknown step
                &printAndLog(STDOUT, 1, "$mip     Import finished with currentStep: $currentStep \n");
                $done = 1;
                $success = 0;
            }
        }
        elsif ($importStatus eq "FAILED")
        {
            $done = 1;
            $DeviceStatus{$mip}{"import_${module}_currentStep"} = $currentStep;
            $DeviceStatus{$mip}{"import_${module}_error"} = $importTask->{"errorMessage"};
            &printAndLog(STDOUT, 1, "$mip     Import ${module} failed, $currentStep $importTask->{'errorMessage'} \n");
            $success = 0;
        }
        else
        {
            $done = 1;
            &printAndLog(STDOUT, 1, "$mip     Import done with status: $importStatus \n");
            $success = 0;
        }
    } #end task loop

    my $importEnd = gettimeofday();
    my $et = sprintf("%d", $importEnd - $importStart);
    &printAndLog(STDOUT, 1, "$mip   $module import task $importStatus, $et seconds\n");

    return $success;
}

#======================================================
# A subroutine for importing APM.
#======================================================
# APM needs an access group.
# If none exist, one will be created.
# The name should be specified with the -g option, otherwise it will default to "access_group"
sub importApm {
    my ($mip, $dmaUrl,) = @_;

    # if the -n option was passed, then we skip the import and return success
    if (defined $opt_n)
    {
        &printAndLog(STDOUT, 1, "$mip   apm import skipped as requested\n");
        $DeviceStatus{$mip}{"import_access_status"} = "SKIPPED";
        return 1;
    }

    my $importStart = gettimeofday();

    # find access group name
    my $machineId = $DeviceStatus{$mip}{"machineId"};
    my $accessGroupName;

    # get access group name from command line.  Default to "access_group" if not specified
    # This is overriden for re-import cases
    if (defined $opt_g && $opt_g)
    {
        $accessGroupName = $opt_g;
    }
    else
    {
        $accessGroupName = "access_group";
    }

    # See if it's already in an access group
    $url = 'https://localhost/mgmt/cm/system/machineid-resolver';
    $resp = getRequest($url, "get resolver");
    $items = $resp->{"items"};
    my $newImport = 1;
    my $importShared = True;
    foreach my $item (@{$items})
    {
        if ($item->{"product"} ne "BIG-IP")
        {
            next;
        }
        $mgmtip = $item->{"address"};
        if (($mip eq $mgmtip) and (exists $item->{"properties"}->{"cm-access-allBigIpDevices"}->{"cm:access:access-group-name"} and\
             $item->{"properties"}->{"cm-access-allBigIpDevices"}->{"cm:access:access-group-name"} ne ""))
        {
            $accessGroupName = $item->{"properties"}->{"cm-access-allBigIpDevices"}->{"cm:access:access-group-name"};
            $newImport = 0;
            $importShared = False;
            last;
        }
    }

    # See if this access group is already imported for this new device import
    if ($newImport)
    {
        $url = "https://localhost/mgmt/shared/resolver/device-groups?\$filter='properties/cm:access:access_group'+eq+'true'";
        $resp = getRequest($url, "get resolver");
        $items = $resp->{"items"};
        foreach my $item (@{$items})
        {
            if (exists $item->{"groupName"} and $accessGroupName eq $item->{"groupName"})
            {
                $importShared = False;
                last;
            }
        }
    }
    my $postBodyJson;
    my %postBodyHash = ();
    my $success = 0;

    $postBodyHash{"properties"}{"cm:access:access-group-name"} = "$accessGroupName";
    $postBodyHash{"properties"}{"cm:access:import-shared"} = $importShared;

    $postBodyHash{"deviceReference"}{"link"} = "http://localhost/mgmt/cm/system/machineid-resolver/$machineId";
    $postBodyHash{"skipConfigDiscovery"} = "true";
    $postBodyJson = encode_json(\%postBodyHash);

    my $importTask = postRequest($dmaUrl, $postBodyJson, "Import apm $mip");
    &printAndLog(STDOUT, 1, "$mip   apm import task " . $importTask->{"status"} . " ($importShared $accessGroupName)\n");

    # finish import
    $importTask = &pollTask($bigiqCreds, $importTask->{"selfLink"}, $opt_v);
    my $importStatus = $importTask->{"status"};
    $DeviceStatus{$mip}{"import_access_status"} = $importStatus;

    my $importEnd = gettimeofday();
    my $et = sprintf("%d", $importEnd - $importStart);
    &printAndLog(STDOUT, 1, "$mip   apm import task $importStatus, $et seconds\n");

    my $currentStep = $importTask->{"currentStep"};
    my $importSelfLink = $importTask->{"selfLink"};

    if ($importStatus eq "FINISHED")
    {
        if (($currentStep ne "DONE") and ($currentStep ne "COMPLETE"))
        {
            &printAndLog(STDOUT, 1, "$mip   apm import task finished with currentStep: $currentStep \n");
            $success = 0;
        }
        else
        {
            $success = 1;
        }
    }
    elsif ($importStatus eq "FAILED")
    {
        $DeviceStatus{$mip}{"import_apm_currentStep"} = $currentStep;
        $DeviceStatus{$mip}{"import_apm_error"} = $importTask->{"errorMessage"};
        &printAndLog(STDOUT, 1, "$mip     apm import failed, $currentStep $importTask->{'errorMessage'} \n");
        $success = 0;
    }
    else
    {
        &printAndLog(STDOUT, 1, "$mip     apm import done with status: $importStatus \n");
        $success = 0;
    }
    # This is not as elegant as desired, but seems to be working
    if (($importStatus eq "FINISHED") and ($currentStep eq "PENDING_CONFLICTS"))
    {
        # Track we hit a conflict on the BIG-IP
        if ($DeviceStatus{$mip}{"conflict"} < 1)
        {
            $DeviceStatus{$mip}{"conflict"} = 1;
            $DeviceStatus{"all"}{"conflict"} ++;    #devices with conflicts;
        }
        &printAndLog(STDOUT, 1, "$mip     apm import accepting conflicts\n");
        # Perform simple accept patch to the task
        my $conflict_patch_data = "{\"status\":\"STARTED\",\"properties\":{\"cm:access:conflict-resolution\":\"accept\"}}";

        $resolveTask = patchRequest($importSelfLink, $conflict_patch_data, "access conflict resolution for $mip");
        $resolveLink = $resolveTask->{"selfLink"};
        $resolveTask = &pollTask($bigiqCreds, $resolveLink, $opt_v);
        $resolveStatus = $resolveTask->{"status"};
        $DeviceStatus{$mip}{"import_access_status"} = $resolveStatus;
        &printAndLog(STDOUT, 1, "$mip     apm import conflicts $resolveStatus\n");
        if ($resolveStatus eq "FINISHED")
        {
            $success = 1;
        }
    }
    return $success;
}

#======================================================
# A subroutine for resolving conflicts.
#======================================================

sub resolveConflicts {
    my ($mip, $module, $currentStep, $taskLink, @conflicts) = @_;
    my $conflictResolutionStart = gettimeofday();
    my $confRes = $DeviceStatus{$mip}{"confRes"};

    my $numConflicts = 0;
    if ($DeviceStatus{$mip}{"conflict"} < 1)
    {
        $DeviceStatus{$mip}{"conflict"} = 1;
        $DeviceStatus{"all"}{"conflict"} ++;    #devices with conflicts;
    }
    my $success = 1;

    # find the different configs and put the diffs in the log
    my @conflictStrs = ();
    foreach my $conflict (@conflicts)
    {
        if (ref($conflict) eq "HASH")
        {
            if ($conflict->{"fromReference"}{"link"})
            {
                my $fromRef = $conflict->{"fromReference"}{"link"};
                my $from = getRequest($fromRef, "show the 'from' (BIG-IQ working config)");
            }

            if ($conflict->{"toReference"}{"link"})
            {
                my $toRef = $conflict->{"toReference"}{"link"};
                my $to = getRequest($toRef, "show the 'to' (BIG-IP discovered config)");
            }

            $conflict->{"resolution"} = $confRes;

            # add this conflict to an array of them
            push(@conflictStrs, to_json($conflict));
            $numConflicts++;
        }
    }

    &printAndLog(STDOUT, 1, "$mip     Number of conflicts: $numConflicts  Resolution: $confRes\n");
    $DeviceStatus{$mip}{"conflicts"}{$module}{$currentStep} = $numConflicts;

    my $conflicts = join(",", @conflictStrs);

    # use a temp file for the conflict patch data since it micht be too big for the command line
    my $conflict_patch_data = "{\"status\":\"STARTED\",\"conflicts\":[$conflicts]}";
    &prettyPrintAndLogJson ($LOG, 0, $conflict_patch_data);

    my $resolveTask = patchRequest($taskLink, $conflict_patch_data, "conflict resolution for $mip");

    my $resolveLink = $resolveTask->{"selfLink"};
    $resolveTask = &pollTask($bigiqCreds, $resolveLink, $opt_v);

    # check, log error status
    my $conflictStatus = $resolveTask->{"status"};
    $DeviceStatus{$mip}{"resolve_${module}_status"} = $conflictStatus;

    my $conflictResolutionEnd = gettimeofday();
    my $et = sprintf("%d", $conflictResolutionEnd - $conflictResolutionStart);
    &printAndLog(STDOUT, 1, "$mip     Conflict resolution: $conflictStatus, $et seconds\n");
    if (defined $resolveTask->{"errorMessage"})
    {
        &printAndLog(STDOUT, 1, "$mip     $module Conflict resolution error: $resolveTask->errorMessage\n");
        $success = 0;
    }

    return $success;
}

sub showSummaryLine {
    my ($mip, $discover, $import, $module) = @_;
    my $string = sprintf("# $col1Fmt $colFmt", $module, "");
    if (defined $DeviceStatus{$mip}{$discover})
    {
        $string = $string  . sprintf(" $colFmt", $DeviceStatus{$mip}{$discover});
        if (defined $DeviceStatus{$mip}{$import})
        {
            $string = $string  . sprintf(" $colFmt", $DeviceStatus{$mip}{$import});
            my $conflictString = "";
            if (defined $DeviceStatus{$mip}{"conflicts"}{$module}{"PENDING_CONFLICTS"})
            {
                $conflictString = $conflictString  . " conflicts: " . $DeviceStatus{$mip}{"conflicts"}{$module}{"PENDING_CONFLICTS"};
            }
            if (defined $DeviceStatus{$mip}{"conflicts"}{$module}{"PENDING_CHILD_CONFLICTS"})
            {
                if (scalar $conflictString)
                {
                    $conflictString .= ",";
                }
                $conflictString = $conflictString  . " child conflicts: " . $DeviceStatus{$mip}{"conflicts"}{$module}{"PENDING_CHILD_CONFLICTS"};
            }
        $string = $string  . $conflictString;
        }
    }
    &printAndLog(STDOUT, 1, "$string\n");
}

#======================================================
# A subroutine for showing the summary.
#======================================================

sub showSummary {
    &printAndLog(STDOUT, 1, "#\n# $section_head\n");
    &printAndLog(STDOUT, 1, "# BULK DISCOVERY FINAL RESULTS\n#\n");

    my $string = sprintf "# $col1Fmt $colFmt $colFmt $colFmt",
            "IP address", "trust", "discovery", "import";
    &printAndLog(STDOUT, 1, "$string\n");

    for $href (@bigips) {

        my $mip = $href->{"mip"};

        # first line: ip, trust, overall-discovery
        $string = sprintf "#\n# $col1Fmt $colFmt $colFmt",
            $mip,
            $DeviceStatus{$mip}{"trust_status"},
            $DeviceStatus{$mip}{"discover_status"};
        &printAndLog(STDOUT, 1, "$string\n");
        if ($DeviceStatus{$mip}{"discover_status"} eq "FW_UPGRADE_FAILED")
        {
            next;
        }

        # next lines (one per module): module-name, discovery-status, import-status, conflict-counts
        if (defined $opt_l)
        {
            showSummaryLine ($mip, "discover_adc_core", "import_ltm_status", "ltm");
        }

        if (defined $opt_p)
        {
            showSummaryLine($mip, "discover_access", "import_access_status", "access");
        }

        if (defined $opt_s)
        {
            showSummaryLine($mip, "discover_asm", "import_asm_status", "asm");
        }

        if (defined $opt_f)
        {
            showSummaryLine ($mip, "discover_firewall", "import_afm_status", "afm");
        }

        # shared-security
        if (defined $DeviceStatus{$mip}{"discover_security_shared"})
         {
            $string = sprintf("# $col1Fmt $colFmt $colFmt", "shared-security", "", $DeviceStatus{$mip}{"discover_security_shared"});
            if (defined $DeviceStatus{$mip}{"import_security-shared_status"})
            {
                $string = $string  . sprintf(" $colFmt", $DeviceStatus{$mip}{"import_security-shared_status"});
            }
            &printAndLog(STDOUT, 1, "$string\n");
        }
        if (defined $opt_d)
        {
            showSummaryLine ($mip, "discover_dns", "import_dns_status", "dns");
        }

     }
}

#======================================================
# A subroutine for showing the errors.
#======================================================

sub showErrors {

    &printAndLog(STDOUT, 1, "#\n# Errors\n");
    &printAndLog(STDOUT, 1, "$table_head\n");

    my $string;
    for $href (@bigips) {
        my $mip = $href->{"mip"};

        # general discovery error
        if (defined $DeviceStatus{$mip}{"trust_error"})
        {
            $string = sprintf "# $col1Fmt $colFmt %s",
                $mip, "trust", $DeviceStatus{$mip}{"trust_error"};
            &printAndLog(STDOUT, 1, "$string\n");
        }

        # general discovery error
        if (defined $DeviceStatus{$mip}{"discover_error"})
        {
            $string = sprintf "# $col1Fmt $colFmt %s",
                $mip, "discover", $DeviceStatus{$mip}{"discover_error"};
            &printAndLog(STDOUT, 1, "$string\n");
        }

        # module specific discovery and import errors
        my @modules = ("ltm", "apm", "asm", "afm");    #shared-security?
        foreach my $module (@modules)
        {
            if (defined $DeviceStatus{$mip}{"discover_${module}_errorMessage"})
            {
                $string = sprintf "# $col1Fmt $colFmt $colFmt %s", $mip, $module, "discover", $DeviceStatus{$mip}{"discover_error"};
                &printAndLog(STDOUT, 1, "$string\n");
            }

            if (defined $DeviceStatus{$mip}{"import_${module}_error"})
            {
                $string = sprintf "# $col1Fmt $colFmt $colFmt", $mip, $module, "import";
                if (defined $DeviceStatus{$mip}{"import_${module}_currentStep"})
                {
                    $string = $string . sprintf " $colFmt", $DeviceStatus{$mip}{"import_${module}_currentStep"}
                }
                $string = $string . " " . $DeviceStatus{$mip}{"import_${module}_error"};
                &printAndLog(STDOUT, 1, "$string\n");
            }
        }
    }
}

#======================================================
# A subroutine for total counts.
#======================================================

sub showTotals {

    my $string = sprintf "#\n# %-10s %-10s %-10s",
        "Success", "Failed", "Conflict";

    &printAndLog(STDOUT, 1, "$string\n");
    &printAndLog(STDOUT, 1, "$table_head\n");

    $string = sprintf "# %-10s %-10s %-10s",
        $DeviceStatus{"all"}{"success"},
        $DeviceStatus{"all"}{"failure"},
        $DeviceStatus{"all"}{"conflict"};
    &printAndLog(STDOUT, 1, "$string\n");
}

#======================================================
# A subroutine to take a string and return a copy with all
# the passwords masked out.
#======================================================
sub maskPasswords {
    my ($pwStr) = @_;

    $pwStr =~ s/"password":".*?"/"password":"XXXXXX"/g;
    $pwStr =~ s/"adminPassword":".*?"/"adminPassword":"XXXXXX"/g;
    $pwStr =~ s/"rootPassword":".*?"/"rootPassword":"XXXXXX"/g;

    return $pwStr;
}

#======================================================
# A subroutine for polling a task until it reaches a conclusion.
# $creds are the admin credentials for the curl call
# $taskLink is the URI to the POSTed task
#======================================================
sub pollTask {
    my ($creds, $taskLink, $printToo) = @_;

    # keep asking for status and checking the answer until the answer is conclusive
    &printAndLog(STDOUT, $printToo, "Polling for completion of '$taskLink'\n");
    my ($taskjpath, $taskdpath, $result, $ct, $taskanswer) = ("", "", "", 1, "");
    my $ctCurly = 0;
    do {
        sleep 5;
        ($taskanswer) = getRequest($taskLink, "Polling for completion of '$taskLink' Attempt $ct");

        if ($taskanswer->{"status"} =~ /^(FINISHED|CANCELED|FAILED|COMPLETED(_WITH_ERRORS)?)/) {
            $result = $taskanswer->{"status"};
        }
        $ct++;
    } while ($result eq "");
    &printAndLog(STDOUT, $printToo, "Finished - '$taskLink' got a result of '$result'.\n");

    # return the JSON pointer
    return $taskanswer;
}

#======================================================
# A subroutine for creating a csv file for use by re-discovery
#======================================================
sub generateCsv {
    login();
    my ($csvFile, $cr) = @_;
    open (CSV, ">$csvFile") || die "Unable to write the CSV file, '$csvFile'\n";

    $url = 'https://localhost/mgmt/cm/system/machineid-resolver';
    $resp = getRequest($url, "get resolver");
    $items = $resp->{"items"};
    foreach my $item (@{$items})
    {
        if ($item->{"product"} ne "BIG-IP")
        {
            next;
        }
        $mgmtip = $item->{"address"};
        $ver = $item->{"version"};
        $props = $item->{"properties"}->{"cm-bigip-allBigIpDevices"};
        $clusterName = "";
        if (exists $props->{"clusterName"})
        {
	    $clusterName = $props->{"clusterName"};
        }
        # If the version is 11.x then we will most likely need to upgrade the framework
        # Making it skip for now so no creds are required.
        if ($ver =~ m/^11/)
        {
            print CSV "$mgmtip,ADMIN,APWD,$clusterName,skip,ROOT,RPWD,$cr\n";
        } else {
            print CSV "$mgmtip,ADMIN,APWD,$clusterName,,,,$cr\n";
        }
    }
    close CSV;
}

#======================================================
# A subroutine for both printing to whatever file is given
# and printing the same thing to a log file.
# This script does a lot, so it may be useful to keep a log.
#======================================================
sub printAndLog {
    my ($FILE, $printToo, @message) = @_;

    my $message = join("", @message);
    print $FILE $message if ($printToo);
    print LOG $message;
}


#======================================================
# pretty format, mask passwords, and log a json string
#======================================================
sub prettyPrintAndLogJson {
    my ($FILE, $printToo, $jsonString) = @_;

    my $jsonWorker = JSON->new->allow_nonref;
    my $jsonHash = $jsonWorker->decode($jsonString);
    my $showRet = $jsonWorker->pretty->encode($jsonHash);
    my $maskln = &maskPasswords($showRet);
    &printAndLog($FILE, $printToo, "$maskln\n");
}

#======================================================
# Print the log file and then exit, so the user knows which log
# file to examine.
#======================================================
sub gracefulExit {
    my ($status) = @_;
    &printAndLog(STDOUT, 1, "# Discovery log file: $log\n");
    close LOG;
    exit($status);
}

#======================================================
# Pretty-print the time.
#======================================================
sub getTimeStamp {
    my ($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time);
    my $time_string = sprintf ("%02d/%02d/%02d %02d:%02d:%02d",$Month+1,$Day,$Year+1900,$Hour,$Minute,$Second);
    return ($time_string);
}