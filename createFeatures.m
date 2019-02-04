function feats = createFeatures(Q, P)

patchSize = 2 * P + 1;
%patchSize = sqrt(size(Q, 1));
center = int32(patchSize / 2 - 1 / 2) + 1;
%mask = ones(2 * P + 1, 2 * P + 1);
feats = zeros(size(Q, 2), 1);
for patchIdx = 1 : size(Q, 2)
   patchCurrent = reshape(Q(:, patchIdx), patchSize, patchSize);
   patchCenter = [P + 1; P + 1; 1; 0];
   %patchCenter = [center; center; 1; 0];
   [f_temp, ~] = vl_sift(single(patchCurrent),...
                    'frames',patchCenter,'orientations');
   feats(patchIdx) = f_temp(4, 1);
end