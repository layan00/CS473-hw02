% Estimating the homography of two images eith matching correspondences 
% this function determines the transform between image 1 and 2

function A = estimateTransform(im1_points, im2_points)

% 1) we know that Pq=r, create P and r using DLT %

% Set up design matrix P: size = 2*size(im1_points,1) x 9
% P =zeros(2*size(im1_points,1),9); not sure

% 2) use Homogeneous Least Squares with SVD method to to obtain q %

if size(P,1) == 8
    [U,S,V] = svd(P);
else
    [U,S,V] = svd(P,'econ');
end

q = V(:,end);

% 3) reshape q to get A %


end