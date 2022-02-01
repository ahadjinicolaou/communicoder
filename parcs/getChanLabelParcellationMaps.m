function [regmap,cidxmap] = getChanLabelParcellationMaps(cmap,emap)
% GETCHANLABELPARCELLATIONMAPS Convenience function, uses output of
%   LOADFITRESULTS and LOADBRAINPARCELLATIONS to create
%   channel label -> [region,parcchanidx] lookups.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

regmap = containers.Map('keytype','char','valuetype','char');
cidxmap = containers.Map('keytype','char','valuetype','uint32');
chanlabels = cmap.values;
for ii = 1:cmap.length
    chanlabel = chanlabels{ii};
    chanidx = find(strcmp(chanlabel,emap.parc.channels));
    
    if ~isempty(chanidx)
        regmap(chanlabel) = emap.parc.chanregions.name{chanidx};
        cidxmap(chanlabel) = chanidx;
    else
        regmap(chanlabel) = '';
        cidxmap(chanlabel) = nan;
    end
end
