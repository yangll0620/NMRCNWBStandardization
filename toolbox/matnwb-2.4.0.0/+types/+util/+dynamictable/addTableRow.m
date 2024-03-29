function addTableRow(DynamicTable, subTable, varargin)
p = inputParser();
p.StructExpand = false;
addParameter(p, 'id', [], @(x)isnumeric(x)); % optional as `id` column is supported for tables.
parse(p, varargin{:});

rowNames = subTable.Properties.VariableNames;
missingColumns = setdiff(DynamicTable.colnames, rowNames);
assert(isempty(missingColumns),...
    'NWB:DynamicTable:AddRow:MissingColumns',...
    'Missing columns { %s }', strjoin(missingColumns, ', '));

isIdInTable = any(strcmp(rowNames, 'id'));
isIdKeywordArg = ~any(strcmp(p.UsingDefaults, 'id'));
if isIdInTable
    idData = subTable.id;
    if isIdKeywordArg
        warning('NWB:DynamicTable:AddRow:DuplicateId',...
            'subtable already has an `id` column. Will ignore keyword argument.');
    end
elseif isIdKeywordArg
    assert(length(p.Results.id) == height(subTable),...
        'NWB:DynamicTable:AddRow:InvalidIdSize',...
        ['Optional keyword argument `id` must match the height of the subtable to append. '...
        'Hint: you can also include `id` as a column in the subtable.']);
    idData = p.Results.id;
end

if isIdInTable || isIdKeywordArg
    validateattributes(idData, {'numeric'}, {'vector'});
end

TypeMap = types.util.dynamictable.getTypeMap(DynamicTable);
for i = 1:length(rowNames)
    rn = rowNames{i};
    rowColumn = subTable.(rn);
    
    if isKey(TypeMap, rn)
        validateType(TypeMap(rn), rowColumn);
    end
    
    for j = 1:length(rowColumn)
        if iscell(rowColumn)
            rv = rowColumn{j};
        else
            rv = rowColumn(j);
        end
        types.util.dynamictable.addRawData(DynamicTable, rn, rv);
    end
end

if isIdInTable
    return;
end

if isIdKeywordArg
    idRange = p.Results.id;
else
    if isa(DynamicTable.id.data, 'types.untyped.DataPipe')
        newStartId = DynamicTable.id.data.offset;
        DynamicTable.id.data.append(DynamicTable.id.data.offset);
    else
        newStartId = length(DynamicTable.id.data);
    end
    
    idRange = (newStartId:(newStartId+height(t))) .';
end

types.util.dynamictable.addRawData(DynamicTable, 'id', idRange);
end

function validateType(TypeStruct, rv)
if strcmp(TypeStruct.type, 'cellstr')
    assert(iscellstr(rv) || (ischar(rv) && 1 == size(rv, 1)),...
        'NWB:DynamicTable:AddRow:InvalidType',...
        'Type of value must be a cell array of character vectors or a scalar character');
else
    if ~iscell(rv)
        rv = {rv};
    end
    for i = 1:length(rv)
        validateattributes(rv{i}, {TypeStruct.type}, {'size', [NaN TypeStruct.dims(2:end)]});
    end
end
end