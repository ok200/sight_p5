class Feature {
  float[] vector;
  float x, y;
  float r, g, b;
  float significance;
  int id;
  
  public Feature(float[] vector, float x, float y, float r, float g, float b, float significance, int id) {
    this.vector = vector;
    this.x = x;
    this.y = y;
    this.r = r;
    this.g = g;
    this.b = b;
    this.significance = significance;
    this.id = id;
  }
}
