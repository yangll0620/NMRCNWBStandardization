function elec_tbl = readnwb_electrodes(nwb)
%  read_electrodes read the electrode information.
%
%    elec_tbl = read_electrodes(nwb) return electrode information table.
%
% 
% 
%  Example:
%
%           elec_tbl = read_electrodes(nwb);
%
%  Input:
%           nwb:  NWB structure
%
%  Output:
%           elec_tbl electrode information table
%

dyntblreg = nwb.acquisition.get('tdtneur').electrodes; % dyntblreg: DynamicTableRegion type, a region/index into a DynamicTable
dyntbl = dyntblreg.table.refresh(nwb);
colnames = dyntbl.colnames;
id = dyntbl.id.data.load;
elecinf = dyntbl.vectordata;

elecinfkeys = elecinf.keys();
%  check the consistent between the colonames and elecinfkeys
if ~isempty(find(~ismember(colnames, elecinfkeys)))
    idx_notinkeys = find(~ismember(colnames, elecinfkeys));
    for i = 1:length(idx_notinkeys)
        disp(['''' colnames{idx_notinkeys(i)} ''' in colnames is not stored!'])
    end
end
if ~isempty(find(~ismember(elecinfkeys, colnames)))
    idx_notinnames = find(~ismember(elecinfkeys, colnames));
    for i = 1:length(idx_notinnames)
        disp(['stored ''' elecinfkeys{idx_notinnames(i)} ''' doesn''t have a corresponding name in colnames!'])
    end
end

%
n_keys = length(elecinfkeys);
elec_tbl = table(id);
for i = 1:n_keys
    % read the data of each key
    eleckey = elecinfkeys{i};
    eval(['data = elecinf.get(''' eleckey ''').data;'])
    if isa(data, 'types.untyped.DataStub') % types.untyped.DataStub
        eval([eleckey ' = data.load;'])
    elseif isa(data, 'cell') % cell type
          eval([eleckey ' = data;'])
        else
            disp(['type is not cell or types.untyped.DataStub,new type is '  class(data)]);
            return
    end
    eval(['elec_tbl = [elec_tbl table(' eleckey ')];'])
    clear data
end
