function [img, r, c] = loadImage(imgIdx, numPixels)

% given an index, load the corresponding image from the database
% return : image, number of rows, number of columns

imgName = sprintf('Images/Img%d.tif', imgIdx);
imgLoaded = double(imread(imgName));

% cropping the image and resizing it
[r, c] = size(imgLoaded);

if(r ~= c)
 % square the image if it isnt square by cropping it%
 if(r < c)             
     imgLoaded = imgLoaded(:, floor(c / 2) - r / 2 + 1: floor(c / 2) + r / 2);             
 else             
     imgLoaded = imgLoaded(floor(r / 2) - c / 2 + 1 : floor(r / 2) + c / 2, :);             
 end
end

[r, c] = size(imgLoaded);
minDim = min(r, c);

img = imresize(imgLoaded, numPixels / minDim);
[r, c] = size(img); 