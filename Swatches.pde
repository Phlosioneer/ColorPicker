
void lazyRebuildSwatches() {
  int i = 0;
  while (i < globalHandleTable.size()) {
    WeakReference<Handle> ref = globalHandleTable.get(i);
    Handle handle = ref.get();
    if (handle == null) {
      globalHandleTable.remove(i);
    } else {
      if (handle.isPressed) {
        rebuildSwatches();
        break;
      }
      i += 1;
    }
  }
}

void rebuildSwatches() {
  int rampCount = getRampCount();
  int rampSize = getRampSize();
  int step = getHueStep();
  int startHue = getStartHue();
  
  int hueIncrement = 256/rampCount;
  
  colorMode(HSB);
  rampColors = new color[rampCount][rampSize];
  desatRampColors = new color[rampCount][rampSize - 2];
  float inverseDesat = 1 - desatSlider.getValue();
  for (int i = 0; i < rampCount; i++) { 
    int currentStartHue = (startHue + i * hueIncrement) % 256;
    for (int j = 0; j < rampSize; j++) {
      int currentHue = (currentStartHue + j * step) % 256;
      float graphIndex = ((float)j) / (float)(rampSize - 1);
      float currentSatPercent = graph.getSatValue(graphIndex);
      float currentBrightPercent = graph.getBrightValue(graphIndex);
      int currentSat = round(currentSatPercent * 256);
      int currentBright = round(currentBrightPercent * 256);
      
      rampColors[i][j] = color(currentHue, currentSat, currentBright);
      if (j > 0 && j < rampSize - 1) {
        int reversedJ = rampSize - j - 1;
        desatRampColors[i][reversedJ - 1] = color(currentHue, currentSat * inverseDesat, currentBright);
      }
    }
  }
  colorMode(RGB);
}

void drawSwatches() {
  if (rampColors == null || desatRampColors == null) {
    rebuildSwatches();
  }
  
  PVector rampAreaOrigin = new PVector(5, 230);
  PVector rampAreaSize = new PVector(width - rampAreaOrigin.x - 15, height - rampAreaOrigin.y - 10);
  
  int rampCount = getRampCount();
  int rampSize = getRampSize();
  int rampAndDesatSize = rampSize * 2 - 2;
  float swatchHeight = rampAreaSize.y / rampCount;
  float swatchWidth = rampAreaSize.x / rampAndDesatSize;
  
  float desatOffset = rampSize * swatchWidth + 5;
  for (int i = 0; i < rampColors.length; i++) {
    for (int j = 0; j < rampColors[0].length; j++) {
      color swatchColor = rampColors[i][j];
      
      if (i == 0 && j == rampSize/2) {
        stroke(255);
      } else {
        noStroke();
      }
      fill(swatchColor);
      rectMode(CORNER);
      rect(rampAreaOrigin.x + j * swatchWidth, rampAreaOrigin.y + i * swatchHeight, swatchWidth - 1, swatchHeight - 1);
    }
    
    for (int j = 0; j < desatRampColors[0].length; j++) {
      color swatchColor = desatRampColors[i][j];
      
      noStroke();
      fill(swatchColor);
      rectMode(CORNER);
      rect(rampAreaOrigin.x + desatOffset + j * swatchWidth, rampAreaOrigin.y + i * swatchHeight, swatchWidth - 1, swatchHeight - 1);
    }
  }
}
