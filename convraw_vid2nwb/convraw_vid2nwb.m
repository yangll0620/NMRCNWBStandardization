function [nwb] = convraw_vid2nwb(vidfilepath, nwb)

% Example usage:
% vidfilepath = 'Y:\\yll\\NMRCNWB\\rawvideofiles';
% nwb = convraw_vid2nwb(vidfilepath,data_unit,starting_time_rate, nwb);

% Inputs:
% vidfilepath ---- the folder containing the video file (.avi)
% nwb         ---- exist nwb structure(v1 will require an existing nwb
%                  structure)

% Outputs:
% nwb             ---- nwb structure containing raw video

%object containing video data
vidObj = VideoReader(vidfilepath);

%creating a ImageSeries Object to contain raw video link
vid_raw = types.core.ImageSeries();
vid_raw.external_file = vidfilepath;
vid_raw.data = [vidObj.NumFrames vidObj.Height vidObj.Width]; 
vid_raw.starting_time_rate = vidObj.FrameRate;
vid_raw.data_unit = 'pixels';
vid_raw.external_file_starting_frame = 0; %If there is a single external file that holds all of the frames of the ImageSeries (and so there is a single element in the 'external_file' dataset), then this attribute should have value [0]


%if video data is unavailable from video reader
TF = isempty(vid_raw.data);
if TF == 1
    fir_dim = input("Enter frames of video file");
    sec_dim = input("Enter height of video file");
    thir_dim = input("Enter width of video file");

    vid_raw.data = [fir_dim sec_dim thir_dim];

    vid_raw.starting_time_rate = input("Enter the video frame rate");

end


% set ImageSeries into nwb.acqusition
nwb.acquisition.set('ImageSeries', vid_raw);

end




