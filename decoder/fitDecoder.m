function fitDecoder(m,varargin)
% FITDECODER takes a model blueprint (i.e., the output of GETMODELDEFAULTS)
%   and uses it to train a neural decoder. The training pipeline involves:
%       1) creating the behavioral signal (intent state or word rate),
%       2) generating spectral estimates in several frequency bands,
%       3) allocating train/test partitions, and
%       4) fitting lasso-regularized GLMs.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'spaths',[],...
    'words',[],...
    'wordroundunit',[],...
    'applywordtimingoffset',true,...
    'freqbands','default',...
    'numstateiterations',100,...
    'statevariance',[],...
    'previewbehavioralsignal',false,...
    'overwritebehavioralsignal',false,...
    'overwriteexistingdecoders',false,...
    'fitbehavioralmodelonly',false,...
    'standardizepredictors',true,...
    'maxbandcombinations',2,...
    'numouterfolds',5,...
    'verbose',true);
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

% load supporting model data if not supplied
words = options.words;
spaths = options.spaths;
if isempty(spaths), spaths = getWorkspacePaths(m); end
if isempty(words)
    words = prepareConversationWords(spaths.wordsetdir,m.dataset,...
        'applytimingoffset',options.applywordtimingoffset,...
        'roundunit',options.wordroundunit,...
        'wordtypes',m.wordtypes,...
        'verbose',options.verbose);
end

% generate behavioral signal
if ~isModelFitted(spaths.modeldir) || options.overwritebehavioralsignal
    % use a low iteration count for model preview (applies to state model)
    if options.previewbehavioralsignal
        options.numstateiterations = 5;
    end
    
    [out,par] = fitModel(m,words,...
        'numstateiterations',options.numstateiterations);
    
    % save the behavioral model (if not previewing)
    if ~options.previewbehavioralsignal
        if ~exist(spaths.modeldir,'dir'), mkdir(spaths.modeldir), end
        if strcmp(m.signal,'state')
            save(fullfile(spaths.modeldir,'model.mat'),'m','par','out');
        else
            save(fullfile(spaths.modeldir,'model.mat'),'m','out');
        end
    end
else
    % load the model
    out = loadModel(spaths.modeldir);
    fprintf('\tLoaded existing model (%s).\n\n',spaths.modelname);
end

if options.previewbehavioralsignal
    plotBehavioralSignal(out,words,'yticks',0:3:9,...
        'showparticipantwords',m.includeparticipant,...
        'showcompanionwords',false)
end

% checkpoint for diagnostic purposes
if options.fitbehavioralmodelonly, return, end

% frequency band specification should be either a cell array of 2-element
% vectors, or a string to indicate a preset ('default' is the only
% recognized preset for now)
if iscell(options.freqbands)
    allbands = options.freqbands;
elseif ischar(options.freqbands) && strcmp(options.freqbands,'default')
    allbands = {[4 8],[8 12],[12 30],[30 50],[70 115],[125 200]};
else
    error('Unrecognized frequency band specification.')
end

% evaluate all n-choose-k frequency band combinations
for kk = 1:options.maxbandcombinations
    freqbandcombs = combnk(allbands,kk);
    nchoosek = size(freqbandcombs,1);
    if options.verbose
        fprintf('\tTraining GLMs for all n-choose-%d=%d band combinations.\n',kk,nchoosek);
    end
    
    for ii = 1:nchoosek
        fbands = freqbandcombs(ii,:);
        % process and split data into train/test partitions
        % rank coefficients by their standardized lassoglm coefficients
        makeTrainTestPartitions(spaths.modeldir,spaths.neuraldir,...
            'pow',fbands,m.timelimit,words,...
            'numfolds',options.numouterfolds,...
            'overwrite',options.overwriteexistingdecoders,...
            'verbose',options.verbose);

        fitLassoCoefficients(spaths.modeldir,'pow',fbands,'signaldist',m.signaldist,...
            'overwrite',options.overwriteexistingdecoders,'verbose',options.verbose,...
            'standardizepredictors',options.standardizepredictors,...
            'dfmax','variable');
    end
end
