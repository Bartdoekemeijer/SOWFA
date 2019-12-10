addpath('D:\bmdoekemeijer\My Documents\MATLAB\SOWFA_tools')
addpath('D:\bmdoekemeijer\My Documents\MATLAB\export_fig')
close all;

timeVec = [20020:20:22000];
h=figure();
for i = 75:length(timeVec)
    filenameVTK = ['../postProcessing/sliceDataInstantaneous/' num2str(timeVec(i)) '/U_slice_horizontal.vtk'];
    [~,cellCenters,cellData] = importVTK(filenameVTK);
    uSOWFA = sqrt(cellData(:,1).^2+cellData(:,2).^2);
    if i == 1
        xIF = cellCenters(:,1);
        yIF = cellCenters(:,2);
        tri = delaunay(xIF, yIF); % Necessary for plotting raw data
    end
    clf;
    ts = trisurf(tri, xIF, yIF, uSOWFA);
    zlim([0 12.5])
    lighting none; shading flat;
    axis equal;
    light('Position',[-50 -15 29]); view(0,90); hold on;
    clb = colorbar;
    clb.Limits = [0 12.5];
    title(['t = ' num2str(timeVec(i)) '~s'],'Interpreter','latex')
    export_fig(['vtk_fig_out/' num2str(i) '.png'],'-transparent','-m3')
end