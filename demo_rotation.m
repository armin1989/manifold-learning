% This script tests the performance three different denoising algorithms as
% follows:
% - NLEM : The non-local Euclidean median approach
% - VNLEM : The vector non-local Euclidean median approach that uses the
%           RID as measure of distance between vectors of patches.
%  - DVNLEM : The same as VNLEM but uses diffusion distances to
%   filter among the neighbours within a specific search window.
%
% Before running the script, make sure that the vl_sift toolbox is
% installed by running the vl_setup.m from the vl_feat toolbox folder:
%run '/vlfeat-0.9.20/toolbox/vl_setup.m'

clear all;
clc;
close all;

mkdir Results
run '../vlfeat-0.9.21/toolbox/vl_setup.m'

%fix the rand/randn generator
rand('state',1234);
randn('state',1234);

%% Parameters

% noise parameters
sigma = sqrt(0.3);  % noise std
mu = 0;             % noise mean
do_save = 0;        % set to 1 if results are to be saved
do_plot = 1;        % set to 1 if results are to be plotted
imgIdx = 1;

% change to control the range of images to test for denoising %
images = [1];
numImages = length(images);
numPixels = 100;
num_samples = 100;

W = zeros(num_samples, num_samples);
%% load and pre-process image%%
[img, r, c] = loadImage(imgIdx, numPixels);
[I, meanOriginal, stdOriginal, imgPeak, imgStd] = processImage(img);

rotated = 
   