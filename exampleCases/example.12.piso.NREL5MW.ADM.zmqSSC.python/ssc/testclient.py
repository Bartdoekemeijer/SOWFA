# Test client for SOWFA SSC
# Sends messages of similar format

import numpy as np
import zmq
import logging
logger = logging.getLogger("testclient")

context = zmq.Context()

#  Socket to talk to server
logger.info("SOWFA test client connecting to server")
socket = context.socket(zmq.REQ)
socket.connect("tcp://localhost:1876")

#  Do 10 requests, waiting each time for a response
measurements = np.linspace(0, 6, 7)
for request in range(10):

    logger.info("Sending measurement series {}".format(request))
    measurements[0] = request
    measurement_string = " ".join(["{:.6f}".format(x) for x in measurements]).encode()

    socket.send(measurement_string)
    logger.info("Sent measurements: {}".format(measurement_string))

    #  Get the reply.
    message = socket.recv()
    logger.info("Received reply {}: {}".format(request, message))
