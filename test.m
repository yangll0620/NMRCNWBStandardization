clear 

%% test video files
videofile_avi = 'BugHabittrail-181130_Block-1_Cam2.avi';
videofile_mp4 = 'CPB10_113018.mp4';

obj_avi = VideoReader(videofile_avi);
obj_mp4 = VideoReader(videofile_mp4);

frame_avi = readFrame(obj_avi);

