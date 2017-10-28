function [leflo,riglo,lefindx,rigindx,nonzrow,nonzcol,detected] = turnfit(binaryImage, leftlineo, rightlineo)
% accomplish the lane tracking
margin = 10; % range of scan
im = binaryImage;
[nonzrow, nonzcol] = find(im); % the index of white pixels of the IPM image
% the index of white pixels in the scan range
lefindx = find((nonzcol<leftlineo(1)*nonzrow.^2+ leftlineo(2)*nonzrow +leftlineo(3)+margin) & ...
               (nonzcol>leftlineo(1)*nonzrow.^2+ leftlineo(2)*nonzrow +leftlineo(3)-margin));
rigindx = find((nonzcol<rightlineo(1)*nonzrow.^2+ rightlineo(2)*nonzrow +rightlineo(3)+margin) & ...
               (nonzcol>rightlineo(1)*nonzrow.^2+ rightlineo(2)*nonzrow +rightlineo(3)-margin));
           

if (length(lefindx')>50) % judge whether the left line pixels are enough
    leftx = nonzcol(lefindx);
    lefty = nonzrow(lefindx);
    leflo = polyfit(lefty,leftx,2); % second order polynomial fit
    detectedl = 1;
else
    leflo = nan;
    detectedl = 0;
end

if (length(rigindx')>50) % judge whether the left line pixels are enough
    rightx = nonzcol(rigindx);
    righty = nonzrow(rigindx);
    riglo = polyfit(righty,rightx,2); % second order polynomial fit
    detectedr = 1;
else
    riglo = nan;
    detectedr = 0;
end

% judge whether the lines have been detected
if(detectedl && detectedr)
    detected = 1;
else
    detected = 0;
end

    