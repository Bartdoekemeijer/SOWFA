%% SSC EXAMPLE FUNCTION

% Setup zeroMQ server
zmqServer = zeromqObj('/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/jeromq/jeromq-0.4.4-SNAPSHOT.jar',1196,3600,true);

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
    measurementVector = dataReceived(1,2:end); % [powerGenerator[1], torqueRotor[1], thrust[1], powerGenerator[2], torqueRotor[2], thrust[2]]
    
    powerGenerator = measurementVector(1:3:end);
    torqueRotor = measurementVector(2:3:end);
    thrust = measurementVector(3:3:end);

    % Do something with our measurements
    % ...
    
    % Generate new control signals
    if currentTime < 10
        yawAngleArrayOut(1) = 260.; % Change the yaw angle of turbine 1 by -10 degrees (w.r.t. 270 being aligned)
    elseif currentTime < 30
        yawAngleArrayOut(1) = 290.; % Change the yaw angle of turbine 1 to +20 degrees (w.r.t. 270 being aligned)
    else
        yawAngleArrayOut(1) = 305.; % Change the yaw angle of turbine 1 to +35 degrees for remainder of simulation
    end
    
    if currentTime < 20
        yawAngleArrayOut(2) = 265.; % Change the yaw angle of turbine 2 by -5 degrees (w.r.t. 270 being aligned)
    elseif currentTime < 40
        yawAngleArrayOut(2) = 275.; % Change the yaw angle of turbine 2 to +5 degrees (w.r.t. 270 being aligned)
    else
        yawAngleArrayOut(2) = 270.; % Change the yaw angle of turbine 2 to 0 degrees for remainder of simulation
    end
        
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