function  imgDenoised  =  NLEM(imgNoisy, params)
% Function for denoising images using Non-Local Euclidean Medians, where the
% kNN nearest neighbours are found using diffusion distances between image
% patches.
% 
% Inputs :
% imgNoisy : noisy image
% params : structure containing the parameters of the simulation as
% follows:
%    h : bandwith of the Gaussian kernel
%    P : patch radius 
%    window = search window for finding neighbours
% 
% Outputs:
% imgDenoised : denoised image
%
% Reference:
%
% K. N. Chaudhury and A. Singer, "Non-Local Euclidean Medians", IEEE Signal
% Processing Letters, vol. 19, no. 11, 2012.

BW = params.BW;
P = params.P;
window = params.window;

[r, c] = size(imgNoisy);
N  = 2*P + 1;
h2 = BW * BW;
kNN = ceil ( (2*window + 1)^2 / 2 ); % top 50% of the neighbors used 

%% Padding image %%

imgPad = imgPadding(imgNoisy, P);

%% create patch vector %%

Q = createPatchVector(imgPad, P, r, c);

%% finding patch distances %%

display('Finding affinity matrix...');
[W_temp, idx] = createNLEMAffinity(imgPad, P, window, r, c, h2);

imgDenoised = zeros(r,c);

%% denoising %%

fprintf('Looping over pixels....\n');
for i = 1 : r 
    for j = 1 : c
        patchIdx = i + (j - 1) * c;
        
        [w , Idx] = sort(W_temp(patchIdx, :), 'descend');
                
        L = min(kNN, 4 * window * window);
        
        neighbors = idx(patchIdx, Idx(1 : L)) + 1;

        % find median % 
        median  = ...
        findEuclideanMedian(Q(: , neighbors), w(1 : L)');
        patch_est  =  reshape(median, [N  N]);
        imgDenoised(j, i) =  patch_est(P + 1, P + 1);
    end
end
end