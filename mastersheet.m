function mastersheet(url, varargin)
    
    table = readtable(url);
    [nrow,~] = size(table);
    cell = table2cell(table);


    %traverse all lines in the sheet
    for i = 1:nrow
    
        % proceed only when the it has been cleaned
        if(~isempty(cell{i,1}) && strcmp(cell{i,10},'_cleaned') && strcmp(cell{i,33},'_cleaned')) 
        
            % create a new nwbfile?
            nwb = NwbFile();
            
            %full path for tdt files on the server
            rawtdtpath = strcat(cell{i,3},cell{i,4},'\Block-',num2str(cell{i,5})); 
            
            %get identifer by extracting info 
            identifier = strcat(cell{1,1},'_TDTbk',num2str(cell{1,5}),'_',cell{1,11}); %identifier for nwb file, formatted

            %get animal name from identifier
            parse_id = strsplit(identifier,'_');
            animal = parse_id{1};


            %put tdt info into nwb by tdt filepath
            tdt = TDTbin2mat(rawtdtpath);

            if exist('nwb', 'var')
                nwb = convraw_tdt2nwb(tdt, 'nwb_in', nwb, 'animal', animal); % change the animal name accordingly
            else
                nwb = convraw_tdt2nwb(tdt, 'animal', animal); % change the animal name accordingly
            end

            %full path for MA anc and trc_cleaned files on the server
            MApath = strcat(cell{i,6},'\',cell{i,7},'\',cell{i,8},'_',num2str(cell{i,9})); 
            rawancfile = strcat(MApath, '.anc');
            rawtrcfile = strcat(MApath,'_cleaned.trc');

            %put MA info into nwb by file path
            if exist('nwb', 'var')
                nwb = convraw_ma2nwb(rawancfile, rawtrcfile, 'nwb_in', nwb, 'identifier', identifier); % change the animal name accordingly
            else
                nwb = convraw_ma2nwb(rawancfile, rawtrcfile, 'identifier', identifier); % change the animal name accordingly
            end

            %export derived nwb
            out_filename = strcat(identifier,'.nwb');
            outNwbFile = fullfile(outcodepath,  'NMRCNWB_TestData', out_filename);
            disp(['...Exporting NWB file to ' outNwbFile ' ...'])
            nwbExport(nwb, outNwbFile);

           end
      
      end

 end

    
