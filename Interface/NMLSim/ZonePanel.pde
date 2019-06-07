class ZonePanel{
    float x, y, w, h;
    TextBox label;
    Button saveButton, newButton, addButton, clearButton;
    DropDownBox phases;
    color panelColor, textColor;
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
    
    void setSubstrateGrid(SubstrateGrid substrateGrid){
        this.substrateGrid = substrateGrid;
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
                    color seriesColor = color(#000000);
                    switch(i){
                        case 0:{seriesName = "External Field X"; seriesColor = color(0,0,255);}
                        break;
                        case 1:{seriesName = "External Field Y"; seriesColor = color(255,0,0);}
                        break;
                        case 2:{seriesName = "External Field Z"; seriesColor = color(255,255,0);}
                        break;
                        case 3:{seriesName = "Current Field X"; seriesColor = color(#000080);}
                        break;
                        case 4:{seriesName = "Current Field Y"; seriesColor = color(#800000);}
                        break;
                        case 5:{seriesName = "Current Field Z"; seriesColor = color(#D4AA00);}
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
    
    void reset(){
        label.setText("");
        phases.resetOption();
        myPhases.clearList();
        llgZones.clearList();
        behaZones.clearList();
        llgZonesValues.clear();
        behaZonesValues.clear();
    }
    
    void loadZoneProperties(ArrayList<String> properties){
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
    
    ArrayList <String> getZoneProperties(){
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
    
    ArrayList <String> getZoneNames(){
        if(phasePanel.getEngine().equals("LLG"))
            return llgZones.getItems();
        return behaZones.getItems();
    }
        
    String getEngine(){
        return phasePanel.getEngine();
    }
    
    Integer getZoneColor(String label){
        if(phasePanel.getEngine().equals("LLG")){
            String [] parts = llgZonesValues.get(label).split(";");
            return Integer.parseInt(parts[parts.length-1]);
        } else{
            String [] parts = behaZonesValues.get(label).split(";");
            return Integer.parseInt(parts[parts.length-1]);
        }
    }
    
    void updatePhases(){
        myPhases.clearList();
        label.resetText();
        zoneColor.resetColor();
        phases.removeAllOptions();
        ArrayList<String> phasesNames = phasePanel.getPhasesNames();
        for(int i=0; i<phasesNames.size(); i++)
            phases.addOption(phasesNames.get(i));
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
    
    void onMouseOverMethod(){
        addButton.onMouseOverMethod();
        newButton.onMouseOverMethod();
        saveButton.onMouseOverMethod();
        clearButton.onMouseOverMethod();
    }
    
    void mouseDraggedMethod(){
        if(phasePanel.getEngine().equals("LLG"))
            llgZones.mouseDraggedMethod();
        else
            behaZones.mouseDraggedMethod();
        myPhases.mouseDraggedMethod();
    }
    
    void mouseWheelMethod(float v){
        if(phasePanel.getEngine().equals("LLG"))
            llgZones.mouseWheelMethod(v);
        else
            behaZones.mouseWheelMethod(v);
        myPhases.mouseWheelMethod(v);
    }
    void keyPressedMethod(){
        label.keyPressedMethod();
    }
}