function [out,par] = fitModel(m,words,varargin)
% FITMODEL takes a behavioral model specification (from GETMODELDEFAULTS)
%   and uses it to create a behavioral model. This can either be:
%       a) an intent state estimation, or
%       b) a simple word rate signal (word count per time bin).
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'statevariance',[],...
    'numstateiterations',[]);
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

par = [];

% generate the behavioral model
if strcmp(m.signal,'state')
    % NOTE: this has not been tested since the refactor!
    [par,y,ip,ic] = buildPoissonTerms(m.dt,m.timelimit,words,...
        'numiterations',options.numstateiterations,...
        'includecompanion',m.includecompanion,...
        'swapspeakers',m.swapspeakers,'s_n',options.statevariance);

    if isControlCondition(m)
        out = makeControlOutput(m,y);
    else
        try
            out = EM_SMC(par,y,ip,ic);
        catch
            % try tweaking c1 if EMC fails
            par.c(1) = -4;
            out = EM_SMC(par,y,ip,ic);
        end
    end
elseif strcmp(m.signal,'wordcount')
    duration = ceil(diff(m.timelimit));
    yp = histcounts(words.participant.onset,0:m.dt:duration)';
    yc = histcounts(words.companion.onset,0:m.dt:duration)';

    if m.swapspeakers, y = yp; yp = yc; yc = y; end

    y = zeros(size(yp));
    if m.includeparticipant, y = y + yp; end
    if m.includecompanion, y = y + yc; end

    out = [];
    out.t = (m.dt*(0:numel(y)-1))';
    out.dt = m.dt;
    out.y = y;

    % for compatibility
    out.x = y;
    out.s = zeros(size(y));
else
    error('Unrecognized signal type (%s).',m.signal)
end

if m.lag
    out.x = circshift(out.x,m.lag);
    out.s = circshift(out.s,m.lag);
    out.x(end+m.lag:end) = 0;
    out.s(end+m.lag:end) = 0;
end

if m.shufflesignal
    idx = randperm(numel(out.x));
    out.x = out.x(idx);
    out.s = out.s(idx);
end
