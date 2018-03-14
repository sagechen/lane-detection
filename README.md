# lane-detection
A video-based guiding system for autonomous car

## Running method: 
open the main.m and run.

## These operations can be chosen according to the specific situation  
- set the value of 'pfilename' in main.m to read the specific videoobject  
- set the values of variates of 'startno' and 'endno' in main.m to control the first and last frames  
- set the related camera parameters and IPM parameters in GetInfo.m  

## File description:
- main.m: the main function  
- GetInfo.m: extract the related parameters of camera and IPM  
- dfRoi.m: construct the trapezoid region of interest  
- edgedetection.m: edge detection for the IPM grayscale image  
- perspectivetrans.m: perspective transform  
- TransformImagetoGround.m: transform the video image into the ground coordinate system  
- TransformGroundtoImage.m: establish the mapping relationship between pixel coordinate and original image coordinate  
- getvanishingpoint.m: get the position of vanishing point to determine the IPM area  
- linefit.m: accomplish the lane detection  
- turnfit.m: accomplish the lane tracking  
- road lane video files: 'challenge.mp4'  

---

## Example:  
![the result](https://github.com/sagechen/lane-detection/blob/master/lane%20detection.png)
