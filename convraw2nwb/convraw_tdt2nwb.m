function nwb = convraw_tdt2nwb(rawtdtpath, googlesheet_electrode, varargin)
% convraw_tdt2nwb converts raw TDT data to NWB.acquisition
%
%   nwb = convraw_tdt2nwb(rawmapath, googledocid_electable, nwb, exportnwbtag) return nwb 
%   structure containing tdt information (i.e. neural data, 
%   electrodes, touchpad sync data,etc).  
%
%   Electrode information are extracted from a spreadsheet.
%   Example of electrode spreadsheet can be seen here 
%   ('https://drive.google.com/open?id=1rqT5kkedZTvqGoWwNhGrS4Wly_1OQxPZ').
% 
% Example usage:
%           rawtdtpath = 'H:\My Drive\NMRC_umn\Projects\NWBStandardization\example_dataset\testData\Recording\Raw\rawTDT\Barb-220303\Block-1';
%
%           googlesheet_electrode = '1s7MvnI3C4WzyW2dxexYaShCHL_z-AzEHE-N3uXaSMJU'
%
%           nwb = convraw_tdt2nwb(rawtdtpath, googledocid_electable, 'export2nwbfile', 'true');
% 
% 
% Inputs
%       rawtdtpath              ---- the folder containing all the tdt files
%
%       googlesheet_electrode   ---- the online google sheet storing electrode information, the value between 'd/'  and '/edit' in your electrode spreadsheet's url
%
%   Name-Value: 
%       export2nwbfile          ---- tag for exporting nwb file (true) to test.nwb or not (false), default false
%
%       nwb                     ---- exist nwb structure (if missing, will create a new nwb structure)
%
% Output:
%       nwb                     ---- nwb structure containing tdt information (i.e. neural data, electrodes, etc)




p = inputParser;
addParameter(p, 'export2nwbfile', false, @(x)isscalar(x)&&islogical(x));
parse(p,varargin{:});
export2nwbfile = p.Results.export2nwbfile;



if nargin < 4
    newnwbtag = 1;
else
    newnwbtag = 0;
end


% parse animal and tdt block number infomation
[animal, tdtblocknum] = parsetdtpath(rawtdtpath);
if isempty(animal) || isempty(tdtblocknum)
    disp(['animal or tdtblocknum is not parsed!']);
    return;
end

% load tdt file to matlab
if isunix || ispc 
    addpath(genpath(fullfile(fileparts(pwd), 'toolbox', 'TDTMatlabSDK'))) % add tdt sdk path ../toolbox/TDTMatlabSDK
    tdt = TDTbin2mat(rawtdtpath);
end

% tdt.info.date = '2019-Jan-11'
dateofexp = datenum(tdt.info.date, 'yyyy-mmm-dd'); 

if newnwbtag == 1
    % create new nwb structure
    identifier = [animal '_' datestr(dateofexp,'yymmdd') '_block' num2str(tdtblocknum)];
    session_description = ['NWB file on ' animal ' performing on day ' datestr(dateofexp,'yymmdd')];
    nwb = nwbfile(...
        'identifier', identifier, ...
        'session_description', session_description);
else
    if isa(nwb.file_create_date,'types.untyped.DataStub') % nwb.file_create_date is not a datetime format
        file_create_date = nwb.file_create_date.load();
        nwb.file_create_date = file_create_date;
    end
end
session_start_time = datevec([tdt.info.date tdt.info.utcStartTime], 'yyyy-mmm-ddHH:MM:SS');
nwb.session_start_time = datestr(session_start_time, 'yyyy-mm-dd HH:MM:SS');

%% deal with tdt.streams
streams_keys = fieldnames(tdt.streams);

%  parse the tdt.streams.Neur structure
neural_key = 'BUGG'
if ~isempty(find(ismember(streams_keys, neural_key)))
    stream_neur = tdt.streams.(neural_key);
    nwb = parse_tdtelect(nwb, googlesheet_electrode);
    tdtneur = parse_tdtneur(stream_neur);
    nwb.acquisition.set('tdt_neur', tdtneur);
end

%  parse the tdt.streams.Stpd structure
stpd_key = 'Stpd';
if ~isempty(find(ismember(streams_keys, stpd_key)))
    stream_stpd = tdt.streams.(stpd_key);
    tdtstpd = parse_tdtstpd(stream_stpd);
    nwb.acquisition.set('tdt_stpd', tdtstpd);
end


if export2nwbfile
    %% export
    outdest = fullfile(['test_convrawtdt' '.nwb']);
    nwbExport(nwb, outdest);
end
end

function nwb = parse_tdtelect(nwb, googlesheet_electrode)
% parse_tdtelect parses the tdt electrode information from google sheet
%
%   tdtneur = parse_tdtneur(stream) return types.core.ElectricalSeries structure
%   of the parsed tdt neural data 
%
% Example usage:
%       googlesheet_electrode = '1s7MvnI3C4WzyW2dxexYaShCHL_z-AzEHE-N3uXaSMJU';
%       nwb = parse_tdtelect(stream, googledocid_electable);
%
% Input:
%       nwb: exist nwb structure
%       googlesheet_electrode: the value between 'd/'  and '/edit' in your spreadsheet's url
%
% Output:
%       nwb:    nwb structure containing tdt electrodes information
%

% read data from google sheet
elec_tbl = webread(['https://docs.google.com/spreadsheet/ccc?key=' googlesheet_electrode '&output=csv&pref=2']);

% deal with the electrode information
n_etrodes = height(elec_tbl);
etrode_labels = elec_tbl.array_name;
elegroups_name = unique(etrode_labels, 'stable'); % 1xn cell array: {'utah'}    {'gray matter'} {'DBS lead'}

% generate the array_name and array_index vectors, each channel is with an
% array type ('utah' or 'gray matter') or an index pointing to utah or gray
% matter device
device_name = 'tdt';
nwb.general_devices.set( device_name, types.core.Device());
% elecgroup_ref = repmat(types.untyped.ObjectView('null'), n_etrodes,1);
for i_elecgroup = 1: length(elegroups_name)
    group_name = elegroups_name{i_elecgroup}; % 
    nwb.general_extracellular_ephys.set(group_name, ...
        types.core.ElectrodeGroup( ...
        'description', ['array type is' group_name], ...
        'location', 'unknown', ...
        'device', types.untyped.SoftLink(['/general/devices/' device_name])));
    
    
%     % elecgroup_ref, not quite sure for what
%     elec_nums = find(strcmp(etrode_labels, group_name));
%     elecgroup_ref(elec_nums) = types.untyped.ObjectView(['/general/extracellular_ephys/' group_name]);
end
% elec_tbl = [elec_tbl table(elecgroup_ref)];
elec_tbl.Properties.Description = 'electrode information';
elec_dyntable = util.table2nwb(elec_tbl);
nwb.general_extracellular_ephys_electrodes = elec_dyntable;
end

function tdtneur = parse_tdtneur(stream)
% parse_tdtneuro parses the tdt.streams.Neur structure
%
%   tdtneur = parse_tdtneur(stream) return types.core.ElectricalSeries structure
%   of the parsed tdt neural data 
%
% Example usage:
%       stream = tdt.streams.Neur;
%       tdtneur = parse_tdtneur(stream);
%       nwb.acquisition.set('tdtneur', tdtneur);
%
% Input:
%       stream: tdt.stream.Neur structure
%
% Output:
%       tdtneur:    types.core.ElectricalSeries structure containing the tdt
%                   neural data and the corresponding electrode information

% electrode table information
tablereg = types.core.DynamicTableRegion(...
    'description','point to /general/extracellular_ephys/electrodes',...
    'table',types.untyped.ObjectView('/general/extracellular_ephys/electrodes'));
tdtneur = types.core.ElectricalSeries(...
    'starting_time', stream.startTime, ...
    'starting_time_rate',stream.fs,...
    'data',stream.data,...
    'electrodes', tablereg);  % electrode is required, otherwise error when exporting
end


function tdtstpd = parse_tdtstpd(stream)
% parse_tdtstpd parses the tdt.streams.Stpd tdt sync structure
%   tdtstpd = parse_tdtstpd(stream) return types.core.TimeSeries structure
%   of the parsed tdt touch pad sync information 
%
% Example usage:
%       stream = tdt.streams.Stpd;
%       tdtstpd = tdt.streams.(stream)
%       nwb.acquisition.set('tdtstpd', tdtstpd);
%
% Input:
%       stream: stream structure (tdt.stream.Stpd)
%
% Output:
%       tdtstpd: types.core.TimeSeries storing the sync data from padding
%                board and the corresponding electrode information


tdtstpd = types.core.TimeSeries(...
    'starting_time', stream.startTime, ...
    'starting_time_rate',stream.fs, ...
    'data', stream.data,...
    'data_unit', 'Volt');
end