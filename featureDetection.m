im1 = im2double(rgb2gray(imread('Image1.jpg')));
im2 = im2double(rgb2gray(imread('Image2.jpg')));

%detecting SURF features
points1 = detectSURFFeatures(im1);
points2 = detectSURFFeatures(im2);

%extracting feature descriptors
[features1, valid_points1] = extractFeatures(im1, points1);
[features2, valid_points2] = extractFeatures(im2, points2);

%matching features
indexPairs = matchFeatures(features1, features2, 'Unique', true);

%checking if there are enough matches before proceeding
if size(indexPairs, 1) > 0
    matchedPoints1 = valid_points1(indexPairs(:, 1));
    matchedPoints2 = valid_points2(indexPairs(:, 2));
else
    error('Not enough matches were found.');
end

%visualizing matched features
figure;
showMatchedFeatures(im1, im2, matchedPoints1, matchedPoints2);
title('Matched Features');

%retrieving locations of matched points
im1_points = matchedPoints1.Location;
im2_points = matchedPoints2.Location;

%calling the RANSAC function
[A_inliers, inlierIdx] = estimateTransformRansac(im1_points, im2_points);

%visualizing inlier matches
figure;
showMatchedFeatures(im1, im2, matchedPoints1(inlierIdx), matchedPoints2(inlierIdx), 'montage');
title('Inlier Matches');

%calling the transformation function
im2_transformed = TransformImage(im2, inv(A_inliers), 'homography');
figure; imshow(im2_transformed); title('Transformed Image 2');

%checking and handling NaN values
im2_transformed(isnan(im2_transformed)) = 0;

%visualizing the transformed image
figure;
imshow(im2_transformed);
title('Transformed Image 2');

canvas_size = max([size(im1); size(im2_transformed)]);


%expanding both images to the canvas size
im1_expanded = padarray(im1, canvas_size - size(im1), 'post');
im2_transformed_padded = padarray(im2_transformed, canvas_size - size(im2_transformed), 'post');

%using ginput to manually select the blending region
imshow(im1_expanded);
[x_overlap, ~] = ginput(2);
close;

%defining the blending ramp based on selected points
overlap_left = round(min(x_overlap));
overlap_right = round(max(x_overlap));
ramp = zeros(1, canvas_size(2));
ramp(overlap_left:overlap_right) = linspace(0, 1, overlap_right - overlap_left + 1);
ramp(overlap_right:end) = 1;
ramp_matrix = repmat(ramp, [canvas_size(1), 1]);

%ensuring both images are of the same height. If not, pad the shorter image.
height_diff = size(im2_transformed, 1) - size(im1_expanded, 1);
if height_diff > 0
    im1_expanded = padarray(im1_expanded, [height_diff 0], 0, 'post');
elseif height_diff < 0
    im2_transformed = padarray(im2_transformed, [-height_diff 0], 0, 'post');
end

%confirming both images now have the same dimensions
assert(all(size(im1_expanded) == size(im2_transformed)), 'Image dimensions do not match.');
[tform, ~] = estimateGeometricTransform(matchedPoints1, matchedPoints2, 'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

xWorldLimits = [min(1, tform.T(3,1)) size(im1, 2)];
yWorldLimits = [min(1, tform.T(3,2)) size(im1, 1) + abs(tform.T(2,3))];
outputView = imref2d(size(im1), xWorldLimits, yWorldLimits);




%applying the blending ramp
im1_blend = im1_expanded .* (1 - ramp_matrix);
im2_blend = im2_transformed_padded .* ramp_matrix;

%combining the blended images
panorama = im1_blend + im2_blend;

figure;
imshow(panorama);
title('Panorama');
imwrite(panorama, 'panorama.png');