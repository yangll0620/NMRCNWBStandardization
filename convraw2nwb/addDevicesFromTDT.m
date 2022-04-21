function nwb = addDevicesFromTDT(nwb, tdt)
% added devices from tdt data


%     STPD: [1×1 struct]
%     TASK: [1×1 struct]
%     EYET: [1×1 struct]
%     DBSS: [1×1 struct]
%     DBSG: [1×1 struct]
%     UDLP: [1×1 struct]
%     UMCX: [1×1 struct]
%     UPMC: [1×1 struct]

stream_names = fields(tdt.streams);
for stri = 1:length(stream_names)    
    stream_name = stream_names{stri};
    
    if strcmpi(stream_name, 'STPD')
        devName = 'TDT-Startpad';
        dev = types.core.Device('description', 'TDT recorded startpad data',...
            'manufacturer', 'Lanbao CR18SCN08DNO Capacitive Proximity Sensor - 8mm, https://www.phidgets.com/?tier=3&catid=13&pcid=11&prodid=397');
        nwb.general_devices.set(devName, dev);
        
        clear stream_name devName dev
        continue;
        
    elseif strcmpi(stream_name, 'TASK')
        devName = 'TDT-TaskStimulus';
        dev = types.core.Device('description', 'TDT recorded 4 bits event code from COT or GoNogo Task Prpgram');
        nwb.general_devices.set(devName, dev);
        
        clear stream_name devName dev
        continue;
        
    elseif strcmpi(stream_name, 'EYET')
        devName = 'TDT-EyeTracking';
        dev = types.core.Device('description', 'TDT recorded x, y position data from eye tracking system');
        nwb.general_devices.set(devName, dev);
        
        clear stream_name devName dev
        continue;
        
    end
    
    % Utah Array, DBSLead and GrayMatter case
    switch stream_name(1)
        case 'U' 
            devName = 'Utah Array';
            dev = types.core.Device();
            nwb.general_devices.set(devName, dev);
            
        case 'D' 
            devName = 'DBS Lead';
            dev = types.core.Device();
            nwb.general_devices.set(devName, dev);
            
        case 'G'
            devName = 'Gray Matter';
            dev = types.core.Device();
            nwb.general_devices.set(devName, dev);
            
        otherwise
            disp('can not extract right device name (Utah Array, DBS Lead or Gray Matter) from tdt stream name')
            continue;
    end

    clear stream_name 
end