% This function is adapted from the first assignment, for transforming images (it has been adjusted)
function TransformedImage = TransformImage(InputImage, TransformMatrix, TransformType)
% Get size of the input image
[h, w] = size(InputImage);

% Define corners of the input image, corrected with the help of TA Mingjun!
c1 = [1;1;1];
c2 = [w;1;1];
c3 = [1;h;1];
c4 = [w;h;1];
corners = [c1 c2 c3 c4];

% Apply the transformation to the corners
cornersprime = TransformMatrix * corners;

% Calculate the range for the transformed image
minx = min(cornersprime(1, :) ./ cornersprime(3, :));
maxx = max(cornersprime(1, :) ./ cornersprime(3, :));
miny = min(cornersprime(2, :) ./ cornersprime(3, :));
maxy = max(cornersprime(2, :) ./ cornersprime(3, :));

% Determine the shift needed to force corners at (1,1)
Xprime_shifted = 1 - minx;
Yprime_shifted = 1 - miny;

% Create a meshgrid for the transformed image covering the entire range
[Xprime, Yprime] = meshgrid(1:maxx+Xprime_shifted, 1:maxy+Yprime_shifted);

switch TransformType
    case 'scaling'
        Ainv = TransformMatrix;
        i = 1/TransformMatrix(1,1);
        j = 1/TransformMatrix(2,2);
        Ainv(1,1) = i;
        Ainv(2,2) = j;
    case 'rotation'
        Ainv = TransformMatrix;
        i = -1*TransformMatrix(1,2);
        j = -1*TransformMatrix(2,1);
        Ainv(1,2) = i;
        Ainv(2,1) = j;
    case 'translation'
        Ainv = TransformMatrix;
        i = -1*TransformMatrix(1,3);
        j = -1*TransformMatrix(2,3);a
        Ainv(1,3) = i;
        Ainv(2,3) = j;
    case 'reflection'
        % Inverse of reflection about y-axis
        if isequal(TransformMatrix, [1, 0, 0; 0, -1, 0; 0, 0, 1])
        Ainv = [1, 0, 0; 0, -1, 0; 0, 0, 1];
        disp("ref 1")
        % Inverse of reflection about x-axis
        elseif isequal(TransformMatrix, [-1, 0, 0; 0, 1, 0; 0, 0, 1])
        Ainv = [-1, 0, 0; 0, 1, 0; 0, 0, 1];
        disp("ref 2")        
        end
    case 'shear'
        Ainv = TransformMatrix;
        i = -1*TransformMatrix(1,2);
        Ainv(1,2) = i;
    case 'affine'
        Ainv = inv(TransformMatrix);
    case 'homography'
        Ainv = inv(TransformMatrix);
    otherwise
        warning('Unexpected transform type; did you misspell your option?')
        return
end % for switch


pprime = [reshape(Xprime, 1, []); reshape(Yprime, 1, []); ones(1, numel(Xprime))];
    phat = Ainv * pprime; 
    
    xhat = phat(1, :) ./ phat(3, :);
    yhat = phat(2, :) ./ phat(3, :);
    
    Xhat = reshape(xhat, size(Xprime));
    Yhat = reshape(yhat, size(Yprime));
    TransformedImage = interp2(double(InputImage), Xhat, Yhat, 'linear', 0);
end % for function TransformImage
