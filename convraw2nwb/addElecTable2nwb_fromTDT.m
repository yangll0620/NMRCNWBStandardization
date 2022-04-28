function nwb = addElecTable2nwb_fromTDT(nwb, tdt, varargin)
% added electrode table to nbw from tdt
%
% Input:
%       nwb: 
%       tdt: tdt stream name, e.g. 'DBSS', 'DBSG', 'UDLP', 'UMCX', 'UPMC' 
%
%       Name-Value: 
%           'neupatt' - neuro pattern used to extract related electrodes, defualt 'DBS[A-Z]|[UG][A-Z]{3}'

%
% Return:
%       nwb: nwb with added nwb.general_extracellular_ephys_electrodes


% parse params
p = inputParser;
addParameter(p, 'neupatt', 'DBS[A-Z]|[UG][A-Z]{3}', @isstr);
parse(p,varargin{:});
neupatt = p.Results.neupatt;


tdt_streams = fieldnames(tdt.streams);

% added all electrode (dynamicTable) to nwb.general_extracellular_ephys_electrodes
neurostream_names = regexp(tdt_streams, neupatt, 'match');
neurostream_names(cellfun(@(x) isempty(x), neurostream_names)) = [];
tbl4elecs = [];
for sni = 1 : length(neurostream_names)
    tdt_stream_name = neurostream_names{sni}{1};
    
    % added and extract intracelluar electrode table
    nelecs = size(tdt.streams.(tdt_stream_name).data, 1);
    [nwb, tbl] = extract_IntracellularElectrodeTable_FromTDT(nwb, tdt_stream_name, nelecs);
    tbl4elecs = [tbl4elecs; tbl];
    
    clear tdt_stream_name nelecs tbl
end
tbl4elecs.id = (int64(1:height(tbl4elecs)))';
nwb.general_extracellular_ephys_electrodes = util.table2nwb(tbl4elecs, 'all neural electrodes');


end