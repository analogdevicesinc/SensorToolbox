
if ~isunix
    error('Build is only supported on Linux');
end
loc = pwd;
cd(fileparts(mfilename('fullpath')));

%% Add schema
sigs = struct;
sigs.schemaVersion = "1.0.0";
sign.IMU = struct;

%% Get part data
filetext = fileread('../../+adi/+sim/imudata.json');
data = jsondecode(filetext);

%% Fill in parts
name = "Part";
parts = {data.PartName};
str_parts = '{';
for p = 1:length(parts)
    str_parts = sprintf("%s'%s',",str_parts,parts{p});
end
str_parts = char(str_parts);
str_parts = [str_parts(1:end-1),'}'];
str_parts = string(str_parts);

str = sprintf("choices=%s", str_parts);
type = ["char",str];

input = struct;
input.name = name;
input.type = type;
sigs.IMU.inputs = {input};

%% Convert to json
j = jsonencode(sigs);
fileID = fopen('data.json','w');
fprintf(fileID,'%s',j);
fclose(fileID);
pause(1);

%% Replace schemaVersion and namespace device
!sed -i 's/schemaVersion/\_schemaVersion/g' data.json 
!sed -i 's/IMU/adi\.sim\.IMU/g' data.json

%% Format json
!python -m json.tool data.json functionSignatures.json

%% Move to installed folder
delete data.json
movefile('functionSignatures.json','../../','f');
cd(loc);
