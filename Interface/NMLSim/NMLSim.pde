SpriteCenter sprites;
Header h;
//SimulationPanel sp;
//PhasePanel pp;
//Scrollbar sb;
//ListContainer lc;
PanelMenu pm;

float fontSz = 15;
float scaleFactor = 1;
//Chart c;

void setup(){
    //size(2560, 1440);
    size(1280, 720);
    sprites = new SpriteCenter();
    h = new Header(0, 0, 1280);
    //sp = new SimulationPanel(400, 200, 300, 500);
    //pp = new PhasePanel(0, 200, 300, 500, sp);
    //sb = new Scrollbar(1200,200,20,300,10,2,true);
    //lc = new ListContainer("All Phases", 10, 400, 280, 100);
    //lc.deleteEnabled = true;
    //lc.editEnabled = true;
    //lc.addItem("Switch");
    //lc.addItem("Reset");
    //lc.addItem("Relax");
    //lc.addItem("Hold");
    pm = new PanelMenu(0, 670, 300, 500);
    //c = new Chart(400, 200, 600, 400);
    //c.addSeires("Red",new float[][]{{0,-00},{5,100}},color(255,0,0));
    //c.addSeires("Green",new float[][]{{0,0},{5,50}},color(0,255,0));
    //c.addSeires("Blue",new float[][]{{0,100},{2.5,0}, {5,100}},color(0,0,255));
}

void draw(){
    if(displayWidth > 2560){
        surface.setSize(2560, 1440);
        scaleFactor = 2;
    }
    scale(scaleFactor);
    //background(45,80,22);
    background(200,200,200);
    h.drawSelf();
    pm.drawSelf();
    //c.drawSelf();
    //c.onMouseOver();
    //sp.drawSelf();
    //pp.drawSelf();
    //sb.drawSelf();
    //pp.onMouseOverMethod();
    //lc.drawSelf();
    //textSize(fontSz+5);
    //println(textAscent()+textDescent());
}

void mousePressed(){
    h.mousePressedMethod();
    pm.mousePressedMethod();
    //sp.mousePressedMethod();
    //pp.mousePressedMethod();
    //sb.mousePressedMethod();
    //lc.mousePressedMethod();
}

void keyPressed(){
    pm.keyPressedMethod();
    //pp.keyPressedMethod();
    //sp.keyPressedMethod();
}

void mouseWheel(MouseEvent e){
    float v = e.getCount();
    pm.mouseWheelMethod(v);
    //sb.mouseWheelMethod(v);
    //pp.mouseWheelMethod(v);
    //lc.mouseWheelMethod(v);
}

void mouseDragged(){
    pm.mouseDraggedMethod();
    //sb.mouseDraggedMethod();
    //pp.mouseDraggedMethod();
    //lc.mouseDraggedMethod();
}
