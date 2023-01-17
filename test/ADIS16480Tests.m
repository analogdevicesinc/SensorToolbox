classdef ADIS16480Tests < HardwareTests 
       
    properties
        uri = 'ip:analog';
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.ADIS16480;
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
        
        function testADIS16480(testCase)
            % Test data from acceletometer and gyroscope sensors
            imu = adi.ADIS16480('uri',testCase.uri);
            imu.EnabledChannels = 1:6;
            [accellReadings, gyroReadings, valid] = imu();
            imu.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(accellReadings))),0);
            testCase.verifyGreaterThan(sum(abs(double(gyroReadings))),0);
        end
        
        function testADIS16480Gravity(testCase)
            % Verify data from accelerometer with only acceleration due to gravity
            imu = adi.ADIS16480('uri',testCase.uri);
            imu.EnabledChannels = 1:6;
            [accelReadings, ~, valid] = imu();
            imu.release();
            
            g = 9.80665;
            meanMagnitude = mean(sqrt(sum(accelReadings.^2,2)));
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(meanMagnitude,0.99*g);
            testCase.verifyLessThan(meanMagnitude,1.01*g);
        end
        
    end
    
end