
class Curve {
  float minX;
  float maxX;
  float minY;
  float maxY;
  
  Handle startHandle;
  Handle middleHandle;
  Handle endHandle;
  color curveColor;
  color guideColor;
  
  Curve(color curveColor, Graph parent) {
    this.curveColor = curveColor;
    
    minX = parent.origin.x;
    minY = parent.origin.y;
    maxX = parent.origin.x + parent.size.x;
    maxY = parent.origin.y + parent.size.y;
    
    colorMode(RGB);
    guideColor = color(red(curveColor), green(curveColor), blue(curveColor), 255.0/4);
    
    PVector b1 = parent.origin.copy();
    PVector b2 = new PVector(parent.origin.x, parent.origin.y + parent.size.y);
    startHandle = new Handle(new PVector(minX, maxY), b1, b2);
    
    b1 = b1.copy();
    b2 = new PVector(parent.origin.x + parent.size.x, parent.origin.y + parent.size.y);
    println(b1, b2);
    middleHandle = new Handle(new PVector((minX + maxX)/2, minY), b1, b2);
    
    b1 = new PVector(parent.origin.x + parent.size.x, parent.origin.y);
    b2 = b2.copy();
    endHandle = new Handle(new PVector(maxX, maxY), b1, b2);
  }
  
  void update() {
    startHandle.update();
    middleHandle.update();
    endHandle.update();
  }
  
  void drawCurve() {
    stroke(curveColor);
    strokeWeight(1);
    noFill();
    bezier(startHandle.pos.x, startHandle.pos.y, middleHandle.pos.x, middleHandle.pos.y,
           middleHandle.pos.x, middleHandle.pos.y, endHandle.pos.x, endHandle.pos.y);
    stroke(guideColor);
    line(startHandle.pos.x, startHandle.pos.y, middleHandle.pos.x, middleHandle.pos.y);
    line(middleHandle.pos.x, middleHandle.pos.y, endHandle.pos.x, endHandle.pos.y);
  }
  
  void drawHandles() {
    startHandle.draw();
    middleHandle.draw();
    endHandle.draw();
  }
  
  // Returns true if a handle is pressed, consuming the event.
  boolean mousePressed() {
    if (startHandle.mousePressed()) {
      return true;
    } else if (middleHandle.mousePressed()) {
      return true;
    } else if (endHandle.mousePressed()) {
      return true;
    } else {
      return false;
    }
  }
  
  void mouseReleased() {
    startHandle.mouseReleased();
    middleHandle.mouseReleased();
    endHandle.mouseReleased();
  }
  
  float getValue(float x) {
    final float tolerance = 0.1;
    final int MAX_ITER = 1000;
    
    // We know that X is monotonically increasing for all of our curves.
    // So we can use a binary search to find an arbitrarily close approximation
    // of x.
    
    float currentMax = 0;
    float currentMin = 1;
    PVector minVector = evalWithT(0);
    PVector maxVector = evalWithT(1);
    assert(x >= minVector.x);
    assert(x <= maxVector.x);
    if (closeEnough(evalWithT(0).x, x, tolerance)) {
      return evalWithT(0).y;
    }
    if (closeEnough(evalWithT(1).x, x, tolerance)) {
      return evalWithT(1).y;
    }
    
    for (int i = 0; i < MAX_ITER; i++) {
      float midpoint = (currentMax + currentMin) / 2;
      float newX = evalWithT(midpoint).x;
      if (closeEnough(newX, x, tolerance)) {
        return evalWithT(midpoint).y;
      }
      
      if (x < newX) {
        currentMin = midpoint;
      } else {
        currentMax = midpoint;
      }
    }
    
    throw new RuntimeException("Unable to find value for " + x + " after " + MAX_ITER + " iterations.");
  }
  
  private boolean closeEnough(float v1, float v2, float tolerance) {
    return abs(v1 - v2) < abs(tolerance);
  }
  
  private PVector evalWithT(float t) {
    float x = (1 - t) * (1 - t) * startHandle.pos.x + 2 * (1 - t) * t * middleHandle.pos.x + t * t * endHandle.pos.x;
    float y = (1 - t) * (1 - t) * startHandle.pos.y + 2 * (1 - t) * t * middleHandle.pos.y + t * t * endHandle.pos.y;
    return new PVector(x, y);
  }
  
  void setStartValue(float percent) {
    float inverted = 1 - percent;
    startHandle.pos.y = minY + inverted * (maxY - minY);
  }
  
  void setEndValue(float percent) {
    float inverted = 1 - percent;
    endHandle.pos.y = minY + inverted * (maxY - minY);
  }
  
  void setMiddleValue(float percentX, float percentY) {
    float invertedY = 1 - percentY;
    middleHandle.pos.x = minX + percentX * (maxX - minX);
    middleHandle.pos.y = minY + invertedY * (maxY - minY);
  }
  
  float getStartValue() {
    float inverted = (startHandle.pos.y - minY) / (maxY - minY);
    return 1 - inverted;
  }
  
  PVector getMiddleValue() {
    float invertedY = (middleHandle.pos.y - minY) / (maxY - minY);
    float percentX = (middleHandle.pos.x - minX) / (maxX - minX);
    float percentY = 1 - invertedY;
    return new PVector(percentX, percentY);
  }
  
  float getEndValue() {
    float inverted = (endHandle.pos.y - minY) / (maxY - minY);
    return 1 - inverted;
  }
}

class Graph {
  PVector size;
  PVector origin;
  
  Curve satCurve;
  Curve brightCurve;
  
  Graph() {
    size = new PVector(200, 200);
    origin = new PVector(5, 25);
    satCurve = new Curve(color(255, 0, 0), this);
    brightCurve = new Curve(color(0, 0, 255), this);
    
    // Recommended defaults
    brightCurve.setStartValue(0.2);
    brightCurve.setMiddleValue(0.4, 0.8);
    brightCurve.setEndValue(1);
    satCurve.setStartValue(0.25);
    satCurve.setMiddleValue(0.3, 0.9);
    satCurve.setEndValue(0.3);
  }
  
  void draw() {
    fill(255);
    noStroke();
    rectMode(CORNER);
    rect(5, 5, size.x, 30);
    
    stroke(150);
    strokeWeight(2);
    rect(origin.x, origin.y, size.x, size.y);
    
    strokeWeight(1);
    fill(satCurve.curveColor);
    float textX = 12;
    textAlign(LEFT, TOP);
    text("Saturation", textX, 10);
    textX += textWidth("Saturation") + 15;
    fill(brightCurve.curveColor);
    text("Brightness", textX, 10);
    
    satCurve.update();
    brightCurve.update();
    satCurve.drawCurve();
    brightCurve.drawCurve();
    satCurve.drawHandles();
    brightCurve.drawHandles();
  }
  
  void mousePressed() {
    if (satCurve.mousePressed()) {
      return;
    } else {
      brightCurve.mousePressed();
    }
  }
  
  void mouseReleased() {
    satCurve.mouseReleased();
    brightCurve.mouseReleased();
  }
  
  float getSatValue(float percent) {
    return getCurveValue(percent, satCurve);
  }
  
  float getBrightValue(float percent) {
    return getCurveValue(percent, brightCurve);
  }
  
  // input is a percent (0 to 1) along the x axis. output is a percent (0 to 1) along the y axis.
  private float getCurveValue(float percent, Curve curve) {
    assert(percent >= 0);
    assert(percent <= 1);
    float x = origin.x + percent * size.x;
    float invertedY = curve.getValue(x);
    float invertedPercent = (invertedY - origin.y) / size.y;
    assert(invertedPercent >= 0);
    assert(invertedPercent <= 1);
    return 1 - invertedPercent;
  }
}
