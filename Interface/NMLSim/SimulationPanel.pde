class SimulationPanel{
    float x, y, w, h;
    DropDownBox engine, mode, method;
    TextBox repetitions, reportStep, alpha, ms, temperature, timeStep, simTime, spinAngle, spinDifusionLenght, heavyMaterialThickness, neighborhoodRadius;
    VectorTextBox subSize, cellSize, bulletSpacing;
    color panelColor, textColor;
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
        
        clearButton = new Button("Clear", "Clear all fields", sprites.smallDeleteIconWhite, x+w-55, y+h-22.5);
        defaultButton = new Button("Defalt", "Set all fields to the default option", sprites.smallDefaultIconWhite, x+w-30, y+h-22.5);
    }
    
    String getProperties(){
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
    
    void loadProperties(String simulation, String grid){
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
    
    void reset(){
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
        
        text("Substract Configurations", x+10, auxY+fontSz);
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
    
    void setZonePanel(ZonePanel zonePanel){
        this.zonePanel = zonePanel;
    }
    
    void onMouseOverMethod(){
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
    
    String getEngine(){
        return engine.getSelectedOption();
    }
    
    String getReportStep(){
        return reportStep.getText();
    }
    
    String getSimulationMode(){
        return mode.getSelectedOption();
    }
    
    String getGridProperties(){
        String gp = "";
        if(bulletSpacing.validateText() && subSize.validateText() && cellSize.validateText()){
            gp += subSize.getText() + cellSize.getText() + bulletSpacing.getText();
        }
        return gp;
    }
}
