SpriteCenter sprites;
Header h;
//SimulationPanel sp;
//PhasePanel pp;
//Scrollbar sb;
//ListContainer lc;
PanelMenu pm;
SubstrateGrid sg;

float fontSz = 15;
float scaleFactor;
//Chart c;

void setup(){
    //size(2560, 1440);
    size(1280, 720);
    //surface.setResizable(true);
    if(displayWidth > 2560){
        surface.setSize(2560, 1440);
        scaleFactor = 2;
    }else{
        scaleFactor = 1;
    }
    sprites = new SpriteCenter();
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
    sg = new SubstrateGrid(0, 105, 1280, 564, 10, 10, 1000, 5000);
    sg.setHiddenDimensions(500,300,500,150);
    sg.setBulletSpacing(60,124);
    pm = new PanelMenu(0, 670, 300, 500, sg);
    h = new Header(0, 0, 1280, sg);
    //c = new Chart(400, 200, 600, 400);
    //c.addSeires("Red",new float[][]{{0,-00},{5,100}},color(255,0,0));
    //c.addSeires("Green",new float[][]{{0,0},{5,50}},color(0,255,0));
    //c.addSeires("Blue",new float[][]{{0,100},{2.5,0}, {5,100}},color(0,0,255));
}

void draw(){
    //scaleFactor = (float(width)/1280.0);
    //println(scaleFactor);
    scale(scaleFactor);
    background(83, 108, 83);
    background(255, 153, 85);
    sg.drawSelf();
    pm.drawSelf();
    h.drawSelf();
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
    sg.mousePressedMethod();
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
    sg.mouseWheelMethod(v);
    //sb.mouseWheelMethod(v);
    //pp.mouseWheelMethod(v);
    //lc.mouseWheelMethod(v);
}

void mouseDragged(){
    pm.mouseDraggedMethod();
    sg.mouseDraggedMethod();
    //sb.mouseDraggedMethod();
    //pp.mouseDraggedMethod();
    //lc.mouseDraggedMethod();
}