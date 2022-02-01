function plotRegionScoreMatrix(rmat,varargin)
% PLOTREGIONSCOREMATRIX
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'clim',[],...
    'score','rho',...
    'showcolorbar',true,...
    'sortby',[],...
    'topregions',[],...
    'highlightmissing',true,...
    'exclude',[]);
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

datasets = getDatasetAliases(rmat.datasets);
if ~isempty(options.exclude)
    excludesets = options.exclude;
    if ~ischar(excludesets), excludesets = {excludesets}; end
    exclude = ismember(datasets,excludesets);
    if any(exclude)
        datasets(exclude) = [];
        rmat.rho(:,exclude) = [];
        rmat.count(:,exclude) = [];
        rmat.datasets(exclude) = [];
    end
end
numregions = numel(rmat.regions);
numdatasets = numel(rmat.datasets);

rho = rmat.rho;
regions = rmat.regions;
count = rmat.count;

score = rmat.(options.score);

if ~isempty(options.sortby)
    if ~ismember(options.sortby,{'rho','predcount','datasetcount'})
        error('SORTBY must be score|predcount|datasetcount.');
    end
    
    if strcmp(options.sortby,'score')
        sc = nanmean(score,2);
    elseif strcmp(options.sortby,'rho')
        sc = nanmean(rho,2);
    elseif strcmp(options.sortby,'predcount')
        sc = nanmean(count,2);
    elseif strcmp(options.sortby,'datasetcount')
        sc = nanmean(count > 0,2);
    end
    [~,idx] = sort(sc,'descend','missingplacement','last');
    score = score(idx,:);
    regions = regions(idx);
    %rho = rho(idx,:);
    %count = count(idx,:);
end

if ~isempty(options.topregions)
    score = score(1:options.topregions,:);
    regions = regions(1:options.topregions);
end

figure
set(gcf,'color','w')
if ~isempty(options.topregions)
    set(gcf,'position',[623   480   560   190])
else
    set(gcf,'position',[680   406   560   580])
end

imagesc(score);
set(gca,'xtick',1:numdatasets)
set(gca,'xticklabel',datasets)
set(gca,'ytick',1:numregions)
set(gca,'yticklabel',regions)
set(gca,'fontsize',11)

if ~isempty(options.clim)
    if isnan(options.clim(2))
        options.clim(2) = nanmax(score,[],'all');
    end
    set(gca,'clim',options.clim)
else
    %set(gca,'clim',[0 max(score,[],'all')])
    set(gca,'clim',[0.98*min(score(:)),max(score(:))])
end

if strcmp(options.score,'count')
    cmap = gray;
    missclr = 0*[1 1 1];
else
    %cmap = parula;
    cmap = brewermap(16,'PuBu');
    cmap(15:end,:) = [];
    missclr = 0.3*[1 1 1];
end
if options.highlightmissing
    cmap(1,:) = missclr;
end
colormap(cmap)

if options.showcolorbar
    hcb = colorbar;
    if ~strcmp(options.score,'count')
        %options.score = ['average ',options.score];
        options.score = '$$\bar{\rho}$$';
    end
    
    clim = get(gca,'clim');
    clabs = arrayfun(@(x) sprintf('%1.1f',x),round(clim,2),'uniformoutput',false);
    clabs{1} = sprintf('%s-',clabs{1});
    clabs{2} = sprintf('%s+',clabs{2});
    set(hcb,'ytick',clim)
    set(hcb,'yticklabel',clabs)
    hcb.Label.String = options.score;
    hcb.Label.Interpreter = 'latex';
    hcb.Label.FontSize = 16;
    hcb.Label.Units = 'normalized';
    hcb.Label.Position(1) = 1+0.2;
end
