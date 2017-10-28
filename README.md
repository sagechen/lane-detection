# lane-detection
A video-based guiding system for autonomous car

## Running method: 
open the main.m and run.

## These operations can be chosen according to the specific situation  
(1) set the value of 'pfilename' in main.m to read the specific videoobject  
(2) set the values of variates of 'startno' and 'endno' in main.m to control the first and last frames  
(3) set the related camera parameters and IPM parameters in GetInfo.m  

## File description:
(1) main.m: the main function  
(2) GetInfo.m: extract the related parameters of camera and IPM  
(3) dfRoi.m: construct the trapezoid region of interest  
(4) edgedetection.m: edge detection for the IPM grayscale image  
(5) perspectivetrans.m: perspective transform  
(6) TransformImagetoGround.m: transform the video image into the ground coordinate system  
(7) TransformGroundtoImage.m: establish the mapping relationship between pixel coordinate and original image coordinate  
(8) getvanishingpoint.m: get the position of vanishing point to determine the IPM area  
(9) linefit.m: accomplish the lane detection  
(10) turnfit.m: accomplish the lane tracking  
(11) road lane video files: 'challenge.mp4'  

## Example:  
![the result](https://github.com/sagechen/lane-detection/blob/master/lane%20detection.png)
