addpath('..\util')
dbpath = dropboxpath();
projectpath = fullfile(dbpath, 'NMRC', 'Projects', ...
    'DataStorageAnalysisArchitecture', 'NWBtest');
datasetpath = fullfile(projectpath, 'dataset');



%% test video file -- MP4
folder = fullfile(datasetpath, 'Bug','Data', 'ExpData', 'Raw', 'Bug-181130', 'GaitTask', 'SideVideo');
videoname = fullfile(folder, 'CPB09_113018.mp4');
vobj = VideoReader(videoname);
% currAxes = axes;
% nframe=0;
nframes = ceil(vobj.FrameRate*vobj.Duration);
vframes = zeros(nframes, vobj.Height, vobj.Width, 3); % 3 for RGB
while hasFrame(v)
    iframe = iframe + 1;
    vframes(iframe, :,:,:) = readFrame(vobj); % video is an H (height_image) x W (width_image) x B matrix, B:  the number of bands in the image
%     image(vFrame, 'Parent', currAxes);
%     currAxes.Visible = 'off';
%     pause(1/v.FrameRate);
end
nframes
iframe
%%
% %% test table
% LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};
% Age = [38;43;38;40;49];
% Smoker = logical([1;0;1;0;1]);
% Height = [71;69;64;67;64];
% Weight = [176;163;131;133;119];
% BloodPressure = [124 93; 109 77; 125 83; 117 75; 122 80];
% 
% T = table(LastName,Age,Smoker,Height,Weight,BloodPressure);
% 
% T = [T; {'Yang', 33, 0, 68, 100, [100 70]}];
% T = [T; {'Jin', 30, NaN, NaN, NaN, [NaN NaN]}];