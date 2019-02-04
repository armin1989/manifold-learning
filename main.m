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
run './vlfeat-0.9.20/toolbox/vl_setup.m'

%fix the rand/randn generator
rand('state',1234);
randn('state',1234);

%% Parameters

% noise parameters
sigma = 0.3;  % noise std
mu = 0;             % noise mean
do_save = 0;        % set to 1 if results are to be saved
do_plot = 1;        % set to 1 if results are to be plotted

% change to control the range of images to test for denoising %
images = [14];
numImages = length(images);
numPixels = 50;

% VNLEM parameters
VNLEM_params.BW = 16.5;  % bandiwdth for Gaussian kernel
VNLEM_params.window = 10; % initial search window
VNLEM_params.P = 10;  % patch radius
VNLEM_params.scale = 2;  % up-sampling rate
VNLEM_params.NN1 = 100;  % number of nearest neighbours for the first filtering step
VNLEM_params.NN2 = 50;   % number of nearest neighbours for the second filtering step

% VNLEM with DD parameters
DD_params.BW = 16.5;
DD_params.window = VNLEM_params.window;
DD_params.P = VNLEM_params.P;
DD_params.T = 1;  % diffusion time
DD_params.nEigs = 4;  % number of eigen values / vectors used for embedding the patches into a low-dimensional space
DD_params.scale = 2;
DD_params.NN1 = 100;
DD_params.NN2 = 50;

% NLEM parameters
NLEM_params.window = 10; 
NLEM_params.P = 6; 
NLEM_params.BW  = 6.5;

%% creating arrays to store the desired data, i.e., running times, etc. %%
VNLEM_time = zeros(numImages, 1);
VNLEM_DD_time = zeros(numImages, 1);
NLEM_time = zeros(numImages, 1);
PSNR_noisy = zeros(numImages, 1);
PSNR_VNLEM = zeros(numImages, 1);
PSNR_DVNLEM = zeros(numImages, 1);
PSNR_NLEM = zeros(numImages, 1);
SNR_noisy = zeros(numImages, 1);
SNR_VNLEM = zeros(numImages, 1);
SNR_DVNLEM = zeros(numImages, 1);
SNR_NLEM = zeros(numImages, 1);

% an array to keep track of the images with failed VNLEM + DD attempt %
failedImages = 0;
count = 0;

%% denoising images %% 
for imgIdx = images
    start = tic;
    disp(imgIdx);
    
    %% load and pre-process image%%
    [img, r, c] = loadImage(imgIdx, numPixels);
    [I, meanOriginal, stdOriginal, imgPeak, imgStd] = processImage(img);
    
    % Apply additive guassian white noise %
    imgNoisy = I + sigma * randn(size(I)) + mu;
    [SNR_noisy, PSNR_noisy] = evaluateMetrics(I, imgNoisy, imgPeak, imgStd);
    
    %% Both VNLEM denoisings %%
    [VNLEM_denoised, DVNLEM_denoised, VNLEM_time]  = VNLEM_wrapper(imgNoisy, VNLEM_params, DD_params);
    DD_time = VNLEM_time;
    [SNR_VNLEM, PSNR_VNLEM] = evaluateMetrics(I, VNLEM_denoised, imgPeak, imgStd);
    [SNR_DVNLEM, PSNR_DVNLEM] = evaluateMetrics(I, DVNLEM_denoised, imgPeak, imgStd);
    
    disp(['Finished VNLEM denoising, ' num2str(VNLEM_time) ' seconds has elapsed']);
    disp(['Finished DVNLEM denoising, ' num2str(DD_time) ' seconds has elapsed']);
    
    %% NLEM denoising %%
    time2 = tic;
    NLEM_denoised = NLEM(imgNoisy, NLEM_params);
    NLEM_time = toc(time2);
    [SNR_NLEM, PSNR_NLEM] = evaluateMetrics(I, NLEM_denoised, imgPeak, imgStd);
    disp(['Finished NLEM denoising, ' num2str(NLEM_time) ' seconds has elapsed']);
    
    
    %% plotting results %%    
    if(do_plot)
        % plotting the denoised images %
        f1 = figure;
        colormap 'gray'
        subplot(2, 4, 1);
        imshow(img, []);
        title('Original image');
        subplot(2, 4, 5);
        imshow(imgNoisy, []);
        xlabel(sprintf('PSNR = %.3f, SNR = %.3f', PSNR_noisy, SNR_noisy), 'fontSize', 10);
        title('Noisy image');

        subplot(2, 4, 2);
        result = NLEM_denoised(:);
        result = (result-mean(result))./std(result, 0, 1);
        result = (result) * stdOriginal + meanOriginal;
        result = reshape(result, size(img));
        imshow(result, []);
        title('NLEM');
        xlabel(sprintf('PSNR = %.3f, SNR = %.3f', PSNR_NLEM, SNR_NLEM),'fontSize', 10);
        subplot(2, 4, 6);
        imshow(result - img, []);
        title('Leftover noise');

        subplot(2, 4, 3);
        result = VNLEM_denoised(:);
        result = (result-mean(result))./std(result, 0, 1);
        result = (result) * stdOriginal + meanOriginal;
        result = reshape(result, size(img));
        imshow(result, []);
        title('VNLEM');
        xlabel(sprintf('PSNR = %.3f, SNR = %.3f', PSNR_VNLEM, SNR_VNLEM),'fontSize', 10);
        subplot(2, 4, 7);
        imshow(result - img, []); 
        title('Leftover noise');

        subplot(2, 4, 4);
        result = DVNLEM_denoised(:);
        result = (result-mean(result))./std(result, 0, 1);
        result = (result) * stdOriginal + meanOriginal;
        result = reshape(result, size(img));
        imshow(result, []);
        title('VNLEM with DD');
        xlabel(sprintf('PSNR = %.3f, SNR = %.3f', PSNR_DVNLEM, SNR_DVNLEM),'fontSize', 10);
        subplot(2, 4, 8);
        imshow(result - img, []);  
        title('Leftover noise');
    end
    
    
    %% saving results %%
    matName = sprintf('Results/Img%d_%d.mat', imgIdx, numPixels);
    
    time_end = toc(start)
    if(do_save)
        save(matName,  'img', 'imgNoisy', ...
            'DVNLEM_denoised', 'VNLEM_denoised', 'NLEM_denoised', ...
            'DD_params', 'VNLEM_params','NLEM_params', ...
            'VNLEM_time', 'NLEM_time', 'DD_time', ...
             'PSNR_noisy', 'PSNR_VNLEM', 'PSNR_NLEM', 'PSNR_DVNLEM', ...
            'SNR_noisy', 'SNR_VNLEM', 'SNR_NLEM', 'SNR_DVNLEM', 'numPixels', 'meanOriginal', ...
            'stdOriginal', 'imgIdx');
    end
end