function [spaths] = getWorkspacePaths(m,varargin)
% GETWORKSPACEPATHS
%
% Alex Hadjinicolaou <a.e.hadjinicolaou@gmail.com>

options = struct(...
    'checkexists',false,...
    'addpath',false,...
    'basedir',[],...
    'wordsetdir','D:\MATLAB\wordsets',...
    'datadir','E:\communicoder\datasets',...
    'parcdir','E:\raw\parcellations');
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

% use the parent directory as BASEDIR if this hasn't been supplied
% childdirs of this directory are used to store model/decoder fits:
%   BASEDIR
%   |__ output
%       |__ datasetx
%       |__ datasety
if isempty(options.basedir)
    options.basedir = fileparts(mfilename('fullpath'));
end

if options.addpath
    % BASEDIR (communicoder home directory) should contain this file
    % below code adds all relevant toolbox directories to path
    dirs = dir();
    blacklist = {'.','..','datasets','images','output','.git'};
    for ii = 1:numel(dirs)
        if dirs(ii).isdir && ~ismember(dirs(ii).name,blacklist)
            if ismember(dirs(ii).name,{'external'})
                addpath(genpath(dirs(ii).name));
            else
                addpath(dirs(ii).name);
            end
        end
    end
end

% DATADIR holds the datasets, and should have the following structure:
%   DATADIR
%   |__ datasetx
%   |   |__ pow/coh
%   |   |__ labels.mat
%   |__ convdata.mat
% prepare paths structure
spaths.dataset = m.dataset;
spaths.basedir = options.basedir;
spaths.datasetdir = options.datadir;
spaths.wordsetdir = options.wordsetdir;

if strcmp(m.neuraltype,'normal')
    spaths.neuraldir = fullfile(spaths.datasetdir,m.dataset);
else
    spaths.neuraldir = fullfile(spaths.datasetdir,m.neuraltype,m.dataset);
end

spaths.outputdir = fullfile(options.basedir,'output',m.dataset);
spaths.modelname = getModelDirectoryName(m);
spaths.modeldir = fullfile(spaths.outputdir,spaths.modelname);

if ~exist(spaths.outputdir,'dir')
    mkdir(spaths.outputdir);
elseif options.checkexists
    warning('Model %s:%s exists.',m.dataset,spaths.modelname);
end

% PARCDIR holds the parcellations base directory
% load the parcellations file if specified
if strcmp(m.dataset,'MG111')
    parcfile = 'MG111_aparc.DKTatlas40_electrodes_cigar_r_3_l_4_bipolar_v2.csv';
elseif ismember(m.dataset,{'MG115'})
    parcfile = 'MG115_aparc.DKTatlas40_electrodes_cigar_r_3_l_4_bipolar.csv';
elseif ismember(m.dataset,{'MG117'})
    parcfile = 'MG117_aparc.DKTatlas40_electrodes_cigar_r_3_l_4_bipolar.csv';
elseif ismember(m.dataset,{'MG118'})
    parcfile = 'MG118_aparc.DKTatlas40_electrodes_cigar_r_3_l_4_bipolar.csv';
elseif ismember(m.dataset,{'MG120'})
    parcfile = 'MG120_aparc.DKTatlas40_electrodes_cigar_r_3_l_4_bipolar.csv';
elseif ismember(m.dataset,{'MG122'})
    parcfile = 'MG122_Revised_aparc.DKTatlas40_electrodes_cigar_r_3_l_4_bipolar.csv';
elseif ismember(m.dataset,{'MG130'})
    parcfile = 'MG130_aparc.DKTatlas40_electrodes_cigar_r_3_l_4_bipolar.csv';
end

if ~isempty(options.parcdir) && exist('parcfile','var')
    spaths.parcpath = fullfile(options.parcdir,m.dataset,parcfile);
    if ~exist(spaths.parcpath,'file')
        warning('Specified parcellations file not found.');
    end
end
