classdef CN0532 < adi.CN0540Base
    % CN0532: Development board with ADXL1002 Low Noise, High Frequency +/-50g MEMS Accelerometer
    %   The adi.ADXL1002 System object is a signal source that can
    %   collect IMU data from the ADXL1002.
    %
    %   accel = adi.CN0532;
    %   accel = adi.CN0532('uri','ip:analog');
    %
    %   [accelReadings, valid] = accel() produces one outputs
    %   where accelReadings
    %
    %   Each collected measurement within a buffer is guaranteed to be
    %   contiguous within that buffer. However, successive buffers are not.
    %
    %   <a href="https://www.analog.com/media/en/technical-documentation/data-sheets/ADXL1002.pdf">ADXL1002 Datasheet</a>         
    properties(Nontunable, Hidden, Access = protected)
        CommonModeVoltage = '2V5';
    end
    
    methods
        %% Constructor
        function obj = CN0532(varargin)
            obj = obj@adi.CN0540Base(varargin{:});
            obj.EnabledChannels = 1;
        end
        % Check 
        function set.CommonModeVoltage(obj, value)
            obj.CommonModeVoltage = value;
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('common_mode_voltage',value);                
            end
        end
    end   
    
    methods (Access=protected)
        function numOut = getNumOutputsImpl(~)
            numOut = 2;
        end       
    end
    
    %% Sensor specific APIs
    methods
        function [accelReadings, valid] = read(obj)
            [accelReadings, valid] = readAccel(obj);
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function [dataR, valid] = stepImpl(obj)
            [dataR, valid] = stepImpl@adi.common.Rx(obj);
            dataR = bitshift(dataR,-8,'int32');
        end
        
        function icon = getIconImpl(~)
            icon = sprintf('CN0532');
        end

    end
        
    %% External Dependency Methods
    methods (Hidden, Static)       
        function bName = getDescriptiveName(~)
            bName = 'CN0532';
        end
    end
end

