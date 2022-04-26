function [devName, dev] = deviceName_extract(key, varargin)
%   extract device name using key
%
%
% Example usage:
%           devName = deviceName_extract('STPD', 'from', 'fromtdt');
%
%   Inputs:
%
%       key: string key word 
%
%       Name-Value: 
%           'from' - state from which structure, one in {'fromtdt', 'fromEyet'}, default 'fromtdt'

% parse params
p = inputParser;
addParameter(p, 'from', 'fromtdt', @isstr);
parse(p,varargin{:});
from = p.Results.from;


from_list = {'fromtdt', 'fromEyet'};

mask_from = strcmpi(from_list, from);
if ~any(mask_from)
    disp('from parameter should be one of ' )
    disp(from_list)
    devName = '';
    return;
end

tdtStream_devName_pairs = {'STPD', 'TDT-Startpad';...
                            'TASK', 'TDT-TaskStimulus';...
                            'EYET', 'TDT-EyeTracking';...
                            'U', 'Utah Array';....
                            'D', 'DBS Lead';...
                            'G', 'Gray Matter'};

                        
                        
if strcmpi(from_list(mask_from), 'fromtdt')
    devName_pairs = tdtStream_devName_pairs;
end


mask = strcmpi(devName_pairs(:, 1), key) | strcmpi(devName_pairs(:, 1), key(1));
if any(mask)
    devName = devName_pairs{mask, 2}; 
else
    devName = '';
    disp([key ': extracted empty device Name.'])
end

% dev 
switch devName
    case 'TDT-Startpad'
        dev = types.core.Device('description', 'TDT recorded startpad data',...
            'manufacturer', 'Lanbao CR18SCN08DNO Capacitive Proximity Sensor - 8mm, https://www.phidgets.com/?tier=3&catid=13&pcid=11&prodid=397');
    
    case 'TDT-TaskStimulus'
        dev = types.core.Device('description', 'TDT recorded 4 bits event code from COT or GoNogo Task Prpgram');
    
    case 'TDT-EyeTracking'
        dev = types.core.Device('description', 'TDT recorded x, y position data from eye tracking system');
        
    case 'Utah Array'
        dev = types.core.Device('description', 'Utah Array');
        
    case 'DBS Lead'
        dev = types.core.Device('description', 'Directional DBS Lead');
        
    case 'Gray Matter'
        dev = types.core.Device('description', 'Gray Matter');
        
    otherwise
        dev = [];
end
