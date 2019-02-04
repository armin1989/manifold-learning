function Qscaled = createScaledPatches(Q, P, scale)

numPatches = size(Q, 2);
Qscaled = zeros(scale ^ 2 * (2 * P + 1) ^ 2, numPatches);

for i = 1 : numPatches
    patch = reshape(Q(:, i), 2 * P + 1, 2 * P + 1);
    patchScaled = imresize(patch, scale);
    Qscaled(:, i) = reshape(patchScaled, scale ^ 2 * (2 * P + 1) ^ 2, 1); 
end