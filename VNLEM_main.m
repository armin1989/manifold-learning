function [imgDenoised, time] = VNLEM_main(W_temp, idx, angles, Q0, params, r, c)

start_time = tic;

% getting the parameters %
h = 100;                  % Bandwidth for Gaussian Kernel in inital RID (using SIFT)  
bw = params.BW;           % Bandwidth used for Gaussian kernel in accurate RID
window = params.window;   % search windows for finding RID among other patches
NN1 = params.NN1;         % number of neighbours in first step of filtering 
NN2 = params.NN2;         % number of neighbours in second step of filtering
P = params.P;             % patch radius
scale = params.scale;    % scale used for resizing patches when finding accurate RID
p = 0.1;                 % p in l_p norm for finding final denoised value
N = 2 * P + 1; 

NN = (2 * window + 1) * (2 * window + 1);
NN1 = int32(min(NN / 2, NN1));
imgDenoised = zeros(r, c);

% creating initial affinity matrix using SIFT RID %
W_SIFT = exp(- (W_temp .^ 2 / (h * h)));
clear W_temp

% up-sampling patches for accurate RID calculation %
Qresized = createScaledPatches(Q0, P, scale);

%% denoising %%
denoising_time_start = tic;
display('Looping over pixels....');
for i = 1 : c
    for j = 1 : r 

        patchIdx = i + (j - 1) * c;

        % first step of filtering with SIFT RID %
        [~, Idx1] = sort(W_SIFT(patchIdx, :), 'descend');
        neighbors1 = idx(patchIdx, Idx1(1 : NN1)) + 1;
        
        % second step of filtering using real RID distances %
         distances = findAccurateRID(Qresized(:, patchIdx), angles(patchIdx), ...
                     Qresized(:, neighbors1).', angles(neighbors1), NN1, bw * bw);

         
         if(NN2 < NN1)
            [w2, Idx2] = sort(distances, 'descend');
            neighbors2 = neighbors1(Idx2(1 : NN2));
         else
             w2 = distances;
             neighbors2 = neighbors1;
         end

        % find median % 
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
