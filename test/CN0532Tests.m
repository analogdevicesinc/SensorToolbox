classdef CN0532Tests < CN0540Tests 
    
    methods (Test)

        function testCN0532(testCase)
            % Verify data is non-zero
            testCase.testCN0540Base();
        end

        function testCN0532Calibration(testCase)
            % Test calibration method
            testCase.testCN0540BaseCalibration();
        end
 
    end
    
end