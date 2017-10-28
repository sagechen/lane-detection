clc;
close all;
imtool close all;
clear;

addpath(genpath(pwd));

% get camera and IPM parameters
[cameraInfo, ipmInfo] = GetInfo;

if(~isdeployed)
    cd(fileparts(which(mfilename)));
end

% read the video information
pfilename = 'challenge.mp4';
VideoFullfilename = fullfile(pfilename);
VideoObject = VideoReader(VideoFullfilename);
NumofFrames = VideoObject.NumberOfFrames;

% set region of interest
VidHight = VideoObject.Height;
VidWidth = VideoObject.Width;
Roibotpa = 0.9;
Roitoppa = 0.1;
Roipa = 3/5;
imgRoi = dfRoi(Roibotpa,Roitoppa,Roipa,VidHight,VidWidth);

% set the parameters for displaying
startno = 1; % start frame number
endno = 251; % end frame number
detected = 0; % the flag of detection
sizeinclo = 3; % length of register
inclo = 1; % location of register
fontSize = 14;
proll = []; % register of left lane boundary
prorl = []; % register of right lane boundary
figure;

% process frame by frame
for frameno = startno : endno
    Thisframe = read(VideoObject, frameno);
    subplot(3, 3, 1);
    image(Thisframe);
    Caption = sprintf('Frame %4d of %d.', frameno, NumofFrames);
    title(Caption, 'FontSize', fontSize);
    drawnow;    

    
    
    tf = Thisframe;
    tf(imgRoi~=1)=0; % processed by ROI
    % hue detection(extract the yellow and white pixels)
    wpixind = find((tf(:,:,1)>=200)&(tf(:,:,1)<=255)...
             &(tf(:,:,2)>=200)&(tf(:,:,2)<=255)...
             &(tf(:,:,3)>=200)&(tf(:,:,3)<=255));
    ypixind = find((tf(:,:,1)>=150)&(tf(:,:,1)<=255)...
             &(tf(:,:,2)>=150)&(tf(:,:,2)<=255)...
             &(tf(:,:,3)<=130));
         
    I = Thisframe;
    grayImage = rgb2gray(I); % convert the color image to grayscale image
    gImage = grayImage(Roipa*size(grayImage,1):end,:);
    thresholdlevel = graythresh(gImage); % Otsu threshold
    bImage = edge(grayImage, 'Canny', thresholdlevel); % Canny edge detection
    bImage = bwmorph(bImage, 'remove'); 
    se3 =strel('square',10);
    bImage = imclose(bImage,se3); % morphological closing operation
    % add the results of hue detection
    bImage(wpixind) = 1;
    bImage(ypixind) = 1;
    
    % perspective transform
    [outImage,orib,orit,uvGrid,outRow,outCol,II,roiim,roiim2] = perspectivetrans(cameraInfo,ipmInfo,I,imgRoi,bImage);
    % locate the lane region
    jbmin = min(orib);
    jbmax = max(orib);
    jtmin = min(orit);
    jtmax = max(orit);
    jmin = min([jbmin,jtmin]);
    jmax = max([jbmax,jtmax]);
    subplot(3, 3, 2)
    imshow(outImage); % the IPM grayscale frame
    title('IPM frame', 'FontSize', fontSize);

    subplot(3, 3, 3)
    binaryImage = edgedetection(outImage,roiim,roiim2); % Canny edge detection for the IPM grayscale image
    imshow(binaryImage);
    hold on;
    if((detected == 0)||(mod(frameno,3)==0))
        % lane detection for the original frame and do this operation every
        % there frames
        [leftlineot, rightlineot, leftinds, righinds, nonzrow, nonzcol, detected] = linefit(binaryImage);
    else
        % lane tracking
        [leftlineot, rightlineot, leftinds, righinds, nonzrow, nonzcol, detected] = turnfit(binaryImage, leftlineo, rightlineo);
    end
    if(detected == 1)
        % save related parameters if detected successfully
        proll(:,inclo) = leftlineot;
        prorl(:,inclo) = rightlineot;
        inclo = inclo + 1;
        if(inclo == sizeinclo+1)
            inclo = 1;
        end
    end
    if(frameno == startno)
        leftlineo = leftlineot;
        rightlineo = rightlineot;
    else
        if (~isempty(proll))&&(~isempty(prorl))
            % mean filter
            leftlinetmp = mean(proll,2);
            rightlinetmp = mean(prorl,2);
             if((abs(leftlinetmp(1)-leftlineo(1))<2*abs(leftlineo(1))) && (abs(rightlinetmp(1)-rightlineo(1))<2*abs(rightlineo(1))))
                leftlineo = leftlinetmp;
                rightlineo = rightlinetmp;
             else
                if(inclo == 1)
                    inclo = sizeinclo;
                else
                    inclo = inclo - 1;
                end
            end
        end
    end

    % lane shape fit on IPM image
    ploty = linspace(0,size(binaryImage,1)-1,size(binaryImage,1));
    if ~isnan(leftlineo)
        leftline = leftlineo(1)*ploty.^2 + leftlineo(2)*ploty + leftlineo(3);
        plot(leftline, ploty, 'LineWidth', 2, 'color', 'red');
    end
    if ~isnan(rightlineo)
        rightline = rightlineo(1)*ploty.^2 + rightlineo(2)*ploty + rightlineo(3);
        plot(rightline, ploty, 'LineWidth', 2, 'color', 'red');
    end



    % mark the lane region in IPM image
    subplot(3, 3, 4)
    img = zeros(size(binaryImage));
    rgbimage = uint8(cat(3,img,img,img).*255);
        for i = 1 : size(leftinds)
            rgbimage(nonzrow(leftinds(i)),nonzcol(leftinds(i)),1)=255;
        end
        for i = 1 : size(righinds)
            rgbimage(nonzrow(righinds(i)),nonzcol(righinds(i)),1)=255;
        end
    imshow(rgbimage);
    hold on;
    if ~isnan(leftlineo)
        plot(leftline,ploty,'LineWidth', 3, 'color', 'blue');
    end
    if ~isnan(rightlineo)
        plot(rightline,ploty, 'LineWidth', 3, 'color', 'blue');
    end
    
    if (~isnan(leftlineo))&(~isnan(rightlineo))
        xx = [leftline, fliplr(rightline)];
        yy = [ploty ,fliplr(ploty)];
        fill(xx,yy,'g');

    % mark the lane region on original image
        Ir = roipoly(rgbimage, xx, yy);
        Iw = zeros(size(I));
        lefv = [];
        lefu = [];
        rigv = [];
        rigu = [];
        for i=1:outRow
            uip = [];
            vip = [];
            for j = int32(1.2*jmin-0.2*jmax):int32(1.2*jmax-0.2*jmin)
                ui = uvGrid(1,(i-1)*outCol+j);
                vi = uvGrid(2,(i-1)*outCol+j);
                if((Ir(i,j)==1) && (ui>ipmInfo.ipmLeft) && (ui<ipmInfo.ipmRight) && (vi>ipmInfo.ipmTop) && (vi<ipmInfo.ipmBottom))
                    uip = [uip,int32(ui)];
                    vip = [vip,int32(vi)];
                end
            end
            Iw(min(vip):max(vip)+1,min(uip):max(uip)+1,3) = 255;
            [lu,indf] = min(uip);
            lefv = [lefv vip(indf)];
            lefu = [lefu lu];
            [ru,indr] = max(uip);
            rigv = [rigv vip(indr)];
            rigu = [rigu ru];
        end
        lefl = polyfit(double(lefv),double(lefu),2);
        rigl = polyfit(double(rigv),double(rigu),2);
        ploty = linspace(ipmInfo.ipmTop,ipmInfo.ipmBottom,ipmInfo.ipmBottom-ipmInfo.ipmTop);
        % mark the lane boundaries on original image
        lefll = lefl(1)*ploty.^2+lefl(2)*ploty+lefl(3);
        rigll = rigl(1)*ploty.^2+rigl(2)*ploty+rigl(3);
        addI = imadd(uint8(Iw),I);
        subplot(3, 3, 5)
        imshow(addI);
        hold on;
        plot(lefll,ploty,'LineWidth', 2, 'color', 'green');
        plot(rigll,ploty,'LineWidth', 2, 'color', 'green');
        
    end    
    
    % show the IPM region
    subplot(3, 3, 6)
    imshow(II);
    hold on;
    
    % show the original binary image
    subplot(3, 3, 7)
    imshow(bImage);
    hold on;
    
    % show the IPM binary image
    subplot(3, 3, 8)
    imshow(binaryImage);
    hold on;
end
   