classdef (Abstract) CN0540Base < matlab.system.mixin.CustomIcon & adi.common.Rx ...
        & matlabshared.libiio.base & adi.common.Attribute ...
        & adi.common.Sensor
    %Base class for all CN0540 sensors classes    
    properties
        %SampleRate Sample Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. Options are:
        %   '256000','128000','64000','32000','16000','8000','4000',
        %   '2000','1000'
        SampleRate = '256000';
    end
    
    properties(Nontunable, Hidden, Constant)
        channel_names = {...
            'voltage0'};
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties (Hidden, Nontunable, Access = protected, Abstract)
        CommonModeVoltage;
    end
    
    properties(Constant, Hidden)
        SampleRateSet = matlab.system.StringSet({ ...
            '256000','128000','64000','32000','16000','8000','4000','2000','1000'});
        CommonModeVoltageSet = matlab.system.StringSet({ ...
            '(AVDD1-AVSS)/2','2V5','2V05','1V9','1V65','1V1','0V9','OFF'});
    end
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 2;
        dataTypeStr = 'int32';
        phyDevName = 'ad7768-1';
        devName = 'ad7768-1';
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
    end
    
    properties (Hidden, Constant)
        ComplexData = false;
    end

    methods
        %% Constructor
        function obj = CN0540Base(varargin)
            obj = obj@matlabshared.libiio.base(varargin{:});
            obj.enableExplicitPolling = false;
            obj.EnabledChannels = 1;
            obj.BufferTypeConversionEnable = true;
            obj.uri = 'ip:analog';
        end
        function flush(obj)
            flushBuffers(obj);
        end
        % Check SamplingRate
        function set.SampleRate(obj, value)
            obj.SampleRate = value;
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('sampling_frequency',value);                
            end
        end
    end   
    
    methods (Access=protected)

        function numOut = getNumOutputsImpl(~)
            numOut = 1;
        end
        
    end
    
    %% Sensor specific APIs
    methods
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function flag = isInactivePropertyImpl(obj, prop)
            flag = isInactivePropertyImpl@adi.common.Sensor(obj, prop);
        end
                
        function setupInit(obj)
            obj.setDeviceAttributeRAW('common_mode_voltage',obj.CommonModeVoltage);
            obj.setDeviceAttributeRAW('sampling_frequency',num2str(obj.SampleRate));
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

