function [nwb] = convraw_vid2nwb(vidfilepath, varargin)

% Example usage:
% 
% vidfilepath = 'Y:\\yll\\NMRCNWB\\rawvideofiles';
% nwb = convraw_vid2nwb(vidfilepath,'nwb_in', nwb, 'animal', 'Barb');
% nwb = convraw_vid2nwb(vidfilepath);

% Inputs:
% vidfilepath ---- the folder containing the video file (.avi)

% Name-Value:
% 'nwb_in': input an exist nwb, default [] create a new nwb 
% 'identifier': input identifier for nwb, default ''




% Outputs:
% nwb             ---- nwb structure containing raw video



% parse params
p = inputParser;
addParameter(p, 'nwb_in', [], @(x) isa(x, 'NwbFile'));
addParameter(p, 'identifier', '', @ischar);
parse(p,varargin{:});
nwb = p.Results.nwb_in;

% Create new file if not exist
if isempty(nwb)

    %get identifier,session_description,and session_description
    identifier = input("enter identifier information ");
    session_description = input("enter session description ");
    session_date = input("enter session date ");
    session_starttime = input("enter session start time ");

    session_start_time = datevec([session_date session_starttime]);

    nwb = NwbFile(...
        'identifier', identifier, ...
        'session_description', session_description, ...
        'session_start_time', datestr(session_start_time, 'yyyy-mm-dd HH:MM:SS'));

    clear identifier session_description session_start_time

end



%object containing video data
vidObj = VideoReader(vidfilepath);

%creating a ImageSeries Object to contain raw video link
vid_raw = types.core.ImageSeries();
vid_raw.external_file = vidfilepath;
vid_frame_data = read(vidObj);
vid_raw.data = vid_frame_data; %read(vidObj) reads all vid frames at once
vid_raw.starting_time_rate = vidObj.FrameRate;
vid_raw.data_unit = 'pixels';
vid_raw.external_file_starting_frame = 0; %If there is a single external file that holds all of the frames of the ImageSeries (and so there is a single element in the 'external_file' dataset), then this attribute should have value [0]

%relevant attributes
vid_raw.addAttribute('height',vidObj.Height);
vid_raw.addAttribute('width', vidObj.Width);
vid_raw.addAttribute('framerate', vidObj.FrameRate);


%if video data is unavailable from video reader just assign video data to empty
TF = isempty(vid_raw.data);

if TF == 1
   vid_raw.data = [];
end


% set ImageSeries into nwb.acqusition
nwb.acquisition.set(nwb.identifier, vid_raw);

end




