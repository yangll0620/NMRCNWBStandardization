%% This script demonstrate how to
%
%   1. read exist Nwb file
%   2. convert raw tdt data to nwb structure
%   3. export nwb to Nwb file


%% Add Path
curFolder = pwd;
[nwbpath,~,~] = fileparts(curFolder);
addpath(genpath(nwbpath));


%% Code Start here

[outcodepath,~,~] = fileparts(nwbpath);

convert_from_mastersheet = true;
read_existNwbFile = true;
conv_rawtdt2Nwb = false;
conv_rawma2Nwb = false;
export_NwbFile = false;

if convert_from_mastersheet
    googleSheetID = '1ITkEPoIkQDr1RebfI4BtUdNK8UNbl8Bvpx-XbvH-v68';
    sheet_name = 'MasterList';
    driver = '/Volumes/GoogleDrive/.shortcut-targets-by-id/1rqT5kkedZTvqGoWwNhGrS4Wly_1OQxPZ/NMRCNWB_TestData/testData/';
    dateofexp = '031722';
    block = 1;
    conv2nwb_using_mastersheet(googleSheetID, sheet_name, driver, dateofexp, block);

   
end
if read_existNwbFile
    
    % the used test_Barb.nwb file can be download at https://drive.google.com/file/d/14IWrm_9LjOmuEehworaPmePUoKvBO7HB/view?usp=sharing
    % changed the existNwbfile to your own exist nwb file path
    existNwbfile = fullfile(outcodepath, 'NMRCNWB_TestData', 'testData', 'testNWBData', 'test.nwb');
    
    disp('... Reading existing Nwb file .....')
    nwb = nwbRead(existNwbfile);
end


if conv_rawtdt2Nwb

    % change the rawtdtpath to your own tdt path
    rawtdtpath = fullfile(outcodepath, 'NMRCNWB_TestData', 'testData',...
        'tdtData','Barb', 'Recording','Raw', 'rawTDT', 'Barb-220324', 'Block-2');

    disp('... Reading tdt data will take a while .....')
    tdt = TDTbin2mat(rawtdtpath);

    if exist('nwb', 'var')
        nwb = convraw_tdt2nwb(tdt, 'nwb_in', nwb, 'animal', 'Barb'); % change the animal name accordingly
    else
        nwb = convraw_tdt2nwb(tdt, 'animal', 'Barb'); % change the animal name accordingly
    end

end

if conv_rawma2Nwb

    % change the rawancfile and rawtrcfile to your own anc file path
    rawancfile = fullfile(outcodepath, 'NMRCNWB_TestData', 'testData','MAData','Bug_20210702_3.anc');
    rawtrcfile = fullfile(outcodepath, 'NMRCNWB_TestData', 'testData','MAData','Bug_20210702_3_cleaned.trc');
    
    defIdentifier = false;
    if defIdentifier
        identifier = 'Bug_20210702_Block_3';
    end
    
    if exist('nwb','var')
        [nwb] = convraw_ma2nwb(rawancfile,rawtrcfile, 'nwb_in', nwb);
    elseif exist('identifier','var')
        [nwb] = convraw_ma2nwb(rawancfile,rawtrcfile, 'identifier', identifier); % 
    end

    % get data_ma and timestamps_ma from nwb file
    [data_ma, timestamps_ma] = readnwb_rawmadata(nwb);
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









