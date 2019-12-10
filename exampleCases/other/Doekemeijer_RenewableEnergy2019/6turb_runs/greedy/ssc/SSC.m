% clear all; clc;
addpath(genpath('FLORISSE_M'))

% Setup zeroMQ server
zmqServer = zeromqObj('/home/bmdoekemeijer/OpenFOAM/zeroMQ/jeromq-0.4.4-SNAPSHOT.jar',1131,3600,true);

% Setup
obsvThreshold = 0.25; % Observability threshold [z] (value between 0 and 1)
relObsvPastWindow = 400; % Average over past [y] seconds. if 0, uses instantaneous observability measure.
relObsvPercentage = 80; % [x], where at least [x] percent of past [y] s of measurements is above threshold [z]

wsInitial = 7.0; % [m/s]
wdInitial = pi/4; % [rad]
tiInitial = 0.40; % [-]

% Initialize model
x0 = struct('WS',wsInitial,'WD',wdInitial,'TI',tiInitial); % Initial guess ambient conditions

% Initialize observability matrix, variable being 'outputMatrix'
load('out_singleRose_6turb_estimateAll.mat');
obsvWDs = outputMatrix.trueRange.WD;
obsvRose = squeeze(outputMatrix.sumJ/max(outputMatrix.sumJ))';
clear outputMatrix

% Load Gaussian noise vector
load('gaussianNoiseVector.mat');

% Load the yaw setpoint LUT and set-up a simple function
nTurbs = 6;
load('LUT_6turb_yaw.simple.filtered.mat');
for turbi = 1:nTurbs
    [X1,X2,X3,X4] = ndgrid(databaseLUT.TI_range,databaseLUT.WS_range,databaseLUT.WD_range,databaseLUT.WD_std_range);
    F{turbi} = griddedInterpolant(X1,X2,X3,X4,databaseLUT.yawT{turbi},'linear','nearest');
end
clear X1 X2 X3 X4
yawAngleLUT = @(TI0,WS,WD,WD_std) arrayfun(@(i) F{i}(TI0,WS,WD,WD_std),1:6);


% Time
updateFrequency = 20.; % Update every [x] seconds

% Initial control settings
yawAngleArrayIF  = 45.0*ones(1,nTurbs); % Initial settings
yawAngleArrayOut = 270. - yawAngleArrayIF;
pitchAngleArrayOut = 0.0*ones(1,nTurbs);
dataSend = setupZmqSignal(yawAngleArrayOut,pitchAngleArrayOut);

timeLastControl = 20e3; % -Inf: optimize right away. 0: optimize after controlTimeInterval (no prec), 20e3: optimize after controlTimeInterval (with prec)
[timeVector,measurementVector] = deal([]);
firstRun = true;

wdTable = [ 0.0     225.0
            20000.0 225.0
            20200.0 235.0
            20400.0 230.0
            20950.0 230.0
            21070.0 182.0
            22350.0 182.0
            22700.0 225.0
            23300.0 225.0
            23380.0 268.0
            24500.0 268.0
            24700.0 225.0
            25000.0 225.0
            90000.0 225.0];

lastTiUpdateTime = -1e6; % Time of last TI update: never
relObsvArray = []; % Initialize empty vector for relObsv
xOpt = x0; % Set initial estimate
pp = parpool(20); % Assuming one node with 40 cores
pp.IdleTimeout = 120; % Time-out is 2 hours (walltime)
disp(['Entering wind farm controller loop...']);
while 1
    % Receive information from SOWFA
    dataReceived = zmqServer.receive();
    currentTime  = dataReceived(1,1);
    timeVector = [timeVector; currentTime];
    measurementVector = [measurementVector;dataReceived(1,2:end)];
    
    if firstRun
        dt = rem(currentTime,10)
        xOpt_array(1) = x0;
        xOpt_array(1).WDfilt = x0.WD;
        xOpt_array(1).WSfilt = x0.WS;
        xOpt_array(1).time = currentTime-dt;
        xOpt_array(1).relObsv = 0.0; % No information
        xOpt_array(1).maxStdYaw = 0.0;
        xOpt_array(1).stdWD = 0.0;
        
        firstRun = false;
    end
    
    % Optimize periodically
    if currentTime-timeLastControl >= updateFrequency
        disp([datestr(rem(now,1)) '__ Optimizing control at timestamp ' num2str(currentTime) '.']);
        
        %% Estimation        
        % 1. Derive a WD estimate from the wind vanes
        wdSOWFAmean = 270.-interp1(wdTable(:,1),wdTable(:,2),currentTime);
        wdSOWFAmean = wdSOWFAmean + gaussianNoiseVector(currentTime)*2/sqrt(6); % Add noise
        disp(['    Instantaneous WD estimate: ' num2str(wdSOWFAmean) ' deg.']);
        xOpt.WD = wdSOWFAmean*pi/180;
        
        % smoothened WD
        if length(xOpt_array) == 1
            WDfilt = sum([0.5 0.5].*[[xOpt_array(end).WD] xOpt.WD]) % 1st order filter
        elseif length(xOpt_array) == 2
            WDfilt = sum([0.5 0.3 0.2].*[[xOpt_array(end-1:end).WD] xOpt.WD]) % 2nd order filter
        elseif length(xOpt_array) >= 3
            WDfilt = sum([0.3 0.3 0.2 0.2].*[[xOpt_array(end-2:end).WD] xOpt.WD]) % 3rd order filter
        end
        disp(['    Low-pass filtered WD estimate: ' num2str(WDfilt*180/pi) ' deg.']);
        
        % 2. Derive a WS estimate from the upstream turbines
        if WDfilt*180./pi < 30
            upstreamTurbIndices = [1 2]
        else
            upstreamTurbIndices = [1 3 5]
        end
        
        % Use 1-minute averages for the WS estimate
        [yawTime,yawValues] = readOOPTdata('../postProcessing/turbineOutput/20000/nacelleYaw');
        yawSOWFAminuteAvg = 270. - mean(yawValues(yawTime >= (currentTime - 60.),:))
        powerSOWFAminuteAvg = mean(measurementVector(timeVector >= (currentTime-60.),1:3:end),1)/1.225;
        
        xOpt.WS = estimateWS(yawSOWFAminuteAvg*pi/180.,powerSOWFAminuteAvg,...
                             struct('WD',WDfilt,'WS',xOpt.WS,'TI',xOpt.TI),...
                             upstreamTurbIndices);
        
        % smoothened WS
        if length(xOpt_array) == 1
            WSfilt = sum([0.5 0.5].*[[xOpt_array(end).WS] xOpt.WS]); % 1st order filter
        elseif length(xOpt_array) == 2
            WSfilt = sum([0.5 0.3 0.2].*[[xOpt_array(end-1:end).WS] xOpt.WS]); % 2nd order filter
        elseif length(xOpt_array) >= 3
            WSfilt = sum([0.3 0.3 0.2 0.2].*[[xOpt_array(end-2:end).WS] xOpt.WS]); % 3rd order filter
        end        
        
        % 3. Check observability for current wind direction and decide what to estimate
        relObsv = interp1(obsvWDs,obsvRose,wdSOWFAmean*pi/180);
        relObsvArray = [relObsvArray; currentTime relObsv (relObsv > obsvThreshold)]; % Append current time and observability
        
        timeAveragedObservability = mean(relObsvArray((relObsvArray(:,1) >= (currentTime - relObsvPastWindow)),3));
        observabilityCheck = (timeAveragedObservability >= (relObsvPercentage/100));
        disp(['    Rel. observability over past [' num2str(relObsvPastWindow) '] s is ' num2str(timeAveragedObservability) '.']);
        
        % Check steady-state situation
        maxStdYaw = max(std(yawValues(yawTime > currentTime - 400)))
        stdWD = std([xOpt_array([xOpt_array.time]>currentTime - 400).WDfilt]*180./pi)
        TiUpdateTimeCheck = (currentTime - lastTiUpdateTime >= 399.9)
        steadystateCheck = (( maxStdYaw < 1.0) & (stdWD < 1.0) & (TiUpdateTimeCheck))
        
        % Decide to estimate TI: only if observability=true AND steady-state situation arised
        if (observabilityCheck & steadystateCheck) 
            % Use 300-second averages for TI estimation
            yawSOWFAlongAvg = 270. - mean(yawValues(yawTime >= (currentTime - 300.),:))
            powerSOWFAlongAvg = mean(measurementVector(timeVector >= (currentTime - 300.),1:3:end),1)/1.225;
            [xOpt.TI,Jopt] = estimateTI(yawSOWFAlongAvg*pi/180,powerSOWFAlongAvg,...
                                        struct('WD',WDfilt,'WS',WSfilt,'TI',xOpt.TI));
            lastTiUpdateTime = currentTime; % Update time
        end
        
        disp(['    [xOpt.WD = ' num2str(xOpt.WD*180/pi,'%.1f') ' deg, xOpt.WS = ' num2str(xOpt.WS,'%.1f') ' m/s, xOpt.TI = ' num2str(xOpt.TI) '].'])
        
        % Save as a vector
        xOpt.time = currentTime;
        xOpt.WDfilt = WDfilt;
        xOpt.WSfilt = WSfilt;
        xOpt.relObsv = relObsv;
        xOpt.maxStdYaw = maxStdYaw;
        xOpt.stdWD = stdWD;
        xOpt_array(end+1) = xOpt;
        
        % Optimization
        WD_std = 2.5; % Include wind direction uncertainty/variability with std = 2.5 deg
        yawAngleArrayWF = 0.*yawAngleLUT(xOpt.TI,xOpt.WSfilt,xOpt.WDfilt*180/pi,WD_std) % Interpolate from table, yaw angles WF in deg, scaled to [-20, +20] deg range
        yawAngleArrayIF = xOpt.WDfilt*180/pi + yawAngleArrayWF % Yaw angles IF in deg
        pitchAngleArray = zeros(size(yawAngleArrayIF));
                
        % Update message string
        yawAngleArrayOut   = round(270.-yawAngleArrayIF,1);
        pitchAngleArrayOut = round(rad2deg(pitchAngleArray),1);        
        disp([datestr(rem(now,1)) '__    Synthesizing message string.']);
        dataSend = setupZmqSignal(yawAngleArrayOut,pitchAngleArrayOut);
        
        % Update time stamp
        timeLastControl = currentTime;
        save(['ssc_workspace_ t' num2str(currentTime) '.mat']);
    end
    
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

function [wsOpt,Jopt] = estimateWS(yawAngleIFArray,powerSOWFA,x0,upstreamTurbIndices)
    tic();
    
    % Initialize a FLORIS model
    florisRunner = loadFLORIS(x0);
    florisRunner.controlSet.yawAngleIFArray = yawAngleIFArray; % Fix yaw angles in IF
    
    % Search 1.5 m/s below and above previously estimated value
    wsVector = [max(x0.WS-1.5,0.0):0.1:x0.WS+1.50]; 
    
    % Initial optimal conditions
    Jopt = Inf;
    wsOpt = x0.WS;
        
    % Evaluate all cases in parallel
    parfor ii = 1:length(wsVector)
        % Initialize localized florisRunner with hypothesized WS
        florisRunnerTmp = copy(florisRunner);
        florisRunnerTmp.layout.ambientInflow.Vref = wsVector(ii);
        
        % Run and calculate RMSE
        florisRunnerTmp.run();
        powerFLORIS = [florisRunnerTmp.turbineResults.power];
        
        J{ii} = mean((powerFLORIS(upstreamTurbIndices) - ...
                      powerSOWFA(upstreamTurbIndices)).^2); 
    end

    [Jopt,idxOpt] = min(cell2mat(J));
    wsOpt = wsVector(idxOpt)
    
    toc();
end

function [tiOpt,Jopt] = estimateTI(yawAngleIFArray,powerSOWFA,x0)
    tic();
    
    % Initialize a FLORIS model
    florisRunner = loadFLORIS(x0);
    florisRunnerTmp.controlSet.yawAngleIFArray = yawAngleIFArray; % Fix yaw angles in IF
    
    tiVector = [0.01:0.01:0.90]; % Search over entire range
    
    % Initial optimal conditions
    Jopt = Inf;
    tiOpt = 0.90;
        
    % Evaluate all cases in parallel
    parfor ii = 1:length(tiVector)
        TI = tiVector(ii);
        florisRunnerTmp = copy(florisRunner);
        florisRunnerTmp.layout.ambientInflow.TI0 = TI;
        
        % Run
        florisRunnerTmp.run();
        powerFLORIS = [florisRunnerTmp.turbineResults.power];
        
        J{ii} = mean((powerFLORIS-powerSOWFA).^2); % MSE Power measurements
    end

    [Jopt,idxOpt]=min(cell2mat(J));
    tiOpt = tiVector(idxOpt);
    
    toc();
end

function florisRunner = loadFLORIS(x)
    % 6-turbine case
    locIf = {[608.5  1232.55];
             [608.5  1767.45];
             [1500.0 1232.55];
             [1500.0 1767.45];
             [2391.5 1232.55];
             [2391.5 1767.45]};

    % Put all the turbines in a struct array
    turbines = struct('turbineType',dtu10mw_v2(),'locIf',locIf);
    layout = layout_class(turbines, 'we19_6_turb');

    % Purposely initialize with poor initial conditions (to assess estimation)
    layout.ambientInflow = ambient_inflow_log('WS', x.WS,'HH', 119.0,'WD', x.WD,'TI0', x.TI);
    controlSet = control_set(layout, 'yaw');
    subModels = model_definition('','rans','','selfSimilar','','quadraticRotorVelocity','', 'crespoHernandez');

    % Set FLORIS model parameters to the values found by offline calibration
    subModels.modelData.TIa = 7.841152377297512;
    subModels.modelData.TIb = 4.573750238535804;
    subModels.modelData.TIc = 0.431969955023207;
    subModels.modelData.TId = -0.246470535856333;
    subModels.modelData.ad = 0.001117233213458;
    subModels.modelData.alpha = 1.087617055657293;
    subModels.modelData.bd = -0.007716521497980;
    subModels.modelData.beta = 0.221944783863084;
    subModels.modelData.ka = 0.536850894208880;
    subModels.modelData.kb = -0.000847912134732;

    florisRunner = floris(layout, controlSet, subModels);
end