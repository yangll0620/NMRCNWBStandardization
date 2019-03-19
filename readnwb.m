clear 
if 1 % script format
    animal = 'Bug';
    dateofExp = datenum('20181130','yyyymmdd');
    task = 'GaitTask';
    block = 1;
else % function format
    if nargin < 4
        animal = 'Bug';
    end
    if nargin < 3
        dateofExp = datenum('20181130','yyyymmdd');
    end
    if nargin < 2
        task = 'GaitTask';
    end
    if nargin < 1
        block = 1;
    end
end

datasetpath = getdatasetpath();
preprocedatapath = fullfile(datasetpath, animal, 'Data', 'ExpData', 'Preprocessed');
%% read data from nwb file
identifier = [animal '_' datestr(dateofExp,'yyyymmdd') '_' task '_Block' num2str(block)];
nwbloc = fullfile(preprocedatapath, animal,[animal '-' datestr(dateofExp, 'yymmdd')] ,task);
nwbdest = fullfile(nwbloc, [identifier '.nwb']);
nwb = nwbRead(nwbdest);


%% load acquistion TDT neural data
dataname = 'rawTDT';
datainf = nwb.acquisition.get(dataname);
data = datainf.data.load; % the actual stream data (n_temporal * n_chns)

etrodes = datainf.electrodes.data.load;

%% load Gaitmat video data (a link)
dataname = 'gaitvideo';
vids = nwb.acquisition.get(dataname);
gaitvideolink = convertCharsToStrings(char(vids.data.load));

%% load Gaitmat pressure data (a link)
dataname = 'pressure';
pressid = nwb.acquisition.get(dataname);
pressurelink = convertCharsToStrings(char(pressid.data.load));
