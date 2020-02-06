%% SSC EXAMPLE FUNCTION

% Setup zeroMQ server
zmqServer = zeromqObj('/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/jeromq/jeromq-0.4.4-SNAPSHOT.jar',1876,3600,true);

% Load the yaw setpoint LUT and set-up a simple function
nTurbs = 2;

% Initial control settings
torqueArrayOut     = 0.0 *ones(1,nTurbs); % Not used unless 'torqueSC' set in turbineProperties
yawAngleArrayOut   = 270.*ones(1,nTurbs); % Not used unless 'yawSC' set in turbineProperties
pitchAngleArrayOut = 0.0 *ones(1,nTurbs); % Not used unless 'PIDSC' or 'pitchSC' set in turbineProperties

% Start control loop
disp(['Entering wind farm controller loop...']);
while 1
    % Receive information from SOWFA
    dataReceived = zmqServer.receive();
    currentTime  = dataReceived(1,1);
    measurementVector = dataReceived(1,2:end); % [powerGenerator[1], torqueRotor[1], thrust[1], powerGenerator[2], torqueRotor[2], thrust[2]]
    
    % Measurements: [genPower,rotSpeedF,azimuth,rotThrust,rotTorque,genTorque,nacYaw,bladePitch]
    generatorPowerArray = measurementVector(1:8:end);
    rotorSpeedArray     = measurementVector(2:8:end);
    azimuthAngleArray   = measurementVector(3:8:end);
    rotorThrustArray    = measurementVector(4:8:end);
    rotorTorqueArray    = measurementVector(5:8:end);
    genTorqueArray      = measurementVector(6:8:end);
    nacelleYawArray     = measurementVector(7:8:end);
    bladePitchArray     = measurementVector(8:8:end);
    
    % Do something with our measurements
    % ...
    
    % Generate new control signals
    if currentTime < 10
        yawAngleArrayOut(1) = 260.; % Change the yaw angle of turbine 1 by -10 degrees (w.r.t. 270 being aligned)
    elseif currentTime < 30
        yawAngleArrayOut(1)   = 290.; % Change the yaw angle of turbine 1 to +20 degrees (w.r.t. 270 being aligned)
        pitchAngleArrayOut(1) = 4.3; % Set blade pitch angle to 4.3 degrees
    else
        yawAngleArrayOut(1) = 305.; % Change the yaw angle of turbine 1 to +35 degrees for remainder of simulation
        pitchAngleArrayOut(1) = 1.5; % Set blade pitch angle to 1.5 degrees
    end
    
    if currentTime < 20
        yawAngleArrayOut(2) = 265.; % Change the yaw angle of turbine 2 by -5 degrees (w.r.t. 270 being aligned)
    elseif currentTime < 40
        yawAngleArrayOut(2) = 275.; % Change the yaw angle of turbine 2 to +5 degrees (w.r.t. 270 being aligned)
        pitchAngleArrayOut(2) = 7.5; % Set blade pitch angle to 7.5 degrees
    else
        yawAngleArrayOut(2) = 270.; % Change the yaw angle of turbine 2 to 0 degrees for remainder of simulation
    end
        
    % Create updated string
    disp([datestr(rem(now,1)) '__    Synthesizing message string.']);
    dataSend = setupZmqSignal(torqueArrayOut,yawAngleArrayOut,pitchAngleArrayOut);
    
    % Send a message (control action) back to SOWFA
    zmqServer.send(dataSend);
end

% Close connection
zmqServer.disconnect()

function [dataOut] = setupZmqSignal(torqueSignals,yawAngles,pitchAngles)
	dataOut = [];
    for i = 1:length(yawAngles)
        dataOut = [dataOut torqueSignals(i) yawAngles(i) pitchAngles(i)];
    end
end