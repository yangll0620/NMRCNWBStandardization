% https://neurodatawithoutborders.github.io/matnwb/tutorials/html/ecephys.html#H_83ADFE4C

addpath(genpath(fullfile('C:\Users\lingling\Desktop\NMRCNWBStandardization', 'toolbox')))

rawtdtpath = fullfile('H:', 'My Drive', 'NMRC_umn', 'Projects', 'NWBStandardization', 'example_dataset', 'testData', ...
    'Barb', 'Recording','Raw', 'rawTDT', 'Barb-220324', 'Block-2');

animal = 'Barb';

testNwbfile = 'H:\My Drive\NMRC_umn\Projects\NWBStandardization\example_dataset\testData\test_Barb.nwb';

%% Code Start here
createNWB_fromtdt = false;
readNWB = true;



% create a new nwb structure from tdt 
if createNWB_fromtdt
    tdt = TDTbin2mat(rawtdtpath);
    nwb = convraw_tdt2nwb(tdt, 'animal', animal);
    if exist(testNwbfile, 'file')
        delete(testNwbfile);
    end
    nwbExport(nwb, testNwbfile);
end


% read nwb file
if readNWB
    nwb = nwbRead(testNwbfile);
end


%% description
nwb

nwb.acquisition










