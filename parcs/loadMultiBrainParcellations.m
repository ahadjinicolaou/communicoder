function emaps = loadMultiBrainParcellations(models,varargin)
% LOADMULTIBRAINPARCELLATIONS Convenience method for LOADBRAINPARCELLATIONS
%   that loads the parcellations for each input model dataset.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'bipolarizeras',true,...
    'pthresh',0);
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

nummodels = numel(models);
emaps = cell(nummodels,1);
for ii = 1:nummodels
    spaths = getWorkspacePaths(models{ii});
    emaps{ii} = loadBrainParcellations(spaths.parcpath,...
        'bipolarizeras',options.bipolarizeras,'pthresh',options.pthresh);
    emaps{ii}.dataset = models{ii}.dataset;
end
