function [data, channels, fs, eventname]= tdt2matlab_activeX(rawtdtpath)
%% read data from tdt file using activeX, can only be used on Windows.
%
% outputs:
%       data: time series neural data (Matrix: n_chn * n_temporal)
%       channels: channel information (vector: 1 * n_chn)
%       eventname: event name (i.e. 'BUGG')
%       fs: sample rate

% input:
%       rawtdtpath: the tdt file path (i.e. '\raw\bug\bug-190111\chairtask\rawtdt\Block-1')

[tdttank, blockname]= fileparts(rawtdtpath);

ttx = actxcontrol('TTank.X');
if ~ttx.ConnectServer('Local','Me') % TTank Server: 'Local', Our name: 'Me'
    error('ConnectServer fails')
end
if ~ttx.OpenTank(tdttank,'R') % 'R': open the tank as read-only
    error('OpenTank fails')
end
if ~ttx.SelectBlock(blockname)
    error('SelectBlock fails')
end

ch1file = dir(fullfile(rawtdtpath, '*_ch1.sev'));
ind1 = strfind(ch1file.name, ['Block-']);
ind2 = strfind(ch1file.name, '_ch1');
eventname = ch1file.name(ind1+8: ind2-1);

curblocknotes = ttx.CurBlockNotes;

inds_item = strfind(curblocknotes, '[STOREHDRITEM]');
ind_event = strfind(curblocknotes, ['NAME=StoreName;TYPE=T;VALUE=' eventname]);
if isempty(ind_event)
    % i.e. VALUE = BUGG does not exist
    error(['no eventname = ' eventname]);
    return;
end
indevent = inds_item(find(inds_item<ind_event,1,'last')):inds_item(find(inds_item>ind_event,1,'first'))-2;
eventnotes = curblocknotes(indevent);

% extract fs
fsnote = char(regexp(eventnotes,'NAME=SampleFreq;[A-Z,=]+;VALUE=[0-9,.]+;','match'));
fsvastr = char(regexp(fsnote, 'VALUE=.*;','match')); % fsvastr = 'VALUE=24414.062500;'
fs = str2num(fsvastr(strfind(fsvastr,'=')+1 : strfind(fsvastr, ';')-1));

% extract channels
channote = char(regexp(eventnotes,'NAME=NumChan;[A-Z,=]+;VALUE=[0-9]+;','match'));
chanvastr = char(regexp(channote, 'VALUE=[0-9]+;','match')); % chanvastr = 'VALUE=112;'
numchan = str2num(chanvastr(strfind(chanvastr,'=')+1 : strfind(chanvastr, ';')-1));
channels = [1:numchan];

% extract data
ttx.SetGlobalV('T1',0); % the start time in seconds, default = 0.0
ttx.SetGlobalV('T2',0); % the stop time in seconds, default = 0.0 meaning to the end of the block
ttx.SetGlobalV('WavesMemLimit', 1024^3);

% too big to read data of all channel, thus read data of 1 channel each time
for chni = 1: numchan
    ttx.SetGlobalV('Channel',chni); % default=0, meaning all channels
    data1ch = ttx.ReadWavesV(eventname); % data1ch: time series data from 1 channel, (numtemporal * 1)
    if chni == 1
        numtemporal = length(data1ch);
        data = zeros(numchan, numtemporal);
    end
    data(chni, :) = data1ch;
    clear data1ch
end

ttx.CloseTank();
ttx.ReleaseServer();


