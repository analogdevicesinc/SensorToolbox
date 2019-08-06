classdef Rx < matlab.system.mixin.CustomIcon & adi.common.Rx ...
        & matlabshared.libiio.base & adi.common.Attribute
    %RX ADIS16460 Inertial Measurement Unit
    %   The adi.ADIS16460.Rx System object is a signal source that can
    %   collect IMU data from the ADIS16460.
    %
    %   rx = adi.ADIS16460.Rx;
    %   rx = adi.ADIS16460.Rx('uri','ip:analog');
    %
    %   [accelReadings, gyroReadings, valid] = rx() produces two outputs
    %   where accelReadings is a Nx3 matrix containing acceleration data
    %   for x, y, and z respectively in m/s^2 where N is SamplesPerFrame.
    %   gyroReadings is the same as accel except it contains angular
    %   velocity data for x, y, and z in rad/s. valid is a logical to
    %   determine if the data is valid.
    %
    %   Each collected measurement within a buffer is guaranteed to be
    %   contiguous within that buffer. However, successive buffers are not.
    %
    %   <a href="https://www.analog.com/media/en/technical-documentation/data-sheets/ADIS16460.pdf">ADIS16460 Datasheet</a>        
    properties (Nontunable)
        %SamplesPerFrame Samples Per Frame
        %   Number of samples per frame, specified as an even positive
        %   integer from 2 to 16,777,216.
        SamplesPerFrame = 1024;
    end
    properties
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second.
        SamplingRate = 1024;
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
        dataTypeStr = 'int32';
        phyDevName = 'adis16460';
        devName = 'adis16460';
    end
    
    properties(Nontunable, Hidden, Constant)
%         channel_names = {'anglvel_x','anglvel_y','anglvel_z',...
%             'accel_x','accel_y','accel_z','temp0'};
        channel_names = {'anglvel_x','anglvel_y','anglvel_z',...
            'accel_x','accel_y','accel_z'};
        Type = 'Rx';
    end
    
    properties (Hidden, Constant)
        ComplexData = false;
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            obj = obj@matlabshared.libiio.base(varargin{:});
            obj.enableExplicitPolling = false;
            obj.EnabledChannels = 1:6;%IGNORE temp0 FOR NOW
            obj.BufferTypeConversionEnable = true;
            obj.uri = 'ip:analog';
        end
        % Check SamplingRate
        function set.SamplingRate(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',1,'<=',2048}, ...
                '', 'SamplesPerFrame');
            obj.SamplingRate = value;
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
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function [accelReadings, gyroReadings, valid] = stepImpl(obj)
            [dataR, valid] = stepImpl@adi.common.Rx(obj);
            data = obj.AttributeScales.*double(dataR);
            % AngularVelocity
            gyroReadings = data(:,1:3);
            % Acceleration
            accelReadings = data(:,4:6);
            %temp = data(:,7);
        end
        
        function flag = isInactivePropertyImpl(obj, prop)
            flag = isInactivePropertyImpl@adi.common.RxTx(obj, prop);
            flag = flag || strcmpi(prop,'EnabledChannels');
        end
        
        function icon = getIconImpl(obj)
            icon = sprintf(['ADIS16460 ',obj.Type]);
        end
        
        function scales = setScales(obj)
            d = 0;
            scales = zeros(1,length(obj.channel_names)-d);
            for c = 1:length(obj.channel_names)-d
                scales(c) = obj.getAttributeDouble(obj.channel_names{c},'scale',false);
            end
        end
        
        function setupInit(obj)
            obj.setDeviceAttributeRAW('current_timestamp_clock',obj.TimeStampClockSource);
            obj.setDeviceAttributeRAW('sampling_frequency',num2str(obj.SamplingRate));
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

