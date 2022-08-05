

% function [data]= export()
%% ******* use for debugging and NOT using as function  *****
clear all; close all;
%% %%%%%%%%%%% FUNCTION BOOKKEEPING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
func_name='export_EYE2MAT'; c_version = 101; str=date;
FileInfoMATLAB.(func_name)=['V:' num2str(c_version) ' created:' str];
%% %%%%%%%%%%% FILE IO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % -----------------Toolbox & Code directories------------------------
% restoredefaultpath;
% FileInfoMATLAB.FT_version='fieldtrip-20160221';
% addpath(['Y:\hendrix\MATLAB Code\lib_FT\' FileInfoMATLAB.FT_version]); ft_defaults;
% addpath('Y:\hendrix\MATLAB Code\lib_NHP\')
% % ---------- choose NHP files to search ---------------
FileInfoMATLAB.NHP2RUN={'Bug' 'Pinky' 'Tootie' 'Lulu', 'Barb'};

% %- - - - - - - QUERRY USR TO SELECT NHP SESSION(S) 2 RUN - - - - - - - -
idx_nhp = menu('Choose NHP',FileInfoMATLAB.NHP2RUN);
NHP2RUN=FileInfoMATLAB.NHP2RUN{1,idx_nhp };

% % --------- I/O paths -----------------
DirInfo.Local='C:\TempData\';%% create if does not exist
DirInfo.root2='Z:\';
DirInfo.root='Y:\';
DirInfo.dir2load.(NHP2RUN)=['/Users/linglingyang/Desktop/NMRCNWB_TestData/EyetrackingData/'];
DirInfo.dir2save.(NHP2RUN)=[ '/Users/linglingyang/Desktop/NMRCNWB_TestData/EyetrackingData/'];
FileInfoMATLAB.DirInfo=DirInfo;
%% %%%%%%%%%   init vars function   %%%%%%%%%%%%%%%%
% %------ init flags------------------------
% % 1. True/yes --  0. false/noflag_overwrite=0;
flag_overwrite=1;
flag_plot=1;
flag_ERR=1; %% display ERRORS
flag_WARN=1; %% display WARNINGS
flag_PROC=0; %% display PROCESSING 
% % - - - - init vars - - - - 
FileInfoMATLAB=struct();
FileInfoMATLAB.DirInfo=DirInfo;
FileInfoMATLAB.VARS_DUMMY={'ATT' 'ADT' 'MRK' 'ARI' 'CNT' 'AQU'};
FileInfoMATLAB.VARS_MINREQ={'ALX' 'ALY'};
%% %%%%%%%%%%%%%%%%%%  BEGIN MAIN PROGRAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%

listing = dir([DirInfo.dir2load.(NHP2RUN) '*.txt' ]);
list_dir=cellstr({listing.name});
dir2choose=list_dir;
dir2choose{1,end+1}='...';
[ss,vv] = listdlg('PromptString','Select a sessions:',...
                'SelectionMode','multiple',...
                'InitialValue' , length(dir2choose), ...
                'ListString',dir2choose);
flag_exit=0;
if isempty(ss) || (length(ss)==1 && ss==length(dir2choose)) || ~isempty(find(ss==0))
    disp('you did not select any sessions to run')
    flag_exit=1;
    return;
end
%% %%%%%%%          MAIN PROGRAM                %%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --------- loop through each recording session :: 1 FILE per RECORDING ---------------
for file_num=1:length(ss) %% ix sessions FOLDERS
    %% init vars Session ix
    fn_str=dir2choose{1,ss(file_num)};
    disp(fn_str);
    if strcmp(fn_str,'...')
       continue; 
    end    
    list_temp=dir([DirInfo.dir2load.(NHP2RUN) fn_str]);
    if list_temp.bytes>1000000000 %% this happens when someone forgets to stop the recording
       disp(['ERROR:: filename ' fn_str  ' too big to load']) ;
       continue;
    end    
    FileInfoMATLAB.WARNING=[]; FileInfoMATLAB.ERROR=[];
    cnt_warning=0; cnt_error=0;
    %% DECOMPOSE FOLDERNAME INTO INIT VARS
    FileInfoBlock=struct();
    FileInfoBlock.NHP=NHP2RUN;
    FileInfoBlock.FileNameRaw=fn_str;
    FileInfoBlock.FileDirRaw=[DirInfo.dir2load.(NHP2RUN)  fn_str];
    FileInfoBlock.FileDirInfo=dir(fullfile(DirInfo.dir2load.(NHP2RUN), fn_str));
    temp_split=strsplit(FileInfoBlock.FileDirInfo.date,' ');
    FileInfoBlock.Date_ddmmmyyyy=temp_split{1,1};
    FileInfoBlock.DateNum=datenum(FileInfoBlock.Date_ddmmmyyyy,'dd-mmm-yyyy') ;
    FileInfoBlock.DateVec=datevec(FileInfoBlock.DateNum);
    FileInfoBlock.Date=datestr(FileInfoBlock.DateVec,'yyyy-mmm-dd');
    FileInfoBlock.Time=temp_split{1,2};
    temp_str=strsplit(FileInfoBlock.Time,':');
    FileInfoBlock.BlockName=[temp_str{1,1} 'h'  temp_str{1,2} 'm' temp_str{1,3} 's' ]; 
    FileInfoBlock.DirName=[FileInfoBlock.NHP '_' FileInfoBlock.Date];
    FileInfoBlock.fn2save=[FileInfoBlock.NHP '_' FileInfoBlock.Date '_' FileInfoBlock.BlockName '_EyeTracking_v' num2str(c_version) '.mat'];
    %% check if file already exists
    if ( flag_overwrite==0 && exist([DirInfo.dir2save.(NHP2RUN) FileInfoBlock.DirName '\' FileInfoBlock.fn2save],'file') )
%        disp(['File already processed, output not overwritten ' FileInfoBlock.FileNameRaw  ]) 
       continue;
    elseif  ( flag_overwrite==1 && exist([DirInfo.dir2save.(NHP2RUN) FileInfoBlock.DirName '\' FileInfoBlock.fn2save],'file') )
            disp(['Overwrite is flagged, deleting old file ' FileInfoBlock.fn2save]);
            delete( [DirInfo.dir2save.(NHP2RUN) FileInfoBlock.DirName '\' FileInfoBlock.fn2save]);
    end
    %% check firt line of code
    fileID = fopen(FileInfoBlock.FileDirRaw,'r');
    first=textscan(fileID,'%s' ,1); %% update this in future to read first line?
    fclose(fileID);
    if ~strcmp(first{1,1},'3') 
%         if ~strcmp(first{1,1},day of the week ) CHECH if header or history file.
       disp(['ERROR:: Filename '  FileInfoBlock.FileNameRaw ' is not an eyetracking data.txt file'  ]);
       continue; 
    end    
    %% open eyetracking file get header info + codes
    delimiter = '\t';
    formatSpec = '%f%[^\n\r]';
    fileID = fopen(FileInfoBlock.FileDirRaw,'r');
    try
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN , 'ReturnOnError', false);
    catch ME
%         disp(ME);
        disp(['ERROR: error scanning file (try removing blank lines at eof and rerun)' FileInfoBlock.FileNameRaw ]);
        fclose(fileID);
        continue;
    end
    fclose(fileID);
    if isempty(strfind(dataArray{1,2}{1,1},'Product Version'))
       disp(['ERROR:: Filename '  FileInfoBlock.FileNameRaw ' is not an eyetracking txt file'  ]);
       continue;
    end
    %% GET LINE CODES (COL 1)
    idx_data_lines=find(dataArray{1,1}==10); %% identify all DATA lines, above is header text
    if isempty(idx_data_lines)
       disp(['ERROR:: Filename ' FileInfoBlock.FileNameRaw    ' missing data lines'    ]) ;
       continue;
    end    
    CODES=unique(dataArray{1,1});
    hdr=struct();
    hdr.code_num=CODES';
    for ix_code=1:length(CODES) %% for each line with unique code x
        code_txt{ix_code}={dataArray{1,2}{  find(dataArray{1,1}==CODES(ix_code)) ,:}}; %% get text for that line
        if CODES(ix_code)==10 %% special case data lines
            code_txt{ix_code}={};
            continue;
        end
        if size(code_txt{ix_code},2)==1 %% if only one column
            hdr.(['code_' num2str(CODES(ix_code)) ]) = strsplit(char(  code_txt{ix_code}   ),'\t');
        elseif size(code_txt{ix_code},1)==1 %% if only one line
            for ix_line=1:size(code_txt{ix_code},2)
                get_str=   strsplit( char(code_txt{ix_code}{1,ix_line}), '\t');
                if (CODES(ix_code)==7 && ix_line==1)
                    hdr.(['code_' num2str(CODES(ix_code)) ]).temp=strsplit( char(code_txt{ix_code}{1,ix_line}) ,'\t')   ;
                end    
                if  ( ~isempty(str2num(get_str{1,1}))  )%&& str2num(get_str{1,1})>0   )
                    hdr.(['code_' num2str(CODES(ix_code)) ]).ts(ix_line,1)=str2num(get_str{1,1});
                    %cell2mat( cellfun(@(x) sscanf(x,'%f'), code_txt{ix_code}' , 'UniformOutput', false) ) ; 
                    hdr.(['code_' num2str(CODES(ix_code)) ]).txt{ix_line,1} = get_str{1,2:end};
                    %code_txt{ix_code}';
                    continue;
                end
            end %% for each line of text
        end
    end
    if ~isfield(hdr,'code_6')
       disp(['ERROR:: Filename ' FileInfoBlock.FileNameRaw    ' missing column header names for data'    ]) ;
       continue;  
    end    
    n_col=size(hdr.code_6,2);
    formatSpec='%f';
    for ix_col=1:n_col
        formatSpec=[formatSpec '%s']; %% this sets size for data array to import
    end    
    formatSpec=[formatSpec '%[^\n\r]'];
    %% open file again and get data (1 column per variable) + 1 extra line, does not load header
    fileID = fopen(FileInfoBlock.FileDirRaw,'r');
    raw_data = textscan(fileID, formatSpec,'HeaderLines', (idx_data_lines(1)-1) , 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
    fclose(fileID);
    n_row=size(raw_data{1,1},1);
    n_col=length(hdr.code_6);
    data=zeros(n_row,n_col+1);
    data(:,1)=raw_data{1,1};
    for ix_label=1:length(hdr.code_6)
        temp_rows=length(cell2mat(cellfun(@(x) str2double(x), raw_data(ix_label+1), 'UniformOutput', false)));
        if temp_rows == n_row;
        data(:,ix_label+1)= cell2mat(cellfun(@(x) str2double(x), raw_data(ix_label+1), 'UniformOutput', false));
        else %% soemtimes writing to txt file gets interupted missing data
        data(1:temp_rows,ix_label+1)  = cell2mat(cellfun(@(x) str2double(x), raw_data(ix_label+1), 'UniformOutput', false));
        data(temp_rows+1:n_row,ix_label+1) = zeros(n_row-temp_rows,1)./0;
        disp(['WARNING:: Variable ' char(hdr.code_6{ix_label}) ' missing data rows ' num2str(temp_rows) '-to-' num2str(n_row) ' in Filename ' FileInfoBlock.FileNameRaw  ]);
        end
    end
    data(end,:)=[]; %% remove last row
    idx_data=find(data(:,1)~=10); %% id lines not data
    data(idx_data,:)=[];%% remove non data
    data(:,1)=[]; %% remove first column with line codes
    if data(2,1)==0
        data(1,:)=[];
    end    
    %% GET estimated Fs 
    if ( isfield(hdr,'code_7') && isfield(hdr.code_7,'temp') )
        temp_split=strsplit( cell2mat(hdr.code_7.temp) ,'FrameRate'   );
    elseif ( isfield(hdr,'code_7') && iscell(hdr.code_7) )
        temp_split=strsplit( cell2mat(hdr.code_7) ,'FrameRate'   );
    else
      disp(['something wrong with file, code_7 unable to get raw Fs from file::'   FileInfoBlock.FileNameRaw  ] );
        continue;
    end
    Fs_raw_est=str2num(temp_split{1,end});
    if isempty(Fs_raw_est) %% sometimes needs this when not tab delimited
        temp_split2=  strsplit(temp_split{1,end},'.');
        Fs_raw_est=str2num(temp_split2{1,1});
    end    
    ADT_sec_est=1/Fs_raw_est;
    ADT_msec_mean=mean(data(:,2));
    if isnan(ADT_msec_mean)
        disp(['ERROR READING :: ' FileInfoBlock.FileNameRaw   ]);
        continue;
    end    
    ADT_sec_target=floor(ADT_msec_mean)/1000;
    Fs=1/ADT_sec_target;
    
    %% need to interpolate data to constant Fs
    TTS=[0:ADT_sec_target:data(end,1)]; %% New time series used to spline data to fixed intervals
    TrialDataEye=struct();
    flag_bad=0; 
    for ix_label=1:size(hdr.code_6,2)
        if find( strcmp( FileInfoMATLAB.VARS_DUMMY, hdr.code_6{1,ix_label} ) )
            continue
        end
        if isempty(find(isnan(data(:,ix_label))))
           
            try
                yy=interp1(data(:,1),data(:,ix_label),TTS','nearest');
            catch ME
%                 disp(ME)
                disp('unable to run interpolation on ...')
                continue;
            end
            if mean(diff(yy))==0
%                 disp( ['WARNING:: '  (hdr.code_6{1,ix_label}) ' does not change in value:: ' FileInfoBlock.FileNameRaw  ] );
                if ~isempty(find(  strcmp(FileInfoMATLAB.VARS_MINREQ,(hdr.code_6{1,ix_label})) ))
                    flag_bad=1; %% mark file as bad
                end
                continue; %% do not save variable
            end
            TrialDataEye.(hdr.code_6{1,ix_label})=yy;
        end
    end
   if flag_bad==1   ||  isempty(fields(TrialDataEye) )    
      disp( ['ERROR:: Filename '  FileInfoBlock.FileNameRaw  ' has bad/no data , file not saved' ] );
      continue; 
   end    
   TrailDataEye.raw_data=raw_data;
   TrialDataEye.TTS_sec=TTS;
   TrialDataEye.Fs=Fs;
   TrialDataEye.hdr=hdr;
   TrialDataEye.Fs_raw_est=Fs_raw_est;
   
   if flag_plot==1
      figure;
      subplot(2,1,1)
      plot(TrialDataEye.TTS_sec,TrialDataEye.ALX,'k') ; hold on;
      plot(data(:,1),data(:,3),'r--');
      subplot(2,1,2)
      plot(TrialDataEye.TTS_sec,TrialDataEye.ALY,'k') ; hold on;
      plot(data(:,1),data(:,4),'r--');
      pause(1);
   end    
   
   disp(['saving........' FileInfoBlock.fn2save]);
            save(['C:\TempData\' FileInfoBlock.fn2save], 'File*','Trial*', '-v7.3');
            if ~exist( [DirInfo.dir2save.(NHP2RUN) FileInfoBlock.DirName],'dir');
                mkdir( [DirInfo.dir2save.(NHP2RUN) FileInfoBlock.DirName] );
            end
   message= movefile( ['C:\TempData\' FileInfoBlock.fn2save] ,[DirInfo.dir2save.(NHP2RUN) FileInfoBlock.DirName]);
   clear data idx_sata_lines;
end
    
    
