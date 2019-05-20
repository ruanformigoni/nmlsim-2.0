class SimulationPanel{
    float x, y, w, h, fontSz;
    DropDownBox engine, mode, method;
    TextBox repetitions, reportStep, alpha, ms, temperature, timeStep, simTime, spinAngle, spinDifusionLenght, heavyMaterialThickness, neighborhoodRadius;
    color panelColor, textColor;
    int selectedIndex = 0;
    
    public SimulationPanel(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.fontSz = 15;
        textSize(fontSz);
        float aux = textAscent()+textDescent();
        panelColor = color(45, 80, 22);
        textColor = color(255,255,255);
        
        engine = new DropDownBox("Engine", 0, 0, w-20, 15);
        engine.addOption("LLG");
        engine.addOption("Behaviour");
        
        mode = new DropDownBox("Mode", 0, 0, w-20, 15);
        mode.addOption("Direct");
        mode.addOption("Verbose");
        mode.addOption("Exaustive");
        mode.addOption("Repetitive");
        
        method = new DropDownBox("Method", 0, 0, w-20, 15);
        method.addOption("RKW2");
        method.addOption("RK4");
        
        repetitions = new TextBox("Repetitions", 0, 0, w-20, 15);
        repetitions.setValidationType("Integer");
        repetitions.setText("100");
        
        reportStep = new TextBox("Report Step (ns)", 0, 0, w-20, 15);
        reportStep.setValidationType("Float");
        reportStep.setText("0.01");
        
        alpha = new TextBox("Gilbert Damping", 0, 0, w-20, 15);
        alpha.setValidationType("Float");
        alpha.setText("0.05");
        
        ms = new TextBox("Saturat. Mag (A/m)", 0, 0, w-20, 15);
        ms.setValidationType("Float");
        ms.setText("800000");
        
        temperature = new TextBox("Temperature (K)", 0, 0, w-20, 15);
        temperature.setValidationType("Float");
        temperature.setText("300");
        
        timeStep = new TextBox("Time Step (ns)", 0, 0, w-20, 15);
        timeStep.setValidationType("Float");
        timeStep.setText("0.0001");
        
        simTime = new TextBox("Sim. Time (ns)", 0, 0, w-20, 15);
        simTime.setValidationType("Float");
        
        spinAngle = new TextBox("Spin Angle", 0, 0, w-20, 15);
        spinAngle.setValidationType("Float");
        spinAngle.setText("0.4");
        
        spinDifusionLenght = new TextBox("Spin Dif. Len.", 0, 0, w-20, 15);
        spinDifusionLenght.setValidationType("Float");
        spinDifusionLenght.setText("3.5");
        
        heavyMaterialThickness = new TextBox("H.M. Thickness", 0, 0, w-20, 15);
        heavyMaterialThickness.setValidationType("Float");
        heavyMaterialThickness.setText("5");
        
        neighborhoodRadius = new TextBox("Neigh. Radius", 0, 0, w-20, 15);
        neighborhoodRadius.setValidationType("Float");
        neighborhoodRadius.setText("300");
    }
    
    public void drawSelf(){
        textSize(fontSz+5);
        fill(panelColor);
        stroke(panelColor);
        rect(x, y, w, h);
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
        if(mode.getSelectedOption().equals("Repetitive")){
            repetitions.updatePosition(x+10, auxY);
            auxY += aux+5;
        }
        if(mode.getSelectedOption().equals("Verbose")){
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
        
        neighborhoodRadius.drawSelf();
        if(engine.getSelectedOption().equals("LLG")){
            heavyMaterialThickness.drawSelf();
            spinDifusionLenght.drawSelf();
            spinAngle.drawSelf();
        }
        simTime.drawSelf();
        timeStep.drawSelf();
        if(engine.getSelectedOption().equals("LLG") & method.getSelectedOption().equals("RKW2"))
            temperature.drawSelf();
        if(engine.getSelectedOption().equals("LLG"))
            ms.drawSelf();
        if(engine.getSelectedOption().equals("LLG"))
            alpha.drawSelf();
        if(mode.getSelectedOption().equals("Verbose"))
            reportStep.drawSelf();
        if(mode.getSelectedOption().equals("Repetitive"))
            repetitions.drawSelf();
        if(engine.getSelectedOption().equals("LLG"))
            method.drawSelf();
        mode.drawSelf();
        engine.drawSelf();        
    }
    
    public boolean mousePressedMethod(){
        if(engine.mousePressedMethod())
            return true;
        if(mode.mousePressedMethod())
            return true;
        if(method.mousePressedMethod())
            return true;
        if(repetitions.mousePressedMethod())
            return true;
        if(reportStep.mousePressedMethod())
            return true;
        if(alpha.mousePressedMethod())
            return true;
        if(ms.mousePressedMethod())
            return true;
        if(temperature.mousePressedMethod())
            return true;
        if(timeStep.mousePressedMethod())
            return true;
        if(simTime.mousePressedMethod())
            return true;
        if(spinAngle.mousePressedMethod())
            return true;
        if(spinDifusionLenght.mousePressedMethod())
            return true;
        if(heavyMaterialThickness.mousePressedMethod())
            return true;
        if(neighborhoodRadius.mousePressedMethod())
            return true;
        return false;
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
            if(key == ENTER | key == TAB){
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
}