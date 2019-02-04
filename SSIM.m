function index = SSIM(img1, img2)

% this function finds the structrucal similarity index of img1 and img2,
% for more info on this metric see equation 8 in 
% "A survey of edge-preserving image denoising methods"

c1 = (0.01 * 255) ^ 2;
c2 = (0.03 * 255) ^ 2;

mean1 = mean(img1(:));
mean2 = mean(img2(:));

var1 = var(img1(:));
var2 = var(img2(:));

cov12 = cov(img1, img2);
cov12 = cov12(1, 2);

index = (2 * mean1 * mean2  + c1) * (2 * cov12 + c2) / ...
        ((mean1 ^ 2 + mean2 ^ 2 + c1) * (var1 + var2 + c2));