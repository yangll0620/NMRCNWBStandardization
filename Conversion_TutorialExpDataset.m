clear
%% matnwb path for windows or mac notebook
if ispc % PC (Windows) in LRB 411
    dropboxpath = 'E:'; 
end
if ismac % mac notebook
    dropboxpath = '/Users/linglingyang';
end
projectpath = fullfile(dropboxpath, 'Dropbox', 'NMRC', 'Projects', ...
    'DataStorageAnalysisArchitecture', 'NWBtest');
matnwbpath = fullfile(projectpath, 'matnwb');
datasetpath = fullfile(projectpath, 'dataset', 'TutorialExpData'); %.....\NWBtest\dataset\TutorialExpData\

%% Script start here
addpath(matnwbpath)

%% script configuration
animal = 'ANM255200';
session = '20140910';

identifier = [animal '_' session];

downloadpath = fullfile(datasetpath, 'downloaddata');
metadata_loc = fullfile(downloadpath,'metadata', ['meta_data_' identifier '.mat']);
datastructure_loc = fullfile(downloadpath,'data_structure_files',...
    ['data_structure_' identifier '.mat']);
rawdata_loc = fullfile(downloadpath, [identifier '.tar']);

outloc = fullfile(datasetpath, 'out');

if 7 ~= exist(outloc, 'dir')
    mkdir(outloc);
end

source_file = [mfilename() '.m'];
[~, source_script, ~] = fileparts(source_file);

%% General Information
nwb = nwbfile();
nwb.identifier = identifier;

loaded = load(metadata_loc, 'meta_data');
meta = loaded.meta_data;

%experiment-specific treatment for animals with the ReaChR gene modification
isreachr = any(cell2mat(strfind(meta.animalGeneModification, 'ReaChR')));

% Device objects are essentially just a list of device names.  
% probe hardware name
probetype = meta.extracellular.probeType{1};
probeSource = meta.extracellular.probeSource{1};
deviceName = [probetype ' (' probeSource ')'];
nwb.general_devices.set(deviceName,...
    types.core.Device());

if isreachr
    laserName = 'laser-594nm (Cobolt Inc., Cobolt Mambo 100)';
else
    laserName = 'laser-473nm (Laser Quantum, Gem 473)';
end
nwb.general_devices.set(laserName, types.core.Device());
% use the formatStruct function which is provided in the tutorials directory
addpath(fullfile(matnwbpath, 'tutorials')); 

recordingLocation = meta.extracellular.recordingLocation{1};
egroup = types.core.ElectrodeGroup(...
    'device', types.untyped.SoftLink(['/general/devices/' deviceName]));
    
nwb.general_extracellular_ephys.set(deviceName, egroup);

egroupPath = ['/general/extracellular_ephys/' deviceName];
etrodeNum = length(meta.extracellular.siteLocations);
etrodeMat = cell2mat(meta.extracellular.siteLocations .');
emptyStr = repmat({''}, etrodeNum,1);
dtColNames = {'x', 'y', 'z', 'imp', 'location', 'filtering','group',...
    'group_name'};
% you can specify column names and values as key-value arguments in the DynamicTable
% constructor.
dynTable = types.core.DynamicTable(...
    'colnames', dtColNames,...
    'description', 'Electrodes',...
    'id', types.core.ElementIdentifiers('data', int64(1:etrodeNum)),...
    'x', types.core.VectorData('data', etrodeMat(:,1),...
        'description', 'the x coordinate of the channel location'),...
    'y', types.core.VectorData('data', etrodeMat(:,2),...
        'description', 'the y coordinate of the channel location'),...
    'z', types.core.VectorData('data', etrodeMat(:,3),...
        'description','the z coordinate of the channel location'),...
    'imp', types.core.VectorData('data', zeros(etrodeNum,1),...
        'description','the impedance of the channel'),...
    'location', types.core.VectorData('data',...
        repmat({recordingLocation}, etrodeNum, 1),...
        'description', 'the location of channel within the subject e.g. brain region'),...
    'filtering', types.core.VectorData('data', emptyStr,...
        'description', 'description of hardware filtering'),...
    'group', types.core.VectorData('data',...
        repmat(types.untyped.ObjectView(egroupPath), etrodeNum, 1),...
        'description', 'a reference to the ElectrodeGroup this electrode is a part of'),...
    'group_name', types.core.VectorData('data', repmat({probetype}, etrodeNum, 1),...
        'description', 'the name of the ElectrodeGroup this electrode is a part of'));

nwb.general_extracellular_ephys_electrodes = dynTable;

%% raw acquisition data
untarLoc = fullfile(downloadpath,identifier);
if 7 ~= exist(untarLoc, 'dir')
    untar(rawdata_loc, downloadpath);
end
rawfiles = dir(untarLoc);
rawfiles = fullfile(untarLoc, {rawfiles(~[rawfiles.isdir]).name});

nrows = length(nwb.general_extracellular_ephys_electrodes.id.data);
tablereg = types.core.DynamicTableRegion(...
    'description','Relevent Electrodes for this Electrical Series',...
    'table',types.untyped.ObjectView('/general/extracellular_ephys/electrodes'),...
    'data',(1:nrows) - 1);
objrefs = cell(size(rawfiles));
trials_idx = nwb.intervals_trials;
endTimestamps = trials_idx.start_time.data;

for i = 1: length(rawfiles)
    tnumstr = regexp(rawfiles{i}, '_trial_(\d+)\.mat$', 'tokens', 'once');
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end

