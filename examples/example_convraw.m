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

read_existNwbFile = true;
conv_rawtdt2Nwb = true;
export_NwbFile = true;

if read_existNwbFile
    
    % the used test_Barb.nwb file can be download at https://drive.google.com/file/d/14IWrm_9LjOmuEehworaPmePUoKvBO7HB/view?usp=sharing
    % changed the existNwbfile to your own exist nwb file path
    existNwbfile = fullfile(outcodepath, 'NMRCNWB_TestData', 'testData', 'testNWBData', 'test_tdt.nwb');
    
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









