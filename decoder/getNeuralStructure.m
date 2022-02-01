function [N] = getNeuralStructure(neuraldir,dtype,fbands,varargin)
% GETNEURALSTRUCTURE
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'timelimit',[],...
    'removeflats',true,...
    'verbose',false);
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

zfiles = arrayfun(@(x) sprintf('%s__%d-%dHz.mat',dtype,x{1}),fbands,'uniformoutput',false);
%zfiles = cellfun(@(x) sprintf('%s__%s.mat',dtype,x{1}),zfiles,'uniformoutput',false);
numbands = numel(zfiles);
N = [];

% load and concatenate data from each file
for ii = 1:numbands
    d = load(fullfile(neuraldir,zfiles{ii}));
    
    if isempty(N)
        tlim = d.t([1 end])';
        tmask = true(size(d.t));
        if ~isempty(options.timelimit)
            tlim = options.timelimit;
            tmask(d.t < tlim(1) | d.t > tlim(2)) = false;
        end
        
        N.dtype = dtype;
        N.Z = d.(dtype)(tmask,:);
        N.t = d.t(tmask);
        N.t = N.t - N.t(1);
        N.labels = d.labels;
        N.fbands = fbands;
        N.bandidx = ones(size(d.labels));
        N.tlim = tlim;
    else
        N.Z = [N.Z, d.(dtype)(tmask,:)];
        N.labels = [N.labels, d.labels];
        N.bandidx = [N.bandidx, ii*ones(size(d.labels))];
    end
end

% exclude flat channels
if options.removeflats
    flatmask = ~any(N.Z);
    numflats = sum(flatmask);
    if numflats > 0
        N.Z(:,flatmask) = [];
        N.labels(flatmask) = [];
        N.bandidx(flatmask) = [];
        if options.verbose
            warning('Removed %d flat channels.',numflats);
        end
    end
end

% aesthetics
if size(N.t,1) < size(N.t,2), N.t = N.t'; end
