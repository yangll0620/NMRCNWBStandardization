%% This script demonstrate how to
%
%   1. read exist Nwb file
%   2. read 
%  
%     2-1 processed deeplabcut xy trajectory data from nwb structure
%       
%     2-2 processed spike data
%   
%   3. export nwb to Nwb file

%% Add Path
curFolder = pwd;
[nwbpath,~,~] = fileparts(curFolder);
addpath(genpath(nwbpath));


%% Code Start here

[outcodepath,~,~] = fileparts(nwbpath);

read_existNwbFile = true;
read_processedDLCxy2Nwb = true;
read_eyeTracking2nwb = true;
export_NwbFile = false;

if read_existNwbFile
    
    % the used test.nwb file can be download at https://drive.google.com/file/d/14IWrm_9LjOmuEehworaPmePUoKvBO7HB/view?usp=sharing
    % changed the existNwbfile to your own exist nwb file path
    existNwbfile = fullfile(outcodepath, 'NMRCNWB_TestData', 'test.nwb');
    
    disp('... Reading existing Nwb file .....')
    nwb = nwbRead(existNwbfile);
end

if read_processedDLCxy2Nwb

    cam_idx = 1; % it should be an integer 1/2 for the test.nwb;  this can be down from https://drive.google.com/file/d/14IWrm_9LjOmuEehworaPmePUoKvBO7HB/view?usp=sharing

    % get position table (posTable) from nwb file
    posTable = readnwb_processedXY(nwb,cam_idx); 
end

if read_eyeTracking2nwb

    % get eyetracking table from nwb file
    EyeTrackingTable = readnwb_processedEyeTracking(nwb);
end

if export_NwbFile
    outNwbFile = fullfile(outcodepath,  'NMRCNWB_TestData', 'outNwb.nwb');

    if ~exist('nwb', 'var')
        
        % the used test.nwb file can be download at https://drive.google.com/file/d/14IWrm_9LjOmuEehworaPmePUoKvBO7HB/view?usp=sharing
        testNwbfile = fullfile(outcodepath, 'NMRCNWB_TestData', 'test.nwb');

        nwb = nwbRead(testNwbfile);
    end

    if exist(outNwbFile, 'file')
        delete(outNwbFile);
    end

    disp(['...Exporting NWB file to ' outNwbFile ' ...'])
    nwbExport(nwb, outNwbFile);
end