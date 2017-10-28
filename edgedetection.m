function [binaryImage]= edgedetection(outImage,roiim,roiim2)
% edge detection for the IPM grayscale image
    thresholdlevel = graythresh(outImage); % Otsu threshold
    binaryImage = edge(outImage, 'Canny', [0.2*thresholdlevel,thresholdlevel]); % Canny edge detection
    binaryImage = bwmorph(binaryImage, 'remove'); % mathemetic morphological remove operation
    se3 =strel('square',10);
    binaryImage = imclose(binaryImage,se3); % mathemetic morphological closing operation
    binaryImage = imadd(binaryImage,logical(roiim2)); % dual edge detection
    binaryImage(roiim~=1) = 0; % processed by ROI