import controlP5.*;
import themidibus.*;

ControlP5 cp5;
DropdownList dropdown;
MidiBus myBus;
Slider delayValue;
int delayV = 0;

PImage img;
String[] midiDevices; // Array to store the MIDI devices

Button startButton;
boolean start = false; // Boolean flag to indicate start

Button stopButton;

void setup() {
  size(1000, 800);
  background(150);
  selectInput("Select an image file:", "fileSelected");
  
  MidiBus.list();
  String[] devices = MidiBus.availableOutputs();
  
  // Initialize the midiDevices array with the same length
  midiDevices = new String[devices.length];
  
  // Write the items into the array
  for (int i = 0; i < devices.length; i++) {
  midiDevices[i] = devices[i];
  }
  
  
  
    // Initialize ControlP5
  cp5 = new ControlP5(this);

// Create a dropdown list
  dropdown = cp5.addDropdownList("myDropdown")
                .setPosition(550, 300)
                .setSize(200, 200)
                .setItemHeight(40)
                .setBarHeight(20)
                .addItems(midiDevices);
  
  // Set a callback function to handle the dropdown list events
  dropdown.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
        int index = (int) theEvent.getController().getValue();
        println(dropdown.getItem(index).get("name"));
      }
    }
  });
  
  
    // Create a start button
  startButton = cp5.addButton("startButton")
                .setLabel("START")
                .setPosition(550, 50)
                .setSize(100, 50)
                .onClick(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    start = true; // Set the flag to true when button is pressed
                  }
                });
                
                
          // Create a stop button
  stopButton = cp5.addButton("stopButton")
                .setLabel("STOP")
                .setPosition(800, 50)
                .setSize(100, 50)
                .onClick(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    start = false; // Set the flag to true when button is pressed
                    println("stopped");
                  }
                });
  
  
    // Create a slider
  delayValue = cp5.addSlider("delayValue")
                .setPosition(50, 150)
                .setSize(300, 50)
                .setRange(1, 1000)
                .setValue(1)
                .setNumberOfTickMarks(100)
                .setSliderMode(Slider.FLEXIBLE)
                .setLabel("Value: 1")
                .onChange(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    float value = theEvent.getController().getValue();
                    delayV = (int)value;
                  }
                });
}
  
  

  






void draw() {
  if (img != null) {
    image(img, 0, 0, 500, 500);


  }
  
  
    if (start) {
    colorreader();

  }
  

  
  
}

void fileSelected(File selection) {
    img = loadImage(selection.getAbsolutePath());
  }

void colorreader() {

  
    // IMAGE COLOR READS
  
  color c2 = get(25, img.width/2);
  println("red"+red(c2));
    println(blue(c2));
      println(green(c2));
  
     delay(delayV);
    println("delay: "+delayV);
 
}


  
