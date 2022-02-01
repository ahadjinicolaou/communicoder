function [tdata] = getTopConditionPerformance(cdata,metric,varargin)

options = struct(...
    'lowerlimit',[],...
    'upperlimit',[],...
    'numbands',[],...
    'maxpredcount',[]);
paramnames = fieldnames(options);

numargs = length(varargin);
if round(numargs/2) ~= numargs/2
    error('Name/value input argument pairs required.')
end

% {name; value} pairs
for pair = reshape(varargin,2,[])
    thisparam = lower(pair{1});
    if any(strcmp(thisparam,paramnames))
        options.(thisparam) = pair{2};
    else
        error('%s is not a recognized parameter name.',thisparam)
    end
end

% -------------------------------------------------------------------------

if any(~ismember(metric,{'rho','rmse'}))
    error('Invalid performance metric(s).');
end

predsets = cdata.perfs{1}.predsets;
predsetmask = true(size(predsets));
numdatasets = numel(cdata.datasets);
numconditions = numel(cdata.conditions);
if ~isempty(options.numbands)
    numbands = cellfun(@(x) numel(x),strfind(predsets,'__'),'uniformoutput',true);
    predsetmask = ismember(numbands,options.numbands);
end

tdata = [];
tdata.datasets = cdata.datasets;
tdata.conditions = cdata.conditions;

results = [];
methods = {'maxperf','mindeviance','onese'};
for ii = 1:numel(methods)
    results.(methods{ii}) = [];
    results.(methods{ii}).values = nan(numdatasets,numconditions);
    results.(methods{ii}).indices = nan(2,numdatasets,numconditions);
end
results.metric = metric;
results.numbands = options.numbands;

for ii = 1:numdatasets
    for jj = 1:numconditions
        % select scores for specific freq bands
        pf = cdata.perfs{ii,jj};
        pf.oneseidx = pf.oneseidx(predsetmask,:);
        pf.mindevianceidx = pf.mindevianceidx(predsetmask,:);
        scores = pf.(metric)(predsetmask,:,:);

        % get mean scores across outer folds
        % 1. max score
        scores = nanmean(scores,3);
        maxscores = nanmax(scores);
        [~,lambdaidx(1)] = nanmax(maxscores);

        % take the mode across outer folds and all predictor sets
        % 2. min deviance
        % 3. min deviance + 1SE
        lambdaidx(2) = mode(pf.mindevianceidx,'all');
        lambdaidx(3) = mode(pf.oneseidx,'all');
        
        for kk = 1:3
            [val,validx] = nanmax(scores(:,lambdaidx(kk)));
            results.(methods{kk}).values(ii,jj) = val;
            results.(methods{kk}).indices(:,ii,jj) = [validx,lambdaidx(kk)];
        end
    end
end

tdata.results = results;
