function plotTopDecoderFoldPerformance(C,varargin)
% PLOTTOPCONDITIONPERFORMANCE
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'condidx',1,...
    'title',[],...
    'metric','rho',...
    'method','onese',...
    'ytick',[],...
    'perflim',[-0.2 0.8],...
    'varname',[],...
    'varvals',[]);     
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

numplots = numel(C);
numdatasets = numel(C{1}.datasets);
numfolds = numel(C{1}.perfs{1}.folds);

S = cell(numplots,1);

% gather performance
for pp = 1:numplots
    scores = nan(numfolds,numdatasets);
    for ii = 1:numdatasets
        pf = C{pp}.perfs{ii,options.condidx};

        % select optimal regularization (mode across folds)
        sc = pf.(options.metric);
        methname = sprintf('%sidx',options.method);
        lambdaidx = pf.(methname);
        bestlambdaidx = mode(lambdaidx,'all');
        
        % find predictor set with highest mean performance
        sm = nanmean(sc,3);
        %[~,predsetidx] = nanmax(sc(:,bestlambdaidx));
        [~,predsetidx] = nanmax(sm(:,bestlambdaidx));

        scores(:,ii) = arrayfun(@(x) sc(predsetidx,lambdaidx(predsetidx,x),x),1:numfolds);
    end
    S{pp} = scores;
end

xgap = 0.15;
ygap = 0.1;
subplot = @(m,n,p) subtightplot (m, n, p, [ygap xgap], [0.2 0.15], [0.15 0.07]);

figure
set(gcf,'color','w')
set(gcf,'position',[488   607   560   250])


for pp = 1:numplots
    scores = S{pp};
    avgscores = mean(scores,1);
    [~,rankidx] = sort(avgscores,'descend');


    ha = subplot(1,numplots,pp);
    hold on
    set(gca,'tickdir','out')
    set(gca,'ticklength',0.025*[1 1])
    %set(gca,'ydir','reverse')
    set(gca,'fontsize',12)

    
    for ii = 1:numdatasets
        ridx = rankidx(ii);
        clr = getDatasetColor(C{pp}.datasets{ridx});
        lineclr = getDarkerColor(clr,0.25);
        plot(ii*[1 1],options.perflim,':','color',0.7*[1 1 1])
        plot(ii,avgscores(ridx),'o','markerfacecolor',getLighterColor(clr,0.5),...
            'markeredgecolor',clr,'markersize',16,'linewidth',1)
        plot(ii,scores(:,ridx),'o','markerfacecolor',clr,'markeredgecolor',lineclr,...
            'markersize',8,'linewidth',1)
    end


    set(gca,'xtick',1:numdatasets)
    set(gca,'xticklabel',getDatasetAliases(C{pp}.datasets(rankidx)))

    xlim([0.4 numdatasets])
    ylim(options.perflim)
    set(gca,'ytick',options.perflim(1):0.2:options.perflim(2))
    if pp == 1
        ylabel('$$\rho_{max}$$','interpreter','latex','fontsize',22)
    end
    
    if ~isempty(options.title) && numel(options.title) == numplots
        title(options.title{pp})
    end
    
    % hide the horizontal axis line
    drawnow%pause(0.2)
    apos = get(ha,'position');
    hx = axes('position',apos);
    hx.Color = 'none';
    hx.XColor = 'none';
    hx.XTick = [];
    hx.YTick = [];
    hx.XColor = 'w';
end