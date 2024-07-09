PImage img;
color[] spiralColors;

void setup() {
  size(600, 600); // Set the size of the window
  img = loadImage("background2.jpg"); // Load the image
  image(img, 0, 0, width, height); // Display the image

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
  
  // Print the first 10 color values for verification
  for (int i = 0; i < 1000; i++) {
    println(red(spiralColors[i]));
  }
}

void draw() {
  // Nothing to do in draw() for this example
}
