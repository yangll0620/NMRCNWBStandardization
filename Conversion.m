%% Questions:
%       1. should we combine all the blocks for the same task on one day
%       2. will the video files be attached? Generally, they are very large
%       (~ 300M)


clear
%% matnwb path
if ispc % PC (Windows) in LRB 411
    dropboxpath = 'E:'; 
end
if ismac % mac notebook
    dropboxpath = '/Users/linglingyang';
end
projectpath = fullfile(dropboxpath, 'Dropbox', 'NMRC', 'Projects', ...
    'DataStorageAnalysisArchitecture', 'NWBtest');
matnwbpath = fullfile(projectpath, 'matnwb');
datasetpath = fullfile(projectpath, 'dataset');

%% Script start here
addpath(matnwbpath)
%% script configuration
animal = 'Bug';
dateOfExp = '20181130';
task = 'Habittrail';
block = 1;

identifier = [animal '_' dateOfExp '_' task '_Block' num2str(block)];
rawdata_loc = fullfile(datasetpath, animal, 'Recording', 'Raw');
outloc = fullfile(projectpath,'out');
if 7 ~= exist(outloc, 'dir')
    mkdir(outloc)
end
source_file = [fullfile(pwd, mfilename()) '.m'];
[~, source_script, ~] = fileparts(source_file);
%%
nwb = nwbfile();
%% general information
nwb.identifier = identifier;
nwb.general_surgery = ['DBS in STN using ** DBS lead, 3 * 96 chns in PMd, DLPFC,''' ... 
    'and one Gray Matter in SMA ... et.al'];  % depict what information can be put here, the content is not correct
nwb.general_source_script = source_script; % Script file used to create this NWB file.
nwb.general_source_script_file_name = source_file; % Script file used to create this NWB file.
nwb.session_description = sprintf('NHP %s performed %s on %s', animal, task, dateOfExp);
nwb.general_experiment_description = 'Habit trail experiment'; % General description of the experiment
nwb.file_create_date = date(); 
nwb.session_start_time = datetime(dateOfExp, 'InputFormat','yyyyMMdd');% required, Date and time of the experiment/session start. COMMENT: - The date is stored in UTC with local timezone offset as ISO 8601 extended formatted string: 2018-09-28T14:43:54.123+02:00 - Dates stored in UTC end in "Z" with no timezone offset. - Date accuracy is up to milliseconds.


%% device information
ADCName = 'TDT (132 channels)';
nwb.general_devices.set( ADCName, types.core.Device());
arrayName = 'Gray Matter';
nwb.general_devices.set( arrayName, types.core.Device());

egroup = types.core.ElectrodeGroup(...
    ''
    );

%% raw data

    
%% export
outdest = fullfile(outloc, [identifier '.nwb']);
nwbExport(nwb, outdest);
