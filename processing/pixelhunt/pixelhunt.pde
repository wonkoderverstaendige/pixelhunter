/**
 * Scan the screen in ever smaller white rectangles 
 */
final int LINEFEED = 10; 
import processing.serial.*; 
 
Serial port;
PixelHunter pxh;

void setup() {
  fullScreen();
  noStroke();
  colorMode(RGB, 1.0);
  rectMode(CORNER);
  pxh = new PixelHunter();
  //printArray(Serial.list());
  port = new Serial(this, Serial.list()[0], 57600); // finding the port: "/dev/ttyACM0" or Serial.list()[0]
  port.bufferUntil(LINEFEED);
}

void draw() {
  background(0.0);
  pxh.tick(millis());
}

void serialEvent(Serial p) {
  // grab trasmitted value as a float
  // Using me AnalogSensor class, the arduino
  // right now sends "[type]:[value]\n"
  // so trim, split, index, return, profit.
  String[] list = split(trim(p.readString()), ':');
  if (list.length == 2) {
    pxh.process(float(list[1]));
  } else {
    println("data error");
  }
}