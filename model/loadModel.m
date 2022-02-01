function [out,m,par] = loadModel(modeldir)
% LOADMODEL
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

% assume we're dealing with a model struct if not a directory
if isstruct(modeldir)
    spaths = getWorkspacePaths(modeldir);
    modeldir = spaths.modeldir;
end

modelfile = fullfile(modeldir,'model.mat');
if contains(modeldir,'state')
    load(modelfile,'m','par','out');
else
    load(modelfile,'m','out');
end