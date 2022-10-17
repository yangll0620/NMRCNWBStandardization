function conv2nwb_using_mastersheet(googleSheetID, sheet_name, driver, dateofexp, tdtblock, savefolder)
%
%   using master sheet to convert data to NWB structure
%
%   Example usage:
%
%       conv2nwb_using_mastersheet('1ITkEPoIkQDr1RebfI4BtUdNK8UNbl8Bvpx-XbvH-v68','MasterList', 'Z:', '031722', 1, 'C:\NWB');
%
%Inputs:
%
%   googleSheetID: the google sheet ID. The string between '/d/' and '/edit#gid=0'
%
%   sheet_name: sheet name (e.g 'MasterList')
%
%   driver: the driver name for network drive (e.g Z:)
%
%   dateofexp: the exact date of the files (mmddyy)
%
%   block: the tdt block number
%
%   savefolder: save the NWB data to savefolder

url_name = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
    googleSheetID, sheet_name);
tbl = webread(url_name);

% selected the rows for dateofexp and tdtblock
tbl_selected = tbl(contains(tbl.OutputFolderName, dateofexp) & (tbl.TDTBlock==tdtblock) , :);

for ti = 1 : height(tbl_selected)
    folderName = tbl_selected.OutputFolderName{ti};
    
    %get animal name from folderName
    tmp = strsplit(folderName,'_');
    animal = tmp{1};
    clear tmp
    
    % create a new nwbfile
    nwb = NwbFile();
    
    %identifier for nwb file, formatted
    identifier = strcat(folderName,'_TDTbk',num2str(tdtblock),'_', tbl_selected.BriefDescription{ti}); 
    
    outNwbFile = fullfile(savefolder, [identifier '.nwb']);
    if exist(outNwbFile, 'file')
        disp(['An exist nwb file ' outNwbFile  ' found and deleted!'])
        fprintf('\n\n');
        delete(outNwbFile);
    end
    
    % convert raw tdt section
    if true
        rawTDTfolder = tbl_selected.rawTDTfolder{ti};
        TDTSessionName = tbl_selected.TDTSessionName{ti};
        rawtdtpath = strcat(rawTDTfolder, TDTSessionName, ['\Block-' num2str(tdtblock)]);
        if isunix
            rawtdtpath = strrep(rawtdtpath, '\', '/');
        end
        rawtdtpath = fullfile(driver, rawtdtpath);
        
        disp(['   reading raw tdt .....'])
        tdt = TDTbin2mat(rawtdtpath);
        
        disp(['   converting raw tdt to NWB.....'])
        nwb = convraw_tdt2nwb(tdt, 'nwb_in', nwb, 'animal', animal); % change the animal name accordingly
        clear rawTDTfolder TDTSessionName rawtdtpath
    end
    
    
    % convert cleaned MA
    if(strcmp(tbl_selected.MACleanedFileName(ti),'_cleaned') & strcmp(tbl_selected.ANCExported_(ti),'ANC exported'))
        fprintf('\nconverting cleaned MA to NWB.....');
        
        %full path for MA anc and trc_cleaned files on the server
        MApath = strcat(tbl_selected.rawMAfolder{ti},'\',tbl_selected.MASessionFolder{ti},'\',tbl_selected.MASessionName{ti},num2str(tbl_selected.MAFile(ti)));
        rawancfile = strcat(MApath, '.anc');
        rawtrcfile = strcat(MApath,'_cleaned.trc');

        if isunix
            rawancfile = strrep(rawancfile, '\', '/');
            rawtrcfile = strrep(rawtrcfile, '\', '/');
        end
        rawancfile = fullfile(driver, rawancfile);
        rawtrcfile = fullfile(driver, rawtrcfile);
        
        %put MA info into nwb by file path
        nwb = convraw_ma2nwb(rawancfile, rawtrcfile, 'nwb_in', nwb, 'identifier', identifier);
        
        clear MApath rawancfile rawtrcfile
    end
    
    
    % eye tracking data
    EyeTracking = tbl_selected.EyeTracking{ti};
    if(~isempty(EyeTracking))
        fprintf('\n converting raw Eye tracking data to NWB.....')
        
        %full path for Eyetracking on the server
        rawTDTfolder = tbl_selected.rawTDTfolder{ti};
        if isunix
            rawTDTfolder = strrep(rawTDTfolder, '\', '/');
        end
        rawFolder = fileparts(rawTDTfolder);
        EyeTPath = fullfile(driver, rawFolder, [animal ' Eyetracking'], [tbl_selected.EyeTracking{ti} '.txt']);
        
        %put MA info into nwb by file path
        nwb = convprocessed_eye2nwb(EyeTPath, 'nwb_in', nwb, 'identifier', identifier);
        
        clear rawTDTfolder rawFolder EyeTPath
    end
    
    
    %export derived nwb
    if ~exist(savefolder, 'dir')
        mkdir(savefolder)
    end
    
    fprintf(['\n...Exporting NWB file to ' outNwbFile ' ...'])
    nwbExport(nwb, outNwbFile);
    
end
end



