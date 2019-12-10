classdef V112_cpct < handle
    
    properties
        controlMethod % The controlMethod that is being used in this turbine
        structLUT % Struct() containing all the preloaded LUT info
    end
    
    methods
        
        % Initialization of the Cp-Ct mapping (LUTs)
        function obj = V112_cpct(controlMethod)
            %TURBINE_TYPE Construct an instance of this class
            %   The turbine characters are saved as properties
            obj.controlMethod = controlMethod;
            
            % Initialize LUTs
            switch controlMethod
                % use pitch angles and Cp-Ct LUTs for pitch and WS,
                
                case {'greedy'}
                    % Load the lookup table for cp and ct as a function of windspeed
                    loadedData = load('V112_cpctdata.mat');
                    structLUT.wsRange = loadedData.ws';
                    structLUT.lutCp   = loadedData.Cp_ws;
                    structLUT.lutCt   = loadedData.Ct_ws; 
                    
                case {'axialInduction'}
                    % No preparation needed
                    structLUT = struct();
                    
                otherwise
                    error('Control methodology with name: "%s" not defined for the V112 turbine', controlMethod);
            end
            
            obj.structLUT = structLUT;
        end
        
        
        % Initial values when initializing the turbines
        function [out] = initialValues(obj)
            switch obj.controlMethod
                case {'pitch'}
                    out = struct('pitchAngle', 0);  % Blade pitch angles, by default set to greedy
                case {'greedy'}
                    out = struct(); % Do nothing: leave all variables as NaN
                otherwise
                    error(['Control methodology with name: "' obj.controlMethod '" not defined']);
            end
        end
        
        
        % Interpolation functions to go from LUT to actual values
        function [cp,ct,adjustCpCtYaw] = calculateCpCt(obj,condition,turbineControl)
            controlMethod = obj.controlMethod;
            structLUT     = obj.structLUT;
            
            switch controlMethod
                                   
                case {'greedy'}
                    cp = interp1(structLUT.wsRange, structLUT.lutCp, condition.avgWS,'linear',0.0);
                    ct = interp1(structLUT.wsRange, structLUT.lutCt, condition.avgWS,'linear',1e-5);
                    if ct > 1
                        ct = 0.999;
                    end
                    adjustCpCtYaw = true; % do function call 'adjust_cp_ct_for_yaw' after this func.
                    
                otherwise
                    error('Control methodology with name: "%s" not defined', obj.controlMethod);
            end
            
        end
        
    end
end
