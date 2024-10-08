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
String selectedMIDIDevice;

boolean start = false; // Boolean flag to indicate start
boolean sending = false; // Boolean flag to indicate sending a MIDI note

int delayV = 200;
int startMillis;
int amountOfBlobs;
int currentPitch;
int isSending = 0;
int highestMIDInote = 80; // values for mapping function
int lowestMIDInote = 25; // values for mapping function
int midiChannel = 1; // selected MIDI channel, defaults to 1

boolean spiral = false;
boolean blobby = false;

boolean sendChords = false; // Boolean flag if some basic chords are sent instead of single notes
boolean enforceHarmonic = false; // Boolean flag if the color values should be mapped to harmonic chords only

String txtMessage = "";


void setup() {
  size(1500, 500);
  background(200);
  
  
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
                

  text("Select image", 550+450, 30); 
  
                   // Create a load image button
  startButton = cp5.addButton("loadImage")
                .setLabel("LOAD IMAGE")
                .setPosition(550+450, 40)
                .setSize(100, 50)
                .onClick(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    
                    
                    start = false;
                    
                      selectInput("Select an image file:", "fileSelected");

                    
                  
                    updateTxtMsg("Image loaded");
                  }
                });


     stroke(255);
  line(550+450, 100, 960+450, 100);
                
              
  text("Select algorithm", 550+450, 190-50); 
                
                
       // create radio button
       radioButton = cp5.addRadioButton("radioButton")
                   .setPosition(550+450, 200-50)
                   .setSize(20, 20)
                   .setItemsPerRow(1)
                   .setSpacingColumn(50)
                   .addItem("Record Player", 0)
                   .addItem("Blob Detection", 1)
                   .setColorLabel(color(0));

                
                
   
     line(700+450, 175-50, 700+450, 240-50);
                
                
            
  text("Send single notes or chords?", 720+450, 190-50);             
                
  // Create a checkbox if chords should be generated
    checkbox = cp5.addCheckBox("checkbox")
                .setPosition(720+450, 200-50)
                .setSize(20, 20)
                .addItem("Send chords", 0)
                .setColorLabel(color(0));          

                
  // Create a checkbox if harmonic should be enforced
    checkbox2 = cp5.addCheckBox("checkbox2")
              .setPosition(720+450, 221-50)
              .setSize(20, 20)
              .addItem("Enforce harmonics", 0)
              .setColorLabel(color(0));
     
                
    line(550+450, 260-50, 960+450, 260-50);          
  
   // Create a slider
  delayValue = cp5.addSlider("delayValue")
                .setPosition(550+450, 275-50)
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
                .setPosition(550+450, 305-50)
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
                .setPosition(550+450, 335-50)
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
     

line(550+450, 380-55, 960+450, 380-55);

  // Create a text field for MIDI channel input
  cp5.addTextfield("MIDI channel")
     .setPosition(550+450, 340)
     .setSize(60, 30)
     .setAutoClear(false)
     .setColorLabel(color(0))
     .setColorBackground(color(230))  // Set light grey color
     .setColor(color(0))  // Set text color to black
     ;
     
       // Create a button to confirm MIDI channel input
  cp5.addButton("submitMIDI")
     .setLabel("Submit")
     .setPosition(1075, 340)
     .setSize(60, 30);
     
     
     

     
line(550+450, 390, 960+450, 390);


                 // Create a start button
  startButton = cp5.addButton("startButton")
                .setLabel("START")
                .setPosition(550+450, 400)
                .setSize(100, 50)
                .onClick(new CallbackListener() {
                  public void controlEvent(CallbackEvent theEvent) {
                    
                    
                    if (img != null){
                    
                      // check if a device was selected
                      if (selectedMIDIDevice != null) {
                        start = true; // Set the flag to true when button is pressed
                        updateTxtMsg("MIDI started");
                       } else {
                        updateTxtMsg("ERROR: no MIDI device");
                        }
                    } else {
                      updateTxtMsg("ERROR: no image selected");
                    }
                  }
                });
                
                
  // Create a stop button
  stopButton = cp5.addButton("stopButton")
                .setLabel("STOP")
                .setPosition(670+450, 400)
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
  
  // check if MIDI Bus was successfully selected
  if (myBus != null) {
         
  int channel = midiChannel;
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
    updateTxtMsg("Sending root note: " + str(pitch));
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

  //translate(img.width / 2, img.height / 2); // Move the origin to the center of the image
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
      // (will be black or white or transparent in WLM)
      if ((pow(imgX - img.width/2, 2) + pow(imgY - img.height/2, 2)) < pow((img.width/2), 2)) {
        
        spiralColors[i] = img.get(imgX, imgY); // Get the color from the image
        
      } 
    } 
    
    angle += angleIncrement; // Increment the angle
    radius += radiusIncrement; // Increment the radius
  }
  
  updateTxtMsg("Phono probing successful");
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
        selectedMIDIDevice = dropdown.getItem(index).get("name").toString();
        myBus = new MidiBus(this, 1, selectedMIDIDevice);
        updateTxtMsg("MIDI device selected");
        
  }
  
  
  if (theEvent.getName().equals("submitMIDI")) {
    String input = cp5.get(Textfield.class, "MIDI channel").getText();
    
    // Validate if the input is a number & if the number is between 0 and 11
    if (input.matches("\\d+") && int(input) <= 16 && int(input) > 0) {  
      midiChannel = Integer.parseInt(input);
        println("MIDI channel set to: " + midiChannel);
        updateTxtMsg("MIDI channel set to: " + midiChannel);
    } else {
        // Clear the field if input is not a number
        cp5.get(Textfield.class, "MIDI channel").setText("");
        updateTxtMsg("Invalid MIDI channel");
    }
  }
  
}
 

void MIDIPanic() {
  
  // check if start button was pressed before sending MIDI panic to avoid null pointer exception
  // when STOP is pressed before any MIDI devices were chosen
  if (start) {
    
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


}

void updateTxtMsg(String msg) {

    // Display the text feedback
    fill(200);
    rect(790+450, 401, 170, 47);
    textSize(12);
    fill (0);
    text(msg, 800+450, 420); 


}
  
