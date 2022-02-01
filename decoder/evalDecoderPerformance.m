function [perf] = evalDecoderPerformance(modeldir,varargin)
% EVALDECODERPERFORMANCE Evaluates the performance metrics for
%	each pre-computed/fitted model found in MODELDIR.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'fit','lasso',...
    'overwrite',false,...
    'permtest',false,...
    'numperms',100,...
    'signaldist','identity',...
    'standardize',true,...
    'verbose',false);
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

if ~ismember(options.fit,{'lasso'})
    error('Unrecognized fit type (%s).',options.fit);
end

% see if an existing performance file is available
% recompute if (a) overwriting or (b) predcount inconsistency found
perffile = fullfile(modeldir,sprintf('perf__%s.mat',options.fit));
if exist(perffile,'file')
    if ~options.overwrite
        if options.verbose
            fprintf('\t\tExisting performance file found; skipping.\n');
        end
        perf = load(perffile);
        return
    end
    if options.verbose, fprintf('\t\tOverwriting existing performance file.\n'); end
end

% load up the coefficient fit results
rfiles = dir(fullfile(modeldir,'predset__*'));
predsets = natsort({rfiles.name}');
predsets = replace(predsets,'predset__','');
predsets = replace(predsets,'.mat','');
numpredsets = numel(predsets);

% get the folds
datafile = fullfile(modeldir,sprintf('predset__%s.mat',predsets{1}));
dd = load(datafile);
numfolds = numel(dd.folds);
numtestedlambdas = numel(dd.lasso(1).testedlambdas);

% initialize performance structure
perf = [];
perf.predsets = predsets;
perf.testedlambdas = dd.lasso(1).testedlambdas;
perf.folds = dd.folds;
perf.rho = nan(numpredsets,numtestedlambdas,numfolds);
perf.rmse = perf.rho;
perf.predcounts = perf.rho;
perf.testedlambdaidx = nan(numel(predsets),1);
perf.fit = options.fit;

for ii = 1:numpredsets
    fname = strjoin({'predset',predsets{ii}},'__');
    d = loadFitResults(modeldir,'filename',fname);
    
    for jj = 1:numfolds
        res = d.lasso(jj);
        numlambdas = size(res.coeffset,2);
        kkoff = res.firstlambdaidx-1;
        
        for kk = 1:numlambdas
            bestidx = find(res.coeffset(:,kk));
            xtest = d.neural.x(perf.folds(jj).testidx);
            Ztest = d.neural.Z(perf.folds(jj).testidx,bestidx);

            if options.standardize, Ztest = zscore(Ztest); end

            % get the coefficients for the lambda index
            b0 = res.interceptset(kk);
            b =  res.coeffset(:,kk);
            b = b(bestidx);

            % evaluate predictions and performance metrics
            linkfn = 'identity';
            if strcmp(options.signaldist,'poisson')
                linkfn = 'log';
            end
            
            xhat = glmval([b0;b],Ztest,linkfn);
            %p = predrsq(xhat,xtest,Ztest,'hatmethod',false);

            % find index of first used lambda
            %isequal = abs(res.testedlambdas-res.lambdas(1)) < 1e-6;
            %jjoffset = find(isequal)-1;

            % compute correlation coefficient and rmse
            cc = corrcoef(xhat,xtest);
            rmse = sqrt(sum((xhat-xtest).^2)/numel(xhat));

            %perf.predrsq(ii,kk+kkoff,jj) = p;
            perf.rho(ii,kk+kkoff,jj) = cc(2);
            perf.rmse(ii,kk+kkoff,jj) = rmse;
            perf.predcounts(ii,kk+kkoff,jj) = numel(bestidx);
            perf.testedlambdaidx(ii,kk+kkoff,jj) = kk+kkoff;
        end
        
        [~,idxmax] = nanmax(perf.rho(ii,:,jj));
        perf.maxperfidx(ii,jj) = idxmax;
        perf.oneseidx(ii,jj) = res.fitinfo.Index1SE + kkoff;
        perf.mindevianceidx(ii,jj) = res.fitinfo.IndexMinDeviance + kkoff;
    end
end

% store performance data
save(perffile,'-struct','perf');
