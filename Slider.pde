
class Slider {
  boolean intOnly;
  Handle handle;
  PVector origin;
  float drawLength;
  
  float min;
  float max;
  
  boolean handlePressed;
  
  Slider(PVector origin, float drawLength, float min, float max) {
    intOnly = false;
    this.origin = origin;
    this.drawLength = drawLength;
    this.min = min;
    this.max = max;
    if (max < min) {
      this.min = max;
      this.max = min;
    }
    
    PVector b1 = new PVector(origin.x, origin.y);
    PVector b2 = new PVector(origin.x + drawLength, origin.y);
    handle = new Handle(b1.copy(), b1, b2);
    handlePressed = false;
  }
  
  void draw() {
    handle.update();
    if (intOnly && handle.isPressed) {
      setValue(getValue());
    }
    
    stroke(255);
    strokeWeight(3);
    line(origin.x, origin.y, origin.x + drawLength, origin.y);
    handle.draw();
  }
  
  float getValue() {
    float relative = handle.pos.x - origin.x;
    float percent = relative / drawLength;
    float value = min + percent * (max - min);
    if (intOnly) {
      return round(value);
    } else {
      return value;
    }
  }
  
  void setValue(float value) {
    float realValue = value;
    if (intOnly) {
      realValue = round(value);
    }
    
    float clampedValue = clamp(realValue, max, min);
    float percent = (clampedValue - min) / (max - min);
    float relative = percent * drawLength;
    handle.pos.x = origin.x + relative;
  }
  
  void mousePressed() {
    handle.mousePressed();
  }
  
  void mouseReleased() {
    handle.mouseReleased();
  }
}
