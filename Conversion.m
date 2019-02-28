addpath('matnwb')
% script configuration
animal = 'Bug';
session = '20181130';

identifier = [animal '_' session];
rawdata_loc = fullfile('K', 'NWBtest\dataset', animal, 'Recording', 'Raw');

outloc = '..\out';
if 7 ~= exist(outloc, 'dir')
    mkdir(outloc)
end

%% general information
nwb = nwbfile();