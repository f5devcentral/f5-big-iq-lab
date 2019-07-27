#! /usr/bin/env python

import httplib
import sys
from os import listdir
from os.path import isfile, join
from BaseHTTPServer import BaseHTTPRequestHandler
from StringIO import StringIO
from optparse import OptionParser
import time
import math


current_milli_time = lambda: int(round(time.time() * 1000))

class HTTPRequest(BaseHTTPRequestHandler):
    def __init__(self, request_text):
        self.rfile = StringIO(request_text)
        self.raw_requestline = self.rfile.readline()
        self.error_code = self.error_message = None
        self.parse_request()
        self.body = ""
        self.headers = {}
        self.length = 0
        rfile = StringIO(request_text)
        line = rfile.readline() #skip request line
        line = rfile.readline()
        while (len(line.strip())>0):
#            print line.strip()
            ar = line.split('=')
            key = ar[0].strip().lower()
            val = ar[1].strip()
#            print "  got: '" + key + "' : '" + val + "'"
            if (key == 'content-length'):
                self.length = int(val)
            else:
                self.headers[key] = val
            line = rfile.readline()
        
        if (self.length > 0):
            self.body = rfile.read()
            self.length = len(self.body)
 
    def send_error(self, code, message):
        self.error_code = code
        self.error_message = message

    

if __name__ == '__main__':

    TCP_PORT = 8008
    mypath = "data/"
    parser = OptionParser(usage="Usage: python rate-ht-sender.py --rate <rate per sec> --log-iq <IP Address>")
    parser.add_option ("-l", "--log-iq", dest='logiq', help="IP address of the LOG-IQ")
    parser.add_option ("-r", "--rate", dest='rate', default=100000, help="desired send rate per second")
    if len(sys.argv) < 2:
       parser.error("Insufficient arguments - please use -l to provide the IP address for the logging node")
       sys.exit(1)
    (options, args) = parser.parse_args()
    SERVER = options.logiq

    onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]
    #print onlyfiles
    
    
    start = current_milli_time()
    delta = round(1000.0/int(options.rate))
    iteration = 0
    print "rate is " + str(delta) + " per ms"
    
    for currFile in onlyfiles:
        diff = (delta*iteration) - current_milli_time() + start
        if (diff > 10):
#            print "sleeping " + str(diff/1000)
            time.sleep(diff/1000.0)
            
        iteration += 1
        print "\n\nAlert file: " + currFile + ", Destination: " + SERVER + ":", TCP_PORT
        with open(mypath+currFile, "rb") as myfile:
            alert = HTTPRequest(myfile.read())
            if (alert.error_code):
                print "Error! " + str(alert.error_code) + " " + alert.error_message
                continue
            
            conn = httplib.HTTPConnection(SERVER, TCP_PORT)
#            print "\nSending this to the Logging Node:"
#            print alert.command, alert.path, alert.body, alert.headers
            conn.request(alert.command, alert.path, alert.body, alert.headers)
            r2 = conn.getresponse()
            print "\nThe Logging Node's response:"
            print r2.status, r2.reason
            r2.read()
            conn.close()
            
    end = current_milli_time()
    print "Average time between alerts " +str((end-start)/iteration)