classdef Rx < adi.AD4020.Base & adi.common.Rx
    % adi.AD4020.Rx Receive data from the AD9467 high speed ADC
    %   The adi.AD4020.Rx System object is a signal source that can receive
    %   data from the AD4020.
    %
    %   rx = adi.AD4020.Rx;
    %   rx = adi.AD4020.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD4020.pdf">AD9467 Datasheet</a>
    
    properties (Dependent)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. This value read from the hardware after
        %   the object is setup.
        SamplingRate
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {'voltage0'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'ad4020';
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD4020.Base(varargin{:});
        end
        function value = get.SamplingRate(obj)
            if obj.ConnectedToDevice
                id = 'voltage0';
                value = obj.getAttributeLongLong(id,'sampling_frequency',false);
            else
                value = 0;
            end
        end

    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function numOut = getNumOutputsImpl(obj)
            numOut = ceil(obj.channelCount) + 1; % +1 for valid
        end
        
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
        end
        
        % Hide unused parameters when in specific modes
        function flag = isInactivePropertyImpl(obj, prop)
            % Call the superclass method
            flag = isInactivePropertyImpl@adi.common.RxTx(obj,prop);
        end
    end
    
    methods (Access=protected)
        

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
            bName = 'AD4020';
        end
        
    end
end

