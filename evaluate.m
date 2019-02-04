function [SNR, PSNR, FSIM, sob, RMS] = evaluate(img, imgHat, imgPeak, imgStd)

% measure different performance metrics between original img and denoised
% imgHat
[r, c] = size(img);

SNR = 10 * log10(r * c * imgStd^2 / sum(sum((imgHat - img).^2)) );
PSNR = 10 * log10(r * c * imgPeak^2 / sum(sum((imgHat - I).^2)) );
FSIM = FeatureSIM(img, imgHat);
[sob, RMS] = sobNorm(uint8(img), uint8(imgHat));