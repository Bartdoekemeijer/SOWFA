import numpy as np
import zmq
from io import StringIO
import logging
logger = logging.getLogger("zmq_server")


class ZmqServer:
    def __init__(self, port, timeout=3600):
        self._port = port
        self._timeoutBufferSeconds = timeout

        self._last_message_sent_string = ""
        self._last_message_sent_data = []
        self._last_message_received_string = ""
        self._last_message_received_data = []

        self._status = "initialised"

        self._context = None
        self._socket = None
        self.connect()

    def connect(self):
        address = "tcp://*:{}".format(self._port)
        logger.info("Connecting to {}".format(address))
        self._context = zmq.Context()
        self._socket = self._context.socket(zmq.REP)
        self._socket.setsockopt(zmq.RCVTIMEO, self._timeoutBufferSeconds * 1000)
        self._socket.bind(address)
        self._status = "connected"
        logger.info("Connected.")

    def disconnect(self):
        logger.info("Disconnecting from tcp://*:{}".format(self._port))
        self._socket.close()
        logger.info("Disconnected.")

    def receive(self):
        try:
            message = self._socket.recv()
        except zmq.Again as e:
            logger.error("Did not receive message - Timed out in {} seconds.".format(self._timeoutBufferSeconds))
            logger.error(e.strerror, exc_out=1)
            self.disconnect()
            raise TimeoutError

        # raw message contains a long useless tail with b'\x00' characters
        # split off the tail before decoding into a Python unicode string
        json_data = message.split(b'\x00', 1)[0].decode()
        received_data = np.loadtxt(StringIO(json_data), delimiter=' ')
        logger.debug("Received measurements: {}".format(received_data))

        self._last_message_received_string = json_data
        self._last_message_received_data = received_data

        current_time = received_data[0]
        measurement_array = received_data[1:]
        return current_time, measurement_array

    def send(self, torque_ref, yaw_ref, pitch_ref):
        # Construct control signal array as expected by SOWFA
        data_send = np.array([[torque, yaw, pitch] for torque, yaw, pitch in zip(torque_ref,yaw_ref, pitch_ref)]).ravel()
        string_data = ["{:.6f}".format(d) for d in data_send]
        string_send = " ".join(string_data)

        message = string_send.encode()
        self._socket.send(message, 0)
        logger.debug("Sent controls: {}".format(data_send))

        self._last_message_sent_string = string_send
        self._last_message_sent_data = data_send
