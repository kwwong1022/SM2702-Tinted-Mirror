import processing.video.*;

int mode, prev;
boolean showGrid;
PImage img;
Capture video;
PGraphics screen, grid;
ArrayList<Pixel> pixels = new ArrayList<Pixel>();
ArrayList<PImage> saves = new ArrayList<PImage>();

public void setup() {
  noStroke();
  size(640, 480);
  
  mode = 0;
  String[] devices = Capture.list();
  screen = createGraphics(width, height);
  video = new Capture(this, devices[0]);
  video.start();
  
  for (int y=0; y<height; y++) {
    for (int x=0; x<width; x++) {
      pixels.add(new Pixel(x, y));
    }
  }
  
  prev = 0;
  showGrid = false;
  grid = createGraphics(width, height);
}
    
public void draw() {
  screen.beginDraw();
  screen.image(video, 0, 0);
  screen.endDraw();
  img = screen;
  
  int count = 0;

  for (int y=0; y<height; y++) {
    for (int x=0; x<width; x++) {
      int c = img.get(x, y);
      
      colorMode(HSB);
      int h = (int) hue(c);
      int s = (int) saturation(c);
      int v = (int) brightness(c);
      pixels.get(count).setH(h);
      pixels.get(count).setS(s);
      pixels.get(count).setV(v);
      
      colorMode(RGB);
      int r = (int) red(c);
      int g = (int) green(c);
      int b = (int) blue(c);
      pixels.get(count).setR(r);
      pixels.get(count).setG(g);
      pixels.get(count).setB(b);

      count++;
    }
  }
  
  img.loadPixels();
  
  for (int i=0; i<img.pixels.length; i++) {
    color c = img.pixels[i];
    float val = sin(frameCount*0.01f)*300;
    
    switch (mode) {
      case 0:
        colorMode(RGB);
        img.pixels[i] = color(val, green(c), blue(c));
        
        if (val < 100) {
          mode++;
        }
        break;
        
      case 1:
        colorMode(RGB);
        img.pixels[i] = color(red(c), val, blue(c));
        
        if (val >= 100 && val <= 200) {
          mode++;
        }
        break;
        
      case 2:
        colorMode(RGB);
        img.pixels[i] = color(red(c), green(c), val);
        
        if (val > 200) {
          mode = 0;
        }
        break;
    } 
  }
  
  img.updatePixels();
  img.loadPixels();
  
  for (int i=0; i<img.pixels.length; i++) {
    color c = img.pixels[i];
    
    colorMode(HSB);
    img.pixels[i] = color(hue(c), saturation(c)+map(sin(frameCount*0.001f), 0, 1, -20, 20), brightness(c));
  }
  
  img.updatePixels();
  image(img, 0, 0);

  for (int i=0; i<pixels.size(); i++) {
    float area = map(dist(mouseX, mouseY, pixels.get(i).getX(), pixels.get(i).getY()), 0, 450, -400, 200);
    
    if (mousePressed && dist(mouseX, mouseY, pixels.get(i).getX(), pixels.get(i).getY())<350) {
      colorMode(RGB);
      fill(pixels.get(i).getR(), pixels.get(i).getG(), pixels.get(i).getB(), area);
    
    } else {
      colorMode(HSB);
      fill(pixels.get(i).getH(), 0, pixels.get(i).getV());
    }

    rect(pixels.get(i).getX(), pixels.get(i).getY(), 1, 1);
  }
  
  if (millis() - prev > 9000 && mousePressed) {
    if (showGrid) {
      for (int i=24; i>=0; i--) {
        println(saves.size());
        saves.remove(i);
      }
      showGrid = false;
      
      println("photo array is cleared: ");
      }
    
    if (saves.size() < 25) {
      saves.add(copy());
      
      if (saves.size() == 25) {
        int i = 0;
        int w = width/5;
        int h = height/5;
        
        for (int y=0; y<5; y++) {
          for (int x=0; x<5; x++) {
            grid.beginDraw();
            grid.image(saves.get(i), x*w, y*h, w, h);
            grid.endDraw();
            i++;
          }
        }
        
        showGrid = true;
      }
      println("screenshot saved, current photos in array: " + saves.size());
      
    } else {
      println("photo array is full");
    }
    
    prev = millis();
    println("prev updated");
  }
  
  if (showGrid) { 
    image(grid, 0, 0);
  }
}

public void captureEvent(Capture video) {
  video.read();
  img = screen;
}
