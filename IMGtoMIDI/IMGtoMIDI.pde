import controlP5.*;
import themidibus.*;

ControlP5 cp5;
ScrollableList dropdown;
MidiBus myBus;
Slider delayValue;
int delayV = 200;

PImage img;
String[] midiDevices; // Array to store the MIDI devices

Button startButton;
boolean start = false; // Boolean flag to indicate start

boolean sending = false; // Boolean flag to indicate sending a MIDI note

int startMillis;

Button stopButton;

void setup() {
  size(1000, 800);
  background(150);
  selectInput("Select an image file:", "fileSelected");


  

  
  MidiBus.list();
  
  startMillis = millis();
  
  
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
        String selectedMIDIDevice = dropdown.getItem(index).get("name").toString();
        myBus = new MidiBus(this, 1, selectedMIDIDevice); 
        println(selectedMIDIDevice);
        
        

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
                    
                    // hacky "MIDI panic" command (sends a noteOff to all pitches in channel 1
                    for (int j=1; j<127; j++) 
                    {
                    myBus.sendNoteOff(1, j, 127); // Send a Midi nodeOff
                    println("sending MIDI panicOff to: "+j);
                    }
                    
                    
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
  
  frameRate(10);
  
  
    if (start) {
    //thread("colorreader");
    sendMIDI(70);
    


  }
  

  
  
}

void fileSelected(File selection) {
    img = loadImage(selection.getAbsolutePath());
  }

void sendMIDI(int pitch) {



         
  int channel = 1;
  // int pitch = int(map(matrixColor[i], 0, 255, 20, 120));
  int velocity = 127;
  


    
  if (sending == false) {
    
  myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
  println("sending MIDI noteON:  "+pitch);
  println();


  sending = true;

  
  } else {
    
  myBus.sendNoteOff(channel, pitch, velocity); // Send a Midi nodeOff
  println("sending MIDI noteOff: "+pitch);
  println();
  
    if (millis() - startMillis >= 2000) {
      println("in if");
  sending = false;
  startMillis = millis();
  }

  }
      
     }  
  
 

 



  
