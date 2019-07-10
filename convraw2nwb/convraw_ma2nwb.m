function nwb = convraw_ma2nwb(rawmapath, blocknum, exportnwbtag, nwb)
%  convraw_ma2nwb convert raw ma data in rawmapath to NWB.acquisition
%
%    nwb = convraw_ma2nwb(rawmapath, blocknum, nwb, exportnwbtag) return nwb 
%    structure containing ma information in both .anc and .trc files 
% 
% 
% Example usage:
%           rawmapath = 'workingfolders\\home\\data_shared\\raw\\bug\\expdata\\setupchair\\bug-190111\\ma';
%
%           blocknum = 1;
%
%           nwb = convraw_ma2nwb(rawmapath, blocknum);
% 
% Inputs:
%       rawmapath       ---- the folder containing all the tdt files
%
%       blocknum        ---- the block number (default 1)
%
%       exportnwbtag    ---- tag for exporting nwb file (1) or not (default 0)
%       
%       nwb             ---- exist nwb structure (if missing, will create a new nwb structure)
%
% Outputs
%       nwb             ---- nwb structure containing ma .anc and .trc information 

if nargin < 4
    newnwbtag = 1;
else
    newnwbtag = 0;
end

if nargin < 3
    exportnwbtag = 0;
end

addpath(genpath(fullfile('..', 'toolbox', 'matnwb'))) % add matnwb path ../toolbox/matnwb

%% extract animal, dateofexp, setup et.al information
animal = rawmapath(strfind(rawmapath, 'raw')+4: strfind(rawmapath, 'expdata')-2);
datefoldername = char(regexp(rawmapath, [animal '-[0-9]*'], 'match'));
dateofexp = datenum(datefoldername(length(animal)+2:end),'yymmdd');
setup = char(regexp(rawmapath, 'setup[a-z]*', 'match'));

if newnwbtag == 1
    % create new nwb structure
    identifier = [animal '_' datestr(dateofexp,'yymmdd') '_' setup '_block' num2str(blocknum)];
    session_description = ['NWB file test on ' animal ' performing ' setup ' on day ' datestr(dateofexp,'yymmdd')];
    nwb = nwbfile(...
        'identifier', identifier, ...
        'session_description', session_description);
else
    if isa(nwb.file_create_date,'types.untyped.DataStub') % nwb.file_create_date is not a datetime format
        file_create_date = nwb.file_create_date.load();
        nwb.file_create_date = file_create_date;
    end
end

%% parse ma .trc file
filename_matrc = [[upper(animal(1)) animal(2:end)] '_' datestr(dateofexp, 'yyyymmdd') '_' num2str(blocknum) '_cleaned.trc']; % filename_matrc = 'Bug_20190111_1_cleaned.trc'
file_matrc = fullfile(rawmapath,filename_matrc);

ma_trc = parse_matrcfile(file_matrc);
nwb.acquisition.set('ma_marker', ma_trc);

%% parse ma .anc file
filename_maanc = [[upper(animal(1)) animal(2:end)] '_' datestr(dateofexp, 'yyyymmdd') '_' num2str(blocknum) '.anc']; % filename_maanc = 'Bug_20190111_1.anc'
file_maanc = fullfile(rawmapath,filename_maanc);
ma_anc = parse_maancfile(file_maanc);
nwb.acquisition.set('ma_sync', ma_anc);

%% export
if exportnwbtag == 1
    outdest = fullfile(['test_convrawma' '.nwb']);
    % fill the requied field of nwb for exporting
    if isempty(nwb.session_start_time) % nwb.session_start_time
        nwb.session_start_time = '';
    end
    nwbExport(nwb, outdest);
end

function ma_trc = parse_matrcfile(file_matrc)
% parse_matrcfile() parses the ma .trc tracking file into a types.core.TimeSeries structure
%
% Example usage:
%       file_matrc = fullfile('H:','My Drive','NMRC_umn', 'Projects', 'DataStorageAnalysis','workingfolders','home','data_shared','raw','bug','expdata', 'setupchair','bug-190111', 'ma','Bug_20190111_1_cleaned.trc');
%
%       ma_trc = parse_matrcfile(file_matrc);
%
% Input:
%       file_matrc: the full path of ma .trc file
%
%
% Output: 
%       ma_trc: a types.core.TimeSeries structure storing the joint tracking data
%               of ma system

%read the numerical data in the ma .trc file 
numlinestart = 7; 
dataimport = importdata(file_matrc,'\t',numlinestart-1);% reading numeric data starting from line numlinestart 

% dataimport.data (ntimes * ncolumns): 
%   first column (frame #), second column (time stamps)
%   third -end columns (x,y,z positions for all joints)
time = dataimport.data(:,2);
data = dataimport.data(:,3:end);

% deal with the head information in the ma .trc file
fid = fopen(file_matrc);
headlinenumstart = 1; 
C = textscan(fid,'%s',numlinestart-1,'delimiter','\n', 'headerlines',headlinenumstart-1); % read headlinenumstart_matrc-1 lines from the linenum 
str2 = split(C{1}{2}); % 2nd line: text description of some basic recording properties(i.e 'DataRate	CameraRate	NumFrames	NumMarkers	Units	OrigDataRate	OrigDataStartFrame	OrigNumFrames')
str3 = split(C{1}{3}); % 3rd line: value of the  properties (i.e '100.00	100.00	     33493	3	mm	100.00	1	     33493')
str4 = split(C{1}{4});
% parse the sampling rate 
idx_sr = find(strcmp(str2, 'DataRate'));
sr = str2double(str3{idx_sr});
% parse the data unit
idx_unit = find(strcmp(str2, 'Units'));
unit = str3{idx_unit};
fclose(fid);

ma_trc = types.core.TimeSeries(... % tracking data
    'starting_time', time(1), ...
    'starting_time_rate', sr,...
    'timestamps',time,...
    'data',data,...
    'data_unit', unit);  


function ma_anc = parse_maancfile(file_maanc)
%% parse_maancfile() parses the ma .anc analog data file into a types.core.TimeSeries structure
%
% Example usage:
%       file_maanc = fullfile('H:','My Drive','NMRC_umn', 'Projects', 'DataStorageAnalysis','workingfolders','home','data_shared','raw','bug','expdata', 'setupchair','bug-190111', 'ma','Bug_20190111_1.anc');
%       ma_trc = parse_matrcfile(file_matrc);
%
% input:
%       file_maanc: the full path of ma .trc file
%
%
% output: 
%       ma_anc: a types.core.TimeSeries structure storing the input analog
%               data of ma system

%read the numerical data in the ma .anc file 
numlinestart = 12; % read from line numlinestrart
dataimport = importdata(file_maanc,'\t',numlinestart -1);% reading numeric data starting from line numlinestart

% dataimport.data (ntimes * ncolumns): 
%   first column (time stamps)
%   second -end columns (analog data of input channel)
time = dataimport.data(:,1);
data = dataimport.data(:,2:end);

% deal with the head information in the ma .anc file
fid = fopen(file_maanc);
headlinenumstart = 1; % read from the linenum 
C = textscan(fid,'%s',numlinestart-1,'delimiter','\n', 'headerlines',headlinenumstart-1); % read numlinestrart-1 lines from the linenum 
str4 = split(C{1}{4});
% parse the sampling rate for analog input data
idx_sr = find(contains(str4, 'PreciseRate'));
sr = str2double(str4{idx_sr+1});
fclose(fid);

ma_anc = types.core.TimeSeries(... % analog data
    'starting_time', time(1), ...
    'starting_time_rate', sr,...
    'timestamps',time,...
    'data',data,...
    'data_unit', 'uV?');