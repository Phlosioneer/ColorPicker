

class Handle {
    final int HANDLE_RADIUS = 4;
    final int HANDLE_DIAMETER = HANDLE_RADIUS * 2;
    final int HANDLE_MOUSE_RADIUS = 7;
    
    PVector pos;
    boolean isPressed;
    color handleColor = color(0, 200, 0);
    PVector bounds1;
    PVector bounds2;
    
    Handle(PVector pos, PVector bounds1, PVector bounds2) {
      this.pos = pos;
      isPressed = false;
      this.bounds1 = bounds1;
      this.bounds2 = bounds2;
      globalHandleTable.add(new WeakReference(this));
    }
    
    void update() {
      if (isPressed) {
        pos.x = clamp(mouseX, bounds1.x, bounds2.x);
        pos.y = clamp(mouseY, bounds1.y, bounds2.y);
      }
    }
    
    void draw() {
      noStroke();
      fill(handleColor);
      ellipseMode(CENTER);
      ellipse(pos.x, pos.y, HANDLE_DIAMETER, HANDLE_DIAMETER);
    }
    
    boolean mousePressed() {
      PVector mouse = new PVector(mouseX, mouseY);
      if (mouse.dist(pos) < HANDLE_MOUSE_RADIUS) {
        isPressed = true;
        return true;
      }
      return false;
    }
    
    void mouseReleased() {
      isPressed = false;
    }
}
