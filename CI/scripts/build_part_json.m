
if ~isunix
    error('Build is only supported on Linux');
end
loc = pwd;
cd(fileparts(mfilename('fullpath')));

data = importfile('ADIParametricSearch.csv');

numParts = size(data,1);
G = 9.80665;

parts = [];

for part = 1:numParts
    %% Gyro
    templateGyro = gyroparams;
    % degrees/s -> rad/s
    templateGyro.MeasurementRange = data.GyroInputRangemin(part)*pi/180;
        
    % Degrees -> %
    templateGyro.AxesMisalignment = sin(data.GyroAxistoAxisAlignmenttyp(part))*100;
    % Degrees/s/sqrt(Hz) RMS -> Rad/s/sqrt(Hz)
    if isnan(data.GyroNoiseDensitytyp(part))
        continue;
    end
    templateGyro.NoiseDensity = data.GyroNoiseDensitytyp(part)*pi/180;
    % Degrees/hr -> rad/s
    if isnan(data.GyroInRunBiasStabilitytyp(part))
        continue;
    end
    templateGyro.BiasInstability = data.GyroInRunBiasStabilitytyp(part)*pi/180*1/3600;   
    
    % Degree/sqrt(hr) = (rad/s)*sqrt(hz)
    % Degree/sqrt(hr) = (rad/s)*sqrt(1/s)
    
    % Degrees/s/sqrt(Hz) -> Degrees/sqrt(Hz)  sqrt(s/hour)
    
    % Degrees/s/g -> rad/s/(m/s^2)
    templateGyro.AccelerationBias = data.GyroLinearGtyp(part)*pi/180*G;
    
%     templateGyro.ConstantBias;
%     template.Resolution
% GRAPHS
%     template.TemperatureBias = data.
%     template.TemperatureScaleFactor
%     template.RandomWalk = data.GyroAngularRandomWalktyp*
    
    
    %% Accel
    templateAccel = accelparams;
    
    templateAccel.MeasurementRange = data.AccelRange(part)*G;
    
    
    templateAccel.AxesMisalignment = sin(data.AccelerometerAxistoAxisAlignmenttyp(part))*100;
    templateAccel.NoiseDensity = data.NoiseDensitytyp(part)*G;
    templateAccel.BiasInstability = data.AccelInRunBiasStabilitytyp(part)*G;
    
    % 
%     templateAccel.RandomWalk = data.AccelerometerVelocityRandomWalktyp(part)*
    
%     templateAccel.ConstantBias;
%     templateAccel.Resolution
%     templateAccel.TemperatureBias
%     templateAccel.TemperatureScaleFactor
    
    
    %% Pack
    p = struct;
    p.PartName = data.Part(part);
    p.gyroparams = templateGyro;
    p.accelparams = templateAccel;
    parts = [parts;p]; %#ok<AGROW>
    
    
end

%% Create json file
j = jsonencode(parts);
fileID = fopen('data.json','w');
fprintf(fileID,'%s',j);
fclose(fileID);
pause(1);

%% Format json nicely
!python -m json.tool data.json imudata.json

%% Move to installed folder
delete data.json
movefile('imudata.json','../../+adi/+sim/','f');
cd(loc);

%% Status
disp('IMU data JSON packaging complete!');