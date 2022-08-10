function [EyeTrackingTable] = readnwb_processedEyeTracking(nwb)
%
% A function that takes in the nwb file and returns a table that contains the eyetracking information table
%
%   Input:
%
%       nwb: an nwbfile object
%
%
%   Output:
%
%       EyeTrackingTable: a table that contains all eyetracking data in the nwb file
    


    eyeTracking = nwb.processing.get('EyeTrackingInfo').nwbdatainterface.get('EyeTrackingPos').spatialseries.get('eyeTracking');

    %check the type of spatialseries.data type first and then get the table
    if(isa(eyeTracking.data, "double"))
        EyeTrackingTable = array2table(eyeTracking.data);
    else
        EyeTrackingTable = array2table(eyeTracking.data.load);
    end


    %get variable names from Spatialseries object's comments
    varNames = strsplit(eyeTracking.comments,';');
    EyeTrackingTable.Properties.VariableNames = varNames;
      
end

