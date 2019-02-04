function [imgDenoised, time] = DVNLEM_main(W_temp, idx, angles, Q0, params, r, c)

start_time = tic;

% getting the parameters %
h = 1;                % Bandwidth for Gaussian Kernel in inital RID (using SIFT)  
BW = params.BW;         % Bandwidth used for Gaussian kernel in accurate RID
window = params.window; % search windows for finding RID among other patches
NN1 = params.NN1;       % number of neighbours in first step of filtering 
NN2 = params.NN2;       % number of neighbours in second step of filtering
P = params.P;           % patch radius
T = params.T;           % diffusion time
nEigs = params.nEigs;   % Number of eigen values used for diffusion mapping
scale = params.scale;   % scale used for resizing patches when finding accurate RID
p = 0.1;                % parameters in l_p norm
N = 2 * P + 1;

NN = (2 * window + 1) * (2 * window + 1);
NN1 = int32(min(NN / 2, NN1));
imgDenoised = zeros(r, c);

%% creating GL %% 
W_SIFT = exp(- (W_temp .^ 2 / (h * h)));
%clear W_temp;
[W2, D2] = createGL(W_SIFT, idx, r, c, NN);
%clear W_SIFT;

%% finding the eigen functions/values %%
eigen_time_start = tic; 
disp('Calculating eigenfunctions/eigenvalues...'); 
[UD, lambdaUD] = eigs(W2, nEigs);
UD = D2 * UD;
lambdaUD = diag(lambdaUD);
eigen_time = toc(eigen_time_start);

%% embedding points %%
embedDim = min(nEigs, length(lambdaUD));
embedded = UD(:,2:embedDim) * diag(lambdaUD(2:embedDim).^ T);
%clear UD lambdaUD W2 D2

%% up-sampling patches for accurate RID calculation
Qresized = createScaledPatches(Q0, P, scale);

%% denoising %%
denoising_time_start = tic;
disp('Looping over pixels....');
for i = 1 : c
    for j = 1 : r 

        patchIdx = i + (j - 1) * c;
        % finding diffusion distances between embedding of current and
        % other patches %
        distances = findDistances(embedded(idx(patchIdx, :) + 1, :), ...
                NN, embedDim - 1, find(idx(patchIdx, :) + 1 == patchIdx) - 1);

        [~ , Idx1] = sort(distances, 'ascend');
        neighbors1 = idx(patchIdx, Idx1(1 : NN1)) + 1;
        
        % finding accurate RID for second stage of filtering %
         w1 = findAccurateRID(Qresized(:, patchIdx), angles(patchIdx), ...
             Qresized(:, neighbors1).', angles(neighbors1), NN1, BW * BW);

          % finding nearest neighbours according to accurate RID % 
        if(NN2 < NN1)
            [w2, Idx2] = sort(w1, 'descend');
            neighbors2 = neighbors1(Idx2(1 : NN2));
        else
            w2 = w1;
            neighbors2 = neighbors1;
        end
         
        median  = ...
        findEstimate(Q0(:, neighbors2), w2(1 : NN2), p);
        patch_est  =  reshape(median, [N  N]);
        imgDenoised(j, i) =  patch_est(P + 1, P + 1);
        
    end
    % to get an idea of where we are, comment if not needed %
%     if(mod(i, int32(c / 10)) == 0)
%         display(i);
%     end
end
denoising_time = toc(denoising_time_start);

time = toc(start_time);
