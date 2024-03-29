function vecIndName = addVecInd(DynamicTable, colName)
%ADDVECIND Add VectorIndex object to DynamicTable
validateattributes(colName, {'char'}, {'scalartext'});
vecIndName = [colName '_index']; % arbitrary convention of appending '_index' to data column names

if isprop(DynamicTable, colName)
    vecTarget = types.untyped.ObjectView(DynamicTable.(colName));
else
    vecTarget = types.untyped.ObjectView(DynamicTable.vectordata.get(colName));
end
oldDataHeight = 0;
if isKey(DynamicTable.vectordata, colName) || isprop(DynamicTable, colName)
    if isprop(DynamicTable, colName)
        VecData = DynamicTable.(colName);
    else
        VecData = DynamicTable.vectordata.get(colName);
    end
    
    if ~isempty(VecData)
        if isa(VecData.data, 'types.untyped.DataPipe')
            oldDataHeight = VecData.data.offset;
        else
            oldDataHeight = size(VecData.data, 1);
        end
    end
end

% we presume that if data already existed in the vectordata, then
% it was never a ragged array and thus its elements corresponded
% directly to each row index.
if 8 == exist('types.hdmf_common.VectorIndex', 'class')
    VecIndex = types.hdmf_common.VectorIndex(...
    'target', vecTarget,...
    'data', (0:(oldDataHeight-1)) .');
else
    VecIndex = types.core.VectorIndex(...
    'target', vecTarget,...
    'data', (0:(oldDataHeight-1)) .');
end

if isprop(VecIndex, 'description')
    VecIndex.description = sprintf('Index into column %s', colName);
end

if isprop(DynamicTable, vecIndName)
    DynamicTable.(vecIndName) = VecIndex;
elseif isprop(DynamicTable, 'vectorindex')
    DynamicTable.vectorindex.set(vecIndName, VecIndex);
else
    DynamicTable.vectordata.set(vecIndName, VecIndex);
end
end