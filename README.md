AugmentedRealityPoolTable
=========================

Processing code for an augmented reality pool table asstiant. Main goal is to predcit the trectory of a shot and
when it'll collide with a ball

Processing V 2.2.1

Libaries Used
OpenNI 2.2.0.33
OpenCV 2.4.9
Kinect SDK 1.6
https://code.google.com/p/kinect-mssdk-openni-bridge/ We used it for using a winndows kinect in processing, OpenCV prefers
a xbox kinect

Peripherals
1x Xbox Kinect v1
1x Kinect for Windows v1

Change log
11/8/2014-Intial upload
Right now the code is only using RGB sensors, so it's possible not to use kinects if desired. We will be adding the use of 
IR sensors from the kinect to detect all the pool balls, the RGB will be mainly for finding the cue ball and the cue stick.
Since we were mainly testing the algoltrhiim for ball colllsions and wall bounce(which is only one right now), 
the code has only 3 inputs hard coded in.Testing for an acutal pool game begins tomrrow
