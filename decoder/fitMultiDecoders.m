function fitMultiDecoders(datasets,varargin)
% FITMULTIDECODERS Fits all possible combinations of neural decoders that
%   are implied by the input parameters. The complete form for each
%   parameter is listed below:
%       a) "p+c+pc", for SPEAKERS
%           (this implies three speaker combinations, comprised of
%           participant, companion, and participant+companion)
%       b) [L1, L2, ..., Ln], for LAGS
%       c) "n+i", for NEURALTYPES (normal and idle)
%       d) "n+s", for SIGNALTYPES (normal and shuffled).
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'speakers',[],...
    'lags',[],...
    'neuraltypes',[],...
    'signaltypes',[],...
    'signal','wordcount',...
    'skipmulticontrols',true,...
    'verbose',true);
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

speakers = options.speakers;
neuraltypes = options.neuraltypes;
signaltypes = options.signaltypes;
if isempty(speakers), speakers = 'p'; end
if isempty(neuraltypes), neuraltypes = 'n'; end
if isempty(signaltypes), signaltypes = 'n'; end

lags = options.lags;
speakers = strsplit(speakers,'+');
neuraltypes = strsplit(neuraltypes,'+');
signaltypes = strsplit(signaltypes,'+');

sigstr = options.signal;
if strcmp(sigstr,'wordcount')
    sigstr = 'wc';
end

% might be a big number!
modelcount = numel(lags) * numel(speakers) * numel(datasets) * ...
    numel(neuraltypes) * numel(signaltypes);

tic;
modelnum = 1;
for gg = 1:numel(lags)
    for pp = 1:numel(speakers)
        includecompanion = contains(speakers(pp),'p');
        includeparticipant = contains(speakers(pp),'c');
        
        for nn = 1:numel(neuraltypes)
            neuraltype = 'normal';
            if strcmp(neuraltypes(nn),'i')
                neuraltype = 'idle';
            end
                
            for ss = 1:numel(signaltypes)
                shufflesignal = contains(signaltypes(ss),'s');
            
                for dd = 1:numel(datasets)
                    [m,spaths,words] = getModelWorkspace(datasets{dd},...
                        'signal',sigstr,'lag',lags(gg),...
                        'includeparticipant',includeparticipant,...
                        'includecompanion',includecompanion,...
                        'shufflesignal',shufflesignal,...
                        'neuraltype',neuraltype);
                    
                    if options.verbose
                        fprintf('\t(%d/%d) %s, lag[%d], ntype[%s], stype[%s], %s\n',...
                            modelnum,modelcount,sigstr,lags(gg),neuraltypes{nn},...
                            signaltypes{ss},m.dataset)
                    end
                    
                    fitModel(m,'spaths',spaths,'words',words)
                    modelnum = modelnum + 1;
                end
            end
        end
    end
end

if options.verbose
    numhours = toc/3600;
    fprintf('\t\tDone in %1.1f hours.\n\n',numhours);
end
