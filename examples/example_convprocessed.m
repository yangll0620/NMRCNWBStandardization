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

read_existNwbFile = true;
conv_processedDLCxy2Nwb = true;
export_NwbFile = true;

if read_existNwbFile
    
    % the used test_Barb.nwb file can be download at https://drive.google.com/file/d/14IWrm_9LjOmuEehworaPmePUoKvBO7HB/view?usp=sharing
    % changed the existNwbfile to your own exist nwb file path
    existNwbfile = fullfile(outcodepath, 'NMRCNWB_TestData', 'test_Barb.nwb');
    
    disp('... Reading existing Nwb file .....')
    nwb = nwbRead(existNwbfile);
end

if conv_processedDLCxy2Nwb

    % change the processed_dlc to your own processed_dlc path
    processed_dlc = fullfile(outcodepath, 'NMRCNWB_TestData', 'DLCXYdata', 'v-20220606-130339-camera-1DLC_resnet50_DLC-GoNogo-Set10-camera1Jun22shuffle1_30000.csv');

    if exist('nwb', 'var')
        [nwb] = convprocessed_dlc2nwb(processed_dlc, 'nwb_in', nwb);
    else
        [nwb] = convprocessed_dlc2nwb(processed_dlc);
    end

    % get xyTable from nwb file
    icam = strfind(processed_dlc,"camera");
    icam = icam(1);
    camname = char(extractBetween(processed_dlc,icam,icam+7));

    
    spatialseries = nwb.processing.get('DLC_2D_XYpos').nwbdatainterface.get('DLCXYPosition').spatialseries.get(camname);
    xyTable = array2table(spatialseries.data);
    [~,colnum] = size(xyTable);

    varNames = strings(colnum,1);
    for i = 1:colnum
        varNames(i) = strtrim(convertCharsToStrings(spatialseries.comments(i,:)));
    end
    xyTable.Properties.VariableNames = varNames;
      
end

if export_NwbFile
    outNwbFile = fullfile(outcodepath,  'NMRCNWB_TestData', 'outNwb.nwb');

    if ~exist('nwb', 'var')
        
        % the used test_Barb.nwb file can be download at https://drive.google.com/file/d/14IWrm_9LjOmuEehworaPmePUoKvBO7HB/view?usp=sharing
        testNwbfile = fullfile(outcodepath, 'NMRCNWB_TestData', 'test_Barb.nwb');

        nwb = nwbRead(testNwbfile);
    end

    if exist(outNwbFile, 'file')
        delete(outNwbFile);
    end

    disp(['...Exporting NWB file to ' outNwbFile ' ...'])
    nwbExport(nwb, outNwbFile);
end