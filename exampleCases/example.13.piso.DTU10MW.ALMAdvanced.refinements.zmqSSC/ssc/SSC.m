%% SSC EXAMPLE FUNCTION

% Setup zeroMQ server
zmqServer = zeromqObj('/home/bmdoekemeijer/OpenFOAM/zeroMQ/jeromq-0.4.4-SNAPSHOT.jar',1711,3600,true);

% Load the yaw setpoint LUT and set-up a simple function
nTurbs = 2;

% Initial control settings
yawAngleArrayOut = 270.*ones(1,nTurbs);
pitchAngleArrayOut = 0.0*ones(1,nTurbs);

% Start control loop
disp(['Entering wind farm controller loop...']);
while 1
    % Receive information from SOWFA
    dataReceived = zmqServer.receive();
    currentTime  = dataReceived(1,1);
    measurementVector = dataReceived(1,2:end); % [generatorPower[1], rotorSpeed[1], rotorAxialForce[1], generatorPower[2], rotorSpeed[2], rotorAxialForce[2]]
    
    powerGenerator = measurementVector(1:nTurbs:end);
    torqueRotor = measurementVector(2:nTurbs:end);
    thrust = measurementVector(3:nTurbs:end);

    % Do something with our measurements
    % ...
    
    % Generate new control signals: dynamic induction control
    Freq = 0.25*8.0/178.3;
    pitchAngleArrayOut(1) = 4.0*sin(2*pi*Freq*currentTime);
        
    % Create updated string
    disp([datestr(rem(now,1)) '__    Synthesizing message string.']);
    dataSend = setupZmqSignal(yawAngleArrayOut,pitchAngleArrayOut);
    
    % Send a message (control action) back to SOWFA
    zmqServer.send(dataSend);
end

% Close connection
zmqServer.disconnect()

function [dataOut] = setupZmqSignal(yawAngles,pitchAngles)
	dataOut = [];
    for i = 1:length(yawAngles)
        dataOut = [dataOut yawAngles(i) pitchAngles(i)];
    end
end