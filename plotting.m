% plotting %
clear all;
idxVec = [14];
for imgIdx = idxVec

    load(sprintf('Results/Img%d_512.mat', imgIdx));

    f1 = figure;
    colormap 'gray'
    subplot(2, 3, 1);
    imshow(img, []);
    title('Original image', 'FontSize', 14);
    subplot(2, 3, 4);
    imshow(imgNoisy, []);
    xlabel(sprintf('PSNR = %.3f, SNR = %.3f', PSNR_noisy, SNR_noisy), 'fontSize', 14);
    title('Noisy image', 'FontSize', 14sqa);
        
    subplot(2, 3, 2);
    result = NLEM_denoised(:);
    result = (result-mean(result))./std(result, 0, 1);
    result = (result) * stdOriginal + meanOriginal;
    result = reshape(result, size(img));
    imshow(result, []);
    title('NLEM', 'FontSize', 14);
    xlabel(sprintf('PSNR = %.3f, SNR = %.3f, FSIM = %.3f', ...
        PSNR_NLEM, SNR_NLEM, FSIM_NLEM),'fontSize', 14);
    subplot(2, 3, 5);
    imshow(result - img, []);
    title('Leftover noise', 'FontSize', 14);
    
    subplot(2, 3, 3);
    result = VNLEM_denoised(:);
    result = (result-mean(result))./std(result, 0, 1);
    result = (result) * stdOriginal + meanOriginal;
    result = reshape(result, size(img));
    imshow(result, []);
    title('VNLEM', 'FontSize', 14);
    xlabel(sprintf('PSNR = %.3f, SNR = %.3f, FSIM = %.3f', ...
                    PSNR_VNLEM, SNR_VNLEM, FSIM_VNLEM),'fontSize', 14);
    subplot(2, 3, 6);
    imshow(result - img, []); 
    title('Leftover noise', 'FontSize', 14);
    
%     subplot(2, 4, 4);
%     result = DVNLEM_denoised(:);
%     result = (result-mean(result))./std(result, 0, 1);
%     result = (result) * stdOriginal + meanOriginal;
%     result = reshape(result, size(img));
%     imshow(result, []);
%     title('VNLEM with DD');
%     xlabel(sprintf('PSNR = %.3f, SNR = %.3f, FSIM = %.3f', ...
%                     PSNR_DVNLEM, SNR_DVNLEM, FSIM_DD),'fontSize', 10);
%     subplot(2, 4, 8);
%     imshow(result - img, []);  
%     title('Leftover noise');

end