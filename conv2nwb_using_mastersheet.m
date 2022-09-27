function conv2nwb_using_mastersheet(googleSheetID, sheet_name, driver, dateofexp, block)
% 
%   using master sheet to convert data to NWB structure
%
%   Example usage:
%       
%       conv2nwb_using_mastersheet('1ITkEPoIkQDr1RebfI4BtUdNK8UNbl8Bvpx-XbvH-v68','MasterList', 'Z:', '031722', 1);
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
%   block: the block number

url_name = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
    googleSheetID, sheet_name);
tbl = webread(url_name);
[nrow,~] = size(tbl);

for i = 1 : nrow
    if contains(tbl.OutputFolderName(i),dateofexp) && (tbl.TDTBlock(i)==block)

        % proceed only when the it has been cleaned
        folderName = string(tbl.OutputFolderName(i));
        if(~isempty(folderName))
        
            % create a new nwbfile
            nwb = NwbFile();
        
            %full path for tdt files on the server
            rawtdtpath = strcat(string(tbl.rawTDTfolder(i)),string(tbl.TDTSessionName(i)),'\Block-', num2str(tbl.TDTBlock(i)));
            if isunix
                rawtdtpath = strrep(rawtdtpath, '\', '/');
            end
            rawtdtpath = convertStringsToChars(fullfile(driver, rawtdtpath));
        
            %get identifer by extracting info
            identifier = strcat(folderName,'_TDTbk',num2str(tbl.TDTBlock(i)),'_',string(tbl.BriefDescription(i))); %identifier for nwb file, formatted
            identifier = convertStringsToChars(identifier);
        
            %get animal name from identifier
            parse_id = strsplit(identifier,'_');
            animal = parse_id{1};
        
        
            %put tdt info into nwb by tdt filepath
            tdt = TDTbin2mat(rawtdtpath);
            
            nwb = convraw_tdt2nwb(tdt, 'nwb_in', nwb, 'animal', animal); % change the animal name accordingly
            
            if(strcmp(tbl.MACleanedFileName(i),'_cleaned') & strcmp(tbl.ANCExported_,'ANC exported'))
                
                %full path for MA anc and trc_cleaned files on the server
                MApath = strcat(tbl.rawMAfolder(i),'\',tbl.MASessionFolder(i),'\',tbl.MASessionName,'_',num2str(tbl.MAFile(i)));
                rawancfile = strcat(MApath, '.anc');
                rawtrcfile = strcat(MApath,'_cleaned.trc');
                
                if isunix
                    rawancfile = strrep(rawancfile, '\', '/');
                    rawtrcfile = strrep(rawtrcfile, '\', '/');
                end
        
                %put MA info into nwb by file path
                nwb = convraw_ma2nwb(rawancfile, rawtrcfile, 'nwb_in', nwb, 'identifier', identifier);
            end

            EyeTracking = tbl.EyeTracking(i);
            if(~isempty(EyeTracking{1}))
                
                %full path for Eyetracking on the server
                EyeTPath = strcat('root2\Animals2\Barb\Recording\Raw\','Barb Eyetracking\',tbl.EyeTracking(i),'.txt');

                if isunix
                    EyeTPath = strrep(EyeTPath, '\', '/');
                end
                
                %put MA info into nwb by file path
                nwb = convprocessed_eye2nwb(EyeTPath, 'nwb_in', nwb, 'identifier', identifier);
            end
            
            
            %export derived nwb
            out_filename = strcat(identifier,'.nwb');
            outNwbFile = fullfile(outcodepath,  'NMRCNWB_TestData', out_filename);
            disp(['...Exporting NWB file to ' outNwbFile ' ...'])
            nwbExport(nwb, outNwbFile);
            
        end
    end
end
end



