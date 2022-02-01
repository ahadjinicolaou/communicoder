function plotRegionCoefficients(rsc,regions,varargin)
% PLOTREGIONCOEFFICIENTS
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'numcolumns',1,...
    'condidx',1,...
    'bandidx',[],...
    'probmorethan',[],...
    'wmlessthan',[],...
    'fpos',[],...
    'xtick',[],...
    'indicateside',true,...
    'shownonzeros',true,...
    'colornonzeros',false);
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

datasets = getDatasetAliases(rsc.datasets);
numregions = numel(regions);
numdatasets = numel(datasets);
numcolumns = options.numcolumns;
colors = brewermap(numregions,'dark2');
%xlims = [-1.2 0.6];

xticks = -1.2:0.6:0.6;
if ~isempty(options.xtick)
    xticks = options.xtick;
end
xlims = xticks([1 end]);

if numcolumns == 1
    fpos = [680   320   450   650];
    maxregionspercol = numregions;
else
    fpos = [680   320   1000   650];
    maxregionspercol = ceil(numregions/numcolumns);
end

if ~isempty(options.fpos), fpos = options.fpos; end


xgap = 0.09;
ygap = 0.06;
subplot = @(m,n,p) subtightplot (m, n, p, [ygap xgap], [0.2 0.05], [0.18 0.05]);

figure
set(gcf,'color','w')
set(gcf,'position',fpos)




for cc = 1:numcolumns
    hp(cc) = subplot(1,numcolumns,cc);
    set(gca,'ydir','reverse')
    set(gca,'tickdir','out')
    set(gca,'ticklength',0.02*[1 1])

    ypos = 1;
    ylabels = [];
    yticks = [];
    if cc == numcolumns
        numregionsincol = mod(numregions,maxregionspercol);
        if numregionsincol == 0, numregionsincol = maxregionspercol; end
    else
        numregionsincol = maxregionspercol;
    end
    numcoeffs = zeros(numregionsincol*numdatasets,1);
    issig = zeros(size(numcoeffs));
    medians = zeros(size(numcoeffs));

    ylims = [0.5 (numdatasets+1)*maxregionspercol];
    hold on
    plot([0 0],ylims,'--','color',0*[1 1 1])
    
    for rr = 1:numregionsincol
        roffset = (cc-1)*maxregionspercol;
        
        for ii = 1:numdatasets
            cidx = ii + (rr-1)*numdatasets;

            rs = rsc.rscores{ii,options.condidx};
            
            plot(xlims,ypos*[1 1],':','color',0.8*[1 1 1]); hold on
            regionidx = find(strcmp(rs.regions,regions{roffset+rr}));
            c = rs.coeffs{regionidx};
            
            % filtering
%             if ~isempty(c)
%                 cmask = true(size(c.values));
%                 if ~isempty(options.bandidx)
%                     cmask = cmask & ismember(c.bandidx,options.bandidx);
%                 end
%                 
%                 if ~isempty(options.probmorethan)
%                     cmask = cmask & (c.prob > options.probmorethan);
%                 end
%                 
%                 if ~isempty(options.wmlessthan)
%                     cmask = cmask & (c.wmprob < options.wmlessthan);
%                 end
%                 
%                 c.values = c.values(cmask);
%                 c.bandidx = c.bandidx(cmask);
%             end
            
            %if isfield(c,'values')
            if ~isempty(c)
                
                facecolor = colors(rr,:);
                edgecolor = facecolor;
                facealpha = 0.3;
                if options.indicateside
                    if contains(regions{roffset+rr},'-rh')
                        %edgecolor = 0.2*[1 1 1];
                        %facealpha = 0.5;
                        facecolor = [1 1 1];
                        %edgecolor = getDarkerColor(edgecolor,0.5);
                        %facecolor = getLighterColor(facecolor,0.5);
                    end
                end
                
                % c.values replaced by c
                medians(cidx) = median(c);
                plot(medians(cidx),ypos,'o','markersize',12,...
                    'markerfacecolor','w','color',edgecolor);
                h(rr) = scatter(c,ypos*ones(size(c)),30,'filled');
                h(rr).MarkerEdgeColor = edgecolor;
                h(rr).MarkerFaceColor = facecolor;
                h(rr).MarkerFaceAlpha = facealpha;
                numcoeffs(cidx) = numel(c);
                if numel(c) > 1
                    issig(cidx) = ttest(c);
                end

            end

            ylabels{ypos} = sprintf('%s (%d)',datasets{ii},numcoeffs(cidx));
            yticks(ypos) = ypos;
            ypos = ypos + 1;
        end
        ypos = ypos + 1;
    end
    ylim(ylims)
    ylabels(yticks == 0) = [];
    yticks(yticks == 0) = [];

    
    xlim(xlims)
    set(gca,'xtick',xticks)
    set(gca,'xticklabel',xticks)
    set(gca,'ytick',yticks)
    set(gca,'yticklabel',ylabels)
    xlabel('coefficients','fontsize',20)

    legend(h,regions((1+roffset):(roffset+numregionsincol)),'location','southwest')

    if options.shownonzeros
        ax = hp(cc);
        cidx = find(~issig);
        color = 0.65*[1 1 1];
        for ii = 1:numel(cidx)
            ax.YTickLabel{cidx(ii)} = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
                color,ax.YTickLabel{cidx(ii)});
        end
        
        if options.colornonzeros
            cidx = find(issig);
            for ii = 1:numel(cidx)
                if medians(cidx(ii)) > 0, color = [0 0 0]; else, color = [0.8 0 0]; end
                ax.YTickLabel{cidx(ii)} = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
                    color,ax.YTickLabel{cidx(ii)});
            end
        end
        
    end

    % draw white line over y-axis (to hide it)
%     h = axes('position',get(hp(cc),'position'));
%     set(h,'color','none')
%     set(h,'xtick',[])
%     set(h,'ytick',[])
%     set(h,'ycolor','w')
end
