import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;

class SimulationBar{
    float x, y, w, h;
    int animationSpeed, animationTime, counter = 0;
    Button forward, backward, play, pause, stop, simulate, charts, export, upSpeed, downSpeed, timeline, exportGif;
    color panelColor, textColor, lineColor;
    SubstrateGrid substrateGrid;
    PanelMenu panelMenu;
    ArrayList <String> labels;
    ArrayList <ArrayList<Float>> magX, magY;
    boolean timelineEnabled = false, timelineRunning = false, isRecording = false;
    
    SimulationBar(float x, float y, float w, float h, SubstrateGrid substrateGrid, PanelMenu panelMenu){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        animationSpeed = 50;
        animationTime = 0;
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
        charts = new Button("Chart", "Plot the magnetization chart for the selected magnets", sprites.chartIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        export = new Button("Export", "Exports the XML file for the simulation engine", sprites.medSaveAsIconWhite, auxX, (h-20)/2+y);
        auxX += 25;
        timeline = new Button("Timeline", "Enables the timeline animation", sprites.timelineIconWhite, auxX, (h-25)/2+y);
        auxX += 30;
        exportGif = new Button("Export Gif", "Records and exports the timeline animation as a Gif", sprites.exportGifIconWhite, auxX, (h-25)/2+y);
        
        panelColor = color(45, 80, 22);
        textColor = color(255,255,255);
        lineColor = color(255,255,255);
        
        this.substrateGrid = substrateGrid;
        this.panelMenu = panelMenu;
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
        backward.isTransparent = !timelineEnabled;
        backward.drawSelf();
        pause.isTransparent = !timelineEnabled || !timelineRunning;
        pause.drawSelf();
        stop.isTransparent = !timelineEnabled || !timelineRunning;
        stop.drawSelf();
        play.isTransparent = !timelineEnabled || timelineRunning;
        play.drawSelf();
        forward.isTransparent = !timelineEnabled;
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
        timeline.drawSelf();
        exportGif.isTransparent = !timelineEnabled;
        exportGif.drawSelf();
        
        strokeWeight(3);
        stroke(lineColor);
        auxX += 235;
        line(auxX, y+5, auxX, y+h-5);
        auxX += 2;
        noStroke();
        strokeWeight(1);
        
        fill(textColor, 255);
        if(timelineEnabled)
            text("Timeline clock (ns): " + animationTime*panelMenu.getReportStep(), auxX+5, y+fontSz+5);
        else
            text("Timeline deactivated", auxX+5, y+fontSz+5);
        
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
        timeline.onMouseOverMethod();
        exportGif.onMouseOverMethod();
        
        if(timelineEnabled && timelineRunning && counter >= (100-animationSpeed)/10){
            forwardSimulation();
            if(isRecording){
                saveFrame(fileSys.fileBaseName + "/gif/frame" + String.format("%1$15s",Integer.toString(animationTime)).replace(" ", "0") + ".png");
            }
            counter = 0;
        } else if(!timelineEnabled){
            counter = 0;
        } else if(timelineEnabled && timelineRunning){
            counter++;
        }
    }
    
    void loadSimulationResultsFile(){
        animationTime = 0;
        labels = new ArrayList<String>();
        magX = new ArrayList<ArrayList<Float>>();
        magY = new ArrayList<ArrayList<Float>>();        
        try{
            BufferedReader file = createReader(fileSys.fileBaseName + "/simulation.csv");
            String line = file.readLine();
            String [] parts = line.split(",");
            for(int i=1; i<parts.length; i+=3){
                labels.add(parts[i].substring(0,parts[i].length()-2));
            }
            line = file.readLine();
            parts = line.split(",");
            for(int i=1; i<parts.length; i+=3){
                magX.add(new ArrayList<Float>());
                magX.get(magX.size()-1).add(Float.parseFloat(parts[i]));
                magY.add(new ArrayList<Float>());
                magY.get(magY.size()-1).add(Float.parseFloat(parts[i+1]));
            }
            while(line != null && !line.equals("")){
                parts = line.split(",");
                int index = 0;
                for(int i=1; i<parts.length; i+=3){
                    magX.get(index).add(Float.parseFloat(parts[i]));
                    magY.get(index).add(Float.parseFloat(parts[i+1]));
                    index++;
                }
                line = file.readLine();
            }
        } catch(Exception e){
        }
    }
    
    void forwardSimulation(){
        animationTime++;
        if(animationTime >= magX.get(0).size()){
            animationTime--;
            return;
        }
        for(int i=0; i<labels.size(); i++){
            substrateGrid.setMagnetMagnetization(labels.get(i),magX.get(i).get(animationTime), magY.get(i).get(animationTime));
        }
    }
    
    void backwardSimulation(){
        animationTime--;
        if(animationTime < 0){
            animationTime++;
            return;
        }
        for(int i=0; i<labels.size(); i++){
            substrateGrid.setMagnetMagnetization(labels.get(i),magX.get(i).get(animationTime), magY.get(i).get(animationTime));
        }
    }
    
    void disableTimeline(){
        timelineEnabled = false;
        timelineRunning = false;
        isRecording = false;
        timeline.deactivate();
        play.deactivate();
        pause.deactivate();
        stop.deactivate();
        simulate.deactivate();
        exportGif.deactivate();
    }
    
    void keyPressedMethod(){
        if(altPressed && int(key) == 115 && !fileSys.fileBaseName.equals("")){ //Simulate
            saveProject();
            try{
                exec("gnome-terminal", "-e", sketchPath() + "/../../nmlsim " + fileSys.fileBaseName + "/simulation.xml " +  fileSys.fileBaseName + "/simulation.csv");
            } catch(Exception e){
                e.printStackTrace();
            }
            timelineEnabled = false;
            timelineRunning = false;
            isRecording = false;
            timeline.deactivate();
            play.deactivate();
            pause.deactivate();
            stop.deactivate();
            if(animationTime > 0){
                animationTime = 1;
                backwardSimulation();
            }
            simulate.deactivate();
            exportGif.deactivate();
        }
        if(altPressed && int(key) == 99){ //Chart
            String call = substrateGrid.getSelectedMagnetsNames();
            if(!call.equals("")){
                try{
                    exec("gnome-terminal", "-e", "python3 " + sketchPath() + "/../../chart.py " + fileSys.fileBaseName + "/simulation.csv " + call);
                } catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
        if(altPressed && int(key) == 101){ //Export XML
            File start = new File(sketchPath("")+"/sim.xml");
            selectOutput("Select a file to export the simulation", "exportXML", start);
        }
        if(altPressed && int(key) == 116 && panelMenu.getSimulationMode().equals("verbose")){ //Activate timeline
            Path p = Paths.get(fileSys.fileBaseName + "/simulation.csv");
            if(!Files.exists(p)){
                timeline.deactivate();
                return;
            }
            if(animationTime > 0){
                animationTime = 1;
                backwardSimulation();
            }
            loadSimulationResultsFile();
            timelineEnabled = !timelineEnabled;
            if(!timelineEnabled){
                exportGif.deactivate();
                isRecording = false;
            }
            timelineRunning = false;
            timeline.active = timelineEnabled;
        }
        if(altPressed && int(key) == 114){ //Record Gif
            isRecording = !isRecording;
            if(!isRecording){
                try{
                    exec("gnome-terminal", "-e", "sh -c \"convert -delay 10 " + fileSys.fileBaseName + "/gif/*.png +repage -loop 0 -strip -coalesce -layers Optimize " + fileSys.fileBaseName + "/simulationAnimation.gif ; " + "rm -rf " + fileSys.fileBaseName + "/gif\"");
                } catch(Exception e){
                    e.printStackTrace();
                }
            }
            exportGif.active = isRecording;
        }
        if(altPressed && int(key) == 112){ //Play and Pause
            if(timelineEnabled){
                timelineRunning = !timelineRunning;
            }
        }
        if(altPressed && int(key) == 80){ //Stop
            if(timelineEnabled){
                timelineRunning = false;
                animationTime = 1;
                backwardSimulation();
            }
        }
        if(keyCode == LEFT){ //Backward
            backwardSimulation();
            timelineRunning = false;
        }
        if(keyCode == RIGHT){ //Forward
            forwardSimulation();
            timelineRunning = false;
        }
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
            try{
                exec("gnome-terminal", "-e", sketchPath() + "/../../nmlsim " + fileSys.fileBaseName + "/simulation.xml " +  fileSys.fileBaseName + "/simulation.csv");
            } catch(Exception e){
                e.printStackTrace();
            }
            timelineEnabled = false;
            timelineRunning = false;
            isRecording = false;
            timeline.deactivate();
            play.deactivate();
            pause.deactivate();
            stop.deactivate();
            if(animationTime > 0){
                animationTime = 1;
                backwardSimulation();
            }
            simulate.deactivate();
            exportGif.deactivate();
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
            } else{
                PopUp pop = new PopUp(((width-250)/2)*scaleFactor, ((height-100)/2)*scaleFactor, 250, 100, "Select at least one magnet!");
                pop.activate();
                pop.setAsTimer(60);
                popCenter.setPopUp(pop);
            }
        }
        if(panelMenu.getSimulationMode().equals("verbose") && timeline.mousePressedMethod()){
            Path p = Paths.get(fileSys.fileBaseName + "/simulation.csv");
            if(!Files.exists(p)){
                timeline.deactivate();
                PopUp pop = new PopUp(((width-400)/2)*scaleFactor, ((height-100)/2)*scaleFactor, 400, 100, "Please perform a verbose simulation first!");
                pop.activate();
                pop.setAsTimer(80);
                popCenter.setPopUp(pop);
                return;
            }
            if(animationTime > 0){
                animationTime = 1;
                backwardSimulation();
            }
            loadSimulationResultsFile();
            timelineEnabled = !timelineEnabled;
            if(!timelineEnabled){
                exportGif.deactivate();
                isRecording = false;
            }
            timelineRunning = false;
        }
        if(!panelMenu.getSimulationMode().equals("verbose") && timeline.mousePressedMethod()){
            PopUp pop = new PopUp(((width-400)/2)*scaleFactor, ((height-100)/2)*scaleFactor, 400, 100, "Please perform a verbose simulation first!");
            pop.activate();
            pop.setAsTimer(80);
            popCenter.setPopUp(pop);
        }
        if(timelineEnabled && !timelineRunning && play.mousePressedMethod()){
            play.deactivate();
            timelineRunning = true;
        }
        if(timelineEnabled && timelineRunning && pause.mousePressedMethod()){
            pause.deactivate();
            timelineRunning = false;
        }
        if(timelineEnabled && timelineRunning && stop.mousePressedMethod()){
            stop.deactivate();
            timelineRunning = false;
            animationTime = 1;
            backwardSimulation();
        }
        if(timelineEnabled && forward.mousePressedMethod()){
            forward.deactivate();
            forwardSimulation();
            timelineRunning = false;
        }
        if(timelineEnabled && backward.mousePressedMethod()){
            backward.deactivate();
            backwardSimulation();
            timelineRunning = false;
        }
        if(exportGif.mousePressedMethod()){
            isRecording = !isRecording;
            if(!isRecording){
                try{
                    exec("gnome-terminal", "-e", "sh -c \"convert -delay 10 " + fileSys.fileBaseName + "/gif/*.png +repage -loop 0 -strip -coalesce -layers Optimize " + fileSys.fileBaseName + "/simulationAnimation.gif ; " + "rm -rf " + fileSys.fileBaseName + "/gif\"");
                } catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
    }
}
