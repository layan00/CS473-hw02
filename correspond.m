% obtaining correspondences: This file describes the use of SURF to 
% extract matching correspondences of two images.

% Preparing images % we need two more pairs of images
im1 = imread('Image1.jpg');
im2 = imread('Image2.jpg');

% Setup the image for transformation
im1 = im2double(im1);
im1 = rgb2gray(im1);

im2 = im2double(im2);
im2 = rgb2gray(im2);

% 2: Obtaining correspondences using SURF %

points1 = detectSURFFeatures(im1);
points2 = detectSURFFeatures(im2);

% Extract features
features1 = extractFeatures( im1,points1 );
features2 = extractFeatures( im2,points2 );

% Matching features between image 1 and 2
indexPairs = matchFeatures( features1, features2, 'Unique', true );

% Extract objects for matched points from matched features 
matchedPoints1 = points1( indexPairs( :,1 ) );
matchedPoints2 = points2( indexPairs( :,2 ) );

%  Convert points objects to coordinates, they should be of size Nx2 each
im1_points = matchedPoints1.Location;
im2_points = matchedPoints2.Location;

% Visualize matches
figure;
showMatchedFeatures(im1,im2,matchedPoints1,matchedPoints2);
title('Matched keypoints');


% Display number of correspondences (aiming for more than 4 matches)
numCorrespondences = size(indexPairs, 1);
fprintf('Number of correspondences: %d\n', numCorrespondences);

% Call estimateTransform for part 3 of the assignment: Estimating the homography %
%A = estimateTransform(im1_p, im2_p);
%A = estimateTransform(im1_points, im2_points);
% call ransac to get good points to estimate transform %


A_inliers = estimateTransformRansac(im1_points, im2_points, im1, im2);
disp(A_inliers);
im2_transformed = TransformImage(im2, inv(A_inliers), 'homography');

nanlocations = isnan( im2_transformed );
im2_transformed( nanlocations )=0;

imwrite(im2_transformed, 'im2_transformed.png');

% Get the size of im2_transformed
[h_im2, w_im2] = size(im2_transformed);

% Create an expanded matrix of zeros with the same size as im2_transformed
im1_expanded = zeros(h_im2, w_im2);

% Copy the contents of im1 into the appropriate region of im1_expanded
im1_expanded(1:size(im1, 1), 1:size(im1, 2)) = im1;


imshow(im1_expanded);
[x_overlap, ~] = ginput(2);

overlap_left=round(x_overlap(1));
overlap_right=round(x_overlap(2));

ramp_width = size(im2_transformed, 2);


% Create the blending ramp
ramp = [zeros(1, overlap_left - 1), linspace(0, 1, overlap_right - ...
    overlap_left + 1), ones(1, ramp_width - overlap_right)];

% Plot the blending ramp
figure;
plot(ramp);
xlabel('Pixel Position');
ylabel('Blend Value');
title('Blending Ramp');



ramp_matrix = repmat(ramp, h_im2, 1);

% Applying the blending ramp
im1_blend = im1_expanded .* (1 - ramp_matrix);
im2_blend = im2_transformed .* ramp_matrix;

% subplot(1,2,1), imshow(im1_blend)
% subplot(1,2,2), imshow(im2_blend)

% Create panorama by adding the two blended images
impanorama=im1_blend+im2_blend;
imwrite(impanorama, "impanorama1.png");
imshow(impanorama);

% end of program %
