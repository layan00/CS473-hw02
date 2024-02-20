% preparing images %

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


