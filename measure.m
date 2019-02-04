% This script performs a comparison between the denoised images usinga
% variety of methods and the orignal image to assess the accuracy of each
% denoising algorithm. The measure used for this comparison is the \Delta_g
% norm. Make sure to mex the deltaG function!

%Each image of size 512 x 512 is devided into subimages of size 16 x
% 16 and then the comparison is made on these image patches. So every
% couple of images gets a 256 x 1 vector of distances.
clc;
clear all;
close all;

images = [14];

VNLEM_times = zeros(length(images), 1);
DD_times = zeros(length(images), 1);
NLEM_times = zeros(length(images), 1);

for imgIdx = images
    
   % load the original and the denoised images %
   inputName = sprintf('Results/Img%d_512.mat', imgIdx);
   load(inputName);
   [r, c] = size(img);
   I = reshape(img,[numel(img),1]);
   I = double(I);
   meanOriginal = mean(I);
   stdOriginal = std(I, 0, 1);
   I = (I-mean(I))./std(I,0,1);
   I = reshape(I,[r,c]);
   peak  = max(max(I));
   sigma_signal = std(I(:));
    
   NLEM_denoised = NLEM_Denoised;
   denoised = NLEM_denoised(:);
   denoised = (denoised-mean(denoised))./std(denoised, 0, 1);
   denoised = (denoised) * stdOriginal + meanOriginal;
   denoised = reshape(denoised, size(img));
   FSIM_NLEM = FeatureSIM(img, denoised);
   %delta_NLEM = findDeltaG(uint8(img), uint8(denoised));
   [sob_NLEM, RMS_NLEM] = sobNorm(im2uint8(img), im2uint8(denoised));
   display('Done with NLEM-denoised image');
   
   VNLEM_denoised = VNLEM_Denoised;
   denoised = VNLEM_denoised(:);
   denoised = (denoised-mean(denoised))./std(denoised, 0, 1);
   denoised = (denoised) * stdOriginal + meanOriginal;
   denoised = reshape(denoised, size(img));
   FSIM_VNLEM = FeatureSIM(img, denoised);
   %delta_VNLEM = findDeltaG(uint8(img), uint8(denoised));
   [sob_VNLEM, RMS_VNLEM] = sobNorm(uint8(img), uint8(denoised));
   display('Done with VNLEM-denoised image');
   
   DVNLEM_denoised = DD_Denoised;
   denoised = DVNLEM_denoised(:);
   denoised = (denoised-mean(denoised))./std(denoised, 0, 1);
   denoised = (denoised) * stdOriginal + meanOriginal;
   denoised = reshape(denoised, size(img));
   FSIM_DD = FeatureSIM(img, denoised);
   %delta_DD = findDeltaG(uint8(img), uint8(denoised));
   [sob_DD, RMS_DD] = sobNorm(uint8(img), uint8(denoised));
   display('Done with VNLEM-DD-denoised image');
   
%    VNLEM_times(imgIdx) = VNLEM_time;
%    NLEM_times(imgIdx) = NLEM_time;
%    DD_times(imgIdx) = DD_time;
   display(imgIdx);
   time_NLEM = NLEM_time;
   time_VNLEM = VNLEM_time;
   time_DD = DD_time;
   
   %% saving %%
   save(inputName,  'img', 'imgNoisy', ...
            'DVNLEM_denoised', 'VNLEM_denoised', 'NLEM_denoised', ...
            'DD_params', 'VNLEM_params','NLEM_params', ...
            'FSIM_DD', 'sob_DD', 'RMS_DD', ...
            'time_VNLEM', 'time_NLEM', 'time_DD', ...
             'PSNR_noisy', 'PSNR_VNLEM', 'PSNR_NLEM', 'PSNR_DVNLEM', ...
            'SNR_noisy', 'SNR_VNLEM', 'SNR_NLEM', 'SNR_DVNLEM', 'numPixels', 'meanOriginal', ...
            'stdOriginal', 'imgIdx', 'FSIM_NLEM', 'sob_NLEM', 'RMS_NLEM', ...
            'FSIM_VNLEM', 'sob_VNLEM', 'RMS_VNLEM');%, 'delta_DD', 'delta_VNLEM', 'delta_NLEM');
    
   %clear img NLEM_Denoised VNLEM_Denoised VNLEM_DD_Denoised
    
    
end

%save('Results2/measurements.mat', 'VNLEM_times', 'DD_times', 'NLEM_times');