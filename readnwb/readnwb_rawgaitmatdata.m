function [data_gaitmat, timestamps_gaitmat] = readnwb_rawgaitmatdata(nwb)
%  readnwb_rawgaitmatdata read raw gaitmat data. 
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
%           data_gaitmat    -----  gaitmat data (matrix: nrows * ncolumns * nframes)
%
%           timestamps_gaitmat  ---- ----- time stamps of gait mat data (vector: 1 * nframes)
% 

% read the time serial gaitmat in nwb.acquisition
timeserial_gaitmat = nwb.acquisition.get('gaitmat');

% gaitmat data
data_gaitmat = timeserial_gaitmat.data;

% time stamps
timestamps_gaitmat = timeserial_gaitmat.timestamps;