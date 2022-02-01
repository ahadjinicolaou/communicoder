function [cmap] = getLabelIndexMap(labels)
% GETLABELINDEXMAP Convenience function, e.g., uses output of
%   LOADFITRESULTS to create a channel index -> channel label lookup.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

cmap = containers.Map('keytype','uint32','valuetype','char');
for ii = 1:numel(labels)
    cmap(ii) = labels{ii};
end
