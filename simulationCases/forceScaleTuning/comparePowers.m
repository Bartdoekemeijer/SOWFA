clear all; clc;
% fileNameList = {'rotorSpeed','generatorPower'};
fileNameList = {'powerGenerator','rotSpeed'}; %{'generatorPower'};
for ji = 1:length(fileNameList)
    fileName = fileNameList{ji};
    
    % Compare turbine models
    homeDir = 'W:/OpenFOAM/bmdoekemeijer-2.4.0/simulationCases/forceScaleRange';
    fileList = {};
    legendDefinition = {};
    fileList{end+1} = [homeDir '/15x15x15/F1.3_k1.15eps16.0/turbineOutput/0/' fileName]; legendDefinition{end+1}='15x15x15 - WD=270deg - k=1.15, eps=16.0';      
%     fileList{end+1} = [homeDir '\10x10x10\F1.3_k1.15eps12.0\turbineOutput\0\' fileName]; legendDefinition{end+1}='10x10x10 - k=1.15, eps=12.0';
    fileList{end+1} = [homeDir '/15x15x15_225deg/F1.3_k1.0eps16.0/turbineOutput/0/' fileName]; legendDefinition{end+1}='15x15x15 - WD=225deg - k=1.0, eps=16.0';      
    fileList{end+1} = [homeDir '/15x15x15_225deg/F1.3_k1.15eps16.0/turbineOutput/0/' fileName]; legendDefinition{end+1}='15x15x15 - WD=225deg - k=1.15, eps=16.0';          
    fileList{end+1} = [homeDir '/15x15x15_225deg/F1.3_k1.3eps16.0/turbineOutput/0/' fileName]; legendDefinition{end+1}='15x15x15 - WD=225deg - k=1.3, eps=16.0';          
%     fileList{end+1} = [homeDir '/15x15x15_225deg/F1.3_k1.0eps21.0/turbineOutput/0/' fileName]; legendDefinition{end+1}='15x15x15 - WD=225deg - k=1.0, eps=21.0';      
%     fileList{end+1} = [homeDir '/15x15x15_225deg/F1.3_k1.15eps21.0/turbineOutput/0/' fileName]; legendDefinition{end+1}='15x15x15 - WD=225deg - k=1.15, eps=21.0';          
%     fileList{end+1} = [homeDir '/15x15x15_225deg/F1.3_k1.3eps21.0/turbineOutput/0/' fileName]; legendDefinition{end+1}='15x15x15 - WD=225deg - k=1.3, eps=21.0';          
    
    
    for i = 1:length(fileList)
        fileData{i} = importGenPower(fileList{i});
        time{i}     = fileData{i}.Times;
        data{i}     = fileData{i}.generator;
        
        if strcmp(fileName, 'powerGenerator')
            data{i} = data{i}/1.225;
        end
    end

    figure(ji); clf;
    for i = 1:length(fileList)
        if strcmp(fileName, 'rotSpeed')
            if i > 1
                U_inf = 7.0;
            else
                U_inf = 7.0;
            end
            TSR{i} = (data{i}*2*pi/60)*88.54/U_inf;
            plot(time{i},TSR{i},'displayName',['TSR fileList{' num2str(i) '}']);
            ylabel('TSR');
        else
            plot(time{i},data{i},'displayName',['fileList{' num2str(i) '}']);
            ylabel(fileName);
        end
        hold on;
    end
    xlabel('Time (s)');
    grid on;
%     legend('-dynamicLegend')
    legend(legendDefinition);
end