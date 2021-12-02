clear all; %#ok<CLALL>

%% ADIS16480 Example

%% Setup
% IMU
IMU = adi.ADIS16480;
IMU.SamplesPerRead = 32;
IMU.uri = 'ip:analog';
IMU.EnabledChannels = 1:6;
% Filter
fs = IMU.SampleRate;
aFilter = imufilter('SampleRate',fs);

%% Get info
numSamples = IMU.SamplesPerFrame;
t = 0:1/fs:(numSamples-1)/fs;

[accelBody,gyroBody] = IMU();
orientation = aFilter(accelBody,gyroBody);

%% Cleanup
release(aFilter);
release(IMU);

%% Plot
figure;
plot(t,eulerd(orientation,'ZYX','frame'))
xlabel('Time (s)')
ylabel('Rotation (degrees)')
title('Orientation Estimation -- IMU Data, Default IMU Filter')
legend('Z-axis','Y-axis','X-axis');
grid on;
figure;
plot(t,accelBody);title('Acceleration');
xlabel('Time (s)')
ylabel('m/s^2');
legend('X-axis','Y-axis','Z-axis');
grid on;
figure;
plot(t,gyroBody);title('Angular Velocity');
xlabel('Time (s)');
ylabel('rad/s');
legend('X-axis','Y-axis','Z-axis');
grid on;