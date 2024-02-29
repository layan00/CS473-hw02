% Estimating the homography of two images eith matching correspondences 
% this function determines the transform between image 1 and 2

function A = estimateTransform(im1_points, im2_points)

% Extract coordinates
x = im1_points(:, 1);
y = im1_points(:, 2);
xp = im2_points(:, 1);
yp = im2_points(:, 2);

% Construct the design matrix P
P = [
    -x, -y, -ones(size(x)), zeros(size(x)), zeros(size(x)), zeros(size(x)), x .* xp, y .* xp, xp;
    zeros(size(x)), zeros(size(x)), zeros(size(x)), -x, -y, -ones(size(x)), x .* yp, y .* yp, yp
];
    
% Use Homogeneous Least Squares with SVD to obtain q
if size(P,1) == 8
    [U,S,V] = svd(P);
else
    [U,S,V] = svd(P,'econ');
end

q = V(:,end);
    
    % Reshape q to obtain the transformation matrix A
    A = reshape(q, 3, 3)';
    disp(A);
end
