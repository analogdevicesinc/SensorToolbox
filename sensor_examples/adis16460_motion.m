clear all; %#ok<CLALL>

%% ADIS16460 Motion Example

%% Setup
% IMU
IMU = adi.ADIS16460;
IMU.SamplesPerRead = 1;
IMU.uri = 'ip:analog';
IMU.SampleRate = 1;
fs = IMU.SampleRate;
% Filter
ifilt = imufilter('SampleRate', fs);
% Scopes
N = 64;
viewer = HelperOrientationViewer;
ts = dsp.TimeScope;
ts.SampleRate = fs;
ts.TimeSpanOverrunAction = 'Scroll';
ts.TimeSpan = 1/fs*N;
ts.NumInputPorts = 2;
ts.ShowLegend = true;
ts.ChannelNames = {'Acceleration X','Acceleration Y','Acceleration Z',...
    'Angular Velocity X','Angular Velocity Y','Angular Velocity Z'};
ts.ShowGrid = true;
ts.LayoutDimensions = [2 ,1];
ts.AxesScaling = 'Auto';
ts_parts = clone(ts);
ts_parts.LayoutDimensions = [1 ,1];
ts_parts.NumInputPorts = 4;
ts_parts.ChannelNames = {'W','X','Y','Z'};

%% Get info
numSamples = 10;
t = 0:1/fs:(numSamples-1)/fs;

for k=1:N

    [acc,gyro] = deal(zeros(numSamples,3));
    for n = 1:numSamples
        [acc(n,:),gyro(n,:)] = IMU();
        pause(0.001);
    end
    
    for ii=1:1:size(acc,1)
        qimu = ifilt(acc(ii,:), gyro(ii,:));
        viewer(qimu);
        pause(0);
    end
    ts(acc(ii,:), gyro(ii,:));
    [w,x,y,z] = qimu.parts;
    ts_parts(w,x,y,z);
end

%% Cleanup
release(ifilt);
release(IMU);
release(viewer);
release(ts);
