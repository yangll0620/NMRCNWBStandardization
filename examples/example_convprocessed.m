%% This script demonstrate how to
%
%   1. read exist Nwb file
%   2. convert processed deeplabcut xy trajectory data to nwb structure
%   3. export nwb to Nwb file

%% Add Path
curFolder = pwd;
[nwbpath,~,~] = fileparts(curFolder);
addpath(genpath(nwbpath));


%% Code Start here

[outcodepath,~,~] = fileparts(nwbpath);

read_existNwbFile = false;
conv_processedDLCxy2Nwb = true;
conv_processedEyeTracking = true;
export_NwbFile = false;

if read_existNwbFile
    
    % the used test_Barb.nwb file can be download at https://drive.google.com/file/d/14IWrm_9LjOmuEehworaPmePUoKvBO7HB/view?usp=sharing
    % changed the existNwbfile to your own exist nwb file path
    existNwbfile = fullfile(outcodepath, 'NMRCNWB_TestData', 'test.nwb');
    
    disp('... Reading existing Nwb file .....')
    nwb = nwbRead(existNwbfile);
end

if conv_processedDLCxy2Nwb

    % change the filepath to your own filepath
    filepath = fullfile(outcodepath, 'NMRCNWB_TestData', 'DLCXYdata', 'v-20220606-130339-camera-1DLC_resnet50_DLC-GoNogo-Set10-camera1Jun22shuffle1_30000.csv');
    
    identifier = input("Enter the appropriate identifier(eg.'animal yyyymmdd '_block_' blockNumber',quotation marks required): ");
    

    if exist('nwb','var') && exist('identifier','var')
        [nwb] = convprocessed_dlc2nwb(filepath, 'nwb_in', nwb, 'identifier', identifier);
    elseif exist('nwb','var')
        [nwb] = convprocessed_dlc2nwb(filepath, 'nwb_in', nwb);
    elseif exist('identifier','var')
        [nwb] = convprocessed_dlc2nwb(filepath, 'identifier', identifier); % 'identifier' = ''; nwb.identifier = '';
    else
        disp('Input parameter "identifier" is missing.');
    end

    % get position table (posTable) from nwb file
    cam_idx = input("Enter camera index (it should be an integer 1/2 for our example): ");
    posTable = readnwb_processedXY(nwb,cam_idx); 
end

if conv_processedEyeTracking

    % change the filepath to your own filepath
    filepath = fullfile(outcodepath, 'NMRCNWB_TestData', 'DLCXYdata', 'v-20220606-130339-camera-1DLC_resnet50_DLC-GoNogo-Set10-camera1Jun22shuffle1_30000.csv');
    
    identifier = input("Enter the appropriate identifier(eg.'animal yyyymmdd '_block_' blockNumber',quotation marks required): ");
    

    if exist('nwb','var') && exist('identifier','var')
        [nwb] = conveyetracking2nwb(TrialDataEye,FileInfoBlock, 'nwb_in', nwb, 'identifier', identifier);
    elseif exist('nwb','var')
        [nwb] = conveyetracking2nwb(TrialDataEye,FileInfoBlock, 'nwb_in', nwb);
    elseif exist('identifier','var')
        [nwb] = conveyetracking2nwb(TrialDataEye,FileInfoBlock, 'identifier', identifier); % 'identifier' = ''; nwb.identifier = '';
    else
        disp('Input parameter "identifier" is missing.');
    end

    % get EyeTracking Table from nwb file
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