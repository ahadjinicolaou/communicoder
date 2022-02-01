function [words,duration] = extractConversationWordOnsets(words,trange,varargin)
% EXTRACTCONVERSATIONWORDONSETS Extract words from input structure whose
%   extents lie within the time interval TRANGE.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'mergecoincident',false,...
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

duration = 0;
speakers = {'participant','companion'};

for ii = 1:numel(speakers)
    data = words.(speakers{ii});
    blacklist = data.onset < trange(1) | data.offset > 0.999*trange(2);
    
    % remove words outside the requested range
    fnames = fieldnames(data);
    for jj = 1:numel(fnames)
        data.(fnames{jj})(blacklist) = [];
    end

    % reset t=0 using trange
    data.onset = data.onset - trange(1);
    data.offset = data.offset - trange(1);
    duration = max([duration, ceil(trange(2)-trange(1))]);
    
    words.(speakers{ii}) = data;
end

% remove coincident words
if options.mergecoincident
    for ii = 1:numel(speakers)
        data = words.(speakers{ii});
        numwords = numel(data.onset);
        [~,idx] = unique(data.onset);
        fnames = fieldnames(data);
        for jj = 1:numel(fnames)
            data.(fnames{jj}) = data.(fnames{jj})(idx);
        end

        if options.verbose
            fprintf('\tRemoved %d (%1.2f%%) coincident %s words.\n',...
                numwords-numel(idx),100*(1-(numel(idx)/numwords)),speakers{ii});
        end
        
        words.(speakers{ii}) = data;
        
        if ii == numel(speakers), fprintf('\n'); end
    end
end
