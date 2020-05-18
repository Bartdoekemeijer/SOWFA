import numpy as np
from zmqserver import ZmqServer
import logging
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%Y-%m-%d %H:%M',
                    filename='SSC_out.log',
                    filemode='w')
logger = logging.getLogger('controller')

logger.info("Initialising ZMQ server")
# Set up the ZMQ server for communication with SOWFA
# Make sure port is unique and set same in constant/turbineArrayProperties
zmq_server = ZmqServer(port=1876, timeout=3600)
logger.info("ZMQ server initialised")

# Specify number of turbines
num_turbines = 2

# Prepare yaw and pitch control signals
yaw_angle_output = 270. * np.ones(num_turbines)
pitch_angle_output = np.zeros(num_turbines)

logger.info("Entering wind farm control loop:")
# todo: Find a suitable end condition that replaces server receive timeout
while True:
    # Receive simulation time and measurements from SOWFA
    current_time, measurement_array = zmq_server.receive()

    # Measurements depend on SOWFA configuration
    power_generator = measurement_array[0::num_turbines]
    torque_rotor = measurement_array[1::num_turbines]
    thrust = measurement_array[2::num_turbines]

    # do something with measurements
    # construct control signals

    if current_time < 10:
        yaw_angle_output[0] = 260.
    elif 10 <= current_time < 30:
        yaw_angle_output[0] = 290.
    else:
        yaw_angle_output[0] = 305.

    if current_time < 20:
        yaw_angle_output[1] = 265.
    elif 20 <= current_time < 40:
        yaw_angle_output[1] = 275.
    else:
        yaw_angle_output[1] = 270.

    # Send control signals to SOWFA
    logger.debug("Sending yaw signal: {}".format(yaw_angle_output))
    logger.debug("Sending pitch signal: {}".format(pitch_angle_output))
    zmq_server.send(yaw_angle_output, pitch_angle_output)
