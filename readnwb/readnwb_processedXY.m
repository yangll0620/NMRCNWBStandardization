function [posTable] = readnwb_processedXY(nwb,cam_idx)
% A function that takes in the nwb file and camera's index and returns a table that contains the position table
%   Input:
%       nwb: an nwbfile object
%       cam_idx: the index of the camera, (eg.1,2,3)
%   Output:
%       xyTable: a table that contains all position data with appropriate column names like "hand_x", "elbow_y", and "wrist_likelihood"
    
    camname = strcat("camera-",string(cam_idx));
    spatialseries = nwb.processing.get('DLC_2D_XYpos').nwbdatainterface.get('DLCXYPosition').spatialseries.get(camname);
    posTable = array2table(spatialseries.data.load);
    varNames = strsplit(spatialseries.comments,';');
    posTable.Properties.VariableNames = varNames;
      
end