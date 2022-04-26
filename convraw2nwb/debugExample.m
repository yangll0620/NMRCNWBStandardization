addpath(genpath(fullfile('C:\Users\lingling\Desktop\NMRCNWBStandardization', 'toolbox')))

rawtdtpath = fullfile('H:', 'My Drive', 'NMRC_umn', 'Projects', 'NWBStandardization', 'example_dataset', 'testData', ...
    'Barb', 'Recording','Raw', 'rawTDT', 'Barb-220324', 'Block-2');

animal = 'Barb';

blockpath = rawtdtpath;
tdt = TDTbin2mat(blockpath);

% extract dateofexp and bktdt
dateofexp = datenum(tdt.info.date, 'yyyy-mmm-dd'); 
bktdt = str2double(tdt.info.blockname(length('block-')+1:end)); 

%% Create new file

identifier = [animal '_' datestr(dateofexp,'yymmdd') '_block' num2str(bktdt)];
session_description = [animal '-' datestr(dateofexp,'yymmdd') ', block' num2str(bktdt)];
session_start_time = datevec([tdt.info.date tdt.info.utcStartTime]);
nwb = NwbFile(...
    'identifier', identifier, ...
        'session_description', session_description, ...
        'session_start_time', datestr(session_start_time, 'yyyy-mm-dd HH:MM:SS'));

%% Electrode Table


% stop here 04/25/2022 11pm
% next step: added all tdt_stream_name into
%               nwb.general_extracellular_ephys_electrodes by combing all tbl4elecs of tdt_stream_name
% using this function [nwb, tbl4elecs] = extract_IntracellularElectrodeTable_FromTDT(nwb, tdt_stream_name, nelectrodes);

