function [perfs] = getDecoderPerformance(models,varargin)
% GETDECODERPERFORMANCE Get performance for all input model specifications.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'overwrite',false,...
    'fit','lasso');
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

if ~iscell(models), models = {models}; end

numdatasets = numel(models);
perfs = cell(numdatasets,1);
for ii = 1:numdatasets
    m = models{ii};
    spaths = getWorkspacePaths(models{ii});
    perfs{ii} = evalDecoderPerformance(spaths.modeldir,...
        'signaldist',m.signaldist,...
        'fit',options.fit,'overwrite',options.overwrite);
    perfs{ii}.m = m;
end
