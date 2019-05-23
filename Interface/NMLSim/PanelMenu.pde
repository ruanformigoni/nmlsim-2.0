class PanelMenu{
    float x, y, panelW, panelH;
    SimulationPanel simPanel;
    PhasePanel phasePanel;
    ZonePanel zonePanel;
    MagnetPanel magnetPanel;
    ArrayList<String> labels;
    ArrayList<HitBox> hitboxes;
    int selectedPanel;
    color selectedColor, normalColor, textColor, lineColor;
    
    PanelMenu(float x, float y, float pw, float ph){
        this.x = x;
        this.y = y;
        panelH = ph;
        panelW = pw;
        
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
        
        simPanel = new SimulationPanel(x, y-ph, pw, ph);
        phasePanel = new PhasePanel(x, y-ph, pw, ph, simPanel);
        zonePanel = new ZonePanel(x, y-ph, pw, ph, phasePanel);
        magnetPanel = new MagnetPanel(x, y-ph, pw, ph, zonePanel);
    }
    
    void drawSelf(){
        float h = textAscent()+textDescent(), auxX = x+5;
        textSize(fontSz);
        fill(normalColor);
        stroke(normalColor);
        rect(x, y, width, h);

        stroke(lineColor);
        strokeWeight(2);
        line(x, y+1, width, y+1);
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
    }
    
    void mousePressedMethod(){
        int i;
        for(i=0; i<hitboxes.size(); i++){
            if(hitboxes.get(i).collision(mouseX, mouseY))
                break;
        }
        if(i == selectedPanel)
            selectedPanel = -1;
        else if(!(i >= hitboxes.size()))
            selectedPanel = i;
        
        if(i == 2)
            zonePanel.updatePhases();
        if(i == 3)
            magnetPanel.updateZones();
        
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