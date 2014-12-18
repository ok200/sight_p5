import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress remote;

int count = 1000;

void setup() {
  oscP5 = new OscP5(this, 12000);
  remote = new NetAddress("127.0.0.1", 57110);
  frameRate(5);
}

void draw() {
  float pan = random(-1, 1);
  
  OscMessage msg = new OscMessage("/n_set"); 
  
  msg.add(count-3); //Synth ID

  msg.add("gate");
  msg.add(0);
  
  oscP5.send(msg, remote);
  
  msg = new OscMessage("/s_new"); 
  
  msg.add("synth" + (int)(random(0, 15))); //Synth名
  msg.add(count++); //Synth ID
  msg.add(1); //アクションNo.
  msg.add(1); //ノードID

  msg.add("pan");
  msg.add(pan);
  msg.add("amp");
  msg.add(1.0f);
  for (int i=1; i<=6; i++) {
    msg.add("p"+i);
    msg.add(random(-0.5, 0.5));
  }
  
  oscP5.send(msg, remote);
}

