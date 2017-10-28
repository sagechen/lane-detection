function [outImage,orib,orit,uvGrid,outRow,outCol,II,roiim,roiim2] = perspectivetrans(cameraInfo,ipmInfo,I,imgRoi,bImage)
% perspective transform
outImage = zeros(ipmInfo.ipmHeight,ipmInfo.ipmWidth);
roiim  = ones(size(outImage)); % ROI of the IPM image
roiim2 = zeros(size(outImage)); % bird-eye mapping of the original binary image

R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);
II = zeros(size(R));

vpp = GetVanishingPoint(cameraInfo);
vp.x = vpp(1);
vp.y = vpp(2);

% limit the range of IPM
uvLimitsp = [ vp.x,         ipmInfo.ipmRight, ipmInfo.ipmLeft,  vp.x;
              ipmInfo.ipmTop, ipmInfo.ipmTop, ipmInfo.ipmTop,   ipmInfo.ipmBottom];

% transform the video image to the ground coordinate system
xyLimits = TransformImage2Ground(uvLimitsp,cameraInfo);

row1 = xyLimits(1,:);
row2 = xyLimits(2,:);
xfMin = min(row1); xfMax = max(row1);
yfMin = min(row2); yfMax = max(row2);

% establish the pixel coordinate system
[outRow ,outCol] = size(outImage);
stepRow = (yfMax - yfMin)/outRow;
stepCol = (xfMax - xfMin)/outCol;
xyGrid = zeros(2,outRow*outCol);
y = yfMax-0.5*stepRow;

for i = 1:outRow
    x = xfMin+0.5*stepCol;
    for j = 1:outCol
        xyGrid(1,(i-1)*outCol+j) = x;
        xyGrid(2,(i-1)*outCol+j) = y;
        x = x + stepCol;
    end
    y = y - stepRow;
end

% establish the mapping relationship between the pixel coordinate and
% original image coordinate
uvGrid = TransformGround2Image(xyGrid,cameraInfo);

means = mean(R(:))/255;
RR = double(R)/255;
GG = double(G)/255;
BB = double(B)/255;
orib = [];
orit = [];
for i=1:outRow
    for j = 1:outCol
        ui = uvGrid(1,(i-1)*outCol+j);
        vi = uvGrid(2,(i-1)*outCol+j);
         if (ui<ipmInfo.ipmLeft || ui>ipmInfo.ipmRight || vi<ipmInfo.ipmTop || vi>ipmInfo.ipmBottom) 
             outImage(i,j) = means;
             % transform the trapezoid ROI
             roiim(i,j)= 0;
         else
             % transform the original binary image
             if (bImage(int32(vi),int32(ui))==1)
                 roiim2(i,j) = 1;
             end
             if (imgRoi(int32(vi),int32(ui))==0)
                 roiim(i,j) = 0;
             else
                 % save the column coordinates of top and bottom
                 if(i == 1)
                     orit = [orit j];
                 end
                 if (i == outRow)
                     orib = [orib j];
                 end
             end
             % bilinear interpolation
             x1 = int32(ui); x2 = int32(ui+1);
             y1 = int32(vi); y2 = int32(vi+1);
             x = ui-double(x1) ;  y = vi-double(y1);
             % choose the red channel to ensure the illumination
             valR = double(RR(y1,x1))*(1-x)*(1-y)+double(RR(y1,x2))*x*(1-y)+double(RR(y2,x1))*(1-x)*y+double(RR(y2,x2))*x*y;
%             valG = double(GG(y1,x1))*(1-x)*(1-y)+double(GG(y1,x2))*x*(1-y)+double(GG(y2,x1))*(1-x)*y+double(GG(y2,x2))*x*y;
%             valB = double(BB(y1,x1))*(1-x)*(1-y)+double(BB(y1,x2))*x*(1-y)+double(BB(y2,x1))*(1-x)*y+double(RR(y2,x2))*x*y;
%              valR = double(RR(y1,x1));
%              valG = double(GG(y1,x1));
%              valB = double(BB(y1,x1));
             outImage(i,j) = valR;
             II(y1:y1+3,x1:x1+3) = RR(y1,x1);
         end
         
    end
end

hold on;
