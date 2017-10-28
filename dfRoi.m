function [imgRoi] = dfRoi(Roibotpa,Roitoppa,Roipa,VidHight,VidWidth)
% construct the trapezoid region of interest
    imgRoi = ones(VidHight,VidWidth);
    c = [(1-Roibotpa)/2*VidWidth, (1+Roibotpa)/2*VidWidth, (1+Roitoppa)/2*VidWidth, ...
        (1-Roitoppa)/2*VidWidth, (1-Roibotpa)/2*VidWidth];
    r = [VidHight, VidHight, VidHight*Roipa, VidHight*Roipa, VidHight];
    Iw = roipoly(imgRoi,c,r);
    imgRoi(Iw~=1) = 0;
    
    