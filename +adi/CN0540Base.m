classdef (Abstract) CN0540Base < matlab.system.mixin.CustomIcon & adi.common.Rx ...
        & matlabshared.libiio.base & adi.common.Attribute ...
        & adi.common.Sensor
    %Base class for all CN0540 sensors classes
    properties (Nontunable)
        %SampleRate Sample Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. Options are:
        %   '256000','128000','64000','32000','16000','8000','4000',
        %   '2000','1000'
        SampleRate = '256000';
    end
    
    properties (Nontunable)
        %ShiftVoltageMV Shift Voltage MV
        %   DAC shift voltage use to bias ADC input. This can only be set
        %   at startup and will become read-only
        ShiftVoltageMV = NaN;
    end
    
    properties (Nontunable)
        %FDAMode FDA Mode
        %   Set amplified power mode. Options are:
        %   -FullPower
        %   -LowPower
        FDAMode = 'FullPower';
    end
    
    properties (Logical, Nontunable)
        %EnableCalibration Enable Calibration
        %   Calibrate sensor voltage DC bias at startup
        EnableCalibration = false;
    end
        
    properties (Logical)
        %MonitorPowerup Monitor Powerup
        %   Monitor ADC powerup status
        MonitorPowerup = true;
        %FDADisableStatus FDA Disable Status
        %   Enable amplifier status check
        FDADisableStatus = false;
        %EnableBlueLED Enable Blue LED
        %   Enable blue LED on board
        EnableBlueLED = true;
        %EnableRedLED Enable Red LED
        %   Enable red LED on board
        EnableRedLED = true;
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
        FDAModeSet = matlab.system.StringSet({'FullPower','LowPower'});
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
        DACBufferGain = 1.22;
        G = 0.3;
        FDAGain = 2.667;
        FDAVocmMv = 2500;
    end
    
    properties (Hidden, Constant)
        ComplexData = false;
    end
    
    properties (Hidden)
        gpio;
        ltc2606;
        % ltc2308;
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
        function set.ShiftVoltageMV(obj, value)
            if obj.ConnectedToDevice
                dac_scale = obj.getAttributeDouble('voltage0', 'scale', true, obj.ltc2606);
                raw = value / (dac_scale * obj.DACBufferGain);
                obj.setAttributeLongLong('voltage0','raw',int64(raw),true,0,obj.ltc2606);%#ok<*MCSUP>
            end
            obj.ShiftVoltageMV = value;
        end
        % Check SamplingRate
        function set.SampleRate(obj, value)
            obj.SampleRate = value;
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('sampling_frequency',value);
            end
        end
        
        function set.MonitorPowerup(obj, value)
            obj.MonitorPowerup = value;
            if obj.ConnectedToDevice
                obj.setAttributeBool('voltage2','raw',value,true,obj.gpio);%#ok<*MCSUP>
            end
        end
        
        function set.FDAMode(obj, value)
            obj.FDAMode = value;
            if obj.ConnectedToDevice
                rvalue = strcmpi(obj.FDAMode,'FullPower');
                obj.setAttributeBool('voltage6','raw',rvalue,true,obj.gpio);%#ok<*MCSUP>
            end
        end
        function set.FDADisableStatus(obj, value)
            obj.FDADisableStatus = value;
            if obj.ConnectedToDevice
                obj.setAttributeBool('voltage5','raw',value,true,obj.gpio);%#ok<*MCSUP>
            end
        end
        
        function set.EnableBlueLED(obj, value)
            obj.EnableBlueLED = value;
            if obj.ConnectedToDevice
                obj.setAttributeBool('voltage1','raw',value,true,obj.gpio);%#ok<*MCSUP>
            end
        end
        function set.EnableRedLED(obj, value)
            obj.EnableRedLED = value;
            if obj.ConnectedToDevice
                obj.setAttributeBool('voltage0','raw',value,true,obj.gpio);%#ok<*MCSUP>
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
        
        function calibrate(obj)
            % Tune LTC2606 to make AD7768-1 ADC codes zero mean
            adc_scale = obj.getAttributeDouble('voltage0', 'scale', false);
            dac_scale = obj.getAttributeDouble('voltage0', 'scale', true, obj.ltc2606);
            
            % Write low value first
            dvoltage = 2000;
            obj.setAttributeLongLong('voltage0', 'raw', int64(dvoltage), true, 0, obj.ltc2606);
            
            for t = 1:20
                araw = obj.getAttributeDouble('voltage0', 'raw', false);
                draw = obj.getAttributeDouble('voltage0', 'raw', true, obj.ltc2606);
                dvoltage = (draw * dac_scale - araw*adc_scale)/dac_scale;
                if dvoltage > 65535
                    dvoltage = 65535;
                end
                disp(araw*adc_scale);
                obj.setAttributeLongLong('voltage0', 'raw', int64(dvoltage), true, 0, obj.ltc2606);
                pause(0.01)
            end
            
        end
        
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            
            % Get additional devices
            obj.gpio = getDev(obj, 'one-bit-adc-dac');
            obj.ltc2606 = getDev(obj, 'ltc2606');
%             obj.ltc2308 = getDev(obj, 'ltc2308');
            
            obj.setDeviceAttributeRAW('common_mode_voltage',obj.CommonModeVoltage);
            obj.setDeviceAttributeRAW('sampling_frequency',num2str(obj.SampleRate));
            
            obj.setAttributeBool('voltage0','raw',obj.EnableBlueLED,true,obj.gpio);
            obj.setAttributeBool('voltage1','raw',obj.EnableRedLED,true,obj.gpio);
            
            rvalue = strcmpi(obj.FDAMode,'FullPower');
            obj.setAttributeBool('voltage6','raw',rvalue,true,obj.gpio);%#ok<*MCSUP>
            
            obj.setAttributeBool('voltage5','raw',obj.FDADisableStatus,true,obj.gpio);
            obj.setAttributeBool('voltage2','raw',obj.MonitorPowerup,true,obj.gpio);
            
            
            % Shift voltage
            if isnan(obj.ShiftVoltageMV)
                dac_scale = obj.getAttributeDouble('voltage0', 'scale', true, obj.ltc2606);
                draw = obj.getAttributeDouble('voltage0', 'raw', true, obj.ltc2606);
                obj.ShiftVoltageMV = draw * dac_scale * obj.DACBufferGain;
            else
                dac_scale = obj.getAttributeDouble('voltage0', 'scale', true, obj.ltc2606);
                raw = obj.ShiftVoltageMV / (dac_scale * obj.DACBufferGain);
                obj.setAttributeLongLong('voltage0','raw',int64(raw),true,0,obj.ltc2606);
            end
            
            % Set
            if obj.EnableCalibration
                obj.calibrate();
            end
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
            bName = 'CN0540 Based Device';
        end
        
    end
end

