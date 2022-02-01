function emap = loadBrainParcellations(parcpath,varargin)
% LOADBRAINPARCELLATIONS Loads RAS and parcellation files. Uses Stephen
%   Cobeldick's NATSORT to handle unordered channel entries,
%   e.g., LAT1 -> LAT10 -> LAT2, etc...
%
%   Outputs a struct (EMAP) that contains two fields:
%       * RAS, RAS channels and their coordinates,
%       * PARC, channels and their mapped region probabilities, taken from
%           the parcellations file.
%
%   By default, the RAS channel labels are bipolarized, with the original
%   RAS labels/coordinates stored in EMAP.RAS.ORIGINAL.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'raspath',[],...
    'bipolarizeras',true,...
    'reorderraschans',true,...
    'pthresh',0);
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

emap.ras = [];
emap.parc = [];

parcdir = fileparts(parcpath);
% assume that RAS file is in parent directory
if isempty(options.raspath)
    raspath = dir(fullfile(parcdir,'*_RAS.*'));
    raspath = fullfile(parcdir,raspath(1).name);
else
    raspath = options.raspath;
end

% complain if either RAS or parcellations file is missing
if ~exist(parcpath,'file'), error('Parcellations file not found.'); end
if ~exist(raspath,'file'), error('RAS file not found in parcellations base path.'); end

% complain if we can't find natsort
if options.reorderraschans && ~exist('natsort','file')
    error('This function needs NATSORT (unless you do not want to reorder the RAS channels.');
end

% load up parcellations file
% first column: [electrode], last two columns: [approx | elc_length]
[parcnum,parctxt] = xlsread(parcpath);
regionlabels = lower(parctxt(1,2:end-2));
chanlabels = parctxt(2:end,1);
probs = parcnum(:,1:end-2);

% replace underscores with hyphens in region names
% shorten superlong names a little
regionlabels = cellfun(@(x) regexprep(x,'_','-'),regionlabels,'uniformoutput',false);
regionlabels = cellfun(@(x) regexprep(x,'cingulate','cing'),regionlabels,'uniformoutput',false);

% use channel labels in the parcellations file to work out which electrode
% groups should not be bipolarized (the ones that don't contain a hyphen)
notbipolaridx = ~contains(chanlabels,'-');
notbipolar = unique(regexprep(chanlabels(notbipolaridx),'\d+$',''));

% process RAS file
[rascoords,rastxt] = xlsread(raspath);
raschans = rastxt(2:end,1);

% handle misordered RAS channel entries
if options.reorderraschans
    [raschans,ridx] = natsort(raschans);
    rascoords = rascoords(ridx,:);
end
chanstems = regexprep(raschans,'\d+$','');

% remove leading zeros
for ii = 1:numel(raschans)
    rasnum = str2double(regexp(raschans{ii},'\d+$','match'));
    raschans{ii} = sprintf('%s%d',chanstems{ii},rasnum);
end

emap.ras.channels = raschans;
emap.ras.coords = rascoords;

% make bipolarized channel labels
if options.bipolarizeras
    labels = cell(size(raschans));
    coords = nan(size(rascoords));
    for ii = 1:numel(raschans)
        if ismember(chanstems{ii},notbipolar)
            % storing non-bipolar contact data
            labels{ii} = raschans{ii};
            coords(ii,:) = rascoords(ii,:);
        elseif ii < numel(raschans)
            % group the two labels if their stem matches
            % average their RAS coordinates
            if strcmp(chanstems{ii},chanstems{ii+1})
                e1 = str2double(regexp(raschans{ii},'\d+','match'));
                e2 = str2double(regexp(raschans{ii+1},'\d+','match'));
                labels{ii} = sprintf('%s%d-%d',chanstems{ii},e1,e2);
                coords(ii,:) = mean(rascoords([ii,ii+1],:));
            end
        end
    end

    % save the rereferenced coords
    validentries = ~isnan(coords(:,1));
    emap.ras.original = emap.ras;
    emap.ras.channels = labels(validentries);
    emap.ras.coords = coords(validentries,:);
end

% now process the parcellations
% revise channel label format (LAB0Y-LAB0X -> LABX-Y)
numchannels = numel(chanlabels);
parcstems = cellfun(@(x) regexp(x,'^[A-Za-z]+','match'),chanlabels);
parcelecs = cellfun(@(x) str2double(fliplr(regexp(x,'\d+','match'))),...
    chanlabels,'uniformoutput',false);
parcchanlabels = cell(size(parcstems));
for ii = 1:numchannels
    elecstr = sprintf('%s%d',parcstems{ii},parcelecs{ii}(1));
    % bipolarize if necessary
    for jj = 2:numel(parcelecs{ii})
        elecstr = sprintf('%s-%d',elecstr,parcelecs{ii}(jj));
    end
    parcchanlabels{ii} = elecstr;
end

% isolate white matter columns
% wm probability -> maximum of both hemisphere probs
wmattermask = contains(regionlabels,'white-matter');
wm.prob = max(probs(:,wmattermask),[],2);
wm.logpwm = nan(size(wm.prob));
regionlabels = regionlabels(~wmattermask);
probs = probs(:,~wmattermask);

% work out most likely regions for each electrode
chanregions.name = cell(size(parcchanlabels));
chanregions.prob = zeros(size(parcchanlabels));
for ii = 1:numchannels
    [prob,idx] = max(probs(ii,:));
    if prob > options.pthresh
        chanregions.name{ii} = regionlabels{idx};
        chanregions.prob(ii) = prob;
    else
        chanregions.name{ii} = 'white-matter';
        chanregions.prob(ii) = wm.prob(ii);
    end
    
    wm.logpwm(ii) = log(prob/wm.prob(ii));
end

emap.parc.regions = regionlabels;
emap.parc.channels = parcchanlabels;
emap.parc.probs = probs;
emap.parc.chanregions = chanregions;
emap.parc.wm = wm;

if numel(emap.ras.channels) ~= numel(emap.parc.channels)
    warning('RAS and parcellation channel counts differ.');
end
