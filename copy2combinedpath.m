function copy2combinedpath(streamerpath, localpath, combinedTDTfilespath)
%%  copy files in streamer and local to a combined folder
%   just copy the files in streamer/local but not in combinedTDTfilespath
%   inputs: 
%           streamerpath: store the ch*.sev files 
%           localpath: store .Tbk, .Tdx, .tev et.al files,.avi files and StoresListing.txt
%           combinedTDTfilespath: combined path

if 7~= exist(combinedTDTfilespath, 'dir')
    mkdir(combinedTDTfilespath)
end
% copy files in streamerpath and localpath to combinedTDTfilespath
filesinstreamer = extractfield(dir(streamerpath), 'name');
filesinlocal = extractfield(dir(localpath), 'name');
filesincombined = extractfield(dir(combinedTDTfilespath), 'name');
filesin_streamer_not_combined = setdiff(filesinstreamer, filesincombined);
filesin_local_not_combined = setdiff(filesinlocal, filesincombined);
if ~isempty(filesin_streamer_not_combined) % copy files in streamer to combined
    filesinstreamer_copy = fullfile(streamerpath, filesin_streamer_not_combined);
    for i_file = 1: length(filesinstreamer_copy)
        copyfile(filesinstreamer_copy{i_file}, combinedTDTfilespath);
    end
end
if ~isempty(filesin_local_not_combined)
    filesinlocal_copy = fullfile(localpath, filesin_local_not_combined);
    for i_file = 1: length(filesinlocal_copy)
        copyfile(filesinlocal_copy{i_file}, combinedTDTfilespath);
    end
end