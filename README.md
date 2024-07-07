# IMGtoMIDI

Objective: Converting a static image to MIDI signals using blob detection and other methods. Autodetecting suitable MIDI interfaces/devices on the target system and providing a simple GUI.

## current status
Prototype is working but a lot of features are highly work in progress. 

## used libraries
- the midibus (for detecting MIDI devices and sending MIDI signals/messages)
- cp5 (for GUI)
- theBlobDetection (for blob detection)

## Todos
- [x] Using modulo and framecount for cycling through main array
- [x] Get rid of `delay()` between `noteOn` and `NoteOff` by using `millis()`
- [ ] Threading (using `threads()` seems to mess up the timing)
- [ ] Better way to send `NoteOff` (depending on the frame rate it is sent more than once)
- [ ] More harmonic alterations of the notes
- [ ] Include text field in GUI with current status 
 
