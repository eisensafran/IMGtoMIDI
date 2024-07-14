import controlP5.*;
import themidibus.*;
import blobDetection.*;
import java.util.ArrayList;

BlobDetection theBlobDetection;
ControlP5 cp5;
ScrollableList dropdown;
MidiBus myBus;
Slider delayValue;
Slider minMIDI;
Slider maxMIDI;
Button startButton;
Button stopButton;
RadioButton radioButton;
CheckBox checkbox;
CheckBox checkbox2;

PImage img;
String[] midiDevices; // Array to store the MIDI devices
color[] spiralColors; // Array to store all colors that were probed by spiral approach
float[] allBlobs; // Array to store all blob coordinates
ArrayList<int[]> chords; // ArrayList to store all melodic chords

boolean start = false; // Boolean flag to indicate start
boolean sending = false; // Boolean flag to indicate sending a MIDI note

int delayV = 200;
int startMillis;
int amountOfBlobs;
int currentPitch;
int isSending = 0;
int highestMIDInote = 80; // values for mapping function
int lowestMIDInote = 25; // values for mapping function

boolean spiral = false;
boolean blobby = false;

boolean sendChords = false; // Boolean flag if some basic chords are sent instead of single notes
boolean enforceHarmonic = false; // Boolean flag if the color values should be mapped to harmonic chords only

String txtMessage = "";


void setup() {
  size(1000, 500);
  background(200);
  selectInput("Select an image file:", "fileSelected");
  
  // limit framerate
  frameRate(25);

  fill(0);


  
  updateTxtMsg("WARNING: no device selected");
  
  MidiBus.list();  
  startMillis = millis();
  
  
  String[] devices = MidiBus.availableOutputs();
  
  // Initialize the midiDevices array with the same length
  midiDevices = new String[devices.length];
  
  // Write the items into the array
  for (int i = 0; i < devices.length; i++) {
  midiDevices[i] = devices[i];
  }
  
  
// Initialize the chords ArrayList
chords = new ArrayList<int[]>();

// Add chords to the ArrayList
chords.add(new int[] {60, 64, 67}); // C major (C, E, G)
chords.add(new int[] {62, 65, 69}); // D minor (D, F, A)
chords.add(new int[] {64, 67, 71}); // E minor (E, G, B)
chords.add(new int[] {65, 69, 72}); // F major (F, A, C)
chords.add(new int[] {67, 71, 74}); // G major (G, B, D)
chords.add(new int[] {69, 72, 76}); // A minor (A, C, E)
chords.add(new int[] {71, 74, 77}); // B diminished (B, D, F)
chords.add(new int[] {60, 64, 67}); // Csus1 (C major)
chords.add(new int[] {62, 69, 74}); // Dsus2
chords.add(new int[] {65, 70, 74}); // Fsus2
chords.add(new int[] {67, 72, 76}); // Gsus2
chords.add(new int[] {69, 74, 78}); // Asus2
chords.add(new int[] {60, 65, 67}); // Csus4
chords.add(new int[] {62, 67, 74}); // Dsus4
chords.add(new int[] {64, 69, 76}); // Esus4
chords.add(new int[] {67, 72, 79}); // Gsus4
chords.add(new int[] {69, 74, 81}); // Asus4
chords.add(new int[] {60, 64, 67, 71}); // Cmaj7
chords.add(new int[] {62, 65, 69, 74}); // Dm7
chords.add(new int[] {64, 67, 71, 74}); // Em7
chords.add(new int[] {65, 69, 72, 76}); // Fmaj7
chords.add(new int[] {67, 71, 74, 77}); // G7
chords.add(new int[] {69, 72, 76, 79}); // Am7
  
  
// -------------------------------------------------
// ----------------- INTERFACE ---------------------
// -------------------------------------------------

// Initialize ControlP5
cp5 = new ControlP5(this);
  
// Hint for setup order    
textSize(18);
text("Important: Choose MIDI device first", 550, 30); 




  dropdown = cp5.addScrollableList("dropdown")
     .setPosition(550, 40)
     .setSize(400, 300)
                .setBarHeight(20)
                .setItemHeight(20)
                .addItems(midiDevices)
                .setOpen(false)
                .setLabel("Select MIDI device")
                ;
                




                
              
  text("Select algorithm", 550, 190); 
                
                
       // create radio button
       radioButton = cp5.addRadioButton("radioButton")
                   .setPosition(550, 200)
                   .setSize(20, 20)
                   .setItemsPerRow(1)
                   .setSpacingColumn(50)
                   .addItem("Record Player", 0)
                   .addItem("Blob Detection", 1)
                   .setColorLabel(color(0));

                
                
     stroke(255);
     line(700, 175, 700, 240);
                
                
            
  text("Send single notes or chords?", 720, 190);             
                
  // Create a checkbox if chords should be generated
    checkbox = cp5.addCheckBox("checkbox")
                .setPosition(720, 200)
                .setSize(20, 20)
                .addItem("Send chords", 0)
                .setColorLabel(color(0));          

                
  // Create a checkbox if harmonic should be enforced
    checkbox2 = cp5.addCheckBox("checkbox2")
              .setPosition(720, 221)
              .setSize(20, 20)
              .addItem("Enforce harmonics", 0)
              .setColorLabel(color(0));
     
                
    line(550, 260, 960, 260);          
  
   // Create a slider
  delayValue = cp5.addSlider("delayValue")
                .setPosition(550, 275)
                .setSize(300, 25)
                .setRange(100, 3000)
                .setValue(500)
                .setSliderMode(Slider.FLEXIBLE)
                .setLabel("Delay between notes")
                .setColorLabel(color(0))
                .onChange(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    float value = theEvent.getController().getValue();
                    delayV = (int)value;
                  }
                });
                
 
    // Create a slider
  minMIDI = cp5.addSlider("minMIDI")
                .setPosition(550, 305)
                .setSize(300, 25)
                .setRange(0, 50)
                .setValue(25)
                .setSliderMode(Slider.FLEXIBLE)
                .setLabel("Limit lowest note")
                .setColorLabel(color(0))
                .onChange(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    float value = theEvent.getController().getValue();
                    lowestMIDInote = (int)value;
                  }
                });
                
                    // Create a slider
  maxMIDI = cp5.addSlider("maxMIDI")
                .setPosition(550, 335)
                .setSize(300, 25)
                .setRange(60, 127)
                .setValue(80)
                .setSliderMode(Slider.FLEXIBLE)
                .setLabel("Limit highest note")
                .setColorLabel(color(0))
                .onChange(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    float value = theEvent.getController().getValue();
                    highestMIDInote = (int)value;
                  }
                });
     

line(550, 380, 960, 380);

                 // Create a start button
  startButton = cp5.addButton("startButton")
                .setLabel("START")
                .setPosition(550, 400)
                .setSize(100, 50)
                .onClick(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    

                    
                    start = true; // Set the flag to true when button is pressed
                    updateTxtMsg("MIDI started");
                  }
                });
                
                
  // Create a stop button
  stopButton = cp5.addButton("stopButton")
                .setLabel("STOP")
                .setPosition(670, 400)
                .setSize(100, 50)
                .onClick(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    start = false; // Set the flag to true when button is pressed
                    println("stopped");
                    updateTxtMsg("MIDI stopped");
                    
                    MIDIPanic();
                    
                    
                  }
                });
              
              
}
  
  
void draw() {
  
    // Display the image    
      if (img != null) {
    image(img, 0, 0, 500, 500);
    }
    

    

  if (start) {
    

      
    // color centerColor = int(red(get(img.width/2, img.height/2)));    
    // sendMIDI(centerColor);
    
    

    if (blobby) {
    // int mod = (int)random(allBlobs.length); // alternative to modulo
    int mod = frameCount % allBlobs.length;

    sendMIDI(int(map(allBlobs[mod], 0, 1, lowestMIDInote, highestMIDInote)));
    }
    
    if (spiral) {
    int mod2 = frameCount % spiralColors.length;
    sendMIDI(int(map(red(spiralColors[mod2]), 0, 255, lowestMIDInote, highestMIDInote)));
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
    
  
  if (sendChords) {
    myBus.sendNoteOn(channel, pitch+4, velocity); // Send a Midi noteOn
    myBus.sendNoteOn(channel, pitch+7, velocity); // Send a Midi noteOn
  }
  
  if (enforceHarmonic) {
      int[] chord = chords.get((int)map(pitch, lowestMIDInote, highestMIDInote, 0, chords.size()));
      // Play the chord
      for (int note : chord) {
        myBus.sendNoteOn(channel, note, velocity);
        }
  } else {
    myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
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
      
      if (sendChords) {
        myBus.sendNoteOff(channel, pitch+4, velocity); // Send a Midi noteOff
        myBus.sendNoteOff(channel, pitch+7, velocity); // Send a Midi noteOff
        }
      if (enforceHarmonic) {
       int[] chord = chords.get((int)map(pitch, lowestMIDInote, highestMIDInote, 0, (chords.size()-1)));
        // Play the chord
        for (int note : chord) {
        myBus.sendNoteOff(channel, note, velocity);
        }
      } else {
        myBus.sendNoteOff(channel, currentPitch, velocity); // Send a Midi noteOff
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
 
float[] blobby() {
  
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(false);
  theBlobDetection.setThreshold(0.7f);
  theBlobDetection.computeBlobs(img.pixels);
  
  // initilialize an array with the length of the amount of all blobs
  allBlobs = new float[theBlobDetection.getBlobNb()];

  
  // write the x coordinates of all blobs into array
  // and map them to MIDI command values in int
  for (int m = 0; m < allBlobs.length; m++) {
   
    allBlobs[m] = theBlobDetection.getBlob(m).x;
   
    
  }

  updateTxtMsg("Detected blobs: "+str(allBlobs.length));

 return(allBlobs);

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
  
  println(spiralColors);
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
      updateTxtMsg("Chord mode activated");
      } 
    if (checkbox.getItem(0).getState() == false) {
      println("Chord mode deactivated");
      sendChords = false;
      MIDIPanic(); // ensure that all notes are off
      updateTxtMsg("Chord mode deactivated");
      } 
    }

  if (theEvent.isFrom(checkbox2)) {
    if (checkbox2.getItem(0).getState() == true) {
      println("Harmonic mode activated");
      
      // attempt to enforce that the external synthesizer is set to polyphonic mode
      // (does not work with Arturia Microfreak at the moment, therefore commented out)
      // myBus.sendControllerChange(1, 127, 0);
      
      enforceHarmonic = true;
      updateTxtMsg("Harmonic mode activated");
      } 
    if (checkbox2.getItem(0).getState() == false) {
      println("Harmonic mode deactivated");
      enforceHarmonic = false;
      updateTxtMsg("Harmonic mode deactivated");
      MIDIPanic(); // ensure that all notes are off
      } 
  }
  
    if (theEvent.isFrom(dropdown)) {
    int selectedOption = int(theEvent.getValue());
    println(selectedOption);
    
      int index = (int) theEvent.getController().getValue();
        println(dropdown.getItem(index).get("name"));
        String selectedMIDIDevice = dropdown.getItem(index).get("name").toString();
        myBus = new MidiBus(this, 1, selectedMIDIDevice); 
        
  }
  
}
 

void MIDIPanic() {
  
  // "correct" MIDI panic signal 
  // sometimes still produces some mistakes
  myBus.sendControllerChange(1, 120, 0);
  updateTxtMsg("ALL NOTES OFF");
  
  // hacky "MIDI panic" command (sends a noteOff to all pitches in channel 1)
  // to REALLY enforce that there are no "hanging" MIDI notes in the synthesizer
  for (int j=1; j<127; j++) {
    myBus.sendNoteOff(1, j, 127); // Send a Midi nodeOff
    println("sending MIDI panicOff to: "+j);
    }
  


}

void updateTxtMsg(String msg) {

    // Display the text feedback
    fill(200);
    rect(790, 401, 170, 47);
    textSize(12);
    fill (0);
    text(msg, 800, 420); 


}
  
