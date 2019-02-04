function [I, meanOriginal, stdOriginal, imgPeak, imgStd] = ...
          processImage(img)
% Preprocess the image 
% return : Pre-processed image, oringal mean, original std, peak of image, 
%          std of normalized image

% Standardize image pixel values (0 mean and 1 variance) %
[r, c] = size(img);
I = reshape(img,[numel(img),1]);
I = double(I);
meanOriginal = mean(I);
stdOriginal = std(I, 0, 1);
I = (I-mean(I))./std(I,0,1);
I = reshape(I,[r,c]);
imgPeak  = max(max(I));
imgStd = std(I(:));