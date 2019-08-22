% this script demonstrates about how to convert data from tdt, ma systems into
% nwb structure. 
% 
% Please read through the codes, modify the corresponding variables and
% write codes for convert your data into nwb struture.
%

%% modify these required variables accordingly
drive = 'Y:\Animals2';

% tdtfolder: folder path storing tdt data, required for converting tdt data
tdtfolder = '\Bug\Recording\Raw\rawTDT\Bug-190111\Block-1';

% googlesheet_electrode: the online google sheet storing electrode information, 
% required for converting raw tdt data, 
% an electrode google sheet template can be seen in 
% https://docs.google.com/spreadsheets/d/1Acg2vV2C6Lb8zIFtP2Qf3E9ugQ0TjJMX2S_sv2J18zk/edit?usp=sharing
% the value between 'd/'  and '/edit' in your electrode spreadsheet's url
googlesheet_electrode = '1Acg2vV2C6Lb8zIFtP2Qf3E9ugQ0TjJMX2S_sv2J18zk';


% mafolder: folder path storing ma data, required for converting ma data
mafolder = '\Bug\Recording\Raw\rawMA\MA20190111';
% mablocknum: corresponding ma block number
mablocknum = 1;


% gaitmat fsxfile
fsxfilename = "\Bug\Recording\Raw\Habit Trail\Gaitmat\20181128\CPB01.fsx";
% gaitmat system: map file path containing .mp file
mapfilepath = "Y:\yll\NMRCNWB\gaitmatfiles";
% gaitmat equilibration file .equ
equilibrationfile = "Y:\yll\NMRCNWB\gaitmatfiles\CES-2016-12-09-7101QL-40PSI.equ";
% gaitmat calibration file .cal
calibrationfile = "Y:\yll\NMRCNWB\gaitmatfiles\Azula_calibrationfile_9.1_080918.cal";

%% convert raw tdt data into nwb structure
disp('It will take a while to convert tdt data to NWB structure......')
rawtdtpath = fullfile(drive, tdtfolder);
% tag for exproting nwb file (1) or not (0) 
exportnwbtag = 0; 
nwb = convraw_tdt2nwb(rawtdtpath, googlesheet_electrode, exportnwbtag);

%% convert raw ma data into nwb structure 
rawmapath = fullfile(drive, mafolder);
exportnwbtag = 0; % not export nwb file
nwb = convraw_ma2nwb(rawmapath, mablocknum, exportnwbtag, nwb);

%% convert raw gaitmat data into nwb structure 
fsxfile = fullfile(drive,fsxfilename);

% tag for exproting nwb file (1) or not (0) 
exportnwbtag = 0; 

nwb = convraw_gaitmat2nwb(fsxfile, mapfilepath, equilibrationfile, calibrationfile, exportnwbtag, nwb);

%% export nwb into test.nwb 
outdest = fullfile(['test.nwb']);
nwbExport(nwb, outdest);