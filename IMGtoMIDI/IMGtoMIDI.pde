import controlP5.*;
import themidibus.*;
import blobDetection.*;

BlobDetection theBlobDetection;
ControlP5 cp5;
ScrollableList dropdown;
MidiBus myBus;
Slider delayValue;
Button startButton;
Button stopButton;
RadioButton radioButton;
CheckBox checkbox;

PImage img;
String[] midiDevices; // Array to store the MIDI devices
color[] spiralColors; // Array to store all colors that were probed by spiral approach
int[] allBlobs; // Array to store all blob coordinates

boolean start = false; // Boolean flag to indicate start
boolean sending = false; // Boolean flag to indicate sending a MIDI note

int delayV = 200;
int startMillis;
int amountOfBlobs;
int currentPitch;
int isSending = 0;

boolean spiral = false;
boolean blobby = false;

boolean sendChords = false; // Boolean flag if some basic chords are sent instead of single notes



void setup() {
  size(1000, 500);
  background(150);
  selectInput("Select an image file:", "fileSelected");
  
  // limit framerate
  frameRate(30);


  
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
  dropdown = cp5.addScrollableList("dropdown")
     .setPosition(550, 250)
     .setSize(300, 300)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(midiDevices)
     .setType(ScrollableList.DROPDOWN)
     .setLabel("Select MIDI device")
     .setOpen(false)                      //false for closed
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
                .setPosition(750, 50)
                .setSize(100, 50)
                .onClick(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    start = false; // Set the flag to true when button is pressed
                    println("stopped");
                    
                    MIDIPanic();
                    
                    
                  }
                });
                
                textSize(18);
                
                
                  // Hint for setup order              
  text("Select algorithm", 550, 410); 
                
                
       // create radio button
       radioButton = cp5.addRadioButton("radioButton")
                   .setPosition(550, 420)
                   .setSize(20, 20)
                   .setItemsPerRow(1)
                   .setSpacingColumn(50)
                   .addItem("Record Player", 0)
                   .addItem("Blob Detection", 1);
     
                
                
  // Hint for setup order              
  text("Important: Choose MIDI device first", 550, 240); 
  
  
   // Create a slider
  delayValue = cp5.addSlider("delayValue")
                .setPosition(550, 150)
                .setSize(300, 50)
                .setRange(100, 3000)
                .setValue(500)
                .setSliderMode(Slider.FLEXIBLE)
                .setLabel("Delay between notes")
                .onChange(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    float value = theEvent.getController().getValue();
                    delayV = (int)value;
                  }
                });
     
     stroke(255);
     line(700, 395, 700, 465);
                
                
      // Hint for setup order              
  text("Send single notes or chords?", 720, 410);             
                
  // Create a checkbox if chords should be generated
    checkbox = cp5.addCheckBox("checkbox")
                .setPosition(720, 420)
                .setSize(20, 20)
                .addItem("Send chords", 0);
              
}
  
  
void draw() {
  
    // Display the image    
      if (img != null) {
    image(img, 0, 0, 500, 500);
    }
    

  if (start) {
    
      
    // color centerColor = int(red(get(img.width/2, img.height/2)));    
    // sendMIDI(centerColor);
    
    
    //todo: blobby needs to be rewritten!
    if (blobby) {
    // int mod = (int)random(allBlobs.length); // alternative to modulo
    int mod = frameCount % allBlobs.length;
    //println("amount of detected blobs: "+blobby().length);
    //println("modulo: "+mod);
    sendMIDI(allBlobs[mod]);
    }
    
    if (spiral) {
    int mod2 = frameCount % spiralColors.length;
    sendMIDI(int(map(red(spiralColors[mod2]), 0, 255, 30, 80)));
    }

    // println("Frame: "+frameCount);
    
    }

}

void fileSelected(File selection) {
    img = loadImage(selection.getAbsolutePath());
    

    
    
       
  }

void sendMIDI(int pitch) {
         
  int channel = 1;
  int velocity = 127;

    
  if (sending == false) {
    
  myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
  if (sendChords) {
    myBus.sendNoteOn(channel, pitch+4, velocity); // Send a Midi noteOn
    myBus.sendNoteOn(channel, pitch+7, velocity); // Send a Midi noteOn
  }
  println("sending MIDI noteON:  "+pitch);
  println();

  currentPitch = pitch;
  sending = true;
  
  } else {
    
    // I do not really understand the next if-function
    // I wrote this piece of code too late at night
    // It can be changed to pitch == currentPitch -> less sent notes (maybe avoids duplicates?)
    // and pitch != currentPitch -> more sent notes (including duplicates)
  if (pitch != currentPitch) {
    
    // ensure that the MIDI noteOff command is sent only once
    if (isSending < 1) {
      myBus.sendNoteOff(channel, currentPitch, velocity); // Send a Midi noteOff
      if (sendChords) {
        myBus.sendNoteOff(channel, pitch+4, velocity); // Send a Midi noteOff
        myBus.sendNoteOff(channel, pitch+7, velocity); // Send a Midi noteOff
      }
      isSending ++;
      println("sending MIDI noteOff: "+currentPitch);
      println();
      }
  
    // ensure that next noteOn will only be sent after delayV  
    if (millis() - startMillis >= delayV) {
      println("---");
      sending = false;
      startMillis = millis();
      isSending = 0;
      }
    }
  }      
}  

// Function to probe the image via blob detection
 
int[] blobby() {
  
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(false);
  theBlobDetection.setThreshold(0.8f);
  theBlobDetection.computeBlobs(img.pixels);
  // println(theBlobDetection.getBlobNb()); // amount of blobs
  // println(theBlobDetection.getBlob(1).getEdgeVertexB(1));
  // println(theBlobDetection.getBlob(1).getEdgeNb());
  // println(theBlobDetection.getBlob(1).x); // between 0 and 1
  // println(theBlobDetection.getBlob(1).y); // between 0 and 1
  
  // initilialize an array with the length of the amount of all blobs
  int[] allBlobs = new int[theBlobDetection.getBlobNb()];
  
  // write the x coordinates of all blobs into array
  // and map them to MIDI command values in int
  for (int m = 0; m < allBlobs.length; m++) {
   
    allBlobs[m] = int(map(theBlobDetection.getBlob(m).x, 0, 1, 30, 80));
   
    
  }

  println(allBlobs);
  return allBlobs;
}


// Function for spiral/record play approach
// probes the image in a spiral manner

int[] spiral() {

  translate(img.width / 2, img.height / 2); // Move the origin to the center of the image
  float angle = 0;
  float radius = 0;
  float angleIncrement = 0.1;
  float radiusIncrement = 0.5;
  
  int numPoints = 1000; // Number of points in the spiral
  spiralColors = new color[numPoints]; // Array to store color values
  
  for (int i = 0; i < numPoints; i++) { // Loop to probe the spiral
    float x = radius * cos(angle);
    float y = radius * sin(angle);
    int imgX = int(img.width / 2 + x);
    int imgY = int(img.height / 2 + y);
    
    // Ensure the coordinates are within image bounds
    if (imgX >= 0 && imgX < img.width && imgY >= 0 && imgY < img.height) {
      
      // Ensure the coordinates are within a circle with radius = img.width/2
      // in order to prevent detecting coordinates in the corners
      // (will be black or white in WLM)
      if ((pow(imgX - img.width/2, 2) + pow(imgY - img.height/2, 2)) < pow((img.width/2), 2)) {
        
        spiralColors[i] = img.get(imgX, imgY); // Get the color from the image
        
      } 
    } 
    
    angle += angleIncrement; // Increment the angle
    radius += radiusIncrement; // Increment the radius
  }
  

  return spiralColors;



}

// Radio button and checkbox control

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(radioButton)) {
    int selected = int(theEvent.getValue());
    if (selected == 0) {
      spiral();
      spiral = true;
      blobby = false;
    } else if (selected == 1) {
      blobby = true;
      spiral = false;
      blobby();
    }
  }
  
    if (theEvent.isFrom(checkbox)) {
    if (checkbox.getItem(0).getState() == true) {
      println("Chord mode activated");
      sendChords = true;
      } 
    if (checkbox.getItem(0).getState() == false) {
      println("Chord mode deactivated");
      sendChords = false;
      MIDIPanic(); // ensure that all notes are off
      } 
 
  }
}
 

void MIDIPanic() {

    // hacky "MIDI panic" command (sends a noteOff to all pitches in channel 1
  for (int j=1; j<127; j++) 
  {
  myBus.sendNoteOff(1, j, 127); // Send a Midi nodeOff
  println("sending MIDI panicOff to: "+j);
  }

}

  
