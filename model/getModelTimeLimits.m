function tlim = getModelTimeLimits(dataset,varargin)
% GETMODELTIMELIMITS Returns an observation interval for the input
%   dataset, which depends on the type of neural data used to train the
%   model. For 'control' models (e.g., those trained on non-social neural
%   data recorded during a non-experimental observation interval), the
%   interval is fixed at [0 1200].
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'neuraltype',[]);     
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

tlim = 0;

if isempty(options.neuraltype), options.neuraltype = 'normal'; end

if ~strcmp(options.neuraltype,'normal')
    tlim = tlim + [0 1200];
else
    if ismember(dataset,{'MG111'})
        tlim = tlim + 1000 + [0 1200];
    elseif ismember(dataset,{'MG115'})
        tlim = tlim + 220 + [0 1200];
    elseif ismember(dataset,{'MG117'})
        tlim = tlim + 1000 + [0 1200];
    elseif ismember(dataset,{'MG120'})
        tlim = tlim + 1400 + [0 1200];
    elseif ismember(dataset,{'MG122'})
        tlim = tlim + 1195 + [0 1200];
    elseif ismember(dataset,{'MG130'})
        tlim = tlim + 200 + [0 1200];
    else
        tlim = tlim + [0 1200];
    end
end
