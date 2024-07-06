import controlP5.*;
import themidibus.*;

ControlP5 cp5;
ScrollableList dropdown;
MidiBus myBus;
Slider delayValue;
int delayV = 0;

PImage img;
String[] midiDevices; // Array to store the MIDI devices

Button startButton;
boolean start = false; // Boolean flag to indicate start

String selectedMIDIDevice;

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
  dropdown = cp5.addScrollableList("choose MIDI device")
     .setPosition(550, 250)
     .setSize(200, 200)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(midiDevices)
     .setType(ScrollableList.DROPDOWN)
     .setOpen(true)                      //false for closed
     ;
  // Set a callback function to handle the dropdown list events
  dropdown.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
              
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
        int index = (int) theEvent.getController().getValue();
        println(dropdown.getItem(index).get("name"));
        selectedMIDIDevice = dropdown.getItem(index).get("name").toString();
        println(selectedMIDIDevice);
        myBus = new MidiBus(this, selectedMIDIDevice, selectedMIDIDevice);
        

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
                .setPosition(550, 150)
                .setSize(300, 50)
                .setRange(1, 1000)
                .setValue(1)
                .setNumberOfTickMarks(100)
                .setSliderMode(Slider.FLEXIBLE)
                .setLabel("Delay between notes")
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

  
    // Read color from center of image
  
  color centerColor = get(img.width/2, img.height/2);
  println("red "+red(centerColor));

      
      // Read color from 9 points (matrix approach)
      
      int[] matrixColor = new int[9];
      matrixColor[0] = int(red(get(img.width/4, img.height/4)));
      matrixColor[1] = int(red(get(img.width/2, img.height/4)));
      matrixColor[2] = int(red(get(3*img.width/4, img.height/4)));
      matrixColor[3] = int(red(get(img.width/4, img.height/2)));
      matrixColor[4] = int(red(get(img.width/2, img.height/2)));
      matrixColor[5] = int(red(get(3*img.width/4, img.height/2)));
      matrixColor[6] = int(red(get(img.width/4, 3*img.height/4)));
      matrixColor[7] = int(red(get(img.width/2, 3*img.height/4)));
      matrixColor[8] = int(red(get(3*img.width/4, 3*img.height/4)));
     
     println(matrixColor);
      
     
     for(int i=0; i<matrixColor.length; i++){
         
       
       
       }

      
      
      
  
     delay(delayV);
    println("delay: "+delayV);
 
}


  
class colortoMIDI {
  
  int colorValue;
  float normalizedColorValue = map(colorValue, 0, 255, 0, 127);

}
