function [nwb, tbl4elecs] = extract_IntracellularElectrodeTable_FromTDT(nwb, tdt_stream_name, nelectrodes)
% extract intracelluar electrode table from tdt stream name
%
% Input:
%       nwb: 
%       tdt_stream_name: tdt stream name, e.g. 'DBSS', 'DBSG', 'UDLP', 'UMCX', 'UPMC' 
%       nelectrodes: number of electrodes
%
% Return:
%       nwb: nwb with added devices in nwb.general_devices and electrode_group in nwb.general_extracellular_ephys
%       tbl4elecs: a table describing electrodes, can convert to DynamicTable using util.table2nwb(tbl4elecs, 'electrodes');



% generate a new device
[devName, dev] = deviceName_extract(tdt_stream_name, 'from', 'fromtdt');
if ~any(strcmpi(nwb.general_devices.keys(), devName))
    nwb.general_devices.set(devName, dev);
end
    
    
% generate and add electrodegroup
loc = [];
if strcmpi(tdt_stream_name(1), 'U')
    loc = tdt_stream_name(2:end);
elseif strcmpi(tdt_stream_name(1:3), 'DBS')
    if strcmpi(tdt_stream_name(4), 'S')
        loc = 'STN';
    end
    if strcmpi(tdt_stream_name(4), 'G')
        loc = 'GP';
    end
end
eg = types.core.ElectrodeGroup(...
    'location', loc, ...
    'device', types.untyped.SoftLink(['/general/devices/' devName]));
nwb.general_extracellular_ephys.set(['electrode_group_' tdt_stream_name], eg);


% generate tbl4elecTable
ov = types.untyped.ObjectView(['/general/extracellular_ephys/elect_group_' tdt_stream_name]);

variables = {'id', 'x', 'y', 'z', 'imp', 'brainarea', 'group', 'group_name'};
tbl4elecs = table(int64(1), NaN, NaN, NaN, NaN, {loc}, ov, {['elect_group_' tdt_stream_name]}, 'VariableNames', variables);
for ei = 2 : nelectrodes
    tbl4elecs = [tbl4elecs; {int64(ei), NaN, NaN, NaN, NaN, {loc}, ov, {['elect_group_' tdt_stream_name]}}];
end

