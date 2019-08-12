function sensor = IMU(partname)

rootDir = fileparts(mfilename('fullpath'));
filetext = fileread(fullfile(rootDir,'imudata.json'));
data = jsondecode(filetext);

parts = {data.PartName};

for p = 1:length(parts)
    if strcmpi(partname,parts{p})
        sensor = imuSensor;
        s = data(p).gyroparams;
        F = fieldnames(s);
        C = struct2cell(s);
        for c = 1:length(C)
            tmp = C{c};
            C{c} = tmp(:).';
        end
        PV = [reshape(F, 1, []); reshape(C, 1, [])];
        sensor.Gyroscope = gyroparams(PV{:});
        return
    end
end

error('Unknown part specified');

end