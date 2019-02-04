function [W1, D1] = createGL(W_temp, idx, r, c, kNN)
% function to create the Graph Laplacian with the given affinity weights
% W_temp : [r x c, kNN] affinity matrix of RIDs
% idx : [r x c, kNN] matrix of indexes of neighbours of each patch
% r : image height (number of rows)
% c : image width (number of columns)
% kNN : number of nearest neighborus for each patch (not really needed,
% Jessica wanted this)
% return :   D ^ -alpha *  W * D ^ -alpha  (the non-normalized GL), D is
% degree matrix 
alpha = 0.5;

weights = reshape(double(W_temp'), r * c * kNN, 1);
col_idx = double(reshape((idx + 1)', r * c * kNN, 1));
row_idx = double(reshape(repmat([1 : r * c], kNN, 1), r * c * kNN, 1));
W = sparse(row_idx, col_idx, weights, r * c, r * c, r * c * kNN);

% free-ing up some memory
clear W_temp idx;
clear row_idx col_idx weights

%W = (W + W') / 2;
D = sum(W, 2);
D = D(:);
D1  = sparse(1:length(D), 1:length(D), 1./D);
clear D
W1  = (D1 .^ alpha) * W * (D1 .^ alpha);