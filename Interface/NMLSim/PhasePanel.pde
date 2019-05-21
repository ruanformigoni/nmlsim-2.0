class PhasePanel{
    float x, y, w, h;
    TextBox name, duration, initialBeha, endBeha;
    VectorTextBox initialField, endField, initialCurr, endCurr;
    Button saveButton, newButton;
    color panelColor, textColor;
    SimulationPanel sp;
    ListContainer allPhases;

    PhasePanel(float x, float y, float w, float h, SimulationPanel sp){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.sp = sp;
        textSize(fontSz);
        panelColor = color(45, 80, 22);
        textColor = color(255,255,255);
        
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
        
        allPhases = new ListContainer("All Phases", 0, 0, w, h);
        allPhases.deleteEnabled = true;
        allPhases.editEnabled = true;
    }
    
    void drawSelf(){
        textSize(fontSz+5);
        fill(panelColor);
        stroke(panelColor);
        rect(x, y, w, h);
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
        
        if(name.validateText() & allPhases.isIn(name.getText())){
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
        
        allPhases.setPositionAndSize(x+10,auxY,w-20,h-(auxY-y)-150);
        allPhases.drawSelf();
        
        auxY += h-(auxY-y)-150 + 5;
        
        strokeWeight(4);
        stroke(color(255,255,255));
        line(x+10, auxY, x+w-10, auxY);
        auxY += 20;
        noStroke();
        strokeWeight(1);
    }
    
    void onMouseOverMethod(){
        saveButton.onMouseOverMethod();
        newButton.onMouseOverMethod();
    }
        
    void mouseDraggedMethod(){
        allPhases.mouseDraggedMethod();
    }
    
    void mouseWheelMethod(float value){
        allPhases.mouseWheelMethod(value);
    }

    boolean mousePressedMethod(){
        boolean hit = false;
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
            if(!invalid & !allPhases.isIn(name.getText())){
                allPhases.addItem(name.getText());
            }
            return true;
        }
        allPhases.mousePressedMethod();
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

    boolean keyPressedMethod(){
        boolean hit = false;
        hit = hit | name.keyPressedMethod();
        hit = hit | initialBeha.keyPressedMethod();
        hit = hit | endBeha.keyPressedMethod();
        hit = hit | initialField.keyPressedMethod();
        hit = hit | endField.keyPressedMethod();
        hit = hit | initialCurr.keyPressedMethod();
        hit = hit | endCurr.keyPressedMethod();
        hit = hit | duration.keyPressedMethod();
        return hit;
    }
}
