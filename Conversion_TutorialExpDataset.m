clear
%% matnwb path
if ispc % PC (Windows) in LRB 411
    dropboxpath = 'E:'; 
end
if ismac % mac notebook
    dropboxpath = '/Users/linglingyang';
end
projectpath = fullfile(dropboxpath, 'Dropbox', 'NMRC', 'Projects', ...
    'DataStorageAnalysisArchitecture', 'NWBtest');
matnwbpath = fullfile(projectpath, 'matnwb');
datasetpath = fullfile(projectpath, 'dataset', 'TutorialExpData'); %.....\NWBtest\dataset\TutorialExpData\

%% Script start here
addpath(matnwbpath)
%% script configuration
animal = 'ANM255200';
session = '20140910';

identifier = [animal '_' session];

metadata_loc = fullfile(datasetpath, 'metadata', ['meta_data_' identifier '.mat']);
datastructure_loc = fullfile(datasetpath,'data_structure_files',...
    ['data_structure_' identifier '.mat']);
rawdata_loc = fullfile(datasetpath, 'rawdata');

outloc = fullfile(datasetpath, 'out');

%%
nwb = nwbfile();

%% raw data
if 7 ~= exist(outloc, 'dir')
    mkdir(outloc);
end

rawfiles = dir(fullfile(rawdata_loc, identifier));
