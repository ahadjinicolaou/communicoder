function d = roundToNearestUnit(d, unit)
% ROUNDTONEARESTUNIT Rounds to the nearest unit!
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

d = round(d/unit)*unit;
