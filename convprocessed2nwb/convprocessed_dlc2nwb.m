function [nwb] = convprocessed_dlc2nwb(filename,varargin)
%


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

M = readtable(filename);

%creating a SpatialSeries Object of hand
jointsXY = types.core.SpatialSeries();
jointsXY.data = M{:,2:end};
jointsXY.reference_frame = '(0,0) is the bottom left corner'; %ask ziling
jointsXY.starting_time = 0; %ask ziling
jointsXY.data_unit = 'pixels'; %ask ziling

%if no data exists, return
if isempty(jointsXY.data) == 1
   return;
end


%create position object
DLCXYPosition = types.core.Position('SpatialSeries', jointsXY);


% create processing module
DLC_2D_mod = types.core.ProcessingModule( ...
    'description',  'processed video data using 2-D deep lab cut');

% add the Position object (that holds the SpatialSeries object)
DLC_2D_mod.nwbdatainterface.set(...
    'DLCXYPosition', DLCXYPosition);

% add the processing module to the NWBFile object, and name it "behavior"
nwb.processing.set('DLC_2D_XYpos',DLC_2D_mod);


end

