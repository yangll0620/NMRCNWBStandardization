function devName = deviceName_extract(key, varargin)
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
%           'from' - state from which structure, one in {'fromtdt', 'fromEyet'}

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


mask = strcmpi(devName_pairs(:, 1), key);
if any(mask)
    devName = devName_pairs{mask, 2}; 
else
    devName = '';
    disp([key ': extracted empty device Name.'])
end

