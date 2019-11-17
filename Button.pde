

abstract class Button {
  final int MARGIN = 5;
  
  color border = color(50);
  color background = color(200);
  color depressedBackground = color(150);
  color textColor = color(0);
  
  PVector origin;
  PVector size;
  String text;
  
  boolean wasPressed;
  
  Button(PVector origin, float textHeight, String text) {
    this.origin = origin;
    this.text = text;
    float width = textWidth(text) + MARGIN * 2;
    float height = textHeight + MARGIN * 2;
    size = new PVector(width, height);
    
    wasPressed = false;
  }
  
  void draw() {
    if (wasPressed) {
      fill(depressedBackground);
    } else {
      fill(background);
    }
    strokeWeight(1);
    stroke(border);
    rectMode(CORNER);
    rect(origin.x, origin.y, size.x, size.y);
    
    PVector center = size.copy();
    center.div(2);
    center.add(origin);
    textAlign(CENTER, CENTER);
    fill(textColor);
    text(text, center.x, center.y);
  }
  
  boolean mouseIsWithinButton() {
    if (mouseX > origin.x && mouseY > origin.y) {
      if (mouseX < origin.x + size.x && mouseY < origin.y + size.y) {
        return true;
      }
    }
    return false;
  }
  
  void mousePressed() {
    wasPressed = mouseIsWithinButton();
  }
  
  void mouseReleased() {
    if (wasPressed && mouseIsWithinButton()) {
      buttonAction();
    }
    wasPressed = false;
  }
  
  abstract void buttonAction();
}

final String SERIAL_RAMP_COUNT = "rampCount";
final String SERIAL_RAMP_SIZE = "rampSize";
final String SERIAL_HUE_STEP = "hueStep";
final String SERIAL_BASE_HUE = "baseHue";
final String SERIAL_DESAT = "desaturation";
final String SERIAL_BRIGHT_CURVE = "brightnessCurve";
final String SERIAL_SAT_CURVE = "saturationCurve";
final String SERIAL_START_Y = "startY";
final String SERIAL_MIDDLE_X = "middleX";
final String SERIAL_MIDDLE_Y = "middleY";
final String SERIAL_END_Y = "endY";


public class SaveButton extends Button {
  SaveButton(PVector origin, float textHeight) {
    super(origin, textHeight, "Save...");
  }
  
  void buttonAction() {
    selectOutput("Select a destination:", "fileChosen", new File("myPalette.json"), this);
  }
  
  public void fileChosen(File selectedFile) {
    if (selectedFile == null) {
      return;
    }
    
    JSONObject json = new JSONObject();
    json.setInt(SERIAL_RAMP_COUNT, getRampCount());
    json.setInt(SERIAL_RAMP_SIZE, getRampSize());
    json.setInt(SERIAL_HUE_STEP, getHueStep());
    json.setFloat(SERIAL_DESAT, desatSlider.getValue());
    json.setInt(SERIAL_BASE_HUE, (int)pickerSlider.getValue());
    json.setJSONObject(SERIAL_BRIGHT_CURVE, serializeCurve(graph.brightCurve));
    json.setJSONObject(SERIAL_SAT_CURVE, serializeCurve(graph.satCurve));
    saveJSONObject(json, selectedFile.getAbsolutePath(), "indent=2");
  }
  
  private JSONObject serializeCurve(Curve curve) {
    JSONObject json = new JSONObject();
    json.setFloat(SERIAL_START_Y, curve.getStartValue());
    PVector middleValue = curve.getMiddleValue();
    json.setFloat(SERIAL_MIDDLE_X, middleValue.x);
    json.setFloat(SERIAL_MIDDLE_Y, middleValue.y);
    json.setFloat(SERIAL_END_Y, curve.getEndValue());
    return json;
  }
}

public class LoadButton extends Button {
  LoadButton(PVector origin, float textHeight) {
    super(origin, textHeight, "Load...");
  }
  
  void buttonAction() {
    selectInput("Select the configuration file:", "fileChosen", new File("myPalette.json"), this);
  }
  
  public void fileChosen(File selectedFile) {
    if (selectedFile == null) {
      return;
    }
    
    if (!selectedFile.exists()) {
      return;
    }
    
    JSONObject json = loadJSONObject(selectedFile.getAbsolutePath());
    int rampCount = json.getInt(SERIAL_RAMP_COUNT);
    int rampCountIndex = -1;
    for (int i = 0; i < rampCountAllowedValues.length; i++) {
      if (rampCountAllowedValues[i] == rampCount) {
        rampCountIndex = i + 1;
        break;
      }
    }
    assert(rampCountIndex >= 0);
    rampCountSlider.setValue(rampCountIndex);
    
    int rampSize = json.getInt(SERIAL_RAMP_SIZE);
    assert(rampSize % 2 == 1);
    assert(rampSize > 0);
    int actualRampSize = rampSize / 2;
    assert(actualRampSize >= MIN_RAMP_SIZE);
    assert(actualRampSize <= MAX_RAMP_SIZE);
    rampSizeSlider.setValue(actualRampSize);
    
    int hueStep = json.getInt(SERIAL_HUE_STEP);
    assert(hueStep >= MIN_HUE_STEP);
    assert(hueStep <= MAX_HUE_STEP);
    hueStepSlider.setValue(hueStep);
    
    float desat = json.getFloat(SERIAL_DESAT);
    assert(desat >= MIN_DESAT);
    assert(desat <= MAX_DESAT);
    desatSlider.setValue(desat);
    
    int baseHue = json.getInt(SERIAL_BASE_HUE);
    assert(baseHue >= 0);
    assert(baseHue <= 255);
    pickerSlider.setValue(baseHue);
    
    deserializeCurve(json.getJSONObject(SERIAL_BRIGHT_CURVE), graph.brightCurve);
    deserializeCurve(json.getJSONObject(SERIAL_SAT_CURVE), graph.satCurve);
    
    rebuildSwatches();
  }
  
  void deserializeCurve(JSONObject json, Curve curve) {
    float startY = json.getFloat(SERIAL_START_Y);
    assert(startY >= 0);
    assert(startY <= 1);
    curve.setStartValue(startY);
    
    float middleX = json.getFloat(SERIAL_MIDDLE_X);
    assert(middleX >= 0);
    assert(middleX <= 1);
    float middleY = json.getFloat(SERIAL_MIDDLE_Y);
    assert(middleY >= 0);
    assert(middleY <= 1);
    curve.setMiddleValue(middleX, middleY);
    
    float endY = json.getFloat(SERIAL_END_Y);
    assert(endY >= 0);
    assert(endY <= 1);
    curve.setEndValue(endY);
  }
}

public class ExportButton extends Button {
  ExportButton(PVector origin, float textHeight) {
    super(origin, textHeight, "Export as .pal");
  }
  
  void buttonAction() {
    selectOutput("Select a destination:", "fileChosen", new File("myPalette.pal"), this);
  }
  
  public void fileChosen(File chosenFile) {
    if (chosenFile == null) {
      return;
    }
    
    int rampLength = rampColors[0].length + desatRampColors[0].length;
    int rampCount = rampColors.length + 1;
    int colorCount = rampLength * rampCount;
    
    PrintWriter output = createWriter(chosenFile.getAbsolutePath());
    output.println("JASC-PAL");
    output.println("0100");
    output.println(colorCount);
    
    // Grayscale ramp. Both first and second are black, because the first is always reserved
    // for a transparency color.
    output.println("0 0 0");
    float grayscaleStep = 255.0 / ((float)rampLength - 2);
    for (int i = 0; i < rampLength - 1; i++) {
      int current = round(i * grayscaleStep);
      current = min(current, 255);
      output.println(current + " " + current + " " + current); 
    }
    
    // Iterate through each ramp.
    for (int i = 0; i < rampColors.length; i++) {
      for (int j = 0; j < rampColors[0].length; j++) {
        color current = rampColors[i][j];
        int r = (int)red(current);
        int g = (int)green(current);
        int b = (int)blue(current);
        output.println(r + " " + g + " " + b);
      }
      
      for (int j = 0; j < desatRampColors[0].length; j++) {
        color current = desatRampColors[i][j];
        int r = (int)red(current);
        int g = (int)green(current);
        int b = (int)blue(current);
        output.println(r + " " + g + " " + b);
      }
    }
    
    output.flush();
    output.close();
  }
}
