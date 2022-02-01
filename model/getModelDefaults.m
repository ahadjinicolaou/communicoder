function [m] = getModelDefaults(dataset,varargin)
% GETMODELDEFAULTS Sets reasonable model defaults.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'signal',[],...
    'numstatevars',[],...
    'processtype',[],...
    'variance',[],...
    'timelimit',[],...
    'dt',[],...
    'lag',[],...
    'rhothresh',[],...
    'includeparticipant',[],...
    'includecompanion',[],...
    'signaldist',[],...
    'swapspeakers',[],...
    'fitwordcount',[],...
    'fitnoise',[],...
    'shufflesignal',[],...
    'neuraltype',[],...
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

m.dataset = dataset;

m.signal = 'wordcount';
if ~isempty(options.signal)
    m.signal = options.signal;
end

m.signaldist = 'normal';
if ~isempty(options.signaldist)
    m.signaldist = options.signaldist;
end

% options specific to state models
if strcmp(m.signal,'state')
    m.processtype = 'poisson';
    if ~isempty(options.processtype)
        m.processtype = options.processtype;
        if ~ismember(m.processtype,{'poisson'})
            error('Unrecognized process type (%s).',m.processtype);
        end
    end
    
    m.variance = 'low';
    if ~isempty(options.variance)
        m.variance = options.variance;
        if ~ismember(m.variance,{'low','med','high'})
            error('Unrecognized variance option (%s).',m.variance);
        end
    end

    m.numstatevars = 1;
    if ~isempty(options.numstatevars)
        m.numstatevars = options.numstatevars;
    end
end

m.dt = 1;
if ~isempty(options.dt)
    m.dt = options.dt;
end

if ~isempty(options.timelimit)
    m.timelimit = options.timelimit;
else
    m.timelimit = getModelTimeLimits(dataset,'neuraltype',options.neuraltype);
end

m.neuraltype = 'normal';
if ~isempty(options.neuraltype)
    m.neuraltype = options.neuraltype;
    if ~ismember(m.neuraltype,{'normal','idle'})
        error('Unrecognized neural type (%s).',m.neuraltype);
    end
end

m.lag = 0;
if ~isempty(options.lag)
    m.lag = options.lag;
end

m.includeparticipant = false;
m.includecompanion = false;

if ~isempty(options.includeparticipant)
    m.includeparticipant = options.includeparticipant;
end
if ~isempty(options.includecompanion)
    m.includecompanion = options.includecompanion;
end

if ~m.includeparticipant && ~m.includecompanion
    error('No word signal selected.')
end

% control condition
m.swapspeakers = false;
if options.swapspeakers
    m.swapspeakers = options.swapspeakers;
end

% control condition
m.fitnoise = false;
if ~isempty(options.fitnoise)
    m.fitnoise = options.fitnoise;
end

% control condition
m.shufflesignal = false;
if ~isempty(options.shufflesignal)
    m.shufflesignal = options.shufflesignal;
end

m.wordtypes = 'all';
if ~isempty(options.wordtypes)
    m.wordtypes = options.wordtypes;
end
