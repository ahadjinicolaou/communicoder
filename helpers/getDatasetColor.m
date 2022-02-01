function color = getDatasetColor(dataset,varargin)
% GETDATASETCOLOR
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'cmap','set2',...
    'lighter',[],...
    'darker',[]);
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

if ismember(options.cmap,{'set2'})
    colors = brewermap(8,options.cmap);
else
    % using eval makes me feel bad
    eval(sprintf('colors = %s(8)',options.cmap));
end

if strcmp(dataset,'MG111')
    color = colors(1,:);
elseif strcmp(dataset,'MG115')
    color = colors(2,:);
elseif strcmp(dataset,'MG117')
    color = colors(3,:);
elseif strcmp(dataset,'MG118')
    color = colors(4,:);
elseif strcmp(dataset,'MG120')
    color = colors(5,:);
elseif strcmp(dataset,'MG130')
    color = colors(6,:);
end

if ~isempty(options.lighter)
    color = getLighterColor(color,options.lighter);
elseif ~isempty(options.darker)
    color = getDarkerColor(color,options.darker);
end
