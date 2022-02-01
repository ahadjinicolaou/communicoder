function isfitted = isModelFitted(modeldir)
% ISMODELFITTED Checks to see if a model directory has its model data file.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

% assume we're dealing with a model struct if not a directory
if isstruct(modeldir)
    spaths = getWorkspacePaths(modeldir);
    modeldir = spaths.modeldir;
end

modelfile = fullfile(modeldir,'model.mat');
isfitted = exist(modelfile,'file');
