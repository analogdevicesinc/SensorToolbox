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
            'accel_x','accel_y','accel_z',...
            'magn_x','magn_y','magn_z'};
    end
    
    methods
        %% Constructor
        function obj = ADIS16480(varargin)
            obj = obj@adi.IMUBase(varargin{:});
            obj.EnabledChannels = 1:9;
        end
    end   
    
%     methods (Access=protected)%REMOVED WHILE stepImpl USES varargout
%         function numOut = getNumOutputsImpl(~)
%             numOut = 3;
%         end       
%     end
    
    %% Sensor specific APIs
    methods
        function [varargout] = read(obj)
            if isequal(obj.EnabledChannels,1:6)
                [accelReadings, gyroReadings, valid] = readAccelGyro(obj);
                varargout = {accelReadings, gyroReadings, valid};
            elseif isequal(obj.EnabledChannels,1:9)
                [accelReadings, gyroReadings, magReadings, valid] = readAccelGyroMag(obj);
                varargout = {accelReadings, gyroReadings, magReadings, valid};
            end
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)

        function [varargout] = stepImpl(obj)
            [dataR, valid] = stepImpl@adi.common.Rx(obj);
            if isequal(obj.EnabledChannels,1:6)
                [accelReadings, gyroReadings] = stepAccelGyro(obj, dataR);
                varargout = {accelReadings, gyroReadings, valid};
            elseif isequal(obj.EnabledChannels,1:9)
                [accelReadings, gyroReadings, magReadings] = stepAccelGyroMag(obj, dataR);
                varargout = {accelReadings, gyroReadings, magReadings, valid};
            end
        end
        
        function icon = getIconImpl(~)
            icon = sprintf('ADIS16480');
        end
        
        function setupInit(obj)
            trig = getDev(obj, 'adis16480-dev0');
            iio_device_set_trigger(obj, obj.iioDev, trig);
            setupInit@adi.IMUBase(obj); % call superclass setupInit
        end
        
    end
        
    %% External Dependency Methods
    methods (Hidden, Static)       
        function bName = getDescriptiveName(~)
            bName = 'ADIS16480';
        end
    end
end

