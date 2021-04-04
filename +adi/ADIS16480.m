classdef ADIS16480 < adi.IMUBase
    %ADIS16480 Inertial Measurement Unit
    %   The adi.ADIS16480 System object is a signal source that can
    %   collect IMU data from the ADIS16480.
    %
    %   imu = adi.ADIS16480;
    %   imu = adi.ADIS16480('uri','ip:analog');
    %
    %   [accelReadings, gyroReadings, valid] = imu() produces two outputs
    %   where accelReadings is a Nx3 matrix containing acceleration data
    %   for x, y, and z respectively in m/s^2 where N is SamplesPerFrame.
    %   gyroReadings is the same as accel except it contains angular
    %   velocity data for x, y, and z in rad/s. valid is a logical to
    %   determine if the data is valid.
    %
    %   Each collected measurement within a buffer is guaranteed to be
    %   contiguous within that buffer. However, successive buffers are not.
    %
    %   <a href="https://www.analog.com/media/en/technical-documentation/data-sheets/ADIS16480.pdf">ADIS16480 Datasheet</a>         
    properties(Nontunable, Hidden)
        dataTypeStr = 'int32';
        phyDevName = 'adis16480';
        devName = 'adis16480';
    end
    
    properties(Nontunable, Hidden, Constant)
        channel_names = {...
            'anglvel_x','anglvel_y','anglvel_z',...
            'accel_x','accel_y','accel_z'};
    end
    
    methods
        %% Constructor
        function obj = ADIS16480(varargin)
            obj = obj@adi.IMUBase(varargin{:});
            obj.EnabledChannels = 1:6;
        end
    end   
    
    methods (Access=protected)
        function numOut = getNumOutputsImpl(~)
            numOut = 2;
        end       
    end
    
    %% Sensor specific APIs
    methods
        function [accelReadings, gyroReadings, magReadings, valid] = read(obj)
            [accelReadings, gyroReadings, magReadings, valid] = readAccelGyroMag(obj);
        end
        function [accelReadings, gyroReadings, valid] = readAccGyro(obj,samples)
            samples = obj.SamplesPerRead; % for syntax consistency, does not affect buffer read
            [accelReadings, gyroReadings, valid] = buffread(obj,samples);
        end
        
        function [magReadings, valid] = readMag(obj,samples)
            [magReadings, valid] = chanreadMag(obj,samples);
        end
        
        function [baroReadings, valid] = readBaro(obj,samples)
            [baroReadings, valid] = chanreadBaro(obj,samples);
        end
        
        function [tempReadings, valid] = readTemp(obj,samples)
            [tempReadings, valid] = chanreadTemp(obj,samples);
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        % function [accelReadings, gyroReadings, magReadings, valid] = stepImpl(obj)
        %     [dataR, valid] = stepImpl@adi.common.Rx(obj);
        %     [accelReadings, gyroReadings, magReadings] = stepAccelGyroMag(obj, dataR);
        % end

        function [dataR, valid] = stepImpl(obj,stepMode,samples)
            [dataR, valid] = stepImpl@adi.common.Rx(obj,stepMode,samples);
        end

        % Travis solution
        function setupInit(obj)
            trig = getDev(obj, 'adis16480-dev0');
            iio_device_set_trigger(obj, obj.iioDev, trig);
            setupInit@adi.IMUBase(obj); % call superclass setupInit
        end
        
        function icon = getIconImpl(~)
            icon = sprintf('ADIS16480');
        end
        
    end
        
    %% External Dependency Methods
    methods (Hidden, Static)       
        function bName = getDescriptiveName(~)
            bName = 'ADIS16480';
        end
    end
end

