function [words] = prepareConversationWords(wordsetdir,dataset,varargin)
% PREPARECONVERSATIONWORDS
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'applytimingoffset',true,...
    'roundunit',[],...
    'wordtypes','all',...
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

% wordsets.mat generated from LOADCONVERSATIONWORDSETS
load(fullfile(wordsetdir,'wordsets.mat'),'datasets','wordsets')
load(fullfile(wordsetdir,'wordinfo.mat'),'wordinfo')
timelimit = getModelTimeLimits(dataset);

didx = find(strcmp(dataset,datasets),1);
if isempty(didx)
    error('Dataset %s could not be found in the wordset.',dataset);
end
words = wordsets{didx};
words.timelimit = timelimit;

% shift the timing of words (synced to NSP1) whose neural recordings have
% been synchronized by MERGE2BANKS, which shifts NSP1 to match NSP2
if options.applytimingoffset
    [words,numexcluded] = applyWordTimingOffset(words,dataset);
    if options.verbose
        fprintf('\tTiming offset applied (delta=%1.2f s; %d words removed).\n',...
            words.timingoffset,numexcluded);
    end
end

% filter word type
if ~strcmp(options.wordtypes,'all')
    words = filterWordTypes(words,wordinfo,options.wordtypes);
end

% bin the word times for point process
if ~isempty(options.roundunit)
    runit = options.roundunit;
    words.participant.onset = roundToNearestUnit(words.participant.onset,runit);
    words.companion.onset = roundToNearestUnit(words.companion.onset,runit);
end

% ~1% of words are fast enough (sub-50 ms word interval) such that
% there will be >1 word per time bin, but for the sake of computational
% sanity we're going to be merging these together as a single word.
% 
% These fast words are usually colloquial, where multiple words get
% mashed together (e.g. Why >dont|cha< do it?).
words = extractConversationWordOnsets(words,timelimit,'mergecoincident',false);
