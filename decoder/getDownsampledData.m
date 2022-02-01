function [Z,t,x,s] = getDownsampledData(Z,t,dt,x,s,varargin)
% GETDOWNSAMPLEDDATA
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'standardize',false,...
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

% standardize neural features
if options.standardize
	Z = (Z - mean(Z,1))./repmat(std(Z,[],1),size(Z,1),1);
    if options.verbose
        fprintf('\tNeural matrix standardized.\n');
    end
end

numoriginalsamples = numel(t);

% take samples corresponding to state time points
% stores the indices of tx whose time values can be found in t
tx = dt*((1:numel(x))-1);
zsamples = [];
for ii = 1:numel(tx)
    if any(abs(tx(ii)-t) < 1e-6)
        zsamples(end+1) = ii;
    end
end

Z = Z(zsamples,:);
t = tx(zsamples);
t = t' - t(1);

sampleratio = round(numoriginalsamples/numel(zsamples),1);
if options.verbose && (sampleratio <0.99 || sampleratio > 1.01)
    fprintf('\tDownsampled neural data, N=%d -> %d (x%1.0f).\n',numoriginalsamples,...
       numel(zsamples),sampleratio);
end

% trim a sample off x, s if necessary
if numel(x) > numel(t)
    numel(x)
    numel(t)
    delta = numel(x)-numel(t);
    if delta > 1
        error('Sample counts vary by more than one...');
    end
    
    x = x(1:numel(t));
    s = s(1:numel(t));
end
