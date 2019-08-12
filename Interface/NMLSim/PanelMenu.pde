class PanelMenu{
    float x, y, panelW, panelH;
    SimulationPanel simPanel;
    PhasePanel phasePanel;
    ZonePanel zonePanel;
    MagnetPanel magnetPanel;
    StructurePanel structurePanel;
    ArrayList<String> labels;
    ArrayList<HitBox> hitboxes;
    int selectedPanel;
    color selectedColor, normalColor, textColor, lineColor;
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
        
        structureLabelHitbox = new HitBox(width/scaleFactor-textWidth("Structures")-33, y, textWidth("Structures")+10, textAscent()+textDescent());
    }
    
    void loadStructures(ArrayList<String> structures){
        structurePanel.loadStructures(structures);
    }
    
    ArrayList<String> getStructures(){
        structurePanel.loadStructures(structurePanel.getStructures());
        return structurePanel.getStructures();
    }
    
    ArrayList<String> getZoneProperties(){
        return zonePanel.getZoneProperties();
    }
    
    String getCircuitProperties(){
        return simPanel.getProperties();
    }
    
    Float getReportStep(){
        return Float.parseFloat(simPanel.getReportStep());
    }
    
    String getSimulationMode(){
        return simPanel.getSimulationMode();
    }
    
    ArrayList<String> getPhaseProperties(){
        return phasePanel.getPhaseProperties();
    }
    
    void enableEditing(){
        magnetPanel.isEditing = true;
        magnetPanel.setEditing(substrateGrid.getSelectedStructure(), substrateGrid.getSelectedMagnetsNames());
        selectedPanel = 3;
    }
        
    void drawSelf(){
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
                    rect(auxX-5, y, textWidth(labels.get(i)) + 7.5, h);
                else
                    rect(auxX-4, y, textWidth(labels.get(i)) + 7.5, h);
                fill(textColor);
                noStroke();
            }
            text(labels.get(i), auxX, y+fontSz);

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
            default:{}
        }
        
        if(!simPanel.getGridProperties().equals("") && !simPanel.getGridProperties().equals(subProperty)){
            subProperty = simPanel.getGridProperties();
            String parts[] = subProperty.split(",");
            substrateGrid.setGridSizes(Float.parseFloat(parts[0]), Float.parseFloat(parts[1]), Float.parseFloat(parts[2]), Float.parseFloat(parts[3]));
            substrateGrid.setBulletSpacing(Float.parseFloat(parts[4]), Float.parseFloat(parts[5]));
        }
    }
    
    void mousePressedMethod(){
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
            default:{}
        }
    }
    
    void mouseWheelMethod(float v){
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
    
    void mouseDraggedMethod(){
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
    
    void keyPressedMethod(){
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
            default:{}
        }
    }
}
