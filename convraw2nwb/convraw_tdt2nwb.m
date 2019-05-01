function nwb = convraw_tdt2nwb(rawtdtpath, nwb, exportnwbtag)
% % CONVRAW_TDT2NWB convert raw TDT data in rawtdtpath to NWB.acquisition
% 
% Example usage:
%           rawtdtpath = fullfile('H:','My Drive','NMRC_umn', 'Projects', 'DataStorageAnalysis','workingfolders','home','data_shared','raw','bug','expdata', 'setupchair','bug-190111', 'tdt','block-1');
%           nwb = convraw_tdt2nwb(rawtdtpath);
% 
% tdt.streams
%     EYEa: [1*1 struct]: x, y position of eye movements (2 * n_temporal)
%     EYEt: [1*1 struct]: sync time from eye tracking system (1 * n_temporal)
%     Para: [1*1 struct]: 
%     Stpd: [1*1 struct]: sync data from touch pad (1 * n_temporal)    
%     BUGG: [1*1 struct]: Neural data (n_chns * n_temporal)
% 
% inputs:
%       rawtdtpath: the folder containing all the tdt files
%       nwb: exist nwb structure (if missing, will create a new nwb structure)
%       newnwbtag: tag for creating new nwb (default, 1) or not (0)
%       exportnwbtag: tag for exporting nwb file (1) or not (default 0)
%
% outputs:
%       nwb: nwb structure containing tdt information (i.e. neural data, electrodes, etc)
% 
% Author: yll


if nargin < 3
    exportnwbtag = 1;
end
if nargin < 2
    newnwbtag = 0;
end

addpath(genpath(fullfile(fileparts(pwd), 'toolbox', 'matnwb'))) % add matnwb path ../toolbox/matnwb
addpath(genpath(fullfile(fileparts(pwd), 'util'))) % add util path ../util

% %load tdt file to matlab
if isunix || ispc % unix-like platform
    addpath(genpath(fullfile(fileparts(pwd), 'toolbox', 'TDTMatlabSDK'))) % add tdt sdk path ../toolbox/TDTMatlabSDK
    tdt = TDTbin2mat(rawtdtpath);
end
% if ispc % windows platform : not use now
%     addpath(genpath(fullfile(fileparts(pwd), 'util'))) % add util path ../util for tdt2matlab_activeX
%     tdt = tdt2matlab_activeX(rawtdtpath);
% end


animal = rawtdtpath(strfind(rawtdtpath, 'raw')+4: strfind(rawtdtpath, 'expdata')-2);
dateofexp = datenum(tdt.info.date); % tdt.info.date = '2019-Jan-11'
setup = char(regexp(rawtdtpath, 'setup[a-z]*', 'match'));
blockname = char(regexp(rawtdtpath, 'block-[0-9]*', 'match')); % blockname = 'block1-rest'
blocknum = str2num(blockname(6:strfind(blockname, '-')-1)); % blocknum = 1

if newnwbtag == 1
    % create new nwb structure
    identifier = [animal '_' datestr(dateofexp,'yymmdd') '_' setup '_block' num2str(blocknum)];
    session_description = ['NWB file test on ' animal ' performing ' setup ' on day ' datestr(dateofexp,'yymmdd')];
    nwb = nwbfile(...
        'identifier', identifier, ...
        'session_description', session_description, ...
        'file_create_date', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
end
session_start_time = datevec([tdt.info.date tdt.info.utcStartTime], 'yyyy-mmm-ddHH:MM:SS');
nwb.session_start_time = datestr(session_start_time, 'yyyy-mm-dd HH:MM:SS');

%% deal with tdt.streams
streams_keys = fieldnames(tdt.streams);

%  parse the tdt.streams.Neur structure
neural_key = 'BUGG';
if ~isempty(find(ismember(streams_keys, neural_key)))
    stream_neur = tdt.streams.(neural_key);
    tdtneur = parse_tdtneuro(stream_neur);
    nwb.acquisition.set('tdtneur', tdtneur);
end

%  parse the tdt.streams.Stpd structure
stpd_key = 'Stpd';
if ~isempty(find(ismember(streams_keys, stpd_key)))
    stream_stpd = tdt.streams.(stpd_key);
    tdtstpd = parse_tdtstpd(nwb, stream_stpd);
    nwb.acquisition.set('tdtstpd', tdtstpd);
end


if exportnwbtag == 1
    %% export
    outdest = fullfile(['test' '.nwb']);
    nwbExport(nwb, outdest);
end


function tdtneur = parse_tdtneuro(stream)
%       parse the tdt.streams.Neur structure of neural data and store the tdt
%       neural data and the corresponding electrode information into nwb
%       structure
%
% Example usage:
%       stream_neur = tdt.streams.Neur;
%       tdtneur = parsetdtneur(stream_neur);
%       nwb.acquisition.set('tdtneur', tdtneur);
%
% inputs:
%       stream: tdt.stream.Neur structure
%
% output:
%       tdtneur:    types.core.ElectricalSeries structure containing the tdt
%                   neural data and the corresponding electrode information

% deal with the electrode information
etrodes = stream.channels;
n_etrodes = length(etrodes);
etrode_labels = cell(1, n_etrodes);
etrode_labels(1, 1:96) = {'utah'};
etrode_labels(1, 97:end) = {'gray matter'};
devices_name = unique(etrode_labels, 'stable'); % 1x2 cell array: {'utah'}    {'gray matter'}
elecdt_colnames = {'xyz', 'imp', 'elec_loc', 'filtering','array_name'};
etrode_xyz = rand([n_etrodes,3]); % randomly generate the x, y, z coordinates for each electrode
imp = rand(n_etrodes,1);

% generate the array_name and array_index vectors, each channel is with an
% array type ('utah' or 'gray matter') or an index pointing to utah or gray
% matter device
array_name = repmat({''},n_etrodes,1);
array_index = repmat(types.untyped.ObjectView('null'), n_etrodes,1);
for i_device = 1: length(devices_name)
    device_name = devices_name{i_device}; % device_name: 'utah' or 'gray matter'
    nwb.general_devices.set( device_name, types.core.Device());
    group_name = device_name;
    nwb.general_extracellular_ephys.set(group_name, ...
        types.core.ElectrodeGroup( ...
        'description', ['array type is' device_name], ...
        'location', 'unknown', ...
        'device', types.untyped.SoftLink(['/general/devices/' device_name])));
    
    elec_nums = find(strcmp(etrode_labels, device_name));
    array_name(elec_nums) = {device_name};
    array_index(elec_nums) = types.untyped.ObjectView(['/general/extracellular_ephys/' group_name]);
end

sma_channels = [1:30];
mc_channels = [31:60];
pmd_channels = [61:100];
stn_channels = [110:112];
gpe_channels = [106:109];
gpi_channels = [101:105];
elec_loc = repmat({''},n_etrodes,1); %location of each electrode inside brain (e.g 'sma', 'gpi', 'stn')
elec_loc(sma_channels) = {'sma'};
elec_loc(mc_channels) = {'mc'};
elec_loc(pmd_channels) = {'pmd'};
elec_loc(stn_channels) = {'stn'};
elec_loc(gpi_channels) = {'gpi'};
elec_loc(gpe_channels) = {'gpe'};
filterstr = repmat({'1-1000Hz Butter'}, n_etrodes,1);
% generate the DynamicTable  for electrodes
elec_dyntable = types.core.DynamicTable(...
    'colnames', elecdt_colnames,...
    'description', 'electrodes',...
    'id', types.core.ElementIdentifiers('data', int64(1:n_etrodes )),...
    'xyz', types.core.VectorData('data', etrode_xyz,...
    'description', 'the x, y,z coordinate of the channel location'),...
    'imp', types.core.VectorData('data', imp,...
    'description','the impedance of the channel'),...
    'elec_loc', types.core.VectorData('data', elec_loc, ...
    'description', 'the location of channel within the subject e.g. brain region'),...
    'filtering', types.core.VectorData('data', filterstr,...
    'description', 'description of hardware filtering'),...
    'array_name', types.core.VectorData('data', array_name, ...
    'description', 'the name of the ElectrodeGroup (utah or gray matter) this electrode is a part of'));
nwb.general_extracellular_ephys_electrodes = elec_dyntable;

% tdt neural data
tablereg = types.core.DynamicTableRegion(...
    'description','point to /general/extracellular_ephys/electrodes',...
    'table',types.untyped.ObjectView('/general/extracellular_ephys/electrodes'));
tdtneur = types.core.ElectricalSeries(...
    'starting_time', stream.startTime, ...
    'starting_time_rate',stream.fs,...
    'data',stream.data,...
    'electrodes', tablereg);  % electrode is required, otherwise error when exporting



function tdtstpd = parse_tdtstpd(stream)
% parsetdtneur() parses the tdt.streams.Stpd structure of sync data 
%                from padding board and the corresponding electrode 
%                information into types.core.TimeSeries structure
%
% Example usage:
%       stream_stpd = tdt.streams.(stpd_key)
% %       stream_neur = tdt.streams.Neur;
%       tdtneur = parsetdtneur(stream_neur);
%       nwb.acquisition.set('tdtneur', tdtneur);
% inputs:
%       stream: stream structure (tdt.stream.Stpd)
%
% output:
%       tdtstpd: types.core.TimeSeries storing the sync data from padding
%                board and the corresponding electrode information


tdtstpd = types.core.TimeSeries(...
    'starting_time', stream.startTime, ...
    'starting_time_rate',stream.fs, ...
    'data', stream.data,...
    'data_unit', 'Volt');
