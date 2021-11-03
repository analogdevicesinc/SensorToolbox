classdef IMUBase < matlab.system.mixin.CustomIcon & adi.common.Rx ...
        & matlabshared.libiio.base & adi.common.Attribute ...
        & adi.common.Sensor
    %Base class for all IMU sensors classes    
    properties
        %SampleRate Sample Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second.
        SampleRate = 1024;
    end
    properties (Nontunable)
        %TimeStampClockSource Time Stamp Clock Source
        %   Clock source used by sensor to perform triggering and data
        %   capture
        TimeStampClockSource = 'realtime';
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties (Hidden, Access = protected)
        AttributeScales
    end
    
    properties(Constant, Hidden)
        TimeStampClockSourceSet = matlab.system.StringSet({ ...
            'realtime'});
    end
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 2;
%         dataTypeStr = 'int32';
%         phyDevName = 'adis16460';
%         devName = 'adis16460';
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
    end
    
    properties (Hidden, Constant)
        ComplexData = false;
    end
    
    methods
        %% Constructor
        function obj = IMUBase(varargin)
            obj = obj@matlabshared.libiio.base(varargin{:});
            obj.enableExplicitPolling = false;
            obj.EnabledChannels = 1:6;%IGNORE temp0 FOR NOW
            obj.BufferTypeConversionEnable = true;
            obj.uri = 'ip:analog';
        end
        % Check SamplingRate
        function set.SampleRate(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',1,'<=',2048}, ...
                '', 'SamplesPerFrame');
            obj.SampleRate = value;
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('sampling_frequency',num2str(value));                
            end
        end
        % Check TimeStampClockSource
        function set.TimeStampClockSource(obj, value)
            obj.TimeStampClockSource = value;
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('current_timestamp_clock',value);                
            end
        end

    end   
    
    methods (Access=protected)

        function numOut = getNumOutputsImpl(~)
            numOut = 3;
        end
        
    end
    
    %% Sensor specific APIs
    methods
        function [accelReadings, gyroReadings, valid] = readAccelGyro(obj)
            [accelReadings, gyroReadings, valid] = step(obj);
        end
        function [accelReadings, gyroReadings, magReadings, valid] = readAccelGyroMag(obj)
            [accelReadings, gyroReadings, magReadings, valid] = step(obj);
        end
        function flush(obj)
            flushBuffers(obj);
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function [accelReadings, gyroReadings] = stepAccelGyro(obj, dataR)
            if strcmpi(obj.ReadMode,'latest')
               dataR = dataR(end:-1:1,:); 
            end
            data = obj.AttributeScales.*double(dataR);
            % AngularVelocity
            gyroReadings = data(:,1:3);
            % Acceleration
            accelReadings = data(:,4:6);
            %temp = data(:,7);
        end
        
        function [accelReadings, gyroReadings, magReadings] = stepAccelGyroMag(obj, dataR)
            if strcmpi(obj.ReadMode,'latest')
               dataR = dataR(end:-1:1,:); 
            end
            data = obj.AttributeScales.*double(dataR);
            % AngularVelocity
            gyroReadings = data(:,1:3);
            % Acceleration
            accelReadings = data(:,4:6);
            % Magnitude
            magReadings = data(:,7:9);
            %temp = data(:,10);
        end
        
        function flag = isInactivePropertyImpl(obj, prop)
            flag = isInactivePropertyImpl@adi.common.Sensor(obj, prop);
        end
               
        function scales = setScales(obj)
            scales = zeros(1,length(obj.EnabledChannels));
            for c = 1:length(obj.EnabledChannels)
                scales(c) = obj.getAttributeDouble(obj.channel_names{c},'scale',false);
            end
        end
                
        function setupInit(obj)
            obj.setDeviceAttributeRAW('current_timestamp_clock',obj.TimeStampClockSource);
            obj.setDeviceAttributeRAW('sampling_frequency',num2str(obj.SampleRate));
            obj.AttributeScales = obj.setScales();
        end
        
    end
        
    %% External Dependency Methods
    methods (Hidden, Static)
        
        function tf = isSupportedContext(bldCfg)
            tf = matlabshared.libiio.ExternalDependency.isSupportedContext(bldCfg);
        end
        
        function updateBuildInfo(buildInfo, bldCfg)
            % Call the matlabshared.libiio.method first
            matlabshared.libiio.ExternalDependency.updateBuildInfo(buildInfo, bldCfg);
        end
        
        function bName = getDescriptiveName(~)
            bName = 'ADIS16460';
        end

    end
end

