function A_inliers = estimateTransformRansac(pts1, pts2, im1, im2)
    Nransac = 10000;
    t = 2;
    n = size(pts1, 1);
    k = 4;
    nbest = 0;
    Abest = [];
    idxbest = [];
    for i_ransac = 1:Nransac
        idx = randperm(n, k);
        pts1i = pts1(idx, :);
        pts2i = pts2(idx, :);
        A_test = estimateTransform(pts1i, pts2i);
        pts2e = A_test * [pts1'; ones(1, n)];
        pts2e = pts2e(1:2, :) ./ pts2e(3, :);
        pts2e = pts2e';
        d = sqrt((pts2e(:, 1) - pts2(:, 1)).^2 + (pts2e(:, 2) - pts2(:, 2)).^2);
        idxgood = d < t;
        ngood = sum(idxgood);
        if ngood > nbest
            nbest = ngood;
            Abest = A_test;
            idxbest = idxgood;
        end
    end

    pts1inliers = pts1(idxbest, :);
    pts2inliers = pts2(idxbest, :);

    figure();
    showMatchedFeatures(im1, im2, pts1inliers, pts2inliers, "montage");
    title("Refined matching points (by RANSAC), only inliers");
    saveas(gcf, 'matched_features_plot.png');

    A_inliers = estimateTransform(pts1inliers, pts2inliers);
end
