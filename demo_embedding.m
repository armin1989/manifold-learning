clear all;
close all;
clc;

% loading patch vectors from clean image %
load('Lena_clean.mat');

% loading params %
h = 100;                % Bandwidth for Gaussian Kernel in inital RID (using SIFT)  
BW = params.BW;         % Bandwidth used for Gaussian kernel in accurate RID
window = params.window; % search windows for finding RID among other patches
NN1 = params.NN1;       % number of neighbours in first step of filtering 
NN2 = params.NN2;       % number of neighbours in second step of filtering
P = params.P;           % patch radius
T = params.T;           % diffusion time
nEigs = params.nEigs;   % Number of eigen values used for diffusion mapping
scale = params.scale;   % scale used for resizing patches when finding accurate RID
p = 0.1;                % parameters in l_p norm
N = 2 * P + 1;          % dimension of each patch
NN = (2 * window + 1) * (2 * window + 1);  % number of neighbours used to form affinity matrix

%% embedding points %%

% creating GL %
W_SIFT = exp(- (W_temp .^ 2 / (h * h)));
[W2, D2] = createGL(W_SIFT, idx, r, c, NN);

% finding the eigen functions/values %
[UD, lambdaUD] = eigs(W2, nEigs);
UD = D2 * UD;
lambdaUD = diag(lambdaUD);

% embedding points %
embedDim = min(nEigs, length(lambdaUD));
embedded_clean = UD(:,2:embedDim) * diag(lambdaUD(2:embedDim).^ T);

%% plotting %%
f = figure();
subplot(1, 2, 1);
imshow(img, []);
title('Image');
subplot(1, 2, 2);
scatter3(embedded_clean(:, 1), embedded_clean(:, 2), embedded_clean(:, 3))
title('Embedded points from clean image', 'FontSize', 14);


%% repeating the same for noisy image %%
load('Lena_noisy.mat');

% creating GL %
W_SIFT = exp(- (W_temp .^ 2 / (h * h)));
[W2, D2] = createGL(W_SIFT, idx, r, c, NN);

% finding the eigen functions/values %
[UD, lambdaUD] = eigs(W2, nEigs);
UD = D2 * UD;
lambdaUD = diag(lambdaUD);

% embedding points %
embedDim = min(nEigs, length(lambdaUD));
embedded_noisy = UD(:,2:embedDim) * diag(lambdaUD(2:embedDim).^ T);

%% plotting %%
f = figure();
subplot(1, 2, 1);
imshow(imgNoisy, []);
title('Noisy image (std of noise = 1)');
subplot(1, 2, 2);
scatter3(embedded_noisy(:, 1), embedded_noisy(:, 2), embedded_noisy(:, 3))
title('Embedded points from noisy image', 'FontSize', 14);


%% repeating the same for noisy image %%
load('Lena_severly_noisy.mat');

% creating GL %
W_SIFT = exp(- (W_temp .^ 2 / (h * h)));
[W2, D2] = createGL(W_SIFT, idx, r, c, NN);

% finding the eigen functions/values %
[UD, lambdaUD] = eigs(W2, nEigs);
UD = D2 * UD;
lambdaUD = diag(lambdaUD);

% embedding points %
embedDim = min(nEigs, length(lambdaUD));
embedded_severe = UD(:,2:embedDim) * diag(lambdaUD(2:embedDim).^ T);

%% plotting %%
f = figure();
subplot(1, 2, 1);
imshow(imgNoisy, []);
title('Severely noisy image (std of noise = 5)');
subplot(1, 2, 2);
scatter3(embedded_severe(:, 1), embedded_severe(:, 2), embedded_severe(:, 3))
title('Embedded points from severely noisy image', 'FontSize', 14);

