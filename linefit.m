function [leftlineo,rightlineo,leftinds,righinds,nonzrow,nonzcol,detected] = linefit(binaryImage)
% accomplish the lane detection
im1 = binaryImage;
heig = size(binaryImage, 1)/2; 
widt = size(binaryImage, 2)/2; % divide the image into left part and right part
im2 = binaryImage(heig:end,:); % original cumulative range
% establish the histogram
histgrol = sum(im2(:,1:widt),1);
histgror = sum(im2(:,widt:end),1);
% search out the maximum points as the original base points
[~,basl] = max(histgrol);
[~,basr] = max(histgror);
basr = basr + widt;

% divide the image into nine blocks
nwindows = 9;
windowhei = size(binaryImage, 1)/nwindows;
[nonzrow ,nonzcol] = find(im1); % find the white pixels and save their coordinate values
bascurl = basl;
bascurr = basr;
margin = 10; % the width of sliding windows
flgl = 0;
flgr = 0;

for k = 1 : nwindows
    % range of rows
    ylow = size(binaryImage, 1) - k*windowhei; 
    yhigh = size(binaryImage, 1) - (k-1)*windowhei;
    if(flgl ~= 0) % means not any left line white pixels have been detected
        bwidt = int32((bascurl + bascurr)/2); % calculate the middle point
        % locate the base point of next block
        bhistgrol = sum(im1(1:int32(yhigh),1:bwidt),1);
        [~,bascurltmp] = max(bhistgrol);
        if(abs(bascurltmp-bascurl)<2*margin)
            bascurl = bascurltmp;
        end
    end
    % the same operation for the right line
    if(flgr ~= 0) % means not any right line white pixels have been detected
        bwidt = int32((bascurl + bascurr)/2);
        bhistgror = sum(im1(1:int32(yhigh),bwidt:end),1);
        [~,bascurrtmp] = max(bhistgror);
        bascurrtmp = bascurrtmp + bwidt;
        if(abs(bascurrtmp-bascurr)<2*margin)
            bascurr = bascurrtmp;
        end
    end
    % determine the region of scan
    xlflow = bascurl - margin;
    xlfhigh = bascurl + margin;
    xrglow = bascurr - margin;
    xrghigh = bascurr + margin;
    % mark the region of scan
    rectangle('Position',[xlflow ylow xlfhigh-xlflow yhigh-ylow],'Curvature', 0.1,'Facecolor', 'g');
    rectangle('Position',[xrglow ylow xrghigh-xrglow yhigh-ylow],'Curvature', 0.1,'Facecolor', 'g');
    % extract the white pixels in the scan ranges
    pleftinds = find((nonzcol>=xlflow) & (nonzcol<xlfhigh) & (nonzrow>=ylow) & (nonzrow<yhigh));
    prighinds = find((nonzcol>=xrglow) & (nonzcol<xrghigh) & (nonzrow>=ylow) & (nonzrow<yhigh));

    % save the pixel indices
    if (k ~= 1)
        leftinds = [leftinds;pleftinds];
        righinds = [righinds;prighinds];
    else
        leftinds = pleftinds;
        righinds = prighinds;
    end
    % judge whether the left line pixels have been detected
    if ~isempty(pleftinds)
        bascurl= int32(mean(nonzcol(pleftinds'))); % locate the base point of next block
        flgl = 0;
    else
        flgl = 1;
    end
    % judge whether the right line pixels have been detected
    if ~isempty(prighinds)
        bascurr= int32(mean(nonzcol(prighinds'))); % locate the base point of next block
        flgr = 0;
    else
        flgr = 1;
    end
end
% second order polynomial fit for left line
if ~isempty(leftinds)
    leftx = nonzcol(leftinds);
    lefty = nonzrow(leftinds);
    leftlineo = polyfit(lefty,leftx,2);
    detectedl = 1;
else
    leftx = nan;
    lefty = nan;
    leftlineo = nan;
    detectedl = 0;
end

% second order polynomial fit for right line
if ~isempty(righinds)
    righx = nonzcol(righinds);
    righy = nonzrow(righinds);
    rightlineo = polyfit(righy,righx,2);
    detectedr = 1;
else
    righx = nan;
    righy = nan;
    rightlineo = nan;
    detectedr = 0;
end

% judge whether the lines have been detected
if (detectedl && detectedr)
    detected = 1;
else
    detected = 0;
end
    
    