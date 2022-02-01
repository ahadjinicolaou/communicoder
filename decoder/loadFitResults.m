function [r,filename] = loadFitResults(modeldir,varargin)
% LOADFITRESULTS Load the model fit results
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'dtype',[],...
    'fbands',[],...
    'filename',[]);
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

if ~ischar(modeldir)
    modeldir = getModelDirectory(modeldir);
end

if ~isempty(options.filename)
    % model filename contains description
    fparts = split(replace(options.filename,'.mat',''),'__');
    % stick it all back together
    desc = strjoin(fparts(2:end),'__');
elseif isempty(options.dtype) || isempty(options.fbands)
    error(['Either (a) a model filename, or (b) both datatype and ',...
        'frequency band arguments must be supplied.']);
else
    desc = describeNeuralMatrix(options.dtype,options.fbands);
end

filename = sprintf('predset__%s.mat',desc);
r = load(fullfile(modeldir,filename));
