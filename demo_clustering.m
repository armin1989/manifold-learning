close all;
% clear all 
% clc
% %load('noisy_patch_vector_512.mat');
% load('Lena_512.mat');
% patchSize = 51;
sigma = 1;  % patches have an std of 1
bw = 50;
T = 1;
% do_PCA = 1;
% rng('default');
% 
% % creating patch vectors 
%imgPad = imgPadding(I, (patchSize - 1) / 2);
%Q0 = createPatchVector(imgPad, (patchSize - 1) / 2, 512, 512);

% selecting 3 patches randomly %
%patch_idx = randi(500, 3, 1) * 512 + 100;
%idx = [4100, 4120, 4108];
Q = Q0(:, patch_idx);

% populating data space by creating 100 random rotations of these 3 patches
Q2 = zeros(size(Q0, 1), 300);
idx = 1;
for i = 1 : 3
    patch = reshape(Q(:, i), [patchSize, patchSize]);
    for j = 1 : 100
        angle = rand() * 360;
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
embedded = UD(:,2:3) * diag(lambdaUD(2:3).^ T);


%% finding nearest neighbours of patches using diffusion distances %%
distances = zeros(300, 3);
ref_patch_idx = 5;
j = 1;
for ref_patch_idx = [1, 101, 201]
    for i = 1 : 300
        distances(i, j) = norm(embedded(i, :) - embedded(ref_patch_idx, :), 2);
    end
    j = j + 1;
end

neighbours_estimated = zeros(100, 3);
neighbours_real = zeros(100, 3);
j = 1;
for ref_patch_idx = [1, 101, 201]
    [~ , idx] = sort(distances(:, j), 'ascend');
    neighbours_estimated(:, j) = idx(1 : 100);
    % because we created the data-set, we know who the real neighbours should be (if there is no noise)
    neighbours_real(:, j) = (j - 1) * 100 + 1 : j * 100; 
    j = j + 1;
end


%% performing PCA for comparison %%
if(do_PCA)
    meanData = mean(Q2, 1);
    X = Q2 - meanData;
    [U, Sigma, V] = svd(X);
    embedded_pca = Q2.' * U(:, 1:3);
    pca_distances = zeros(100, 3);
    pca_neighbours_estimated = zeros(100, 3);
    j = 1;
    for ref_patch_idx = [1, 101, 201]
        for i = 1 : 300
            pca_distances(i, j) = norm(embedded_pca(i, :) - ...
                                  embedded_pca(ref_patch_idx, :), 2);
        end
        [~ , idx] = sort(pca_distances(:, j), 'ascend');
        pca_neighbours_estimated(:, j) = idx(1 : 100);
        j = j + 1;
    end
end

%% plotting %%
prefix = 'high_noise';
f = figure();
%subplot(1, 3, 1);
colors = {'red', 'blue', 'green'};
for j = 1 : 3
    scatter(embedded(neighbours_real(:, j), 1), ...
         embedded(neighbours_real(:, j), 2));%, ...
         %embedded(neighbours_real(:, j), 3));
     hold on;
end
grid on;
legends ={'Neighbours of 1', 'Neighbours of 2', 'Neighbours of 3'};
legend(legends, 'location', 'NW', 'FontSize', 14);
title('Real neighbours', 'FontSize', 14);
print(f, '-dpdf', sprintf('real_%s.pdf', prefix));

%subplot(1, 3, 2);
f = figure();
for j = 1 : 3
    scatter(embedded(neighbours_estimated(:, j), 1), ...
         embedded(neighbours_estimated(:, j), 2))%, ...
         %embedded(neighbours_estimated(:, j), 3));
         %'MarkerFaceColor', colors{j}, 'MarkerEdgeColor', colors{j});
     hold on;
end
classified = union(neighbours_estimated(:, 1), ...
                   union(neighbours_estimated(:, 2), neighbours_estimated(:, 3)));
not_selected = embedded;
not_selected(classified, :) = [];
scatter(not_selected(:, 1), not_selected(:, 2));
grid on;
legends ={'Neighbours of 1', 'Neighbours of 2', 'Neighbours of 3', 'Neighbours of None'};
legend(legends, 'location', 'NW', 'FontSize', 14);
title('Estimated neighbours with DM', 'FontSize', 14);
print(f, '-dpdf', sprintf('DM_%s.pdf', prefix));

%subplot(1, 3, 3)
f = figure();
for j = 1 : 3
    scatter(embedded(pca_neighbours_estimated(:, j), 1), ...
         embedded(pca_neighbours_estimated(:, j), 2));%, ...
         %embedded(pca_neighbours_estimated(:, j), 3))
     hold on
end
classified = union(pca_neighbours_estimated(:, 1), ...
                   union(pca_neighbours_estimated(:, 2), pca_neighbours_estimated(:, 3)));              
              
not_selected = embedded;
not_selected(classified, :) = [];
scatter(not_selected(:, 1), not_selected(:, 2));
grid on;
legends ={'Neighbours of 1', 'Neighbours of 2', 'Neighbours of 3', 'Neighbours of None'};
legend(legends, 'location', 'NW', 'FontSize', 14);
grid on;
%legend('All points', 'Real neighbours', 'Estimated neighbours');
title('Estimated neighbours with PCA', 'FontSize', 14);
print(f, '-dpdf', sprintf('PCA_%s.pdf', prefix)); 