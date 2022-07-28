function [nwb] = convprocessed_dlc2nwb(processed_dlc,varargin)
% converts processed xy dlc data to nwb and xyTable
%
% Variable names:
%
%   processed_dlc: path of the file, can be obtained in jointsXY.description, stored as character
%
%   jointsXY: SpatialSeries object containing information from the processed_dlc file
%
%   DLCXYPosition: Position object that stores the SpatialSeries Object named jointsXY
%
%   DLC_2D_mod: ProcessingModule object that contains a description and Position object named DLCXYPosition, can be found at nwb.processing.DLC_2D_XYpos
%   
% 
% Example usage:
%       [nwb] = convprocessed_dlc2nwb(processed_dlc)
% 
% Inputs
%   
%   processed_dlc: processed dlc data using deep lab cut, required
%   
%   Name-Value (optional parameters): 
%
%       'nwb_in': input an exist nwb, default [] create a new nwb       
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

Mcell = readcell(processed_dlc);
xyTable = readtable(processed_dlc);
[~,colnum] = size(xyTable);



%creating a SpatialSeries Object of hand
jointsXY = types.core.SpatialSeries();
jointsXY.data = xyTable{:,:};
jointsXY.reference_frame = '(0,0) is the bottom left corner'; %not sure
jointsXY.description = char(processed_dlc);
%jointsXY.starting_time = processed_dlc(12:27); 
jointsXY.data_unit = 'pixels'; %not sure
jointsXY.starting_time_rate = 30;



varNames = strings(colnum,1);
varNames(1) = "timepoint";
for i = 2:colnum
    joint_name = Mcell{2,i};
    coord = Mcell{3,i};
    varNames(i) = strcat(joint_name,"_",coord);
    
end

jointsXY.comments = char(varNames);


%if no data exists, return
if isempty(jointsXY.data) == 1
   return;
end


%create position object and name it as 'camera-index'
icam = strfind(processed_dlc,"camera");
icam = icam(1);
camname = extractBetween(processed_dlc,icam,icam+7);
DLCXYPosition = types.core.Position(char(camname), jointsXY);


% create processing module
DLC_2D_mod = types.core.ProcessingModule(...
    'description',  'processed video data using 2-D deep lab cut');

% add the Position object (that holds the SpatialSeries object)
DLC_2D_mod.nwbdatainterface.set(...
    'DLCXYPosition', DLCXYPosition);

% add the processing module to the NWBFile object, and name it "behavior"
nwb.processing.set('DLC_2D_XYpos',DLC_2D_mod);



end

