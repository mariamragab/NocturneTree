import java.util.Date;
import java.text.SimpleDateFormat;
import oscP5.*;
import netP5.*;
Tree tree;
int currVal=0;
float newVal=0;
OscP5 oscP5;

void setup() {
  size(1280, 720, P2D);
  background(#333333);
  tree = new Tree();
  oscP5 = new OscP5(this,"224.0.1.3",7571);
}

void draw() {
  tree.draw();
}

void mousePressed() {
  background(#333333);
  tree = new Tree();
}

void keyPressed() {
  String timeStamp = new SimpleDateFormat("yyyyMMdd").format(new Date());
  String name = "tree_" + timeStamp + "_" + frameCount;
  save(name + ".png");
}

class Tree {
  ArrayList<Branch> branches = new ArrayList<Branch>();
  boolean growing=true;
  float newVal=0;
  float currVal=0;
  
  
  Tree() {
    // float quarterScreen = width / 4;
    // float randomHorizontalPosition = random(quarterScreen, width - quarterScreen);
    // PVector position = new PVector(randomHorizontalPosition, height);

    PVector position = new PVector(width / 2, height);
    double angle = -1.57;
    float thickness = 25;

    createBranch(position, angle, thickness);
  }

  void draw() {
    int i=0;
    checkGrowing();
    if (growing){
      updateBranch(branches.get(i));
      i++;
    }
    else{
     branches.remove(i);
     i--;
    }
     
     
  }
  void oscEvent(OscMessage theOscMessage) {
    println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
    newVal=theOscMessage.get(0).floatValue();
  }
  
  void checkGrowing(){
    if (currVal<=newVal){
      growing=true;
      currVal=newVal;
    }
    else
      growing=false;
  }
    
  void createBranch(PVector position, double angle, float thickness) {
    Branch branch = new Branch(position, angle, thickness);
    branches.add(branch);
  }

  void updateBranch(Branch branch) {
    branch.draw();

    boolean divaricate = Math.round(Math.random() * (branch.thickness / 2)) == 1;

    if (divaricate) {
      double angle = branch.angle + ((Math.random() - .5) * 2);
      float thickness = random(1, branch.thickness);
      createBranch(branch.position, angle, thickness);
    }

    if (branch.thickness < 7) {
      Leaf leaf = new Leaf(branch.position.get());
      leaf.draw();
    }

    if (branch.ended) {
      branches.remove(branch);
    }
  }
}

class Branch {
  boolean ended = false;

  PVector position;
  double angle;
  float thickness;
  
  Branch(PVector position, double angle, float thickness) {
    this.position = position;
    this.angle = angle;
    this.thickness = thickness;

    strokeCap(ROUND);
  }

  void draw() {
    thickness -= .3;

    if (thickness < 1) {
      ended = true;
    }

    strokeWeight(thickness);

    double length = (Math.random() * 8) + 4;
    angle += PI / 180 * ((Math.random() * 30) -15);

    PVector newPosition = position.get();
    newPosition.x += length * Math.cos(angle);
    newPosition.y += length * Math.sin(angle);

    noFill();
    stroke(#F5F5F5);
    line(position.x, position.y, newPosition.x, newPosition.y);

    position = newPosition;
  }
}

class Leaf {
  int[] colors = {#006bd5, #C00000, #00d5d5, #D50000, #d500d5, #00d500};

  PVector position;

  Leaf(PVector position) {
    this.position = position;
  }

  void draw() {
    int index = (int) random(0, colors.length);
    color leafColor = colors[index];
    float leafSize = (float) ((Math.random() * 30) + 2);

    position.x = (float) (-30 + position.x + Math.random() * 60);
    position.y = (float) (-30 + position.y + Math.random() * 60);

    fill(leafColor);
    noStroke();
    ellipse(position.x, position.y, leafSize, leafSize);
  }
}