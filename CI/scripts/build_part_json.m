
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
    template = gyroparams;
    % degrees/s -> rad/s
    template.MeasurementRange = data.GyroInputRangemin(part)*pi/180;
    
    template.ConstantBias
    
    % Degrees -> %
    template.AxesMisalignment = sin(data.GyroAxistoAxisAlignmenttyp(part))*100;
    % Degrees/s/sqrt(Hz) RMS -> Rad/s/sqrt(Hz)
    if ~isnan(data.GyroNoiseDensitytyp(part))
        template.NoiseDensity = data.GyroNoiseDensitytyp(part)*pi/180;
    end
    % Degrees/hr -> rad/s
    if ~isnan(data.GyroInRunBiasStabilitytyp(part))
        template.BiasInstability = data.GyroInRunBiasStabilitytyp(part)*pi/180*1/3600;
    end
    
    
    %     template.RandomWalk = data.GyroAngularRandomWalktyp*
    
    % Degree/sqrt(hr) = (rad/s)*sqrt(hz)
    % Degree/sqrt(hr) = (rad/s)*sqrt(1/s)
    
    % Degrees/s/sqrt(Hz) -> Degrees/sqrt(Hz)  sqrt(s/hour)
    
    % Degrees/s/g -> rad/s/(m/s^2)
    template.AccelerationBias = data.GyroLinearGtyp(part)*pi/180*G;
    
    %
    %     template.Resolution
    % GRAPHS
    %     template.TemperatureBias = data.
    %     template.TemperatureScaleFactor
    
    
    %% Accel
    
    
    %% Pack
    p = struct;
    p.PartName = data.Part(part);
    p.gyroparams = template;
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