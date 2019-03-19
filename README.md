manual:
1. datainf = nwb.acquisition.get('rawTDT');

datainf = 
    ElectricalSeries with properties electrodes: [1×1 types.core.DynamicTableRegion] 
    starting_time_unit: 'Seconds' 
    timestamps_interval: 1 
    timestamps_unit: 'Seconds' 
    comments: 'no comments' 
    control: [] 
    control_description: [] 
    data: [1×1 types.untyped.DataStub] 
    data_conversion: 1 
    data_resolution: 0 
    data_unit: 'volt' 
    description: 'no description' 
    starting_time: 0 
    starting_time_rate: 2.4414e+04 
    timestamps: [] 
    help: 'Stores acquired voltage data from extracellular recordings'

2. nwb.acquisition.keys: return the keys of nwb.acquisition
3. the uniform naming of the sidevideo and pressure files, currently:
   
   for date: 113018 
    CPB09.fsx                   CPB09_113018.mp4
    CPB10.fsx                   CPB10_113018.mp4
    CPB11.fsx                   CPB11_113018.mp4
    CPB12.fsx                   CPB12_113018.mp4
    CPB13.fsx                   CPB13_113018.mp4
    CPB14.fsx                   CPB14_113018.mp4

   for date: 120918 
    CPB15.fsx                   CPB15_120918.mp4
    CPB16.fsx                   CPB16_120918.mp4
    CPB17.fsx                   CPB17_120918.mp4
    CPB18.fsx                   CPB18_120918.mp4
    CPB19.fsx                   CPB19_120918.mp4
    CPB20.fsx                   CPB20_120918.mp4


4. nwb.acquisition.keys():
    'rawTDT',
    'gaitvideolink',
    'pressurelink'
    'facialvideolink', 