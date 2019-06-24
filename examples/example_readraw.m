function example_readraw()
% example_readraw() demonstrates about how to read data from nwb structure
%
% first download the test.nwb file here: 
%  'https://drive.google.com/open?id=1rqT5kkedZTvqGoWwNhGrS4Wly_1OQxPZ'

nwbfile = 'test.nwb';
if ~exist(nwbfile)
    disp('Please first download the test.nwb file here:')
    disp('https://drive.google.com/file/d/1resIFv20QiY2mXc1mta-TE9_1xK6PVWj/view?usp=sharing')
end

nwb = nwbRead(nwbfile);

% read tdt electrode information
elec_tbl = readnwb_electrodes(nwb);

% read raw tdt neural data
chn_read = [1 5]; % read neural data of channels [1:5], default read all channels
idx_read = [100 1000]; % read the neural data of time stamps [100:1000], default read all time stamps 
neurdata = readnwb_rawtdtneurdata(nwb, chn_read, idx_read);

% read raw touch pad synchronization data
stpddata = readnwb_rawtdtstpddata(nwb);