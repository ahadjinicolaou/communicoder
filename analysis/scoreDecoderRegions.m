function rs = scoreDecoderRegions(c,method,varargin)
% SCOREDECODERREGIONS
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'numdecoders',[],...
    'numpredictors',[]);
paramnames = fieldnames(options);

numargs = length(varargin);
if round(numargs/2) ~= numargs/2
    error('Name/value input argument pairs required.')
end

% {name; value} pairs
for pair = reshape(varargin,2,[])
    param = lower(pair{1});
    if any(strcmp(param,paramnames))
        options.(param) = pair{2};
    else
        error('%s is not a recognized parameter name.',param)
    end
end

% -------------------------------------------------------------------------

perfs = c.perfs;
maps = c.maps;
models = c.models;

methodfield = sprintf('%sidx',lower(method));
if ~contains(methodfield,fieldnames(perfs{1}))
    error('Method name can be either MAXPERFIDX, ONESEIDX, or MINDEVIANCEIDX.');
end

numperfs = numel(perfs);
rs.datasets = c.datasets;
rs.conditions = c.conditions;
rs.rscores = cell(size(perfs));

for ii = 1:numperfs
    rsc = [];
    rsc.regions = maps{ii}.parc.regions';
    rsc.coeffs = cell(size(rsc.regions));
    rsc.rho = nan(size(rsc.regions));
    rsc.count = zeros(size(rsc.regions));
    predsets = perfs{ii}.predsets;
    
    modeldir = getModelDirectory(models{ii});
    
    % get the optimal lambdas/scores for all predsets
    lambdaidx = mode(perfs{ii}.(methodfield),2);
    dscores = zeros(numel(predsets,1));
    for jj = 1:numel(predsets)
        dscores(jj) = nanmean(perfs{ii}.rho(jj,lambdaidx(jj),:));
    end
    
    % rank the top K decoders
    [topsc,decoderrankidx] = sort(dscores,'descend');
    numdecoders = numel(topsc);
    if ~isempty(options.numdecoders)
        numdecoders = options.numdecoders;
    end
    
    % for each decoder, get the top P predictors
    for jj = 1:numdecoders
        didx = decoderrankidx(jj);
        fname = strjoin({'predset',predsets{didx}},'__');
        d = loadFitResults(modeldir,'filename',fname);
        zvar = std(d.neural.Z)';
        
        % get predictor coefficients (average over folds)
        numfolds = numel(d.folds);
        b = nan(size(d.lasso(1).coeffset,1),numfolds);
        
        numbadidx = 0;
        for kk = 1:numfolds
            % lambda index adjusted for first tested index
            adjustedidx = lambdaidx(didx) - d.lasso(kk).firstlambdaidx + 1;
            if adjustedidx >= 1 && adjustedidx <= size(b,2)
                b(:,kk) = d.lasso(kk).coeffset(:,adjustedidx);
            else
                % not all folds will be able to accommodate lambda mode
                numbadidx = numbadidx + 1;
            end
        end
        if numbadidx > numfolds/2, continue; end
        
        b = nanmean(b,2);

        % normalize coeffs using predictor variance and rank by magnitude
        beta = b .* zvar;
        [~,predictorrankidx] = sort(abs(beta),'descend');
        
        % create chanindex -> chanlabel -> regionindex lookup
        cmap = getLabelIndexMap(d.labels);
        [rmap,cidxmap] = getChanLabelParcellationMaps(cmap,maps{ii});
        
        numpredictors = numel(beta);
        if ~isempty(options.numpredictors)
            numpredictors = options.numpredictors;
        end
        
        for kk = 1:numpredictors
            pidx = predictorrankidx(kk);
            chanlabel = cmap(pidx);
            region = rmap(chanlabel);
            %cidx = cidxmap(chanlabel);
            cidx = find(strcmp(rsc.regions,region));
            
            if numel(cidx) > 1
                warning('Region %s was found %d times.',region,numel(cidx));
                cidx = cidx(1);
            end
            
            if isempty(region), continue; end
            
            % add score for corresponding decoder
            % NAN means it hasn't been accessed yet
            if isnan(rsc.rho(cidx))
                rsc.rho(cidx) = dscores(didx);
                rsc.coeffs{cidx} = [beta(kk)];
            else
                rsc.rho(cidx) = rsc.rho(cidx) + dscores(didx);
                rsc.coeffs{cidx} = [rsc.coeffs{cidx},beta(kk)];
            end
            rsc.count(cidx) = rsc.count(cidx) + 1;
        end
    end
    
    % compute average rho
    hasval = rsc.count > 0;
    rsc.rho(hasval) = rsc.rho(hasval) ./ rsc.count(hasval);
    rs.rscores{ii} = rsc;
end
