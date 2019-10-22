classdef ADIS16375 < adi.IMUBase
    %ADIS16375 Inertial Measurement Unit
    %   The adi.ADIS16375 System object is a signal source that can
    %   collect IMU data from the ADIS16375.
    %
    %   imu = adi.ADIS16375;
    %   imu = adi.ADIS16375('uri','ip:analog');
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
    %   <a href="https://www.analog.com/media/en/technical-documentation/data-sheets/ADIS16375.pdf">ADIS16375 Datasheet</a>         
    properties(Nontunable, Hidden)
        dataTypeStr = 'int32';
        phyDevName = 'adis16375';
        devName = 'adis16375';
    end
    
    properties(Nontunable, Hidden, Constant)
        channel_names = {...
            'anglvel_x','anglvel_y','anglvel_z',...
            'accel_x','accel_y','accel_z'};
    end
    
    methods
        %% Constructor
        function obj = ADIS16375(varargin)
            obj = obj@adi.IMUBase(varargin{:});
            obj.EnabledChannels = 1:6;
        end
    end   
    
    methods (Access=protected)
        function numOut = getNumOutputsImpl(~)
            numOut = 3;
        end       
    end
    
    %% Sensor specific APIs
    methods
        function [accelReadings, gyroReadings, valid] = read(obj)
            [accelReadings, gyroReadings, valid] = readAccelGyro(obj);
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function [accelReadings, gyroReadings, valid] = stepImpl(obj)
            [dataR, valid] = stepImpl@adi.common.Rx(obj);
            [accelReadings, gyroReadings] = stepAccelGyro(obj, dataR);
        end
        
        function icon = getIconImpl(~)
            icon = sprintf('ADIS16375');
        end
        
    end
        
    %% External Dependency Methods
    methods (Hidden, Static)       
        function bName = getDescriptiveName(~)
            bName = 'ADIS16375';
        end
    end
end

