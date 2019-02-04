clear all 
clc
load('demo.mat');
patchSize = sqrt(size(Q0, 1));
sigma = 1.0;  % patches have an std of 1
bw = 100;
T = 1;
do_PCA = 1;
rng('default');

% selecting 3 patches randomly %
idx = randi(size(Q0, 2), 3, 1);
Q = Q0(:, idx);

% populating data space by creating 100 random rotations of these 3 patches
Q2 = zeros(size(Q0, 1), 300);
idx = 1;
for i = 1 : 3
    patch = reshape(Q(:, i), [patchSize, patchSize]);
    for j = 1 : 100
        angle = rand() * 90;
        patch_rotated = imrotate(patch, angle, 'bilinear', 'crop');
        % adding noise to rotated patches %
        patch_rotated = patch_rotated + sigma * randn(size(patch_rotated));
        Q2(:, idx) = reshape(patch_rotated, [patchSize * patchSize, 1]);
        idx = idx + 1;
    end
end

% finding pair-wise RIDs between patches using SIFT
angles = createFeatures(Q2, (patchSize - 1) / 2);
RID = zeros(300, 300);
for i = 1 : 300
    ref_patch = reshape(Q2(:, i), [patchSize, patchSize]);
    for j = 1 : 300
        if(j < i)
            other_patch = reshape(Q2(:, j), [patchSize, patchSize]);
            angle = (angles(j) - angles(i)) / pi * 180;
            rotated_patch = imrotate(other_patch, angle, 'bilinear', 'crop');
            dist = norm(ref_patch(:) - rotated_patch(:), 2);
            RID(i, j) = dist;
            RID(j, i) = dist;
        end
    end
    if(mod(i, 30) == 0)
        disp(i);
    end
end


%% creating GL %%
W = exp(- RID .^ 2 / (bw * bw));
D = sum(W, 2);
D_inv = diag(1 ./ D);
GL = D_inv .^ 0.5 * W * D_inv .^ 0.5;

%% Diffusion mapping %%
GL = (GL + GL') / 2;  % making sure GL is symmetric
[UD, lambdaUD] = eigs(GL, 4);
UD = D_inv * UD;
lambdaUD = diag(lambdaUD);
embedded = UD(:,2:4) * diag(lambdaUD(2:4).^ T);


%% finding nearest neighbours of patches using diffusion distances %%
distances = zeros(300, 1);
ref_patch_idx = 5;
for i = 1 : 300
    distances(i) = norm(embedded(i, :) - embedded(ref_patch_idx, :), 2);
end
[~ , idx] = sort(distances, 'ascend');
neighbours_estimated = idx(1 : 100);
% because we created the data-set, we know who the real neighbours should be (if there is no noise)
neighbours_real = int32(ref_patch_idx / 100) + 1 : int32(ref_patch_idx / 100) + 100;   

%% performing PCA for comparison %%
if(do_PCA)
    meanData = mean(Q2, 1);
    X = Q2 - meanData;
    [U, Sigma, V] = svd(X);
    embedded_pca = Q2.' * U(:, 1:3);
    pca_distances = zeros(300, 1);
    ref_patch_idx = 5;
    for i = 1 : 300
        pca_distances(i) = norm(embedded_pca(i, :) - embedded_pca(ref_patch_idx, :), 2);
    end
    [~ , idx] = sort(pca_distances, 'ascend');
    pca_neighbours_estimated = idx(1 : 100);
end

%% plotting %%
if(~do_PCA) 
    scatter3(embedded(:, 1), embedded(:, 2), embedded(:, 3));
    hold on;
    scatter3(embedded(neighbours_real, 1), ...
             embedded(neighbours_real, 2), ...
             embedded(neighbours_real, 3))
    scatter3(embedded(neighbours_estimated, 1), ...
             embedded(neighbours_estimated, 2), ...
             embedded(neighbours_estimated, 3))
    legend('All points', 'Real neighbours', 'Estimated neighbours');
else
    figure();
    subplot(1, 2, 1);
    scatter3(embedded(:, 1), embedded(:, 2), embedded(:, 3));
    hold on;
    scatter3(embedded(neighbours_real, 1), ...
             embedded(neighbours_real, 2), ...
             embedded(neighbours_real, 3))
    scatter3(embedded(neighbours_estimated, 1), ...
             embedded(neighbours_estimated, 2), ...
             embedded(neighbours_estimated, 3))
    legend('All points', 'Real neighbours', 'Estimated neighbours');
    title('Diffusion mapping');

    subplot(1, 2, 2)
    scatter3(embedded_pca(:, 1), embedded_pca(:, 2), embedded_pca(:, 3));
    hold on;
    scatter3(embedded_pca(neighbours_real, 1),...
            embedded_pca(neighbours_real, 2),...
            embedded_pca(neighbours_real, 3))
    scatter3(embedded_pca(pca_neighbours_estimated, 1), ...
             embedded_pca(pca_neighbours_estimated, 2), ...
             embedded_pca(pca_neighbours_estimated, 3))
    legend('All points', 'Real neighbours', 'Estimated neighbours');
    title('PCA');
end
%save('demo.mat');