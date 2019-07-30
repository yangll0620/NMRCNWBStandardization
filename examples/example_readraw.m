function example_readraw()
% example_readraw() demonstrates about how to read data from nwb structure
%
% first download the test.nwb file here: 
%  'https://drive.google.com/open?id=1rqT5kkedZTvqGoWwNhGrS4Wly_1OQxPZ'

nwbfile = 'test.nwb';
if ~exist(nwbfile)
    disp('Please first download the test.nwb file and copy it to this folder.')
    disp('https://drive.google.com/open?id=1rqT5kkedZTvqGoWwNhGrS4Wly_1OQxPZ')
end

% Reads the nwbfile  and returns an nwbfile object representing its contents.
nwb = nwbRead(nwbfile);

% read tdt electrode information to elec_tbl
elec_tbl = readnwb_electrodes(nwb);
disp(elec_tbl)

% read raw tdt neural data
chn_read = [1 5]; % read neural data of channels [1:5], default read all channels
idx_read = [100 1000]; % read the neural data of time stamps [100:1000], default read all time stamps 
neurdata = readnwb_rawtdtneurdata(nwb, chn_read, idx_read);

% read raw touch pad synchronization data
stpddata = readnwb_rawtdtstpddata(nwb);