%% Video Replay with Streaming Data
%
%  Import video and stream data into Matlab
%  Plot the video and stream
%  Good for replay analysis

%% Housekeeping
% Clear workspace and close existing figures. Add SDK directories to Matlab
% path.
close all; clear all; clc;
[MAINEXAMPLEPATH,name,ext] = fileparts(cd); % \TDTMatlabSDK\Examples
DATAPATH = fullfile(MAINEXAMPLEPATH, 'ExampleData'); % \TDTMatlabSDK\Examples\ExampleData
[SDKPATH,name,ext] = fileparts(MAINEXAMPLEPATH); % \TDTMatlabSDK
addpath(genpath(SDKPATH));

%% Importing the Data
% This example assumes you downloaded our
% <https://www.tdt.com/files/examples/TDTExampleData.zip example data sets>
% and extracted it into the \TDTMatlabSDK\Examples\ directory. To import your own data, replace
% 'BLOCKPATH' with the path to your own data block.
%
% In Synapse, you can find the block path in the database. Go to Menu --> History. 
% Find your block, then Right-Click --> Copy path to clipboard.
BLOCKPATH = fullfile(DATAPATH,'Subject1-211115-094936');
STREAM_STORE = 'x465A'; % single channel stream store name
VID_STORE = 'Cam1'; % video store name
CREATE_OUTPUT_VIDEO = 1; % set to 0 to skip writing the output video
VIDEO_OUTPUT_PATH = BLOCKPATH; % where the output video should go
data = TDTbin2mat(BLOCKPATH);

%%
% Read video file.
vvv = dir([BLOCKPATH filesep '*' VID_STORE '.avi']);
vid_filename = [vvv.folder filesep vvv.name];
fprintf('reading file %s\n', vid_filename);
myvideo = VideoReader(vid_filename);

%%
% Get data specs.
max_frames = length(data.epocs.(VID_STORE).onset);
max_ts = data.epocs.(VID_STORE).onset(end);
expected_fps = max_frames / max_ts;
max_x = max(size(data.streams.(STREAM_STORE).data));

%%
% Make array of images if we're outputting a video.
if CREATE_OUTPUT_VIDEO
     M(max_frames) = struct('cdata',[],'colormap',[]);
end

%%
% Create figure.
h = figure;
h.Position = [500 500 560 560];

%%
% The main loop.
tic
for k = 1:max_frames
    % grab one image
    im = readFrame(myvideo);
    
    subplot(3,1,[1 2])

    % plot it
    image(im)
    if k == 1
        % hide x and y pixel axes
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        set(gca,'nextplot','replacechildren')
    end
    recording_ts = data.epocs.(VID_STORE).onset(k);

    % set title
    title_text = sprintf('%s frame %d of %d, t = %.2fs', VID_STORE, k, max_frames, recording_ts);
    title(title_text);
    
    % plot stream in another subplot
    subplot(3,1,3)
    stream_ind = round(recording_ts * data.streams.(STREAM_STORE).fs);
    t = max_ts .* (1:stream_ind) ./ max_x;
    plot(t, data.streams.(STREAM_STORE).data(1:stream_ind), 'b', 'LineWidth', 2)
    if k == 1
        axis([0, max_ts, 0, max(data.streams.(STREAM_STORE).data)])
        grid on;
        title(STREAM_STORE)
        xlabel('time, s')
        ylabel('mV')
        set(gca,'nextplot','replacechildren') % maintains the axis properties next time, improves speed
    end

    % force the plot to update
    drawnow;
    
    if CREATE_OUTPUT_VIDEO
        M(k) = getframe(gcf); % get the whole figure
    end

    % slow down to match video fps
    expected_el = k / expected_fps;
    ddd = expected_el - toc;
    if ddd > 0, pause(ddd); end
end

disp('done playing')

%%
% Create the output video file of figure with same FPS as original.
if CREATE_OUTPUT_VIDEO
    out_file = [VIDEO_OUTPUT_PATH filesep strrep(vvv.name, '.avi', '_output.avi')];
    fprintf('writing video file %s\n', out_file);
    out_video = VideoWriter(out_file);
    out_video.FrameRate = expected_fps;
    open(out_video);
    for k = 1:max_frames
        writeVideo(out_video, M(k));
    end
    close(out_video)
end
