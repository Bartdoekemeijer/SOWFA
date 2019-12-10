addpath('D:\bmdoekemeijer\My Documents\MATLAB\SOWFA_tools')
addpath('D:\bmdoekemeijer\My Documents\MATLAB\SOWFA_tools\readTurbineOutput')
addpath(genpath('FLORISSE_M'))
caseFolder = 'W:\OpenFOAM\bmdoekemeijer-2.4.0\precursorCases\neutral_RE19_11mps_varyingWsWd\source';
timeVec = 20000+100*[1:50]

for ki = 1:length(timeVec)
    k = timeVec(ki);
    [A,B,C] = importVTK([caseFolder '\postProcessing\sliceDataInstantaneous\' num2str(k) '\U_slice_horizontal.vtk']); 
    Uall = sqrt(C(:,1).^2+C(:,2).^2); 
    U(ki) = mean(Uall);
    I(ki) = std(Uall)/mean(Uall);
%     WD(ki) = 270.-atand(mean(C(:,2))/mean(C(:,1)));
    WD(ki) = atand(mean(C(:,2))/mean(C(:,1)));
    disp(['k=' num2str(k) ', U=' num2str(U(ki)) ' m/s, TI=' num2str(I(ki))  ', WD=' num2str(WD(ki)) ' deg']); 
end

%% Load SSC information
load('ssc_workspace.mat')

%% Plot estimation signals
clf;
subplot(3,1,1);
plot(timeVec,U,'k');
hold on
plot([xOpt_array.time],[xOpt_array.WS])
grid on
ylabel('Wind speed (m/s)')
subplot(3,1,2);
plot(timeVec,WD,'k');
hold on
plot([xOpt_array.time],[xOpt_array.WD]*180/pi)
grid on
ylabel('Wind direction (deg)')
xlabel('Time (s)')
subplot(3,1,3);
plot(timeVec,I,'k');
hold on
plot([xOpt_array.time],[xOpt_array.TI])
grid on
ylabel('Turb intensity (%)')
xlabel('Time (s)')

%% Plot turbine power signals
[time,Power] = readOOPTdata('W:\OpenFOAM\bmdoekemeijer-2.4.0\simulationCases\RE2019\6turb_runs\varyingWsWd\postProcessing\turbineOutput\20000\generatorPower');
figure()
subplot(2,1,1)
plot(time,movmean(Power(:,[1 2]),[300/.2 0])*1e-6)
legend('Interpreter','latex')
grid on
xlabel('Time (s)','Interpreter','latex')
xlabel('Power (MW)','Interpreter','latex')

florisRunner = loadFLORIS(xOpt);
florisRunner.controlSet.yawAngleWFArray = yawAngleArrayWF*pi/180;
florisRunner.run()
powerFLORIS = [florisRunner.turbineResults.power]

subplot(2,1,2)
bar([powerSOWFA; powerFLORIS]')
legend({'SOWFA','FLORIS'},'Interpreter','latex','Location','southeast')
    
%% Plot FLORIS for latest xOpt
visTool = visualizer(florisRunner);
visTool.plot2dIF;

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