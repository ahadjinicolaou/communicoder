function aliases = getDatasetAliases(datasets)
% GETDATASETALIASES
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

if ~iscell(datasets), datasets = {datasets}; end

% might be best to do it explicitly
m = containers.Map(...
    {'MG111','MG115','MG117','MG118','MG120','MG130'},...
    {'S1','S2','S3','S4','S5','S6'});

aliases = cellfun(@(x) m(x),datasets,'uniformoutput',false);

% if size(datasets,2) > size(datasets,1), datasets = datasets'; end
% 
% renamed = cell(size(datasets));
% codes = {'MG'};
% 
% % replaced when we consider other patient designations
% if ~all(contains(datasets,'MG')), error('Unhandled!'); end
% 
% offset = 0;
% for ii = 1:numel(codes)
%     cmask = contains(datasets,codes{ii});
%     if sum(cmask) > 0
%         nums = compose('%d',offset + (1:sum(cmask)))';
%         renamed(cmask) = cellfun(@(x) sprintf('S%s',x),nums,'uniformoutput',false);
%         offset = sum(cmask);
%     end
% end
