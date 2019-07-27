#! /usr/bin/env python

import time
import os
import random
import string
import getopt
import sys
import os.path


#version: 1.1
#change list
#1.1 adds command line option parsing for IP network, number of IPs to use, times to repeat, seconds to wait between loops, you vip addr and file to use
#change file format to only need the unique part of the url and params vs the whole http URL
#if user does not specify a base network, then we'll create a very random address for the X-FORWARD-FOR

def usage():
    print (
    " -n base IP network a.b.c for X-Forward-For \n" +
    " -r number of IPs to use starting at 0 - if -n is not used then this is just a loop counter for the number of client ips \n" + 
    " -c number of times to repeat \n" + 
    " -w seconds to wait between loops\n" + 
    " -v myVipAddress\n" + 
    " -t file or random\n" +
    " -f file we should use for violations\n" +
    " -l file we should use for loading vips\n" )

    #...

def loadDataFromFile (myFileName):
    fo = open(myFileName , "r")
    violations = fo.read().splitlines()
    fo.close()
    return violations;

def loadVipsFromFile (myFileName):
    fo = open(myFileName , "r")
    violations = fo.read().splitlines()
    fo.close()
    return violations;

def getViolation (violationList, violationNumber, myVip):
    #myNewViolation= violationList[violationNumber]
    myNewViolation = makeMethod() + "http://" + myVip +" "+ violationList[violationNumber] 
    
    return myNewViolation;

def makeViolation (myVip, myRange, myIndex):
    newExtension = makeExtension(3)
    myNewViolation= makeParamViolation(myVip, newExtension, myRange)
    return myNewViolation;
    
def makeParamViolation (myVip, myParam, myRange):
    #int(myRange)
    paramValues = ["", "="+makeExtension(5), "=0", "=", "=?hostname", "=0&password=text"]
    qtyValues = len(paramValues)
    myValue = paramValues[random.randint(1,qtyValues)-1]
    myNum = random.randint(1,myRange) 
    myNewParamViolation = makeMethod() + "http://" + myVip + "/" + makeURL() + "?" + myParam + str(myNum) + myValue
    return myNewParamViolation;

def makeExtension (myRange):
    myString = ""
    for i in range(1,myRange+1,1):
       myString = myString + random.choice(string.letters)
    return myString;

def makeCookie ():
    myCookie = "\"name=turtle;path=/;expires=Wednesday, 09-Nov-2011 23:00:00 GMT\""
    myCookieString = "-b " + myCookie + " "
    #randomly return no cookie
    cookieWizardSays = (random.randint(0,1))
    if (cookieWizardSays == 0):
       myCookieString = " "

    return myCookieString;

def makeMethod ():
    methodList = ["GET", "POST", "PATCH", "DELETE", "TOAST"]
    qtyMethods = len(methodList)
    myMethod = methodList[random.randint(1,qtyMethods)-1]
    myMethodString = "-X " + myMethod + " "
    return myMethodString;

def makeURL ():
    urlList = [".", "login.aspx", "test"+"."+makeExtension(3), "test/pictures"+"."+makeExtension(1), ""]
    qtyUrls = len(urlList)
    myURL = urlList[random.randint(1,qtyUrls)-1]
    return myURL;

def makeHeader (fakeAddress):
    myHeader = "--header \"X-Forwarded-For: " + fakeAddress + "\" " 
    return myHeader;     


#main
def main ():

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hn:r:c:w:v:t:f:l:")
    except getopt.GetoptError as err:
        #print my help info
        usage("This is the error")
        sys.exit()

    ipBaseNet = None #what fake network do I want to use. Used for the X-Forwarded-For
    ipHostRange = 10 # how many fake addresses do I want to loop through for the differnt XFF headers
    loopCount = 10 # how many times do I want to loop through the violations for each fake IP address
    loopWait = 1 # number of seconds to wait between runs for differnt IPs
    myVip = "10.44.248.165" #This is my VIP
    myRange = 1 # range used for xxxxx
    testType = "random" # random or file
    violationsFileName = "cpbNorEaster.txt"
    vipFileName = None


    for o, optValue in opts:
        if o == "-n":
            ipBaseNet = optValue
        elif o == "-r":
            ipHostRange = int(optValue)
        elif o == "-c":
            loopCount = int(optValue)
        elif o == "-w":
            loopWait = int(optValue)
        elif o == "-v":
            myVip = optValue
        elif o == "-l":
            vipFileName = optValue
        elif o == "-t":
            testType = optValue
            if not ((testType == "random") or (testType == "file")): 
                print ("HEY!!!! unrecognized test type\n")
                usage()
                sys.exit()
        elif o == "-f":
            violationsFileName = optValue
            testType == "file"
        elif o == "-h":
            usage()
            sys.exit()
        else:
            assert False, "unhandled option"
    # ...
    
   

    #print the current settings for the test 
    print ("network is " + str(ipBaseNet) + "\n")
    print ("host range is " + str(ipHostRange) + "\n")
    print ("loop count is " + str(loopCount) + "\n")
    print ("loop wait is " + str(loopWait) + "\n")
    print ("target vip is " + str(myVip) + "\n")
    print ("test type is " + str(testType) + "\n")
    print ("violations file " + str(violationsFileName) + "\n")
    print ("vip file " + str(vipFileName) + "\n")

    #here is where we start processing the VIP file
    if not (vipFileName == None): 
        vipList = loadVipsFromFile (vipFileName)
        qtyVips = len(vipList)
    else:
        vipList = [myVip]
        qtyVips = len(vipList)
    print ("INFO: qty of vips " + str(qtyVips) + "\n")

    violations = loadDataFromFile (violationsFileName)
    qtyViolations = len(violations)

    #How many full cycles to run
    for x in range (1,loopCount+1,1):
   
        #how many vips do I need to target  
        for vips in range (0, qtyVips, 1):
            myVip = vipList[vips] 

            #how many clients do I want to simulate sending each violation
            for y in range (1,ipHostRange+1,1):
                #if user does not specify a base network address, use a really random address
                if (ipBaseNet == None):
                    fakeAddress = ".".join(map(str, (random.randint(1, 254) for _ in range(4)))) 
                else:      
                    fakeAddress = ipBaseNet + str(y)
                
                myViolation = (random.randint(0, qtyViolations -1))
      
                if testType == "file": 
                    #make a violation from somthing you've read from the file  
                    cmd = "curl -k -i " +  makeCookie() + makeHeader(fakeAddress) + getViolation(violations, myViolation, myVip)
                    status = os.system(cmd)
                    print (cmd + "\n")
                    print (status)

                if testType == "random":
                    cmd = "curl -k  -i " + makeCookie() + makeHeader(fakeAddress) + makeViolation(myVip, myRange, y)
                    status = os.system(cmd)
                    print (cmd + "\n")
                    print (status)

        print ("loop count " + str(x) + "\n") 
        time.sleep (loopWait)

    #print the current settings for the test 
    print ("Summary: " +  "\n")
    print ("Network is: " + str(ipBaseNet) + "\n")
    print ("Host range is: " + str(ipHostRange) + "\n")
    print ("Loop count is: " + str(loopCount) + "\n")
    print ("Loop wait is: " + str(loopWait) + "\n")
    print ("Target vip is: " + str(myVip) + "\n")
    print ("Test type is: " + str(testType) + "\n")
    print ("Violations file: " + str(violationsFileName) + "\n")
    print ("Vip file: " + str(vipFileName) + "\n")
    print ("Number of VIPs tested: " + str(qtyVips) + "\n")
    print ('Done.\n')

if __name__ == "__main__":
    main()




#TODO 


