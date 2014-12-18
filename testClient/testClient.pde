import oscP5.*;
import netP5.*;

// constants
int videoWidth = 320;
int videoHeight = 240;

int life = 3;

// variables
OscP5 oscP5;
NetAddress remote;
int count = 0;
int dim = 6;
ArrayList<Feature> features = new ArrayList<Feature>();

long prev_mil = 0;
int frequency = 5;

boolean sem = false;

void setup() {
  size(videoWidth, videoHeight);
  frameRate(30);
  
  oscP5 = new OscP5(this, 12000);
  remote = new NetAddress("127.0.0.1", 57110);
}

void draw() {
  background(255);
  noFill();
    while (sem) {
      delay(1);
    }
  sem = true;
  for (Feature f : features) {
    strokeWeight(1);    
    stroke(f.r, f.g, f.b);
    fill(f.r+50, f.g+50, f.b+50, 100-f.count*30);
    ellipse(f.x, f.y, 100*f.significance/64, 100*f.significance/64);
    strokeWeight(2);    
    for (int i=0; i<6; i++) {
      float len = 50 * (f.vector[i]+1);
      line (f.x, f.y, f.x + len*sin(TWO_PI/6*i), f.y - len*cos(TWO_PI/6*i));
    }
  }
  sem = false;
}

void oscEvent(OscMessage msg) {
  long now = millis();
  if (now - prev_mil < 1000.0 / frequency) return;
  prev_mil = now;
  
  print("### received an osc message.");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
  
  // parse
  if (msg.addrPattern().equals("/frame")) {    
    while (sem) {
      delay(1);
    }
    sem = true;
    
    println("[[frame received]]");
    release();
//    features.clear();
    
    int m = msg.get(0).intValue();
    println("m = " + m);
    for (int i=0; i<m; i++) {
//      println("feature " + i);
      float sig = msg.get(1 + i*(dim + 6)).floatValue();
      float[] vec = new float[dim];
      for (int j=0; j<dim; j++) {
        vec[j] = msg.get(1 + i*(dim + 6) + 1 + j).floatValue();
      }
      float x = msg.get(1 + i*(dim + 6) + 1 + dim).floatValue();
      float y = msg.get(1 + i*(dim + 6) + 1 + dim + 1).floatValue();
      float r = msg.get(1 + i*(dim + 6) + 1 + dim + 2).floatValue();
      float g = msg.get(1 + i*(dim + 6) + 1 + dim + 3).floatValue();
      float b = msg.get(1 + i*(dim + 6) + 1 + dim + 4).floatValue();
      features.add( new Feature(vec, x, y, r, g, b, sig, 1000 + count) );
      count++;
    }
    synthesize();
    
    sem = false;
  }
}

int select_timbre(Feature f) {
  float r = f.r, g = f.g, b = f.b;
  float max = r > g ? r : g;
  max = max > b ? max : b;
  float min = r < g ? r : g;
  min = min < b ? min : b;
  float h = max - min;
  if (h > 0.0f) {
      if (max == r) {
          h = (g - b) / h;
          if (h < 0.0f) {
              h += 6.0f;
          }
      } else if (max == g) {
          h = 2.0f + (b - r) / h;
      } else {
          h = 4.0f + (r - g) / h;
      }
  }
  h /= 6.0f;
  h *= 360;
  float s = (max - min);
  if (max != 0.0f)
      s /= max;
  float v = max;
  
  if (s < 0.05) { // 1
    return 0;
  } else if (s < 0.3) { // 6
    return (int)(1 + (h / 60));
  } else { // 8
    return (int)(7 + (h / 45));
  }
}

void synthesize() {
  for (Feature f : features) {
    if (f.count == 0) {
      OscMessage msg = new OscMessage("/s_new"); 
      
      msg.add("synth" + select_timbre(f)); //Synth名
      msg.add(f.id); //Synth ID
      msg.add(1); //アクションNo.
      msg.add(1); //ノードID
    
      msg.add("pan");
      msg.add((f.x/videoWidth)*2-1);
      msg.add("amp");
      msg.add(f.significance / 64);
      for (int i=1; i<=6; i++) {
        msg.add("p"+i);
        msg.add(f.vector[i-1]);
      }
      
      oscP5.send(msg, remote);
      println("synth " + select_timbre(f) + " (" + f.r + ", " + f.g + ", " + f.b + ")");
    }
    f.count++;
  }
}

void release() {
  for (int i=0; i<features.size(); i++) {
    Feature f = features.get(i);
    if (f.count >= life) {
      OscMessage msg = new OscMessage("/n_set"); 
      
      msg.add(f.id); //Synth ID
    
      msg.add("gate");
      msg.add(0);
      
      oscP5.send(msg, remote);
      //println("release: " + f.id);
      
      features.remove(f);
      i--;
    }
  }
}

