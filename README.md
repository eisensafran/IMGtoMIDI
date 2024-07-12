# IMGtoMIDI

Objective: Converting a static image to MIDI signals using blob detection and other methods. Autodetecting suitable MIDI interfaces/devices on the target system and providing a simple GUI. More info [here](https://andi-siess.de/image-to-music/). 

## current status
Prototype is working but a lot of features are highly work in progress. 

## used libraries
- the midibus (for detecting MIDI devices and sending MIDI signals/messages)
- cp5 (for GUI)
- theBlobDetection (for blob detection)

## todos
- [x] Using modulo and framecount for cycling through main array
- [x] Get rid of `delay()` between `noteOn` and `NoteOff` by using `millis()`
- [x] Implementing phonograph and blob detection as approaches to 'probe' the image
- [x] Include radio buttons to choose between these two approaches
- [x] Exclude the calculation of blobs and phonograph probe from `draw()`. These calculations are done now once the radio buttons are checked.
- [ ] Threading (using `threads()` seems to mess up the timing)
- [x] Better way to send `NoteOff` (depending on the frame rate it is sent more than once)
- [ ] More harmonic alterations of the notes
- [ ] Include text field in GUI with current status (or at least all console logs)
- [ ] Better way to sending MIDI panic message (`CC 120` or `CC 123`) than the for loop that is currently in place
- [x] Include option to include accords
 
## prerequisites
- loaded images need to have an aspect ratio of 1:1
- preferred image format is *.jpg