function mastersheet(url, varargin)
    
    tbl = readtable(url);
    [nrow,~] = size(tbl);
    


    %traverse all lines in the sheet
    for i = 1:nrow
    
        % proceed only when the it has been cleaned
        folderName = tbl.OutputFolderName(i);
        if(~isempty(folderName{1}))
        
            % create a new nwbfile?
            nwb = NwbFile();
            
            %full path for tdt files on the server
            rawtdtpath = strcat(tbl.rawTDTfolder(i),tbl.TDTSessionName(i),'\Block-',num2str(tbl.TDTBlock(i))); 
            
            %get identifer by extracting info 
            identifier = strcat(tbl.OutputFolderName(i),'_TDTbk',num2str(tbl.TDTBlock(i)),'_',tbl.BriefDescription(i)); %identifier for nwb file, formatted

            %get animal name from identifier
            parse_id = strsplit(identifier,'_');
            animal = parse_id{1};


            %put tdt info into nwb by tdt filepath
            tdt = TDTbin2mat(rawtdtpath);

            
            nwb = convraw_tdt2nwb(tdt, 'nwb_in', nwb, 'animal', animal); % change the animal name accordingly
            
        end

        
         if(strcmp(tbl.MACleanedFileName(i),'_cleaned') && strcmp(tbl.ANCExported_,'ANC exported')) 
            %full path for MA anc and trc_cleaned files on the server
            MApath = strcat(tbl.rawMAfolder(i),'\',tbl.MASessionFolder(i),'\',tbl.MASessionName,'_',num2str(tbl.MAFile(i))); 
            rawancfile = strcat(MApath, '.anc');
            rawtrcfile = strcat(MApath,'_cleaned.trc');

            %put MA info into nwb by file path
            
            nwb = convraw_ma2nwb(rawancfile, rawtrcfile, 'nwb_in', nwb, 'identifier', identifier); 
            

            %export derived nwb
            out_filename = strcat(identifier,'.nwb');
            outNwbFile = fullfile(outcodepath,  'NMRCNWB_TestData', out_filename);
            disp(['...Exporting NWB file to ' outNwbFile ' ...'])
            nwbExport(nwb, outNwbFile);
 
        end
      
   end

end


    
