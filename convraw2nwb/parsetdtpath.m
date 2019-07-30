function [animal, blocknum] = parsetdtpath(tdtpath)
% parsetdtpath return the parsed animal name and block number from tdtpath
%
% Input:
%       tdtpath: the absoluate tdt path with structure of Animals\Bug\....\block-1 or
%       Animals2\Bug\...\block-1
%
% Outputs:
%       animal: the parsed animal name, i.e. 'bug', 'pinky', et.al
%       blocknum: the parsed tdt block number

% convert to lowercase
tdtpath = lower(tdtpath);

% split tdtpath into string array, i.e. separate subfolder names
if ispc
    foldernames = split(tdtpath, '\');
end

if isunix
    foldernames = split(tdtpath, '/');
end

% parse animal name
animal = [];
for i = 1: length(foldernames)
    % match substring 'animals' or animals2
    if ~isempty(regexp(foldernames{i}, 'animals\w*', 'match'))
        
        % animal name is the next subfolder name
        if i + 1<= length(foldernames)
            animal = foldernames{i+1};
            animali = i + 1;
        end
        break;
    end
end

% parse block number
for i = animali : length(foldernames)
    if ~isempty(regexp(foldernames{i}, 'block-\d*', 'match'))
        str = foldernames{i};
        blocknum = str2num(str(1+length('block-'):end));
    end
end
