function example_gentestnwb()
% example_gentestnwb demonstrates how to generate the example test.nwb file
% test.nwb can also be downloaded from https://drive.google.com/open?id=1rqT5kkedZTvqGoWwNhGrS4Wly_1OQxPZ

addpath(fullfile('..','convraw2nwb'))

%% convert raw tdt to nwb 
rawtdtpath = 'F:\yang7003@umn\NMRC_umn\Projects\NWBStandardization\workingfolders\home\data_shared\raw\bug\expdata\setupchair\bug-190111\tdt\block-1';
googledocid_electable = '1s7MvnI3C4WzyW2dxexYaShCHL_z-AzEHE-N3uXaSMJU';
exportnwbtag = 0; % change to 1 if need exportnwb 
nwb = convraw_tdt2nwb(rawtdtpath, googledocid_electable, exportnwbtag);

%% convert raw ma to nwb
rawmapath = 'F:\yang7003@umn\NMRC_umn\Projects\NWBStandardization\workingfolders\home\data_shared\raw\bug\expdata\setupchair\bug-190111\ma';
blocknum = 1;
exportnwbtag = 0; % change to 1 if need exportnwb 
nwb = convraw_ma2nwb(rawmapath, blocknum, exportnwbtag, nwb);


%% export 
savefile = 'test.nwb';
nwbExport(nwb, savefile);
end