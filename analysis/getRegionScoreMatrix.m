function rmat = getRegionScoreMatrix(rsc,varargin)
% GETREGIONSCOREMATRIX
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'condidx',1,...
    'excludedatasets',[],...
    'excludenan',true);
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

if ~isempty(options.excludedatasets)
    if ~iscell(options.excludedatasets)
        options.excludedatasets = {options.excludedatasets};
    end
    idx = find(ismember(rsc.datasets,options.excludedatasets));
    rsc.rscores(idx,:) = [];
    rsc.datasets(idx) = [];
end

condidx = options.condidx;
numdatasets = numel(rsc.datasets);

% get region list
regions = {};
for ii = 1:numdatasets
    regions = [regions;rsc.rscores{ii,condidx}.regions];
end
rmat.datasets = rsc.datasets;
rmat.condition = rsc.conditions{condidx};
rmat.regions = unique(regions);
rmat.rho = nan(numel(rmat.regions,numdatasets));
rmat.count = zeros(size(rmat.rho));

for ii = 1:numdatasets
    rs = rsc.rscores{ii,condidx};
    numregions = numel(rs.regions);
    
    for jj = 1:numregions
        ridx = find(strcmp(rmat.regions,rs.regions{jj}));
        rmat.rho(ridx,ii) = rs.rho(jj);
        rmat.count(ridx,ii) = rs.count(jj);
    end
end

if options.excludenan
    allnan = all(isnan(rmat.rho),2);
    rmat.regions(allnan) = [];
    rmat.rho(allnan,:) = [];
    rmat.count(allnan,:) = [];
end
