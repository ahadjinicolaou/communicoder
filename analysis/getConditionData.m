function [cdata] = getConditionData(datasets,condsets,varargin)
% GETCONDITIONDATA
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'signal','wordcount',...
    'lag',[],...
    'overwrite',false);
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

if ~iscell(condsets), condsets = {condsets}; end
numdatasets = numel(datasets);
numconds = numel(condsets);

cdata = [];
cdata.datasets = datasets;
cdata.conditions = condsets;
cdata.models = cell(numdatasets,numconds);
cdata.perfs = cdata.models;
cdata.maps = cdata.models;

for ii = 1:numconds
    if strcmp(options.signal,'wordcount')
        includeparticipant = contains(condsets{ii},'pwords');
        includecompanion = contains(condsets{ii},'cwords');
        if contains(condsets{ii},'allwords')
            includeparticipant = true;
            includecompanion = true;
        end
    elseif strcmp(options.signal,'state')
        % state (legacy)
        includeparticipant = true;
        includecompanion = contains(condsets{ii},'dialog');
    else
        error('Unrecognized signal type (%s).',options.s)
    end
    
    shufflesignal = contains(condsets{ii},'shuffle');
    ntype = []; if contains(condsets{ii},'idle'), ntype = 'idle'; end
    cdata.models(:,ii) = getMultiModelDefaults(datasets,...
        'lag',options.lag,...
        'neuraltype',ntype,...
        'shufflesignal',shufflesignal,...
        'signal',options.signal,...
        'includeparticipant',includeparticipant,...
        'includecompanion',includecompanion);
    cdata.perfs(:,ii) = getDecoderPerformance(cdata.models(:,ii),...
        'overwrite',options.overwrite);
    cdata.maps(:,ii) = loadMultiBrainParcellations(cdata.models(:,ii));
end
