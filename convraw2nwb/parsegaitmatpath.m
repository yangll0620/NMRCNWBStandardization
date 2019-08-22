function [animal, dateofexp] = parsegaitmatpath(gaitmatpath)
% parsegaitmatpath return the parsed animal name and block number from mapath
% Y:\Animals2\Bug\Recording\Raw\Habit Trail\Gaitmat\20181128
%
% Example usage:
%       gaitmatpath = "Y:\Animals2\Bug\Recording\Raw\Habit Trail\Gaitmat\20181128"
%       
%       [animal, dateofexp] = parsegaitmatpath(gaitmatpath);
%
% Input:
%       gaitmatpath: the absoluate gaitmat path with structure of: 
%       Animals\Bug\....\Gaitmat\20181128
%
% Outputs:
%       animal: the parsed animal name, i.e. 'Bug', 'Pinky', et.al
%
%       dateofexp: the parsed date of experiment using datenum format


% convert to lowercase
gaitmatpath = lower(gaitmatpath);

% split mapath into string array, i.e. separate subfolder names
if ispc
    foldernames = split(gaitmatpath, '\');
end

if isunix
    foldernames = split(gaitmatpath, '/');
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

% dateexpression format yyyymmdd (e.g 20180219)
dateexpression = '(?<year>\d{4}+)(?<month>\d{2}+)(?<day>\d{2}+)';
for i = animali : length(foldernames)
    if ~isempty(regexp(foldernames{i}, dateexpression, 'match'))
        dateofexp = datenum(char(regexp(foldernames{i}, dateexpression, 'match')), 'yyyymmdd');
    end
end

