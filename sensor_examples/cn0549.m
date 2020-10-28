clear all; close all;
uri = 'ip:192.168.86.66';

xl = adi.ADXL1002();
xl.uri = uri;

data = xl();