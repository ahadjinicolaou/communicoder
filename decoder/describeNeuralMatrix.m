function [desc] = describeNeuralMatrix(dtype,fbands)
% DESCRIBENEURALMATRIX Returns a string that describes a neural predictor
%   matrix's data content: frequency bands and data type.
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

if ~iscell(fbands), fbands = mat2cell(fbands,ones(size(fbands,1),1)); end
desc = arrayfun(@(x) sprintf('%d-%dHz',x{1}),fbands,'uniformoutput',false);
desc = sprintf('%s__%s',dtype,strjoin(desc,'__'));
