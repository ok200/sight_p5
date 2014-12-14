import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress remote;

void setup() {
  size(320, 240);
  oscP5 = new OscP5(this, 15000);
  remote = new NetAddress("127.0.0.1", 12000);
}

void draw() {
  background(255);
}

void mousePressed() {
  OscMessage msg = new OscMessage("/frame");
  msg.add(1);
  
  msg.add(random(24, 48)); // sig
  msg.add(random(-1, 1)); // p1
  msg.add(random(-1, 1)); // p2
  msg.add(random(-1, 1)); // p3
  msg.add(random(-1, 1)); // p4
  msg.add(random(-1, 1)); // p5
  msg.add(random(-1, 1)); // p6
  msg.add((float)mouseX); // x
  msg.add((float)mouseY); // y
  msg.add(random(255)); // r
  msg.add(random(255)); // g
  msg.add(random(255)); // b
  
  oscP5.send(msg, remote);
}
