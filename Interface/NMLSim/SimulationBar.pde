class SimulationBar{
    float x, y, w, h;
    int animationSpeed;
    Button forward, backward, play, pause, stop, simulate, charts, export, upSpeed, downSpeed;
    color panelColor, textColor, lineColor;
    SubstrateGrid substrateGrid;
    
    SimulationBar(float x, float y, float w, float h, SubstrateGrid substrateGrid){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        animationSpeed = 50;
        textSize(fontSz);
        float auxX = x + textWidth("Timeline") + 10;
        backward = new Button("Backward", "Make one step back in the simulation animation", sprites.backwardIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        stop = new Button("Stop", "Stop the animation and reset the magnetization to initial state", sprites.stopIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        pause = new Button("Pause", "Pauses the simulation animation", sprites.pauseIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        play = new Button("Play", "Resumes or start the simulation animation", sprites.playIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        forward = new Button("Forward", "Make one step forward in the simulation animation", sprites.forwardIconWhite, auxX, (h-25)/2+y);
        auxX += 30 + textWidth("Speed: 100") + 20;
        upSpeed = new Button("Upgrade Speed", "Upgrades the speed of the simulation animation", sprites.nanoArrowUpIconWhite, auxX, (h-15)/2+y);
        auxX += 20;
        downSpeed = new Button("Downgrade Speed", "Downgrades the speed of the simulation animation", sprites.nanoArrowDownIconWhite, auxX, (h-15)/2+y);
        auxX += 20 + textWidth("Simulation") + 20;
        simulate = new Button("Simulate", "Performes the engine simulation", sprites.simulationIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        charts = new Button("Results", "Opens the simulation results panel", sprites.chartIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        export = new Button("Export", "Exports the XML file for the simulation engine", sprites.medSaveAsIconWhite, auxX, (h-20)/2+y);
        
        panelColor = color(45, 80, 22);
        textColor = color(255,255,255);
        lineColor = color(255,255,255);
        
        this.substrateGrid = substrateGrid;
    }
    
    void drawSelf(){
        upSpeed.isTransparent = animationSpeed == 100;
        downSpeed.isTransparent = animationSpeed == 0;
        
        float auxX = 5;
        fill(panelColor);
        stroke(panelColor);
        rect(x, y, w, h);
        fill(textColor, 255);
        noStroke();
        textSize(fontSz);
        text("Timeline", auxX, y+fontSz+5);
        auxX += textWidth("Timeline") + 5;
        backward.drawSelf();
        pause.drawSelf();
        stop.drawSelf();
        play.drawSelf();
        forward.drawSelf();
        
        strokeWeight(3);
        stroke(lineColor);
        auxX += 153;
        line(auxX, y+5, auxX, y+h-5);
        auxX += 2;
        noStroke();
        strokeWeight(1);
        
        fill(textColor, 255);
        text("Speed: " + animationSpeed, auxX+5, y+fontSz+5);
        auxX += textWidth("Speed: 100")+10;
        upSpeed.drawSelf();
        downSpeed.drawSelf();

        strokeWeight(3);
        stroke(lineColor);
        auxX += 53;
        line(auxX, y+5, auxX, y+h-5);
        auxX += 2;
        noStroke();
        strokeWeight(1);

        fill(textColor, 255);
        text("Simulation", auxX+5, y+fontSz+5);
        charts.drawSelf();
        simulate.drawSelf();
        export.drawSelf();
        
        strokeWeight(2);
        stroke(lineColor);
        auxX += 53;
        line(x, y-1, x+w, y-1);
        auxX += 2;
        noStroke();
        strokeWeight(1);

        export.onMouseOverMethod();
        charts.onMouseOverMethod();
        simulate.onMouseOverMethod();
        downSpeed.onMouseOverMethod();
        upSpeed.onMouseOverMethod();
        forward.onMouseOverMethod();
        play.onMouseOverMethod();
        pause.onMouseOverMethod();
        stop.onMouseOverMethod();
        backward.onMouseOverMethod();
    }
    
    void mousePressedMethod(){
        if(upSpeed.mousePressedMethod()){
            upSpeed.deactivate();
            if(animationSpeed < 100)
                animationSpeed += 10;
        }
        if(downSpeed.mousePressedMethod()){
            downSpeed.deactivate();
            if(animationSpeed > 0)
                animationSpeed -= 10;
        }
        if(export.mousePressedMethod()){
            export.deactivate();
            File start = new File(sketchPath("")+"/sim.xml");
            selectOutput("Select a file to export the simulation", "exportXML", start);
        }
        if(simulate.mousePressedMethod() && !fileSys.fileBaseName.equals("")){
            saveProject();
            simulate.deactivate();
            try{
                exec("gnome-terminal", "-e", sketchPath() + "/../../nmlsim " + fileSys.fileBaseName + "/simulation.xml " +  fileSys.fileBaseName + "/simulation.csv");
            } catch(Exception e){
                e.printStackTrace();
            }
        }
        if(charts.mousePressedMethod()){
            charts.deactivate();
            String call = substrateGrid.getSelectedMagnetsNames();
            if(!call.equals("")){
                try{
                    exec("gnome-terminal", "-e", "python3 " + sketchPath() + "/../../chart.py " + fileSys.fileBaseName + "/simulation.csv " + call);
                } catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
    }
}
