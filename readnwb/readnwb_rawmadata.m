function [data_ma, timestamps_ma] = readnwb_rawmadata(nwb)
%  readnwb_rawgaitmatdata read raw ma data. 
%
%    gaitmatdata = readnwb_rawtdtneurdata(nwb) return the 
%    readed neural data (matrix: nchns * ntemporal)
% 
% 
%  Example:
%
%           gaitmatdata = readnwb_rawgaitmatdata(nwb);
% 
%  Input:
%           nwb         ----  NWB structure
%
%  Output:
%           data_ma    -----  ma data (matrix: nframes * (nmarkers * 3))
%
%           timestamps_ma  ---- ----- time stamps of ma data (matrix: nframes * 1)
% 

% read the time serial timeserial_ma in nwb.acquisition
timeserial_ma = nwb.acquisition.get('ma_marker_cleaned');

% ma data
data_ma = timeserial_ma.data;

% time stamps
timestamps_ma = timeserial_ma.timestamps;