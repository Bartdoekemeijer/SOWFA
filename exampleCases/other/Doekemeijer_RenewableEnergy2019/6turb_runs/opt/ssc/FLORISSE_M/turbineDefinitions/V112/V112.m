function turbineType = V112()
%V112 This functions creates a turbine type of the Vestas V112 turbine
%    More information can be found in :cite:`Jonkman2009`.

% Available control methods
availableControl = {'greedy', 'axialInduction'};

% Function definitions for the calculation of Cp and Ct                       
cpctMapFunc   = @V112_cpct;

% Instantiate turbine with the correct dimensions and characteristics
% obj = turbine_type(rotorRadius, genEfficiency, hubHeight, pP, ...
turbineType = turbine_type(56, 0.927, 83.52, 1.7, ...
                           cpctMapFunc, availableControl, 'V112 turbine');
end

% % This function is compatible with C-compilation
% function Path = getFileLocation()
%     filePath = mfilename('fullpath');
%     Path = filePath(1:end-1-length(mfilename()));
% end
