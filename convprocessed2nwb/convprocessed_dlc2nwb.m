function [nwb] = convprocessed_dlc2nwb(filepath,varargin)
% converts processed xy dlc data to nwb and xyTable
%
% Variable names and the cammand to get them:
%
%   filepath: path of the file, can be obtained in jointsXY.description, stored as character
%
%   jointsXY: SpatialSeries object containing information from the file
%       nwb.processing.get('DLC_2D_XYpos').nwbdatainterface.get('DLCXYPosition').spatialseries.get(camname);
%       NOTE: 1.camname is in the format of 'camera-index', it is in character form
%             2.each spatialseries object represents information from a single camera of the recording
%
%   DLCXYPosition: Position object that stores the SpatialSeries Objects named jointsXY
%       nwb.processing.get('DLC_2D_XYpos').nwbdatainterface.get('DLCXYPosition')
%       NOTE: 1.This position object contains a set of all spatialseries objects, each one of which represents one camera
%             2.To get the set of all spatialseries objects, use
%                       nwb.processing.get('DLC_2D_XYpos').nwbdatainterface.get('DLCXYPosition').spatialseries
%             3.To add another spatialseries to the spatialseries set inside the position object, use 
%                       nwb.processing.get('DLC_2D_XYpos').nwbdatainterface.get('DLCXYPosition').spatialseries.set(char(camname), jointsXY);
%
%   DLC_2D_mod: ProcessingModule object that contains a description and Position object named DLCXYPosition
%       nwb.processing.get('DLC_2D_XYpos')
%
% Example usage:
%       [nwb] = convprocessed_dlc2nwb(filename)
% 
% Inputs
%   
%   filepath: processed dlc data using deep lab cut, required
%   
%   Name-Value (optional parameters): 
%
%       'nwb_in': input an exist nwb, default [] create a new nwb  
%       command to use when nwb exist:
%        newnwb = convprocessed_dlc2nwb(filepath,'nwb_in',existNWB)
%       
%
% Output:
%       nwb       ---- nwb structure containing processed xy position information 


% parse params
p = inputParser;
addParameter(p, 'nwb_in', [], @(x) isa(x, 'NwbFile'));
addParameter(p, 'identifier', '', @ischar);
parse(p,varargin{:});
nwb = p.Results.nwb_in;


if isempty(nwb)
    nwb = NwbFile();
end


if ~(isunix || ispc)
    disp('Using neither windows or unix OS.');
    return;
end

Mcell = readcell(filepath);
xyTable = readtable(filepath);
[~,colnum] = size(xyTable);


icam = strfind(filepath,"camera");
icam = icam(1);

idate_year = icam-16;
year = str2double(extractBetween(filepath,idate_year,idate_year+3));


idate_month = idate_year+4;
month = str2double(extractBetween(filepath,idate_month,idate_month+1));

idate_date = idate_month+2;
date = str2double(extractBetween(filepath,idate_date,idate_date+1));

idate_hour = idate_date+3;
hour = str2double(extractBetween(filepath,idate_hour,idate_hour+1));

idate_minute = idate_hour+2;
minute = str2double(extractBetween(filepath,idate_minute,idate_minute+1));

idate_second = idate_minute+2;
second = str2double(extractBetween(filepath,idate_second,idate_second+1));

%creating a SpatialSeries Object of hand




jointsXY = types.core.SpatialSeries();
jointsXY.data = xyTable{:,:};
nwb.identifier = 'xydata'; % change to better version later?
nwb.session_description = char(filepath); % change to better version later?

nwb.session_start_time = datetime(year, month, date, hour, minute, second); % extracted from file's name
nwb.timestamps_reference_time = datetime(year, month, date, hour, minute, second); % not sure
jointsXY.reference_frame = '(0,0) is the bottom left corner'; % not sure
jointsXY.data_unit = 'pixels'; % not sure
jointsXY.starting_time_rate = 30;



varNames = "timestamp";
for i = 2:colnum
    joint_name = Mcell{2,i};
    coord = Mcell{3,i};
    varNames = strcat(varNames,";",joint_name,"_",coord);
    
end

jointsXY.comments = char(varNames); % a character array of column names that are diliminated by ';'


%if no data exists, return
if isempty(jointsXY.data) == 1
   return;
end


%create position object and name it as 'camera-index'

camname = extractBetween(filepath,icam,icam+7);
if(isempty(nwb.processing.keys))
    DLCXYPosition = types.core.Position(char(camname),jointsXY);
else
    DLCXYPosition = nwb.processing.get('DLC_2D_XYpos').nwbdatainterface.get('DLCXYPosition');
    DLCXYPosition.spatialseries.set(char(camname), jointsXY);
end


% create processing module
DLC_2D_mod = types.core.ProcessingModule(...
    'description',  'processed video data using 2-D deep lab cut');

% add the Position object (that holds the SpatialSeries object)
DLC_2D_mod.nwbdatainterface.set(...
    'DLCXYPosition', DLCXYPosition);

% add the processing module to the NWBFile object, and name it "behavior"
nwb.processing.set('DLC_2D_XYpos',DLC_2D_mod);



end

