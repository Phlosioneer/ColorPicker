
import java.lang.ref.WeakReference;

Graph graph;
Slider rampSizeSlider;
Slider rampCountSlider;
Slider hueStepSlider;
Slider desatSlider;
Picker pickerSlider;

Button saveButton;
Button loadButton;
Button exportButton;

// [rampCount][rampSize];
// [0] is the first ramp, and [0][3] is the 4th swatch in the first ramp.
color[][] rampColors;
// Same as rampColors, with less saturation.
// The first and last swatches of each ramp are ignored.
color[][] desatRampColors;

ArrayList<WeakReference<Handle>> globalHandleTable;

final int[] rampCountAllowedValues = new int[]{
  1, 2, 3, 4, 5, 6, 8, 9, 10
};

final int MIN_RAMP_SIZE = 2;
final int MAX_RAMP_SIZE = 5;
final int MIN_HUE_STEP = -25;
final int MAX_HUE_STEP = 25;
final float MIN_DESAT = 0.3;
final float MAX_DESAT = 1.0;

void setup() {
  size(800, 500);
  textFont(loadFont("ArialMT-14.vlw"));
  globalHandleTable = new ArrayList();
  
  graph = new Graph();
  rampSizeSlider = new Slider(new PVector(315, 20), 100, MIN_RAMP_SIZE, MAX_RAMP_SIZE);
  rampSizeSlider.intOnly = true;
  rampCountSlider = new Slider(new PVector(315, 40), 100, 1, rampCountAllowedValues.length);
  rampCountSlider.intOnly = true;
  hueStepSlider = new Slider(new PVector(315, 60), 100, MIN_HUE_STEP, MAX_HUE_STEP);
  hueStepSlider.intOnly = true;
  desatSlider = new Slider(new PVector(315, 80), 100, MIN_DESAT, MAX_DESAT);
  pickerSlider = new Picker(new PVector(215, 100));
  rampColors = null;
  
  rampSizeSlider.setValue(2);
  rampCountSlider.setValue(4);
  hueStepSlider.setValue(15);
  desatSlider.setValue(0.6);
  pickerSlider.setValue(random(0, 256));
  
  saveButton = new SaveButton(new PVector(215, 120), 20);
  loadButton = new LoadButton(new PVector(saveButton.origin.x + saveButton.size.x + 5, 120), 20);
  exportButton = new ExportButton(new PVector(loadButton.origin.x + loadButton.size.x + 5, 120), 20);
}

void draw() {
  background(0);
  
  graph.draw();
  rampSizeSlider.draw();
  rampCountSlider.draw();
  hueStepSlider.draw();
  desatSlider.draw();
  pickerSlider.draw();
  saveButton.draw();
  loadButton.draw();
  exportButton.draw();
  
  fill(255);
  textAlign(LEFT, CENTER);
  text(str(getRampSize()), 430, 20);
  text(str(getRampCount()), 430, 40);
  text(str(getHueStep()), 430, 60);
  text(str(desatSlider.getValue()), 430, 80);
  text("Ramp Length:", 215, 20);
  text("# of Ramps:", 215, 40);
  text("Hue Step:", 215, 60);
  text("Desaturation:", 215, 80);
  
  lazyRebuildSwatches();
  drawSwatches();
}

int getRampSize() {
  int slider = (int)rampSizeSlider.getValue();
  return slider * 2 + 1;
}

int getRampCount() {
  int index = (int)rampCountSlider.getValue() - 1;
  return rampCountAllowedValues[index];
}

int getHueStep() {
  return (int)hueStepSlider.getValue();
}

int getStartHue() {
  int centerHue = (int)pickerSlider.getValue();
  int startHue = centerHue - getHueStep() * (int)rampSizeSlider.getValue();
  if (startHue < 0) {
    startHue += 256;
  }
  return startHue;
}

void mousePressed() {
  graph.mousePressed();
  rampSizeSlider.mousePressed();
  rampCountSlider.mousePressed();
  hueStepSlider.mousePressed();
  desatSlider.mousePressed();
  pickerSlider.mousePressed();
  saveButton.mousePressed();
  loadButton.mousePressed();
  exportButton.mousePressed();
}

void mouseReleased() {
  graph.mouseReleased();
  rampSizeSlider.mouseReleased();
  rampCountSlider.mouseReleased();
  hueStepSlider.mouseReleased();
  desatSlider.mouseReleased();
  pickerSlider.mouseReleased();
  saveButton.mouseReleased();
  loadButton.mouseReleased();
  exportButton.mouseReleased();
}

// Order of max and min doesn't matter.
float clamp(float value, float max, float min) {
  float realMin = min;
  float realMax = max;
  if (max < min) {
    realMin = max;
    realMax = min;
  }
  float temp = max(value, realMin);
  return min(temp, realMax);
}
