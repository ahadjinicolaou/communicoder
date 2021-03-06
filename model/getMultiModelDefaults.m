function [models] = getMultiModelDefaults(datasets, varargin)
% GETMULTIMODELDEFAULTS Sets reasonable model defaults for each dataset.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'numstatevars',[],...
    'processtype',[],...
    'variance',[],...
    'timelimit',[],...
    'dt',[],...
    'lag',[],...
    'rhothresh',[],...          % set to empty to include all predictors
    'signal',[],...
    'includeparticipant',[],...
    'includecompanion',[],...
    'fitnoise',[],...
    'swapspeakers',[],...
    'neuraltype',[],...
    'shufflesignal',[],...
    'wordtypes',[]);
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

models = cell(numel(datasets),1);
for ii = 1:numel(datasets)
    models{ii} = getModelDefaults(datasets{ii},...
        'numstatevars',options.numstatevars,...
        'processtype',options.processtype,...
        'variance',options.variance,...
        'timelimit',options.timelimit,...
        'dt',options.dt,...
        'lag',options.lag,...
        'rhothresh',options.rhothresh,...
        'includeparticipant',options.includeparticipant,...
        'includecompanion',options.includecompanion,...
        'swapspeakers',options.swapspeakers,...
        'signal',options.signal,...
        'fitnoise',options.fitnoise,...
        'neuraltype',options.neuraltype,...
        'shufflesignal',options.shufflesignal,...
        'wordtypes',options.wordtypes);
end
