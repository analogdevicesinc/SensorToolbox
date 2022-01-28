classdef CN0540Tests < HardwareTests 
    
    properties
        uri = 'ip:analog';
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.CN0532;
            testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
    end
    
    methods (Test)
        
        function testCN0540Base(testCase)
            % Verify data is non-zero with or without sensor connected
            daq = adi.CN0532();
            daq.uri = testCase.uri;
            [accelReadings, valid] = daq();
            daq.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(accelReadings))),0);
        end
        
        
        function testCN0540BaseCalibration(testCase)
            % Test calibration method
            % How to reset calibration settings? Power-cycle?
            daq = adi.CN0532();
            daq.uri = testCase.uri;
            [accelReadings0, valid0] = daq();
            daq.release(); clear daq;
            daq = adi.CN0532();
            daq.uri = testCase.uri;
            daq.EnableCalibration = 1;
            for t = 1 : 5
                [accelReadings1, valid1] = daq();
            end
            daq.release();
            checkRange = [diff(max([accelReadings1, accelReadings0])),...
                            diff(min([accelReadings1, accelReadings0]))];
            deltaMean = diff(mean([accelReadings1, accelReadings0]));
            testCase.verifyTrue(valid0);
            testCase.verifyTrue(valid1);
            testCase.verifyGreaterThan(sum(abs(double(accelReadings0))),0);
            testCase.verifyGreaterThan(sum(abs(double(accelReadings1))),0);
            testCase.verifyTrue(ismember(round(deltaMean),...
                            min(checkRange):max(checkRange)));
        end
        
        function testCN0540BaseSineInput(testCase)
            % Test data from signal generator
            % Requires 1kHz signal connected to CN0540 either at J3 SMA or P7 Vin
            frequency = 1000;
            daq = adi.CN0532();
            daq.uri = testCase.uri;
            [accelReadings, valid] = daq();
            daq.release();
            freqEst = meanfreq(double(accelReadings),...
                            str2double(string(daq.SampleRate)),[500 1500]);
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(accelReadings))),0);
            testCase.verifyEqual(freqEst,frequency,'RelTol',0.01,...
                'Frequency of signal unexpected');
        end
 
    end
    
end