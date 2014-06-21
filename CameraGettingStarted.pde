import ketai.cv.facedetector.*;
import ketai.camera.*;
import ketai.sensors.*;

import android.media.*;
import android.content.res.*;

KetaiCamera cam;
KetaiSensor sensor;

int MAX_FACES = 20; // 顔の最大認識数を指定
int camWidth=1280,camHeight=720; // カメラの解像度を指定
int phase; // 0はオープニング、1はメイン
int SWcat,SWflash,SWauto,SWsel; // 各スイッチの状態
int auto;
int totalCam,currentCam;

float t,mul,exp; // オープニングで使う変数
float acX,acY; // オープニングで使う加速度

PImage cat,cat0,cat1; // 各ボタンの画像

KetaiSimpleFace[] faces = new KetaiSimpleFace[MAX_FACES];

void setup(){
  orientation(LANDSCAPE);
  rectMode(CENTER);
  imageMode(CENTER);
  textAlign(CENTER,CENTER);
  textSize(72);
  
  mul=1;
  exp=80;
  cat=loadImage("cat.png");
  cat0=loadImage("cat0.png");
  cat1=loadImage("cat1.png");
  
  cam = new KetaiCamera(this, camWidth, camHeight, 24);
  sensor=new KetaiSensor(this);
  sensor.start();
  faces = KetaiFaceDetector.findFaces(cam, MAX_FACES);
  
  totalCam=cam.getNumberOfCameras();

  strokeCap(ROUND);
}

void draw(){
  if(phase==0){
    noStroke();
    pushMatrix();
    translate(width/2,height/2);
    t=t+PI/8;
    for(int ry=-17;ry<17;ry++){
      for(int rx=-17;rx<17;rx++){
        fill(127+sin(dist(-0.5,-0.5,rx,ry)*mul-t)*127,127+sin(dist(-0.5,-0.5,rx,ry)*mul-t+PI/3*2)*127,127+sin(dist(-0.5,-0.5,rx,ry)*mul-t+PI/3*4)*127);
        rect(rx*40+20,ry*40+20,40,40);
      }
    }
    rotate(atan2(-acY,acX));
    image(cat,0,0,500+sin(t/4)*80, 500+sin(t/4)*80);
    popMatrix();
  }else{
    if(cam.isStarted()){
      background(0);
      image(cam, width/2,height/2);
      
      if(SWcat==0){
        stroke(#FF0066);
        strokeWeight(20);
        fill(#FFFFFF);
        ellipse(width-140,height/2,200,200);
        image(cat0,width-140,height/2,200,200);
      }else{
        stroke(#FFFFFF);
        strokeWeight(20);
        fill(#FF0066);
        ellipse(width-140,height/2,200,200);
        image(cat1,width-140,height/2,200,200);
      }
      if(SWcat==1&&dist(mouseX,mouseY,width-140,height/2)>=100){
        SWcat=0;
      }
      
      if(SWflash==0){
        stroke(#FF0066);
        strokeWeight(10);
        fill(#FFFFFF);
        rect(80,80,120,120,10);
        ellipse(80,80,40,40);
        if(cam.isFlashEnabled()){
          for(float flashC=0;flashC<2*PI;flashC+=PI/4){
            line(80+cos(flashC)*35,80+sin(flashC)*35,80+cos(flashC)*45,80+sin(flashC)*45);
          }
        }
      }else{
        stroke(#FFFFFF);
        strokeWeight(10);
        fill(#FF0066);
        rect(80,80,120,120,10);
        ellipse(80,80,40,40);
        if(cam.isFlashEnabled()){
          for(float flashC=0;flashC<2*PI;flashC+=PI/4){
            line(80+cos(flashC)*35,80+sin(flashC)*35,80+cos(flashC)*45,80+sin(flashC)*45);
          }
        }
      }
      if(SWflash==1&&(abs(mouseX-80)>=60||abs(mouseY-80)>=60)){
        SWflash=0;
      }
      
      if(SWauto==0){
        stroke(#FF0066);
        strokeWeight(10);
        fill(#FFFFFF);
        rect(80,220,120,120,10);
        fill(#FF0066);
        if(auto==1){text("AS",80,220);}
        else{text("MS",80,220);}
      }else{
        stroke(#FFFFFF);
        strokeWeight(10);
        fill(#FF0066);
        rect(80,220,120,120,10);
        fill(#FFFFFF);
        if(auto==1){text("AS",80,220);}
        else{text("MS",80,220);}
      }
      if(SWauto==1&&(abs(mouseX-80)>=60||abs(mouseY-220)>=60)){
        SWauto=0;
      }
      
      if(SWsel==0){
        stroke(#FF0066);
        strokeWeight(10);
        fill(#FFFFFF);
        rect(220,80,120,120,10);
        arc(220,80,60,60,0.5,PI-0.5);
        arc(220,80,60,60,PI+0.5,2*PI-0.5);
        fill(#FF0066);
        triangle(220+20,80-10,220+30,80-20,220+30,80-10);
        triangle(220-20,80+10,220-30,80+20,220-30,80+10);
      }else{
        stroke(#FFFFFF);
        strokeWeight(10);
        fill(#FF0066);
        rect(220,80,120,120,10);
        arc(220,80,60,60,0.5,PI-0.5);
        arc(220,80,60,60,PI+0.5,2*PI-0.5);
        fill(#FFFFFF);
        triangle(220+20,80-10,220+30,80-20,220+30,80-10);
        triangle(220-20,80+10,220-30,80+20,220-30,80+10);
      }
      if(SWsel==1&&(abs(mouseX-220)>=60||abs(mouseY-80)>=60)){
        SWsel=0;
      }
    }else{
      background(0);
      image(cam, width/2,height/2);
      stroke(0, 255, 0);
      strokeWeight(2);
      noFill();
      for (int i=0; i < faces.length; i++){//      rect(width/2-camWidth/2+faces[i].location.x, height/2-camHeight/2+faces[i].location.y, 2.5*faces[i].distance, 3*faces[i].distance);
        image(cat,width/2-camWidth/2+faces[i].location.x, height/2-camHeight/2+faces[i].location.y-faces[i].distance*0.3, 5*faces[i].distance, 5*faces[i].distance);
      }
    }
  }
}

void onAccelerometerEvent(float x,float y,float z){
  acX=x;acY=y;
}

void onCameraPreviewEvent(){
  cam.read();
}

void mousePressed(){
  if(phase==0&&dist(mouseX,mouseY,width/2,height/2)<250){
    try {
      MediaPlayer snd = new MediaPlayer();
      AssetManager assets = this.getAssets();
      AssetFileDescriptor fd = assets.openFd("cat.mp3");
      snd.setDataSource(fd.getFileDescriptor(), fd.getStartOffset(), fd.getLength());
      snd.prepare();
      snd.start();
    }catch (IllegalArgumentException e) {
       e.printStackTrace();
    }catch (IllegalStateException e) {
       e.printStackTrace();
    }catch (IOException e) {
       e.printStackTrace();
    }
  }else{
    if(dist(mouseX,mouseY,width-140,height/2)<100){
      SWcat=1;
    }
    if(abs(mouseX-80)<60&&abs(mouseY-80)<60){
      SWflash=1;
    }
    if(abs(mouseX-80)<60&&abs(mouseY-220)<60){
      SWauto=1;
    }
    if(abs(mouseX-220)<60&&abs(mouseY-80)<60){
      SWsel=1;
    }
  }
}

void mouseReleased(){
  if(phase==1){
    if(cam.isStarted()){
      if(SWcat==1){
        cam.stop();
        faces = KetaiFaceDetector.findFaces(cam, MAX_FACES);
      }
      if(SWflash==1){
        if(cam.isFlashEnabled()){cam.disableFlash();}
        else{cam.enableFlash();}
      }
      if(SWauto==1){
        if(auto==1){auto=0;cam.manualSettings();}
        else{auto=1;cam.autoSettings();}
      }
      if(SWsel==1){
        if(currentCam==totalCam-1){currentCam=0;cam.setCameraID(0);}
        else{currentCam++;cam.setCameraID(currentCam);}
        cam.stop();
        cam.start();
      }
    }else{
      cam.start();
      cam.autoSettings();
      auto=1;
    }
  SWcat=0;
  SWflash=0;
  SWauto=0;
  SWsel=0;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == MENU) {
      if(phase==0){
        sensor.stop();
        phase=1;
        cam.start();
        cam.autoSettings();
        auto=1;
      }else{
        cam.stop();
        phase=0;
        sensor.start();
      }
    }
  }
}