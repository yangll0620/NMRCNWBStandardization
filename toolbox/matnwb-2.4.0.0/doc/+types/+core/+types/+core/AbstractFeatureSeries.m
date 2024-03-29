classdef AbstractFeatureSeries < types.core.TimeSeries & types.untyped.GroupClass
% ABSTRACTFEATURESERIES Abstract features, such as quantitative descriptions of sensory stimuli. The TimeSeries::data field is a 2D array, storing those features (e.g., for visual grating stimulus this might be orientation, spatial frequency and contrast). Null stimuli (eg, uniform gray) can be marked as being an independent feature (eg, 1.0 for gray, 0.0 for actual stimulus) or by storing NaNs for feature values, or through use of the TimeSeries::control fields. A set of features is considered to persist until the next set of features is defined. The final set of features stored should be the null set. This is useful when storing the raw stimulus is impractical.


% PROPERTIES
properties
    feature_units; % Units of each feature.
    features; % Description of the features represented in TimeSeries::data.
end

methods
    function obj = AbstractFeatureSeries(varargin)
        % ABSTRACTFEATURESERIES Constructor for AbstractFeatureSeries
        %     obj = ABSTRACTFEATURESERIES(parentname1,parentvalue1,..,parentvalueN,parentargN,name1,value1,...,nameN,valueN)
        % features = char
        % feature_units = char
        varargin = [{'data_unit' 'see `feature_units`'} varargin];
        obj = obj@types.core.TimeSeries(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'features',[]);
        addParameter(p, 'feature_units',[]);
        misc.parseSkipInvalidName(p, varargin);
        obj.features = p.Results.features;
        obj.feature_units = p.Results.feature_units;
        if strcmp(class(obj), 'types.core.AbstractFeatureSeries')
            types.util.checkUnset(obj, unique(varargin(1:2:end)));
        end
    end
    %% SETTERS
    function obj = set.feature_units(obj, val)
        obj.feature_units = obj.validate_feature_units(val);
    end
    function obj = set.features(obj, val)
        obj.features = obj.validate_features(val);
    end
    %% VALIDATORS
    
    function val = validate_data(obj, val)
        val = types.util.checkDtype('data', 'numeric', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        elseif istable(val)
            valsz = height(val);
        elseif ischar(val)
            valsz = size(val, 1);
        else
            valsz = size(val);
        end
        validshapes = {[Inf,Inf], [Inf]};
        types.util.checkDims(valsz, validshapes);
    end
    function val = validate_data_unit(obj, val)
        val = types.util.checkDtype('data_unit', 'char', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        elseif istable(val)
            valsz = height(val);
        elseif ischar(val)
            valsz = size(val, 1);
        else
            valsz = size(val);
        end
        validshapes = {[1]};
        types.util.checkDims(valsz, validshapes);
    end
    function val = validate_feature_units(obj, val)
        val = types.util.checkDtype('feature_units', 'char', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        elseif istable(val)
            valsz = height(val);
        elseif ischar(val)
            valsz = size(val, 1);
        else
            valsz = size(val);
        end
        validshapes = {[Inf]};
        types.util.checkDims(valsz, validshapes);
    end
    function val = validate_features(obj, val)
        val = types.util.checkDtype('features', 'char', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        elseif istable(val)
            valsz = height(val);
        elseif ischar(val)
            valsz = size(val, 1);
        else
            valsz = size(val);
        end
        validshapes = {[Inf]};
        types.util.checkDims(valsz, validshapes);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@types.core.TimeSeries(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.feature_units)
            if startsWith(class(obj.feature_units), 'types.untyped.')
                refs = obj.feature_units.export(fid, [fullpath '/feature_units'], refs);
            elseif ~isempty(obj.feature_units)
                io.writeDataset(fid, [fullpath '/feature_units'], obj.feature_units, 'forceArray');
            end
        end
        if ~isempty(obj.features)
            if startsWith(class(obj.features), 'types.untyped.')
                refs = obj.features.export(fid, [fullpath '/features'], refs);
            elseif ~isempty(obj.features)
                io.writeDataset(fid, [fullpath '/features'], obj.features, 'forceArray');
            end
        else
            error('Property `features` is required in `%s`.', fullpath);
        end
    end
end

end