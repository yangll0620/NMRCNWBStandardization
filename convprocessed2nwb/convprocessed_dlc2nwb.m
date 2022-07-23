function [nwb,xyTable] = convprocessed_dlc2nwb(processed_dlc,varargin)
% converts processed xy dlc data to nwb and xyTable
% 
% Example usage:
%       [nwb,xyTable] = convprocessed_dlc2nwb(processed_dlc)
%       
%       eg. use xyTable.('handx') to get x coordinates of hand overtime
% 
% Inputs
%   
%   processed_dlc: processed dlc data using deep lab cut, required
%   
%   Name-Value (optional parameters): 
%
%       'nwb_in': input an exist nwb, default [] create a new nwb       
%
%       
%
% Output:
%       nwb       ---- nwb structure containing tdt information 
%       xyTable   ---- table that stores position data under appropriate column names


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
Mtable = readtable(processed_dlc);
[rownum,colnum] = size(Mtable);



%creating a SpatialSeries Object of hand
jointsXY = types.core.SpatialSeries();
jointsXY.data = Mtable{:,:};
jointsXY.reference_frame = '(0,0) is the bottom left corner'; %ask ziling
jointsXY.starting_time = 0; %ask ziling
jointsXY.data_unit = 'pixels'; %ask ziling



varNames = strings(colnum,1);
varNames(1) = "timepoint";
for i = 2:colnum
    joint_name = Mcell{2,i};
    coord = Mcell{3,i};
    colname = strcat(joint_name,coord);
    varNames(i) = colname;
    disp(varNames);
end

varTypes = strings(colnum,1);
for i = 1:colnum
    varTypes(i) = "double";
end

xyTable = table('Size',[rownum colnum],'VariableTypes',varTypes,'VariableNames',varNames);
xyTable(:,:) = Mtable(:,:);



%if no data exists, return
if isempty(jointsXY.data) == 1
   return;
end


%create position object
DLCXYPosition = types.core.Position('SpatialSeries', jointsXY);


% create processing module
DLC_2D_mod = types.core.ProcessingModule(...
    'description',  'processed video data using 2-D deep lab cut');

% add the Position object (that holds the SpatialSeries object)
DLC_2D_mod.nwbdatainterface.set(...
    'DLCXYPosition', DLCXYPosition);

% add the processing module to the NWBFile object, and name it "behavior"
nwb.processing.set('DLC_2D_XYpos',DLC_2D_mod);



end

