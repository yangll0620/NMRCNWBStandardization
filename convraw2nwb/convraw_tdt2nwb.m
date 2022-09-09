function nwb = convraw_tdt2nwb(tdt, varargin)
% converts raw TDT data to nwb.acquisition
% 
% Example usage:
%       
%       nwb = convraw_tdt2nwb(tdt, 'nwb_in', nwb, 'animal', 'Barb')
%       
%       nwb = convraw_tdt2nwb(tdt)
% 
% Inputs:
%   
%   tdt: tdt data extracted using TDTbin2mat(rawtdtpath), required
%   
%   Name-Value (optional parameters): 
%
%       'nwb_in': input an exist nwb, default [] create a new nwb       
%
%       'animal': the animal data for this tdt, default 'Barb', don't need if nwb_in exist
%
% Output:
%       nwb       ---- nwb structure containing tdt information 


if ~(isunix || ispc)
    disp('Using neither windows or unix OS.');
    return;
end

% parse params
p = inputParser;
addParameter(p, 'nwb_in', [], @(x) isa(x, 'NwbFile'));
addParameter(p, 'animal', 'Barb', @isstr);
parse(p,varargin{:});
nwb = p.Results.nwb_in;


% Create new file if not exist
if isempty(nwb)
    animal = p.Results.animal;
    animal(1) = upper(animal(1));
    
    % extract dateofexp and bktdt
    dateofexp = datenum(tdt.info.date, 'yyyy-mmm-dd');
    bktdt = str2double(tdt.info.blockname(length('block-')+1:end));
    
    identifier = [animal '_' datestr(dateofexp,'yymmdd') '_block' num2str(bktdt)];
    session_description = [animal '-' datestr(dateofexp,'yymmdd') ', block' num2str(bktdt)];
    session_start_time = datevec([tdt.info.date ' ' tdt.info.utcStartTime], 'yyyy-mmm-dd HH:MM:SS');
    
    nwb = NwbFile(...
        'identifier', identifier, ...
        'session_description', session_description, ...
        'session_start_time', datestr(session_start_time, 'yyyy-mm-dd HH:MM:SS'));
    
    clear animal dateofexp  bktdt
    clear identifier session_description session_start_time
end


%%% --- added all neural electrode (dynamicTable) to nwb.general_extracellular_ephys_electrodes --- %%%
neupatt = 'DBS[A-Z]|[UG][A-Z]{3}';
nwb = addElecTable2nwb_fromTDT(nwb, tdt, 'neupatt', neupatt);


%%% --- store tdt stream data --- %%%
patt_names = [{'DBS[A-Z]'}, {'DBS'};...
               {'U[A-Z]{3}'}, {'Utah Array'};...
               {'G[A-Z]{3}'}, {'Gray Matter'};]; 


% extract and electrical_series
for pni = 1 : size(patt_names, 1)
    patt = patt_names{pni, 1};
    surname = patt_names{pni, 2};
    
    stream_names = regexp(fieldnames(tdt.streams), patt, 'match');
    stream_names(cellfun(@(x) isempty(x), stream_names)) = [];
    for sti = 1 : length(stream_names)
        stream_names{sti} = stream_names{sti}{1};
    end
    
    nwb = add_StreamData2nwb_fromTDT(nwb, tdt, 'stream_names', stream_names, 'suffix_name', surname);
    
    clear patt surname stream_names
end

