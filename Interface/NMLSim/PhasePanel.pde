class PhasePanel{
    float x, y, w, h;
    TextBox name, duration, initialBeha, endBeha;
    VectorTextBox initialField, endField, initialCurr, endCurr;
    Button saveButton, newButton, clearButton;
    color panelColor, textColor;
    SimulationPanel sp;
    ListContainer llgPhases, behaPhases;
    HashMap<String, String> llgPhaseValues, behaPhaseValues;
    Chart preview;

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
        duration.setValidationType("Float");
        
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
    
    void drawSelf(){
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
            if(sp.getEngine().equals("LLG") & llgPhases.isIn(name.getText())){
                saveButton.setPosition(x+w-30,auxY);
                saveButton.drawSelf();
                newButton.isValid = false;
                saveButton.isValid = true;
            } else if(behaPhases.isIn(name.getText())){
                saveButton.setPosition(x+w-30,auxY);
                saveButton.drawSelf();
                newButton.isValid = false;
                saveButton.isValid = true;
            } else{
                newButton.setPosition(x+w-30,auxY);
                newButton.drawSelf();
                newButton.isValid = true;
                saveButton.isValid = false;
            }
        } else{
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
                            color(0,0,255    ));
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
                            color(#000080));
                    preview.addSeires("Current Field Y",
                            new float[][]{
                                {0,Float.parseFloat(initData[1])},
                                {Float.parseFloat(duration.getText()),Float.parseFloat(endData[1])}
                                },
                            color(#800000));
                    preview.addSeires("Current Field Z",
                            new float[][]{
                                {0,Float.parseFloat(initData[2])},
                                {Float.parseFloat(duration.getText()),Float.parseFloat(endData[2])}
                                },
                            color(#D4AA00));
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
    
    void onMouseOverMethod(){
        saveButton.onMouseOverMethod();
        newButton.onMouseOverMethod();
        clearButton.onMouseOverMethod();
    }
        
    void mouseDraggedMethod(){
        if(sp.getEngine().equals("LLG"))
            llgPhases.mouseDraggedMethod();
        else
            behaPhases.mouseDraggedMethod();
    }
    
    void mouseWheelMethod(float value){
        if(sp.getEngine().equals("LLG"))
            llgPhases.mouseDraggedMethod();
        else
            behaPhases.mouseWheelMethod(value);
    }

    boolean mousePressedMethod(){
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
            return true;
        }
        boolean boolPhasesAux;
        if(sp.getEngine().equals("LLG")){
            boolPhasesAux = llgPhases.mousePressedMethod();
        } else{
            boolPhasesAux = behaPhases.mousePressedMethod();
        }
        if(boolPhasesAux){
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

    void keyPressedMethod(){
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
