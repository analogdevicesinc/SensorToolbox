clear all; %#ok<CLALL>

%% ADIS16480 Motion Example

%% Setup
% IMU
IMU = adi.ADIS16480;
IMU.SamplesPerRead = 8;
IMU.uri = 'ip:analog';
IMU.SampleRate = 128;
IMU.EnabledChannels = 1:6;
fs = IMU.SampleRate;
% Filter
ifilt = imufilter('SampleRate', fs);
% Scopes
N = 500;
viewer = HelperOrientationViewer;
useScope = true;
if useScope
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
end
%% Get info
numSamples = IMU.SamplesPerFrame;
t = 0:1/fs:(numSamples-1)/fs;

for k=1:N
    [acc,gyro] = IMU();
    for ii=1:size(acc,1)
        qimu = ifilt(acc(ii,:), gyro(ii,:));
        viewer(qimu);
        pause(0);
    end
    if useScope
        ts(acc(ii,:), gyro(ii,:));
        [w,x,y,z] = qimu.parts;
        ts_parts(w,x,y,z);
    end
end

%% Cleanup
release(ifilt);
release(IMU);
release(viewer);
% release(ts);
