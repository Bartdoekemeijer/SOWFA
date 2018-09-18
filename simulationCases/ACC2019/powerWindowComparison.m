
generatorPowerGreedy = importGenPower('W:\OpenFOAM\bmdoekemeijer-2.4.0\simulationCases\ACC2019\NREL5MW_9turb_greedy\turbineOutput\20000\powerGenerator');
generatorPowerOpt    = importGenPower('W:\OpenFOAM\bmdoekemeijer-2.4.0\simulationCases\NREL5MW_9turb_SSC\turbineOutput\20000\powerGenerator');

nTurbs = max(generatorPowerGreedy.Turbine)+1;
for i = 1:nTurbs
    timeGreedy{i}  = generatorPowerGreedy.Times(generatorPowerGreedy.Turbine==i-1);
    powerGreedy{i} = generatorPowerGreedy.generator(generatorPowerGreedy.Turbine==i-1);
    timeOpt{i}     = generatorPowerOpt.Times(generatorPowerOpt.Turbine==i-1);
    powerOpt{i}    = generatorPowerOpt.generator(generatorPowerOpt.Turbine==i-1);
    
    powerGreedy{i} = powerGreedy{i}/1.2250; % Correct for density
end



figure;
for i = 1:nTurbs
    subplot(3,3,i)
    plot(timeGreedy{i},powerGreedy{i},'k','displayName','Baseline');
    hold on; grid on;
    plot(timeOpt{i},powerOpt{i},'r--','displayName','Optimized');
    xlabel('Time (s)')
    ylabel('Power (W)')
end

windowTimes = [20000 20600; 20600 21200; 21200 21800; 21800 22000];
for jw = 1:size(windowTimes,1)
    [greedyWindow(jw,1),optWindow(jw,1)] = deal(0);
    for i = 1:nTurbs
        greedyWindow(jw,1) = greedyWindow(jw,1)+mean(powerGreedy{i}(find(timeGreedy{i}==windowTimes(jw,1)):find(timeGreedy{i}==windowTimes(jw,2))))
        optWindow(jw,1)    = optWindow(jw,1)+mean(powerOpt{i}(find(timeOpt{i}==windowTimes(jw,1)):find(timeOpt{i}==windowTimes(jw,2))))
    end
end