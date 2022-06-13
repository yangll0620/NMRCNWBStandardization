function [video_data, framerate, height, width] = readnwb_rawvid(nwb)
%  readnwb_rawvideo to read raw video data. 
% 
% 
%  Example:
%
%           videodata = readnwb_rawvideo(nwb);
% 
%  Input:
%           nwb         ----  NWB structure
%
%  Output:
%           video_data  -----  [vid_frame_data]
%           framerate
%           height
%           width


image_series = nwb.acquisition.get('ImageSeries');
video_data = image_series.data;
framerate = image_series.framerate;
height = image_series.height;
width = image_series.width;





 
