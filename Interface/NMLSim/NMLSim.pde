import static javax.swing.JOptionPane.*;
import javax.swing.UIManager;
import java.awt.Color;


SpriteCenter sprites;
Header h;
PanelMenu pm;
SubstrateGrid sg;
FileHandler fileSys;
SimulationBar sb;
PopUpCenter popCenter;

float fontSz = 15;
float scaleFactor;

boolean ctrlPressed = false, altPressed = false, shiftPressed = false;

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
    
    popCenter = new PopUpCenter();
    UIManager UI=new UIManager();
    UI.put("OptionPane.background", new Color(116, 163, 117));
    UI.put("Panel.background", new Color(116, 163, 117));
}

void draw(){
    scale(scaleFactor);
    background(255, 153, 85);
    sg.drawSelf();
    pm.drawSelf();
    h.drawSelf();
    sb.drawSelf();
    popCenter.drawSelf();
}

void mousePressed(){
    if(popCenter.isActive())
        return;
    h.mousePressedMethod();
    pm.mousePressedMethod();
    sg.mousePressedMethod();
    sb.mousePressedMethod();
}

void keyPressed(){
    if(key == ESC) key=0;
    if(popCenter.isActive())
        return;
    if(key == CODED && keyCode == CONTROL)
        ctrlPressed = true;
    if(key == CODED && keyCode == ALT)
        altPressed = true;
    if(key == CODED && keyCode == SHIFT)
        shiftPressed = true;
    h.keyPressedMethod();
    pm.keyPressedMethod();
    sb.keyPressedMethod();
}

void keyReleased(){
    if(key == CODED && keyCode == CONTROL)
        ctrlPressed = false;
    if(key == CODED && keyCode == ALT)
        altPressed = false;
    if(key == CODED && keyCode == SHIFT)
        shiftPressed = false;
}

void mouseWheel(MouseEvent e){
    if(popCenter.isActive())
        return;
    float v = e.getCount();
    pm.mouseWheelMethod(v);
    sg.mouseWheelMethod(v);
}

void mouseDragged(){
    if(popCenter.isActive())
        return;
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
    PopUp p = new PopUp((width-200)/2, (height-100)/2,200,100,"Chages saved!");
    p.activate();
    p.setAsTimer(20);
    popCenter.setPopUp(p);
}

void saveProject(){
    fileSys.writeXmlFile(null);
    fileSys.writeConfigFile(null);
    fileSys.writeStructureFile();
    PopUp p = new PopUp((width-200)/2, (height-100)/2,200,100,"Chages saved!");
    p.activate();
    p.setAsTimer(20);
    popCenter.setPopUp(p);
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
