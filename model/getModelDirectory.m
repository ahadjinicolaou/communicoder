function modeldir = getModelDirectory(m)
% GETMODELDIRECTORY Returns the model directory given the input model
%	specification.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

if ~(isfield(m,'dataset') && isfield(m,'timelimit') && isfield(m,'dt'))
    error('Supplied input does not look like a model structure.');
end

spaths = getWorkspacePaths(m);
modeldir = spaths.modeldir;
