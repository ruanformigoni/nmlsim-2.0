SpriteCenter sprites;
Header h;
SimulationPanel sp;
PhasePanel pp;
Scrollbar sb;
//ListContainer lc;

PApplet ref;

float fontSz = 15;

void setup(){
    size(1280, 720);
    sprites = new SpriteCenter();
    h = new Header(0, 0, 1280);
    sp = new SimulationPanel(400, 200, 300, 500);
    pp = new PhasePanel(0, 200, 300, 500, sp);
    sb = new Scrollbar(1200,200,20,300,10,2,true);
    ref = this;
    //lc = new ListContainer("All Phases", 10, 400, 280, 100);
    //lc.deleteEnabled = true;
    //lc.editEnabled = true;
    //lc.addItem("Switch");
    //lc.addItem("Reset");
    //lc.addItem("Relax");
    //lc.addItem("Hold");
}

void draw(){
    //background(45,80,22);
    background(200,200,200);
    h.drawSelf();
    sp.drawSelf();
    pp.drawSelf();
    //sb.drawSelf();
    pp.onMouseOverMethod();
    //lc.drawSelf();
    //textSize(fontSz+5);
    //println(textAscent()+textDescent());
}

void mousePressed(){
    h.mousePressedMethod();
    sp.mousePressedMethod();
    pp.mousePressedMethod();
    sb.mousePressedMethod();
    //lc.mousePressedMethod();
}

void keyPressed(){
    pp.keyPressedMethod();
    sp.keyPressedMethod();
}

void mouseWheel(MouseEvent e){
    float v = e.getCount();
    sb.mouseWheelMethod(v);
    pp.mouseWheelMethod(v);
    //lc.mouseWheelMethod(v);
}

void mouseDragged(){
    sb.mouseDraggedMethod();
    pp.mouseDraggedMethod();
    //lc.mouseDraggedMethod();
}
