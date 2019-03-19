function datasetpath = getdatasetpath()
%% add path of toolboxes
addpath('..\util')
dbpath = dropboxpath();
% matnwb path
addpath(fullfile(dbpath,'toolbox', 'matnwb'))
% TDT Matlab SDK path
addpath(genpath(fullfile(dbpath,'toolbox', 'TDTMatlabSDK')))

%% TDT2mat
% combine *.sev files in Streamer and *.tbk files in Local
projectpath = fullfile(dbpath, 'NMRC', 'Projects', ...
    'DataStorageAnalysisArchitecture', 'NWBtest');
datasetpath = fullfile(projectpath, 'dataset');