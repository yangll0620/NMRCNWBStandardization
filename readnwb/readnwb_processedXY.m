function [posTable] = readnwb_processedXY(nwb,cam_idx)
%
% A function that takes in the nwb file and camera's index and returns a table that contains the position table
%
%   Input:
%
%       nwb: an nwbfile object
%
%       cam_idx: the index of the camera, (eg.1,2,3)
%
%   Output:
%
%       xyTable: a table that contains all position data with appropriate column names like "hand_x", "elbow_y", and "wrist_likelihood"
    

    %get the camera name with input
    camname = strcat("camera-",string(cam_idx));


    spatialseries = nwb.processing.get('DLC_2D_XYpos').nwbdatainterface.get('DLCXYPosition').spatialseries.get(camname);


    %check the type of spatialseries.data type first and then get the table
    if(isa(spatialseries.data, "double"))
        posTable = array2table(spatialseries.data);
    else
        posTable = array2table(spatialseries.data.load);
    end


    %get variable names from Spatialseries object's comments
    varNames = strsplit(spatialseries.comments,';');
    posTable.Properties.VariableNames = varNames;
      
end