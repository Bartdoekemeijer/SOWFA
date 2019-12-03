clear all; %close all;

% fileVTK = ['W:\OpenFOAM\bmdoekemeijer-2.4.0\simulationCases\forceScaleRange\10x10x10\F1.3_k1.15eps12.0' ...
%               '\postProcessing\sliceDataInstantaneous\500\U_slice_horizontal.vtk'];
fileVTK = ['W:\OpenFOAM\bmdoekemeijer-2.4.0\simulationCases\forceScaleRange\15x15x15_U10\' ...
              'F1.3_k1.15eps16.0\postProcessing\sliceDataInstantaneous\500\U_slice_horizontal.vtk'];          
          
addpath('D:\bmdoekemeijer\My Documents\MATLAB\FLORISSE_M\Examples\example_SOWFA_calibration\bin');
[dataType,cellCenters,cellData] = importVTK(fileVTK);

% Setup interpolant
F = scatteredInterpolant(cellCenters(:,1), cellCenters(:,2), ...
                         sqrt(cellData(:,1).^2+cellData(:,2).^2),'linear');
      
                     
yRange = 750+[-126.4/2:5:126.4/2];
xRange = min(cellCenters(:,1)):5:max(cellCenters(:,1));
for xi = 1:length(xRange)
    U_crossstream = F(xRange(xi)*ones(size(yRange)),yRange);
    U_streamwise(xi) = mean(U_crossstream);
end

figure(1);
plot(xRange,U_streamwise);
ylabel('Wind speed (m/s)');
xlabel('Distance (m)'); 
grid on;


% Plot ADM on top
U_inf = max(U_streamwise); % 7.0 m/s
hold all;
plot(xRange,U_inf*ones(size(xRange))*2/3,'r--')
plot(xRange,U_inf*ones(size(xRange))*1/3,'r--')