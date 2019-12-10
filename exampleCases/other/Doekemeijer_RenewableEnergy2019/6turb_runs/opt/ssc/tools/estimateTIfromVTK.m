clear
clc
addpath('D:\bmdoekemeijer\My Documents\MATLAB\SOWFA_tools')

t = 21500;

locIf = [608.5  1232.55
         608.5  1767.45
         1500.0 1232.55
         1500.0 1767.45
         2391.5 1232.55
         2391.5 1767.45];
     
fileName = ['W:\OpenFOAM\bmdoekemeijer-2.4.0\simulationCases\RE2019\6turb_runs\varyingWsWd\20190808.archived\postProcessing\sliceDataInstantaneous\' num2str(t) '\U_slice_horizontal.vtk'];
[~,cellCenters,cellData] = importVTK(fileName);
x = cellCenters(:,1);
y = cellCenters(:,2);
z = cellCenters(:,3);
u = cellData(:,1);
v = cellData(:,2);
z = cellData(:,3);


x_beforeTurb = 178.3; % length of section
w_beforeTurb = 178.3; % width of section

for i = 1:size(locIf,1)
    idSelection = x >= locIf(i,1)-x_beforeTurb & ...
                  x <= locIf(i,1) & ...
                  y >= locIf(i,2)-0.5*w_beforeTurb & ...
                  y <= locIf(i,2)+0.5*w_beforeTurb;
              
    uSelection = u(idSelection);
    vSelection = v(idSelection);
    uMagSelection = sqrt(uSelection.^2 + vSelection.^2);
    TI(i) = std(uMagSelection)/mean(uMagSelection);
    U(i)  = mean(uMagSelection);
    WD(i) = atand(mean(vSelection)/mean(uSelection));
end
TI
U
WD