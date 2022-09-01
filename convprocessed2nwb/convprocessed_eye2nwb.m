function [nwb] = convprocessed_eye2nwb(filepath,varargin)
% converts raw eyetracking data to nwb.processing using a preprocessed module
%
% Variable names and the command to get them:
%
%   eyeTracking: SpatialSeries object containing processed eyetracking information from the txt file
%       nwb.processing.get('EyeTrackingInfo').nwbdatainterface.get('EyeTrackingPos').spatialseries.get('eyeTracking');
%       
%
%   EyeTrackingPos: Position object that stores the SpatialSeries Objects named eyeTracking
%       nwb.processing.get('EyeTrackingInfo').nwbdatainterface.get('EyeTrackingPos');
%       
%
%   EyeTrackingInfo: ProcessingModule object that contains a description and Position object named EyeTrackingPos
%       nwb.processing.get('EyeTrackingInfo');
%
%
% Example usage:
%
%       [nwb] = convprocessed_eye2nwb(filepath, 'identifier', identifier)
%
%       [nwb] = convprocessed_eye2nwb(filepath, 'nwb_in', nwb)
%
%       [nwb] = convprocessed_eye2nwb(filepath, 'nwb_in', nwb, 'identifier', identifier)
% 
% Inputs
%   
%   filepath(required): filepath of the raw eyetracking data (txt file)
%   
%   Name-Value (optional parameters): 
%
%       'nwb_in': input an exist nwb, default [] create a new nwb  
%
%       'identifier': input an identifier, default '' create an empty character string
%       
%
% Output:
%
%       nwb       ---- nwb structure containing processed eyetracking data information 

% parse params
p = inputParser;
addParameter(p, 'nwb_in', [], @(x) isa(x, 'NwbFile'));
addParameter(p, 'identifier', '', @(x) ischar(x)&&(~isempty(x)));
parse(p,varargin{:});
nwb = p.Results.nwb_in; % [] or a NwbFile variable

%check if nwb exists
if isempty(nwb)
    nwb = NwbFile();
end

%check system
if ~(isunix || ispc)
    disp('Using neither windows or unix OS.');
    return;
end


%Check if identifier exists
if(isempty(nwb.identifier))
    if(~isempty(p.Results.identifier))
        nwb.identifier = p.Results.identifier;
    else
        error('Input parameter "identifier" is missing. convprocessed_dlc2nwb');
    end
end


%Get file name
[~,filename,~] = fileparts(filepath);

% preprocessed module
TrialDataEye = exportTrialDataEye(filepath);

%Create spatialseries object and name it as eyeTracking
eyeTracking = types.core.SpatialSeries();


%Get Variable Names from TrialDataEye --- get all the field names before "raw_data" for now(not sure about this)
f = string(fieldnames(TrialDataEye));
varNames = f(1:find(f=="raw_data")-1);
comments = "TTS_sec";
s = size(varNames);
s = s(1);
dataset = [];
dataset{1} = transpose(getfield(TrialDataEye,"TTS_sec"));
for i = 2:(s+1)
    comments = strcat(comments,";",varNames(i-1));
    dataset{i} = getfield(TrialDataEye,varNames(i-1));
end

%get datetime information from filename

str = string(filename); %start time in string format
dateVal = strsplit(str,{'-',';'}); %start time denoted by a list of strings

%set attributes of nwbfile object
if(isempty(nwb.session_description))
    nwb.session_description = nwb.identifier; %not sure
end

if(isempty(nwb.session_start_time))
    nwb.session_start_time = datetime(str2double(dateVal));
end

if(isempty(nwb.timestamps_reference_time))
    nwb.timestamps_reference_time = nwb.session_start_time;
end

%set attributes of spatialseries object
eyeTracking.comments = char(comments); % a character array of column names that are diliminated by ';'
eyeTracking.data = cell2mat(dataset);
eyeTracking.description = filepath; %not sure
eyeTracking.starting_time_rate = TrialDataEye.Fs;

%create EyeTracking object and name it as 'eyetracking'
if(~any(strcmp(nwb.processing.keys,'EyeTrackingInfo')))
    EyeTrackingPos = types.core.EyeTracking('eyeTracking',eyeTracking);
else
    EyeTrackingPos = nwb.processing.get('EyeTrackingInfo').nwbdatainterface.get('EyeTrackingPos');
    EyeTrackingPos.spatialseries.set('eyeTracking', eyeTracking);
end

% create processing module
behavior_mod = types.core.ProcessingModule( 'description',  'contains eyeTracking data');
% add the Position object (that holds the SpatialSeries object)
behavior_mod.nwbdatainterface.set('EyeTrackingPos', EyeTrackingPos);
% add the processing module to the NWBFile object, and name it "behavior"
nwb.processing.set('EyeTrackingInfo',behavior_mod);


end


function[TrialDataEye] = exportTrialDataEye(filepath)
% Get a struct that contains useful information from the txt file.
%
%
% TrialDataEye.Fs_actual=Fs_actual; % Actual Fs
%
%
% Example usage:
%
%       [TrialDataEye] = exportTrialDataEye(filepath)
% 
% Inputs
%   
%   filepath(required): filepath of the raw eyetracking data (txt file)
%   
%       
%
% Output:
%
%       TrialDataEye       ---- a struct containing useful information from the raw eyetracking data txt file 
%           Variable names:
%               TrialDataEye.raw_data: Eyetracking raw data
%               TrialDataEye.TTS_sec: Interpolated timepoints corresponding to the estimated Fs we got
%               TrialDataEye.Fs: Estimated Fs that we are using
%               TrialDataEye.hdr: Containing all descriptive contents except raw data from the file, categorized by different line codes
%               Examples:
%                   TrialDataEye.hdr.code_5: Column names with their actual names.
%                   TrialDataEye.hdr.code_6: Column names with their abbreviated names in three letters.         


%Construct dataArray, which consists of a list of line codes, and a list of content of all lines
delimiter = '\t'; %tab
formatSpec = '%f%[^\n\r]'; %?
fileID = fopen(filepath,'r');
try
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN , 'ReturnOnError', false);
catch ME
    disp(['ERROR: error scanning file (try removing blank lines at eof and rerun)' filename ]);
    fclose(fileID);
end
fclose(fileID);
if isempty(strfind(dataArray{1,2}{1,1},'Product Version'))
   disp(['ERROR:: Filename '  filename ' is not an eyetracking txt file'  ]);
end

%Identify all data lines's index
idx_data_lines=find(dataArray{1,1}==10);
if isempty(idx_data_lines)
   disp(['ERROR:: Filename ' filename    ' missing data lines'    ]) ;
end    

%There are different line codes at the beginning of each line denoting the data type of that line. 
%Get all different line codes that have appeared in the txt file.
CODES=unique(dataArray{1,1});

%Construct hdr to store line content categorized by different line codes
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
            if  ( ~isempty(str2num(get_str{1,1}))  ) 
                hdr.(['code_' num2str(CODES(ix_code)) ]).ts(ix_line,1)=str2num(get_str{1,1});
                hdr.(['code_' num2str(CODES(ix_code)) ]).txt{ix_line,1} = get_str{1,2:end};
                continue;
            end
        end
    end
end

%Report if there is no line containing column names in the file. 
if ~isfield(hdr,'code_6')
   disp(['ERROR:: Filename ' filename    ' missing column header names for data'    ]) ;
end

%Count how many column names there are, which will be the number of columns.
n_col=size(hdr.code_6,2);

%Set data format
formatSpec='%f';
for ix_col=1:n_col
    formatSpec=[formatSpec '%s']; %% this sets size for data array to import
end    
formatSpec=[formatSpec '%[^\n\r]'];


% open file again and get data (1 column per variable) + 1 extra line, does not load header
fileID = fopen(filepath,'r');
raw_data = textscan(fileID, formatSpec,'HeaderLines', (idx_data_lines(1)-1) , 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

%number of rows of data
n_row=size(raw_data{1,1},1);


data=zeros(n_row,n_col+1);
data(:,1)=raw_data{1,1};
for ix_label=1:length(hdr.code_6)
    temp_rows=length(cell2mat(cellfun(@(x) str2double(x), raw_data(ix_label+1), 'UniformOutput', false)));
    if temp_rows == n_row;
        data(:,ix_label+1)= cell2mat(cellfun(@(x) str2double(x), raw_data(ix_label+1), 'UniformOutput', false));
    else %% sometimes writing to txt file gets interupted missing data
        data(1:temp_rows,ix_label+1)  = cell2mat(cellfun(@(x) str2double(x), raw_data(ix_label+1), 'UniformOutput', false));
        data(temp_rows+1:n_row,ix_label+1) = zeros(n_row-temp_rows,1)./0;
        disp(['WARNING:: Variable ' char(hdr.code_6{ix_label}) ' missing data rows ' num2str(temp_rows) '-to-' num2str(n_row) ' in Filename ' FileInfoBlock.FileNameRaw  ]);
    end
end

%remove last row
data(end,:)=[];

%For each line that contains the eyetracking data, the line code at the beginning of that line is 10.
%Find the indices of all lines that are not eyetracking data / not starting with 10.
idx_data=find(data(:,1)~=10); 
data(idx_data,:)=[];%% remove non data
data(:,1)=[]; %% remove first column with line codes
if data(2,1)==0
    data(1,:)=[];
end 

% get estimated Fs (sampling rate)
if ( isfield(hdr,'code_7') && isfield(hdr.code_7,'temp') )
    temp_split=strsplit( cell2mat(hdr.code_7.temp) ,'FrameRate'   );
elseif ( isfield(hdr,'code_7') && iscell(hdr.code_7) )
    temp_split=strsplit( cell2mat(hdr.code_7) ,'FrameRate'   );
else
  disp(['something wrong with file, code_7 unable to get raw Fs from file::'   filename  ] );
end
Fs_raw_est=str2num(temp_split{1,end});
if isempty(Fs_raw_est) %% sometimes needs this when not tab delimited
    temp_split2=  strsplit(temp_split{1,end},'.');
    Fs_raw_est=str2num(temp_split2{1,1});
end    
ADT_sec_est=1/Fs_raw_est;
ADT_msec_mean=mean(data(:,2));
if isnan(ADT_msec_mean)
    disp(['ERROR READING :: ' filename   ]);

end    
ADT_sec_target=floor(ADT_msec_mean)/1000;
Fs=1/ADT_sec_target;

% Get timepoints according to the estimated Fs, we need to interpolate data to constant Fs
TTS=[0:ADT_sec_target:data(end,1)]; %% New time series used to spline data to fixed intervals
TrialDataEye=struct();
flag_bad=0; 
VARS_DUMMY={'ATT' 'ADT' 'MRK' 'ARI' 'CNT' 'AQU'}; 
VARS_MINREQ={'ALX' 'ALY'};
for ix_label=1:size(hdr.code_6,2)
    if find( strcmp( VARS_DUMMY, hdr.code_6{1,ix_label} ) )
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
            if ~isempty(find(  strcmp(VARS_MINREQ,(hdr.code_6{1,ix_label})) ))
                flag_bad=1; %% mark file as bad
            end
            continue; %% do not save variable
        end
        TrialDataEye.(hdr.code_6{1,ix_label})=yy;
    end
end
if flag_bad==1   ||  isempty(fields(TrialDataEye) )    
  disp( ['ERROR:: Filename '  filepath  ' has bad/no data , file not saved' ] );

end    

TrialDataEye.raw_data=raw_data; %Eyetracking raw data
TrialDataEye.TTS_sec=TTS; % Interpolated timepoints corresponding to the estimated Fs we got
TrialDataEye.Fs=Fs; % Estimated Fs that we are using
TrialDataEye.hdr=hdr; % Containing all contents from the file, categorized by different line codes
TrialDataEye.Fs_actual=Fs_actual; % Actual Fs


end
