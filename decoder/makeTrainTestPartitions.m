function makeTrainTestPartitions(modeldir,neuraldir,dtype,fbands,timelimit,words,varargin)
% MAKETRAINTESTPARTITIONS
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'logz',true,...
    'overwrite',false,...
    'verbose',false,...
    'rhothresh',[],...
    'numfolds',5);
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

desc = describeNeuralMatrix(dtype,fbands);
datafile = fullfile(modeldir,sprintf('predset__%s.mat',desc));

% skip fitting if we've got precomputed fits (and we're not overwriting them)
if ~options.overwrite && exist(datafile,'file')
    if options.verbose
        fprintf('\t\tExisting partition file found (%s).\n',desc);
    end
    return
end

% load the neural data
N = getNeuralStructure(neuraldir,dtype,fbands,'timelimit',timelimit);
if options.logz, N.Z = log(N.Z); end
labels = N.labels;

% load the behavioral model
[out] = loadBehavioralModel(modeldir);

% downsample and split into train/test partitions
[Z,t,x,s] = getDownsampledData(N.Z,N.t,out.dt,out.x,out.s,...
    'verbose',options.verbose);
folds = makeTrainTestFolds(numel(t),'numfolds',options.numfolds);

% bundle the neural data
neural.Z = Z;
neural.t = t;
neural.x = x;
neural.s = s;

% get the word onsets
onsets.participant = words.participant.onset;
onsets.companion = words.companion.onset;

% write to disk
save(datafile,'folds','neural','onsets','desc','labels');
