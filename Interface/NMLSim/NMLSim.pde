SpriteCenter sprites;
Header h;
PanelMenu pm;
SubstrateGrid sg;
FileHandler fileSys;
String fileBaseName = "";

float fontSz = 15;
float scaleFactor;

void setup(){
    size(1280, 720);
    //surface.setResizable(true);
    if(displayWidth > 2560){
        surface.setSize(2560, 1440);
        scaleFactor = 2;
    }else{
        scaleFactor = 1;
    }
    sprites = new SpriteCenter();

    sg = new SubstrateGrid(0, 105, 1280, 564, 10, 10, 1000, 5000);
    sg.setHiddenDimensions(500,300,500,150);
    sg.setBulletSpacing(60,124);
    pm = new PanelMenu(0, 670, 300, 500, sg);
    h = new Header(0, 0, 1280, sg);
    h.setPanelMenu(pm);
    fileSys = new FileHandler("", h, pm, sg);
}

void draw(){
    scale(scaleFactor);
    background(255, 153, 85);
    sg.drawSelf();
    pm.drawSelf();
    h.drawSelf();
}

void mousePressed(){
    h.mousePressedMethod();
    pm.mousePressedMethod();
    sg.mousePressedMethod();
}

void keyPressed(){
    pm.keyPressedMethod();
}

void mouseWheel(MouseEvent e){
    float v = e.getCount();
    pm.mouseWheelMethod(v);
    sg.mouseWheelMethod(v);
}

void mouseDragged(){
    pm.mouseDraggedMethod();
    sg.mouseDraggedMethod();
}

void saveXML(File selectedPath){
    if(selectedPath == null)
        return;
    fileBaseName = selectedPath.getAbsolutePath();
    fileSys.setBaseName(fileBaseName);
    fileSys.writeXmlFile();
}
