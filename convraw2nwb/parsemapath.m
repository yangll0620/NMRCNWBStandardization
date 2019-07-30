function [animal, dateofexp] = parsemapath(mapath)
% parsetdtpath return the parsed animal name and block number from mapath
%
% Input:
%       mapath: the absoluate tdt path with structure of Animals\Bug\....\MA20190111 or
%       Animals2\Bug\...\MA20190111
%
% Outputs:
%       animal: the parsed animal name, i.e. 'Bug', 'Pinky', et.al
%       dateofexp: the parsed date of experiment using datenum format


% convert to lowercase
mapath = lower(mapath);

% split mapath into string array, i.e. separate subfolder names
if ispc
    foldernames = split(mapath, '\');
end

if isunix
    foldernames = split(mapath, '/');
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

% parse date of experiment
dateofexp = [];
dateexpression = '(?<year>\d{4}+)(?<month>\d{2}+)(?<day>\d{2}+)';
for i = animali : length(foldernames)
    if ~isempty(regexp(foldernames{i}, dateexpression, 'match'))
        dateofexp = datenum(char(regexp(foldernames{i}, dateexpression, 'match')), 'yyyymmdd');
    end
end

