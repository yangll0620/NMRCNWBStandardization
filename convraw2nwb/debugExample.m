function example_convraw2nwb()

% https://neurodatawithoutborders.github.io/matnwb/tutorials/html/ecephys.html#H_83ADFE4C

%% Add Path
curFolder = pwd;
[nwbpath,~,~] = fileparts(curFolder);
addpath(genpath(nwbpath));

%% Download example dataset
[outfolder, ~, ~] = fileparts(nwbpath);





rawtdtpath = fullfile('H:', 'My Drive', 'NMRC_umn', 'Projects', 'NWBStandardization', 'example_dataset', 'testData', ...
    'Barb', 'Recording','Raw', 'rawTDT', 'Barb-220324', 'Block-2');

animal = 'Barb';

testNwbfile = 'H:\My Drive\NMRC_umn\Projects\NWBStandardization\example_dataset\testData\test_Barb.nwb';

%% Code Start here
createNWB_fromtdt = false;
readNWB = true;


% create a new nwb structure from tdt 
if createNWB_fromtdt
    disp('... Reading tdt data .....')
    tdt = TDTbin2mat(rawtdtpath);
    nwb = convraw_tdt2nwb(tdt, 'animal', animal);
    toc
    if exist(testNwbfile, 'file')
        delete(testNwbfile);
    end
    tic
    nwbExport(nwb, testNwbfile);
    toc
end


% read nwb file
if readNWB
    tic
    nwb = nwbRead(testNwbfile);
    toc
end


%% description
nwb

nwb.acquisition










