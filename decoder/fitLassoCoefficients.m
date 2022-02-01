function fitLassoCoefficients(modeldir,dtype,fbands,varargin)
% FITLASSOCOEFFICIENTS Works out the most informative predictors for
%   the target variable (e.g. intent state).
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'standardizepredictors',false,...
    'lassocv',5,...
    'lambda',logspace(-1,-5,40),...
    'signaldist','normal',...
    'dfmax','variable',...
    'numsamplesperbin',150,...
    'numbins',7,...
    'resample',false,...
    'overwrite',false,...
    'permtest',false,...
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

desc = describeNeuralMatrix(dtype,fbands);
datafile = fullfile(modeldir,sprintf('predset__%s.mat',desc));
d = load(datafile);

%save(datafile,'folds','neural','onsets','desc','labels');

if ~isfield(d,'lasso') || options.overwrite
    for ii = 1:numel(d.folds)
        x = d.neural.x(d.folds(ii).trainidx);
        Z = d.neural.Z(d.folds(ii).trainidx,:);
        
        if options.resample
            % partition and resample training data to account for nonuniform X dist
            xedges = linspace(min(x),max(x),options.numbins+1);
            [~,xidx] = getPartitionSamples(x,xedges,...
                'samplesperbin',options.numsamplesperbin,...
                'validate',true);
            x = x(xidx);
            Z = Z(xidx,:);
        end

        % max number of nonzero coefficients
        dfmax = 150;
        if options.dfmax
            if strcmp(options.dfmax,'variable')
                numbands = size(fbands,1);
                dfmax = 120 + (numbands-1)*50;
            else
                dfmax = options.dfmax;
            end
        end

        [coeffset,fitinfo] = lassoglm(Z,x,options.signaldist,'standardize',true,...
            'dfmax',dfmax,'lambda',options.lambda,'cv',options.lassocv,...
            'standardize',options.standardizepredictors);

        % make lambda directions match in FITINFO and TESTEDLAMBDAS
        if options.lambda(1) > options.lambda(end)
            options.lambda = fliplr(options.lambda);
        end

        lambda = fitinfo.Lambda(1);

        x = [];
        x.coeffset = coeffset;
        x.interceptset = fitinfo.Intercept;
        x.numpredictors = sum(abs(coeffset) > 0);
        x.lambdas = fitinfo.Lambda;
        x.testedlambdas = options.lambda;
        x.firstlambdaidx = find(abs(lambda-x.testedlambdas) < 1e-6);
        x.fitinfo = fitinfo;
        d.lasso(ii) = x;
    end
elseif options.verbose
    fprintf('\t\tExisting lasso rank found (%s).\n',desc);
end

% update data on disk
save(datafile,'-struct','d');
