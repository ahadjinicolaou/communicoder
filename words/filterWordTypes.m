function [words] = filterWordTypes(words,winfo,wtypes)
% FILTERWORDTYPES Filters words based on WTYPES specification. Included
%   word types should be separated by pluses, e.g.:
%       noun+verb+adjective
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

wtypes = unique(strsplit(wtypes,'+'));
if ~all(ismember(wtypes,winfo.name)), error('Invalid word type(s).'), end

for ii = 1:2
    if ii == 1, sname = 'participant'; else, sname = 'companion'; end
    
    % get the word codes for the given word types
    tidx = find(ismember(winfo.name,wtypes));
    codes = winfo.code(tidx);

    % filter the words
    w = words.(sname);
    widx = find(ismember(w.code,codes));
    fnames = fieldnames(w);
    for jj = 1:numel(fnames)
        d = w.(fnames{jj});
        w.(fnames{jj}) = d(widx);
    end
    
    words.(sname) = w;
end

