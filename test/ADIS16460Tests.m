classdef ADIS16460Tests < HardwareTests 
       
    properties
        uri = 'ip:analog';
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.ADIS16460;
            testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
    end
    
    methods (Static)
        function estFrequency(data,fs)
            nSamp = length(data);
            FFTRxData  = fftshift(10*log10(abs(fft(data))));
            df = fs/nSamp;  freqRangeRx = (-fs/2:df:fs/2-df).'/1000;
            plot(freqRangeRx, FFTRxData);
        end
    end
    
    methods (Test)
        
        function testADIS16460(testCase)
            % Test data from all sensors
            rx = adi.ADIS16460('uri',testCase.uri);
            [out1, out2, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out1))),0);
            testCase.verifyGreaterThan(sum(abs(double(out2))),0);
        end
        
    end
    
end

