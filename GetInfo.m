function [ cameraInfo, ipmInfo ] = GetInfo

% focal length
cameraInfo.focalLengthX=1169.8;
cameraInfo.focalLengthY=1166.2;

% optical center
cameraInfo.opticalCenterX=668.2411;
cameraInfo.opticalCenterY=408.5262;

% height of the camera in mm
cameraInfo.cameraHeight=1579.8 ;

% pitch of the camera
cameraInfo.pitch=0;

% yaw of the camera
cameraInfo.yaw=0;

% imag width and height
cameraInfo.imageWidth=320;
cameraInfo.imageHeight=180;

%settings for stop line perceptor
ipmInfo.ipmWidth = 640;
ipmInfo.ipmHeight = 480;
ipmInfo.ipmLeft = 30;
ipmInfo.ipmRight = 1250;
ipmInfo.ipmTop = 460;
ipmInfo.ipmBottom = 680;
ipmInfo.ipmInterpolation = 0;
ipmInfo.ipmVpPortion = 0;


end

