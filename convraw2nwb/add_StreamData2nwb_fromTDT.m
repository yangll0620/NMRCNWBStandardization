function nwb = add_StreamData2nwb_fromTDT(nwb, tdt, varargin)
% added tdt stream data from tdt 
%
%   Usage:
%       nwb = add_StreamData2nwb_fromTDT(nwb, tdt, 'stream_names', [{'DBSS'};{'DBSG'}], 'suffix_name', 'DBS')
%
%   Inputs:
%       nwb: input nwb 
%
%       tdt: tdt structure
%
%       Name-Value: 
%
%           stream_names (cell array): the stream names of which to be added, e.g. {'DBSS'}; {'DBSG'};{'UDLP'}, default [] represent stream data in tdt
%       
%           'suffix_name': the suffix name used for name the electrical series,
%                          electrical series name has the format as ['raw_' suffix_name], default ''


% parse params
p = inputParser;
addParameter(p, 'stream_names', []);
addParameter(p, 'suffix_name', '', @isstr);
parse(p,varargin{:});
stream_names = p.Results.stream_names;
suffix_name = p.Results.suffix_name;

if isempty(stream_names)
    return;
end

mask = cellfun(@(x) any(strcmp(fieldnames(tdt.streams), x)), stream_names);
if ~all(mask) % stream_names contains name not in fieldnames(tdt.streams)
    disp([stream_names{~mask} ' not include in fieldnames(tdt.streams)'])
    return;
end


elec_table = nwb.general_extracellular_ephys_electrodes;
if isempty(elec_table)
    disp('nwb.general_extracellular_ephys_electrodes empty.')
    return
end

elec_table_labels = elec_table.vectordata.get('label').data; % {'DBSS-elect1'}    {'DBSS-elect2'} ...
data_all = [];
electbl_region_rows = [];
starting_time = [];
ntemp = [];
fs = [];
for sni = 1 : length(stream_names)
    stream_name = stream_names{sni};
    
    % extract and combine the rows from the electrode table (nwb.general_extracellular_ephys_electrodes)
    rows = find(cellfun(@(x) contains(x, [stream_name '-']), elec_table_labels));
    electbl_region_rows = [electbl_region_rows; rows'];
    
    
    % checking startTime, fs, ntemp
    if isempty(ntemp)
        ntemp = size(tdt.streams.(stream_name).data, 2);
    elseif ntemp ~= size(tdt.streams.(stream_name).data, 2)
        disp(['Temporal length not consistent for : '])
        disp(stream_names)
        return;
    end
    if isempty(starting_time)
        starting_time = tdt.streams.(stream_name).startTime;
    elseif starting_time ~= tdt.streams.(stream_name).startTime
        disp(['StartTime length not consistent for : '])
        disp(stream_names)
        return;
    end
    if isempty(fs)
        fs = tdt.streams.(stream_name).fs;
    elseif fs ~= tdt.streams.(stream_name).fs
        disp(['fs length not consistent for : '])
        disp(stream_names)
        return;
    end
    
    
    % combine data
    data = tdt.streams.(stream_name).data;
    data_all = cat(1, data_all, data);
    
    clear stream_name 
    clear rows data
end

% electrode_table_region
electrode_table_region = types.hdmf_common.DynamicTableRegion( ...
    'table', types.untyped.ObjectView(elec_table), ...
    'description', [suffix_name ' electrode table reference'], ...
    'data', electbl_region_rows);


electrical_series = types.core.ElectricalSeries( ...
    'starting_time', starting_time, ... % seconds
    'starting_time_rate', fs, ... % Hz
    'data', data_all, ...
    'electrodes', electrode_table_region, ...
    'data_unit', 'volts');

% set
nwb.acquisition.set(['raw-' strrep(suffix_name, ' ', '')], electrical_series);