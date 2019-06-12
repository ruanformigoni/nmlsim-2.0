public class FileHandler{
    String fileBaseName;
    Header header;
    PanelMenu panelMenu;
    SubstrateGrid substrateGrid;
    PrintWriter xmlFileOut, configFileOut, structureFileOut;
    BufferedReader configFileIn, structureFileIn;
    
    FileHandler(String baseName, Header h, PanelMenu pm, SubstrateGrid sg){
        fileBaseName = baseName;
        header = h;
        panelMenu = pm;
        substrateGrid = sg;
    }
    
    void setBaseName(String baseName){
        fileBaseName = baseName;
    }
    
    void writeStructureFile(){
        ArrayList <String> structures = panelMenu.getStructures();
        structureFileOut = createWriter(fileBaseName + "/structures.str");
        for(String s : structures)
            structureFileOut.println(s);
        structureFileOut.flush();
        structureFileOut.close();
        
    }
    
    void readStructureFile(){
        ArrayList<String> structures = new ArrayList<String>();
        structureFileIn = createReader(fileBaseName + "/structures.str");
        try{
            String line = structureFileIn.readLine();
            while(line != null && !line.equals("")){
                structures.add(line);
                line = structureFileIn.readLine();
            }
            panelMenu.loadStructures(structures);
            structureFileIn.close();
        } catch(Exception e){}
    }
    
    void readConfigFile(){
        structureFileIn = createReader(fileBaseName + "/configurations.nmls");
        try{
            String circuit = structureFileIn.readLine();
            String grid = structureFileIn.readLine();
            panelMenu.simPanel.loadProperties(circuit, grid);
            
            String line = structureFileIn.readLine();
            while(!line.equals("Phases"))
                line = structureFileIn.readLine();
            line = structureFileIn.readLine();
            ArrayList <String> phases = new ArrayList<String>(); 
            while(!line.equals("Zones")){
                phases.add(line);
                line = structureFileIn.readLine();
            }
            panelMenu.phasePanel.loadPhaseProperties(phases);
            
            line = structureFileIn.readLine();
            ArrayList <String> zones = new ArrayList<String>(); 
            while(!line.equals("Magnets")){
                zones.add(line);
                line = structureFileIn.readLine();
            }
            panelMenu.zonePanel.loadZoneProperties(zones);
            panelMenu.magnetPanel.updateZones();
            
            line = structureFileIn.readLine();
            substrateGrid.randomName = Integer.parseInt(line);
            line = structureFileIn.readLine();
            ArrayList <String> magnets = new ArrayList<String>(); 
            while(line != null && !line.equals("")){
                magnets.add(line);
                line = structureFileIn.readLine();
            }
            substrateGrid.loadMagnetProperties(magnets);
            
            structureFileIn.close();
        } catch(Exception e){}
    }
    
    void writeConfigFile(String filename){
        if(filename == null || filename.equals(""))
            structureFileOut = createWriter(fileBaseName + "/configurations.nmls");
        else
            structureFileOut = createWriter(filename);
        String circuit = panelMenu.getCircuitProperties();
        String grid = panelMenu.simPanel.getGridProperties();
        ArrayList<String> phases = pm.getPhaseProperties();
        ArrayList<String> zones = pm.getZoneProperties();
        ArrayList<String> magnets = sg.getMagnetsProperties();
        
        structureFileOut.println(circuit);
        structureFileOut.println(grid);
        structureFileOut.println("Phases");
        for(String p : phases){
            structureFileOut.println(p);
        }
        structureFileOut.println("Zones");        
        for(String z : zones){
            structureFileOut.println(z);
        }
        structureFileOut.println("Magnets");
        structureFileOut.println(substrateGrid.randomName);
        for(String m : magnets){
            structureFileOut.println(m);
        }
        
        structureFileOut.flush();
        structureFileOut.close();
    }
    
    void writeXmlFile(String filename){
        if(filename == null || filename.equals(""))
            xmlFileOut = createWriter(fileBaseName + "/simulation.xml");
        else
            xmlFileOut = createWriter(filename);
        //engine;mode;method;repetitions;reportStep;alpha;ms;temperature;timeStep;simTime;spinAngle;spinDiff;hmt;neighborhood
        String [] circuitParts = panelMenu.getCircuitProperties().split(";");
        xmlFileOut.println("<!-- ALL measures of time are in nanoseconds and ALL metric measures are in nanometers -->\n" + 
                           "<!-- This is the main circuit properties, such as technology, engine and others -->\n" + 
                           "<!-- Each engine had different properties to be setted in this field -->\n" + 
                           "<circuit>\n" + 
                           "\t<!-- There are 2 engines: LLG and Behaviour. There is only iNML technology for now -->\n" +
                           "\t<property technology=\"iNML\" engine=\"" + circuitParts[0] + "\"/>\n" +
                           "\t<!-- There are two possible different methods for the LLG engine, the RK4 and the RKW2 - Runge Kutta 4th order and Runge Kutta Weak 2nd order -->\n" +
                           "\t<!-- Be mindfull that the RK4 method disconsiders the temperature -->\n" + 
                           "\t<property method=\"" + circuitParts[2] + "\"/>\n" + 
                           "\t<!-- There are 4 simulationMode: exaustive, direct, repetitive and verbose -->\n" +
                           "\t<property simulationMode=\"" + circuitParts[1] + "\"/>\n" +
                           "\t<!-- The number of simulations to be done in the repetitive mode -->\n" +
                           "\t<property repetitions=\"" + circuitParts[3] + "\"/>\n" +
                           "\t<!-- The report time step. Starting at time 0, the program reports at each reportStep. Only used in verbose mode -->\n" +
                           "\t<property reportStep=\"" + circuitParts[4] + "\"/>\n" +
                           "\t<!-- Gilbert damping factor -->\n" +
                           "\t<property alpha=\"" + circuitParts[5] + "\"/>\n" +
                           "\t<!-- Saturation Magnetization in A/m -->\n" +
                           "\t<property Ms=\"" + circuitParts[6] + "\"/>\n" +
                           "\t<!-- Temperature in K. Be mindfull that the RK-Weak order 2.0 (RKW2) is used for T > 0 and the RK of fourth order (RK4) for T == 0 -->\n" +
                           "\t<property temperature=\"" + circuitParts[7] + "\"/>\n" +
                           "\t<!-- Discretization of time in nanoseconds. It's highly recommended using very low timeStep -->\n" +
                           "\t<property timeStep=\"" + circuitParts[8] + "\"/>\n" +
                           "\t<!-- Simulation Duration in nanoseconds -->\n" +
                           "\t<property simTime=\"" + circuitParts[9] + "\"/>\n" +
                           "\t<!-- Properties for the heavy material for spin hall effect -->\n" +
                           "\t<property spinAngle=\"" + circuitParts[10] + "\"/>\n" +
                           "\t<property spinDifusionLenght=\"" + circuitParts[11] + "\"/>\n" +
                           "\t<!-- Thickness in nanometers -->\n" + 
                           "\t<property heavyMaterialThickness=\"" + circuitParts[12] + "\"/>\n" +
                           "\t<!-- Radius of the considered neighborhood. We recomend using values of 300 for more efficciency. -->\n" +
                           "\t<property neighborhoodRatio=\"" + circuitParts[13] + "\"/>\n" +
                           "</circuit>\n");
                           
        ArrayList<String> phases = pm.getPhaseProperties();
        xmlFileOut.println("<!-- This is the clock phases properties -->\n<clockPhase>\n" +
                           "\t<!-- Each clock phase must be an item -->\n\t<!-- Each clock phase must have a different name, which can be whatever name -->\n" +
                           "\t<!-- The format for RKW2 uses a clock signal with 6 values. The 3 first are external field (x,y,z) and the 3 last are current field (x,y,z) -->\n" +
                           "\t<!-- Users can use both an external field and a current field with LLG. In order to not use one of them, just leave its fields as 0 -->\n" +
                           "\t<!-- The format for the Behaviour engine uses only one value for clock signal. The value corresponds to a field applied on x direction -->\n" +
                           "\t<!-- The value for signal in the Behaviour engine needs to be in the [0,1] interval, where 0 represents no clock and 1 represents 100% force -->\n" +
                           "\t<!-- Phases can have different durations, but be mindfull of their sincronization -->");
        for(String phase : phases){
            String parts[] = phase.split(";");
            if(parts[1].contains(",")){
                xmlFileOut.println("\t<item name=\"" + parts[0] + "\">\n" +
                                   "\t\t<property initialSignal=\"" + parts[1] + parts[3] + "\"/>\n" +
                                   "\t\t<property endSignal=\"" + parts[2] + parts[4] + "\"/>\n" +
                                   "\t\t<property duration=\"" + parts[5] + "\"/>\n\t</item>");
            }else{
                xmlFileOut.println("\t<item name=\"" + parts[0] + "\">\n" +
                                   "\t\t<property initialSignal=\"" + parts[1] + "\"/>\n" +
                                   "\t\t<property endSignal=\"" + parts[2] + "\"/>\n" +
                                   "\t\t<property duration=\"" + parts[3] + "\"/>\n\t</item>");
            }
        }
        xmlFileOut.println("</clockPhase>\n");
       
        ArrayList<String> zones = pm.getZoneProperties();
        HashMap<String,Integer> zoneIndex = new HashMap<String,Integer>();
        xmlFileOut.println("<!-- This is the clock zone properties -->\n<clockZone>\n\t<!-- Each clock zone must be an item -->\n" +
                           "\t<!-- Each clock zone must have an integer numerical name, starting in 0 and following growing sequence (0,1,2,3,etc) -->\n" +
                           "\t<!-- All phases that a zone percieve must be listed -->\n" +
                           "\t<!-- The order of the phases matter a lot, since the zone will start with the first phase and follow the order from top to bottom -->\n" +
                           "\t<!-- The order of the phases are ciclycal, which means the first phase start again after the end of the last one -->");
        int index = 0;
        for(String zone : zones){
            String parts[] = zone.split(";");
            xmlFileOut.println("\t<item name=\"" + index + "\">");
            for(int i=1; i<parts.length-1; i++){
                xmlFileOut.println("\t\t<property phase=\"" + parts[i] + "\">");
            }
            xmlFileOut.println("\t</item>");
            zoneIndex.put(parts[0],index);
            index++;
        }
        xmlFileOut.println("</clockZone>");
       
        /*name;type;clockZone;magnetization;fixed;w;h;tk;tc;bc;position;zoneColor*/
        ArrayList<String> magnets = sg.getMagnetsProperties();
        magnets.sort(String.CASE_INSENSITIVE_ORDER);
        HashMap<String,String> components = new HashMap<String,String>();
        int compName = 0;
        xmlFileOut.println("<!-- This is the components properties -->\n<components>\n\t<!-- List here all different geometries of magnets in the circuit -->" +
                           "\t<!-- This part also is used to determine if a magnet is fixed or not -->\n\t<!-- Each different geometry must be an item -->\n" +
                           "\t<!-- Each geometry must have a unique name, which can be whatever -->");
        for(String magnet : magnets){
            String [] parts = magnet.split(";");
            String component = "\t\t<property width=\"" + parts[5] + "\"/>\n\t\t<property height=\"" + parts[6] + "\"/>\n\t\t<property thickness=\"" + parts[7] + "\"/>\n" +
                               "\t\t<property topCut=\"" + parts[8] + "\"/>\n\t\t<property bottomCut=\"" + parts[9] + "\"/>\n";
            if(!components.containsKey(component)){
                xmlFileOut.println("\t<item name=\"component_" + compName + "\">\n" + component + "\t</item>");
                components.put(component, "component_"+compName);
                compName++;
            }

        }
        xmlFileOut.println("</components>");
        
        xmlFileOut.println("<!-- This is the design properties -->\n<design>\n\t" +
                           "<!-- List here all magnets of the circuit. Note that the geometry section does not insert any magnet in the circuit! -->\n" +
                           "\t<!-- Each magnet must be an item -->\n\t<!-- Each magnet must have a unique name, which can be whatever -->");
        for(String magnet : magnets){
            String [] parts = magnet.split(";");
            String component = "\t\t<property width=\"" + parts[5] + "\"/>\n\t\t<property height=\"" + parts[6] + "\"/>\n\t\t<property thickness=\"" + parts[7] + "\"/>\n" +
                               "\t\t<property topCut=\"" + parts[8] + "\"/>\n\t\t<property bottomCut=\"" + parts[9] + "\"/>\n";
            xmlFileOut.println("\t<item name=\"" + parts[0] + "\">\n\t\t<property component=\"" + components.get(component) + "\"/>\n" +
                               "\t\t<property myType=\"" + parts[1] + "\"/>\n\t\t<property fixedMagnetization=\"" + parts[4] + "\"/>\n" +
                               "\t\t<property position=\"" + parts[10] + "\"/>\n\t\t<property clockZone=\"" + zoneIndex.get(parts[2]) + "\"/>\n" +
                               "\t\t<property magnetization=\"" + parts[3] + "\"/>\n\t</item>");
        }
        xmlFileOut.println("</design>");
        xmlFileOut.flush();
        xmlFileOut.close();
    }
}
