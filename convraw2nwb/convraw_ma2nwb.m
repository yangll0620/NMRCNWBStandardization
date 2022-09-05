function nwb = convraw_ma2nwb(rawancfile, rawtrcfile, varargin)
%  convraw_ma2nwb convert raw ma data in rawancfile and rawtrcfile to NWB.acquisition
% 
% 
% Example usage:
%
%       rawancfile = 'Y:\Animals2\Bug\Recording\Raw\rawMA\MA20190111\Bug_20190111_1.anc';
%
%       rawtrcfile = 'Y:\Animals2\Bug\Recording\Raw\rawMA\MA20190111\Bug_20190111_1_cleaned.trc';
%
%       nwb = convraw_ma2nwb(rawancfile, rawtrcfile);
% 
% Inputs:
%
%       rawancfile(required)      ---- the ANC file containing MA data
%
%       rawtrcfile(required)      ---- the trc file containing MA data
%
%       
%   Name-Value (optional parameters): 
%
%       'nwb_in': input an exist nwb, default [] create a new nwb  
%
%       'identifier': input an identifier, default '' create an empty character string
%
% Outputs:
%
%       nwb             ---- nwb structure containing ma .anc and .trc information 



% check if rawancfile and rawtrcfile matches by animal name and date
parse_rawancfile = strsplit(rawancfile,'\');
parse_rawtrcfile = strsplit(rawtrcfile,'\');

anc_filename = parse_rawancfile{end};
trc_filename = parse_rawtrcfile{end};

parse_anc_filename = strsplit(anc_filename,'.');
parse_trc_filename = strsplit(trc_filename,'.');

anc_animal_date_block = parse_anc_filename{1};
trc_animal_date_block = parse_trc_filename{1}(1:end-8);

if ~strcmp(anc_animal_date_block,trc_animal_date_block)
    error('Error. Two input files (anc and trc) are not for the same recording.')
end

% parse params
p = inputParser;
addParameter(p, 'nwb_in', [], @(x) isa(x, 'NwbFile'));
addParameter(p, 'identifier', '', @(x) ischar(x)&&(~isempty(x)));
parse(p,varargin{:});
nwb = p.Results.nwb_in; % [] or a NwbFile variable

% create empty nwb file if doesn't exist
if isempty(nwb)
    nwb = NwbFile();
end

% system check
if ~(isunix || ispc)
    disp('Using neither windows or unix OS.');
    return;
end

% assign value to nwb.identifier
if(isempty(nwb.identifier))
    if(~isempty(p.Results.identifier))
        nwb.identifier = p.Results.identifier;
    else
        error('Input parameter "identifier" is missing.');
    end
end

nwb.session_description = rawtrcfile(1:end-(length(trc_filename)+1)); %link folder name to nwb.session_description

    
% DO WE NEED A FILE CREATE DATE?
%if isa(nwb.file_create_date,'types.untyped.DataStub') % nwb.file_create_date is not a datetime format
    %file_create_date = nwb.file_create_date.load();
    %nwb.file_create_date = file_create_date;
%end

% parse ma .trc file
ma_trc = parse_matrcfile(rawtrcfile);
nwb.acquisition.set('ma_marker_cleaned', ma_trc);

% parse ma .anc file
ma_anc = parse_maancfile(rawancfile);
nwb.acquisition.set('ma_sync', ma_anc);

%get year, month, date from the 6-digit yyyymmdd in file names
parse_anc_animal_date_block = strsplit(anc_animal_date_block,'_');
datestring = parse_anc_animal_date_block{2};

year = str2double(extractBetween(datestring,1,4));
month = str2double(extractBetween(datestring,5,6));
date = str2double(extractBetween(datestring,7,8));

% assign time in yyyymmdd format to nwb.session_start_time
if(isempty(nwb.session_start_time))
    nwb.session_start_time = datetime(year, month, date); 
end

if(isempty(nwb.timestamps_reference_time))
    nwb.timestamps_reference_time = nwb.session_start_time; % not sure
end



function ma_trc = parse_matrcfile(rawtrcfile)
% parse_matrcfile() parses the ma .trc tracking file into a types.core.TimeSeries structure
%
% Example usage:
%       rawtrcfile = 'Y:\Animals2\Bug\Recording\Raw\rawMA\MA20190111\Bug_20190111_1_cleaned.trc';
%
%       ma_trc = parse_matrcfile(rawtrcfile);
%
% Input:
%       rawtrcfile: the full path of ma .trc file
%
%
% Output: 
%       ma_trc: a types.core.TimeSeries structure storing the joint tracking data
%               of ma system

%read the numerical data in the ma .trc file 
numlinestart = 7; 
dataimport = importdata(rawtrcfile,'\t',numlinestart-1);% reading numeric data starting from line numlinestart 

% dataimport.data (ntimes * ncolumns): 
%   first column (frame #), second column (time stamps)
%   third -end columns (x,y,z positions for all joints)
time = dataimport.data(:,2);
data = dataimport.data(:,3:end);

% deal with the head information in the ma .trc file
fid = fopen(rawtrcfile);
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


function ma_anc = parse_maancfile(rawancfile)
%% parse_maancfile() parses the ma .anc analog data file into a types.core.TimeSeries structure
%
% Example usage:
%       rawancfile = 'Y:\Animals2\Bug\Recording\Raw\rawMA\MA20190111\Bug_20190111_1.anc';
%       ma_anc = parse_matrcfile(rawancfile);
%
% input:
%       rawancfile: the full path of ma .anc file
%
%
% output: 
%       ma_anc: a types.core.TimeSeries structure storing the input analog
%               data of ma system

%read the numerical data in the ma .anc file 
numlinestart = 12; % read from line numlinestrart
dataimport = importdata(rawancfile,'\t',numlinestart -1);% reading numeric data starting from line numlinestart

% dataimport.data (ntimes * ncolumns): 
%   first column (time stamps)
%   second -end columns (analog data of input channel)
time = dataimport.data(:,1);
data = dataimport.data(:,2:end);

% deal with the head information in the ma .anc file
fid = fopen(rawancfile);
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