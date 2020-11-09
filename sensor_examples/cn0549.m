clear all; close all;
uri = 'ip:analog';

%% Configure device for initialization
xl = adi.CN0532();
xl.uri = uri;
xl.SampleRate = '16000';
xl.SamplesPerRead = 2^14;
xl.FDAMode = 'FullPower';
% xl.ShiftVoltageMV = 4240;

%% Collect data
data = xl();

%% Plot data
ts = 1/str2double(xl.SampleRate);
t = 0:ts:(length(data)-1)*ts;
plot(t,data);
xlabel('Time (s)');ylabel('ADC Codes');grid on;
ylim([min(data)-abs(min(data)*0.01) max(data)+abs(max(data)*0.01)]);