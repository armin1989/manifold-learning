function [imgDenoised,  imgDenoised_DD, VNLEM_time, DVNLEM_time] = ...
         VNLEM_wrapper(imgNoisy, params, DD_params)


%% Parameters
P = params.P;
window = params.window;

%% main process %%
[r, c] = size(imgNoisy);

% padding image and creating patches vector %
imgPad = imgPadding(imgNoisy, P);
Q0 = createPatchVector(imgPad, P, r, c);

% getting RID features for patches using SIFT %
angles = createFeatures(Q0, P);

% creating affinity matrix %
affinity_start = tic;
disp('Finding affinity matrix...');
[W_temp, idx] = createAffinity(imgPad, angles, P, window, r, c);
affinity_time = toc(affinity_start);

% clear padded image and noisy image to free some memory %
clear imgPad imgNoisy;

disp('DVNLEM denoising');
[imgDenoised_DD, DVNLEM_time] = DVNLEM_main(W_temp, idx, angles, Q0, DD_params, r, c);
disp('Done!');
DVNLEM_time = DVNLEM_time + affinity_time;


disp('VNLEM denoising');
[imgDenoised, VNLEM_time] = VNLEM_main(W_temp, idx, angles, Q0, params, r, c);
disp('Done!');
VNLEM_time = VNLEM_time + affinity_time;




