W = zeros(3, 3);
min_angles = zeros(3, 3);
for i = 1 : 3
    ref_patch = reshape(Q(:, i), [patchSize, patchSize]);
    for j = 1 : 3
        if(j < i)
            other_patch = reshape(Q(:, j), [patchSize, patchSize]);
            min_dist = norm(ref_patch(:) - other_patch(:), 2);
            min_angle = 0;
            for angle = 0 : 5 : 360
                
               rotated_patch = imrotate(other_patch, angle, 'bilinear', 'crop');
               dist = norm(ref_patch(:) - rotated_patch(:), 2);
               if(dist < min_dist)
                   min_dist = dist;
                   min_angle = angle;
               end
            end
            W(i, j) = min_dist;
            W(j, i) = min_dist;
            min_angles(i, j) = min_angle;
            min_angles(j, i) = min_angle;
        end
    end
end