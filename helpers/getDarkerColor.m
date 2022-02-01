function [darker] = getDarkerColor(color, factor)
% DARKERCOLOR(COLOR) returns an interpolated color ranging between the
%   input color and black (FACTOR = 0 -> 1).
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

if nargin == 1, factor = 0.2; end

if ~isnumeric(color) || numel(color) ~= 3
    error('Color must be a 3-element numeric vector.');
end

if factor < 0 || factor > 1
    error('Color factor must be a number between 0 and 1.');
end

nLevels = 21;
idx = 1+round(factor*(nLevels-1));
darker = nan(1,3);
for ii = 1:3
    range = linspace(color(ii),0,nLevels);
    darker(ii) = range(idx);
end
