function Q = createPatchVector(imgPad, P, m, n)

patchSize = 2 * P + 1;
Q = zeros(patchSize * patchSize, m * n);
k = 1; 
tic
for i = P + 1 : P + m
    for j = P + 1 : P + n
        patch = imgPad(i - P : i + P, j - P : j + P);
        Q(:, k) = reshape(patch, [patchSize * patchSize, 1]);
        k = k + 1;
    end
end
