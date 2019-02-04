function J = imgPadding(imgNoisy,P)
[m, n] = size(imgNoisy);

%imgPad = sparse(m+2*P,n+2*P);
imgPad = zeros(m + 2 * P, n + 2 * P);
% Put in the image
imgPad(P+1:P+m, P+1:P+n) = imgNoisy;
% Reflect the top and bottom
imgPad(1:P,P+1:P+n)=flipud(imgNoisy(1:P,:));
imgPad(P+m+1:end,P+1:P+n)=flipud(imgNoisy(m-(P-1):m,:));
% Reflect the left and right
imgPad(P+1:P+m,1:P)=fliplr(imgNoisy(:,1:P));
imgPad(P+1:P+m,P+n+1:end)=fliplr(imgNoisy(:,n-(P-1):n));
% Fill in the four corners starting with upper-left going clockwise
imgPad(1:P,1:P)=rot90(imgNoisy(1:P,1:P),2);
imgPad(1:P,P+n+1:end)=rot90(imgNoisy(1:P,n-(P-1):end),2);
imgPad(P+m+1:end,1:P)=rot90(imgNoisy(m-(P-1):end,1:P),2);
imgPad(P+m+1:end,P+n+1:end)=rot90(imgNoisy(m-(P-1):end,n-(P-1):end),2);

J=imgPad;
end