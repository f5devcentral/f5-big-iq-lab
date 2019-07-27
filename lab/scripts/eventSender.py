#! /usr/bin/env python

import httplib
import logging
import sys
import re
import socket
from os import listdir
from os.path import isfile, isdir, join
from StringIO import StringIO
from optparse import OptionParser
from random import *
from time import sleep

LOGGER = logging.getLogger(__name__)


class getEvent():
    def __init__(self, request_text):
        self.rfile = StringIO(request_text)
        self.raw_requestline = self.rfile.readline()
        self.length = 0
        rfile = StringIO(request_text)
        line = rfile.readline()


def send_alerts(mypath, server, tcp_port=8020, verbose=False):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((server, tcp_port))
    onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]
    for currFile in onlyfiles:
        print mypath + currFile
        with open(mypath + currFile, "rb") as myfile:
            if verbose:
                print "\n\n---------- Alert file: " +  mypath + currFile + ", Destination: " + server + ":", tcp_port
            attackID = -1
            for event in myfile:
                LOGGER.debug("Sending this to the Logging Node:")
                if attackID == -1:
                    attackID = str(randint(0000000000, 9999999999))
                if event.find("dos_attack_id") > -1:
                    newattackID = "dos_attack_id="+attackID
                    event = re.sub(r"dos_attack_id=\"(.*?)\"", newattackID, event)
                if verbose:
                    print server
                    print tcp_port
                    print "\nSending this to the Logging Node:"
                    print event
                if event.find("Attack Stopped") > -1 or event.find("Attack ended") > -1:
                    sleep(2)
                sock.send(event)
    sock.shutdown(socket.SHUT_RDWR)
    sock.close()


if __name__ == '__main__':

    parser = OptionParser(usage="Usage: python htSender.py -l <IP Address>")
    parser.add_option("-l", "--log-iq", dest='logiq', help="IP address of the LOG-IQ")
    parser.add_option("-p", "--path", dest="path", help="Absolute path upto data directory containing alerts",
                      default=".")
    parser.add_option("-v", "--verbose", dest='verbose', help="Enable logging during alert sending",
                      action='store_true')
    parser.add_option("-t", "--tcp-port", dest="port", help="TCP port to be used for connection, only needed for HTTP",
                      default=8020)
    if len(sys.argv) < 2:
        parser.error("Insufficient arguments - please use -l to provide the IP address for the logging node")
        sys.exit(1)
    (options, args) = parser.parse_args()
    verbose = False
    SERVER = options.logiq
    path_to_alert_files_folder = options.path
    if (options.verbose):
        verbose = options.verbose
    if (options.port):
        port = options.port
    mypath = "{0}/data/".format(path_to_alert_files_folder)
    send_alerts(mypath=mypath, server=SERVER, verbose=verbose, tcp_port=port)