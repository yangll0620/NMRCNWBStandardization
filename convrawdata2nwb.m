function convrawdata2nwb(block, task, animal, dateofExp)
%% Questions:
%       1. should we combine all the blocks for the same task on one day
%       2. will the video files be attached? Generally, they are very large
%       (~ 300M)
%       3.  TDT2mat -- run tdt2mat: 137s, tdt saving: (43s,877M), tdt loading: 12s
%       4. randomly generate the x, y, z coordinates for each electrode
%       5. framework:   1)  combine Streamer\*.sev and Local\*tbk to sevtbkpath
%                       2)  TDT2mat
%                       3)  nwb initiation:
%                               nwbfile('identifier','***', 'file_create_date', now, 'session_description', '***')
%                       4)  input general information:
%                               nwb.general_source_scrip,
%                               nwb.general_source_script_file_name,
%                               nwb.general_surgery, et.al
%                       5) input electrode or device information
%                       6) store the raw TDT neural data
%

if nargin < 4
    animal = 'Bug';
end
if nargin < 3
    dateofExp = datenum('20181130','yyyymmdd');
end
if nargin < 2
    task = 'GaitTask';
end
if nargin < 1
    block = 1;
end
datasetpath = getdatasetpath();
rawdatapath = fullfile(datasetpath, animal, 'Data', 'ExpData', 'Raw');
preprocedatapath = fullfile(datasetpath, animal, 'Data', 'ExpData', 'Preprocessed');

%% combine files from streamer and local folders
rawTDTpath = fullfile(rawdatapath, [animal '-' datestr(dateofExp, 'yymmdd')], task, 'rawTDT', ['Block-' num2str(block)]);
streamerpath = fullfile(rawTDTpath, 'Streamer'); % streamerpath: store the ch*.sev files
localpath = fullfile(rawTDTpath, 'Local'); % localpath: store .Tbk, .Tdx, .tev et.al files,.avi files and StoresListing.txt
combinedTDTfilespath = fullfile(rawTDTpath, 'TDTfiles_combine');
copy2combinedpath(streamerpath, localpath, combinedTDTfilespath);

%% TDT2mat function TDTbin2mat: 137s, tdt saving: (43s,877M), tdt loading: 12s
inter_tdtdata = 'test_TDT2mat.mat';
if ~exist(inter_tdtdata,'file')
    tdt = TDTbin2mat(combinedTDTfilespath);
    save(inter_tdtdata, 'tdt')
else
    load(inter_tdtdata, 'tdt')
end
streams_name = fieldnames(tdt.streams);
stream = tdt.streams.(streams_name{1});

%% nwb file initiation
identifier = [animal '_' datestr(dateofExp,'yyyymmdd') '_' task '_Block' num2str(block)];
% create nwb file
session_description = ['NWB file test on ' animal ' performing ' task ' on ' datestr(dateofExp,'yyyymmdd')];
nwb = nwbfile(...
    'identifier', identifier, ...
    'session_description', session_description, ...
    'file_create_date', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

%% general information
source_file = [fullfile(pwd, mfilename()) '.m'];
[~, source_script, ~] = fileparts(source_file);
nwb.general_source_script = source_script; % Script file used to create this NWB file.
nwb.general_source_script_file_name = source_file; % Script file used to create this NWB file.

%% electrode information
etrodes = stream.channels;
n_etrodes = length(etrodes);
etrode_labels = cell(1, n_etrodes);
etrode_labels(1, 1:96) = {'Utah'};
etrode_labels(1, 97:end) = {'Gray Matter'};
devices_name = unique(etrode_labels, 'stable');
colNames = {'id','array_label','x', 'y', 'z', 'label'};
etrodeMat = rand([n_etrodes,3]); % randomly generate the x, y, z coordinates for each electrode
for i_device = 1: length(devices_name)
    device_name = devices_name{i_device};
    nwb.general_devices.set( device_name, types.core.Device());
    nwb.general_extracellular_ephys.set(device_name, ...
        types.core.ElectrodeGroup( ...
        'description', 'a test ElectrodeGroup', ...
        'location', 'unknown', ...
        'device', types.untyped.SoftLink(['/general/devices/' device_name])));
    
    device_object_view = types.untyped.ObjectView( ...
        ['/general/extracellular_ephys/' device_name]);
    
    elec_nums = find(strcmp(etrode_labels, device_name));
    for i_elec = 1:length(elec_nums)
        elec_num = elec_nums(i_elec);
        coord_x = etrodeMat(elec_num,1); coord_y = etrodeMat(elec_num,2); coord_z = etrodeMat(elec_num,3);
        if i_device == 1 && i_elec == 1
            tbl = table(elec_num, device_object_view, ...
                coord_x, coord_y, coord_z, {'electrode'}, ...
                'VariableNames', colNames);
        else
            tbl = [tbl; {elec_num, device_object_view, ...
                coord_x, coord_y, coord_z, 'electrode_label'}];
        end
    end
    
end
electrode_table = util.table2nwb(tbl, 'all electrodes');
nwb.general_extracellular_ephys_electrodes = electrode_table;

%% raw TDT data to NWB.acquisition
date = datevec([tdt.info.date tdt.info.utcStartTime], 'yyyy-mmm-ddHH:MM:SS');
nwb.session_start_time = datestr(date, 'yyyy-mm-dd HH:MM:SS');
nrows = length(nwb.general_extracellular_ephys_electrodes.id.data);
tablereg = types.core.DynamicTableRegion(...
    'description','Relevent Electrodes for this Electrical Series',...
    'table',types.untyped.ObjectView('/general/extracellular_ephys/electrodes'),...
    'data',(1:nrows) - 1);
es = types.core.ElectricalSeries(...
    'starting_time', stream.startTime, ...
    'starting_time_rate',stream.fs,...
    'data',stream.data,...
    'electrodes', tablereg);  % electrode is required, otherwise error when exporting
rawname = 'rawTDT';
nwb.acquisition.set(rawname, es);

%% Gaitmat System raw pressure data and video data to NWB.acquistion
% the mp4 data
gaitvideopath = fullfile(rawdatapath, [animal '-' datestr(dateofExp,'yymmdd')], task, 'SideVideo');
gaitvideo = fullfile(gaitvideopath, 'CPB09_113018.mp4');
videoname = 'sidevideo';
imgsvideo = types.core.ImageSeries(...
    'data_unit','mp4', ...
    'data', gaitvideo);
nwb.acquisition.set(videoname, imgsvideo);

%%   stop here
% the pressure *.fsx file
pressfilepath = fullfile(rawdatapath, [animal '-' datestr(dateofExp,'yymmdd')], task, 'Gaitmat');
pressfile = fullfile(pressfilepath, 'CPB09.fsx');
pressname = 'pressure';
imgspress = types.core.ImageSeries(...
    'data_unit','Tekscan', ...
    'data', pressfile);
nwb.acquisition.set(pressname, imgspress);
%% export
outloc = fullfile(preprocedatapath, animal,[animal '-' datestr(dateofExp, 'yymmdd')] ,task);
if 7 ~= exist(outloc, 'dir')
    mkdir(outloc);
end
outdest = fullfile(outloc, [identifier '.nwb']);
nwbExport(nwb, outdest);








