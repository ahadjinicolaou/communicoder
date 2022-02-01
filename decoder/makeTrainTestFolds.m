function [folds] = makeTrainTestFolds(numsamples,varargin)
% MAKETRAINTESTFOLDS
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'numfolds',3,...
    'foldgappc',12.5,...
    'foldgaplength',[]);
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

offset = 0;
numfolds = options.numfolds;
numtestsamples = floor(numsamples/numfolds);

% dead zone around train set samples
gapsamples = floor((options.foldgappc/100)*numsamples);
if options.foldgaplength
    gapsamples = options.foldgaplength;
end
    
for ii = 1:numfolds
    f.testidx = (1:numtestsamples) + offset;
    f.trainidx = setdiff(1:numsamples,f.testidx);
    
    if gapsamples
        lzone = (f.testidx(1)-gapsamples):(f.testidx(1)-1);
        rzone = (f.testidx(end)+1):(f.testidx(end)+gapsamples);
        
        if ii == 1
            f.trainidx(f.trainidx <= rzone(end)) = [];
        elseif ii == numfolds
            f.trainidx(f.trainidx >= lzone(1)) = [];
        else
            f.trainidx(f.trainidx >= lzone(1) & f.trainidx <= rzone(end)) = [];
        end
    end
    
    folds(ii) = f;
    offset = offset + numtestsamples;
end

