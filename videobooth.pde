/*
need
 webcam, usb extension, tablet, physical button, projector, recording progress bar
 
 
 */

import processing.video.*;
Capture cam;
int cam_w = 1280;
int cam_h = 720;

// GIF export
boolean ENABLE_GIF = false;
import gifAnimation.*;
GifMaker gifExport;

// MP4 export
boolean ENABLE_MP4 = true;
import com.hamoid.*;
VideoExport videoExport;

PGraphics pg;  // context to render/save

boolean isRecording = false;
int recDuration = 7000;
long startedRec = -99999;
int skipFrames = 10;
String fn;
String dir = "out/";
int recFrameIndex = 0;

PFont font;

// messages
long msgStarted = -999990;
int msgDuration = 1 * 1000;
String lastMsg = "";
long countdownStarted = -99999;
int countdownDuration = 4000;
int countdown = countdownDuration;
boolean isCounting = false;

PImage [] duplicates = new PImage[100];
int repeatBy = 3;

public void setup() {
  size(1280, 720);
  //frameRate(FRAME_RATE);
  frameRate(30);
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(248);
  font = loadFont("Domine-Bold-248.vlw");
  textFont(font);

  pg = createGraphics(cam_w, cam_h);

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, cam_w, cam_h);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    //cam = new Capture(this, cameras[0]);
    // Or, the settings can be defined based on the text in the list
    cam = new Capture(this, cam_w, cam_h, 15);

    // Start capturing the images from the camera
    cam.start();
  }
}


void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  pg.beginDraw();
  pg.image(cam, 0, 0);

  //for(int i = 0; i < 200; i++){
  //  pg.fill(random(255), random(255), random(255));
  //  pg.noStroke();
  //  pg.ellipse(random(pg.width), random(pg.height), 10, 10);
  //}
  pg.endDraw();

  image(pg, 0, 0, width, height);

  if (isCounting) {

    int timeLeft = (countdownDuration - int(millis() - countdownStarted)) / 1000;
    println(timeLeft);

    fill(255);
    stroke(127);
    strokeWeight(12);
    text(timeLeft, width/2, height/2);

    if (timeLeft <= 0) {

      background(255, 0, 0);

      isCounting = false;

      startRecording();
    }
  }

  // check rules
  if (isRecording && millis() > startedRec + recDuration) {
    endRecording();
  }

  // display messages
  if (millis() < msgStarted + msgDuration) {
    fill(255);
    stroke(127);
    strokeWeight(4);
    text(lastMsg, width/2, height/2);
  }

  if (isRecording) {

    // draw recording progress bar

    noFill();
    stroke(255, 180);
    strokeWeight(6);
    rect(10, 10, width-20, 50);
    // scrubber
    stroke(255, 0, 0, 180);
    float x = map(millis(), startedRec, startedRec + recDuration, 10, width-20);
    line(x, 10, x, 60);

    //if (ENABLE_GIF) {
    //  // we make the gif-"framerate" the same as the sketch framerate.
    //  gifExport.setDelay(1000/FRAME_RATE/4);
    //  gifExport.addFrame();  // can pass PImage as argument
    //}

    if (ENABLE_MP4 && frameCount % skipFrames == 0) {
      //for (int i = 0; i < duplicateFrames; i++)
      videoExport.saveFrame();

      // store a duplicate so we can add to loop later
      duplicates[recFrameIndex++] = pg.get();
    }
  }
}

void keyPressed() {
  println(key);

  if (key=='n' && !isCounting) {
    startCounting();
  }

  if (key=='s' && isRecording) {
    endRecording();
  }
}

void startCounting() {

  isCounting = true;
  countdown = countdownDuration;
  countdownStarted = millis();
}

void startRecording() {

  // new recording
  isRecording = true;
  startedRec = millis();
  recFrameIndex = 0;

  int s = second();  // Values from 0 - 59
  int m = minute();  // Values from 0 - 59
  int h = hour();    // Values from 0 - 23
  fn = str(h)+str(m)+str(s);

  if (ENABLE_GIF) fn += ".gif";
  if (ENABLE_MP4) fn += ".mp4";

  println(fn);

  if (ENABLE_GIF) {
    gifExport = new GifMaker(this, dir+fn);
    gifExport.setRepeat(0); 
    //gifExport.setTransparent(255, 255, 255);
  }

  if (ENABLE_MP4) {
    videoExport = new VideoExport(this, dir+fn, pg);
    //videoExport.setFrameRate(FRAME_RATE*4);
    videoExport.setFrameRate(15);
    videoExport.startMovie();
  }
}

void endRecording() {

  isRecording = false;

  // make video loop n times by using duplicate frames array
  pg.beginDraw();
  for (int n = 1; n < repeatBy; n++) {
    for (int i = 0; i < recFrameIndex; i++) {
      pg.image(duplicates[i], 0, 0);
      videoExport.saveFrame();
    }
  }
  pg.beginDraw();

  lastMsg = "saved!";
  msgStarted = millis();
  thread("uploadFile");
}

void uploadFile() {
  // stop recording
  if (ENABLE_GIF) {
    gifExport.finish();
    println("gif exported");
  }

  if (ENABLE_MP4) {
    videoExport.endMovie();
    println("mp4 exported");
  }

  // upload to server
  String ftp[] = loadStrings("http://localhost:8888/reeves/videobooth/"+dir+"uploader.php?value="+fn);
  printArray(ftp); // report
}
