#!/usr/bin/python

# Function to discover all nodes on the 3me cluster
def importNodelist(verbose=False):
    import subprocess
    import numpy as np
    nodelist = []
    
    cmd = ["/opt/ud/torque-4.2.10/bin/pbsnodes"]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    for line in proc.stdout.readlines():
        idxStart = line.find("n06-")
        idxEnd = line.find(" ",idxStart)
        if idxEnd > 0:
            nodelist.append(line[idxStart:idxEnd])
    
    if len(nodelist) >= 1 & verbose:
        print "Nodes found through pbsnodes."
        
    if len(nodelist) < 1:
        nodelist = ['n06-153', 'n06-152', 'n06-151', 'n06-150', 'n06-142', 'n06-141', 'n06-140', 'n06-139', 'n06-138', 'n06-137', 'n06-136', 'n06-135', 'n06-134', 'n06-133', 'n06-132', 'n06-131', 'n06-129', 'n06-128', 'n06-127', 'n06-126', 'n06-125', 'n06-124', 'n06-123', 'n06-122', 'n06-121', 'n06-120', 'n06-119', 'n06-118', 'n06-117', 'n06-116', 'n06-115', 'n06-114', 'n06-113', 'n06-112', 'n06-111', 'n06-110', 'n06-109', 'n06-108', 'n06-107', 'n06-106', 'n06-105', 'n06-104', 'n06-103', 'n06-102', 'n06-101', 'n06-100', 'n06-99', 'n06-98', 'n06-97', 'n06-96', 'n06-95', 'n06-71', 'n06-70', 'n06-69', 'n06-68', 'n06-67', 'n06-66', 'n06-65', 'n06-64', 'n06-63', 'n06-62', 'n06-61', 'n06-60', 'n06-59', 'n06-58', 'n06-57', 'n06-56', 'n06-55', 'n06-54', 'n06-53', 'n06-52', 'n06-51', 'n06-50', 'n06-49', 'n06-48', 'n06-47', 'n06-46', 'n06-44', 'n06-43', 'n06-42', 'n06-41', 'n06-40', 'n06-39', 'n06-38', 'n06-37', 'n06-36', 'n06-35', 'n06-34', 'n06-33', 'n06-32', 'n06-31', 'n06-30', 'n06-29', 'n06-28', 'n06-25', 'n06-24', 'n06-23', 'n06-22', 'n06-20', 'n06-19', 'n06-18', 'n06-17', 'n06-16', 'n06-15', 'n06-14', 'n06-13', 'n06-12', 'n06-11', 'n06-10', 'n06-09', 'n06-08', 'n06-07', 'n06-06', 'n06-05', 'n06-04', 'n06-03', 'n06-02', 'n06-01', 'n06-149', 'n06-21', 'n06-26', 'n06-27']
        if verbose:
            print "Cannot connect to PBS server. Nodes found through database."
          
    if verbose:
        print('Nodelist:')
        print(nodelist)
        print('')

    return nodelist
    

# Check if a port is already taken on any of the nodes
def checkPortAvailability(nodelist,port,verbose=False):
    import subprocess
    portAvailable = True # Initial condition
    for node in nodelist:
        cmd = ['/bin/nc', '-zvw10', node, str(port)]
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        for line in proc.stdout.readlines():
            if "Connected to" in line: # Positive connection
                portAvailable = False
            if verbose:
                print('    ' + line.replace('\n',''))
        if portAvailable:
            if verbose:
                print "  Node " + node + " has no port conflict."
        else:
            if verbose:
                print "  Node " + node + " has a port conflict."
            break
    return portAvailable


# Find a free port on the cluster
def findPort(startIdx=1600,endIndx=1999,verbose=False):
    import random
    portArray = range(startIdx,endIndx)
    random.shuffle(portArray) # Shuffle order to increase chances of uniqueness
    nodelist = importNodelist(verbose) # Import nodelist
    
    portAvailability = False
    for port in portArray:
        if verbose:
            print "Testing port " + str(port) + "."
        portAvailability = checkPortAvailability(nodelist,port,verbose)
        
        if portAvailability:
            print "Found an available port: " + str(port) + "."
            return port
        else:
            print "Port " + str(port) + " is already taken.\n"

    print "Did not find an available port."
    return -1
       

# Update simulation files with the new port
def updatePortInFiles(newPort):
    import numpy as np
    
    # Replace port entry in SSC.m
    with open("ssc/SSC.m") as f:
        oldTextSSC=f.read()
        idxZeromqObjLine = oldTextSSC.find('zeromqObj(')
        startIdxPort = oldTextSSC.find(',',idxZeromqObjLine)+1
        endIdxPort = oldTextSSC.find(',',startIdxPort)
        oldPort = oldTextSSC[startIdxPort:endIdxPort]
        newTextSSC = oldTextSSC[0:startIdxPort] + str(newPort) + oldTextSSC[endIdxPort::] # Create new text
        
    with open("ssc/SSC.m", "w") as f:
        f.write(newTextSSC)
    
    print "Replaced port " + oldPort + " in SSC.m with port " + str(newPort) + "."
    
    
    # Replace port entry in constant/turbineArrayProperties
    with open("constant/turbineArrayProperties") as g:
        oldTextTAP=g.read()
        startIdxPort = oldTextTAP.find('tcp://localhost:') + 16
        endIdxPort = oldTextTAP.find('"',startIdxPort)
        oldPort = oldTextTAP[startIdxPort:endIdxPort]
        newTextTAP = oldTextTAP[0:startIdxPort] + str(newPort) + oldTextTAP[endIdxPort::] # Create new text
        
    with open("constant/turbineArrayProperties", "w") as g:
        g.write(newTextTAP)
    
    print "Replaced port " + oldPort + " in constant/turbineArrayProperties with port " + str(newPort) + "."
    
    
# Demo with verbose on
port = findPort(verbose=True)
updatePortInFiles(port)