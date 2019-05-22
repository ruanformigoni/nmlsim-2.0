class ZonePanel{
    float x, y, w, h;
    TextBox label;
    Button saveButton, newButton, addButton, clearButton;
    DropDownBox phases;
    color panelColor, textColor;
    PhasePanel phasePanel;
    ListContainer myPhases, allZones;
    HashMap<String, String> zonesValues;
    Chart preview;
    ColorPallete zoneColor;
    
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
        
        allZones = new ListContainer("All Zones", 0, 0, w, h);
        allZones.deleteEnabled = true;
        allZones.editEnabled = true;
        
        zonesValues = new HashMap<String, String>();
        
        phases = new DropDownBox("Add Phase", x+10, y+82, w-40);
        zoneColor = new ColorPallete(x+w-10, y+82, 15, 15);
    }
    
    void drawSelf(){
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
        zoneColor.updatePosition(x+w-25,auxY+2.5);
        auxY += aux+5;
        
        addButton.setPosition(x+w-40+15, auxY+2.5);
        auxY += aux+10;
        
        myPhases.setPositionAndSize(x+10, auxY, w-20, 100);
        auxY += 105;
        
        if(label.validateText() && allZones.isIn(label.getText())){
            saveButton.setPosition(x+w-30, auxY);
            saveButton.drawSelf();
            saveButton.isValid = true;
            newButton.isValid = false;
        } else{
            newButton.setPosition(x+w-30, auxY);
            newButton.drawSelf();
            newButton.isValid = true;
            saveButton.isValid = false;
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

        allZones.setPositionAndSize(x+10, auxY, w-20, 100);        
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

        preview.drawSelf();
        
        allZones.drawSelf();
        myPhases.drawSelf();
        addButton.drawSelf();
        phases.drawSelf();
        label.drawSelf();
        zoneColor.drawSelf();
        onMouseOverMethod();
    }
    
    void updatePhases(){
        phases.removeAllOptions();
        ArrayList<String> phasesNames = phasePanel.getPhasesNames();
        for(int i=0; i<phasesNames.size(); i++)
            phases.addOption(phasesNames.get(i));
    }
    
    void mousePressedMethod(){
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
            if(label.validateText()){
                ArrayList<String> aux = myPhases.getItems();
                String strAux = label.getText() + ";";
                for(int i=0; i<aux.size(); i++){
                    strAux += aux.get(i) + ";";
                }
                strAux += zoneColor.getColor();
                zonesValues.put(label.getText(), strAux);
                allZones.addItem(label.getText());
            }
        }
        if(saveButton.mousePressedMethod()){
            saveButton.deactivate();
            if(label.validateText()){
                ArrayList<String> aux = myPhases.getItems();
                String strAux = label.getText() + ";";
                for(int i=0; i<aux.size(); i++){
                    strAux += aux.get(i) + ";";
                }
                strAux += zoneColor.getColor();
                zonesValues.put(label.getText(), strAux);
            }
        }
        if(allZones.mousePressedMethod()){
            String auxKey = allZones.getEditionField();
            if(auxKey != ""){
                String[] parts = zonesValues.get(auxKey).split(";");
                label.setText(parts[0]);
                myPhases.clearList();
                for(int i=1; i<parts.length-1; i++){
                    myPhases.addItem(parts[i]);
                }
                zoneColor.setColor(Integer.parseInt(parts[parts.length-1]));
            }
        }
        myPhases.mousePressedMethod();
        label.mousePressedMethod();
        phases.mousePressedMethod();
        zoneColor.mousePressedMethod();
    }
    
    void onMouseOverMethod(){
        addButton.onMouseOverMethod();
        newButton.onMouseOverMethod();
        saveButton.onMouseOverMethod();
        clearButton.onMouseOverMethod();
    }
    
    void mouseDraggedMethod(){
        allZones.mouseDraggedMethod();
        myPhases.mouseDraggedMethod();
    }
    
    void mouseWheelMethod(float v){
        allZones.mouseWheelMethod(v);
        myPhases.mouseWheelMethod(v);
    }
    void keyPressedMethod(){
        label.keyPressedMethod();
    }
}
