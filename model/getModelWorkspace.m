function [m,spaths,words] = getModelWorkspace(dataset,varargin)
% GETMODELWORKSPACE Convenience function, merges the functionality of
%   GETMODELDEFAULTS, SETWORKSPACEPATHS and PREPARECONVERSATIONWORDS.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'verbose',false,...
    'signal',[],...
    'numstatevars',[],...
    'processtype',[],...
    'variance',[],...
    'timelimit',[],...
    'lag',[],...
    'dt',[],...
    'wordroundunit',[],...
    'applywordtimingoffset',true,...
    'includeparticipant',[],...
    'includecompanion',[],...
    'signaldist',[],...
    'swapspeakers',[],...
    'fitwordcount',[],...
    'fitnoise',[],...
    'shufflesignal',[],...
    'neuraltype',[],...
    'wordtypes',[]);
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

m = getModelDefaults(dataset,...
    'numstatevars',options.numstatevars,...
    'processtype',options.processtype,...
    'variance',options.variance,...
    'timelimit',options.timelimit,...
    'dt',options.dt,...
    'lag',options.lag,...
    'includeparticipant',options.includeparticipant,...
    'includecompanion',options.includecompanion,...
    'signaldist',options.signaldist,...
    'swapspeakers',options.swapspeakers,...
    'fitwordcount',options.fitwordcount,...
    'fitnoise',options.fitnoise,...
    'signaldist',options.signaldist,...
    'shufflesignal',options.shufflesignal,...
    'neuraltype',options.neuraltype,...
    'wordtypes',options.wordtypes);

spaths = getWorkspacePaths(m);

% read in conversation word data
% topic classification is still experimental (requires glove.6B.300d.txt)
% note that APPLYWORDTIMINGOFFSET should be set to FALSE before initial
% data preprocessing (including MERGE2BANKS) has been performed
words = prepareConversationWords(spaths.wordsetdir,m.dataset,...
    'applytimingoffset',options.applywordtimingoffset,...
    'roundunit',options.wordroundunit,...
    'wordtypes',m.wordtypes,...
    'verbose',options.verbose);
