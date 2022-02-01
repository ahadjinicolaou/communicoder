function [modeldir] = getModelDirectoryName(m)
% GETMODELDIRECTORYNAME Uses behavioral model specification to generate a
%   folder name for the corresponding model data.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

dtstr = sprintf('dt[%s]',num2str(m.dt));

tstr = sprintf('tlim[%d-%d]',round(m.timelimit(1)),round(m.timelimit(2)));

if strcmp(m.signal,'wordcount')
    sigstr = 'wc'; sigsubstr = ''; sigdiststr = '';
    if m.includeparticipant, sigsubstr = 'p'; end
    if m.includecompanion, sigsubstr = [sigsubstr,'c']; end
    if ~strcmp(m.signaldist,'normal'), sigdiststr = ['-',m.signaldist]; end
end
sigstr = sprintf('signal[%s-%s%s]',sigstr,sigsubstr,sigdiststr);

lstr = '';
if abs(m.lag)
    lstr = sprintf('lag[%d]',m.lag);
end

% behavioral control options
sigoptstr = '';
if m.swapspeakers || m.fitnoise || m.shufflesignal
    sigopts = {};
    if m.swapspeakers, sigopts = [sigopts,'swap']; end
    if m.fitnoise, sigopts = [sigopts,'noise']; end
    if m.shufflesignal, sigopts = [sigopts,'shuffle']; end

    sigopts = sigopts(cellfun(@(x) ~isempty(x),sigopts));
    sigopts = strjoin(sigopts,'-');
    sigoptstr = sprintf('sigopts[%s]',sigopts);
end

% neural control options
nstr = '';
if ~strcmp(m.neuraltype,'normal')
    nstr = sprintf('neural[%s]',m.neuraltype);
end

wstr = '';
if ~strcmp(m.wordtypes,'all')
    wstr = sprintf('words[%s]',replace(m.wordtypes,'+','-'));
end

stubs = {dtstr,tstr,lstr,sigstr,sigoptstr,nstr,wstr};
stubs = stubs(cellfun(@(x) ~isempty(x),stubs));

modeldir = strjoin(stubs,'__');
