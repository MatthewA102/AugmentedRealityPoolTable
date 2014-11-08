import SimpleOpenNI.*;
SimpleOpenNI cam1;
SimpleOpenNI cam2;

PGraphics build;
PImage currentFrame;
color trackColor;
boolean twoCam = false;
// The Images ****************************************************************
void setup()
{
  size(960*2, 480*2);
  cam1 = new SimpleOpenNI(0, this);
  cam1.enableRGB();
  cam1.enableDepth();
  // Second Kinect
  StrVector strList = new StrVector();
  SimpleOpenNI.deviceNames(strList);
  if(strList.size() == 2)
  {
    cam2 = new SimpleOpenNI(1,this);
    cam2.enableRGB();
    cam2.enableDepth();
    twoCam = true;
  }
   
  trackColor = color (255, 0, 0);
  smooth ();
  //currentFrame = createImage (320, 240, RGB);

  //Thresholds
  int thresh = 100;
}
// Ya! *********************************************************************


void draw()
{
  SimpleOpenNI.updateAll();
  if(twoCam)
  {
    build = createGraphics(1280,480, JAVA2D);
    build.beginDraw();
    build.image(cam1.rgbImage(),0,0);
    
    build.image(cam2.rgbImage(),640,0);
    currentFrame = build.get();
    build.endDraw();
  }
  else currentFrame = cam1.rgbImage();
  image(currentFrame, 0, 480);
  currentFrame.loadPixels();
  //image(cam1.depthImage(), 640, 480);
  // Colors to look for   ****************************************************************
  // Cue Ball
  float rCue = 122; //98
  float gCue = 8; //132
  float bCue = 31; //178

  // Cue Stick
  float rStick = 98; //175
  float gStick = 132; //91
  float bStick = 178; //12

  // First Ball
  float rBall1 = 175; //98
  float gBall1 = 91; //132
  float bBall1 = 12; //178
  
  //Intalize objects
  Ball cueStick = new Ball(rStick,gStick,bStick,500);
  Ball cueBall = new Ball(rCue,gCue,bCue,500);
  Ball targetBall = new Ball(rBall1,gBall1, bBall1, 500);

  /*
  // Threshold Lineup *******************************************************************
   int[] depthArray = kinect.depthMap();
   
   int threshold = 500;
   int threshold_near = 50;
   int allNearXPosAddedUp =  0;
   int allNearYPosAddedUp  = 0;
   int allPos = 0;
   
   for(int row = 0; row < kinect.depthHeight(); row++) {
   for(int col = 0; col < kinect.depthWidth(); col++) {
   int offsetInBigArray = row*kinect.depthWidth() + col;
   int thisDepth = depthArray[offsetInBigArray];
   if(thisDepth > threshold_near && thisDepth < threshold){
   allNearYPosAddedUp = allNearYPosAddedUp + row;
   allPos++;
   kinect.depthImage().pixels[offsetInBigArray] = color (255, 255, 255);
   }
   if (thisDepth < threshold_near || thisDepth > threshold) { //the shadows turn out to be 0
   allNearXPosAddedUp =  allNearXPosAddedUp  + col;
   allNearYPosAddedUp  = allNearYPosAddedUp  + row;
   allPos++;
   kinect.depthImage().pixels[offsetInBigArray] = color(0, 0, 0);
   }
   }
   }
   image(kinect.depthImage(),640,0);
   // End of Threshold *******************************************************************
   */

  cueStick.pixelScanner(currentFrame);
  cueBall.pixelScanner(currentFrame);
  targetBall.pixelScanner(currentFrame);
  
  // End of Scanner ****************************************************************

  // Draw the Circles ****************************************************************
  // We only consider the color found if its color distance is less than 10.
  // This threshold of 10 is arbitrary and you can adjust this number depending on how accurate you require the tracking to be.


  fill(255);
  rect(0, 0, 1280, 480);
  cueStick.drawCircle(cueBall.getX(),cueBall.getY());
  cueBall.drawCircle(cueBall.getX(),cueBall.getY());
  targetBall.drawCircle(cueBall.getX(),cueBall.getY());
  
  // End of Circle ****************************************************************
  QudrantCheck mainCheck = new QudrantCheck(cueBall, cueStick, targetBall);
  mainCheck.drawLines();
  delay(100);
  //println("Hi");
}

void mousePressed() {
  color c = get(mouseX, mouseY);
  println("r: " + red(c) + " g: " + green(c) + " b: " + blue(c));
}


class Ball
{
  float X = 0;
  float Y = 0;
  float r, g, b, accuracy;
 
  Ball(float rI, float gI, float bI, float accuracyI)
  {
    r = rI;
    g = gI;
    b = bI;
    accuracy = accuracyI;
  }
  
  void pixelScanner(PImage currentFrame)
  {
     float r1, g1, b1, d2;
     color currentColor;
      for (int x = 0; x < currentFrame.width; x ++ ) {
      for (int y = 0; y < currentFrame.height; y ++ ) {
        int loc = x + y*currentFrame.width;
        // What is current color
        currentColor = currentFrame.pixels[loc];
        r1 = red(currentColor);
        g1 = green(currentColor);
        b1 = blue(currentColor);
  
        // Using euclidean distance to compare colors      
        d2 = dist(r1, g1, b1, r, g, b);
  
        // If current color is more similar to tracked color than
        // closest color, save current location and current difference
        if (d2 < accuracy) {
          accuracy = d2;
          X = x;
          Y = y;
        }
      }
    }
  }
  
  void drawCircle(float cueBallX, float cueBallY)
  {
    if (accuracy < 15)//Adjustable for better accuracy
    {
    // Draw a circle at the tracked pixel of Cue Ball
      fill(r, g, b);
      strokeWeight(4.0);
      stroke(0);
      ellipse(X,Y+480, 16, 16);     
      noFill();
      ellipse(X,Y, 20, 20);    
    }
    else 
    {
      fill(r, g, b);
      strokeWeight(4.0);
      stroke(0);
      ellipse(X, Y+480, 16, 16);
      X = cueBallX;
      Y = cueBallY;
      noFill();
      ellipse(X, Y, 20, 20);
    }
  }
  float getX(){return X;}
  float getY(){return Y;}
  float getR(){return r;}
  float getG(){return g;}
  float getB(){return b;}
}

class QudrantCheck
{
  Ball cueBall;
  Ball cueStick;
  Ball targetBall;
  float slopeBall, cueBallX, cueBallY, cueStickX, cueStickY, targetX, targetY;
  float lineX, lineY, temp, distance, distX, distY;
  boolean postive = false;
  
  QudrantCheck(Ball cueInput, Ball stickInput, Ball targetInput)
  {
    
    cueBall = cueInput;
    cueStick = stickInput;
    targetBall = targetInput;
    cueBallX = cueBall.getX();
    cueBallY = cueBall.getY();
    cueStickX = cueStick.getX();
    cueStickY = cueStick.getY();
    targetX = targetBall.getX();
    targetY = targetBall.getY();
    slopeBall = (cueBallY - cueStickY)/(cueBallX - cueStickX);
    
  }
  
  void drawLines()
  {
    if (cueBallX < cueStickX && cueBallY < cueStickY)
    {
      float slopeI = -cueStickY/-cueStickX;
      if(slopeI<slopeBall)qudrant1Top();
      if (slopeI > slopeBall)qudrant1Left();
    }
    
    if (cueBallX < cueStickX && cueBallY > cueStickY)
    {
      float slopeII = (480-cueStickY)/-cueStickX;
      if (slopeII > slopeBall) qudrant2Bottem();
      if (slopeII < slopeBall) qudrant2Left();
    }
    
    if (cueBallX > cueStickX && cueBallY < cueStickY)
    {
      float slopeIII = -cueStickY/(960-cueStickX);
      if (slopeIII < slopeBall) qudrant3Right();
      if (slopeIII > slopeBall) qudrant3Top();
    }
    
    if (cueBallX > cueStickX && cueBallY > cueStickY)
    {
      float slopeIV = (480-cueStickY)/(960-cueStickX);
      if (slopeIV < slopeBall) qudrant4Bottem();
      if (slopeIV > slopeBall) qudrant4Right();
    }
  }
  
  
  void qudrant1Top()
  {
    lineX = cueStickX;
    lineY = cueStickY;
      while (lineX > 0) {
        ellipse(lineX, lineY, 1, 1);
        lineX = lineX - 1/slopeBall;
        temp = lineY - 1;
        if (postive) temp = lineY + 1;
        else if (temp < 0)
        {
          temp = lineY + 1;
          postive = true;
        }
        lineY = temp;
        distance = dist(lineX, lineY, targetX, targetY);
        if(distance <= 20)
        {
          collsionLine(lineX,lineY);
          break;
        }
      }
  }
  
  void qudrant1Left()
  {
     lineX = cueStickX;
     lineY = cueStickY;
      while (lineY > 0) {
        ellipse(lineX, lineY, 1, 1);
        temp = lineX - 1;
        lineY = lineY - slopeBall;
        if (postive) temp = lineX + 1;
        else if (temp < 0)
        {
          temp = lineX + 1;
          postive = true;
        }
        lineX = temp;
        distance = dist(lineX, lineY, targetX, targetY);
        if(distance <= 20)
        {
          collsionLine(lineX,lineY);
          break;
        }
      }
  }
  
  void qudrant2Bottem()
  {
    lineX = cueStickX;
    lineY = cueStickY;
      while (lineX > 0) {
        ellipse(lineX, lineY, 1, 1);
        lineX = lineX + 1/slopeBall;
        temp = lineY + 1;
        if (postive) temp = lineY - 1;
        else if (temp > 480)
        {
          temp = lineY - 1;
          postive = true;
        }
        lineY = temp;
        distance = dist(lineX, lineY, targetX, targetY);
        if(distance <= 20)
        {
          collsionLine(lineX,lineY);
          break;
        }
      }
  }
  
  void qudrant2Left()
  {
    lineX = cueStickX;
    lineY = cueStickY;
      
      while (lineY < 480) {
        distance = dist(lineX, lineY, targetX, targetY);
        ellipse(lineX, lineY, 1, 1);
        temp = lineX - 1;
        lineY = lineY - slopeBall;
        if (postive) temp = lineX + 1;
        else if (temp < 0)
        {
          temp = lineX + 1;
          postive = true;
        }
        lineX = temp;
        distance = dist(lineX, lineY, targetX, targetY);
        if(distance <= 20)
        {
          collsionLine(lineX,lineY);
          break;
        }
      }
  }
  
  void qudrant3Right()
  {
    lineX = cueStickX;
      lineY = cueStickY;
      while (lineY > 0) {
        ellipse(lineX, lineY, 1, 1);
        temp = lineX + 1;
        lineY = lineY + slopeBall;
        if (postive) temp = lineX - 1;
        else if (temp > 960)
        {
          temp = lineX - 1;
          postive = true;
        }
        lineX = temp;
        distance = dist(lineX, lineY, targetX, targetY);
        if(distance <= 20)
        {
          collsionLine(lineX,lineY);
          break;
        }
      }
  }
  
  void qudrant3Top()
  {
    lineX = cueStickX;
      lineY = cueStickY;
      while (lineX < 960) {
        ellipse(lineX, lineY, 1, 1);
        lineX = lineX - 1/slopeBall;
        temp = lineY - 1;
        if (postive) temp = lineY + 1;
        else if (temp < 0)
        {
          temp = lineY + 1;
          postive = true;
        }
        lineY = temp;
        distance = dist(lineX, lineY, targetX, targetY);
        if(distance <= 20)
        {
          collsionLine(lineX,lineY);
          break;
        }
      }
  }
  
  void qudrant4Bottem()
  {
    lineX = cueStickX;
      lineY = cueStickY;
      while (lineX < 960) {
        ellipse(lineX, lineY, 1, 1);
        lineX = lineX + 1/slopeBall;
        temp = lineY + 1;
        if (postive) temp = lineY - 1;
        else if (temp > 480)
        {
          temp = lineY - 1;
          postive = true;
        }
        lineY = temp;
        distance = dist(lineX, lineY, targetX, targetY);
        if(distance <= 20)
        {
          collsionLine(lineX,lineY);
          break;
        }
      }
  }
  void qudrant4Right()
  {
    lineX = cueStickX;
    lineY = cueStickY;
      while (lineY < 480) {
        ellipse(lineX, lineY, 1, 1);
        temp = lineX + 1;
        lineY = lineY + slopeBall;
        if (postive) temp = lineX - 1;
        else if (temp > 960)
        {
          temp = lineX - 1;
          postive = true;
        }
        lineX = temp;
        distance = dist(lineX, lineY, targetX, targetY);
        if(distance <= 20)
        {
          collsionLine(lineX,lineY);
          break;
        }
      }
  }
  
  void collsionLine(float lineX, float lineY)
  {
    float colSlope, tempSlope;
    //distance = dist(lineX, lineY, targetX, targetY);
          strokeWeight(2);
          distX = lineX - targetX;
          distY = lineY - targetY;
          colSlope = (cueBallY - targetY)/(cueBallX - targetX);
          tempSlope = (cueBallY - lineY)/(cueBallX - lineX);
          ellipse(lineX, lineY, 20, 20);
          if(colSlope < tempSlope) line(lineX, lineY, lineX + 10*distY, lineY - 10*distX);
          else if(colSlope > tempSlope) line(lineX, lineY, lineX - 10*distY, lineY + 10*distX);
          else line(lineX, lineY, targetX, targetY);
          line(targetX, targetY, targetX-10*distX, targetY-10*distY);
       
  }
  
}


