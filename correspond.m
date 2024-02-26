% obtaining correspondences: This file describes the use of SURF to 
% extract matching correspondences of two images.

% preparing images % we need two more pairs of images
im1 = imread('Image1.jpg');
im2 = imread('Image2.jpg');

% setup the image for transformation
im1 = im2double(im1);
im1 = rgb2gray(im1);

im2 = im2double(im2);
im2 = rgb2gray(im2);

% 2: Obtaining correspondences using SURF %

points1 = detectSURFFeatures(im1);
points2 = detectSURFFeatures(im2);

% extract features
features1 = extractFeatures( im1,points1 );
features2 = extractFeatures( im2,points2 );

% matching features between image 1 and 2
indexPairs = matchFeatures( features1, features2, 'Unique', true );

% extract objects for matched points from matched features 
matchedPoints1 = points1( indexPairs( :,1 ) );
matchedPoints2 = points2( indexPairs( :,2 ) );

%  convert points objects to coordinates, they should be of size Nx2 each
im1_points = matchedPoints1.Location;
im2_points = matchedPoints2.Location;

% Call estimateTransform for part 3 of the assignment: Estimating the homography %
A = estimateTransform(im1_points, im2_points);