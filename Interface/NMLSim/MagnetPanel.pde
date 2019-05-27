class MagnetPanel{
    float x, y, w, h;
    boolean isEditing;
    
    TextBox label, behaInitMag, magWidth, magHeight, magThickness, magTopCut, magBottomCut;
    DropDownBox type, clockZone;
    VectorTextBox position, llgInitMag;
    CheckBox fixedMag;
    
    Button saveButton, saveTemplateButton, clearButton;
    
    color panelColor, textColor;
    ZonePanel zonePanel;
    StructurePanel structurePanel;

    public MagnetPanel(float x, float y, float w, float h, ZonePanel zp, StructurePanel sp){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        zonePanel = zp;
        structurePanel = sp;
        
        label = new TextBox("Label", x, y, w-20);
        label.setValidationType("String");
        
        behaInitMag = new TextBox("Initial Mag.", x, y, w-20);
        behaInitMag.setValidationType("Float");
        behaInitMag.setText("0");
        
        magWidth = new TextBox("Width (nm)", x, y, w-20);
        magWidth.setValidationType("Float");
        magWidth.setText("50");
        
        magHeight = new TextBox("Height (nm)", x, y, w-20);
        magHeight.setValidationType("Float");
        magHeight.setText("100");
        
        magThickness = new TextBox("Thickness (nm)", x, y, w-20);
        magThickness.setValidationType("Float");
        magThickness.setText("15");
        
        magTopCut = new TextBox("Top Cut (nm)", x, y, w-20);
        magTopCut.setValidationType("Float");
        magTopCut.setText("0");
        
        magBottomCut = new TextBox("Bottom Cut (nm)", x, y, w-20);
        magBottomCut.setValidationType("Float");
        magBottomCut.setText("0");        
        
        type = new DropDownBox("Magnet Type", x, y, w-20);
        type.addOption("Input");
        type.addOption("Regular");
        type.addOption("Output");
        
        clockZone = new DropDownBox("Clock Zone", x, y, w-20);
        
        position = new VectorTextBox("Position (nm)", x, y, w-20, 2);
        position.setValidationType("Float");
        
        llgInitMag = new VectorTextBox("Initial Mag.(x, y, z)", x, y, w-20, 3);
        llgInitMag.setValidationType("Float");
        llgInitMag.setText(".141,0.99,0");
        
        fixedMag = new CheckBox("No Field Effect", x, y, w-20);
        
        panelColor = color(45, 80, 22);
        textColor = color(255,255,255);
        
        isEditing = false;
        
        saveButton = new Button("Save", "Save the changes in the current magnet", sprites.smallSaveIconWhite, x+w-80, y+h-30);
        saveTemplateButton = new Button("Save Template", "Save the configuration as a new template", sprites.smallSaveTemplateIconWhite, x+w-30, y+h-30);
        clearButton = new Button("Clear", "Clear all fields", sprites.smallDeleteIconWhite, x+w-55, y+h-30);
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
        
        if(!isEditing){
            label.setPosition(x+10, auxY);
            auxY += aux+5;
        }
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
        
        if(isEditing)
            saveButton.drawSelf();
        saveTemplateButton.drawSelf();
        clearButton.drawSelf();
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
        if(!isEditing)
            label.drawSelf();
        if(isEditing)
            saveButton.onMouseOverMethod();
        saveTemplateButton.onMouseOverMethod();
        clearButton.onMouseOverMethod();
    }
    
    boolean validateAllFields(){
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
    
    String getValue(boolean toStructure){
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
    
    void mousePressedMethod(){
        if(saveTemplateButton.mousePressedMethod() && validateAllFields()){
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
        if(clearButton.mousePressedMethod()){
            clearButton.deactivate();
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
    }
    
    void keyPressedMethod(){
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