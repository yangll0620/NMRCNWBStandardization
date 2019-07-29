function example_convraw()
% example_convraw() demonstrates about how to convert data from tdt, ma systems into
% nwb structure
% 

% dateset parameters, modify these according to your dataset
animal = 'bug';
setup = 'setupchair'; % 'setupchair' or 'setupgait'
dateofexp = datetime(2019,1,11);% 2019-Jan-11
blocknum = 1;
onedaypath = fullfile('H:','My Drive','NMRC_umn', 'Projects',...
'DataStorageAnalysis','workingfolders',...
'home', 'data_shared', 'raw',animal, ...
    'expdata',setup ,[animal '-' datestr(dateofexp, 'yymmdd')]);
googledocid_electable = '1Acg2vV2C6Lb8zIFtP2Qf3E9ugQ0TjJMX2S_sv2J18zk';% the value between 'd/'  and '/edit' in your electrode spreadsheet's url


% convert raw tdt data into nwb structure
rawtdtpath = fullfile(onedaypath, 'tdt',['block-' num2str(blocknum)]);
exportnwbtag = 0; % not exprot nwb file
nwb = convraw_tdt2nwb(rawtdtpath, googledocid_electable, exportnwbtag);


% convert raw ma data into nwb structure
rawmapath = fullfile(onedaypath, 'ma');
exportnwbtag = 0; % not export nwb file
nwb = convraw_ma2nwb(rawmapath, blocknum, exportnwbtag, nwb);

%% export
outdest = fullfile(['test.nwb']);
nwbExport(nwb, outdest);