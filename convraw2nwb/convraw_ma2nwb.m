function nwb = convraw_ma2nwb(rawmapath, blocknum, nwb, exportnwbtag)
% 
% 
% %% input parameters
% blocknum = 1; % blocknum: block number (default 1)
% exportnwbtag =  1; %tag for creating new nwb (default, 1) or not (0)
% newnwbtag = 1;       % tag for creating new nwb (default, 1) or not (0)
%       exportnwbtag: tag for exporting nwb file (1) or not (default 0)
%
%
% % example code
% if ispc % windows
%     driver_path = fullfile('H:', 'My Drive')
% end
% if ismac % mac
%     driver_path = fullfile('/Volumes','GoogleDrive','My Drive');
% end
% if isunix && ~ismac
%     driver_path = fullfile('/home','lingling','yang7003@umn.edu');
% end
% rawmapath = fullfile(driver_path,'NMRC_umn', 'Projects', 'DataStorageAnalysis','workingfolders','home','data_shared','raw','bug','expdata', 'setupchair','bug-190111', 'ma');


%% function start here

if nargin < 4
    exportnwbtag = 1;
end
if nargin < 3
    newnwbtag = 1;
end
if nargin < 2
    blocknum = 1;
end

addpath(genpath(fullfile(fileparts(pwd), 'toolbox', 'matnwb'))) % add matnwb path ../toolbox/matnwb

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
        'session_description', session_description, ...
        'file_create_date', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
end

%%
filename_matrc = [[upper(animal(1)) animal(2:end)] '_' datestr(dateofexp, 'yyyymmdd') '_' num2str(blocknum) '_cleaned.trc']; % filename_matrc = 'Bug_20190111_1_cleaned.trc'
filename = fullfile(rawmapath,filename_matrc);

% %%%% read the ma file numerical data
nheadline = 6; 
dataimport = importdata(filename,'\t',nheadline);% reading numeric data starting from line nheadline+1 

% dataimport.data (ntimes * ncolumns): 
%   first column (frame #), second column (time stamps)
%   third -end columns (x,y,z positions for each joints)
time = dataimport.data(:,2);
ma_xyz = dataimport.data(:,3:end);

% %% deal with the text information in the ma file
fid = fopen(filename);
% the 2nd line
linenum = 1; 
C = textscan(fid,'%s',5,'delimiter','\n', 'headerlines',linenum-1); % read 5 lines from the linenum-1 
str2 = split(C{1}{2});
str3 = split(C{1}{3});
str4 = split(C{1}{4});
% parse the sampling rate, unit
idx_sr = find(strcmp(str2, 'DataRate'));
sr_matrc = str2double(str3{idx_sr});
idx_unit = find(strcmp(str2, 'Units'));
unit_matrc = str3{idx_unit};
fclose(fid);

ma_trc = types.core.TimeSeries(... % tracking data
    'starting_time', time(1), ...
    'starting_time_rate', sr_matrc,...
    'timestamps',time,...
    'data',ma_xyz,...
    'data_unit', unit_matrc);  
nwb.acquisition.set('ma_trc', ma_trc);
if exportnwbtag == 1
    %% export
    outdest = fullfile(['test_convrawma' '.nwb']);
    nwbExport(nwb, outdest);
end

% %% deal ma anc file
% filename_maanc = [[upper(animal(1)) animal(2:end)] '_' datestr(dateofexp, 'yyyymmdd') '_' num2str(blocknum) '.anc']; % filename_maanc = 'Bug_20190111_1.anc'
% ma_anc = types.core.TimeSeries(... % Analog data
%     'starting_time', stream.startTime, ...
%     'starting_time_rate',stream.fs,...
%     'data',stream.data,...
%     'electrodes', tablereg);  



