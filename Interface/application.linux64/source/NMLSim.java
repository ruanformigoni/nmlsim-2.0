import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import static javax.swing.JOptionPane.*; 
import javax.swing.UIManager; 
import java.awt.Color; 
import java.nio.file.Path; 
import java.nio.file.Paths; 
import java.nio.file.Files; 
import java.util.Map; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class NMLSim extends PApplet {






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

public void setup(){
    
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

public void draw(){
    if(!focused)
        ctrlPressed = altPressed = shiftPressed = false;
    scale(scaleFactor);
    background(255, 153, 85);
    sg.drawSelf();
    pm.drawSelf();
    h.drawSelf();
    sb.drawSelf();
    popCenter.drawSelf();
}

public void mousePressed(){
    if(popCenter.isActive())
        return;
    h.mousePressedMethod();
    pm.mousePressedMethod();
    sg.mousePressedMethod();
    sb.mousePressedMethod();
}

public void keyPressed(){
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

public void keyReleased(){
    if(key == CODED && keyCode == CONTROL)
        ctrlPressed = false;
    if(key == CODED && keyCode == ALT)
        altPressed = false;
    if(key == CODED && keyCode == SHIFT)
        shiftPressed = false;
}

public void mouseWheel(MouseEvent e){
    if(popCenter.isActive())
        return;
    float v = e.getCount();
    pm.mouseWheelMethod(v);
    sg.mouseWheelMethod(v);
}

public void mouseDragged(){
    if(popCenter.isActive())
        return;
    pm.mouseDraggedMethod();
    sg.mouseDraggedMethod();
}

public void saveAs(File selectedPath){
    if(selectedPath == null)
        return;
    String fileBaseName = selectedPath.getAbsolutePath();
    fileSys.setBaseName(fileBaseName);
    fileSys.writeXmlFile(null);
    fileSys.writeStructureFile();
    fileSys.writeConfigFile(null);
    PopUp p = new PopUp(((width-200)/2)*scaleFactor, ((height-100)/2)*scaleFactor, 200, 100, "Chages saved!");
    p.activate();
    p.setAsTimer(20);
    popCenter.setPopUp(p);
    ctrlPressed = altPressed = shiftPressed = false;
}

public void saveProject(){
    fileSys.writeXmlFile(null);
    fileSys.writeConfigFile(null);
    fileSys.writeStructureFile();
    PopUp p = new PopUp(((width-200)/2)*scaleFactor, ((height-100)/2)*scaleFactor, 200, 100, "Chages saved!");
    p.activate();
    p.setAsTimer(20);
    popCenter.setPopUp(p);
    ctrlPressed = altPressed = shiftPressed = false;
}

public void openProject(File selectedPath){
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
    ctrlPressed = altPressed = shiftPressed = false;
}

public void importStructures(File selectedPath){
    if(selectedPath == null)
        return;
    Path p = Paths.get(selectedPath.getAbsolutePath() + "/structures.str");
    if(!Files.exists(p)){
        return;
    }
    fileSys.importStructureFile(selectedPath.getAbsolutePath() + "/structures.str");
    ctrlPressed = altPressed = shiftPressed = false;
}

public void exportXML(File selectedPath){
    if(selectedPath == null)
        return;
    String filename = selectedPath.getAbsolutePath();
    fileSys.writeXmlFile(filename);
    ctrlPressed = altPressed = shiftPressed = false;
}
class Button{
    private String label, explanation;
    private PImage icon;
    private float x, y;
    private int labelColor, explanationColor, explanationBox, selectedBox, mouseOverColor, mouseOverExpandedColor;
    private Boolean active, expanded, isValid, isMouseOver, explanationOnRight, isTransparent;
    private HitBox hitbox;
    private int initialTime = -1;
    
    public Button(String label, String explanation, PImage icon, float x, float y){
        this.label = label;
        this.explanation = explanation;
        this.icon = icon;
        this.x = x;
        this.y = y;
        this.labelColor = color(255, 255, 255);
        this.explanationColor = color(255, 255, 255);
        this.explanationBox = color(212, 85, 0);
        this.selectedBox = color(200, 113, 55);
        this.mouseOverColor = color(83,108,83);
        this.mouseOverExpandedColor = color(45,80,22);
        this.active = false;
        explanationOnRight = true;
        isTransparent = false;
        this.expanded = false;
        this.isValid = true;
        this.isMouseOver = false;
        hitbox = new HitBox(x, y, icon.width, icon.height);
    }
    
    public void drawSelf(){
        textSize(fontSz);
        if(expanded){
            float offset = (icon.height - (textAscent()+textDescent()))/2;
            textSize(fontSz);
            fill(labelColor, (isTransparent)?128:255);
            stroke(labelColor, (isTransparent)?128:255);
            text(label, x + icon.width + 5, y + icon.height - textDescent() - offset);
        }
        if(!isValid)
            isMouseOver = false;
        if(active){
            fill(selectedBox, (isTransparent)?128:255);
            stroke(selectedBox, (isTransparent)?128:255);
            rect(x, y, icon.width, icon.height);
        } else if(isMouseOver){
            if(!expanded){
                fill(mouseOverColor, (isTransparent)?128:255);
                stroke(mouseOverColor, (isTransparent)?128:255);
            } else{
                fill(mouseOverExpandedColor, (isTransparent)?128:255);
                stroke(mouseOverExpandedColor, (isTransparent)?128:255);
            }
            if(!isTransparent)
                rect(x, y, icon.width, icon.height);
        }

        tint((isTransparent)?128:255);
        image(icon, x, y);
        tint(255);
    }

    public String getLabel(){
        return label;
    }

    public Boolean mousePressedMethod(){
    	if(!isValid || isTransparent)
            return false;
        Boolean collided = hitbox.collision(mouseX, mouseY);
        if(collided)
            active = !active;
        return collided;
    }
    
    public void onMouseOverMethod(){
        if(!isValid || isTransparent)
            return;
        if(hitbox.collision(mouseX, mouseY)){
            isMouseOver = true;
            int currTime = minute()*60*60 + second()*60 + millis();
            if(initialTime < 0)
                initialTime = currTime;
            if(currTime - initialTime > 2000){
                fill(explanationBox);
                stroke(explanationBox);
                if(explanationOnRight)
                    rect(x+icon.width, y, textWidth(explanation)+10, textAscent() + textDescent(), 5);
                else
                    rect(x-10-textWidth(explanation), y, textWidth(explanation)+10, textAscent() + textDescent(), 5);
                fill(explanationColor);
                noStroke();
                if(explanationOnRight)
                    text(explanation, x+icon.width+5, y + fontSz);
                else
                    text(explanation, x-5-textWidth(explanation), y + fontSz);
            }
        } else{
            initialTime = -1;
            isMouseOver = false;
        }
    }
    
    public void deactivate(){
        this.active = false;
    }
    
    public void setExpanded(Boolean opt){
        expanded = opt;
    }
    
    public void setPosition(float x, float y){
        this.x = x;
        this.y = y;
        hitbox.updateBox(x, y, icon.width, icon.height);
    }
    
    public float getWidth(){
        textSize(fontSz);
        if(expanded){
            return icon.width + textWidth(label) + 5;
        } else{
            return icon.width;
        }
    }
    
    public float getHeight(){
        return icon.height;
    }
}

class TextButton{
    private String label, content = "";
    private float x, y, w;
    private int labelColor, selectedColor, mouseOverColor, buttonColor;
    private Boolean isSelected, isValid, isTyping, isCentered;
    private HitBox hitbox;
    
    TextButton(String label, float x, float y, float w){
        this.x = x;
        this.y = y;
        this.label = label;
        labelColor = color(255,255,255);
        selectedColor = color(212,85,0);
        mouseOverColor = color(83,108,83);
        buttonColor = color(45,80,22);
        isSelected = false;
        isValid = true;
        isTyping = false;
        isCentered = false;
        textSize(fontSz);
        hitbox = new HitBox(x, y, w, textAscent()+textDescent());
    }
    
    public void drawSelf(){
        textSize(fontSz);
        float h = textAscent()+textDescent();
        if(isSelected){
            fill(selectedColor);
            stroke(selectedColor);
        } else if(hitbox.collision(mouseX, mouseY)){
            fill(mouseOverColor);
            stroke(mouseOverColor);
        } else{
            fill(buttonColor);
            stroke(buttonColor);
        }
        rect(x, y, w, h, 5);
        fill(labelColor);
        noStroke();
        String aux = label;
        while(textWidth(aux) > w-10)
            if(isTyping)
                aux = aux.substring(1, aux.length());
            else
                aux = aux.substring(0, aux.length()-1);
        if(isCentered){
            text(aux, x+5+(w-textWidth(aux)-10)/2, y+fontSz);
        } else{
            text(aux, x+5, y+fontSz);
        }
    }

    public Boolean mousePressedMethod(){
        if(!isValid)
            return false;
        Boolean collided = hitbox.collision(mouseX, mouseY);
        if(collided)
            isSelected = !isSelected;
        return collided;
    }
    
    public void center(){
        isCentered = true;
    }
    
    public void unselect(){
        isSelected = false;
    }
    
    public String getText(){
        return label;
    }
    
    public boolean keyPressedMethod(){
        if(!isValid)
            return false;
        if(isSelected){
            if(key == BACKSPACE){
                if(label.length() > 0){
                    this.label = label.substring(0, label.length()-1);
                }
            } else if (key == ENTER | key == TAB){
                unselect();
            } else if((keyCode > 64 && keyCode < 91) || (keyCode > 95 && keyCode < 106) || keyCode == 107 || keyCode == 109 || (keyCode > 43 && keyCode < 47) || (keyCode > 47 && keyCode < 58)){
                label += key;
            }
            return true;
        }
        return false;
    }
    
    public String getButtonContent(){
        return content;
    }
    
    public void setButtonContent(String c){
        content = c;
    }

    public void deactivate(){
        this.isSelected = false;
    }
    
    public void select(){
        isSelected = true;
    }
    
    public void setPosition(float x, float y){
        this.x = x;
        this.y = y;
        textSize(fontSz);
        hitbox.updateBox(x, y, w, textAscent()+textDescent());
    }
    
    public void setWidth(float w){
        this.w = w;
        textSize(fontSz);
        hitbox.updateBox(x, y, w, textAscent()+textDescent());
    }
    
    public void setText(String s){
        label = s;
    }
}
class Chart{
    float x, y, w, h;
    ArrayList<float[][]> series;
    ArrayList<Integer> colors;
    ArrayList<String> labels;
    int background, axis, text, popUpColor;
    HitBox hitbox;
    
    Chart(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        background = color(200,200,200);
        text = color(0,0,0);
        axis = color(0,0,0);
        popUpColor = color(212,85,0);
        series = new ArrayList<float[][]>();
        colors = new ArrayList<Integer>();
        labels = new ArrayList<String>();
        hitbox = new HitBox(x, y, w, h);
    }
    
    public void rescale(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        hitbox.updateBox(x, y, w, h);
    }
    
    public void addSeires(String label, float[][] data, Integer seriesColor){
        series.add(data);
        colors.add(seriesColor);
        labels.add(label);
    }
    
    public Float getLowerValue(){
        Float lower = null;
        for(int s=0; s<series.size(); s++){
            float[][] aux = series.get(s);
            for(int i=0; i<aux.length; i++){
                if(lower == null){
                    lower = aux[i][1];
                } else if(aux[i][1] < lower){
                    lower = aux[i][1];
                }
            }
        }
        if(lower != null && lower>0)
            lower = 0.0f;
        return lower;
    }
    
    public Float getHigherValue(){
        Float higher = null;
        for(int s=0; s<series.size(); s++){
            float[][] aux = series.get(s);
            for(int i=0; i<aux.length; i++){
                if(higher == null){
                    higher = aux[i][1];
                } else if(aux[i][1] > higher){
                    higher = aux[i][1];
                }
            }
        }
        if(higher != null && higher<=0)
            higher = 1.0f;
        return higher;
    }
    
    public Float getHigherX(){
        Float higher = null;
        for(int s=0; s<series.size(); s++){
            float[][] aux = series.get(s);
            for(int i=0; i<aux.length; i++){
                if(higher == null){
                    higher = aux[i][0];
                } else if(aux[i][0] > higher){
                    higher = aux[i][0];
                }
            }
        }
        return higher;
    }
    
    public float getPixel(float value){
        float delta = -(h-15)/(getHigherValue() - getLowerValue());
        return (value-getLowerValue())*delta + h + y - 10;
    }
    
    public void drawSerie(float[][]data){
        float delta = (w-15)/getHigherX();
        for(int i=0; i<data.length-1; i++){
            line(data[i][0]*delta+x+10, getPixel(data[i][1]), data[i+1][0]*delta+x+10, getPixel(data[i+1][1]));
        }
    }
    
    public void drawSelf(){
        fill(background);
        stroke(background);
        rect(x, y, w, h, 5);
        if(series.size() == 0)
            return;
        stroke(axis);
        strokeWeight(3);
        line(x+10, y+5, x+10, y+h-10);
        line(x+10, getPixel(0), x+w-5, getPixel(0));

        for(int i=0; i<series.size(); i++){
            stroke(colors.get(i));
            drawSerie(series.get(i));
        }
        strokeWeight(1);
        onMouseOver();
    }
    
    public void onMouseOver(){
        if(!hitbox.collision(mouseX,mouseY))
            return;
        textSize(fontSz);
        float w = 0, h;
        for(int i=0; i<labels.size(); i++)
            if(textWidth(labels.get(i)) > w)
                w = textWidth(labels.get(i));
        w += 30;
        h = labels.size()*(textAscent() + textDescent() + 5) + 5;
        fill(popUpColor);
        stroke(popUpColor);
        rect(x+this.w, y, w, h, 5);
        float auxY = y + 5;
        for(int i=0; i<labels.size(); i++){
            fill(colors.get(i));
            stroke(255, 255, 255);
            rect(x+this.w+5, auxY+2, 15, 15, 5);
            fill(255,255,255);
            noStroke();
            text(labels.get(i), x+this.w+25, auxY+fontSz);
            auxY += textAscent() + textDescent() + 5;
        }
    }
}
class CheckBox{
    String label;
    float x, y, w, boxSide;
    int boxColor, strokeColor, checkColor, fontColor;
    boolean isChecked, isActive;
    HitBox hitbox;
    
    public CheckBox(String label, float x, float y, float w){
        this.x = x;
        this.y = y;
        this.w = w/2;
        this.isChecked = false;
        this.label = label;
        boxColor = color(45, 80, 22);
        strokeColor = color(255, 255, 255);
        checkColor = color(212, 85, 0);
        fontColor = color(255, 255, 255);
        isActive = true;
        textSize(fontSz);
        boxSide = (textAscent()+textDescent());
        this.hitbox = new HitBox(x+w, this.y, boxSide, boxSide);
    }
    
    public void drawSelf(){
        textSize(fontSz);
        fill(fontColor);
        stroke(fontColor);
        String aux = label;
        while(textWidth(aux) > w)
            aux = aux.substring(0, aux.length()-1);
        text(aux, x, y+fontSz);
        
        fill(boxColor);
        strokeWeight(3);
        stroke(strokeColor);
        rect(x+w, y, boxSide, boxSide,5);
        fill(checkColor);
        stroke(checkColor);
        if(isChecked){
            line(x + w + 5, y+5, x + w + boxSide - 5, y+boxSide-5);
            line(x + w + boxSide - 5, y+5, x + w + 5, y+boxSide-5);
        }
        strokeWeight(1);
    }
    
    public void updatePosition(float x, float y){
        this.x = x;
        this.y = y;
        hitbox.updateBox(x+w,y,boxSide,boxSide);
    }
    
    public boolean mousePressedMethod(){
        if(!isActive)
            return false;
        boolean collided = hitbox.collision(mouseX, mouseY);
        if(collided){
            this.isChecked = !this.isChecked;
        }
        return collided;
    }
}
class ColorPallete{
    float x, y, w, h;
    int selectedColor, strokeColor, palleteColor;
    int[] colors;
    HitBox hitbox;
    ArrayList<HitBox> colorsBoxes;
    boolean isSelecting = false;
    
    ColorPallete(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        hitbox = new HitBox(x, y, w, h);
        colorsBoxes = new ArrayList<HitBox>();
        strokeColor = color(255,255,255);
        palleteColor = color(212,85,0);
        colors = new int[]{0xff008000,0xff000080,0xffFFFF00,0xff5500D4,0xff502D16,0xff1ECFD4,0xff00FF00,0xff000000,0xffFF8A00};
        for(int i=0; i<colors.length; i++)
            colorsBoxes.add(new HitBox(x, y, w, h));
        selectedColor = colors[PApplet.parseInt(random(colors.length))];
    }
    
    public void drawSelf(){
        stroke(strokeColor);
        fill(selectedColor);
        rect(x, y, w, h, 5);
        if(isSelecting){
            float maxH = ceil(colors.length/3.0f)*(h+5)+5;
            float maxW = 3*(w+5)+5;
            fill(palleteColor);
            rect(x+w/2-maxW/2, y+h/2-maxH/2, maxW, maxH, 5);
            float auxY = y+h/2-maxH/2 + 5, auxX;
            for(int i=0; i<colors.length; i+=3){
                auxX = x+w/2-maxW/2+5;
                fill(colors[i]);
                rect(auxX, auxY, w, h, 5);
                colorsBoxes.get(i).updateBox(auxX, auxY, w, h);
                auxX += w+5;
                if(i+1 < colors.length){
                    fill(colors[i+1]);
                    rect(auxX, auxY, w, h, 5);
                    colorsBoxes.get(i+1).updateBox(auxX, auxY, w, h);
                    auxX += w+5;
                }
                if(i+2 < colors.length){
                    fill(colors[i+2]);
                    rect(auxX, auxY, w, h, 5);
                    colorsBoxes.get(i+2).updateBox(auxX, auxY, w, h);
                }
                auxY += h+5;
            }
        }
    }
    
    public boolean mousePressedMethod(){
        boolean hit = false;
        if(isSelecting){
            int index;
            for(index=0; index<colorsBoxes.size(); index++)
                if(colorsBoxes.get(index).collision(mouseX, mouseY))
                    break;
            if(index < colorsBoxes.size()){
                this.selectedColor = colors[index];
                isSelecting = false;
                hit = true;
            }
        } else{
            hit = hitbox.collision(mouseX, mouseY);
            if(hit){
                isSelecting = true;
            }
        }
        return hit;
    }
    
    public void updatePosition(float x, float y){
        this.x = x;
        this.y = y;
        hitbox.updateBox(x,y,w,h);
    }
    
    public void resetColor(){
        selectedColor = colors[PApplet.parseInt(random(colors.length))];
    }
    
    public Integer getColor(){
        return selectedColor;
    }
    
    public void setColor(Integer myColor){
        selectedColor = myColor;
    }
}
public class DropDownBox{
    private String label;
    private ArrayList<String> options;
    private float x, y, w;
    private int selectedOpt = -1;
    private boolean isSelected, isDropping, isActive;
    private int fontColor, insideFontColor, boxColor, normal, selected, invalid;
    private HitBox boxhit, arrowhit;
    private ArrayList<HitBox> optionshit;
    
    public DropDownBox(String label, float xPosition, float yPosition, float boxWidth){
        this.label = label;
        this.x = xPosition;
        this.y = yPosition;
        this.w = boxWidth/2;
        this.isActive = true;
        this.options = new ArrayList<String>();
        this.isSelected = false;
        this.isDropping = false;
        this.fontColor = color(255,255,255);
        this.boxColor = color(255,255,255);
        this.normal = color(45,80,22);
        this.selected = color(255,153,85);
        this.invalid = color(255,0,0);
        this.insideFontColor = color(45,80,22);
        textSize(fontSz);
        boxhit = new HitBox(x+w, y, w, textAscent()+textDescent());
        arrowhit = new HitBox(x + 2*w - fontSz, y, fontSz, textAscent()+textDescent());
        optionshit = new ArrayList<HitBox>();
    }
    
    public void drawSelf(){
        textSize(fontSz);
        float h = textAscent() + textDescent();
        fill(fontColor);
        stroke(fontColor);
        String auxl = label;
        while(textWidth(auxl) > w)
            auxl = auxl.substring(0, auxl.length()-1);
        text(auxl, x, y + fontSz);
        
        fill(boxColor);
        if(isSelected)
            stroke(selected);
        else if(selectedOpt >= 0)
            stroke(normal);
        else
            stroke(invalid);

        if(isDropping){
            rect(x+w, y, w, (options.size()+1)*(h+5)-5, 5);
        } else{
            rect(x+w, y, w, h, 5);
        }

        fill(insideFontColor);
        stroke(insideFontColor);
        if(selectedOpt >= 0){
            String aux = options.get(selectedOpt);
            while(textWidth(aux) > (w-fontSz-5))
                aux = aux.substring(0, aux.length()-1);
            text(aux, x+5+w, y+fontSz);
        }
        
        fill(normal);
        if(isDropping)
            triangle(x + 2*w - (h-5), y+h-5, x + 2*w - 5, y+h-5, x + 2*w - (h)/2, y+5);
        else
            triangle(x + 2*w - (h-5), y+5, x + 2*w - 5, y+5, x + 2*w - (h)/2, y+h-5);
            
        fill(insideFontColor);
        if(isDropping){
            if(options.size() > 0)
                line(x+w+5, y+h+5, x+2*w-5, y+h+5);
            for(int i=0; i<options.size(); i++){
                String aux = options.get(i);
                while(textWidth(aux) > w-5)
                    aux = aux.substring(0, aux.length()-1);
                text(aux, x+5+w, y+(i+1)*(h)+fontSz+5);
                optionshit.get(i).updateBox(x+w, y+(i+1)*(h)+5, w, h);
            }
        }
    }
    
    public void addOption(String opt){
        options.add(opt);
        optionshit.add(new HitBox(0,0,0,0));
    }
    
    public void removeOption(int index){
        options.remove(index);
        optionshit.remove(index);
    }
    
    public void removeAllOptions(){
        options.clear();
        optionshit.clear();
        resetOption();
    }
    
    public boolean mousePressedMethod(){
        if(!isActive)
            return false;
        isSelected = boxhit.collision(mouseX, mouseY);
        if(isDropping){
            for(int i=0; i<options.size(); i++)
                if(optionshit.get(i).collision(mouseX, mouseY)){
                    selectedOpt = i;
                    isDropping = false;
                }
        }
        isDropping = arrowhit.collision(mouseX, mouseY) & !isDropping;
        return isSelected;
    }
    
    public void setLabel(String newLabel){
        this.label = newLabel;
    }
    
    public String getSelectedOption(){
        if(selectedOpt < 0)
            return "";
        else
            return options.get(selectedOpt);
    }
    
    public void setSelectedOption(String opt){
        for(int i=0; i<options.size(); i++)
            if(options.get(i).equals(opt))
                selectedOpt = i;
    }
    
    public void resetOption(){
        this.selectedOpt = -1;
    }    
    
    public void updatePosition(float x, float y){
        this.x = x;
        this.y = y;
        boxhit.updateBox(x, y, w, textAscent()+textDescent());
        arrowhit = new HitBox(x + 2*w - fontSz, y, fontSz, textAscent()+textDescent());
    }
}
public class FileHandler{
    String fileBaseName;
    Header header;
    PanelMenu panelMenu;
    SubstrateGrid substrateGrid;
    PrintWriter xmlFileOut, configFileOut, structureFileOut;
    BufferedReader configFileIn, structureFileIn;
    
    FileHandler(String baseName, Header h, PanelMenu pm, SubstrateGrid sg){
        fileBaseName = baseName;
        header = h;
        panelMenu = pm;
        substrateGrid = sg;
    }
    
    public void setBaseName(String baseName){
        fileBaseName = baseName;
    }
    
    public void writeStructureFile(){
        ArrayList <String> structures = panelMenu.getStructures();
        structureFileOut = createWriter(fileBaseName + "/structures.str");
        for(String s : structures)
            structureFileOut.println(s);
        structureFileOut.flush();
        structureFileOut.close();
        
    }
    
    public void readStructureFile(){
        ArrayList<String> structures = new ArrayList<String>();
        structureFileIn = createReader(fileBaseName + "/structures.str");
        try{
            String line = structureFileIn.readLine();
            while(line != null && !line.equals("")){
                structures.add(line);
                line = structureFileIn.readLine();
            }
            panelMenu.loadStructures(structures);
            structureFileIn.close();
        } catch(Exception e){}
    }
    
    public void importStructureFile(String path){
        ArrayList<String> structures = new ArrayList<String>();
        structureFileIn = createReader(path);
        try{
            String line = structureFileIn.readLine();
            while(line != null && !line.equals("")){
                structures.add(line);
                line = structureFileIn.readLine();
            }
            panelMenu.importStructureFile(structures);
            structureFileIn.close();
        } catch(Exception e){}
    }
    
    public void readConfigFile(){
        structureFileIn = createReader(fileBaseName + "/configurations.nmls");
        try{
            String circuit = structureFileIn.readLine();
            String grid = structureFileIn.readLine();
            panelMenu.simPanel.loadProperties(circuit, grid);
            
            String line = structureFileIn.readLine();
            while(!line.equals("Phases"))
                line = structureFileIn.readLine();
            line = structureFileIn.readLine();
            ArrayList <String> phases = new ArrayList<String>(); 
            while(!line.equals("Zones")){
                phases.add(line);
                line = structureFileIn.readLine();
            }
            panelMenu.phasePanel.loadPhaseProperties(phases);
            
            line = structureFileIn.readLine();
            ArrayList <String> zones = new ArrayList<String>(); 
            while(!line.equals("Magnets")){
                zones.add(line);
                line = structureFileIn.readLine();
            }
            panelMenu.zonePanel.loadZoneProperties(zones);
            
            line = structureFileIn.readLine();
            substrateGrid.randomName = Integer.parseInt(line);
            line = structureFileIn.readLine();
            ArrayList <String> magnets = new ArrayList<String>(); 
            while(line != null && !line.equals("")){
                magnets.add(line);
                line = structureFileIn.readLine();
            }
            substrateGrid.loadMagnetProperties(magnets);
            
            panelMenu.zonePanel.updatePhases();
            panelMenu.magnetPanel.updateZones();

            structureFileIn.close();
            
        } catch(Exception e){}
    }
    
    public void writeConfigFile(String filename){
        if(filename == null || filename.equals(""))
            structureFileOut = createWriter(fileBaseName + "/configurations.nmls");
        else
            structureFileOut = createWriter(filename);
        String circuit = panelMenu.getCircuitProperties();
        String grid = panelMenu.simPanel.getGridProperties();
        ArrayList<String> phases = pm.getPhaseProperties();
        ArrayList<String> zones = pm.getZoneProperties();
        ArrayList<String> magnets = sg.getMagnetsProperties();
        
        structureFileOut.println(circuit);
        structureFileOut.println(grid);
        structureFileOut.println("Phases");
        for(String p : phases){
            structureFileOut.println(p);
        }
        structureFileOut.println("Zones");        
        for(String z : zones){
            structureFileOut.println(z);
        }
        structureFileOut.println("Magnets");
        structureFileOut.println(substrateGrid.randomName);
        for(String m : magnets){
            structureFileOut.println(m);
        }
        
        structureFileOut.flush();
        structureFileOut.close();
    }
    
    public void writeXmlFile(String filename){
        if(filename == null || filename.equals(""))
            xmlFileOut = createWriter(fileBaseName + "/simulation.xml");
        else
            xmlFileOut = createWriter(filename);
        //engine;mode;method;repetitions;reportStep;alpha;ms;temperature;timeStep;simTime;spinAngle;spinDiff;hmt;neighborhood
        String [] circuitParts = panelMenu.getCircuitProperties().split(";");
        xmlFileOut.println("<!-- ALL measures of time are in nanoseconds and ALL metric measures are in nanometers -->\n" + 
                           "<!-- This is the main circuit properties, such as technology, engine and others -->\n" + 
                           "<!-- Each engine had different properties to be setted in this field -->\n" + 
                           "<circuit>\n" + 
                           "\t<!-- There are 2 engines: LLG and Behaviour. There is only iNML technology for now -->\n" +
                           "\t<property technology=\"iNML\" engine=\"" + circuitParts[0] + "\"/>\n" +
                           "\t<!-- There are two possible different methods for the LLG engine, the RK4 and the RKW2 - Runge Kutta 4th order and Runge Kutta Weak 2nd order -->\n" +
                           "\t<!-- Be mindfull that the RK4 method disconsiders the temperature -->\n" + 
                           "\t<property method=\"" + circuitParts[2] + "\"/>\n" + 
                           "\t<!-- There are 4 simulationMode: exaustive, direct, repetitive and verbose -->\n" +
                           "\t<property simulationMode=\"" + circuitParts[1] + "\"/>\n" +
                           "\t<!-- The number of simulations to be done in the repetitive mode -->\n" +
                           "\t<property repetitions=\"" + circuitParts[3] + "\"/>\n" +
                           "\t<!-- The report time step. Starting at time 0, the program reports at each reportStep. Only used in verbose mode -->\n" +
                           "\t<property reportStep=\"" + circuitParts[4] + "\"/>\n" +
                           "\t<!-- Gilbert damping factor -->\n" +
                           "\t<property alpha=\"" + circuitParts[5] + "\"/>\n" +
                           "\t<!-- Saturation Magnetization in A/m -->\n" +
                           "\t<property Ms=\"" + circuitParts[6] + "\"/>\n" +
                           "\t<!-- Temperature in K. Be mindfull that the RK-Weak order 2.0 (RKW2) is used for T > 0 and the RK of fourth order (RK4) for T == 0 -->\n" +
                           "\t<property temperature=\"" + circuitParts[7] + "\"/>\n" +
                           "\t<!-- Discretization of time in nanoseconds. It's highly recommended using very low timeStep -->\n" +
                           "\t<property timeStep=\"" + circuitParts[8] + "\"/>\n" +
                           "\t<!-- Simulation Duration in nanoseconds -->\n" +
                           "\t<property simTime=\"" + circuitParts[9] + "\"/>\n" +
                           "\t<!-- Properties for the heavy material for spin hall effect -->\n" +
                           "\t<property spinAngle=\"" + circuitParts[10] + "\"/>\n" +
                           "\t<property spinDifusionLenght=\"" + circuitParts[11] + "\"/>\n" +
                           "\t<!-- Thickness in nanometers -->\n" + 
                           "\t<property heavyMaterialThickness=\"" + circuitParts[12] + "\"/>\n" +
                           "\t<!-- Radius of the considered neighborhood. We recomend using values of 300 for more efficciency. -->\n" +
                           "\t<property neighborhoodRatio=\"" + circuitParts[13] + "\"/>\n" +
                           "</circuit>\n");
                           
        ArrayList<String> phases = pm.getPhaseProperties();
        xmlFileOut.println("<!-- This is the clock phases properties -->\n<clockPhase>\n" +
                           "\t<!-- Each clock phase must be an item -->\n\t<!-- Each clock phase must have a different name, which can be whatever name -->\n" +
                           "\t<!-- The format for RKW2 uses a clock signal with 6 values. The 3 first are external field (x,y,z) and the 3 last are current field (x,y,z) -->\n" +
                           "\t<!-- Users can use both an external field and a current field with LLG. In order to not use one of them, just leave its fields as 0 -->\n" +
                           "\t<!-- The format for the Behaviour engine uses only one value for clock signal. The value corresponds to a field applied on x direction -->\n" +
                           "\t<!-- The value for signal in the Behaviour engine needs to be in the [0,1] interval, where 0 represents no clock and 1 represents 100% force -->\n" +
                           "\t<!-- Phases can have different durations, but be mindfull of their sincronization -->");
        for(String phase : phases){
            String parts[] = phase.split(";");
            if(parts[1].contains(",")){
                xmlFileOut.println("\t<item name=\"" + parts[0] + "\">\n" +
                                   "\t\t<property initialSignal=\"" + parts[1] + parts[3] + "\"/>\n" +
                                   "\t\t<property endSignal=\"" + parts[2] + parts[4] + "\"/>\n" +
                                   "\t\t<property duration=\"" + parts[5] + "\"/>\n\t</item>");
            }else{
                xmlFileOut.println("\t<item name=\"" + parts[0] + "\">\n" +
                                   "\t\t<property initialSignal=\"" + parts[1] + "\"/>\n" +
                                   "\t\t<property endSignal=\"" + parts[2] + "\"/>\n" +
                                   "\t\t<property duration=\"" + parts[3] + "\"/>\n\t</item>");
            }
        }
        xmlFileOut.println("</clockPhase>\n");
       
        ArrayList<String> zones = pm.getZoneProperties();
        HashMap<String,Integer> zoneIndex = new HashMap<String,Integer>();
        xmlFileOut.println("<!-- This is the clock zone properties -->\n<clockZone>\n\t<!-- Each clock zone must be an item -->\n" +
                           "\t<!-- Each clock zone must have an integer numerical name, starting in 0 and following growing sequence (0,1,2,3,etc) -->\n" +
                           "\t<!-- All phases that a zone percieve must be listed -->\n" +
                           "\t<!-- The order of the phases matter a lot, since the zone will start with the first phase and follow the order from top to bottom -->\n" +
                           "\t<!-- The order of the phases are ciclycal, which means the first phase start again after the end of the last one -->");
        int index = 0;
        for(String zone : zones){
            String parts[] = zone.split(";");
            xmlFileOut.println("\t<item name=\"" + index + "\">");
            for(int i=1; i<parts.length-1; i++){
                xmlFileOut.println("\t\t<property phase=\"" + parts[i] + "\">");
            }
            xmlFileOut.println("\t</item>");
            zoneIndex.put(parts[0],index);
            index++;
        }
        xmlFileOut.println("</clockZone>");
       
        /*name;type;clockZone;magnetization;fixed;w;h;tk;tc;bc;position;zoneColor;mimic*/
        ArrayList<String> magnets = sg.getMagnetsProperties();
        magnets.sort(String.CASE_INSENSITIVE_ORDER);
        HashMap<String,String> components = new HashMap<String,String>();
        int compName = 0;
        xmlFileOut.println("<!-- This is the components properties -->\n<components>\n\t<!-- List here all different geometries of magnets in the circuit -->" +
                           "\t<!-- This part also is used to determine if a magnet is fixed or not -->\n\t<!-- Each different geometry must be an item -->\n" +
                           "\t<!-- Each geometry must have a unique name, which can be whatever -->");
        for(String magnet : magnets){
            String [] parts = magnet.split(";");
            String component = "\t\t<property width=\"" + parts[5] + "\"/>\n\t\t<property height=\"" + parts[6] + "\"/>\n\t\t<property thickness=\"" + parts[7] + "\"/>\n" +
                               "\t\t<property topCut=\"" + parts[8] + "\"/>\n\t\t<property bottomCut=\"" + parts[9] + "\"/>\n";
            if(!components.containsKey(component)){
                xmlFileOut.println("\t<item name=\"component_" + compName + "\">\n" + component + "\t</item>");
                components.put(component, "component_"+compName);
                compName++;
            }

        }
        xmlFileOut.println("</components>");
        
        xmlFileOut.println("<!-- This is the design properties -->\n<design>\n\t" +
                           "<!-- List here all magnets of the circuit. Note that the geometry section does not insert any magnet in the circuit! -->\n" +
                           "\t<!-- Each magnet must be an item -->\n\t<!-- Each magnet must have a unique name, which can be whatever -->");
        for(String magnet : magnets){
            String [] parts = magnet.split(";");
            String component = "\t\t<property width=\"" + parts[5] + "\"/>\n\t\t<property height=\"" + parts[6] + "\"/>\n\t\t<property thickness=\"" + parts[7] + "\"/>\n" +
                               "\t\t<property topCut=\"" + parts[8] + "\"/>\n\t\t<property bottomCut=\"" + parts[9] + "\"/>\n";
            xmlFileOut.println("\t<item name=\"" + parts[0] + "\">\n\t\t<property component=\"" + components.get(component) + "\"/>\n" +
                               "\t\t<property myType=\"" + parts[1] + "\"/>\n\t\t<property fixedMagnetization=\"" + parts[4] + "\"/>\n" +
                               "\t\t<property position=\"" + parts[10] + "\"/>\n\t\t<property clockZone=\"" + zoneIndex.get(parts[2]) + "\"/>\n" +
                               "\t\t<property magnetization=\"" + parts[3] + "\"/>\n" + ((parts.length > 12)?("\t\t<property mimic=\"" + parts[12] + "\"/>\n"):("")) + "\t</item>");
        }
        xmlFileOut.println("</design>");
        xmlFileOut.flush();
        xmlFileOut.close();
    }
}
class HeaderContainer{
    private ArrayList <Button> buttons;
    private Boolean isExpanded;
    private String label;
    private float x, y;
    private int containerColor, expandedColor, labelColor;
    private HitBox hitbox;
    
    public HeaderContainer(String label, float x, float y){
        this.label = label;
        this.isExpanded = false;
        this.x = x;
        this.y = y;
        this.buttons = new ArrayList<Button>();
        this.containerColor = color(45, 80, 22);
        this.expandedColor = color(83, 108, 83);
        this.labelColor = color(255, 255, 255);
        this.hitbox = new HitBox(0, 0, 0, 0);
    }
    
    public void drawSelf(){
        float centerFactor = 0;
        float boxWidth = 0;
        for(int i=0; i<buttons.size(); i+=2){
            float big = buttons.get(i).getWidth();
            if(i+1 < buttons.size() && buttons.get(i+1).getWidth() > big)
                big = buttons.get(i+1).getWidth();
            boxWidth += big + 5;
        } boxWidth += 10;
        textSize(fontSz+5);
        if(textWidth(label) > boxWidth){
            centerFactor = (textWidth(label) + 10 - boxWidth)/2;
            boxWidth = textWidth(label) + 10;
        }
        if(isExpanded){
            fill(expandedColor);
            stroke(expandedColor);
        } else{
            fill(containerColor);
            stroke(containerColor);
        }
        rect(x, y, boxWidth, textAscent() + textDescent() + buttons.get(0).getHeight()*2 + 10);
        fill(labelColor);
        stroke(labelColor);
        hitbox.updateBox(x + (boxWidth - textWidth(label))/2, y, textWidth(label), fontSz+5);
        textSize(fontSz+5);
        text(label, x + (boxWidth - textWidth(label))/2, y+fontSz+5);
        float tempX = x+5+centerFactor, tempY = y+fontSz+10, bigger = 0;
        for(int i=0; i<buttons.size(); i++){
            Button b = buttons.get(i);
            b.setPosition(tempX, tempY);
            b.drawSelf();
            if(b.getWidth() > bigger)
                bigger = b.getWidth();
            if(i%2 == 0){
                tempY += b.getHeight() + 5;
            } else{
                tempY -= b.getHeight() + 5;
                tempX += bigger + 5;
                bigger = 0;
            }
        }
    }
    
    public float getWidth(){
        float boxWidth = 0;
        for(int i=0; i<buttons.size(); i+=2){
            float big = buttons.get(i).getWidth();
            if(i+1 < buttons.size() && buttons.get(i+1).getWidth() > big)
                big = buttons.get(i+1).getWidth();
            boxWidth += big + 5;
        }
        boxWidth = (textWidth(label) > boxWidth)?textWidth(label):boxWidth;
        return boxWidth + 10;
    }
    
    public float getHeight(){
        textSize(fontSz+5);
        return textAscent() + textDescent() + buttons.get(0).getHeight()*2 + 10;
    }
    
    public void setPosition(float x, float y){
        this.x = x;
        this.y = y;
    }
    
    public void onMouseOverMethod(){
        for(int i=0; i<buttons.size(); i++)
            buttons.get(i).onMouseOverMethod();
    }
    
    public void setExpanded(boolean opt){
        isExpanded = opt;
        for(int i=0; i<buttons.size(); i++)
            buttons.get(i).setExpanded(isExpanded);
    }
    
    public String mousePressedMethod(){
        if(hitbox.collision(mouseX, mouseY)){
            isExpanded = !isExpanded;
            for(int i=0; i<buttons.size(); i++)
                buttons.get(i).setExpanded(isExpanded);
            return "HeaderLabel";
        }
        for(int i=0; i<buttons.size(); i++){
            if(buttons.get(i).mousePressedMethod()){
                return buttons.get(i).getLabel();
            }
        }
        return "None";
    }
    
    public void addButton(Button b){
        if(b.getLabel().equals("Bullet"))
            b.active = true;
        b.setExpanded(isExpanded);
        buttons.add(b);
    }
    
    public void deactiveteButton(String label){
        for(int i=0; i<buttons.size(); i++){
            if(buttons.get(i).getLabel().equals(label))
                buttons.get(i).deactivate();
        }
    }
    
    public void activeteButton(String label){
        for(int i=0; i<buttons.size(); i++){
            if(buttons.get(i).getLabel().equals(label))
                buttons.get(i).active = true;
        }
    }
    
    public boolean isActive(String label){
        for(int i=0; i<buttons.size(); i++){
            if(buttons.get(i).getLabel().equals(label))
                return buttons.get(i).active;
        }
        return false;
    }
}

class Header{
    HeaderContainer file, magnet, substrate;//, others;
    float x, y, myW;
    SubstrateGrid substrateGrid;
    SimulationBar simulationBar;
    PanelMenu panelMenu;
    String fileBaseName;
    
    public Header(float x, float y, float w, SubstrateGrid sg){
        this.x = x;
        this.y = y;
        this.myW = w;
        substrateGrid = sg;
        //fontSz = 30;
        
        file = new HeaderContainer("File", x+5, y);
        file.addButton(new Button("Save", "Saves the NML circuit file", sprites.saveIconWhite, 0, 0));
        file.addButton(new Button("New", "Creates a new NML circuit file", sprites.newIconWhite, 0, 0));
        file.addButton(new Button("Save As", "Saves the NML circuit file with a different name", sprites.saveAsIconWhite, 0, 0));
        file.addButton(new Button("Open", "Opens a NML circuit file", sprites.openIconWhite, 0, 0));
        
        magnet = new HeaderContainer("Magnet", x, y);
        magnet.addButton(new Button("Delete", "Delete a magnet or a group of magnets", sprites.deleteIconWhite, 0, 0));
        magnet.addButton(new Button("Edit", "Edit a magnet or a group of magnets", sprites.editIconWhite, 0, 0));
        magnet.addButton(new Button("Copy", "Copy a magnet or a group of magnets", sprites.copyIconWhite, 0, 0));
        magnet.addButton(new Button("Paste", "Paste copied magnets", sprites.pasteIconWhite, 0, 0));
        magnet.addButton(new Button("Cut", "Cut from grid a magnet or a group of magnets", sprites.cutIconWhite, 0, 0));
        magnet.addButton(new Button("Group", "Makes a group with selected magnets", sprites.groupIconWhite, 0, 0));
        magnet.addButton(new Button("Up Zone", "Change a selected magnet or group to the next zone", sprites.zoneUpIconWhite, 0, 0));
        magnet.addButton(new Button("Down Zone", "Change a selected magnet or group to the previos zone", sprites.zoneDownIconWhite, 0, 0));
        magnet.addButton(new Button("Magnetization", "Change the magnet intial magnetization clockwise", sprites.magnetIconWhite, 0, 0));
        magnet.addButton(new Button("Zone View", "Toggles zone visibility with magnetization visibility", sprites.zoneViewIconWhite, 0, 0));
        magnet.addButton(new Button("Link", "Add a mimic link between selected magnets", sprites.linkIconWhite, 0, 0));
        magnet.addButton(new Button("Unlink", "Remove the mimic link from selected magnets", sprites.unlinkIconWhite, 0, 0));
        magnet.addButton(new Button("V. Flip", "Flip the selected magnets' shape vertically", sprites.verticalFlipIcon, 0, 0));
        magnet.addButton(new Button("H. Flip", "Flip the selected magnets' shape horizontally", sprites.horizontalFlipIcon, 0, 0));
        
        substrate = new HeaderContainer("Substrate", x, y);
        substrate.addButton(new Button("Grid", "Shows the ruler for the minimum cell definition", sprites.gridIconWhite, 0, 0));
        substrate.addButton(new Button("Bullet", "Shows the bullets for reference", sprites.bulletsIconWhite, 0, 0));
        substrate.addButton(new Button("Zoom In", "Zooms in the subtract", sprites.zoomInIconWhite, 0, 0));
        substrate.addButton(new Button("Zoom Out", "Zooms out of the substract", sprites.zoomOutIconWhite, 0, 0));
        substrate.addButton(new Button("Light", "Toggles the light scheme on the substract", sprites.lightIconWhite, 0, 0));
        substrate.addButton(new Button("Move", "Enables cursor to move the substract", sprites.moveIconWhite, 0, 0));
        //substrate.addButton(new Button("Display", "Toggles the display size", sprites.displaySizeIcon, 0, 0));
    }
    
    public void drawSelf(){
        float tempX, h = file.getHeight();
        textSize(fontSz+15);
        fill(45, 80, 22);
        stroke(45, 80, 22);
        rect(x, y, myW, h);
        
        image(sprites.nanocompLogo, x+myW-105, y+5);
        
        if(file.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(x, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(x, y, 5, h);
        }
        file.drawSelf();
        tempX = file.getWidth() + 10 + x;
        if(file.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(tempX-10, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(tempX-10, y, 5, h);
        }
        if(magnet.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(tempX-5, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(tempX-5, y, 5, h);
        }
        magnet.setPosition(tempX,y);
        magnet.drawSelf();
        strokeWeight(4);
        fill(255,255,255);
        stroke(255,255,255);
        line(tempX-5, y+15, tempX-5, y + h - 15);
        strokeWeight(1);
        tempX += magnet.getWidth() + 10;
        if(magnet.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(tempX-10, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(tempX-10, y, 5, h);
        }
        if(substrate.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(tempX-5, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(tempX-5, y, 5, h);
        }
        substrate.setPosition(tempX,y);
        substrate.drawSelf();
        strokeWeight(4);
        fill(255,255,255);
        stroke(255,255,255);
        line(tempX-5, y+15, tempX-5, y + h - 15);
        strokeWeight(1);
        tempX += substrate.getWidth() + 10;
        if(substrate.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(tempX-10, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(tempX-10, y, 5, h);
        }
        
        file.onMouseOverMethod();
        magnet.onMouseOverMethod();
        substrate.onMouseOverMethod();
    }
    
    public void setPanelMenu(PanelMenu panelMenu){
        this.panelMenu = panelMenu;
    }
    
    public void setSimulationBar(SimulationBar simulationBar){
        this.simulationBar = simulationBar;
    }
    
    public float getHeight(){
        return file.getHeight();
    }
    
    public boolean keyPressedMethod(){
        //File
        if(ctrlPressed && PApplet.parseInt(key) == 15){ //Open
            int dialogResult = showConfirmDialog (null, "There might be unsaved changes in the current project...\n   Are you sure you want to discard unsaved changes?", "Warning!", YES_NO_OPTION);
            if(dialogResult != YES_OPTION)
                return false;
            simulationBar.disableTimeline();
            File start = new File(sketchPath(""));
            selectFolder("Select a folder to open the project", "openProject", start);
            return true;
        }
        if(ctrlPressed && PApplet.parseInt(key) == 14){ //New
            int dialogResult = showConfirmDialog (null, "There might be unsaved changes in the current project...\n   Are you sure you want to discard unsaved changes?", "Warning!", YES_NO_OPTION);
            if(dialogResult != YES_OPTION)
                return false;
            simulationBar.disableTimeline();
            panelMenu.simPanel.reset();
            panelMenu.phasePanel.reset();
            panelMenu.zonePanel.reset();
            substrateGrid.reset();
            fileSys.setBaseName("");
        }
        if(ctrlPressed && !shiftPressed && PApplet.parseInt(key) == 19){ //Save
            if(fileSys.fileBaseName.equals("")){
                File start = new File(sketchPath(""));
                selectFolder("Select a folder to save the project", "saveAs", start);
            } else{
                saveProject();
            }
            return true;
        }
        if(ctrlPressed && shiftPressed && PApplet.parseInt(key) == 19){ //Save As
            File start = new File(sketchPath(""));
            selectFolder("Select a folder to save the project", "saveAs", start);
            return true;
        }
        
        //Magnet
        if(PApplet.parseInt(key) == 127){ //Delete
            substrateGrid.deleteSelectedMagnets();
            return true;
        }
        if(ctrlPressed && PApplet.parseInt(key) == 5){ //Edit
            substrateGrid.isEditingMagnet = true;
            panelMenu.enableEditing();
            if(!substrateGrid.isLeftHidden)
                substrateGrid.toggleHideGrid("left");
            return true;
        }
        if(ctrlPressed && PApplet.parseInt(key) == 3){ //Copy
            substrateGrid.copySelectedMagnetsToClipBoard();
            return true;
        }
        if(ctrlPressed && PApplet.parseInt(key) == 22){ //Paste
            if(substrateGrid.toPasteStructure.equals("")){
                return true;
            } else{
                if(magnet.isActive("Paste"))
                    magnet.deactiveteButton("Paste");
                else
                    magnet.activeteButton("Paste");
                substrateGrid.togglePasteState();
            }
            return true;
        }
        if(ctrlPressed && PApplet.parseInt(key) == 24){ //Cut
            substrateGrid.copySelectedMagnetsToClipBoard();
            substrateGrid.deleteSelectedMagnets();
            return true;
        }
        if(ctrlPressed && PApplet.parseInt(key) == 7){ //Group
            substrateGrid.groupSelectedMagnets();
            return true;
        }
        if(ctrlPressed && PApplet.parseInt(key) == 43){ //Zone Up
            substrateGrid.changeSelectedMagnetsZone(true);
            return true;
        }
        if(ctrlPressed && PApplet.parseInt(key) == 45){ // Zone Down
            substrateGrid.changeSelectedMagnetsZone(false);
            return true;
        }
        if(altPressed && PApplet.parseInt(key) == 109){ //Magnetization
            substrateGrid.changeSelectedMagnetsMagnetization();
            return true;
        }
        if(altPressed && PApplet.parseInt(key) == 118){ //Zone view
            substrateGrid.toggleZoneViewMode();
            if(magnet.isActive("Zone View"))
                magnet.deactiveteButton("Zone View");
            else
                magnet.activeteButton("Zone View");
            return true;
        }
        if(altPressed && PApplet.parseInt(key) == 108){ //Link
            substrateGrid.linkSelectedMagnets();
        }
        if(altPressed && PApplet.parseInt(key) == 117){ //unlink
            substrateGrid.unlinkSelectedMagnets();
        }
        if(ctrlPressed && !shiftPressed && PApplet.parseInt(key) == 6){ //H. flip
            substrateGrid.flipSelectedMagnets(false);
        }
        if(ctrlPressed && shiftPressed  && PApplet.parseInt(key) == 6){ //V. flip
            substrateGrid.flipSelectedMagnets(true);
        }
        
        //Substrate
        if(ctrlPressed && PApplet.parseInt(key) == 18){ //Ruler
            substrateGrid.isRulerActive = !substrateGrid.isRulerActive;
            if(substrateGrid.isRulerActive)
                substrate.activeteButton("Grid");
            else
                substrate.deactiveteButton("Grid");
        }
        if(ctrlPressed && PApplet.parseInt(key) == 2){ //Bullets
            substrateGrid.toggleBullet();
            if(substrate.isActive("Bullet"))
                substrate.deactiveteButton("Bullet");
            else
                substrate.activeteButton("Bullet");
        }
        if(ctrlPressed && PApplet.parseInt(key) == 12){ //Lights
            substrateGrid.isLightColor = !substrateGrid.isLightColor;
            if(!substrateGrid.isLightColor)
                substrate.activeteButton("Light");
            else
                substrate.deactiveteButton("Light");
        }
        if(ctrlPressed && PApplet.parseInt(key) == 13){ //Move
            substrateGrid.toggleMoving();
            if(substrate.isActive("Move"))
                substrate.deactiveteButton("Move");
            else
                substrate.activeteButton("Move");
        }
        
        return false;
    }
    
    public boolean mousePressedMethod(){
        String buttonLabel;
        buttonLabel = file.mousePressedMethod();
        if(buttonLabel.equals("HeaderLabel")){
            magnet.setExpanded(false);
            substrate.setExpanded(false);
            return true;
        }
        if(buttonLabel.equals("Save")){
            file.deactiveteButton("Save");
            if(fileSys.fileBaseName.equals("")){
                File start = new File(sketchPath(""));
                selectFolder("Select a folder to save the project", "saveAs", start);
            } else{
                saveProject();
            }
            return true;
        }
        if(buttonLabel.equals("Save As")){
            file.deactiveteButton("Save As");
            File start = new File(sketchPath(""));
            selectFolder("Select a folder to save the project", "saveAs", start);
            return true;
        }
        if(buttonLabel.equals("Open")){
            file.deactiveteButton("Open");
            int dialogResult = showConfirmDialog (null, "There might be unsaved changes in the current project...\n   Are you sure you want to discard unsaved changes?", "Warning!", YES_NO_OPTION);
            if(dialogResult != YES_OPTION)
                return false;
            simulationBar.disableTimeline();
            File start = new File(sketchPath(""));
            selectFolder("Select a folder to open the project", "openProject", start);
            return true;
        }
        if(buttonLabel.equals("New")){
            file.deactiveteButton("New");
            int dialogResult = showConfirmDialog (null, "There might be unsaved changes in the current project...\n   Are you sure you want to discard unsaved changes?", "Warning!", YES_NO_OPTION);
            if(dialogResult != YES_OPTION)
                return false;
            simulationBar.disableTimeline();
            panelMenu.simPanel.reset();
            panelMenu.phasePanel.reset();
            panelMenu.zonePanel.reset();
            substrateGrid.reset();
            fileSys.setBaseName("");
            return true;
        }
        buttonLabel = magnet.mousePressedMethod();
        if(buttonLabel.equals("HeaderLabel")){
            substrate.setExpanded(false);
            file.setExpanded(false);
            return true;
        }
        if(buttonLabel.equals("Delete")){
            magnet.deactiveteButton("Delete");
            substrateGrid.deleteSelectedMagnets();
            return true;
        }
        if(buttonLabel.equals("Group")){
            magnet.deactiveteButton("Group");
            substrateGrid.groupSelectedMagnets();
            return true;
        }
        if(buttonLabel.equals("Up Zone")){
            magnet.deactiveteButton("Up Zone");
            substrateGrid.changeSelectedMagnetsZone(true);
            return true;
        }
        if(buttonLabel.equals("Down Zone")){
            magnet.deactiveteButton("Down Zone");
            substrateGrid.changeSelectedMagnetsZone(false);
            return true;
        }
        if(buttonLabel.equals("Copy")){
            magnet.deactiveteButton("Copy");
            substrateGrid.copySelectedMagnetsToClipBoard();
            return true;
        }
        if(buttonLabel.equals("Paste")){
            if(substrateGrid.toPasteStructure.equals("")){
                magnet.deactiveteButton("Paste");
            } else{
                substrateGrid.togglePasteState();
            }
            return true;
        }
        if(buttonLabel.equals("Edit")){
            magnet.deactiveteButton("Edit");
            substrateGrid.isEditingMagnet = true;
            panelMenu.enableEditing();
            if(!substrateGrid.isLeftHidden)
                substrateGrid.toggleHideGrid("left");
            return true;
        }
        if(buttonLabel.equals("Cut")){
            magnet.deactiveteButton("Cut");
            substrateGrid.copySelectedMagnetsToClipBoard();
            substrateGrid.deleteSelectedMagnets();
            return true;
        }
        if(buttonLabel.equals("Magnetization")){
            magnet.deactiveteButton("Magnetization");
            substrateGrid.changeSelectedMagnetsMagnetization();
            return true;
        }
        if(buttonLabel.equals("Zone View")){
            substrateGrid.toggleZoneViewMode();
            return true;
        }
        if(buttonLabel.equals("Link")){
            magnet.deactiveteButton("Link");
            substrateGrid.linkSelectedMagnets();
            return true;
        }
        if(buttonLabel.equals("Unlink")){
            magnet.deactiveteButton("Unlink");
            substrateGrid.unlinkSelectedMagnets();
            return true;
        }
        if(buttonLabel.equals("V. Flip")){
            magnet.deactiveteButton("V. Flip");
            substrateGrid.flipSelectedMagnets(true);
            return true;
        }
        if(buttonLabel.equals("H. Flip")){
            magnet.deactiveteButton("H. Flip");
            substrateGrid.flipSelectedMagnets(false);
            return true;
        }
        buttonLabel = substrate.mousePressedMethod();
        if(buttonLabel.equals("HeaderLabel")){
            magnet.setExpanded(false);
            file.setExpanded(false);
            return true;
        }
        if(buttonLabel.equals("Grid")){
            substrateGrid.isRulerActive = !substrateGrid.isRulerActive;
            return true;
        }
        if(buttonLabel.equals("Light")){
            substrateGrid.isLightColor = !substrateGrid.isLightColor;
            return true;
        }
        if(buttonLabel.equals("Zoom In")){
            substrateGrid.zoomIn();
            substrate.deactiveteButton("Zoom In");
            return true;
        }
        if(buttonLabel.equals("Zoom Out")){
            substrateGrid.zoomOut();
            substrate.deactiveteButton("Zoom Out");
            return true;
        }
        if(buttonLabel.equals("Bullet")){
            substrateGrid.toggleBullet();
            return true;
        }
        if(buttonLabel.equals("Move")){
            substrateGrid.toggleMoving();
            return true;
        }
        if(buttonLabel.equals("Display")){
            if(scaleFactor == 1){
                surface.setSize(2560, 1440);
                scaleFactor = 2;
            } else{
                surface.setSize(1080, 720);
                scaleFactor = 1;
            }
            return true;
        }
        return false;
    }
}
class HitBox{
    private float x, y, w, h;
    
    HitBox(float xPos, float yPos, float boxWidth, float boxHeight){
        x = xPos*scaleFactor;
        y = yPos*scaleFactor;
        w = boxWidth*scaleFactor;
        h = boxHeight*scaleFactor;
    }
    
    public void updateBox(float xPos, float yPos, float boxWidth, float boxHeight){
        x = xPos*scaleFactor;
        y = yPos*scaleFactor;
        w = boxWidth*scaleFactor;
        h = boxHeight*scaleFactor;
    }
    
    public void drawSelf(){
        stroke(255, 0, 0);
        noFill();
        rect(x/scaleFactor, y/scaleFactor, w/scaleFactor, h/scaleFactor);
    }
    
    public boolean collision(float px, float py){
        return (px > x && px < (x + w) && py > y && py < (y+h));
    }
    
    public boolean collision(HitBox other){
        return (other.x+other.w > x && other.x < (x + w) && other.y+other.h > y && other.y < (y+h));
    }
}
class ListContainer{
    String label, editionField;
    float x, y, w, h;
    int maxIndex;
    boolean deleteEnabled, editEnabled, upEnabled, downEnabled;
    Scrollbar scroll;
    ArrayList<String> items;
    ArrayList<Button> delete;
    ArrayList<Button> edit;
    ArrayList<Button> up;
    ArrayList<Button> down;
    int textColor;
    
    ListContainer(String label, float x, float y, float w, float h){
        this.label = label;
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        deleteEnabled = false;
        editEnabled = false;
        upEnabled = false;
        downEnabled = false;
        editionField = "";
        items = new ArrayList<String>();
        delete = new ArrayList<Button>();
        edit = new ArrayList<Button>();
        up = new ArrayList<Button>();
        down = new ArrayList<Button>();
        maxIndex = PApplet.parseInt((h-25)/25);
        scroll = new Scrollbar(x+w-20,y,20,h,1, maxIndex,true);
        textColor = color(255,255,255);
    }
    
    public boolean isIn(String element){
        return items.contains(element);
    }
    
    public boolean hasExtraItems(ArrayList <String> options){
        for(int i=0; i<items.size(); i++)
            if(!options.contains(items.get(i)))
                return true;
        return false;
    }
    
    public void removeExtraItems(ArrayList <String> options){
        for(int i=0; i<items.size(); i++)
            if(!options.contains(items.get(i))){
                items.remove(i);
                if(deleteEnabled) delete.remove(i);
                if(editEnabled) edit.remove(i);
                if(upEnabled) up.remove(i);
                if(downEnabled) down.remove(i);
                i--;
                scroll.decreaseMaxIndex();
            }
    }
        
    public void removeItem(String option){
        for(int i=0; i<items.size(); i++)
            if(items.get(i).equals(option)){
                items.remove(i);
                if(deleteEnabled) delete.remove(i);
                if(editEnabled) edit.remove(i);
                if(upEnabled) up.remove(i);
                if(downEnabled) down.remove(i);
                scroll.decreaseMaxIndex();
                return;
            }
    }
        
    public ArrayList <String> getItems(){
        return items;
    }
    
    public void clearList(){
        items.clear();
        delete.clear();
        edit.clear();
        up.clear();
        down.clear();
        scroll.resetMaxIndex();
    }
    
    public void setPositionAndSize(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        maxIndex = PApplet.parseInt((h-25)/25);
        scroll.redefine(x+w-20,y,20,h, maxIndex);
    }
    
    public void addItem(String item){
        if(items.size() > 0)
            scroll.increaseMaxIndex();
        items.add(item);
        if(deleteEnabled)
            delete.add(new Button("Delete", "Deletes this item from the list", sprites.nanoDeleteIconWhite, 0, 0));
        if(editEnabled)
            edit.add(new Button("Edit", "Load this item from list for editing", sprites.nanoEditIconWhite, 0, 0));
        if(upEnabled)
            up.add(new Button("Up", "Raise this item one position in the list", sprites.nanoArrowUpIconWhite, 0, 0));
        if(downEnabled)
            down.add(new Button("Down", "Lower this item one position in the list", sprites.nanoArrowDownIconWhite, 0, 0));
    }
    
    public void drawSelf(){
        scroll.drawSelf();
        textSize(fontSz);
        float auxY = y+15;
        fill(textColor);
        noStroke();
        text(label, x, y+5);
        int currIndex = scroll.getIndex();
        if(currIndex >= 0){
            for(int i=0; i<maxIndex; i++){
                fill(textColor);
                noStroke();
                if(items.size() <= i+currIndex)
                    break;
                String textAux = items.get(i+currIndex);
                float space = w - 25 -((deleteEnabled)?20:0) -((editEnabled)?20:0) -((upEnabled)?20:0) -((downEnabled)?20:0);
                while(textWidth(textAux) > space)
                    textAux = textAux.substring(0, textAux.length()-1);
                textAux += " ";
                while(textWidth(textAux) < space - 10)
                    textAux += "-";
                text(textAux, x, auxY+fontSz);
                float auxX = x+w-40;
                auxY+=2;
                if(deleteEnabled){
                    delete.get(i+currIndex).setPosition(auxX, auxY);
                    auxX -= 20;
                    delete.get(i+currIndex).drawSelf();
                    delete.get(i+currIndex).onMouseOverMethod();
                }
                if(editEnabled){
                    edit.get(i+currIndex).setPosition(auxX, auxY);
                    auxX -= 20;
                    edit.get(i+currIndex).drawSelf();        
                    edit.get(i+currIndex).onMouseOverMethod();
                }
                if(downEnabled){
                    down.get(i+currIndex).setPosition(auxX, auxY);
                    auxX -= 20;
                    down.get(i+currIndex).drawSelf();                
                    down.get(i+currIndex).onMouseOverMethod();
                }
                if(upEnabled){
                    up.get(i+currIndex).setPosition(auxX, auxY);
                    auxX -= 20;
                    up.get(i+currIndex).drawSelf();                
                    up.get(i+currIndex).onMouseOverMethod();
                }
                auxY += 25;
            }
        }
    }
    
    public String getEditionField(){
        return editionField;
    }
    
    public boolean mousePressedMethod(){
        scroll.mousePressedMethod();
        int index;
        if(deleteEnabled){
            for(index=0; index<delete.size(); index++){
                if(delete.get(index).mousePressedMethod()){
                    break;
                }
            }
            if(index < delete.size()){
                scroll.decreaseMaxIndex();
                items.remove(index);
                delete.remove(index);
                if(editEnabled)
                    edit.remove(index);
                if(upEnabled)
                    up.remove(index);
                if(downEnabled)
                    down.remove(index);
                return true;
            }
        }
        if(editEnabled){
            for(index=0; index<edit.size(); index++){
                if(edit.get(index).mousePressedMethod())
                    break;
            }
            if(index < edit.size()){
                edit.get(index).deactivate();
                editionField = items.get(index);
                return true;
            } else{
                editionField = "";
            }
        }
        if(upEnabled){
            for(index=0; index<up.size(); index++){
                if(up.get(index).mousePressedMethod())
                    break;
            }
            if(index < up.size()){
                up.get(index).deactivate();
                if(index > 0){
                    String temp = items.get(index-1);
                    items.set(index-1, items.get(index));
                    items.set(index, temp);
                }
            }
        }
        if(downEnabled){
            for(index=0; index<down.size(); index++){
                if(down.get(index).mousePressedMethod())
                    break;
            }
            if(index < up.size()){
                down.get(index).deactivate();
                if(index < items.size()-1){
                    String temp = items.get(index+1);
                    items.set(index+1, items.get(index));
                    items.set(index, temp);
                }
            }
        }
        return false;
    }
    
    public void mouseDraggedMethod(){
        scroll.mouseDraggedMethod();
    }
    
    public void mouseWheelMethod(float value){
        scroll.mouseWheelMethod(value);
    }
}
class MagnetPanel{
    float x, y, w, h;
    boolean isEditing;
    
    TextBox label, behaInitMag, magWidth, magHeight, magThickness, magTopCut, magBottomCut;
    DropDownBox type, clockZone;
    VectorTextBox position, llgInitMag;
    CheckBox fixedMag;
    
    Button saveButton, saveTemplateButton, clearButton, addButton, cancelButton;
    
    int panelColor, textColor;
    ZonePanel zonePanel;
    StructurePanel structurePanel;
    SubstrateGrid substrateGrid;
    
    String editingStructure, oldName;

    public MagnetPanel(float x, float y, float w, float h, ZonePanel zp, StructurePanel sp){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        zonePanel = zp;
        structurePanel = sp;
        
        label = new TextBox("Mag. or Stru. Label", x, y, w-20);
        label.setValidationType("String");
        
        behaInitMag = new TextBox("Initial Mag.", x, y, w-20);
        behaInitMag.setValidationType("Float");
        behaInitMag.setText("0");
        
        magWidth = new TextBox("Width (nm)", x, y, w-20);
        magWidth.setValidationType("FloatPos");
        magWidth.setText("50");
        
        magHeight = new TextBox("Height (nm)", x, y, w-20);
        magHeight.setValidationType("FloatPos");
        magHeight.setText("100");
        
        magThickness = new TextBox("Thickness (nm)", x, y, w-20);
        magThickness.setValidationType("FloatPos");
        magThickness.setText("15");
        
        magTopCut = new TextBox("Top Cut (nm)", x, y, w-20);
        magTopCut.setValidationType("Float");
        magTopCut.setText("0");
        
        magBottomCut = new TextBox("Bottom Cut (nm)", x, y, w-20);
        magBottomCut.setValidationType("Float");
        magBottomCut.setText("0");        
        
        type = new DropDownBox("Magnet Type", x, y, w-20);
        type.addOption("input");
        type.addOption("regular");
        type.addOption("output");
        
        clockZone = new DropDownBox("Clock Zone", x, y, w-20);
        
        position = new VectorTextBox("Position (nm)", x, y, w-20, 2);
        position.setValidationType("FloatPos");
        
        llgInitMag = new VectorTextBox("Initial Mag.(x, y, z)", x, y, w-20, 3);
        llgInitMag.setValidationType("Float");
        llgInitMag.setText(".141,0.99,0");
        
        fixedMag = new CheckBox("No Field Effect", x, y, w-20);
        
        panelColor = color(45, 80, 22);
        textColor = color(255,255,255);
        
        isEditing = false;
        
        saveButton = new Button("Save", "Save the changes in the current magnet", sprites.smallSaveIconWhite, x+w-30, y+h-30);
        cancelButton = new Button("Cancel", "Cancel the changes made in the current magnet", sprites.cancelIconWhite, x+w-80, y+h-30);
        saveTemplateButton = new Button("Save Template", "Save the configuration as a new template", sprites.smallSaveTemplateIconWhite, x+w-30, y+h-30);
        clearButton = new Button("Clear", "Clear all fields", sprites.smallDeleteIconWhite, x+w-55, y+h-30);
        addButton = new Button("Add", "Adds the magnet directly to the grid", sprites.smallNewIconWhite, x+w-80, y+h-30);
    }
    
    public void updateZones(){
        ArrayList <String> zoneNames = zonePanel.getZoneNames();
        clockZone.removeAllOptions();
        for(int i=0; i<zoneNames.size(); i++){
            clockZone.addOption(zoneNames.get(i));
        }
    }
    
    public void drawSelf(){
        textSize(fontSz+5);
        fill(panelColor);
        stroke(panelColor);
        rect(x, y, w, h, 0, 15, 0, 0);
        fill(textColor);
        noStroke();
        float aux = textAscent()+textDescent(), auxY;
        String txt = "Magnet Panel";
        auxY = y;
        text(txt, x+(w-textWidth(txt))/2, auxY+aux);
        auxY += aux+10;
        textSize(fontSz);
        aux = textAscent()+textDescent();
        text("Configuration", x+10, auxY+aux);
        auxY += aux+5;
        
        label.setPosition(x+10, auxY);
        auxY += aux+5;
        type.updatePosition(x+10, auxY);
        auxY += aux+5;
        clockZone.updatePosition(x+10, auxY);
        auxY += aux+5;

        strokeWeight(4);
        stroke(color(255,255,255));
        auxY += 3;
        line(x+10, auxY, x+w-10, auxY);
        auxY += 3;
        noStroke();
        strokeWeight(1);

        text("Magnetization", x+10, auxY+aux);
        auxY += aux+5;
        
        if(zonePanel.getEngine().equals("LLG")){
            llgInitMag.updatePosition(x+10, auxY);
        } else {
            behaInitMag.updatePosition(x+10, auxY);
        }
        auxY += aux+5;

        fixedMag.updatePosition(x+10, auxY);
        auxY += aux+5;

        strokeWeight(4);
        stroke(color(255,255,255));
        auxY += 3;
        line(x+10, auxY, x+w-10, auxY);
        auxY += 3;
        noStroke();
        strokeWeight(1);

        text("Geometry", x+10, auxY+aux);
        auxY += aux+5;
        
        magWidth.updatePosition(x+10,auxY);
        auxY += aux+5;
        magHeight.updatePosition(x+10, auxY);
        auxY += aux+5;
        magThickness.updatePosition(x+10, auxY);
        auxY += aux+5;
        magTopCut.updatePosition(x+10, auxY);
        auxY += aux+5;
        magBottomCut.updatePosition(x+10, auxY);
        auxY += aux+5;
        position.updatePosition(x+10,auxY);
        auxY += aux+5;
        
        strokeWeight(4);
        stroke(color(255,255,255));
        auxY += 3;
        line(x+10, auxY, x+w-10, auxY);
        auxY += 3;
        noStroke();
        strokeWeight(1);

        text("Shape Preview", x+10, auxY+aux);
        auxY += aux+5;
        
        if(magBottomCut.validateText() && magHeight.validateText() && magThickness.validateText() && magTopCut.validateText() && magWidth.validateText()){
            float vSpaceLeft = (h-(auxY-y)-10);
            float hSpaceLeft = (isEditing)?(w-100):(w-75);
            float scale;
            float mh = Float.parseFloat(magHeight.getText());
            float mw = Float.parseFloat(magWidth.getText());
            if(vSpaceLeft/mh < hSpaceLeft/mw)
                scale = vSpaceLeft/mh;
            else
                scale = hSpaceLeft/mw;
            mh *= scale;
            mw *= scale;
            float mbc = Float.parseFloat(magBottomCut.getText())*scale;
            float mtc = Float.parseFloat(magTopCut.getText())*scale;
            fill(255,255,255);
            stroke(255,255,255);
            beginShape();
            if(mtc >= 0){
                vertex(x+10,auxY);
                vertex(x+10+mw,auxY+mtc);
            } else{
                vertex(x+10,auxY-mtc);
                vertex(x+10+mw,auxY);
            }
            if(mbc >= 0){
                vertex(x+10+mw,auxY+mh-mbc);
                vertex(x+10,auxY+mh);
            } else{
                vertex(x+10+mw,auxY+mh);
                vertex(x+10,auxY+mh+mbc);
            }
            endShape();
        }
        
        if(isEditing){
            saveButton.isTransparent = !((zonePanel.getEngine().equals("LLG")?llgInitMag.validateText():behaInitMag.validateText()) && label.validateText() &&
                                        magBottomCut.validateText() && magHeight.validateText() && magThickness.validateText() && magTopCut.validateText() && magWidth.validateText());
            saveButton.drawSelf();
            cancelButton.drawSelf();
        }
        if(!isEditing){
            saveTemplateButton.isTransparent = !validateAllFields();
            saveTemplateButton.drawSelf();
        }
        clearButton.drawSelf();
        if(!isEditing){
            addButton.isTransparent = !validateAllFields();
            addButton.drawSelf();
        }
        magWidth.drawSelf();
        magHeight.drawSelf();
        magThickness.drawSelf();
        magTopCut.drawSelf();
        magBottomCut.drawSelf();
        position.drawSelf();
        fixedMag.drawSelf();
        if(zonePanel.getEngine().equals("LLG"))
            llgInitMag.drawSelf();
        else
            behaInitMag.drawSelf();
        clockZone.drawSelf();
        type.drawSelf();
        label.drawSelf();
        if(isEditing){
            saveButton.onMouseOverMethod();
            cancelButton.onMouseOverMethod();
        }
        if(!isEditing)
            saveTemplateButton.onMouseOverMethod();
        clearButton.onMouseOverMethod();
        if(!isEditing)
            addButton.onMouseOverMethod();
    }
    
    public void setEditing(String structure, String name){
        if(structure.contains(":") || structure.equals("")){
            isEditing = false;
            substrateGrid.isEditingMagnet = false;
            return;
        }
        //type;clockZone;magnetization;fixed;w;h;tc;bc;position;zoneColor
        editingStructure = structure;
        String fields[] = structure.split(";");
        type.setSelectedOption(fields[0]);
        clockZone.setSelectedOption(fields[1]);
        fixedMag.isChecked = fields[3].equals("true");
        if(zonePanel.getEngine().equals("LLG")){
            llgInitMag.setText(fields[2]);
        } else{
            behaInitMag.setText(fields[2]);
        }
        magWidth.setText(fields[4]);
        magHeight.setText(fields[5]);
        magThickness.setText(fields[6]);
        magTopCut.setText(fields[7]);
        magBottomCut.setText(fields[8]);
        position.setText(fields[9]);
        label.setText(name);
        oldName = name;
    }
    
    public boolean validateAllFields(){
        boolean valid = true;
        valid = valid & label.validateText();
        valid = valid & !type.getSelectedOption().equals("");
        valid = valid & !clockZone.getSelectedOption().equals("");
        if(zonePanel.getEngine().equals("LLG")){
            valid = valid & llgInitMag.validateText();
        } else{
            valid = valid & behaInitMag.validateText();
        }
        valid = valid & magBottomCut.validateText();
        valid = valid & magHeight.validateText();
        valid = valid & magThickness.validateText();
        valid = valid & magTopCut.validateText();
        valid = valid & magWidth.validateText();
        valid = valid & position.validateText();
        return valid;
    }
    
    public String getValue(boolean toStructure){
        String value = "";
        if(!toStructure)
            value += label.getText() + ";";
        value += type.getSelectedOption() + ";";
        value += clockZone.getSelectedOption() + ";";
        if(zonePanel.getEngine().equals("LLG")){
            value += llgInitMag.getText() + ";";
        } else{
            value += behaInitMag.getText() + ";";
        }
        value += fixedMag.isChecked + ";";
        value += magWidth.getText() + ";";
        value += magHeight.getText() + ";";
        value += magThickness.getText() + ";";
        value += magTopCut.getText() + ";";
        value += magBottomCut.getText() + ";";
        value += position.getText() + ";";
        value += zonePanel.getZoneColor(clockZone.getSelectedOption());
        return value;
    }
    
    public void setSubstrateGrid(SubstrateGrid sg){
        substrateGrid = sg;
    }
    
    public void mousePressedMethod(){
        if(!isEditing && saveTemplateButton.mousePressedMethod() && validateAllFields()){
            saveTemplateButton.deactivate();
            structurePanel.addStructure(label.getText(), getValue(true));
        }
        saveTemplateButton.deactivate();
        label.mousePressedMethod();
        type.mousePressedMethod();
        clockZone.mousePressedMethod();
        if(zonePanel.getEngine().equals("LLG")){
            llgInitMag.mousePressedMethod();
        } else{
            behaInitMag.mousePressedMethod();
        }
        fixedMag.mousePressedMethod();
        magBottomCut.mousePressedMethod();
        magHeight.mousePressedMethod();
        magThickness.mousePressedMethod();
        magTopCut.mousePressedMethod();
        magWidth.mousePressedMethod();
        position.mousePressedMethod();
        if(!isEditing && addButton.mousePressedMethod()){
            addButton.deactivate();
            if(validateAllFields()){
                String parts[] = position.getText().split(",");
                if(Float.parseFloat(parts[0]) < Float.parseFloat(magWidth.getText())/2 || Float.parseFloat(parts[1]) < Float.parseFloat(magHeight.getText())/2){
                    return;
                }
                substrateGrid.addMagnet(label.getText(), getValue(true));
            }
        }
        if(isEditing && cancelButton.mousePressedMethod()){
            cancelButton.deactivate();
            isEditing = false;
            substrateGrid.unselectMagnets();
            substrateGrid.isEditingMagnet = false;
        }
        if(clearButton.mousePressedMethod()){
            clearButton.deactivate();
            int dialogResult = showConfirmDialog (null, "Are you sure you want to clear ALL fields in this panel?", "Warning!", YES_NO_OPTION);
            if(dialogResult != YES_OPTION)
                return;
            label.resetText();
            label.validateText();
            type.resetOption();
            clockZone.resetOption();
            if(zonePanel.getEngine().equals("LLG")){
                llgInitMag.resetText();
                llgInitMag.validateText();
            }
            else{
                behaInitMag.resetText();
                behaInitMag.validateText();
            }
            fixedMag.isChecked = false;
            magBottomCut.resetText();
            magBottomCut.validateText();
            magHeight.resetText();
            magHeight.validateText();
            magThickness.resetText();
            magThickness.validateText();
            magTopCut.resetText();
            magTopCut.validateText();
            magWidth.resetText();
            magWidth.validateText();
            position.resetText();
            position.validateText();
        }
        if(isEditing && saveButton.mousePressedMethod()){
            saveButton.deactivate();
            //type;clockZone;magnetization;fixed;w;h;tc;bc;position;zoneColor
            String parts[] = editingStructure.split(";");
            editingStructure = label.getText() + ";";
            if(!type.getSelectedOption().equals("")){
                parts[0] = type.getSelectedOption();
            }
            if(!clockZone.getSelectedOption().equals("")){
                parts[1] = clockZone.getSelectedOption();
            }
            if(zonePanel.getEngine().equals("LLG")){
                parts[2] = llgInitMag.getText();
            } else{
                parts[2] = behaInitMag.getText();
            }
            parts[3] = (fixedMag.isChecked)?"true":"false";
            parts[4] = magWidth.getText();
            parts[5] = magHeight.getText();
            parts[6] = magThickness.getText();
            parts[7] = magTopCut.getText();
            parts[8] = magBottomCut.getText();
            parts[9] = position.getText();
            parts[10] = zonePanel.getZoneColor(parts[1]).toString();
            for(int i=0; i<parts.length; i++)
                editingStructure += parts[i] + ";";
            substrateGrid.editSelectedMagnets(editingStructure, oldName);
            substrateGrid.isEditingMagnet = false;
            isEditing = false;
            
            PopUp pop = new PopUp((width-250)/2, (height-50)/2, 250, 50, "Magnet modifications saved!");
            pop.activate();
            pop.setAsTimer(60);
            popCenter.setPopUp(pop);
        }
    }
    
    public void keyPressedMethod(){
        if(label.keyPressedMethod() && (key == ENTER || key == TAB)){
            if(zonePanel.getEngine().equals("LLG")){
                llgInitMag.select();
            } else{
                behaInitMag.select();
            }
            return;
        }
        if(zonePanel.getEngine().equals("LLG")){
            if(llgInitMag.keyPressedMethod() && (key == ENTER || key == TAB)){
                if(!llgInitMag.isSelected()){
                    magWidth.select();
                    return;
                }
            }
        } else{
            if(behaInitMag.keyPressedMethod() && (key == ENTER || key == TAB)){
                magWidth.select();
                return;
            }
        }
        if(magWidth.keyPressedMethod() && (key == ENTER || key == TAB)){
            magHeight.select();
            return;
        }
        if(magHeight.keyPressedMethod() && (key == ENTER || key == TAB)){
            magThickness.select();
            return;
        }
        if(magThickness.keyPressedMethod() && (key == ENTER || key == TAB)){
            magTopCut.select();
            return;
        }
        if(magTopCut.keyPressedMethod() && (key == ENTER || key == TAB)){
            magBottomCut.select();
            return;
        }
        if(magBottomCut.keyPressedMethod() && (key == ENTER || key == TAB)){
            position.select();
            return;
        }
        if(position.keyPressedMethod() && (key == ENTER || key == TAB)){
            if(!position.isSelected()){
                if(!isEditing)
                    label.select();
                else if (zonePanel.getEngine().equals("LLG"))
                    llgInitMag.select();
                else
                    behaInitMag.select();
            }
            return;
        }
    }
}
class PanelMenu{
    float x, y, panelW, panelH;
    SimulationPanel simPanel;
    PhasePanel phasePanel;
    ZonePanel zonePanel;
    MagnetPanel magnetPanel;
    StructurePanel structurePanel;
    ResultsPanel resultsPanel;
    ArrayList<String> labels;
    ArrayList<HitBox> hitboxes;
    int selectedPanel;
    int selectedColor, normalColor, textColor, lineColor;
    boolean structurePanelActive;
    HitBox structureLabelHitbox;
    SubstrateGrid substrateGrid;
    String subProperty = "";
    
    PanelMenu(float x, float y, float pw, float ph, SubstrateGrid sg){
        this.x = x;
        this.y = y;
        panelH = ph;
        panelW = pw;
        substrateGrid = sg;
        
        textSize(fontSz);
        float auxX = x+5, h = textAscent()+textDescent(), auxW;
        labels = new ArrayList<String>();
        hitboxes = new ArrayList<HitBox>();
        labels.add("Simulation");
        auxW = textWidth("Simulation");
        hitboxes.add(new HitBox(auxX, y, auxW, h));
        auxX += auxW+10;
        labels.add("Phases");
        auxW = textWidth("Phases");
        hitboxes.add(new HitBox(auxX, y, auxW, h));
        auxX += auxW+10;
        labels.add("Zones");
        auxW = textWidth("Zones");
        hitboxes.add(new HitBox(auxX, y, auxW, h));
        auxX += auxW+10;
        labels.add("Magnet");
        auxW = textWidth("Magnet");
        hitboxes.add(new HitBox(auxX, y, auxW, h));
        auxX += auxW+10;
        labels.add("Results");
        auxW = textWidth("Results");
        hitboxes.add(new HitBox(auxX, y, auxW, h));
        auxX += auxW+10;
        
        textColor = color(255,255,255);
        lineColor = color(255,255,255);
        normalColor = color(212,85,0);
        selectedColor = color(45,80,22);
        
        selectedPanel = -1;
        
        structurePanelActive = false;
        structurePanel = new StructurePanel(width/scaleFactor-pw/2-23, y-ph, pw/2, ph);
        substrateGrid.setStructurePanel(structurePanel);
        structurePanel.setSubstrateGrid(substrateGrid);
        simPanel = new SimulationPanel(x, y-ph, pw, ph);
        phasePanel = new PhasePanel(x, y-ph, pw, ph, simPanel);
        zonePanel = new ZonePanel(x, y-ph, pw, ph, phasePanel);
        phasePanel.setZonePanel(zonePanel);
        simPanel.setZonePanel(zonePanel);
        zonePanel.setSubstrateGrid(substrateGrid);
        substrateGrid.setZonePanel(zonePanel);
        magnetPanel = new MagnetPanel(x, y-ph, pw, ph, zonePanel, structurePanel);
        magnetPanel.setSubstrateGrid(substrateGrid);
        resultsPanel = new ResultsPanel(x, y-ph, pw, ph);
        resultsPanel.setSubstrateGrid(substrateGrid);
        
        structureLabelHitbox = new HitBox(width/scaleFactor-textWidth("Structures")-33, y, textWidth("Structures")+10, textAscent()+textDescent());
    }
    
    public void loadStructures(ArrayList<String> structures){
        structurePanel.loadStructures(structures);
    }

    public void importStructureFile(ArrayList<String> structures){
        structurePanel.importStructures(structures);
    }
    
    public ArrayList<String> getStructures(){
        structurePanel.loadStructures(structurePanel.getStructures());
        return structurePanel.getStructures();
    }
    
    public ArrayList<String> getZoneProperties(){
        return zonePanel.getZoneProperties();
    }
    
    public String getCircuitProperties(){
        return simPanel.getProperties();
    }
    
    public Float getReportStep(){
        return Float.parseFloat(simPanel.getReportStep());
    }
    
    public String getSimulationMode(){
        return simPanel.getSimulationMode();
    }
    
    public ArrayList<String> getPhaseProperties(){
        return phasePanel.getPhaseProperties();
    }
    
    public void enableEditing(){
        magnetPanel.isEditing = true;
        magnetPanel.setEditing(substrateGrid.getSelectedStructure(), substrateGrid.getSelectedMagnetsNames());
        selectedPanel = 3;
    }
        
    public void drawSelf(){
        float h = textAscent()+textDescent(), auxX = x+5;
        textSize(fontSz);
        fill(normalColor);
        stroke(normalColor);
        rect(x, y, width/scaleFactor, h);

        stroke(lineColor);
        strokeWeight(2);
        line(x, y+1, width/scaleFactor, y+1);
        strokeWeight(1);
        
        fill(textColor);
        noStroke();
        for(int i=0; i<labels.size(); i++){
            if(i == selectedPanel){
                fill(selectedColor);
                stroke(selectedColor);
                if(i==0)
                    rect(auxX-5, y, textWidth(labels.get(i)) + 7.5f, h);
                else
                    rect(auxX-4, y, textWidth(labels.get(i)) + 7.5f, h);
                fill(textColor);
                noStroke();
            }
            text(labels.get(i), auxX, y+fontSz);
            hitboxes.get(i).updateBox(auxX, y, textWidth(labels.get(i)), h);

            stroke(lineColor);
            strokeWeight(2);
            line(auxX+4+textWidth(labels.get(i)), y+1, auxX+4+textWidth(labels.get(i)), y+h-2);
            strokeWeight(1);
            noStroke();

            auxX += textWidth(labels.get(i))+10;
        }
        
        fill(textColor);
        noStroke();
        if(structurePanelActive){
            fill(selectedColor);
            stroke(selectedColor);
            rect(width/scaleFactor-textWidth("Structures")-33, y, textWidth("Structures")+10, h);
        }
        
        stroke(lineColor);
        strokeWeight(2);
        line(width/scaleFactor-23, y+1, width/scaleFactor-23, y+h-2);
        strokeWeight(1);

        noStroke();
        fill(textColor);
        text("Structures", width/scaleFactor-textWidth("Structures")-28, y+fontSz);
        structureLabelHitbox.updateBox(width/scaleFactor-textWidth("Structures")-28, y,textWidth("Structures"), h);
        stroke(lineColor);
        strokeWeight(2);
        line(width/scaleFactor-textWidth("Structures")-33, y+1, width/scaleFactor-textWidth("Structures")-33, y+h-2);
        strokeWeight(1);
        noStroke();
        
        if(structurePanelActive)
            structurePanel.drawSelf();
        
        switch(selectedPanel){
            case 0:
                simPanel.drawSelf();
            break;
            case 1:
                phasePanel.drawSelf();
            break;
            case 2:
                zonePanel.drawSelf();
            break;
            case 3:
                magnetPanel.drawSelf();
            break;
            case 4:
                resultsPanel.drawSelf();
            break;
            default:{}
        }
        
        if(!simPanel.getGridProperties().equals("") && !simPanel.getGridProperties().equals(subProperty)){
            subProperty = simPanel.getGridProperties();
            String parts[] = subProperty.split(",");
            substrateGrid.setGridSizes(Float.parseFloat(parts[0]), Float.parseFloat(parts[1]), Float.parseFloat(parts[2]), Float.parseFloat(parts[3]));
            substrateGrid.setBulletSpacing(Float.parseFloat(parts[4]), Float.parseFloat(parts[5]));
        }
    }
    
    public void mousePressedMethod(){
        if(structureLabelHitbox.collision(mouseX,mouseY)){
            structurePanelActive = !structurePanelActive;
            substrateGrid.toggleHideGrid("right");
        }
        int i;
        for(i=0; i<hitboxes.size(); i++){
            if(hitboxes.get(i).collision(mouseX, mouseY))
                break;
        }
        if(i == selectedPanel){
            selectedPanel = -1;
            substrateGrid.toggleHideGrid("left");
        }
        else if(!(i >= hitboxes.size())){
            selectedPanel = i;
            if(!substrateGrid.isLeftHidden)
                substrateGrid.toggleHideGrid("left");
        }
        
        if(i == 2)
            zonePanel.updatePhases();
        if(i == 3)
            magnetPanel.updateZones();
        
        structurePanel.mousePressedMethod();
        
        switch(selectedPanel){
            case 0:
                simPanel.mousePressedMethod();
            break;
            case 1:
                phasePanel.mousePressedMethod();
            break;
            case 2:
                zonePanel.mousePressedMethod();
            break;
            case 3:
                magnetPanel.mousePressedMethod();
            break;
            case 4:
                resultsPanel.mousePressedMethod();
            default:{}
        }
    }
    
    public void mouseWheelMethod(float v){
        structurePanel.mouseWheelMethod(v);
        switch(selectedPanel){
            case 1:
                phasePanel.mouseWheelMethod(v);
            break;
            case 2:
                zonePanel.mouseWheelMethod(v);
            break;
            default:{}
        }
    }
    
    public void mouseDraggedMethod(){
        structurePanel.mouseDraggedMethod();
        switch(selectedPanel){
            case 1:
                phasePanel.mouseDraggedMethod();
            break;
            case 2:
                zonePanel.mouseDraggedMethod();
            break;
            default:{}
        }
    }
    
    public void keyPressedMethod(){
        structurePanel.keyPressedMethod();
        switch(selectedPanel){
            case 0:
                simPanel.keyPressedMethod();
            break;
            case 1:
                phasePanel.keyPressedMethod();
            break;
            case 2:
                zonePanel.keyPressedMethod();
            break;
            case 3:
                magnetPanel.keyPressedMethod();
            break;
            case 4:
                resultsPanel.keyPressedMethod();
            break;
            default:{}
        }
    }
}
class PhasePanel{
    float x, y, w, h;
    TextBox name, duration, initialBeha, endBeha;
    VectorTextBox initialField, endField, initialCurr, endCurr;
    Button saveButton, newButton, clearButton;
    int panelColor, textColor;
    SimulationPanel sp;
    ListContainer llgPhases, behaPhases;
    HashMap<String, String> llgPhaseValues, behaPhaseValues;
    Chart preview;
    ZonePanel zonePanel;

    PhasePanel(float x, float y, float w, float h, SimulationPanel sp){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.sp = sp;
        textSize(fontSz);
        panelColor = color(45, 80, 22);
        textColor = color(255,255,255);
        
        llgPhaseValues = new HashMap<String, String>();
        behaPhaseValues = new HashMap<String, String>();
        
        name = new TextBox("Name", 0, 0, w-20);
        name.setValidationType("String");
        
        initialField = new VectorTextBox("Init. Field (x,y,z)", 0, 0, w-20, 3);
        initialField.setValidationType("Float");
        initialField.setText("0,0,0");

        endField = new VectorTextBox("End Field (x,y,z)", 0, 0, w-20, 3);
        endField.setValidationType("Float");
        endField.setText("0,0,0");

        initialCurr = new VectorTextBox("Init. Curr. (x,y,z)", 0, 0, w-20, 3);
        initialCurr.setValidationType("Float");
        initialCurr.setText("0,0,0");

        endCurr = new VectorTextBox("End Curr. (x,y,z)", 0, 0, w-20, 3);
        endCurr.setValidationType("Float");
        endCurr.setText("0,0,0");
        
        duration = new TextBox("Duration", 0, 0, w-20);
        duration.setValidationType("FloatPos");
        
        initialBeha = new TextBox("Init. Sig.", 0, 0, w-20);
        initialBeha.setValidationType("Float");
        
        endBeha = new TextBox("End Sig.", 0, 0, w-20);
        endBeha.setValidationType("Float");
        
        saveButton = new Button("Save", "Saves the changes made on the phase", sprites.smallSaveIconWhite, 0, 0);
        newButton = new Button("New", "Adds the configuration as a new phase", sprites.smallNewIconWhite, 0, 0);        
        clearButton = new Button("Clear", "Clear ALL texts in the boxes", sprites.smallDeleteIconWhite, 0, 0);
        
        llgPhases = new ListContainer("All Phases", 0, 0, w, h);
        llgPhases.deleteEnabled = true;
        llgPhases.editEnabled = true;
        
        behaPhases = new ListContainer("All Phases", 0, 0, w, h);
        behaPhases.deleteEnabled = true;
        behaPhases.editEnabled = true;
    }
    
    public void setZonePanel(ZonePanel zonePanel){
        this.zonePanel = zonePanel;
    }
        
    public void drawSelf(){
        textSize(fontSz+5);
        fill(panelColor);
        stroke(panelColor);
        rect(x, y, w, h, 0, 15, 0, 0);
        fill(textColor);
        noStroke();
        float aux = textAscent()+textDescent(), auxY;
        String txt = "Phase Panel";
        auxY = y;
        text(txt, x+(w-textWidth(txt))/2, auxY+aux);
        auxY += aux+10;
        textSize(fontSz);
        aux = textAscent()+textDescent();
        text("Configuration", x+10, auxY+aux);
        auxY += aux+5;
        
        name.updatePosition(x+10, auxY);
        auxY += aux+5;
        if(sp.getEngine().equals("LLG")){
            initialField.updatePosition(x+10,auxY);
            auxY += aux+5;
            endField.updatePosition(x+10,auxY);
            auxY += aux+5;
            initialCurr.updatePosition(x+10,auxY);
            auxY += aux+5;
            endCurr.updatePosition(x+10,auxY);
            auxY += aux+5;
        } else{
            initialBeha.updatePosition(x+10,auxY);
            auxY += aux+5;
            endBeha.updatePosition(x+10,auxY);
            auxY += aux+5;
        }
        duration.updatePosition(x+10,auxY);
        auxY += aux+5;
        
        if(name.validateText()){
            if(sp.getEngine().equals("LLG") && llgPhases.isIn(name.getText())){
                saveButton.isTransparent = (!validateAllFields());
                saveButton.setPosition(x+w-30,auxY);
                saveButton.drawSelf();
                newButton.isValid = false;
                saveButton.isValid = true;
            } else if(!sp.getEngine().equals("LLG") && behaPhases.isIn(name.getText())){
                saveButton.isTransparent = (!validateAllFields());
                saveButton.setPosition(x+w-30,auxY);
                saveButton.drawSelf();
                newButton.isValid = false;
                saveButton.isValid = true;
            } else{
                newButton.isTransparent = (!validateAllFields());
                newButton.setPosition(x+w-30,auxY);
                newButton.drawSelf();
                newButton.isValid = true;
                saveButton.isValid = false;
            }
        } else{
            newButton.isTransparent = (!validateAllFields());
            newButton.setPosition(x+w-30,auxY);
            newButton.drawSelf();
            newButton.isValid = true;
            saveButton.isValid = false;
        }
        clearButton.setPosition(x+w-60,auxY);
        clearButton.drawSelf();
        clearButton.isValid = true;
        auxY += 25;
        
        duration.drawSelf();
        if(sp.getEngine().equals("LLG")){
            endCurr.drawSelf();
            endCurr.isActive = true;
            initialCurr.drawSelf();
            initialCurr.isActive = true;
            endField.drawSelf();
            endField.isActive = true;
            initialField.drawSelf();
            initialField.isActive = true;
            endBeha.isActive = false;
            initialBeha.isActive = false;
        } else{
            endCurr.isActive = false;
            initialCurr.isActive = false;
            endField.isActive = false;
            initialField.isActive = false;
            endBeha.drawSelf();
            initialBeha.drawSelf();
            endBeha.isActive = true;
            initialBeha.isActive = true;
        }
        name.drawSelf();
        
        strokeWeight(4);
        stroke(color(255,255,255));
        line(x+10, auxY, x+w-10, auxY);
        auxY += 20;
        noStroke();
        strokeWeight(1);
        
        if(sp.getEngine().equals("LLG")){
            llgPhases.setPositionAndSize(x+10,auxY,w-20,h-(auxY-y)-150);
            llgPhases.drawSelf();
        } else{
            behaPhases.setPositionAndSize(x+10,auxY,w-20,h-(auxY-y)-150);
            behaPhases.drawSelf();
        }
        
        auxY += h-(auxY-y)-150 + 5;
        
        strokeWeight(4);
        stroke(color(255,255,255));
        line(x+10, auxY, x+w-10, auxY);
        auxY += 10;
        noStroke();
        strokeWeight(1);
        
        fill(textColor);
        text("Phase Preview", x+10, auxY+fontSz);
        auxY += aux+5;
        
        float spaceLeft = (h-5-(auxY-y));
        preview = new Chart(x+10, auxY, w-20, spaceLeft);
        if(duration.validateText()){
            if(sp.getEngine().equals("LLG")){
                if(initialField.validateText() && endField.validateText()){
                    String [] initData = initialField.getText().split(",");
                    String [] endData = endField.getText().split(",");
                    preview.addSeires("External Field X",
                            new float[][]{
                                {0,Float.parseFloat(initData[0])},
                                {Float.parseFloat(duration.getText()),Float.parseFloat(endData[0])}
                                },
                            color(0,0,255));
                    preview.addSeires("External Field Y",
                            new float[][]{
                                {0,Float.parseFloat(initData[1])},
                                {Float.parseFloat(duration.getText()),Float.parseFloat(endData[1])}
                                },
                            color(255,0,0));
                    preview.addSeires("External Field Z",
                            new float[][]{
                                {0,Float.parseFloat(initData[2])},
                                {Float.parseFloat(duration.getText()),Float.parseFloat(endData[2])}
                                },
                            color(255,255,0));
                }
                if(initialCurr.validateText() && endCurr.validateText()){
                    String [] initData = initialCurr.getText().split(",");
                    String [] endData = endCurr.getText().split(",");
                    preview.addSeires("Current Field X",
                            new float[][]{
                                {0,Float.parseFloat(initData[0])},
                                {Float.parseFloat(duration.getText()),Float.parseFloat(endData[0])}
                                },
                            color(0xff000080));
                    preview.addSeires("Current Field Y",
                            new float[][]{
                                {0,Float.parseFloat(initData[1])},
                                {Float.parseFloat(duration.getText()),Float.parseFloat(endData[1])}
                                },
                            color(0xff800000));
                    preview.addSeires("Current Field Z",
                            new float[][]{
                                {0,Float.parseFloat(initData[2])},
                                {Float.parseFloat(duration.getText()),Float.parseFloat(endData[2])}
                                },
                            color(0xffD4AA00));
                }
            } else{
                if(initialBeha.validateText() && endBeha.validateText()){
                    preview.addSeires("Clock Field",
                            new float[][]{
                                {0,Float.parseFloat(initialBeha.getText())},
                                {Float.parseFloat(duration.getText()),Float.parseFloat(endBeha.getText())}
                                },
                            color(255,0,0));
                }
            }
        }
        preview.drawSelf();
        onMouseOverMethod();
    }
    
    public void reset(){
        name.setText("");
        duration.setText("");
        initialBeha.setText("");
        endBeha.setText("");
        initialField.setText("0,0,0");
        endField.setText("0,0,0");
        initialCurr.setText("0,0,0");
        endCurr.setText("0,0,0");
        llgPhases.clearList();
        behaPhases.clearList();
        llgPhaseValues.clear();
        behaPhaseValues.clear();        
    }
    
    public void loadPhaseProperties(ArrayList<String> properties){
        reset();
        for(String phase : properties){
            String name = phase.substring(0, phase.indexOf(";"));
            if(sp.getEngine().equals("LLG")){
                if(!llgPhases.isIn(name)){
                    llgPhases.addItem(name);
                    llgPhaseValues.put(name, phase);
                }
            } else{
                behaPhases.addItem(name);
                behaPhaseValues.put(name, phase);
            }
        }
    }
    
    public ArrayList<String> getPhaseProperties(){
        ArrayList<String> properties = new ArrayList<String>();
        if(sp.getEngine().equals("LLG")){
            for(String name : llgPhases.getItems()){
                properties.add(llgPhaseValues.get(name));
            }
        } else{
            for(String name : behaPhases.getItems()){
                properties.add(behaPhaseValues.get(name));
            }
        }
        return properties;
    }
    
    public ArrayList<String> getPhasesNames(){
        if(sp.getEngine().equals("LLG"))
            return llgPhases.getItems();
        return behaPhases.getItems();
    }
    
    public String getEngine(){
        return sp.getEngine();
    }
    
    public String getPhaseInfo(String phaseName){
        if(sp.getEngine().equals("LLG"))
            return llgPhaseValues.get(phaseName);
        return behaPhaseValues.get(phaseName);
    }
    
    public void onMouseOverMethod(){
        saveButton.onMouseOverMethod();
        newButton.onMouseOverMethod();
        clearButton.onMouseOverMethod();
    }
        
    public void mouseDraggedMethod(){
        if(sp.getEngine().equals("LLG"))
            llgPhases.mouseDraggedMethod();
        else
            behaPhases.mouseDraggedMethod();
    }
    
    public void mouseWheelMethod(float value){
        if(sp.getEngine().equals("LLG"))
            llgPhases.mouseDraggedMethod();
        else
            behaPhases.mouseWheelMethod(value);
    }
    
    public boolean validateAllFields(){
        boolean invalid = false;
        invalid = invalid | !name.validateText();
        invalid = invalid | !duration.validateText();
        if(sp.getEngine().equals("LLG")){
            invalid = invalid | !initialField.validateText();
            invalid = invalid | !endField.validateText();
            invalid = invalid | !initialCurr.validateText();
            invalid = invalid | !endCurr.validateText();
        } else{
            invalid = invalid | !initialBeha.validateText();
            invalid = invalid | !endBeha.validateText();
        }
        return !invalid;
    }

    public boolean mousePressedMethod(){
        boolean hit = false;
        if(clearButton.mousePressedMethod()){
            clearButton.deactivate();
            name.resetText();
            duration.resetText();
            if(sp.getEngine().equals("LLG")){
                initialCurr.resetText();
                initialField.resetText();
                endCurr.resetText();
                endField.resetText();
            } else{
                initialBeha.resetText();
                endBeha.resetText();
            }
        }
        if(newButton.mousePressedMethod()){
            boolean invalid = false;
            newButton.deactivate();
            invalid = invalid | !name.validateText();
            invalid = invalid | !duration.validateText();
            if(sp.getEngine().equals("LLG")){
                invalid = invalid | !initialField.validateText();
                invalid = invalid | !endField.validateText();
                invalid = invalid | !initialCurr.validateText();
                invalid = invalid | !endCurr.validateText();
            } else{
                invalid = invalid | !initialBeha.validateText();
                invalid = invalid | !endBeha.validateText();
            }
            if(!invalid){
                String value = name.getText() + ";";
                if(sp.getEngine().equals("LLG")){
                    value += initialField.getText() + ";";
                    value += endField.getText() + ";";
                    value += initialCurr.getText() + ";";
                    value += endCurr.getText() + ";";
                    value += duration.getText();
                    llgPhaseValues.put(name.getText(), value);
                    if(!llgPhases.isIn(name.getText()))
                        llgPhases.addItem(name.getText());
                } else{
                    value += initialBeha.getText() + ";";
                    value += endBeha.getText() + ";";
                    value += duration.getText();
                    behaPhaseValues.put(name.getText(), value);
                    if(!behaPhases.isIn(name.getText()))
                        behaPhases.addItem(name.getText());
                }
            }
            PopUp pop = new PopUp((width-150)/2,(height-50)/2, 150, 50, "Phase added!");
            pop.activate();
            pop.setAsTimer(50);
            popCenter.setPopUp(pop);
            return true;
        }
        if(saveButton.mousePressedMethod()){
            boolean invalid = false;
            saveButton.deactivate();
            invalid = invalid | !name.validateText();
            invalid = invalid | !duration.validateText();
            if(sp.getEngine().equals("LLG")){
                invalid = invalid | !initialField.validateText();
                invalid = invalid | !endField.validateText();
                invalid = invalid | !initialCurr.validateText();
                invalid = invalid | !endCurr.validateText();
            } else{
                invalid = invalid | !initialBeha.validateText();
                invalid = invalid | !endBeha.validateText();
            }
            if(!invalid){
                String value = name.getText() + ";";
                if(sp.getEngine().equals("LLG")){
                    value += initialField.getText() + ";";
                    value += endField.getText() + ";";
                    value += initialCurr.getText() + ";";
                    value += endCurr.getText() + ";";
                    value += duration.getText();
                    llgPhaseValues.put(name.getText(), value);
                } else{
                    value += initialBeha.getText() + ";";
                    value += endBeha.getText() + ";";
                    value += duration.getText();
                    behaPhaseValues.put(name.getText(), value);
                }
            }
            PopUp pop = new PopUp(((width-150)/2)*scaleFactor, ((height-50)/2)*scaleFactor, 150, 50, "Phase saved!");
            pop.activate();
            pop.setAsTimer(50);
            popCenter.setPopUp(pop);
            return true;
        }
        boolean boolPhasesAux;
        if(sp.getEngine().equals("LLG")){
            boolPhasesAux = llgPhases.mousePressedMethod();
        } else{
            boolPhasesAux = behaPhases.mousePressedMethod();
        }
        if(boolPhasesAux){
            zonePanel.updatePhases();
            String auxKey = (sp.getEngine().equals("LLG"))?llgPhases.getEditionField():behaPhases.getEditionField();
            if(auxKey != ""){
                if(sp.getEngine().equals("LLG")){
                    String value = llgPhaseValues.get(auxKey);
                    String [] parts = value.split(";");
                    name.setText(parts[0]);
                    initialField.setText(parts[1]);
                    endField.setText(parts[2]);
                    initialCurr.setText(parts[3]);
                    endCurr.setText(parts[4]);
                    duration.setText(parts[5]);
                } else{
                    String value = behaPhaseValues.get(auxKey);
                    String [] parts = value.split(";");
                    name.setText(parts[0]);
                    initialBeha.setText(parts[1]);
                    endBeha.setText(parts[2]);
                    duration.setText(parts[3]);
                }
            }
        }
        hit = hit | name.mousePressedMethod();
        hit = hit | initialBeha.mousePressedMethod();
        hit = hit | endBeha.mousePressedMethod();
        hit = hit | initialField.mousePressedMethod();
        hit = hit | endField.mousePressedMethod();
        hit = hit | initialCurr.mousePressedMethod();
        hit = hit | endCurr.mousePressedMethod();
        hit = hit | duration.mousePressedMethod();
        return hit;
    }

    public void keyPressedMethod(){
        if(name.keyPressedMethod() & (key == ENTER | key == TAB)){
            if(sp.getEngine().endsWith("LLG")){
                initialField.select();
            } else{
                initialBeha.select();
            }
            return;
        }
        if(initialBeha.keyPressedMethod() & (key == ENTER | key == TAB)){
            endBeha.select();
            return;
        }
        if(endBeha.keyPressedMethod() & (key == ENTER | key == TAB)){
            duration.select();
            return;
        }
        if(initialField.keyPressedMethod() & (key == ENTER | key == TAB) & !initialField.isSelected()){
            endField.select();
            return;
        }
        if(endField.keyPressedMethod() & (key == ENTER | key == TAB) & !endField.isSelected()){
            initialCurr.select();
            return;
        }
        if(initialCurr.keyPressedMethod() & (key == ENTER | key == TAB) & !initialCurr.isSelected()){
            endCurr.select();
            return;
        }
        if(endCurr.keyPressedMethod() & (key == ENTER | key == TAB) & !endCurr.isSelected()){
            duration.select();
            return;
        }
        if(duration.keyPressedMethod() & (key == ENTER | key == TAB)){
            name.select();
            return;
        }
    }
}
public class PopUp{
    float x, y, w, h;
    String text;
    ArrayList <TextButton> options;
    int timer, timeLimit;
    int green = color(45, 80, 22), orange = color(212, 85, 0);
    boolean isActive, fadeBackground, isTimer;
    
    public PopUp(float x, float y, float w, float h, String text){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.text = text;
        isActive = false;
        fadeBackground = true;
        options = new ArrayList<TextButton>();
        isTimer = false;
    }
    
    public void activate(){
        isActive = true;
    }
    
    public void deactivate(){
        isActive = false;
    }
    
    public void setAsTimer(int limit){
        isTimer = true;
        timer = 0;
        timeLimit = limit;
    }
    
    public void drawSelf(){
        if(timer >= timeLimit && isTimer)
            deactivate();
        timer++;
        if(isActive){
            if(fadeBackground){
                stroke(255, 255, 255, 125);
                fill(255, 255, 255, 125);
                rect(0, 0, width*scaleFactor, height*scaleFactor);
            }
            
            stroke(orange);
            fill(green);
            rect(x, y, w, h);
            
            fill(255);
            stroke(255);
            textSize(fontSz);
            int count = (options.size() > 0)?2:1;
            for(int i=0; i<text.length(); i++)
                if(text.charAt(i) == '\n')
                    count++;
            text(text, x+(w-textWidth(text))/2, y+fontSz+(h - (textAscent()+textDescent())*count)/2);
            
            count = 0;
            for(TextButton opt : options){
                opt.setWidth((w-10)/options.size());
                opt.setPosition(x+5+count*((w-10)/options.size()), y+h-textAscent()-textDescent()-5);
                count++;
                opt.drawSelf();
            }
        }
    }    
}

public class PopUpCenter{
    PopUp pop = new PopUp(0,0,0,0,"");
    
    public void setPopUp(PopUp pop){
        this.pop = pop;
    }
    
    public void drawSelf(){
        pop.drawSelf();
    }
    
    public boolean isActive(){
        return pop.isActive;
    }    
}
class ResultsPanel{
    float x, y, w, h;
    TextBox fontSize, startRange, endRange, numberOfColumns;
    CheckBox xComponent, yComponent, zComponent, customSeriesStart, customSeriesEnd, customNumberOfColumns;
    DropDownBox plotMode;
    Button chartButton;
    SubstrateGrid substrateGrid;
    int panelColor, textColor;
    
    public ResultsPanel(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;

        fontSize = new TextBox("Font Size", x, y, w-20);
        fontSize.setValidationType("IntegerPos");
        fontSize.setText("12");
        
        startRange = new TextBox("", x, y, w-30-2*(textAscent()+textDescent()));
        startRange.setValidationType("FloatPos");
        
        endRange = new TextBox("", x, y, w-30-2*(textAscent()+textDescent()));
        endRange.setValidationType("FloatPos");
        
        numberOfColumns = new TextBox("", x, y, w-30-2*(textAscent()+textDescent()));
        numberOfColumns.setValidationType("IntegerPos");

        plotMode = new DropDownBox("Plot Mode", x, y, w-20);
        plotMode.addOption("split");
        plotMode.addOption("comparative");
        plotMode.setSelectedOption("split");

        xComponent = new CheckBox("", x, y, w-20);
        xComponent.isChecked = true;
        yComponent = new CheckBox("", x, y, w-20);
        yComponent.isChecked = true;
        zComponent = new CheckBox("", x, y, w-20);
        zComponent.isChecked = true;
        customSeriesStart = new CheckBox("Range Start (ns)", x, y, w-20);
        customSeriesEnd = new CheckBox("Range End (ns)", x, y, w-20);
        customNumberOfColumns = new CheckBox("Columns", x, y, w-20);

        chartButton = new Button("Save", "Plot the magnetization chart for the selected magnets", sprites.chartIconWhite, x+w-30, y+h-30);
    
        panelColor = color(45, 80, 22);
        textColor = color(255,255,255);
    }

    public void setSubstrateGrid(SubstrateGrid sg){
        substrateGrid = sg;
    }
    
    public void drawSelf(){
        textSize(fontSz+5);
        fill(panelColor);
        stroke(panelColor);
        rect(x, y, w, h, 0, 15, 0, 0);
        fill(textColor);
        noStroke();
        float aux = textAscent()+textDescent(), auxY;
        String txt = "Results Panel";
        auxY = y;
        text(txt, x+(w-textWidth(txt))/2, auxY+aux);
        auxY += aux+15;
        textSize(fontSz);
        aux = textAscent()+textDescent();
        text("Properties", x+10, auxY+aux);
        auxY += aux+5;

        plotMode.updatePosition(x+10, auxY);
        auxY += aux+5;
        fontSize.updatePosition(x+10, auxY);
        auxY += aux+5;
        customSeriesStart.updatePosition(x+10, auxY);
        startRange.updatePosition(x+20+2*(textAscent()+textDescent()), auxY);
        auxY += aux+5;
        customSeriesEnd.updatePosition(x+10, auxY);
        endRange.updatePosition(x+20+2*(textAscent()+textDescent()), auxY);
        auxY += aux+5;
        customNumberOfColumns.updatePosition(x+10, auxY);
        numberOfColumns.updatePosition(x+20+2*(textAscent()+textDescent()), auxY);
        auxY += aux+5;
        text("Components", x+10, auxY+fontSz);
        text("x:", x+w/2, auxY+fontSz);
        text("y:", x+w/2+15+textWidth("x:")+aux, auxY+fontSz);
        text("z:", x+w/2+25+textWidth("x:y:")+2*aux, auxY+fontSz);
        xComponent.updatePosition(x+15+textWidth("x:"), auxY);
        yComponent.updatePosition(x+30+textWidth("x:y:")+(textAscent()+textDescent()), auxY);
        zComponent.updatePosition(x+40+textWidth("x:y:z:")+2*(textAscent()+textDescent()), auxY);
        auxY += aux+5;
        
        chartButton.isTransparent = !validateAllFields();
        
        chartButton.drawSelf();
        chartButton.onMouseOverMethod();
        xComponent.drawSelf();
        yComponent.drawSelf();
        zComponent.drawSelf();
        if(customNumberOfColumns.isChecked)
            numberOfColumns.drawSelf();
        customNumberOfColumns.drawSelf();
        if(customSeriesEnd.isChecked)
            endRange.drawSelf();
        customSeriesEnd.drawSelf();
        if(customSeriesStart.isChecked)
            startRange.drawSelf();
        customSeriesStart.drawSelf();
        fontSize.drawSelf();
        plotMode.drawSelf();
    }
    
    public boolean validateAllFields(){
       boolean validation = true;
       validation = validation && fontSize.validateText();
       if(customSeriesStart.isChecked)
           validation = validation && startRange.validateText();
       if(customSeriesEnd.isChecked)
           validation = validation && endRange.validateText();
       if(customNumberOfColumns.isChecked)
           validation = validation && numberOfColumns.validateText();
       if(!xComponent.isChecked && !yComponent.isChecked && !zComponent.isChecked)
           validation = false;
       return validation;
    }
    
    public void mousePressedMethod(){
        if(plotMode.mousePressedMethod())
            return;
        if(fontSize.mousePressedMethod())
            return;
        if(customSeriesStart.mousePressedMethod())
            return;
        if(customSeriesEnd.mousePressedMethod())
            return;
        if(customNumberOfColumns.mousePressedMethod())
            return;
        if(xComponent.mousePressedMethod())
            return;
        if(yComponent.mousePressedMethod())
            return;
        if(zComponent.mousePressedMethod())
            return;
        startRange.mousePressedMethod();
        endRange.mousePressedMethod();
        numberOfColumns.mousePressedMethod();
        if(chartButton.mousePressedMethod()){
            chartButton.deactivate();
            String call = substrateGrid.getSelectedMagnetsNames();
            if(!call.equals("")){
                try{
                    call = call.replaceAll(" ", ";");
                    exec("gnome-terminal", "-e",
                        "python3 " + sketchPath() + "/../../chart.py" +
                        " --input=" + fileSys.fileBaseName + "/simulation.csv" +
                        " --magnets=\"" + call + "\"" +
                        " --fontsz=" + fontSize.getText() +
                        " --range=" + ((customSeriesStart.isChecked)?startRange.getText():"begin") + ";" + ((customSeriesEnd.isChecked)?endRange.getText():"end") +
                        " --cols=" + ((customNumberOfColumns.isChecked)?numberOfColumns.getText():"auto") +
                        " --comps=" + ((xComponent.isChecked)?"x":"") + ";" + ((yComponent.isChecked)?"y":"") + ";" + ((zComponent.isChecked)?"z":"") +
                        " --mode=" + plotMode.getSelectedOption());
                } catch(Exception e){
                    e.printStackTrace();
                }
            } else{
                PopUp pop = new PopUp(((width-250)/2)*scaleFactor, ((height-100)/2)*scaleFactor, 250, 100, "Select at least one magnet!");
                pop.activate();
                pop.setAsTimer(60);
                popCenter.setPopUp(pop);
            }
        }
    }
    
    public void keyPressedMethod(){
        if(customSeriesStart.isChecked)
           startRange.keyPressedMethod();
        if(customSeriesEnd.isChecked)
           endRange.keyPressedMethod();
        if(customNumberOfColumns.isChecked)
            numberOfColumns.keyPressedMethod();
        fontSize.keyPressedMethod();
   }
}
class Scrollbar{
    float x, y, w, h, mx, my;
    boolean isVertical, isDragging, isFlipped;
    int buttons, trail;
    int maxIndex, index, foldSize;
    HitBox plusArrow, minusArrow, bar, fullScroll;
    PImage auicon, adicon;
    
    Scrollbar(float x, float y, float w, float h, int maxIndex, int foldSize, boolean isVertical){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.maxIndex = maxIndex;
        this.foldSize = foldSize;
        buttons = color(255,153,85);
        trail = color(212,85,0);
        index = 0;
        this.isVertical = isVertical;
        this.isDragging = false;
        this.isFlipped = false;
        fullScroll = new HitBox(x, y, w, h);
        if(isVertical){
            auicon = sprites.orangeArrowUpIcon;
            adicon = sprites.orangeArrowDownIcon;
            minusArrow = new HitBox(x+(w-10)/2-5, y, 20, 20);
            plusArrow = new HitBox(x+(w-10)/2-5, y+h-20, 20, 20);
            float barH = ((h-40)/maxIndex)*foldSize;
            barH = (barH > h-40)?h-40:barH;
            float barPos = y+20+((h-40)/maxIndex)*index;
            bar = new HitBox(x, barPos, w, h);
        } else{
            auicon = sprites.orangeArrowLeftIcon;
            adicon = sprites.orangeArrowRightIcon;
            minusArrow = new HitBox(x, y, 20, 20);
            plusArrow = new HitBox(x+w-20, y, 20, 20);
            float barW = ((w-40)/maxIndex)*foldSize;
            barW = (barW > w-40)?w-40:barW;
            float barPos = x+20+((w-40)/maxIndex)*index;
            bar = new HitBox(barPos, y, w, h);
        }
    }
    
    public void redefine(float x, float y, float w, float h, int foldSz){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        foldSize = foldSz;
        fullScroll.updateBox(x, y, w, h);
        if(isVertical){
            minusArrow.updateBox(x+(w-10)/2-5, y, 20, 20);
            plusArrow.updateBox(x+(w-10)/2-5, y+h-20, 20, 20);
        } else{
            minusArrow = new HitBox(x, y, 20, 20);
            plusArrow = new HitBox(x+w-20, y, 20, 20);
        }
        index = (index>maxIndex-foldSize)?maxIndex-foldSize:index;
        index = (index<0)?0:index;
    }
    
    public void increaseMaxIndex(){
        this.maxIndex++;
    }
    
    public void decreaseMaxIndex(){
        maxIndex--;
        if(maxIndex < 1)
            maxIndex = 1;
        index = (index>maxIndex-foldSize)?maxIndex-foldSize:index;
        index = (index<0)?0:index;
    }
    
    public void incrementIndex(){
        index++;
        index = (index>maxIndex-foldSize)?maxIndex-foldSize:index;
        index = (index<0)?0:index;
    }
    
    public void decreaseIndex(){
        index--;
        index = (index<0)?0:index;
    }
    
    public void resetMaxIndex(){
        index = 0;
        maxIndex = 1;
    }
    
    public void drawSelf(){
        fill(trail);
        stroke(trail);
        rect(x, y, w, h, 15);
                
        fill(buttons);
        stroke(buttons);
        if(isVertical){
            image(auicon,x+(w-auicon.width)/2, y+5);
            image(adicon,x+(w-auicon.width)/2, y+h-15);
            float barH = ((h-40)/maxIndex)*foldSize;
            barH = (barH > h-40)?h-40:barH;
            float barPos = y+20+((h-40)/maxIndex)*index;
            if(!isFlipped)
                rect(x, barPos, w, barH, 15);
            else
                rect(x, y+h-(barPos-y)-barH, w, barH, 15);
            if(!isFlipped)
                bar.updateBox(x, barPos, w, barH);
            else
                bar.updateBox(x, y+h-(barPos-y)-barH, w, barH);
        } else{
            image(auicon,x+5, y+(h-10)/2);
            image(adicon,x+w-15, y+(h-10)/2);
            float barW = ((w-40)/maxIndex)*foldSize;
            barW = (barW > w-40)?w-40:barW;
            float barPos = x+20+((w-40)/maxIndex)*index;
            if(!isFlipped)
                rect(barPos, y, barW, h, 15);
            else
                rect(x+w-(barPos-x)-barW, y, barW, h, 15);
            if(!isFlipped)
                bar.updateBox(barPos, y, barW, h);
            else
                bar.updateBox(x+w-(barPos-x)-barW, y, barW, h);
        }        
    }
    
    public int getIndex(){
        return index;
    }
    
    public void mousePressedMethod(){
        if(plusArrow.collision(mouseX, mouseY)){
            if(!isFlipped)
                incrementIndex();
            else
                decreaseIndex();
        }
        else if(minusArrow.collision(mouseX, mouseY)){
            if(!isFlipped)
                decreaseIndex();
            else
                incrementIndex();
        }
        else if(bar.collision(mouseX, mouseY))
            isDragging = true;
    }
    
    public boolean mouseDraggedMethod(){
        if(isDragging){
            if(!fullScroll.collision(mouseX, mouseY)){
                isDragging = false;
                return false;
            }
            if(isVertical){
                if(!isFlipped)
                    index = PApplet.parseInt((mouseY/scaleFactor - y - 20)/((h-40)/maxIndex));
                else
                    index = maxIndex - PApplet.parseInt((mouseY/scaleFactor - y - 20)/((h-40)/maxIndex));
            } else{
                if(!isFlipped)
                    index = PApplet.parseInt((mouseX/scaleFactor - x - 20)/((w-40)/maxIndex));
                else
                    index = maxIndex - PApplet.parseInt((mouseX/scaleFactor - x - 20)/((w-40)/maxIndex));
            }
            if(index>maxIndex-foldSize){
                index = maxIndex-foldSize;
                if(index < 0)
                    index = 0;
            }
            else if (index < 0)
                index = 0;
            return true;
        }
        return false;
    }
    
    public boolean mouseWheelMethod(float value){
        if(fullScroll.collision(mouseX, mouseY)){
            if(value > 0){
                if(!isFlipped){
                    incrementIndex();
                } else{
                    decreaseIndex();
                }
            } else{
                if(!isFlipped){
                    decreaseIndex();
                } else{
                    incrementIndex();
                }
            }
            return true;
        }
        return false;
    }
}




class SimulationBar{
    float x, y, w, h;
    int animationSpeed, animationTime, counter = 0;
    Button forward, backward, play, pause, stop, simulate, charts, export, upSpeed, downSpeed, timeline, exportGif;
    int panelColor, textColor, lineColor;
    SubstrateGrid substrateGrid;
    PanelMenu panelMenu;
    ArrayList <String> labels;
    ArrayList <ArrayList<Float>> magX, magY;
    boolean timelineEnabled = false, timelineRunning = false, isRecording = false;
    
    SimulationBar(float x, float y, float w, float h, SubstrateGrid substrateGrid, PanelMenu panelMenu){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        animationSpeed = 50;
        animationTime = 0;
        textSize(fontSz);
        float auxX = x + textWidth("Timeline") + 10;
        backward = new Button("Backward", "Make one step back in the simulation animation", sprites.backwardIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        stop = new Button("Stop", "Stop the animation and reset the magnetization to initial state", sprites.stopIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        pause = new Button("Pause", "Pauses the simulation animation", sprites.pauseIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        play = new Button("Play", "Resumes or start the simulation animation", sprites.playIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        forward = new Button("Forward", "Make one step forward in the simulation animation", sprites.forwardIconWhite, auxX, (h-25)/2+y);
        auxX += 30 + textWidth("Speed: 100") + 20;
        upSpeed = new Button("Upgrade Speed", "Upgrades the speed of the simulation animation", sprites.nanoArrowUpIconWhite, auxX, (h-15)/2+y);
        auxX += 20;
        downSpeed = new Button("Downgrade Speed", "Downgrades the speed of the simulation animation", sprites.nanoArrowDownIconWhite, auxX, (h-15)/2+y);
        auxX += 20 + textWidth("Simulation") + 20;
        simulate = new Button("Simulate", "Performes the engine simulation", sprites.simulationIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        charts = new Button("Chart", "Plot the magnetization chart for the selected magnets", sprites.chartIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        export = new Button("Export", "Exports the XML file for the simulation engine", sprites.medSaveAsIconWhite, auxX, (h-20)/2+y);
        auxX += 25;
        timeline = new Button("Timeline", "Enables the timeline animation", sprites.timelineIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        exportGif = new Button("Export Gif", "Records and exports the timeline animation as a Gif", sprites.exportGifIconWhite, auxX, (h-25)/2+y);
        
        panelColor = color(45, 80, 22);
        textColor = color(255,255,255);
        lineColor = color(255,255,255);
        
        this.substrateGrid = substrateGrid;
        this.panelMenu = panelMenu;
    }
    
    public void drawSelf(){
        upSpeed.isTransparent = animationSpeed == 100;
        downSpeed.isTransparent = animationSpeed == 0;
        
        float auxX = 5;
        fill(panelColor);
        stroke(panelColor);
        rect(x, y, w, h);
        fill(textColor, 255);
        noStroke();
        textSize(fontSz);
        text("Timeline", auxX, y+fontSz+5);
        auxX += textWidth("Timeline") + 5;
        backward.isTransparent = !timelineEnabled;
        backward.drawSelf();
        pause.isTransparent = !timelineEnabled || !timelineRunning;
        pause.drawSelf();
        stop.isTransparent = !timelineEnabled || !timelineRunning;
        stop.drawSelf();
        play.isTransparent = !timelineEnabled || timelineRunning;
        play.drawSelf();
        forward.isTransparent = !timelineEnabled;
        forward.drawSelf();
        
        strokeWeight(3);
        stroke(lineColor);
        auxX += 153;
        line(auxX, y+5, auxX, y+h-5);
        auxX += 2;
        noStroke();
        strokeWeight(1);
        
        fill(textColor, 255);
        text("Speed: " + animationSpeed, auxX+5, y+fontSz+5);
        auxX += textWidth("Speed: 100")+10;
        upSpeed.drawSelf();
        downSpeed.drawSelf();

        strokeWeight(3);
        stroke(lineColor);
        auxX += 53;
        line(auxX, y+5, auxX, y+h-5);
        auxX += 2;
        noStroke();
        strokeWeight(1);

        fill(textColor, 255);
        text("Simulation", auxX+5, y+fontSz+5);
        charts.drawSelf();
        simulate.drawSelf();
        export.drawSelf();
        timeline.drawSelf();
        exportGif.isTransparent = !timelineEnabled;
        exportGif.drawSelf();
        
        strokeWeight(3);
        stroke(lineColor);
        auxX += 235;
        line(auxX, y+5, auxX, y+h-5);
        auxX += 2;
        noStroke();
        strokeWeight(1);
        
        fill(textColor, 255);
        if(timelineEnabled)
            text("Timeline clock (ns): " + animationTime*panelMenu.getReportStep(), auxX+5, y+fontSz+5);
        else
            text("Timeline deactivated", auxX+5, y+fontSz+5);
        
        strokeWeight(2);
        stroke(lineColor);
        auxX += 53;
        line(x, y-1, x+w, y-1);
        auxX += 2;
        noStroke();
        strokeWeight(1);

        export.onMouseOverMethod();
        charts.onMouseOverMethod();
        simulate.onMouseOverMethod();
        downSpeed.onMouseOverMethod();
        upSpeed.onMouseOverMethod();
        forward.onMouseOverMethod();
        play.onMouseOverMethod();
        pause.onMouseOverMethod();
        stop.onMouseOverMethod();
        backward.onMouseOverMethod();
        timeline.onMouseOverMethod();
        exportGif.onMouseOverMethod();
        
        if(timelineEnabled && timelineRunning && counter >= (100-animationSpeed)/10){
            forwardSimulation();
            if(isRecording){
                saveFrame(fileSys.fileBaseName + "/gif/frame" + String.format("%1$15s",Integer.toString(animationTime)).replace(" ", "0") + ".png");
            }
            counter = 0;
        } else if(!timelineEnabled){
            counter = 0;
        } else if(timelineEnabled && timelineRunning){
            counter++;
        }
    }
    
    public void loadSimulationResultsFile(){
        animationTime = 0;
        labels = new ArrayList<String>();
        magX = new ArrayList<ArrayList<Float>>();
        magY = new ArrayList<ArrayList<Float>>();        
        try{
            BufferedReader file = createReader(fileSys.fileBaseName + "/simulation.csv");
            String line = file.readLine();
            String [] parts = line.split(",");
            for(int i=1; i<parts.length; i+=3){
                labels.add(parts[i].substring(0,parts[i].length()-2));
            }
            line = file.readLine();
            parts = line.split(",");
            for(int i=1; i<parts.length; i+=3){
                magX.add(new ArrayList<Float>());
                magX.get(magX.size()-1).add(Float.parseFloat(parts[i]));
                magY.add(new ArrayList<Float>());
                magY.get(magY.size()-1).add(Float.parseFloat(parts[i+1]));
            }
            while(line != null && !line.equals("")){
                parts = line.split(",");
                int index = 0;
                for(int i=1; i<parts.length; i+=3){
                    magX.get(index).add(Float.parseFloat(parts[i]));
                    magY.get(index).add(Float.parseFloat(parts[i+1]));
                    index++;
                }
                line = file.readLine();
            }
        } catch(Exception e){
        }
    }
    
    public void forwardSimulation(){
        animationTime++;
        if(animationTime >= magX.get(0).size()){
            animationTime--;
            return;
        }
        for(int i=0; i<labels.size(); i++){
            substrateGrid.setMagnetMagnetization(labels.get(i),magX.get(i).get(animationTime), magY.get(i).get(animationTime));
        }
    }
    
    public void backwardSimulation(){
        animationTime--;
        if(animationTime < 0){
            animationTime++;
            return;
        }
        for(int i=0; i<labels.size(); i++){
            substrateGrid.setMagnetMagnetization(labels.get(i),magX.get(i).get(animationTime), magY.get(i).get(animationTime));
        }
    }
    
    public void disableTimeline(){
        timelineEnabled = false;
        timelineRunning = false;
        isRecording = false;
        timeline.deactivate();
        play.deactivate();
        pause.deactivate();
        stop.deactivate();
        simulate.deactivate();
        exportGif.deactivate();
    }
    
    public void keyPressedMethod(){
        if(altPressed && PApplet.parseInt(key) == 115 && !fileSys.fileBaseName.equals("")){ //Simulate
            saveProject();
            try{
                exec("gnome-terminal", "-e", sketchPath() + "/../../nmlsim " + fileSys.fileBaseName + "/simulation.xml " +  fileSys.fileBaseName + "/simulation.csv");
            } catch(Exception e){
                e.printStackTrace();
            }
            timelineEnabled = false;
            timelineRunning = false;
            isRecording = false;
            timeline.deactivate();
            play.deactivate();
            pause.deactivate();
            stop.deactivate();
            if(animationTime > 0){
                animationTime = 1;
                backwardSimulation();
            }
            simulate.deactivate();
            exportGif.deactivate();
        }
        if(altPressed && PApplet.parseInt(key) == 99){ //Chart
            String call = substrateGrid.getSelectedMagnetsNames();
            if(!call.equals("")){
                try{
                    call = call.replaceAll(" ", ";");
                    exec("gnome-terminal", "-e", "python3 " + sketchPath() + "/../../chart.py --input=" + fileSys.fileBaseName + "/simulation.csv --magnets=\"" + call + "\"");
                } catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
        if(altPressed && PApplet.parseInt(key) == 101){ //Export XML
            File start = new File(sketchPath("")+"/sim.xml");
            selectOutput("Select a file to export the simulation", "exportXML", start);
        }
        if(altPressed && PApplet.parseInt(key) == 116 && panelMenu.getSimulationMode().equals("verbose")){ //Activate timeline
            Path p = Paths.get(fileSys.fileBaseName + "/simulation.csv");
            if(!Files.exists(p)){
                timeline.deactivate();
                return;
            }
            if(animationTime > 0){
                animationTime = 1;
                backwardSimulation();
            }
            loadSimulationResultsFile();
            timelineEnabled = !timelineEnabled;
            if(!timelineEnabled){
                exportGif.deactivate();
                isRecording = false;
            }
            timelineRunning = false;
            timeline.active = timelineEnabled;
        }
        if(altPressed && PApplet.parseInt(key) == 114){ //Record Gif
            isRecording = !isRecording;
            if(!isRecording){
                try{
                    exec("gnome-terminal", "-e", "sh -c \"convert -delay 10 " + fileSys.fileBaseName + "/gif/*.png +repage -loop 0 -strip -coalesce -layers Optimize " + fileSys.fileBaseName + "/simulationAnimation.gif ; " + "rm -rf " + fileSys.fileBaseName + "/gif\"");
                } catch(Exception e){
                    e.printStackTrace();
                }
            }
            exportGif.active = isRecording;
        }
        if(altPressed && PApplet.parseInt(key) == 112){ //Play and Pause
            if(timelineEnabled){
                timelineRunning = !timelineRunning;
            }
        }
        if(altPressed && PApplet.parseInt(key) == 80){ //Stop
            if(timelineEnabled){
                timelineRunning = false;
                animationTime = 1;
                backwardSimulation();
            }
        }
        if(keyCode == LEFT){ //Backward
            backwardSimulation();
            timelineRunning = false;
        }
        if(keyCode == RIGHT){ //Forward
            forwardSimulation();
            timelineRunning = false;
        }
    }
    
    public void mousePressedMethod(){
        if(upSpeed.mousePressedMethod()){
            upSpeed.deactivate();
            if(animationSpeed < 100)
                animationSpeed += 10;
        }
        if(downSpeed.mousePressedMethod()){
            downSpeed.deactivate();
            if(animationSpeed > 0)
                animationSpeed -= 10;
        }
        if(export.mousePressedMethod()){
            export.deactivate();
            File start = new File(sketchPath("")+"/sim.xml");
            selectOutput("Select a file to export the simulation", "exportXML", start);
        }
        if(simulate.mousePressedMethod() && !fileSys.fileBaseName.equals("")){
            saveProject();
            try{
                exec("gnome-terminal", "-e", sketchPath() + "/../../nmlsim " + fileSys.fileBaseName + "/simulation.xml " +  fileSys.fileBaseName + "/simulation.csv");
            } catch(Exception e){
                e.printStackTrace();
            }
            timelineEnabled = false;
            timelineRunning = false;
            isRecording = false;
            timeline.deactivate();
            play.deactivate();
            pause.deactivate();
            stop.deactivate();
            if(animationTime > 0){
                animationTime = 1;
                backwardSimulation();
            }
            simulate.deactivate();
            exportGif.deactivate();
        }
        if(charts.mousePressedMethod()){
            charts.deactivate();
            String call = substrateGrid.getSelectedMagnetsNames();
            if(!call.equals("")){
                try{
                    call = call.replaceAll(" ", ";");
                    exec("gnome-terminal", "-e", "python3 " + sketchPath() + "/../../chart.py --input=" + fileSys.fileBaseName + "/simulation.csv --magnets=\"" + call + "\"");
                } catch(Exception e){
                    e.printStackTrace();
                }
            } else{
                PopUp pop = new PopUp(((width-250)/2)*scaleFactor, ((height-100)/2)*scaleFactor, 250, 100, "Select at least one magnet!");
                pop.activate();
                pop.setAsTimer(60);
                popCenter.setPopUp(pop);
            }
        }
        if(panelMenu.getSimulationMode().equals("verbose") && timeline.mousePressedMethod()){
            Path p = Paths.get(fileSys.fileBaseName + "/simulation.csv");
            if(!Files.exists(p)){
                timeline.deactivate();
                PopUp pop = new PopUp(((width-400)/2)*scaleFactor, ((height-100)/2)*scaleFactor, 400, 100, "Please perform a verbose simulation first!");
                pop.activate();
                pop.setAsTimer(80);
                popCenter.setPopUp(pop);
                return;
            }
            if(animationTime > 0){
                animationTime = 1;
                backwardSimulation();
            }
            loadSimulationResultsFile();
            timelineEnabled = !timelineEnabled;
            if(!timelineEnabled){
                exportGif.deactivate();
                isRecording = false;
            }
            timelineRunning = false;
        }
        if(!panelMenu.getSimulationMode().equals("verbose") && timeline.mousePressedMethod()){
            PopUp pop = new PopUp(((width-400)/2)*scaleFactor, ((height-100)/2)*scaleFactor, 400, 100, "Please perform a verbose simulation first!");
            pop.activate();
            pop.setAsTimer(80);
            popCenter.setPopUp(pop);
        }
        if(timelineEnabled && !timelineRunning && play.mousePressedMethod()){
            play.deactivate();
            timelineRunning = true;
        }
        if(timelineEnabled && timelineRunning && pause.mousePressedMethod()){
            pause.deactivate();
            timelineRunning = false;
        }
        if(timelineEnabled && timelineRunning && stop.mousePressedMethod()){
            stop.deactivate();
            timelineRunning = false;
            animationTime = 1;
            backwardSimulation();
        }
        if(timelineEnabled && forward.mousePressedMethod()){
            forward.deactivate();
            forwardSimulation();
            timelineRunning = false;
        }
        if(timelineEnabled && backward.mousePressedMethod()){
            backward.deactivate();
            backwardSimulation();
            timelineRunning = false;
        }
        if(exportGif.mousePressedMethod()){
            isRecording = !isRecording;
            if(!isRecording){
                try{
                    exec("gnome-terminal", "-e", "sh -c \"convert -delay 10 " + fileSys.fileBaseName + "/gif/*.png +repage -loop 0 -strip -coalesce -layers Optimize " + fileSys.fileBaseName + "/simulationAnimation.gif ; " + "rm -rf " + fileSys.fileBaseName + "/gif\"");
                } catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
    }
}
class SimulationPanel{
    float x, y, w, h;
    DropDownBox engine, mode, method;
    TextBox repetitions, reportStep, alpha, ms, temperature, timeStep, simTime, spinAngle, spinDifusionLenght, heavyMaterialThickness, neighborhoodRadius;
    VectorTextBox subSize, cellSize, bulletSpacing;
    int panelColor, textColor;
    Button clearButton, defaultButton;
    ZonePanel zonePanel;
    
    public SimulationPanel(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        textSize(fontSz);
        panelColor = color(45, 80, 22);
        textColor = color(255,255,255);
        
        engine = new DropDownBox("Engine", 0, 0, w-20);
        engine.addOption("LLG");
        engine.addOption("Behaviour");
        engine.setSelectedOption("LLG");
        
        mode = new DropDownBox("Mode", 0, 0, w-20);
        mode.addOption("direct");
        mode.addOption("verbose");
        mode.addOption("exaustive");
        mode.addOption("repetitive");
        mode.setSelectedOption("verbose");
        
        method = new DropDownBox("Method", 0, 0, w-20);
        method.addOption("RKW2");
        method.addOption("RK4");
        method.setSelectedOption("RK4");
        
        repetitions = new TextBox("Repetitions", 0, 0, w-20);
        repetitions.setValidationType("IntegerPos");
        repetitions.setText("100");
        
        reportStep = new TextBox("Report Step (ns)", 0, 0, w-20);
        reportStep.setValidationType("FloatPos");
        reportStep.setText("0.01");
        
        alpha = new TextBox("Gilbert Damping", 0, 0, w-20);
        alpha.setValidationType("Float");
        alpha.setText("0.05");
        
        ms = new TextBox("Saturat. Mag (A/m)", 0, 0, w-20);
        ms.setValidationType("Float");
        ms.setText("800000");
        
        temperature = new TextBox("Temperature (K)", 0, 0, w-20);
        temperature.setValidationType("FloatPos");
        temperature.setText("300");
        
        timeStep = new TextBox("Time Step (ns)", 0, 0, w-20);
        timeStep.setValidationType("FloatPos");
        timeStep.setText("0.0001");
        
        simTime = new TextBox("Sim. Time (ns)", 0, 0, w-20);
        simTime.setValidationType("FloatPos");
        
        spinAngle = new TextBox("Spin Angle", 0, 0, w-20);
        spinAngle.setValidationType("Float");
        spinAngle.setText("0.4");
        
        spinDifusionLenght = new TextBox("Spin Dif. Len.", 0, 0, w-20);
        spinDifusionLenght.setValidationType("Float");
        spinDifusionLenght.setText("3.5");
        
        heavyMaterialThickness = new TextBox("H.M. Thickness", 0, 0, w-20);
        heavyMaterialThickness.setValidationType("FloatPos");
        heavyMaterialThickness.setText("5");
        
        neighborhoodRadius = new TextBox("Neigh. Radius", 0, 0, w-20);
        neighborhoodRadius.setValidationType("FloatPos");
        neighborhoodRadius.setText("300");
        
        subSize = new VectorTextBox("Subst. Size (nm)", 0, 0, w-20, 2);
        subSize.setValidationType("FloatPos");
        subSize.setText("1000,1000");

        cellSize = new VectorTextBox("Cell Size (nm)", 0, 0, w-20, 2);
        cellSize.setValidationType("FloatPos");
        cellSize.setText("10,10");

        bulletSpacing = new VectorTextBox("Bullet Dist. (nm)", 0, 0, w-20, 2);
        bulletSpacing.setValidationType("FloatPos");
        bulletSpacing.setText("60,125");
        
        clearButton = new Button("Clear", "Clear all fields", sprites.smallDeleteIconWhite, x+w-55, y+h-22.5f);
        defaultButton = new Button("Defalt", "Set all fields to the default option", sprites.smallDefaultIconWhite, x+w-30, y+h-22.5f);
    }
    
    public String getProperties(){
        //engine;mode;method;repetitions;reportStep;alpha;ms;temperature;timeStep;simTime;spinAngle;spinDiff;hmt;neighborhood
        String properties = "";
        properties += engine.getSelectedOption() + ";";
        properties += mode.getSelectedOption() + ";";
        properties += method.getSelectedOption() + ";";
        properties += repetitions.getText() + ";";
        properties += reportStep.getText() + ";";
        properties += alpha.getText() + ";";
        properties += ms.getText() + ";";
        properties += temperature.getText() + ";";
        properties += timeStep.getText() + ";";
        properties += simTime.getText() + ";";
        properties += spinAngle.getText() + ";";
        properties += spinDifusionLenght.getText() + ";";
        properties += heavyMaterialThickness.getText() + ";";
        properties += neighborhoodRadius.getText() + ";";
        return properties;
    }
    
    public void loadProperties(String simulation, String grid){
        reset();
        String parts[] = simulation.split(";");
        if(!parts[0].equals(""))
            engine.setSelectedOption(parts[0]);
        if(!parts[1].equals(""))
            mode.setSelectedOption(parts[1]);
        if(!parts[2].equals(""))
            method.setSelectedOption(parts[2]);
        if(!parts[3].equals(""))
            repetitions.setText(parts[3]);
        if(!parts[4].equals(""))
            reportStep.setText(parts[4]);
        if(!parts[5].equals(""))
            alpha.setText(parts[5]);
        if(!parts[6].equals(""))
            ms.setText(parts[6]);
        if(!parts[7].equals(""))
            temperature.setText(parts[7]);
        if(!parts[8].equals(""))
            timeStep.setText(parts[8]);
        if(!parts[9].equals(""))
            simTime.setText(parts[9]);
        if(!parts[10].equals(""))
            spinAngle.setText(parts[10]);
        if(!parts[11].equals(""))
            spinDifusionLenght.setText(parts[11]);
        if(!parts[12].equals(""))
            heavyMaterialThickness.setText(parts[12]);
        if(!parts[13].equals(""))
            neighborhoodRadius.setText(parts[13]);
            
        parts = grid.split(",");
        if(!parts[0].equals("") && !parts[1].equals(""))
            subSize.setText(parts[0]+","+parts[1]);
        if(!parts[2].equals("") && !parts[3].equals(""))
            cellSize.setText(parts[2]+","+parts[3]);
        if(!parts[4].equals("") && !parts[5].equals(""))
            bulletSpacing.setText(parts[4]+","+parts[5]);
    }
    
    public void reset(){
            reportStep.setText("0.01");
            alpha.setText("0.05");
            ms.setText("800000");
            timeStep.setText("0.0001");
            spinAngle.setText("0.4");
            spinDifusionLenght.setText("3.5");
            heavyMaterialThickness.setText("5");
            neighborhoodRadius.setText("300");
            subSize.setText("1000,1000");
            cellSize.setText("10,10");
            bulletSpacing.setText("60,125");
            temperature.setText("300");
            repetitions.setText("100");
    }
    
    public void drawSelf(){
        textSize(fontSz+5);
        fill(panelColor);
        stroke(panelColor);
        rect(x, y, w, h, 0, 15, 0, 0);
        fill(textColor);
        noStroke();
        float aux = textAscent()+textDescent(), auxY;
        String txt = "Simulation Panel";
        auxY = y;
        text(txt, x+(w-textWidth(txt))/2, auxY+aux);
        auxY += aux+10;
        textSize(fontSz);
        aux = textAscent()+textDescent();
        text("Simulation", x+10, auxY+aux);
        auxY += aux+5;
        engine.updatePosition(x+10,auxY);
        auxY += aux+5;
        mode.updatePosition(x+10,auxY);
        auxY += aux+5;
        if(engine.getSelectedOption().equals("LLG")){
            method.updatePosition(x+10, auxY);
            auxY += aux+5;
        }
        if(mode.getSelectedOption().equals("repetitive")){
            repetitions.updatePosition(x+10, auxY);
            auxY += aux+5;
        }
        if(mode.getSelectedOption().equals("verbose")){
            reportStep.updatePosition(x+10, auxY);
            auxY += aux+5;
        }
        if(engine.getSelectedOption().equals("LLG")){
            alpha.updatePosition(x+10, auxY);
            auxY += aux+5;
        }
        if(engine.getSelectedOption().equals("LLG")){
            ms.updatePosition(x+10, auxY);
            auxY += aux+5;
        }
        if(engine.getSelectedOption().equals("LLG") & method.getSelectedOption().equals("RKW2")){
            temperature.updatePosition(x+10, auxY);
            auxY += aux+5;
        }
        timeStep.updatePosition(x+10, auxY);
        auxY += aux + 5;
        simTime.updatePosition(x+10, auxY);
        auxY += aux + 5;
        if(engine.getSelectedOption().equals("LLG")){
            spinAngle.updatePosition(x+10, auxY);
            auxY += aux+5;
            spinDifusionLenght.updatePosition(x+10, auxY);
            auxY += aux+5;
            heavyMaterialThickness.updatePosition(x+10, auxY);
            auxY += aux+5;
        }
        neighborhoodRadius.updatePosition(x+10, auxY);
        auxY += aux+5;
        
        auxY += 5;
        fill(textColor);
        stroke(textColor);
        strokeWeight(4);
        line(x+10, auxY+2, x+w-10, auxY+2);
        strokeWeight(1);
        noStroke();
        auxY += 8;
        
        text("Substrate Configurations", x+10, auxY+fontSz);
        auxY += aux+5;
        
        subSize.updatePosition(x+10, auxY);
        auxY += aux+5;
        cellSize.updatePosition(x+10, auxY);
        auxY += aux+5;
        bulletSpacing.updatePosition(x+10, auxY);
        auxY += aux+5;
        
        defaultButton.drawSelf();
        clearButton.drawSelf();
        bulletSpacing.drawSelf();
        cellSize.drawSelf();
        subSize.drawSelf();
        neighborhoodRadius.drawSelf();
        if(engine.getSelectedOption().equals("LLG")){
            heavyMaterialThickness.drawSelf();
            spinDifusionLenght.drawSelf();
            spinAngle.drawSelf();
            heavyMaterialThickness.isActive = true;
            spinAngle.isActive = true;
            spinDifusionLenght.isActive = true;
        } else{
            heavyMaterialThickness.isActive = false;
            spinAngle.isActive = false;
            spinDifusionLenght.isActive = false;
        }
        simTime.drawSelf();
        timeStep.drawSelf();
        if(engine.getSelectedOption().equals("LLG") & method.getSelectedOption().equals("RKW2")){
            temperature.drawSelf();
            temperature.isActive = true;
        }
        else{
            temperature.isActive = false;
        }
        if(engine.getSelectedOption().equals("LLG")){
            ms.drawSelf();
            ms.isActive = true;
        }
        else{
            ms.isActive = false;
        }
        if(engine.getSelectedOption().equals("LLG")){
            alpha.drawSelf();
            alpha.isActive = true;
        }
        else{
            alpha.isActive = false;
        }
        if(mode.getSelectedOption().equals("verbose")){
            reportStep.drawSelf();
            reportStep.isActive = true;
        }
        else{
            reportStep.isActive = false;
        }
        if(mode.getSelectedOption().equals("repetitive")){
            repetitions.drawSelf();
            repetitions.isActive = true;
        }
        else{
            repetitions.isActive = false;
        }
        if(engine.getSelectedOption().equals("LLG")){
            method.drawSelf();
            method.isActive = true;
        }
        else{
            method.isActive = false;
        }
        mode.drawSelf();
        engine.drawSelf();
        onMouseOverMethod();
    }
    
    public void setZonePanel(ZonePanel zonePanel){
        this.zonePanel = zonePanel;
    }
    
    public void onMouseOverMethod(){
        clearButton.onMouseOverMethod();
        defaultButton.onMouseOverMethod();
    }
    
    public boolean mousePressedMethod(){
        boolean hit = false;
        if(clearButton.mousePressedMethod()){
            clearButton.deactivate();
            int dialogResult = showConfirmDialog (null, "Are you sure you want to clear ALL fields in this panel?", "Warning!", YES_NO_OPTION);
            if(dialogResult != YES_OPTION)
                return false;
            reportStep.resetText();
            repetitions.resetText();
            temperature.resetText();
            method.resetOption();
            alpha.resetText();
            ms.resetText();
            spinAngle.resetText();
            spinDifusionLenght.resetText();
            heavyMaterialThickness.resetText();
            engine.resetOption();
            mode.resetOption();
            timeStep.resetText();
            simTime.resetText();
            neighborhoodRadius.resetText();
            subSize.resetText();
            cellSize.resetText();
            bulletSpacing.resetText();
        }
        if(defaultButton.mousePressedMethod()){
            defaultButton.deactivate();
            int dialogResult = showConfirmDialog (null, "     Are you sure you want to set ALL\nfields in this panel to the default value?", "Warning!", YES_NO_OPTION);
            if(dialogResult != YES_OPTION)
                return false;
            reportStep.setText("0.01");
            alpha.setText("0.05");
            ms.setText("800000");
            timeStep.setText("0.0001");
            spinAngle.setText("0.4");
            spinDifusionLenght.setText("3.5");
            heavyMaterialThickness.setText("5");
            neighborhoodRadius.setText("300");
            subSize.setText("1000,1000");
            cellSize.setText("10,10");
            bulletSpacing.setText("60,125");
            temperature.setText("300");
            repetitions.setText("100");
        }
        hit = hit | engine.mousePressedMethod();
        hit = hit | mode.mousePressedMethod();
        hit = hit | method.mousePressedMethod();
        hit = hit | repetitions.mousePressedMethod();
        hit = hit | reportStep.mousePressedMethod();
        hit = hit | alpha.mousePressedMethod();
        hit = hit | ms.mousePressedMethod();
        hit = hit | temperature.mousePressedMethod();
        hit = hit | timeStep.mousePressedMethod();
        hit = hit | simTime.mousePressedMethod();
        hit = hit | spinAngle.mousePressedMethod();
        hit = hit | spinDifusionLenght.mousePressedMethod();
        hit = hit | heavyMaterialThickness.mousePressedMethod();
        hit = hit | neighborhoodRadius.mousePressedMethod();
        hit = hit | subSize.mousePressedMethod();
        hit = hit | cellSize.mousePressedMethod();
        hit = hit | bulletSpacing.mousePressedMethod();
        zonePanel.updatePhases();
        return hit;
    }
    
    public boolean keyPressedMethod(){
        if(repetitions.keyPressedMethod()){
            if(key == ENTER | key == TAB){
                if(engine.getSelectedOption().equals("LLG")){
                    alpha.select();
                } else{
                    timeStep.select();
                }
            }
            return true;
        }
        if(reportStep.keyPressedMethod()){
            if(key == ENTER | key == TAB){
                if(engine.getSelectedOption().equals("LLG")){
                    alpha.select();
                } else{
                    timeStep.select();
                }
            }
            return true;
        }
        if(alpha.keyPressedMethod()){
            if(key == ENTER | key == TAB){
                ms.select();
            }
            return true;
        }
        if(ms.keyPressedMethod()){
            if(key == ENTER | key == TAB){
                if(method.getSelectedOption().equals("RKW2")){
                    temperature.select();
                } else{
                    timeStep.select();
                }
            }
            return true;
        }
        if(temperature.keyPressedMethod()){
            if(key == ENTER | key == TAB){
                timeStep.select();
            }
            return true;
        }
        if(timeStep.keyPressedMethod()){
            if(key == ENTER | key == TAB){
                simTime.select();
            }
            return true;
        }
        if(simTime.keyPressedMethod()){
            if(key == ENTER | key == TAB){
                if(engine.getSelectedOption().equals("LLG")){
                    spinAngle.select();
                } else{
                    neighborhoodRadius.select();
                }
            }
            return true;
        }
        if(spinAngle.keyPressedMethod()){
            if(key == ENTER | key == TAB){
                spinDifusionLenght.select();
            }
            return true;
        }
        if(spinDifusionLenght.keyPressedMethod()){
            if(key == ENTER | key == TAB){
                heavyMaterialThickness.select();
            }
            return true;
        }
        if(heavyMaterialThickness.keyPressedMethod()){
            if(key == ENTER | key == TAB){
                neighborhoodRadius.select();
            }
            return true;
        }
        if(neighborhoodRadius.keyPressedMethod()){
            if(key == ENTER | key == TAB)
                subSize.select();
            return true;
        }
        if(subSize.keyPressedMethod()){
            if((key == ENTER | key == TAB) & !subSize.isSelected())
                cellSize.select();
            return true;
        }
        if(cellSize.keyPressedMethod()){
            if((key == ENTER | key == TAB) & !cellSize.isSelected())
                bulletSpacing.select();
            return true;
        }
        if(bulletSpacing.keyPressedMethod()){
            if((key == ENTER | key == TAB) & !bulletSpacing.isSelected()){
                if(mode.getSelectedOption().equals("Repetitive")){
                    repetitions.select();
                } else if(mode.getSelectedOption().equals("Verbose")){
                    reportStep.select();
                } else if(engine.getSelectedOption().equals("LLG")){
                    alpha.select();
                } else{
                    timeStep.select();
                }
            }
            return true;
        }
        return false;
    }
    
    public String getEngine(){
        return engine.getSelectedOption();
    }
    
    public String getReportStep(){
        return reportStep.getText();
    }
    
    public String getSimulationMode(){
        return mode.getSelectedOption();
    }
    
    public String getGridProperties(){
        String gp = "";
        if(bulletSpacing.validateText() && subSize.validateText() && cellSize.validateText()){
            gp += subSize.getText() + cellSize.getText() + bulletSpacing.getText();
        }
        return gp;
    }
}
class SpriteCenter{
    public PImage copyIconWhite, openIconWhite, saveIconWhite, saveAsIconWhite, newIconWhite, lineAddWhite, editIconWhite, moveIconWhite, deleteIconWhite, pinIconWhite;
    public PImage pasteIconWhite, groupIconWhite, gridIconWhite, zoomInIconWhite, zoomOutIconWhite, bulletsIconWhite, lightIconWhite, zoneUpIconWhite, zoneDownIconWhite;
    public PImage undoIconWhite, redoIconWhite, orangeArrowUpIcon, orangeArrowDownIcon, smallSaveIconWhite, smallNewIconWhite, nanoNewIconWhite, nanoArrowDownIconWhite;
    public PImage nanoDeleteIconWhite, nanoEditIconWhite, nanoZoneUpIconWhite, nanoZoneDownIconWhite, smallDeleteIconWhite, nanoArrowUpIconWhite,smallSaveTemplateIconWhite;
    public PImage smallDefaultIconWhite, smallEditIconWhite, orangeArrowLeftIcon, orangeArrowRightIcon, cutIconWhite, forwardIconWhite, backwardIconWhite, playIconWhite;
    public PImage pauseIconWhite, stopIconWhite, chartIconWhite, simulationIconWhite, arrowUpIconWhite, arrowDownIconWhite, medSaveAsIconWhite, timelineIconWhite;
    public PImage cancelIconWhite, exportGifIconWhite, magnetIconWhite, zoneViewIconWhite, smallOpenIconWhite, linkIconWhite, unlinkIconWhite, horizontalFlipIcon;
    public PImage verticalFlipIcon, nanocompLogo, displaySizeIcon;
    
    public SpriteCenter(){
        nanoArrowUpIconWhite = loadImage("Sprites/arrowUpIconWhite.png");
        nanoArrowUpIconWhite.resize(15,15);
        nanocompLogo = loadImage("Sprites/nanocompLogo.png");
        nanocompLogo.resize(100,0);
        nanoArrowDownIconWhite = loadImage("Sprites/arrowDownIconWhite.png");
        nanoArrowDownIconWhite.resize(15,15);
        arrowUpIconWhite = loadImage("Sprites/arrowUpIconWhite.png");
        arrowUpIconWhite.resize(25,25);
        arrowDownIconWhite = loadImage("Sprites/arrowDownIconWhite.png");
        arrowDownIconWhite.resize(25,25);
        copyIconWhite = loadImage("Sprites/copyIconWhite.png");
        copyIconWhite.resize(35,35);
        displaySizeIcon = loadImage("Sprites/displaySizeIconWhite.png");
        displaySizeIcon.resize(35,35);
        cancelIconWhite = loadImage("Sprites/cancelIconWhite.png");
        cancelIconWhite.resize(20,20);
        horizontalFlipIcon = loadImage("Sprites/horizontalFlipIcon.png");
        horizontalFlipIcon.resize(35,35);
        verticalFlipIcon = loadImage("Sprites/verticalFlipIcon.png");
        verticalFlipIcon.resize(35,35);
        cutIconWhite = loadImage("Sprites/cutIconWhite.png");
        cutIconWhite.resize(35,35);
        linkIconWhite = loadImage("Sprites/linkIconWhite.png");
        linkIconWhite.resize(35,35);
        unlinkIconWhite = loadImage("Sprites/unlinkIconWhite.png");
        unlinkIconWhite.resize(35,35);
        openIconWhite = loadImage("Sprites/openIconWhite.png");
        openIconWhite.resize(35,35);
        smallOpenIconWhite = loadImage("Sprites/openIconWhite.png");
        smallOpenIconWhite.resize(20,20);
        timelineIconWhite = loadImage("Sprites/timelineIconWhite.png");
        timelineIconWhite.resize(25,25);
        saveIconWhite = loadImage("Sprites/saveIconWhite.png");
        saveIconWhite.resize(35,35);
        magnetIconWhite = loadImage("Sprites/magnetIconWhite.png");
        magnetIconWhite.resize(35,35);
        zoneViewIconWhite = loadImage("Sprites/zoneViewIconWhite.png");
        zoneViewIconWhite.resize(35,35);
        smallSaveIconWhite = loadImage("Sprites/saveIconWhite.png");
        smallSaveIconWhite.resize(20,20);
        smallSaveTemplateIconWhite = loadImage("Sprites/saveTemplateIconWhite.png");
        smallSaveTemplateIconWhite.resize(20,20);
        saveAsIconWhite = loadImage("Sprites/saveAsIconWhite.png");
        saveAsIconWhite.resize(35,35);
        medSaveAsIconWhite = loadImage("Sprites/saveAsIconWhite.png");
        medSaveAsIconWhite.resize(20,20);
        newIconWhite = loadImage("Sprites/newIconWhite.png");
        newIconWhite.resize(35,35);
        smallNewIconWhite = loadImage("Sprites/newIconWhite.png");
        smallNewIconWhite.resize(20,20);
        nanoNewIconWhite = loadImage("Sprites/newIconWhite.png");
        nanoNewIconWhite.resize(15,15);
        lineAddWhite = loadImage("Sprites/lineAddWhite.png");
        lineAddWhite.resize(35,35);
        editIconWhite = loadImage("Sprites/editIconWhite.png");
        editIconWhite.resize(35,35);
        smallEditIconWhite = loadImage("Sprites/editIconWhite.png");
        smallEditIconWhite.resize(20,20);
        nanoEditIconWhite = loadImage("Sprites/editIconWhite.png");
        nanoEditIconWhite.resize(15,15);
        moveIconWhite = loadImage("Sprites/moveIconWhite.png");
        moveIconWhite.resize(35,35);
        deleteIconWhite = loadImage("Sprites/deleteIconWhite.png");
        deleteIconWhite.resize(35,35);
        smallDeleteIconWhite = loadImage("Sprites/deleteIconWhite.png");
        smallDeleteIconWhite.resize(20,20);
        nanoDeleteIconWhite = loadImage("Sprites/deleteIconWhite.png");
        nanoDeleteIconWhite.resize(15,15);
        pinIconWhite = loadImage("Sprites/pinIconWhite.png");
        pinIconWhite.resize(35,35);
        pasteIconWhite = loadImage("Sprites/pasteIconWhite.png");
        pasteIconWhite.resize(35,35);
        groupIconWhite = loadImage("Sprites/groupIconWhite.png");
        groupIconWhite.resize(35,35);
        gridIconWhite = loadImage("Sprites/gridIconWhite.png");
        gridIconWhite.resize(35,35);
        zoomInIconWhite = loadImage("Sprites/zoomInIconWhite.png");
        zoomInIconWhite.resize(35,35);
        zoomOutIconWhite = loadImage("Sprites/zoomOutIconWhite.png");
        zoomOutIconWhite.resize(35,35);
        bulletsIconWhite = loadImage("Sprites/bulletsIconWhite.png");
        bulletsIconWhite.resize(35,35);
        lightIconWhite = loadImage("Sprites/lightIconWhite.png");
        lightIconWhite.resize(35,35);
        zoneUpIconWhite = loadImage("Sprites/zoneUpIconWhite.png");
        zoneUpIconWhite.resize(35,35);
        nanoZoneUpIconWhite = loadImage("Sprites/zoneUpIconWhite.png");
        nanoZoneUpIconWhite.resize(15,15);
        zoneDownIconWhite = loadImage("Sprites/zoneDownIconWhite.png");
        zoneDownIconWhite.resize(35,35);
        nanoZoneDownIconWhite = loadImage("Sprites/zoneDownIconWhite.png");
        nanoZoneDownIconWhite.resize(15,15);
        undoIconWhite = loadImage("Sprites/undoIconWhite.png");
        undoIconWhite.resize(35,35);
        redoIconWhite = loadImage("Sprites/redoIconWhite.png");
        redoIconWhite.resize(35,35);
        smallDefaultIconWhite = loadImage("Sprites/defaultIconWhite.png");
        smallDefaultIconWhite.resize(20,20);
        orangeArrowDownIcon = loadImage("Sprites/orangeArrowDownIcon.png");
        orangeArrowDownIcon.resize(10,10);
        orangeArrowUpIcon = loadImage("Sprites/orangeArrowUpIcon.png");
        orangeArrowUpIcon.resize(10,10);
        orangeArrowLeftIcon = loadImage("Sprites/orangeArrowLeftIcon.png");
        orangeArrowLeftIcon.resize(10,10);
        orangeArrowRightIcon = loadImage("Sprites/orangeArrowRightIcon.png");
        orangeArrowRightIcon.resize(10,10);
        forwardIconWhite = loadImage("Sprites/forwardIconWhite.png");
        forwardIconWhite.resize(25,25);
        backwardIconWhite = loadImage("Sprites/backwardIconWhite.png");
        backwardIconWhite.resize(25,25);
        playIconWhite = loadImage("Sprites/playIconWhite.png");
        playIconWhite.resize(25,25);
        pauseIconWhite = loadImage("Sprites/pauseIconWhite.png");
        pauseIconWhite.resize(25,25);
        stopIconWhite = loadImage("Sprites/stopIconWhite.png");
        stopIconWhite.resize(25,25);
        simulationIconWhite = loadImage("Sprites/simulationIconWhite.png");
        simulationIconWhite.resize(25,25);
        chartIconWhite = loadImage("Sprites/chartIconWhite.png");
        chartIconWhite.resize(25,25);
        exportGifIconWhite = loadImage("Sprites/exportGifIconWhite.png");
        exportGifIconWhite.resize(25,25);
    }
}
class StructurePanel{
    float x, y, w, h;
    int foldSize;
    ArrayList <TextButton> structuresButtons;
    ArrayList <Button> delete;
    Scrollbar scroll;
    int selectedStructure, randomName;
    int panelColor, textColor;
    Button editButton, saveTemplateButton, saveButton, importStructures;
    boolean isEditing;
    SubstrateGrid substrateGrid;
    
    StructurePanel(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        textSize(fontSz);
        foldSize = PApplet.parseInt((h-(textAscent() + textDescent())-35)/(textAscent() + textDescent()+5));
        scroll = new Scrollbar(x+w-20, y+textAscent()+textDescent()+10, 20, h-(textAscent()+textDescent())-35, 1, foldSize, true);
        selectedStructure = -1;
        randomName = 0;
        structuresButtons = new ArrayList<TextButton>();
        delete = new ArrayList<Button>();
        panelColor = color(45,80,22);
        textColor = color(255,255,255);
        isEditing = false;
        
        editButton = new Button("Edit", "Enables the structure editing", sprites.smallEditIconWhite, x+w-30, y+h-20);
        editButton.explanationOnRight = false;
        saveButton = new Button("Save", "Disables the structure editing, saving all changes", sprites.smallSaveIconWhite, x+w-30, y+h-20);
        saveButton.isValid = false;
        saveButton.explanationOnRight = false;
        saveTemplateButton = new Button("Save Template", "Saves the selected magnets as a new structure", sprites.smallSaveTemplateIconWhite, x+w-55, y+h-20);
        saveTemplateButton.explanationOnRight = false;
        importStructures = new Button("Import Structures", "Import the structures from the selected file", sprites.smallOpenIconWhite, x+w-80, y+h-20);
        importStructures.explanationOnRight = false;
    }
    
    public void addStructure(String label, String structure){
        for(int i=0; i<structuresButtons.size(); i++){
            if(structuresButtons.get(i).getText().equals(label)){
                structuresButtons.get(i).setButtonContent(structure);
                return;
            }
        }
        TextButton aux = new TextButton(label, 0, 0, w-45);
        aux.setButtonContent(structure);
        structuresButtons.add(aux);
        delete.add(new Button("Delete", "Delete the structure from the list", sprites.nanoDeleteIconWhite, 0, 0));
        delete.get(delete.size()-1).explanationOnRight = false;
        scroll.increaseMaxIndex();
    }
    
    public void setSubstrateGrid(SubstrateGrid substrateGrid){
        this.substrateGrid = substrateGrid;
    }
    
    public void drawSelf(){
        textSize(fontSz);
        float aux = textAscent()+textDescent()+5;
        float auxY = y+aux+5;
        fill(panelColor);
        stroke(panelColor);
        rect(x, y, w, h, 15, 15, 0, 0);

        fill(textColor);
        noStroke();
        text("Structures Panel", x+10+((w-20)/2-textWidth("Structures Panel")/2), y+5+fontSz);
        int currIndex = scroll.getIndex();
        for(int i=0; i<structuresButtons.size(); i++){
            structuresButtons.get(i).isValid = false;
            delete.get(i).isValid = false;
        }
        if(currIndex >= 0){
            for(int iAux=0; iAux<foldSize; iAux++){
                if(structuresButtons.size() <= iAux+currIndex)
                    break;
                int i = iAux + currIndex;
                structuresButtons.get(i).setPosition(x+10, auxY);
                if(isEditing){
                    structuresButtons.get(i).setWidth(w-60);
                    structuresButtons.get(i).drawSelf();
                    structuresButtons.get(i).isValid = true;
                    delete.get(i).setPosition(x+w-45, (aux-20)/2+auxY);
                    delete.get(i).isValid = true;
                    delete.get(i).drawSelf();
                    delete.get(i).onMouseOverMethod();
                }
                else{
                    structuresButtons.get(i).setWidth(w-35);
                    structuresButtons.get(i).isTyping = false;
                    structuresButtons.get(i).drawSelf();
                    structuresButtons.get(i).isValid = true;
                }
                
                auxY += aux;
            }
        }
        saveTemplateButton.drawSelf();
        importStructures.drawSelf();
        importStructures.onMouseOverMethod();
        saveTemplateButton.onMouseOverMethod();
        if(isEditing){
            saveButton.drawSelf();
            saveButton.isValid = true;
            editButton.isValid = false;
            saveButton.onMouseOverMethod();
        }else{
            editButton.isTransparent = structuresButtons.size() <= 0;
            editButton.drawSelf();
            editButton.isValid = true;
            saveButton.isValid = false;
            editButton.onMouseOverMethod();
        }
        scroll.drawSelf();
    }
    
    public void loadStructures(ArrayList<String> structures){
        reset();
        importStructures(structures);
    }    
    
    public void importStructures(ArrayList<String> structures){
        for(String structure : structures){
            String name = structure.substring(0, structure.indexOf(";"));
            structure = structure.substring(structure.indexOf(";")+1, structure.length());
            addStructure(name, structure);
        }
    }
    
    public void reset(){
        structuresButtons.clear();
        delete.clear();
        selectedStructure = -1;
        randomName = 0;
        isEditing = false;
    }
    
    public ArrayList<String> getStructures(){
        ArrayList<String> str = new ArrayList<String>();
        for(TextButton b : structuresButtons){
            str.add(b.getText() + ";" + b.getButtonContent());
        }
        return str;
    }
    
    public String getSelectedStructure(){
        if(selectedStructure == -1 || isEditing)
            return "";
        return structuresButtons.get(selectedStructure).getButtonContent();
    }
    
    public void keyPressedMethod(){
        if(ctrlPressed && PApplet.parseInt(key) == 20){
            if(!substrateGrid.getSelectedStructure().equals("")){
                while(true){
                    String name = "Structure_" + randomName;
                    Boolean equal = false;
                    for(TextButton structure : structuresButtons){
                        if(structure.getText().equals(name))
                            equal = true;
                    }
                    if(!equal)
                        break;
                    else
                        randomName++;
                }
                addStructure("Structure_" + randomName, substrateGrid.getSelectedStructure());
                randomName++;
            }
        }
        if(isEditing){
            for(int i=0; i<structuresButtons.size(); i++){
                if(structuresButtons.get(i).keyPressedMethod()){
                    structuresButtons.get(i).isTyping = true;
                }
            }
        }
    }
    
    public void mouseDraggedMethod(){
        scroll.mouseDraggedMethod();
    }
    
    public void mouseWheelMethod(float v){
        scroll.mouseWheelMethod(v);
    }
    
    public void mousePressedMethod(){
        scroll.mousePressedMethod();
        if(importStructures.mousePressedMethod()){
            importStructures.deactivate();
            File start = new File(sketchPath(""));
            selectFolder("Select a folder to import the project's structures", "importStructures", start);
            return;
        }
        if(saveTemplateButton.mousePressedMethod()){
            saveTemplateButton.deactivate();
            if(!substrateGrid.getSelectedStructure().equals("")){
                while(true){
                    String name = "Structure_" + randomName;
                    Boolean equal = false;
                    for(TextButton structure : structuresButtons){
                        if(structure.getText().equals(name))
                            equal = true;
                    }
                    if(!equal)
                        break;
                    else
                        randomName++;
                }
                addStructure("Structure_" + randomName, substrateGrid.getSelectedStructure());
                randomName++;
            }
        }
        if(editButton.mousePressedMethod()){
            isEditing = true;
            editButton.deactivate();
        }
        if(saveButton.mousePressedMethod()){
            isEditing = false;
            selectedStructure = -1;
            saveButton.deactivate();
            for(int i=0; i<structuresButtons.size(); i++){
                if(structuresButtons.get(i).getText().equals("")){
                    structuresButtons.get(i).setText("Structure_" + randomName);
                    randomName++;
                }
            }
        }
        for(int i=0; i<structuresButtons.size(); i++){
            if(structuresButtons.get(i).mousePressedMethod())
                selectedStructure = i;
        }
        if(selectedStructure >= 0 && !structuresButtons.get(selectedStructure).isSelected)
            selectedStructure = -1;
        for(int i=0; i<structuresButtons.size(); i++){
            if(i != selectedStructure)
                structuresButtons.get(i).deactivate();
        }
        for(int i=0; i<delete.size(); i++){
            if(delete.get(i).mousePressedMethod()){
                delete.remove(i);
                structuresButtons.remove(i);
                scroll.decreaseMaxIndex();
                return;
            }
        }
    }
}


class SubstrateGrid{
    float x, y, w, h, cellW, cellH, gridW, gridH, leftHiddenAreaW, leftHiddenAreaH, rightHiddenAreaW, rightHiddenAreaH, bulletVS, bulletHS, normalization, initMouseX, initMouseY;
    int zoomFactor, xPos, yPos, randomName = 0, randomGroup = 0;
    int darkBG, lightBG, darkRuler, lightRuler, darkBullet, lightBullet;
    boolean isLightColor, isLeftHidden, isRightHidden, isRulerActive, isBulletActive, isPasting = false, isMoving = false, isEditingMagnet = false, zoneViewMode = true;
    HitBox fullAreaHitbox, leftHidden, rightHidden;
    Scrollbar vScroll, hScroll;
    HashMap<String, Magnet> magnets;
    ArrayList<Magnet> selectedMagnets;
    ArrayList<String> zoneNames;
    StructurePanel structurePanel;
    ZonePanel zonePanel;
    String toPasteStructure = "";
    
    SubstrateGrid(float x, float y, float w, float h, float cellW, float cellH, float gridW, float gridH){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        zoomFactor = 10;
        structurePanel = null;
        setGridSizes(gridW, gridH, cellW, cellH);
        
        isLightColor = true;
        darkBG = color(128,128,128);
        darkRuler = color(242,242,242);
        darkBullet = color(242,242,242);
        lightBG = color(255,255,255);
        lightRuler = color(128,128,128);
        lightBullet = color(128,128,128);
        
        fullAreaHitbox = new HitBox(x, y, w-20, h-20);
        this.w -= 20;
        this.h -= 20;
        
        isLeftHidden = false;
        isRightHidden = false;
        isRulerActive = false;
        isBulletActive = true;
        
        magnets = new HashMap<String, Magnet>();
        selectedMagnets = new ArrayList<Magnet>();
        zoneNames = new ArrayList<String>();
    }
    
    public void reset(){
        zoomFactor = 10;
        magnets.clear();
        selectedMagnets.clear();
        zoneNames = null;
    }
    
    public void setZonePanel(ZonePanel z){
        zonePanel = z;
    }
    
    public void updateZoneNames(ArrayList<String> zoneNames){
        this.zoneNames = zoneNames;
        for(Magnet mag : magnets.values()){
            if(!zoneNames.contains(mag.getZoneName())){
                mag.changeZone("none",255);
            } else{
                mag.changeZone(mag.zone, zonePanel.getZoneColor(mag.zone));
            }
        }
    }
    
    public void setStructurePanel(StructurePanel sp){
        structurePanel = sp;
    }
    
    public void setBulletSpacing(float hs, float vs){
        bulletHS = hs;
        bulletVS = vs;
    }
    
    public void addMagnet(String label, String structure){
        if(structure.contains(":")){
            ArrayList <Magnet> strMags = new ArrayList<Magnet>();
            String [] parts = structure.split(":");
            int index = 0;
            for(String str : parts){
                Magnet aux = new Magnet(str, label + "_" + index, zoneViewMode);
                index++;
                for(Magnet mag : magnets.values())
                    if(aux.collision(mag))
                        return;
                strMags.add(aux);
            }
            index = 0;
            for(Magnet mag : strMags){
                magnets.put(label + "_" + index, mag);
                index++;
            }
        } else{
            Magnet aux =  new Magnet(structure, label, zoneViewMode);
            for(Magnet mag : magnets.values())
                if(aux.collision(mag))
                    return;
            magnets.put(label, aux);
        }
    }
    
    public void setGridSizes(float gridW, float gridH, float cellW, float cellH){
        normalization = ((w/(gridW/cellW)) < (h/(gridH/cellH)))?(w/(gridW/cellW)):(h/(gridH/cellH));
        this.cellW = cellW;
        this.cellH = cellH;
        this.gridW = gridW;
        this.gridH = gridH;
        this.w += 20;
        this.h += 20;
        vScroll = new Scrollbar(this.x+this.w-20, this.y, 20, this.h-20, PApplet.parseInt(this.gridH/this.cellH), PApplet.parseInt(this.h/normalization*this.zoomFactor/10), true);
        vScroll.isFlipped = true;
        hScroll = new Scrollbar(this.x, this.y+this.h-20, this.w-20, 20, PApplet.parseInt(this.gridW/this.cellW), PApplet.parseInt(this.w/normalization*this.zoomFactor/10), false);
        this.w -= 20;
        this.h -= 20;
    }
    
    public void toggleBullet(){
        isBulletActive = !isBulletActive;
    }
    
    public void setHiddenDimensions(float lh, float lw, float rh, float rw){
        leftHiddenAreaH = lh;
        leftHiddenAreaW = lw;
        rightHiddenAreaH = rh;
        rightHiddenAreaW = rw;
        leftHidden = new HitBox(x, y+h+20-lh, lw, lh);
        rightHidden = new HitBox(x+w-rw-4, y+h+20-rh, rw+4, rh);
    }
    
    public void deleteSelectedMagnets(){
        for(Magnet mag : selectedMagnets){
            magnets.remove(mag.name);
        }
        selectedMagnets.clear();
    }
    
    public void copySelectedMagnetsToClipBoard(){
        toPasteStructure = getSelectedStructure();
    }
    
    public void togglePasteState(){
        isPasting = !isPasting;
        if(toPasteStructure.equals(""))
            isPasting = false;
    }
    
    public void groupSelectedMagnets(){
        for(Magnet mag : selectedMagnets){
            mag.addToGroup("RandomGroupName_"+randomGroup);
        }
        randomGroup++;
    }
    
    public void linkSelectedMagnets(){
        if(selectedMagnets.size() < 2){
            unselectMagnets();
            return;
        }
        Magnet original = selectedMagnets.get(0);
        for(int i=1; i<selectedMagnets.size(); i++){
            if(!original.getMimic().equals(selectedMagnets.get(i).name) && !original.name.equals(selectedMagnets.get(i).name))
                selectedMagnets.get(i).addMimic(selectedMagnets.get(0).name);
        }
        unselectMagnets();
    }
    
    public void unlinkSelectedMagnets(){
        for(Magnet mag : selectedMagnets){
            mag.removeMimic();
        }
        unselectMagnets();
    }
    
    public void setMagnetMagnetization(String label, float magX, float magY){
        if(magnets.get(label) == null)
            return;
        magnets.get(label).setMagnetization(magX, magY);
    }
    
    public void loadMagnetProperties(ArrayList<String> magnets){
        reset();
        for(String magnet : magnets){
            String name = magnet.substring(0, magnet.indexOf(";"));
            magnet = magnet.substring(magnet.indexOf(";")+1, magnet.length());
            addMagnet(name, magnet);
        }
    }
    
    public ArrayList<String> getMagnetsProperties(){
        ArrayList<String> properties = new ArrayList<String>();
        for(Magnet mag : magnets.values()){
            properties.add(mag.name + ";" + mag.magStr);
        }
        return properties;
    }
    
    public String getSelectedStructure(){
        if(selectedMagnets.size() == 0)
            return "";
        String structure = "";
        for(Magnet mag : selectedMagnets){
            structure += mag.magStr + ":";
        }
        structure = structure.substring(0, structure.length()-1);
        return structure;
    }
    
    public String getSelectedMagnetsNames(){
        String names = "";
        for(Magnet mag : selectedMagnets){
            names += mag.name + " ";
        }
        if(!names.equals(""))
            names = names.substring(0,names.length()-1);
        return names;
    }
    
    public void unselectMagnets(){
        for(Magnet mag : selectedMagnets){
            mag.isSelected = false;
        }
        selectedMagnets.clear();
    }
    
    public void editSelectedMagnets(String newStrucutre, String oldName){
        magnets.remove(oldName);
        String name = newStrucutre.substring(0, newStrucutre.indexOf(";"));
        newStrucutre = newStrucutre.substring(newStrucutre.indexOf(";")+1, newStrucutre.length());
        addMagnet(name, newStrucutre);
    }
    
    public void changeSelectedMagnetsZone(boolean isUP){
        if(zoneNames.size() == 0)
            return;
        for(Magnet mag : selectedMagnets){
            int i;
            for(i=0; i<zoneNames.size(); i++){
                if(zoneNames.get(i).equals(mag.getZoneName()))
                    break;
            }
            if(i == zoneNames.size()){
                i--;
            }
            if(isUP)
                i = (i+1)%zoneNames.size();
            else{
                i--;
                if(i < 0)
                    i = zoneNames.size()-1;
            }
            mag.changeZone(zoneNames.get(i),zonePanel.getZoneColor(zoneNames.get(i)));
        }
    }
    
    public void changeSelectedMagnetsMagnetization(){
        for(Magnet mag : selectedMagnets){
            float xMag = mag.getXMag(), yMag = mag.getYMag();
            if(abs(xMag) > abs(yMag)){
                if(xMag > 0){
                    mag.setMagnetizationInStructure(0.141f,-0.99f);
                } else{
                    mag.setMagnetizationInStructure(0.141f,0.99f);
                }
            } else{
                if(yMag > 0){
                    mag.setMagnetizationInStructure(0.99f,0.141f);
                } else{
                    mag.setMagnetizationInStructure(-0.99f,0.141f);
                }
            }
        }
    }
    
    public void flipSelectedMagnets(boolean isVerticalFlip){
        for(Magnet mag : selectedMagnets){
            if(isVerticalFlip){
                mag.verticalFlip();
            } else{
                mag.horizontalFlip();
            }
        }
    }
    
    public void toggleZoneViewMode(){
        zoneViewMode = !zoneViewMode;
        for(Magnet mag : magnets.values()){
            mag.zoneViewMode = zoneViewMode;
        }
    }
    
    public void drawSelf(){
        if(isLightColor){
            fill(lightBG);
            stroke(lightBG);
            rect(x, y, w, h);
        } else{
            fill(darkBG);
            stroke(darkBG);
            rect(x, y, w, h);
        }
        
        float xOrigin = hScroll.getIndex()*cellW, yOrigin = vScroll.getIndex()*cellH;
        
        if(isRulerActive){
            float cont = xOrigin;
            float cellPxW = (normalization)*zoomFactor/10;
            float auxX = x;
            float cellPxH = (normalization)*zoomFactor/10;
            float auxY = y+h;
            if(isLightColor)
                stroke(lightRuler);
            else
                stroke(darkRuler);
            while(auxX < x+w && cont <= gridW){
                float temp = ((gridH-yOrigin)/cellH)*cellPxH;
                line(auxX, y+h, auxX, y+h-((temp>h)?h:temp));
                auxX += cellPxW;
                cont += cellW;
            }
            cont = yOrigin;
            while(auxY > y && cont <= gridH){
                float temp = ((gridW-xOrigin)/cellW)*cellPxW;
                line(x, auxY, x+((temp>w)?w:temp), auxY);
                auxY -= cellPxH;
                cont += cellH;
            }
        }
        
        if(isBulletActive){
            if(isLightColor){
                fill(lightBullet);
                stroke(lightBullet);
            } else{
                fill(darkBullet);
                stroke(darkBullet);
            }
            float contW = bulletHS/2, contH = bulletVS/2;
            float bulletPxW = (normalization)*zoomFactor/10;
            float auxX = -(xOrigin+bulletHS/2);
            while(auxX < 0)
                auxX += bulletHS;
            auxX = auxX/cellW*(normalization)*zoomFactor/10 + x;
            float bulletPxH = (normalization)*zoomFactor/10;
            float auxY = yOrigin+bulletVS/2;
            while(auxY > 0)
                auxY -= bulletVS;
            auxY = auxY/cellH*(normalization)*zoomFactor/10 + y + h;
            while(auxY >= y && contH <= gridH){
                while(auxX-bulletPxW <= x+w && contW <= gridW){
                    ellipseMode(CORNER);
                    ellipse(auxX-bulletPxW, auxY, bulletPxW, bulletPxH);
                    auxX += (((bulletHS/cellW)*normalization)*zoomFactor/10);
                    contW  += bulletHS;
                }
                contW = bulletHS/2;
                auxX = -(xOrigin+bulletHS/2);
                while(auxX < 0)
                    auxX += bulletHS;
                auxX = auxX/cellW*(normalization)*zoomFactor/10 + x;
                auxY -= (((bulletVS/cellH)*normalization)*zoomFactor/10);
                contH += bulletVS;
            }
        }

        try{
            for(Magnet mag : magnets.values()){
                mag.drawSelf(xOrigin, yOrigin, normalization, zoomFactor, x, y, w, h, cellW, cellH);
            }
            for(Magnet mag : magnets.values()){
                if(!mag.getMimic().equals("")){
                    Magnet mimicMag = magnets.get(mag.getMimic());
                    if(mimicMag == null){
                        mag.removeMimic();
                    } else{
                        float c1x = mag.getPixelCenterX(xOrigin, cellW, normalization, zoomFactor, x);
                        float c1y = mag.getPixelCenterY(yOrigin, cellH, normalization, zoomFactor, y, h);
                        float c2x = mimicMag.getPixelCenterX(xOrigin, cellW, normalization, zoomFactor, x);
                        float c2y = mimicMag.getPixelCenterY(yOrigin, cellH, normalization, zoomFactor, y, h);
                        fill(0,0,0,125);
                        stroke(0,0,0,125);
                        strokeWeight(5);
                        ellipse(c2x-5, c2y-5, 10, 10);
                        line(c2x, c2y, c1x, c1y);
                        strokeWeight(1);
                    }
                }
            }
        } catch(Exception e){
        }
        
        onMouseOverMethod();
        
        vScroll.drawSelf();
        hScroll.drawSelf();

        if(ctrlPressed && mousePressed){
            fill(255,255,255,125);
            stroke(0, 0, 0, 125);
            rect(initMouseX, initMouseY, (mouseX-initMouseX), (mouseY-initMouseY));
        }
    }
    
    public void toggleMoving(){
        isMoving = !isMoving;
    }
    
    public void onMouseOverMethod(){
        if(!fullAreaHitbox.collision(mouseX, mouseY) || (isLeftHidden && leftHidden.collision(mouseX, mouseY)) || (isRightHidden && rightHidden.collision(mouseX, mouseY))){
            cursor(ARROW);
            return;
        }
        
        if(isMoving && mousePressed == false)
            cursor(HAND);
        else if(isMoving && mousePressed == true)
            cursor(MOVE);
        else
            cursor(ARROW);
            
        if((structurePanel != null && !structurePanel.getSelectedStructure().equals("")) || isPasting){
            float xOrigin = hScroll.getIndex()*cellW, yOrigin = vScroll.getIndex()*cellH;
            String [] magnetsStr;
            if(isPasting){
                magnetsStr = toPasteStructure.split(":");
            }else{
                magnetsStr = structurePanel.getSelectedStructure().split(":");
            }
            float deltaX = (isBulletActive)?(PApplet.parseInt((xOrigin+(((mouseX/scaleFactor-x)*10)/normalization/zoomFactor)*cellW)/bulletHS)*bulletHS+bulletHS/2-cellH/2):(xOrigin+(((mouseX/scaleFactor-x)*10)/normalization/zoomFactor)*cellW);
            float deltaY = (isBulletActive)?(PApplet.parseInt((yOrigin-(((mouseY/scaleFactor-y-h)*10)/normalization/zoomFactor)*cellW)/bulletVS)*bulletVS+bulletVS/2-cellW/2):(yOrigin-(((mouseY/scaleFactor-y-h)*10)/normalization/zoomFactor)*cellW);
            float xRef = Float.parseFloat(magnetsStr[0].split(";")[9].split(",")[0]);
            float yRef = Float.parseFloat(magnetsStr[0].split(";")[9].split(",")[1]);
            for(String structure : magnetsStr){
                String parts[] = structure.split(";");
                
                parts[9] = "" + (Float.parseFloat(parts[9].split(",")[0])-xRef+deltaX) + "," + (Float.parseFloat(parts[9].split(",")[1])-yRef+deltaY);

                structure = "";
                for(int i=0; i<parts.length; i++){
                    structure += parts[i] + ";";
                }
                Magnet magAux = new Magnet(structure, "Magnet_Aux", zoneViewMode);
                magAux.isTransparent = true;
                magAux.drawSelf(xOrigin, yOrigin, normalization, zoomFactor, x, y, w, h, cellW, cellH);
            }
        }
    }
    
    public void mousePressedMethod(){
        if(isMoving || ctrlPressed){
            initMouseX = mouseX;
            initMouseY = mouseY;
            return;
        }
        vScroll.mousePressedMethod();
        hScroll.mousePressedMethod();
        if(isLeftHidden && leftHidden.collision(mouseX, mouseY))
            return;
        if(isRightHidden && rightHidden.collision(mouseX, mouseY))
            return;
        if(!fullAreaHitbox.collision(mouseX, mouseY) || isEditingMagnet)
            return;
        if((structurePanel != null && !structurePanel.getSelectedStructure().equals("")) || isPasting){
            for(Magnet mag : selectedMagnets)
                mag.isSelected = false;
            selectedMagnets.clear();
            float xOrigin = hScroll.getIndex()*cellW, yOrigin = vScroll.getIndex()*cellH;
            String [] magnetsStr;
            if(isPasting){
                magnetsStr = toPasteStructure.split(":");
            }else{
                magnetsStr = structurePanel.getSelectedStructure().split(":");
            }
            float deltaX = (isBulletActive)?(PApplet.parseInt((xOrigin+(((mouseX/scaleFactor-x)*10)/normalization/zoomFactor)*cellW)/bulletHS)*bulletHS+bulletHS/2-cellH/2):(xOrigin+(((mouseX/scaleFactor-x)*10)/normalization/zoomFactor)*cellW);
            float deltaY = (isBulletActive)?(PApplet.parseInt((yOrigin-(((mouseY/scaleFactor-y-h)*10)/normalization/zoomFactor)*cellW)/bulletVS)*bulletVS+bulletVS/2-cellW/2):(yOrigin-(((mouseY/scaleFactor-y-h)*10)/normalization/zoomFactor)*cellW);
            float xRef = Float.parseFloat(magnetsStr[0].split(";")[9].split(",")[0]);
            float yRef = Float.parseFloat(magnetsStr[0].split(";")[9].split(",")[1]);
            String fullStr = "";
            for(String structure : magnetsStr){
                String parts[] = structure.split(";");
                float newMagX = (Float.parseFloat(parts[9].split(",")[0])-xRef+deltaX);
                float newMagY = (Float.parseFloat(parts[9].split(",")[1])-yRef+deltaY);
                if(newMagX < Float.parseFloat(parts[4])/2 || newMagX > gridW - Float.parseFloat(parts[4])/2)
                    return;
                if(newMagY < Float.parseFloat(parts[5])/2 || newMagY > gridH - Float.parseFloat(parts[5])/2)
                    return;
                parts[9] = "" + newMagX + "," + newMagY;
                structure = "";
                for(int i=0; i<parts.length; i++){
                    structure += parts[i] + ";";
                }
                fullStr += structure + ":";
            }
            fullStr = fullStr.substring(0, fullStr.length()-1);
            addMagnet("Magnet_" + randomName, fullStr);
            randomName++;
            return;
        }
        if(!shiftPressed){
            for(Magnet mag : selectedMagnets)
                mag.isSelected = false;
            selectedMagnets.clear();
        }
        for(Magnet mag : magnets.values()){
            if(mag.collision(mouseX, mouseY)){
                mag.isSelected = true;
                if(!mag.getGroup().equals("")){
                    for(Magnet otherMag : magnets.values()){
                        if(otherMag.getGroup().equals(mag.getGroup())){
                            otherMag.isSelected = true;
                            selectedMagnets.add(otherMag);
                        }
                    }
                } else{
                    selectedMagnets.add(mag);
                }
            }
        }
    }
    
    public void mouseDraggedMethod(){
        vScroll.mouseDraggedMethod();
        hScroll.mouseDraggedMethod();
        if(isLeftHidden && leftHidden.collision(mouseX, mouseY))
            return;
        if(isRightHidden && rightHidden.collision(mouseX, mouseY))
            return;
        if(!fullAreaHitbox.collision(mouseX, mouseY))
            return;
        if(isMoving){
            if(mouseX < initMouseX-10){
                hScroll.incrementIndex();
            } else if(mouseX > initMouseX+10){
                hScroll.decreaseIndex();
            }
            if(mouseY > initMouseY+10){
                vScroll.incrementIndex();
            } else if(mouseY < initMouseY-10){
                vScroll.decreaseIndex();
            }
            return;
        }
        if(ctrlPressed && mousePressed){
            if(!shiftPressed)
                unselectMagnets();
            HitBox hit = new HitBox(((mouseX-initMouseX > 0)?initMouseX:mouseX), ((mouseY-initMouseY > 0)?initMouseY:mouseY), ((mouseX-initMouseX>0)?(mouseX-initMouseX):(-mouseX+initMouseX)), ((mouseY-initMouseY>0)?(mouseY-initMouseY):(-mouseY+initMouseY)));
            for(Magnet mag : magnets.values()){
                if(mag.collision(hit)){
                    mag.isSelected = true;
                    selectedMagnets.add(mag);
                }
            }
        }
    }
    
    public void toggleHideGrid(String side){
        if(side.equals("left")){
            isLeftHidden = !isLeftHidden;
        } else if(side.equals("right")){
            isRightHidden = ! isRightHidden;
        }
        if(isLeftHidden & isRightHidden){
            hScroll.redefine(x+leftHiddenAreaW, y+h, w-leftHiddenAreaW-rightHiddenAreaW, 20, PApplet.parseInt(w/(normalization*zoomFactor/10)));
        } else if(isLeftHidden){
            hScroll.redefine(x+leftHiddenAreaW, y+h, w-leftHiddenAreaW, 20, PApplet.parseInt(w/(normalization*zoomFactor/10)));
        } else if(isRightHidden){
            hScroll.redefine(x, y+h, w-rightHiddenAreaW, 20, PApplet.parseInt(w/(normalization*zoomFactor/10)));
        } else{
            hScroll.redefine(x, y+h, w, 20, PApplet.parseInt(w/(normalization*zoomFactor/10)));
        }
    }
    
    public void zoomIn(){
        zoomFactor += 2;
        if(zoomFactor > 500)
            zoomFactor = 500;
        vScroll.redefine(x+w, y, 20, h, PApplet.parseInt(h/(normalization*zoomFactor/10)));
        toggleHideGrid("none");
    }
    
    public void zoomOut(){
        zoomFactor -= 2;
        if(zoomFactor < 10)
            zoomFactor = 10;
        vScroll.redefine(x+w, y, 20, h, PApplet.parseInt(h/(normalization*zoomFactor/10)));
        toggleHideGrid("none");
    }

    public void mouseWheelMethod(float v){
        if(isLeftHidden && leftHidden.collision(mouseX, mouseY))
            return;
        if(isRightHidden && rightHidden.collision(mouseX, mouseY))
            return;
        if(fullAreaHitbox.collision(mouseX,mouseY) && keyPressed == true && keyCode == 17){
            if(v<0){
                zoomIn();
            } else{
                zoomOut();
            }
            return;
        }
        vScroll.mouseWheelMethod(v);
        hScroll.mouseWheelMethod(v);
    }
}

class Magnet{
    float w, h, bottomCut, topCut, xMag, yMag, x, y;
    String magStr, name, groupName, zone, mimic = "";
    int clockZone;
    boolean isTransparent = false, isSelected = false, zoneViewMode = true;
    HitBox hitbox;
    
    /*MagStr = type;clockZone;magnetization;fixed;w;h;tk;tc;bc;position;zoneColor;mimic*/
    
    Magnet(String magStr, String name, boolean viewMode){
        this.magStr = magStr;
        this.zoneViewMode = viewMode;
        this.groupName = "";
        this.name = name;
        String parts[] = magStr.split(";");
        if(parts.length > 11){
            this.mimic = parts[11];
        }
        if(parts[2].contains(",")){
            String [] aux = parts[2].split(",");
            xMag = Float.parseFloat(aux[0]);
            yMag = Float.parseFloat(aux[1]);
        } else{
            yMag = Float.parseFloat(parts[2]);
            xMag = 1-abs(yMag);
        }
        zone = parts[1];
        w = Float.parseFloat(parts[4]);
        h = Float.parseFloat(parts[5]);
        topCut = Float.parseFloat(parts[7]);
        bottomCut = Float.parseFloat(parts[8]);
        String [] aux = parts[9].split(",");
        x = Float.parseFloat(aux[0]);
        y = Float.parseFloat(aux[1]);
        clockZone = Integer.parseInt(parts[10]);
        hitbox = new HitBox(0,0,0,0);
    }
    
    public void editStructure(String newStructure){
        this.magStr = newStructure + ";" + mimic + ";";
        String parts[] = magStr.split(";");
        if(parts[2].contains(",")){
            String [] aux = parts[2].split(",");
            xMag = Float.parseFloat(aux[0]);
            yMag = Float.parseFloat(aux[1]);
        } else{
            yMag = Float.parseFloat(parts[2]);
            xMag = 1-abs(yMag);
        }
        zone = parts[1];
        w = Float.parseFloat(parts[4]);
        h = Float.parseFloat(parts[5]);
        topCut = Float.parseFloat(parts[7]);
        bottomCut = Float.parseFloat(parts[8]);
        String [] aux = parts[9].split(",");
        x = Float.parseFloat(aux[0]);
        y = Float.parseFloat(aux[1]);
        clockZone = Integer.parseInt(parts[10]);
    }
    
    public void horizontalFlip(){
        if(topCut != 0 || bottomCut != 0){
            topCut *= -1;
            bottomCut *= -1;
            String [] parts = magStr.split(";");
            parts[7] = "" + topCut;
            parts[8] = "" + bottomCut;
            magStr = "";
            for(String part : parts){
                magStr += part + ";";
            }
        }
    }
    
    public void verticalFlip(){
        if(topCut != bottomCut){
            float aux = topCut;
            topCut = bottomCut;
            bottomCut = aux;
            String [] parts = magStr.split(";");
            parts[7] = "" + topCut;
            parts[8] = "" + bottomCut;
            magStr = "";
            for(String part : parts){
                magStr += part + ";";
            }
        }
    }
    
    public void addMimic(String mimicId){
        this.mimic = mimicId;
        String [] parts = magStr.split(";");
        if(parts.length > 11){
            parts[11] = mimic;
        }
        magStr = "";
        for(int i=0; i<parts.length; i++){
            magStr += parts[i] + ";";
        }
        if(parts.length <= 11){
            magStr += mimic + ";";
        }
    }
    
    public void removeMimic(){
        this.mimic = "";
        String [] parts = magStr.split(";");
        if(parts.length > 11){
            parts[11] = "";
        }
        magStr = "";
        for(int i=0; i<parts.length; i++){
            magStr += parts[i] + ";";
        }
    }
    
    public String getMimic(){
        return mimic;
    }
    
    public String getZoneName(){
        return zone;
    }
    
    public float getXMag(){
        return this.xMag;
    }
    
    public float getYMag(){
        return this.yMag;
    }
    
    public void setMagnetization(float xMag, float yMag){
        this.xMag = xMag;
        this.yMag = yMag;
    }
    
    public void setMagnetizationInStructure(float xMag, float yMag){
        this.xMag = xMag;
        this.yMag = yMag;
        String [] parts = magStr.split(";");
        if(parts[2].contains(",")){
            parts[2] = xMag + "," + yMag + ",0";
            magStr = "";
            for(int i=0; i<parts.length; i++)
                magStr += parts[i] + ";";
        }
    }
    
    public void changeZone(String zName, Integer zColor){
        String [] parts = magStr.split(";");
        parts[1] = zName;
        zone = zName;
        parts[10] = zColor.toString();
        clockZone = color(zColor);
        magStr = "";
        for(int i=0; i<parts.length; i++)
            magStr += parts[i] + ";";
    }
    
    public void addToGroup(String group){
        this.groupName = group;
    }
    
    public String getGroup(){
        return groupName;
    }
    
    public float sign (float p1x, float p1y, float p2x, float p2y, float p3x, float p3y){
        return (p1x - p3x) * (p2y - p3y) - (p2x - p3x) * (p1y - p3y);
    }
    
    public boolean pointInTriangle(float ptx, float pty, boolean isTopCut){
        float d1, d2, d3;
        boolean has_neg, has_pos;
    
        if(isTopCut){
            d1 = sign(ptx, pty, x-w/2, ((topCut>0)?y-h/2:y-h/2-topCut), x+w/2, ((topCut<0)?y-h/2:y-h/2+topCut));
            d2 = sign(ptx, pty, x+w/2, ((topCut<0)?y-h/2:y-h/2+topCut), ((topCut>0)?x-w/2:x+w/2), y-h/2+abs(topCut));
            d3 = sign(ptx, pty, ((topCut>0)?x-w/2:x+w/2), y-h/2+abs(topCut), x-w/2, ((topCut>0)?y-h/2:y-h/2-topCut));
        }else{
            d1 = sign(ptx, pty, x-w/2, ((bottomCut>0)?y+h/2:y+h/2+bottomCut), x+w/2, ((bottomCut<0)?y+h/2:y+h/2-bottomCut));
            d2 = sign(ptx, pty, x+w/2, ((bottomCut<0)?y+h/2:y+h/2-bottomCut), ((bottomCut>0)?x-w/2:x+w/2), y+h/2-abs(bottomCut));
            d3 = sign(ptx, pty, ((bottomCut>0)?x-w/2:x+w/2), y+h/2-abs(bottomCut), x-w/2, ((bottomCut>0)?y+h/2:y+h/2+bottomCut));
        }
    
        has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0);
        has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0);
    
        return !(has_neg && has_pos);
    }

    public boolean collision(Magnet m){
        if(m.x-m.w/2 <= x+w/2 &&
                m.x+m.w/2 >= x-w/2 &&
                m.y-m.h/2+abs(m.topCut) <= y+h/2-abs(bottomCut) &&
                m.y+m.h/2-abs(m.bottomCut) >= y-h/2+abs(topCut))
                    return true;
        if(m.y > y){
            if(m.pointInTriangle(((topCut>0)?(x-w/2):(x+w/2)), y-h/2, false))
                return true;
        } else{
            if(m.pointInTriangle(((bottomCut>0)?(x-w/2):(x+w/2)), y+h/2, true))
                return true;
        }
        return false;
    }
    
    public boolean collision(float px, float py){
        return hitbox.collision(px, py);
    }
    
    public boolean collision(HitBox hit){
        return hitbox.collision(hit);
    }
        
    public void drawArrow(float x0, float y0, float x1, float y1, float beginHeadSize, float endHeadSize){
        PVector d = new PVector(x1 - x0, y1 - y0);
        d.normalize();

        float coeff = 1.5f;

        strokeCap(SQUARE);
        
        fill((zoneViewMode && !isSelected)?255:0, (isTransparent)?128:255);
        stroke((zoneViewMode && !isSelected)?255:0, (isTransparent)?128:255);
        
        line(x0+d.x*beginHeadSize*coeff/1.0f, 
            y0+d.y*beginHeadSize*coeff/1.0f, 
            x1-d.x*endHeadSize*coeff/1.0f, 
            y1-d.y*endHeadSize*coeff/1.0f);
  
        float angle = atan2(d.y, d.x);
  
        pushMatrix();
        translate(x0, y0);
        rotate(angle+PI);
        triangle(-beginHeadSize*coeff, -beginHeadSize, 
         -beginHeadSize*coeff, beginHeadSize, 
         0, 0);
        popMatrix();

        pushMatrix();
        translate(x1, y1);
        rotate(angle);
        triangle(-endHeadSize*coeff, -endHeadSize, 
         -endHeadSize*coeff, endHeadSize, 
         0, 0);
        popMatrix();
    }

    public float getPixelCenterX(float xOrigin, float cellW, float normalization, float zoomFactor, float gx){
        return (((x-xOrigin)/cellW)*normalization)*zoomFactor/10 + gx;
    }
    
    public float getPixelCenterY(float yOrigin, float cellH, float normalization, float zoomFactor, float gy, float gh){
        return (((yOrigin-y)/cellH)*normalization)*zoomFactor/10 + gy + gh;
    }
    public void drawSelf(float xOrigin,  float yOrigin, float normalization, float zoomFactor, float gx, float gy, float gw, float gh, float cellW, float cellH){
        float auxX = (((x-xOrigin)/cellW)*normalization)*zoomFactor/10 + gx;
        float auxY = (((yOrigin-y)/cellH)*normalization)*zoomFactor/10 + gy + gh;
        float auxW = (w/cellW*normalization)*zoomFactor/10;
        float auxH = (h/cellH*normalization)*zoomFactor/10;
        float auxTC = (topCut/cellH*normalization)*zoomFactor/10;
        float auxBC = (bottomCut/cellH*normalization)*zoomFactor/10;
        hitbox.updateBox(auxX-auxW/2,auxY-auxH/2,auxW,auxH);
        if(auxX-auxW > gx+gw || auxX+auxW < gx || auxY-auxH > gy+gh || auxY+auxH < gy)
            return;
        strokeWeight(2*zoomFactor/100+1);
        stroke(clockZone, (isTransparent)?128:255);
        if(isSelected){
            fill(255, 255, 255, 255);
        } else if(zoneViewMode){
            fill(clockZone, (isTransparent)?128:255);
        }else if(abs(xMag) > abs(yMag)){
            fill(200, 200, 200, (isTransparent)?128:255);
        } else if(yMag > 0){
            fill(0xffFF5555, (isTransparent)?128:255);
        } else{
            fill(0xff80B3FF, (isTransparent)?128:255);
        }
        beginShape();
        
        if(topCut > 0){
            vertex((auxX-auxW/2), auxY-auxH/2);
            vertex(auxX+auxW/2, auxY-auxH/2+((topCut/cellH*normalization)*zoomFactor/10));
        } else{
            vertex(auxX-auxW/2, auxY-auxH/2-((topCut/cellH*normalization)*zoomFactor/10));
            vertex(auxX+auxW/2, auxY-auxH/2);
        }
        if(bottomCut > 0){
            vertex(auxX+auxW/2, auxY+auxH/2-((bottomCut/cellH*normalization)*zoomFactor/10));
            vertex(auxX-auxW/2, auxY+auxH/2);
        } else{
            vertex(auxX+auxW/2, auxY+auxH/2);
            vertex(auxX-auxW/2, auxY+auxH/2+((bottomCut/cellH*normalization)*zoomFactor/10));
        }
        if(topCut > 0){
            vertex(auxX-auxW/2, auxY-auxH/2);
        } else{
            vertex(auxX-auxW/2, auxY-auxH/2-((topCut/cellH*normalization)*zoomFactor/10));
        }
        endShape();        
        
        drawArrow(
            auxX-(auxW/2)*xMag,
            auxY+(auxH/2-abs((yMag>0)?auxBC:auxTC))*yMag,
            auxX+(auxW/2)*xMag,
            auxY-(auxH/2-abs((yMag>0)?auxTC:auxBC))*yMag,
            0,((abs(xMag) > abs(yMag))?auxH/10:auxW/10));
        strokeWeight(1);
    }
}
public class TextBox{
    private boolean isSelected, isValidated, isActive;
    private String label, text;
    private float x, y, w;
    private int normal, selection, invalid, boxColor, fontColor, insideFontColor, editing;
    private HitBox hitbox;
    private String validationType;
    
    public TextBox(String label, float xPosition, float yPosition, float boxWidth){
        this.label = label;
        this.x = xPosition;
        this.y = yPosition;
        this.w = boxWidth/2;
        this.normal = color(45,80,22);
        this.fontColor = color(255,255,255);
        this.insideFontColor = color(45,80,22);
        this.boxColor = color(255,255,255);
        this.selection = color(255,153,85);
        this.invalid = color(255,0,0);
        this.editing = color(0xffFFE6D5);
        this.isValidated = false;
        this.isSelected = false;
        this.isActive = true;
        this.text = "";
        textSize(fontSz);
        this.hitbox = new HitBox(x+w, y, w, textAscent() + textDescent());
    }
    
    public void drawSelf(){
        if(!isActive)
            isSelected = false;
        textSize(fontSz);
        fill(fontColor);
        stroke(fontColor);
        String auxl = label;
        while(textWidth(auxl) > w)
            auxl = auxl.substring(0, auxl.length()-1);
        text(auxl, x, y+fontSz);
        
        if(isSelected)
            fill(editing);
        else if(isValidated)
            fill(boxColor);
        else
            fill(selection);
        if(isSelected){
            stroke(selection);
        } else if(isValidated){
            stroke(normal);
        } else{
            stroke(invalid);
        }
        float h = textAscent() + textDescent();
        rect(x+w, y, w, h, 5);
        
        String aux = text;
        while(textWidth(aux) > w){
            aux = aux.substring(1, aux.length());
        }
        fill(insideFontColor);
        stroke(insideFontColor);
        text(aux, x+w+5, y+fontSz);
    }
    
    public void setLabel(String newLabel){
        this.label = newLabel;
    }
    
    public String getText(){
        return text;
    }
    
    public void setText(String text){
        this.text = text;
        validateText();
    }
    
    public boolean mousePressedMethod(){
        if(!isActive)
            return false;
        boolean collided = hitbox.collision(mouseX, mouseY);
        isSelected = collided;
        if (!collided)
            unselect();
        return collided;
    }
    
    public void setPosition(float x, float y){
        this.x = x;
        this.y = y;
        textSize(fontSz);
        this.hitbox.updateBox(x+w, y, w, textAscent() + textDescent());
    }
    
    public boolean keyPressedMethod(){
        if(!isActive)
            return false;
        if(isSelected){
            if(key == BACKSPACE){
                if(text.length() > 0){
                    this.text = text.substring(0, text.length()-1);
                }
            } else if (key == ENTER | key == TAB){
                unselect();
            } else if((keyCode > 64 && keyCode < 91) || (keyCode > 95 && keyCode < 106) || keyCode == 107 || keyCode == 109 || (keyCode > 43 && keyCode < 47) || (keyCode > 47 && keyCode < 58)){
                text += key;
            }
            validateText();
            return true;
        }
        return false;
    }
    
    public boolean isSelected(){
        return isSelected;
    }
    
    public boolean isValid(){
        return isValidated;
    }
    
    public void unselect(){
        isSelected = false;
        validateText();
    }
    
    public void select(){
        isSelected = true;
    }
    
    public void setInvalid(){
        this.isValidated = false;
    }
    
    public void setValid(){
        this.isValidated = true;
    }
    
    public void resetText(){
        this.text = "";
    }
    
    public void setValidationType(String type){
        validationType = type;
    }
    
    public boolean validateText(){
        if(validationType.equals("String") && !text.equals("") && !text.contains(";") && !text.contains("$"))
            setValid();
        else if(validationType.equals("Integer")){
            try{
                Integer.parseInt(text);
                setValid();
            } catch(NumberFormatException e){
                setInvalid();
                return false;
            }
        } else if(validationType.equals("Float")){
            try{
                Float.parseFloat(text);
                setValid();
            } catch(NumberFormatException e){
                setInvalid();
                return false;
            }
        } else if(validationType.equals("IntegerPos")){
            try{
                int aux =Integer.parseInt(text);
                if(aux > 0)
                    setValid();
                else{
                    setInvalid();
                    return false;
                }
            } catch(NumberFormatException e){
                setInvalid();
                return false;
            }
        } else if(validationType.equals("FloatPos")){
            try{
                float aux = Float.parseFloat(text);
                if(aux > 0)
                    setValid();
                else{
                    setInvalid();
                    return false;
                }
            } catch(NumberFormatException e){
                setInvalid();
                return false;
            }
        } else{
            setInvalid();
            return false;
        }
        return true;
    }
    
    public void updatePosition(float x, float y){
        this.x = x;
        this.y = y;
        textSize(fontSz);
        hitbox.updateBox(x+w, y, w, textAscent() + textDescent());
    }
}
public class VectorTextBox{
    private boolean isActive;
    private String label;
    private ArrayList <String> texts;
    private float x, y, w;
    private int normal, selection, invalid, boxColor, fontColor, insideFontColor, editing;
    private ArrayList<HitBox> hitboxes;
    private ArrayList<Boolean> isValid;
    private String validationType;
    private int fields, selectedIndex;
    
    public VectorTextBox(String label, float xPosition, float yPosition, float boxWidth, int fields){
        this.label = label;
        this.x = xPosition;
        this.y = yPosition;
        this.w = boxWidth/2;
        this.fields = fields;
        this.isActive = true;
        this.normal = color(45,80,22);
        this.fontColor = color(255,255,255);
        this.insideFontColor = color(45,80,22);
        this.boxColor = color(255,255,255);
        this.selection = color(255,153,85);
        this.invalid = color(255,0,0);
        this.editing = color(0xffFFE6D5);
        this.isActive = true;
        this.selectedIndex = -1;
        texts = new ArrayList<String>();
        hitboxes = new ArrayList<HitBox>();
        isValid = new ArrayList<Boolean>();
        for(int i=0; i<fields; i++){
            texts.add("");
            isValid.add(false);
        }
        textSize(fontSz);
        for(int i=0; i<fields; i++){
            this.hitboxes.add(new HitBox(x+w+(((w-(fields-1)*5)/fields)*i + i*5), y, (w-(fields-1)*5)/fields, textAscent() + textDescent()));
        }
    }
    
    public void drawSelf(){
        textSize(fontSz);
        fill(fontColor);
        stroke(fontColor);
        String auxl = label;
        while(textWidth(auxl) > w)
            auxl = auxl.substring(0, auxl.length()-1);
        text(auxl, x, y+fontSz);
        
        for(int i=0; i<fields; i++){
            if(i == selectedIndex)
                fill(editing);
            else if(isValid.get(i))
                fill(boxColor);
            else
                fill(selection);
            if(i == selectedIndex){
                stroke(selection);
            } else if(isValid.get(i)){
                stroke(normal);
            } else{
                stroke(invalid);
            }
            float h = textAscent() + textDescent();
            rect(x+w+(((w-(fields-1)*5)/fields)*i + i*5), y, (w-(fields-1)*5)/fields, h, 5);
            
            String aux = texts.get(i);
            while(textWidth(aux) > (w-(fields-1)*5)/fields-2){
                aux = aux.substring(1, aux.length());
            }
            fill(insideFontColor);
            stroke(insideFontColor);
            text(aux, 5+x+w+(((w-(fields-1)*5)/fields)*i + i*5), y+fontSz);
        }
    }
    
    public void setLabel(String newLabel){
        this.label = newLabel;
    }
    
    public String getText(){
        String textAux = "";
        for(int i=0; i<fields; i++)
            textAux += texts.get(i) + ",";
        return textAux;
    }
    
    public void setText(String text){
        String[] textAux = text.split(",");
        for(int i=0; i<fields; i++)
            texts.set(i, textAux[i]);
        validateText();
    }
    
    public boolean mousePressedMethod(){
        if(!isActive)
            return false;
        selectedIndex = -1;
        for(int i=0; i<fields; i++){
            if(hitboxes.get(i).collision(mouseX, mouseY)){
                selectedIndex = i;
                break;
            }
        }
        if (selectedIndex == -1)
            unselect();
        return (selectedIndex != -1);
    }
    
    public boolean keyPressedMethod(){
        if(!isActive)
            return false;
        if(selectedIndex >= 0){
            if(key == BACKSPACE){
                if(texts.get(selectedIndex).length() > 0){
                    texts.set(selectedIndex, texts.get(selectedIndex).substring(0, texts.get(selectedIndex).length()-1));
                }
            } else if (key == ENTER | key == TAB){
                selectedIndex++;
                if(selectedIndex >= fields)
                    unselect();
            } else if((keyCode > 64 && keyCode < 91) || (keyCode > 95 && keyCode < 106) || keyCode == 107 || keyCode == 109 || (keyCode > 43 && keyCode < 47) || (keyCode > 47 && keyCode < 58)){
                texts.set(selectedIndex, texts.get(selectedIndex)+key);
            }
            return true;
        }
        return false;
    }
    
    public void unselect(){
        selectedIndex = -1;
        validateText();
    }
    
    public void select(){
        selectedIndex = 0;
    }
    
    public boolean isSelected(){
        return selectedIndex != -1;
    }
    
    public void resetText(){
        for(int i=0; i<fields; i++)
            this.texts.set(i, "");
    }
    
    public void setValidationType(String type){
        validationType = type;
    }
    
    public boolean validateText(){
        for(int i=0; i<fields; i++){
            if(validationType.equals("String") && texts.get(i) != "" && !texts.get(i).contains(";") && !texts.get(i).contains("$")){
                isValid.set(i, true);
            } else if(validationType.equals("Integer")){
                try{
                    Integer.parseInt(texts.get(i));
                    isValid.set(i, true);
                } catch(NumberFormatException e){
                    isValid.set(i, false);
                }
            } else if(validationType.equals("Float")){
                try{
                    Float.parseFloat(texts.get(i));
                    isValid.set(i, true);
                } catch(NumberFormatException e){
                    isValid.set(i, false);
                }
            } else if(validationType.equals("IntegerPos")){
                try{
                    int aux = Integer.parseInt(texts.get(i));
                    if(aux > 0){
                        isValid.set(i, true);
                    } else{
                        isValid.set(i, false);
                        return false;
                    }
                } catch(NumberFormatException e){
                    isValid.set(i, false);
                }
            } else if(validationType.equals("FloatPos")){
                try{
                    float aux = Float.parseFloat(texts.get(i));
                    if(aux > 0.0f){
                        isValid.set(i, true);
                    } else{
                        isValid.set(i, false);
                        return false;
                    }
                } catch(NumberFormatException e){
                    isValid.set(i, false);
                }
            } else{
                isValid.set(i, false);
            }
        }
        for(int i=0; i<isValid.size(); i++)
            if(!isValid.get(i))
                return false;
        return true;
    }
    
    public void updatePosition(float x, float y){
        this.x = x;
        this.y = y;
        textSize(fontSz);
        for(int i=0; i<fields; i++){
            this.hitboxes.get(i).updateBox(x+w+(((w-(fields-1)*5)/fields)*i + i*5), y, (w-(fields-1)*5)/fields, textAscent() + textDescent());
        }
    }
}
class ZonePanel{
    float x, y, w, h;
    TextBox label;
    Button saveButton, newButton, addButton, clearButton;
    DropDownBox phases;
    int panelColor, textColor;
    PhasePanel phasePanel;
    ListContainer myPhases, llgZones, behaZones;
    HashMap<String, String> llgZonesValues, behaZonesValues;
    Chart preview;
    ColorPallete zoneColor;
    SubstrateGrid substrateGrid;
    
    ZonePanel(float x, float y, float w, float h, PhasePanel pp){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.phasePanel = pp;
        textSize(fontSz);
        panelColor = color(45, 80, 22);
        textColor = color(255,255,255);
        
        label = new TextBox("Zone Label", x, y, w-40);
        label.setValidationType("String");
        label.isActive = true;
        
        saveButton = new Button("Save", "Saves the changes done in the zone", sprites.smallSaveIconWhite, 0, 0);
        newButton = new Button("New", "Add the zone as a new one", sprites.smallNewIconWhite, 0, 0);
        addButton = new Button("Add", "Add the selected phase to the current zone", sprites.nanoNewIconWhite, 0, 0);
        clearButton = new Button("Clear", "Clear all fields", sprites.smallDeleteIconWhite, 0, 0);
        
        myPhases = new ListContainer("Zone Phases", 0, 0, w, h);
        myPhases.deleteEnabled = true;
        myPhases.upEnabled = true;
        myPhases.downEnabled = true;
        
        llgZones = new ListContainer("All Zones", 0, 0, w, h);
        llgZones.deleteEnabled = true;
        llgZones.editEnabled = true;
        behaZones = new ListContainer("All Zones", 0, 0, w, h);
        behaZones.deleteEnabled = true;
        behaZones.editEnabled = true;
        
        llgZonesValues = new HashMap<String, String>();
        behaZonesValues = new HashMap<String, String>();
        
        phases = new DropDownBox("Add Phase", x+10, y+82, w-40);
        zoneColor = new ColorPallete(x+w-10, y+82, 15, 15);
    }
    
    public void setSubstrateGrid(SubstrateGrid substrateGrid){
        this.substrateGrid = substrateGrid;
    }
        
    public void drawSelf(){
        textSize(fontSz+5);
        fill(panelColor);
        stroke(panelColor);
        rect(x, y, w, h, 0, 15, 0, 0);
        fill(textColor);
        noStroke();
        float aux = textAscent()+textDescent(), auxY;
        String txt = "Zone Panel";
        auxY = y;
        text(txt, x+(w-textWidth(txt))/2, auxY+aux);
        auxY += aux+10;
        textSize(fontSz);
        aux = textAscent()+textDescent();
        text("Configuration", x+10, auxY+aux);
        auxY += aux+5;
        
        label.updatePosition(x+10, auxY);
        zoneColor.updatePosition(x+w-25,auxY+2.5f);
        auxY += aux+5;
        
        addButton.setPosition(x+w-40+15, auxY+2.5f);
        auxY += aux+10;
        
        myPhases.setPositionAndSize(x+10, auxY, w-20, 100);
        auxY += 105;
        
        if(phasePanel.getEngine().equals("LLG")){
            if(label.validateText() && llgZones.isIn(label.getText())){
                saveButton.isTransparent = !(label.validateText() && myPhases.getItems().size() > 0);
                saveButton.setPosition(x+w-30, auxY);
                saveButton.drawSelf();
                saveButton.isValid = true;
                newButton.isValid = false;
            } else{
                newButton.isTransparent = !(label.validateText() && myPhases.getItems().size() > 0);
                newButton.setPosition(x+w-30, auxY);
                newButton.drawSelf();
                newButton.isValid = true;
                saveButton.isValid = false;
            }
        } else{
            if(label.validateText() && behaZones.isIn(label.getText())){
                saveButton.isTransparent = !(label.validateText() && myPhases.getItems().size() > 0);
                saveButton.setPosition(x+w-30, auxY);
                saveButton.drawSelf();
                saveButton.isValid = true;
                newButton.isValid = false;
            } else{
                newButton.isTransparent = !(label.validateText() && myPhases.getItems().size() > 0);
                newButton.setPosition(x+w-30, auxY);
                newButton.drawSelf();
                newButton.isValid = true;
                saveButton.isValid = false;
            }
        }
        clearButton.setPosition(x+w-60, auxY);
        clearButton.isValid = true;
        clearButton.drawSelf();
        auxY += aux+5;
        
        strokeWeight(4);
        stroke(color(255,255,255));
        line(x+10, auxY, x+w-10, auxY);
        auxY += 20;
        noStroke();
        strokeWeight(1);

        if(phasePanel.getEngine().equals("LLG")){
            llgZones.setPositionAndSize(x+10, auxY, w-20, 100);
        } else{
            behaZones.setPositionAndSize(x+10, auxY, w-20, 100);
        }
        auxY += 105;

        strokeWeight(4);
        stroke(color(255,255,255));
        line(x+10, auxY, x+w-10, auxY);
        auxY += 10;
        noStroke();
        strokeWeight(1);
        
        fill(textColor);
        text("Zone Preview", x+10, auxY+fontSz);
        auxY += aux+5;
        float spaceLeft = (h-5-(auxY-y));
        preview = new Chart(x+10, auxY, w-20, spaceLeft);
        
        ArrayList <String> currentPhaseNames = myPhases.getItems();
        if(label.validateText() && currentPhaseNames.size() > 0){
            ArrayList <float[]> behaSeries = new ArrayList <float[]>();
            ArrayList <float[]> [] llgSeries = new ArrayList[6];
            for(int i=0; i<6; i++)
                llgSeries[i] = new ArrayList<float[]>();
            float time = 0;
            for(int i=0; i<currentPhaseNames.size(); i++){
                String[] data = phasePanel.getPhaseInfo(currentPhaseNames.get(i)).split(";");
                if(phasePanel.getEngine().equals("LLG")){
                    String[]initFieldData = data[1].split(",");
                    String[]endFieldData = data[2].split(",");
                    String[]initCurrData = data[3].split(",");
                    String[]endCurrData = data[4].split(",");
                    for(int j=0; j<6; j++){
                        if(j<3){
                            llgSeries[j].add(new float[]{time, Float.parseFloat(initFieldData[j])});
                            llgSeries[j].add(new float[]{time+Float.parseFloat(data[5]), Float.parseFloat(endFieldData[j])});
                        } else{
                            llgSeries[j].add(new float[]{time, Float.parseFloat(initCurrData[j-3])});
                            llgSeries[j].add(new float[]{time+Float.parseFloat(data[5]), Float.parseFloat(endCurrData[j-3])});
                        }
                    }
                    time += Float.parseFloat(data[5]);
                } else{
                    behaSeries.add(new float[]{time, Float.parseFloat(data[1])});
                    time += Float.parseFloat(data[3]);
                    behaSeries.add(new float[]{time, Float.parseFloat(data[2])});
                }
            }
            if(phasePanel.getEngine().equals("LLG")){
                for(int i=0; i<6; i++){
                    float [][] finalData = new float[llgSeries[i].size()][];
                    llgSeries[i].toArray(finalData);
                    String seriesName = "";
                    int seriesColor = color(0xff000000);
                    switch(i){
                        case 0:{seriesName = "External Field X"; seriesColor = color(0,0,255);}
                        break;
                        case 1:{seriesName = "External Field Y"; seriesColor = color(255,0,0);}
                        break;
                        case 2:{seriesName = "External Field Z"; seriesColor = color(255,255,0);}
                        break;
                        case 3:{seriesName = "Current Field X"; seriesColor = color(0xff000080);}
                        break;
                        case 4:{seriesName = "Current Field Y"; seriesColor = color(0xff800000);}
                        break;
                        case 5:{seriesName = "Current Field Z"; seriesColor = color(0xffD4AA00);}
                        break;
                        default:{};
                    }
                    preview.addSeires(seriesName, finalData, seriesColor);
                }
            } else{
                float [][] finalData = new float[behaSeries.size()][];
                behaSeries.toArray(finalData);
                preview.addSeires("External Field X", finalData, color(255,0,0));
            }
        }
        preview.drawSelf();
        
        if(phasePanel.getEngine().equals("LLG"))
            llgZones.drawSelf();
        else
            behaZones.drawSelf();
        myPhases.drawSelf();
        addButton.isTransparent = (phases.getSelectedOption().equals(""));
        addButton.drawSelf();
        phases.drawSelf();
        label.drawSelf();
        zoneColor.drawSelf();
        onMouseOverMethod();
        if(phasePanel.getEngine().equals("LLG")){
            substrateGrid.updateZoneNames(llgZones.getItems());
        } else{
            substrateGrid.updateZoneNames(behaZones.getItems());
        }
    }
    
    public void reset(){
        label.setText("");
        phases.resetOption();
        myPhases.clearList();
        llgZones.clearList();
        behaZones.clearList();
        llgZonesValues.clear();
        behaZonesValues.clear();
    }
    
    public void loadZoneProperties(ArrayList<String> properties){
        reset();
        for(String zone : properties){
            String name = zone.substring(0, zone.indexOf(";"));
            if(phasePanel.getEngine().equals("LLG")){
                llgZones.addItem(name);
                llgZonesValues.put(name, zone);
            } else{
                behaZones.addItem(name);
                behaZonesValues.put(name, zone);
            }
        }
    }
    
    public ArrayList <String> getZoneProperties(){
        ArrayList properties = new ArrayList<String>();
        if(phasePanel.getEngine().equals("LLG")){
            for(String name : llgZones.getItems())
                properties.add(llgZonesValues.get(name));
        } else{
            for(String name : behaZones.getItems())
                properties.add(behaZonesValues.get(name));
        }
        return properties;
    }
    
    public ArrayList <String> getZoneNames(){
        if(phasePanel.getEngine().equals("LLG"))
            return llgZones.getItems();
        return behaZones.getItems();
    }
        
    public String getEngine(){
        return phasePanel.getEngine();
    }
    
    public Integer getZoneColor(String label){
        if(phasePanel.getEngine().equals("LLG")){
            String [] parts = llgZonesValues.get(label).split(";");
            return Integer.parseInt(parts[parts.length-1]);
        } else{
            String [] parts = behaZonesValues.get(label).split(";");
            return Integer.parseInt(parts[parts.length-1]);
        }
    }
    
    public void updatePhases(){
        myPhases.clearList();
        label.resetText();
        zoneColor.resetColor();
        phases.removeAllOptions();
        ArrayList<String> phasesNames = phasePanel.getPhasesNames();
        for(int i=0; i<phasesNames.size(); i++){
            phases.addOption(phasesNames.get(i));
        }
        ArrayList<String> zoneNames;
        if(phasePanel.getEngine().equals("LLG")){
            zoneNames = new ArrayList<String>(llgZones.getItems());
        } else{
            zoneNames = new ArrayList<String>(behaZones.getItems());
        }
        for(int index=0; index<zoneNames.size(); index++){
            String[] parts;
            if(phasePanel.getEngine().equals("LLG"))
                parts = llgZonesValues.get(zoneNames.get(index)).split(";");
            else
                parts = behaZonesValues.get(zoneNames.get(index)).split(";");
            for(int j=1; j<parts.length-1; j++){
                if(!phasesNames.contains(parts[j])){
                    if(phasePanel.getEngine().equals("LLG"))
                        llgZones.removeItem(zoneNames.get(index));
                    else
                        behaZones.removeItem(zoneNames.get(index));
                }
            }
        }
        if(phasePanel.getEngine().equals("LLG")){
            substrateGrid.updateZoneNames(llgZones.getItems());
        } else{
            substrateGrid.updateZoneNames(behaZones.getItems());
        }
    }
    
    public void mousePressedMethod(){
        if(addButton.mousePressedMethod()){
            addButton.deactivate();
            String opt = phases.getSelectedOption();
            if(opt != ""){
                myPhases.addItem(opt);
            }
        }
        if(clearButton.mousePressedMethod()){
            clearButton.deactivate();
            myPhases.clearList();
            label.resetText();
            phases.resetOption();
            zoneColor.resetColor();
        }
        if(newButton.mousePressedMethod()){
            newButton.deactivate();
            if(label.validateText() && myPhases.getItems().size() > 0){
                ArrayList<String> aux = myPhases.getItems();
                String strAux = label.getText() + ";";
                for(int i=0; i<aux.size(); i++){
                    strAux += aux.get(i) + ";";
                }
                strAux += zoneColor.getColor();
                if(phasePanel.getEngine().equals("LLG")){
                    llgZonesValues.put(label.getText(), strAux);
                    llgZones.addItem(label.getText());
                } else{
                    behaZonesValues.put(label.getText(), strAux);
                    behaZones.addItem(label.getText());
                }
            }
            PopUp pop = new PopUp(((width-150)/2)*scaleFactor, ((height-50)/2)*scaleFactor, 150, 50, "Zone added!");
            pop.activate();
            pop.setAsTimer(50);
            popCenter.setPopUp(pop);
        }
        if(saveButton.mousePressedMethod()){
            saveButton.deactivate();
            if(label.validateText() && myPhases.getItems().size() > 0){
                ArrayList<String> aux = myPhases.getItems();
                String strAux = label.getText() + ";";
                for(int i=0; i<aux.size(); i++){
                    strAux += aux.get(i) + ";";
                }
                strAux += zoneColor.getColor();
                if(phasePanel.getEngine().equals("LLG")){
                    llgZonesValues.put(label.getText(), strAux);
                } else{
                    behaZonesValues.put(label.getText(), strAux);
                }
            }
            PopUp pop = new PopUp(((width-150)/2)*scaleFactor, ((height-50)/2)*scaleFactor, 150, 50, "Zone saved!");
            pop.activate();
            pop.setAsTimer(50);
            popCenter.setPopUp(pop);
        }
        if(phasePanel.getEngine().equals("LLG")){
            if(llgZones.mousePressedMethod()){
                String auxKey = llgZones.getEditionField();
                if(auxKey != ""){
                    String[] parts = llgZonesValues.get(auxKey).split(";");
                    label.setText(parts[0]);
                    myPhases.clearList();
                    for(int i=1; i<parts.length-1; i++){
                        myPhases.addItem(parts[i]);
                    }
                    zoneColor.setColor(Integer.parseInt(parts[parts.length-1]));
                }
            }
        } else{
            if(behaZones.mousePressedMethod()){
                String auxKey = behaZones.getEditionField();
                if(auxKey != ""){
                    String[] parts = behaZonesValues.get(auxKey).split(";");
                    label.setText(parts[0]);
                    myPhases.clearList();
                    for(int i=1; i<parts.length-1; i++){
                        myPhases.addItem(parts[i]);
                    }
                    zoneColor.setColor(Integer.parseInt(parts[parts.length-1]));
                }
            }
        }
        myPhases.mousePressedMethod();
        label.mousePressedMethod();
        phases.mousePressedMethod();
        zoneColor.mousePressedMethod();
    }
    
    public void onMouseOverMethod(){
        addButton.onMouseOverMethod();
        newButton.onMouseOverMethod();
        saveButton.onMouseOverMethod();
        clearButton.onMouseOverMethod();
    }
    
    public void mouseDraggedMethod(){
        if(phasePanel.getEngine().equals("LLG"))
            llgZones.mouseDraggedMethod();
        else
            behaZones.mouseDraggedMethod();
        myPhases.mouseDraggedMethod();
    }
    
    public void mouseWheelMethod(float v){
        if(phasePanel.getEngine().equals("LLG"))
            llgZones.mouseWheelMethod(v);
        else
            behaZones.mouseWheelMethod(v);
        myPhases.mouseWheelMethod(v);
    }
    public void keyPressedMethod(){
        label.keyPressedMethod();
    }
}
    public void settings() {  size(1280, 720); }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "NMLSim" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
