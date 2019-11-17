
final int COLOR_MAX = 256;
final int HUE_BAR_HEIGHT = 10;

class Picker extends Slider {
  
  PImage hueBar;
  
  Picker(PVector origin) {
    super(new PVector(origin.x, origin.y + HUE_BAR_HEIGHT / 2), COLOR_MAX, 0, COLOR_MAX - 1);
    intOnly = true;
    
    handle = new PickerHandle(handle);
    
    hueBar = createImage(COLOR_MAX, 10, RGB);
    hueBar.loadPixels();
    colorMode(HSB);
    for (int i = 0; i < COLOR_MAX; i++) {
      color currentColor = color(i, COLOR_MAX, COLOR_MAX);
      for (int j = 0; j < hueBar.height; j++) {
        int index = j * COLOR_MAX + i;
        hueBar.pixels[index] = currentColor;
      }
    }
    hueBar.updatePixels();
    colorMode(RGB);
  }
  
  void draw() {
    handle.update();
    
    imageMode(CORNER);
    image(hueBar, origin.x, origin.y - HUE_BAR_HEIGHT / 2);
    
    handle.draw();
  }
  
  void mousePressed() {    
    if (mouseX > origin.x && mouseY > origin.y - HUE_BAR_HEIGHT / 2) {
      if (mouseX < origin.x + COLOR_MAX && mouseY < origin.y + HUE_BAR_HEIGHT / 2) {
        handle.isPressed = true;
      }
    }
  }
  
  class PickerHandle extends Handle {
  
    PickerHandle(Handle original) {
      super(original.pos, original.bounds1, original.bounds2);
    }
    
    void update() {
      if (isPressed) {
        
        float length = abs(bounds1.x - bounds2.x);
        float bottomBound = min(bounds1.x, bounds2.x);
        float ratioMouseX = (mouseX - bottomBound) % length;
        if (ratioMouseX < 0) {
          ratioMouseX += length;
        }
        float trueMouseX = ratioMouseX + bottomBound;
        pos.y = clamp(mouseY, bounds1.y, bounds2.y);
        pos.x = trueMouseX;
      }
    }
    
    void draw() {
      ellipseMode(CENTER);
      noFill();
      stroke(0);
      strokeWeight(1);
      ellipse(pos.x, pos.y, 10, 10);
    }
  }
}
