import numpy as np
from zmqserver import ZmqServer
import re
import logging
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%Y-%m-%d %H:%M',
                    filename='SSC_out.log',
                    filemode='w')
logger = logging.getLogger('controller')

logger.info("Initialising ZMQ server")
# Set up the ZMQ server for communication with SOWFA
# Port is taken from definition in constant/turbineArrayProperties
with open('../constant/turbineArrayProperties') as f:
    address_regex = r"tcp://localhost:\d{4}"
    client_addres = re.search(address_regex,f.read()).group()
    port = int(client_addres[-4:])
    
zmq_server = ZmqServer(port=port, timeout=3600)
logger.info("ZMQ server initialised")

# Specify number of turbines
num_turbines = 2

# Prepare yaw and pitch control signals
torque_output = 0. * np.ones(num_turbines)
yaw_angle_output = 270. * np.ones(num_turbines)
pitch_angle_output = 0. * np.ones(num_turbines)

logger.info("Entering wind farm control loop:")
# todo: Find a suitable end condition that replaces server receive timeout
while True:
    # Receive simulation time and measurements from SOWFA
    current_time, measurement_array = zmq_server.receive()

    # Measurements depend on SOWFA configuration as specified in:
    # src/turbineModels/turbineModelsStandard/horizontalAxisWindTurbinesADM/controllers/measurementfunctions/default.H
    generator_power = measurement_array[0::8]
    rotor_speed = measurement_array[1::8]
    azimuth_angle = measurement_array[2::8]
    rotor_thrust = measurement_array[3::8]
    rotor_torque = measurement_array[4::8]
    generator_torque = measurement_array[5::8]
    nacelle_yaw = measurement_array[6::8]
    blade_pitch = measurement_array[7::8]

    logger.debug("Current time: {}".format(current_time))
    logger.debug("Generator power: {}".format(generator_power))

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
    zmq_server.send(torque_output, yaw_angle_output, pitch_angle_output)
