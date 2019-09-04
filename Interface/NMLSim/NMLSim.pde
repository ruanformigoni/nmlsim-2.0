SpriteCenter sprites;
Header h;
PanelMenu pm;
SubstrateGrid sg;
FileHandler fileSys;
SimulationBar sb;

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
    sb = new SimulationBar(0, 690, 1280, 30, sg, pm);
    h.setSimulationBar(sb);
}

void draw(){
    scale(scaleFactor);
    background(255, 153, 85);
    sg.drawSelf();
    pm.drawSelf();
    h.drawSelf();
    sb.drawSelf();
}

void mousePressed(){
    h.mousePressedMethod();
    pm.mousePressedMethod();
    sg.mousePressedMethod();
    sb.mousePressedMethod();
}

void keyPressed(){
    if(key == ESC) key=0;
    println(int(key));
    h.keyPressedMethod();
    pm.keyPressedMethod();
    sb.keyPressedMethod();
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

void saveAs(File selectedPath){
    if(selectedPath == null)
        return;
    String fileBaseName = selectedPath.getAbsolutePath();
    fileSys.setBaseName(fileBaseName);
    fileSys.writeXmlFile(null);
    fileSys.writeStructureFile();
    fileSys.writeConfigFile(null);
}

void saveProject(){
    fileSys.writeXmlFile(null);
    fileSys.writeConfigFile(null);
    fileSys.writeStructureFile();
}

void openProject(File selectedPath){
    if(selectedPath == null)
        return;
    String fileBaseName = selectedPath.getAbsolutePath();
    Path p = Paths.get(fileBaseName + "/structures.str");
    if(!Files.exists(p)){
        return;
    }
    p = Paths.get(fileBaseName + "/configurations.nmls");
    if(!Files.exists(p)){
        return;
    }
    fileSys.setBaseName(fileBaseName);
    fileSys.readStructureFile();
    fileSys.readConfigFile();
}

void importStructures(File selectedPath){
    if(selectedPath == null)
        return;
    Path p = Paths.get(selectedPath.getAbsolutePath() + "/structures.str");
    if(!Files.exists(p)){
        return;
    }
    fileSys.importStructureFile(selectedPath.getAbsolutePath() + "/structures.str");
}

void exportXML(File selectedPath){
    if(selectedPath == null)
        return;
    String filename = selectedPath.getAbsolutePath();
    fileSys.writeXmlFile(filename);
}
