function [nwb] = convprocessed_eye2nwb(TrialDataEye, FileInfoBlock,varargin)
% converts processed eyetracking data to nwb
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
%   TrialDataEye(required): containing all eyetracking data, variable gotten from running the function export_EYE2MAT.m
%
%   FileInfoBlock(required): containing all descriptive information of the data, variable gotten from running the function export_EYE2MAT.m
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

%Create spatialseries object and name it as eyeTracking
eyeTracking = types.core.SpatialSeries();


%Get Variable Names from TrialDataEye --- get all the field names before "raw_data" for now(not sure about this)
f = string(fieldnames(TrialDataEye));
varNames = f(1:find(f=="raw_data")-1);
comments = "TTS_sec";
s = size(varNames);
s = s(1);
data = [];
data{1} = transpose(getfield(TrialDataEye,"TTS_sec"));
for i = 2:(s+1)
    comments = strcat(comments,";",varNames(i-1));
    data{i} = getfield(TrialDataEye,varNames(i-1));
end

%get datetime information from filename
filename = FileInfoBlock.FileNameRaw;
startTime = filename(1:end-4);
str = string(startTime);
dateVal = strsplit(str,{'-',';'});

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
eyeTracking.data = cell2mat(data);
eyeTracking.description = FileInfoBlock.FileDirRaw; %not sure
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

