function [sob, RMS] = sobNorm(f, g)

% This function calculates the sobolev norm between f & g (f - g). For a definition
% of this norm see:
% A New Metric for Grey-Scale Image Comparison, A.Wilson, et. al. 1997.

delta = 0.5;
[r, c] = size(f);
F = fftshift(fft2(f));
G = fftshift(fft2(g));
[Xu, Yu] = meshgrid(-r / 2 : r /2 - 1, - c / 2 : c / 2 - 1);

eta = sqrt((Xu / r) .^ 2 + (Yu / c) .^ 2);
sob = sqrt(sum(sum((1 + eta .^ 2) .^ delta .* abs(F - G) .^ 2))) / (r * c);
sob = sob / 255;
RMS = sqrt(sum(sum(abs(F - G) .^ 2)) / (r * c) ^ 2);
RMS = RMS / 255;