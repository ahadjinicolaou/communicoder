function plotBehavioralSignal(out,words,varargin)
% PLOTBEHAVIORALSIGNAL shows the response variable time series.
%   NOTE: this hasn't yet been refactored to handle intent state models!
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'par',[],...
    'figpos',[500 450 1000 330],...
    'xticks',[],...
    'yticks',[],...
    'signalcolor',0.3*[1 1 1],...
    'participantwordcolor',[0 0.4470 0.7410],...
    'companionwordcolor',[0.8500 0.3250 0.0980],...
    'showparticipantwords',true,...
    'showcompanionwords',false,...
    'linewidth',1.5);
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

figure
set(gcf,'position',options.figpos)
set(gcf,'color','w')

set(gca,'tickdir','out')
set(gca,'fontsize',14)
set(gca,'layer','top')
hold on

plot(out.t,out.x,'linewidth',options.linewidth,'color',options.signalcolor);

xticks = options.xticks;
yticks = options.yticks;
if isempty(yticks), yticks = get(gca,'ytick'); end
if isempty(xticks), xticks = get(gca,'xtick'); end

set(gca,'ytick',yticks)
set(gca,'yticklabel',yticks)
ylim(yticks([1 end]))

% word ticks
dy = 0.09*diff(yticks([1,end]));
ybottom = 0;
for ii = 1:2
    if ii == 1
        onsets = words.participant.onset;
        color = options.participantwordcolor;
        plotwords = options.showparticipantwords;
    else
        onsets = words.companion.onset;
        color = options.companionwordcolor;
        plotwords = options.showcompanionwords;
    end
    
    if plotwords
        px = onsets;
        px = [px,px];
        py = ones(size(px));
        py(:,1) = ybottom + py(:,1) * -0.15*dy;
        py(:,2) = ybottom + py(:,2) * -0.85*dy;
        plot(px',py','color',color)
        ybottom = ybottom - 0.85*dy;
    end
end

% nicer spacing
ybottom = ybottom -0.15*dy;
ylim(yticks([1,end]) + [ybottom,0])

set(gca,'xtick',xticks)
ylabel('$$y_{k}$$','fontsize',24,'interpreter','Latex')
xlabel('seconds','fontsize',24)
