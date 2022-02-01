function [words,numexcluded] = applyWordTimingOffset(words,dataset)
% APPLYWORDTIMINGOFFSET Account for the difference between multiple NSP
%	recordings that have been merged with MERGE2BANKS.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

offsets = [...
    -2.8539, -2.0130, -14.1405, -1.2495, ...
    -0.8310, 0, -0.9460];
datasets = {...
    'MG111','MG115','MG117','MG118',...
    'MG120','MG122','MG130'};
deltas = containers.Map(datasets,offsets);
if ~deltas.isKey(dataset)
    error('Dataset %s does not have a listed word timing offset.',dataset)
end

numexcluded = 0;
for speaker = {'participant','companion'}
    s = speaker{1};
    words.(s).onset = words.(s).onset + deltas(dataset);
    words.(s).offset = words.(s).offset + deltas(dataset);

    outside = words.(s).onset <= 0;
    if any(outside)
        words.(s).onset(outside) = [];
        words.(s).offset(outside) = [];
        words.(s).code(outside) = [];
        words.(s).word(outside) = [];
        numexcluded = numexcluded + sum(outside);
    end
end

words.timingoffset = deltas(dataset);
