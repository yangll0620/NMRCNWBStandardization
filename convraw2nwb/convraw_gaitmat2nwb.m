function nwb = convraw_gaitmat2nwb(fsxfile, mapfilepath, equilibrationfile, calibrationfile, exportnwbtag, nwb)
%  convraw_gaitmat2nwb convert raw gaitmat data in rawgaitmatfile to NWB.acquisition
%  
%  Can only be used in Windows as the SDK provided by Tekscan (gait mat company) requires .Net 
%
% Example usage:
%           fsxfile = 'Y:\\Animals2\\Bug\\Recording\\Raw\\Habit Trail\\Gaitmat\\20181128\\CPB01.fsx';
% 
%           mapfilepath = 'Y:\\yll\\NMRCNWB\\gaitmatfiles';
%       
%           equilibrationfile = 'Y:\\yll\\NMRCNWB\\gaitmatfiles\\CES-2016-12-09-7101QL-40PSI.equ';
%   
%           calibrationfile = 'Y:\\yll\\NMRCNWB\\gaitmatfiles\\Azula_calibrationfile_9.1_080918.cal';
%
%           nwb = convraw_gaitmat2nwb(fsxfile, mapfilepath, equilibrationfile, calibrationfile);
%           or
%           nwb = convraw_gaitmat2nwb(fsxfile, mapfilepath, equilibrationfile, calibrationfile, 1, nwb);
%
% Inputs:
%       fsxfile        ---- the .fsx file
%
%       mapfilepath       ---- the folder containing the map file (.mp)
%
%       equilibrationfile  ---- the equilibration .equ file
%
%       calibrationfile  ---- the calibration .cal file
%
%       exportnwbtag    ---- tag for exporting nwb file (1) or not (default 0)
%
%       nwb             ---- exist nwb structure (if missing, will create a new nwb structure)
%
% Outputs
%       nwb             ---- nwb structure containing gait mat information


if nargin < 6
    newnwbtag = 1;
else
    newnwbtag = 0;
end

if nargin < 5
    exportnwbtag = 0;
end


%% extract animal, dateofexp information
gaitmatpath = fileparts(fsxfile);
[animal, dateofexp] = parsegaitmatpath(gaitmatpath);
if isempty(animal)
    disp(['animal is not parsed!']);
    return;
end

if isempty(dateofexp)
    disp(['dateofexp is not parsed!']);
    return;
end

%% create a new nwb structure
if newnwbtag == 1
    % create new nwb structure
    identifier = [animal '_' datestr(dateofexp,'yymmdd')];
    session_description = ['NWB file on ' animal ' performing on day ' datestr(dateofexp,'yymmdd')];
    nwb = nwbfile(...
        'identifier', identifier, ...
        'session_description', session_description);
else
    if isa(nwb.file_create_date,'types.untyped.DataStub') % nwb.file_create_date is not a datetime format
        file_create_date = nwb.file_create_date.load();
        nwb.file_create_date = file_create_date;
    end
end

%% parse gait mat files
gaitmat = parse_gaitmatfile(fsxfile, mapfilepath, equilibrationfile, calibrationfile);

% set gaitmat time series into nwb.acqusition
nwb.acquisition.set('gaitmat', gaitmat);

%% export
if exportnwbtag == 1
    outdest = fullfile(['test_convrawgaitmat' '.nwb']);
    
    % fill the requied field nwb.session_start_time for exporting
    if isempty(nwb.session_start_time) 
        nwb.session_start_time = datestr(dateofexp);
    end
    
    % export
    nwbExport(nwb, outdest);
end


function gaitmat = parse_gaitmatfile(fsxfile, mapfilepath, equilibrationfile, calibrationfile)
% parse_gaitmatfile() parses the gaitmat .fsx file into a types.core.TimeSeries structure
%
% Example usage:
%           fsxfile = 'Y:\Animals2\Bug\Recording\Raw\Habit Trail\Gaitmat\061119\CPB94.fsx';
% 
%           mapfilepath = 'Y:\yll\NMRCNWB\gaitmatfiles';
%       
%           equilibrationfile = 'Y:\yll\NMRCNWB\gaitmatfiles\CES-2016-12-09-7101QL-40PSI.equ';
%   
%           calibrationfile = 'Y:\yll\NMRCNWB\gaitmatfiles\Azula_calibrationfile_9.1_080918.cal';
% 
% Inputs:
%       fsxfile        ---- the .fsx file
%
%       mapfilepath       ---- the folder containing the map file (.mp)
%
%       equilibrationfile  ---- the equilibration .equ file
%
%       calibrationfile  ---- the calibration .cal file
%
%
% Output: 
%       gaitmat: a types.core.TimeSeries structure storing the pressure
%       data in gait mat system

%% Import OEM Toolkit functions as .NET assembly
% Tekscan SDK and DRT require .Net version 4.0 and Matlab 2011 and higher


if ~strcmp(mexext, 'mexw64')
   disp('')
end

% Use the following dll for Matlab 64-bit
assembly = NET.addAssembly('C:\Tekscan\TekAPI\x64\TekAPIRead64.dll');

% Use the following dll for Matlab 32-bit
% assembly = NET.addAssembly('C:\Tekscan\TekAPI\TekAPIRead.dll');


%% CTekAPI Calss
CTekAPI = TekAPI.CTekAPI;

%% .mp, equilibration, and calibration files
% Set the location to look for .mp files
CTekAPI.TekSetMapFileDirectory(mapfilepath);

% Load a calibration/equilibration (optional)
% Return types are CTekEquilibration and CTekCalibration objects,
% respectively. These objects provide a function allowing for calibration
% and equilibration of arrays of captured frame data and can also be passed
% as parameters to functions that save recordings or apply calibrations and
% equilibrations to .fsx files.
% CTekEquilibration Class
equilibration = CTekAPI.TekLoadEquilibration(equilibrationfile);

% CTekCalibration Class
calibration = CTekAPI.TekLoadCalibration(calibrationfile);


%% Open .FSX file
% returns CTekFile object
recording = CTekAPI.TekLoadRecording(fsxfile);

%% Get details about the recording
rows = recording.TekGetRows();
columns = recording.TekGetColumns();
numberOfFrames = recording.TekGetFrameCount();
rowSpacing = recording.TekGetRowSpacing();
columnSpacing = recording.TekGetColumnSpacing();


%% Get data from file
% 0-based frame counting (first frame of the recording)
validframenum = 0;
for framenum = 0: numberOfFrames-1
    
    % get data for each framenum
    [error1, recordingData] = recording.TekGetRawFrameData(framenum);
    
    % get time stamps
    [error2, timestamp] = recording.TekGetFrameTimestamp(framenum);
    
    % return TEK_OK
    if error1 == 0 && error2 == 0
        validframenum = validframenum + 1;
        
        % Return value of data is System.Byte[], must use int8(), double(), etc.
        % to convert to MATLAB matrix/vector.
        recordingData = double(recordingData);
        
        % Reshape frame data to 2D array
        % Note reshape can be used to convert 1-D frame data to 2-D
        data(:,:, validframenum) = transpose(reshape(recordingData, columns, rows));
        
        
        time(validframenum) = timestamp;
    end
    
    clear error1 error2 recordingData timestamp;
end

% generate to a timeseries structure
gaitmat = types.core.TimeSeries(... % gaitmat data
    'starting_time', time(1), ...
    'starting_time_rate', 0,...
    'timestamps',time,...
    'data',data,...
    'data_unit', 'PSI');  % data units of pounds per square inch (PSI). 