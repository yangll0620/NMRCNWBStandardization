function [animal, dateofexpStr, bktdt] = parsetdtpath(tdtpath)
% parsetdtpath return the parsed animal name and block number from tdtpath
%
% Input:
%       tdtpath: the absoluate tdt path with structure of ...\Barb-220303\Block-1 
%
% Outputs:
%       animal: the parsed animal name, i.e. 'Bug', 'Barb', et.al
%       dateofexpStr: date of experiment in format yymmdd, i.e 220303
%       bktdt: the parsed tdt block number


% parse animal name
tmp = regexp(tdtpath, '[a-zA-Z]*-[\d]{6}', 'match');
if length(tmp) ~= 1
    disp(['tdt folder path should have a folder name like Barb-220303']);
    animal = [];
    bktdt =[];
    dateofexpStr = [];
    return;
end
tmpstr = tmp{1};
animal = tmpstr(1:end-7);
dateofexpStr = tmpstr(end-5:end);
clear tmp tmpstr

% parse blocknum
tmp = regexp(lower(tdtpath), 'block-[\d]{1}', 'match');
if length(tmp) ~= 1
    disp(['tdt folder path should have a sub block folder name like Block-1']);
    animal = [];
    bktdt =[];
    dateofexpStr = [];
    return;
end
tmpstr = tmp{1};
bktdt = str2num(tmpstr(end));
clear tmp tmpstr
