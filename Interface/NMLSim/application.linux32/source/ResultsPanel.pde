class ResultsPanel{
    float x, y, w, h;
    TextBox fontSize, startRange, endRange, numberOfColumns;
    CheckBox xComponent, yComponent, zComponent, customSeriesStart, customSeriesEnd, customNumberOfColumns;
    DropDownBox plotMode;
    Button chartButton;
    SubstrateGrid substrateGrid;
    color panelColor, textColor;
    
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

    void setSubstrateGrid(SubstrateGrid sg){
        substrateGrid = sg;
    }
    
    void drawSelf(){
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
    
    boolean validateAllFields(){
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
    
    void mousePressedMethod(){
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
    
    void keyPressedMethod(){
        if(customSeriesStart.isChecked)
           startRange.keyPressedMethod();
        if(customSeriesEnd.isChecked)
           endRange.keyPressedMethod();
        if(customNumberOfColumns.isChecked)
            numberOfColumns.keyPressedMethod();
        fontSize.keyPressedMethod();
   }
}
