import processing.video.*;

int mode;
PImage img, testImg;
Capture video;
PGraphics screen;
ArrayList<Pixel> pixels = new ArrayList<Pixel>();

public void setup() {
  mode = 0;
  
  testImg = loadImage("fg.png");
  
  size(640, 480);
  
  String[] devices = Capture.list();

  noStroke();
  
  video = new Capture(this, devices[0]);
  video.start();
  
  screen = createGraphics(width, height);
  
  for (int y=0; y<height; y++) {
    for (int x=0; x<width; x++) {
      pixels.add(new Pixel(x, y));
    }
  }
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
    img.pixels[i] = color(hue(c), saturation(c), brightness(c));
  }
  img.updatePixels();
  
  
  image(img, 0, 0);

  for (int i=0; i<pixels.size(); i++) {
    if (mousePressed && dist(mouseX, mouseY, pixels.get(i).getX(), pixels.get(i).getY())<400) {
      colorMode(RGB);
      fill(pixels.get(i).getR(), pixels.get(i).getG(), pixels.get(i).getB(), map(dist(mouseX, mouseY, pixels.get(i).getX(), pixels.get(i).getY()), 0, 400, -200, 200));
    } else {
      colorMode(HSB);
      fill(pixels.get(i).getH(), 0, pixels.get(i).getV());
    }

    rect(pixels.get(i).getX(), pixels.get(i).getY(), 1, 1);
  }
}

public void captureEvent(Capture video) {
  video.read();
  img = screen;
}
