function neurdata = readraw_tdtneurdata(nwb, chn_read, idx_read)
%  readraw_tdtneurdata read raw neural data. 
%
%    neurdata = readraw_tdtneurdata(nwb, chn_read, idx_read) return the 
%    readed neural data (matrix: nchns * ntemporal) 
% 
% 
% 
%  Example:
%           nwbfile = fullfile(fileparts(pwd), 'test.nwb');
%
%           addpath(genpath(fullfile(fileparts(pwd), 'toolbox', 'matnwb')))
%
%           nwb = nwbRead(nwbfile);
%
%           relec_tbl = read_electrodes(nwb);
% 
%  Input:
%           nwb         ----  NWB structure
%           chns_red    ----  start and end channel number to read, a vector with two values, [chn_str chn_end] (default=0, all channels)
%           idx_red     ----  start and end index number to read, a vector with two values, [idx_str idx_end] (default=0, from 1 to end)
% 
%  Output:
%           neurdata    ----- readed neural data (matrix: nchns * ntemporal)
% 

%% default function parameters
if nargin < 3
    idx_read = 0;
end
if nargin < 2
    chn_read = 0;
end

%% check idx_read/chn_read is a vector with 2 values or zero
if ~(isvector(idx_read) && length(idx_read) == 2 || idx_read == 0) 
    disp('idx_read should be zero or a vector with exactly 2 values representing the start and end reading index')
    neurdata = [];
    return;
end
if ~(isvector(chn_read) && length(chn_read) == 2 || chn_read == 0) % check chn_read is a vector with 2 values or zero
    disp('chn_read should be zero or a vector with exactly 2 values representing the start and end reading channel number')
    neurdata = [];
    return;
end

%%
elecserial_tdtneur = nwb.acquisition.get('tdtneur'); % elecserial_tdtneur:  ElectricalSeries type
data = elecserial_tdtneur.data;
if isa(data, 'types.untyped.DataStub')
    if isscalar(idx_read) && idx_read == 0
        idx_read = [1 Inf];
    end
    if isscalar(chn_read) && chn_read == 0
        chn_read = [1 Inf];
    end
    neurdata = data.load([chn_read(1) idx_read(1)], [chn_read(2) idx_read(2)]);
end