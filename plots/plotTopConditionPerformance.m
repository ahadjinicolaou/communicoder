function plotTopConditionPerformance(C,T,varargin)
% PLOTTOPCONDITIONPERFORMANCE
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'method','onese',...
    'columns',[],...
    'rows',[],...
    'ytick',[],...
    'sigtest',true,...
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

% labmap = containers.Map(...
%     {'pwords','idle.pwords','shuffle.pwords','cwords','idle.cwords','shuffle.cwords'},...
%     {'participant','participant

numconds = numel(C{1}.conditions);
numdatasets = numel(C{1}.datasets);
numcondsets = size(C,1);
numvarvals = size(C,2);
varvals = options.varvals;

nullconds = {'idle','shuffle'};
expidx = find(cellfun(@(x) ~contains(x,nullconds),C{1}.conditions));

if options.sigtest
    % null dist scores are idle/shuffle scores
    % collect these for t-tests later on
    nullidx = find(cellfun(@(x) contains(x,nullconds),C{1}.conditions));
    numnullconds = numel(nullidx);
    nulls = nan(numdatasets,numvarvals,numnullconds,numcondsets);
    nullthresh = nan(numdatasets,1);

    for pp = 1:numcondsets
        for cc = 1:numnullconds
            cidx = nullidx(cc);
            for ii = 1:numdatasets
                for jj = 1:numvarvals
                    nulls(ii,jj,cc,pp) = T{pp,jj}.results.(options.method).values(ii,cidx);
                end
            end
        end
    end
    
%     for ii = 1:numdatasets
%         nullthresh(ii) = mean(nulls(ii,:)) + 3*std(nulls(ii,:));
%     end
    nullthresh = mean(nulls(:)) + 3*std(nulls(:));
end





xgap = 0.1;
ygap = 0.05;
subplot = @(m,n,p) subtightplot (m, n, p, [ygap xgap], [0.2 0.10], [0.15 0.07]);



clear h
figure
set(gcf,'color','w')
set(gcf,'position',[414   191   880   530])
for pp = 1:numcondsets
    %pp = 1; % 1=participant
    scores = nan(numdatasets,numvarvals,numconds);

    for cc = 1:numconds
        for ii = 1:numdatasets
            for jj = 1:numvarvals
                scores(ii,jj,cc) = T{pp,jj}.results.(options.method).values(ii,cc);
            end
        end
    end

    %isok = scores(:,1,1) > scores(:,1,2);
    for cc = 1:numconds
        pidx = cc+(pp-1)*numconds;
        hx = subplot(numcondsets,numconds,pidx);
        set(gca,'fontsize',14)
        hold on

        clrs = lines(2);
        if pp == 1
            axclr = getLighterColor(clrs(1,:),0.95);
        else
            axclr = getLighterColor(clrs(2,:),0.95);
        end
        %set(gca,'color',axclr)
        hx.Color = axclr;
        
        lw = 1.5;
        xvals = 1:numvarvals;
        for ii = 1:numdatasets
            color = getDatasetColor(C{1}.datasets{ii});
            
            h(ii) = plot(xvals,scores(ii,:,cc),'color',color,'linewidth',lw);
            
        end
        
        % plot markers
        notsigclr = 1*[1 1 1];
        for ii = 1:numdatasets
            color = getDatasetColor(C{1}.datasets{ii});
            
            if options.sigtest
                % colorize if different from null dist
                isdiff = scores(ii,:,cc) > nullthresh;

                if any(isdiff)
                    plot(xvals(isdiff),scores(ii,isdiff,cc),'o','color',color,'markerfacecolor',color);
                end
                if any(~isdiff)
                    plot(xvals(~isdiff),scores(ii,~isdiff,cc),'o','color',color,...
                        'markerfacecolor',notsigclr,'linewidth',1.0);
                end

            else
                plot(xvals,scores(ii,:,cc),'o','color',color,'markerfacecolor',color);
            end
        end
        
        xlims = [0.75 numvarvals+0.25];
        if options.sigtest
            nullclr = 0.3*[1 1 1];
            plot(xlims,nullthresh*[1 1],'--','color',nullclr)
%             if pidx == numcondsets * numconds
%                 text(xlims(2),nullthresh,'$$\mu+3\sigma$$','color',nullclr,...
%                     'fontsize',12,'interpreter','latex',...
%                     'horizontalalign','right','verticalalign','bottom')
%             end
        end
        
        if ~isempty(options.rows) && cc == 1
            text(0.94,0.96,options.rows{pp},'color',clrs(pp,:),...
                'fontsize',14,'units','normalized',...
                'horizontalalign','right','verticalalign','top')
        end
        
        

        
        set(gca,'tickdir','out')
        set(gca,'ticklength',0.035*[1 1])
        xlim(xlims)
        set(gca,'xtick',1:numvarvals)
        if pp < numcondsets
            set(gca,'xticklabel',[])
        else
        	set(gca,'xticklabel',varvals)
        end
        
        if ~isempty(options.ytick)
            %set(gca,'ylim',options.ytick([1 end]))
            ylim([-0.05 options.ytick(end)])
            set(gca,'ytick',options.ytick)
            set(gca,'yticklabel',options.ytick)
        end
        
        %title(condsets{pp}{cc})
        if pp == 1
            if ~isempty(options.columns)
                title(options.columns{cc})
            else
                title(T{pp}.conditions{cc})
            end
        end
        
        if pp == numcondsets && cc == 2
            xlabel(options.varname,'fontsize',22)
        end
        if cc == 1
            mstr = T{1}.results.metric;
            if strcmp(mstr,'rho')
                mstr = '$$\rho_{max}$$';
            end
            ylabel(mstr,'fontsize',22,'interpreter','latex')
        end
        
        if cc == numconds && pp == 1
            hl = legend(h,getDatasetAliases(C{1}.datasets));
            hl.FontSize = 11;
            hl.Color = [1 1 1];
        end
    end
end
