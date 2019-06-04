class HeaderContainer{
    private ArrayList <Button> buttons;
    private Boolean isExpanded;
    private String label;
    private float x, y;
    private color containerColor, expandedColor, labelColor;
    private HitBox hitbox;
    
    public HeaderContainer(String label, float x, float y){
        this.label = label;
        this.isExpanded = false;
        this.x = x;
        this.y = y;
        this.buttons = new ArrayList<Button>();
        this.containerColor = color(45, 80, 22);
        this.expandedColor = color(83, 108, 83);
        this.labelColor = color(255, 255, 255);
        this.hitbox = new HitBox(0, 0, 0, 0);
    }
    
    public void drawSelf(){
        float centerFactor = 0;
        float boxWidth = 0;
        for(int i=0; i<buttons.size(); i+=2){
            float big = buttons.get(i).getWidth();
            if(i+1 < buttons.size() && buttons.get(i+1).getWidth() > big)
                big = buttons.get(i+1).getWidth();
            boxWidth += big + 5;
        } boxWidth += 10;
        textSize(fontSz+5);
        if(textWidth(label) > boxWidth){
            centerFactor = (textWidth(label) + 10 - boxWidth)/2;
            boxWidth = textWidth(label) + 10;
        }
        if(isExpanded){
            fill(expandedColor);
            stroke(expandedColor);
        } else{
            fill(containerColor);
            stroke(containerColor);
        }
        rect(x, y, boxWidth, textAscent() + textDescent() + buttons.get(0).getHeight()*2 + 10);
        fill(labelColor);
        stroke(labelColor);
        hitbox.updateBox(x + (boxWidth - textWidth(label))/2, y, textWidth(label), fontSz+5);
        textSize(fontSz+5);
        text(label, x + (boxWidth - textWidth(label))/2, y+fontSz+5);
        float tempX = x+5+centerFactor, tempY = y+fontSz+10, bigger = 0;
        for(int i=0; i<buttons.size(); i++){
            Button b = buttons.get(i);
            b.setPosition(tempX, tempY);
            b.drawSelf();
            if(b.getWidth() > bigger)
                bigger = b.getWidth();
            if(i%2 == 0){
                tempY += b.getHeight() + 5;
            } else{
                tempY -= b.getHeight() + 5;
                tempX += bigger + 5;
                bigger = 0;
            }
        }
    }
    
    public float getWidth(){
        float boxWidth = 0;
        for(int i=0; i<buttons.size(); i+=2){
            float big = buttons.get(i).getWidth();
            if(i+1 < buttons.size() && buttons.get(i+1).getWidth() > big)
                big = buttons.get(i+1).getWidth();
            boxWidth += big + 5;
        }
        boxWidth = (textWidth(label) > boxWidth)?textWidth(label):boxWidth;
        return boxWidth + 10;
    }
    
    public float getHeight(){
        textSize(fontSz+5);
        return textAscent() + textDescent() + buttons.get(0).getHeight()*2 + 10;
    }
    
    public void setPosition(float x, float y){
        this.x = x;
        this.y = y;
    }
    
    public void onMouseOverMethod(){
        for(int i=0; i<buttons.size(); i++)
            buttons.get(i).onMouseOverMethod();
    }
    
    public void setExpanded(boolean opt){
        isExpanded = opt;
        for(int i=0; i<buttons.size(); i++)
            buttons.get(i).setExpanded(isExpanded);
    }
    
    public String mousePressedMethod(){
        if(hitbox.collision(mouseX, mouseY)){
            isExpanded = !isExpanded;
            for(int i=0; i<buttons.size(); i++)
                buttons.get(i).setExpanded(isExpanded);
            return "HeaderLabel";
        }
        for(int i=0; i<buttons.size(); i++){
            if(buttons.get(i).mousePressedMethod()){
                return buttons.get(i).getLabel();
            }
        }
        return "None";
    }
    
    public void addButton(Button b){
        if(b.getLabel().equals("Grid") || b.getLabel().equals("Bullet"))
            b.active = true;
        b.setExpanded(isExpanded);
        buttons.add(b);
    }
    
    public void deactiveteButton(String label){
        for(int i=0; i<buttons.size(); i++){
            if(buttons.get(i).getLabel().equals(label))
                buttons.get(i).deactivate();
        }
    }
}

class Header{
    HeaderContainer file, magnet, substrate;//, others;
    float x, y, myW;
    SubstrateGrid substrateGrid;
    PanelMenu panelMenu;
    String fileBaseName;
    
    public Header(float x, float y, float w, SubstrateGrid sg){
        this.x = x;
        this.y = y;
        this.myW = w;
        substrateGrid = sg;
        //fontSz = 30;
        
        file = new HeaderContainer("File", x+5, y);
        file.addButton(new Button("Save", "Saves the NML circuit file", sprites.saveIconWhite, 0, 0));
        file.addButton(new Button("New", "Creates a new NML circuit file", sprites.newIconWhite, 0, 0));
        file.addButton(new Button("Save As", "Saves the NML circuit file with a different name", sprites.saveAsIconWhite, 0, 0));
        file.addButton(new Button("Open", "Opens a NML circuit file", sprites.openIconWhite, 0, 0));
        
        magnet = new HeaderContainer("Magnet", x, y);
        //magnet.addButton(new Button("Line Add", "Adds a line of magnets", sprites.lineAddWhite, 0, 0));
        magnet.addButton(new Button("Delete", "Delete a magnet or a group of magnets", sprites.deleteIconWhite, 0, 0));
        //magnet.addButton(new Button("Edit", "Edit a magnet or a group of magnets", sprites.editIconWhite, 0, 0));
        //magnet.addButton(new Button("Pin", "Pin a magnet to show animated magnetization", sprites.pinIconWhite, 0, 0));
        magnet.addButton(new Button("Cut", "Cut from grid a magnet or a group of magnets", sprites.cutIconWhite, 0, 0));
        magnet.addButton(new Button("Copy", "Copy a magnet or a group of magnets", sprites.copyIconWhite, 0, 0));
        magnet.addButton(new Button("Paste", "Paste copied magnets", sprites.pasteIconWhite, 0, 0));
        magnet.addButton(new Button("Up Zone", "Change a selected magnet or group to the next zone", sprites.zoneUpIconWhite, 0, 0));
        magnet.addButton(new Button("Down Zone", "Change a selected magnet or group to the previos zone", sprites.zoneDownIconWhite, 0, 0));
        magnet.addButton(new Button("Group", "Makes a group with selected magnets", sprites.groupIconWhite, 0, 0));
        
        substrate = new HeaderContainer("Substrate", x, y);
        substrate.addButton(new Button("Grid", "Shows the ruler for the minimum cell definition", sprites.gridIconWhite, 0, 0));
        substrate.addButton(new Button("Bullet", "Shows the bullets for reference", sprites.bulletsIconWhite, 0, 0));
        substrate.addButton(new Button("Zoom In", "Zooms in the subtract", sprites.zoomInIconWhite, 0, 0));
        substrate.addButton(new Button("Zoom Out", "Zooms out of the substract", sprites.zoomOutIconWhite, 0, 0));
        substrate.addButton(new Button("Light", "Toggles the light scheme on the substract", sprites.lightIconWhite, 0, 0));
        substrate.addButton(new Button("Move", "Enables cursor to move the substract", sprites.moveIconWhite, 0, 0));

/*        others = new HeaderContainer("Others", x, y);
        others.isExpanded = true;
        others.addButton(new Button("Undo", "Undo last action", sprites.undoIconWhite, 0, 0));
        others.addButton(new Button("Redo", "Redo last undone action", sprites.redoIconWhite, 0, 0));*/
    }
    
    public void drawSelf(){
        float tempX, h = file.getHeight();
        textSize(fontSz+15);
        fill(45, 80, 22);
        stroke(45, 80, 22);
        rect(x, y, myW, h);
        if(file.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(x, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(x, y, 5, h);
        }
        file.drawSelf();
        tempX = file.getWidth() + 10 + x;
        if(file.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(tempX-10, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(tempX-10, y, 5, h);
        }
        if(magnet.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(tempX-5, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(tempX-5, y, 5, h);
        }
        magnet.setPosition(tempX,y);
        magnet.drawSelf();
        strokeWeight(4);
        fill(255,255,255);
        stroke(255,255,255);
        line(tempX-5, y+15, tempX-5, y + h - 15);
        strokeWeight(1);
        tempX += magnet.getWidth() + 10;
        if(magnet.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(tempX-10, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(tempX-10, y, 5, h);
        }
        if(substrate.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(tempX-5, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(tempX-5, y, 5, h);
        }
        substrate.setPosition(tempX,y);
        substrate.drawSelf();
        strokeWeight(4);
        fill(255,255,255);
        stroke(255,255,255);
        line(tempX-5, y+15, tempX-5, y + h - 15);
        strokeWeight(1);
        tempX += substrate.getWidth() + 10;
        if(substrate.isExpanded){
            fill(83, 108, 83);
            stroke(83, 108, 83);
            rect(tempX-10, y, 5, h);
        } else{
            fill(45, 80, 22);
            stroke(45, 80, 22);
            rect(tempX-10, y, 5, h);
        }
        //if(others.isExpanded){
        //    fill(83, 108, 83);
        //    stroke(83, 108, 83);
        //    rect(tempX-5, y, 5, h);
        //} else{
        //    fill(45, 80, 22);
        //    stroke(45, 80, 22);
        //    rect(tempX-5, y, 5, h);
        //}
        //others.setPosition(tempX,y);
        //others.drawSelf();
        //strokeWeight(4);
        //fill(255,255,255);
        //stroke(255,255,255);
        //line(tempX-5, y+15, tempX-5, y + h - 15);
        //strokeWeight(1);
        
        file.onMouseOverMethod();
        magnet.onMouseOverMethod();
        substrate.onMouseOverMethod();
        //others.onMouseOverMethod();
    }
    
    void setPanelMenu(PanelMenu panelMenu){
        this.panelMenu = panelMenu;
    }
    
    float getHeight(){
        return file.getHeight();
    }
        
    public boolean mousePressedMethod(){
        String buttonLabel;
        buttonLabel = file.mousePressedMethod();
        if(buttonLabel.equals("HeaderLabel")){
            if(file.isExpanded){
                magnet.setExpanded(false);
                substrate.setExpanded(false);
            }
            return true;
        }
        if(buttonLabel.equals("New")){
            file.deactiveteButton("New");
            File start = new File(sketchPath("")+"/test");
            selectOutput("Select a file to save", "saveXML", start);
            return true;
        }
        buttonLabel = magnet.mousePressedMethod();
        if(buttonLabel.equals("HeaderLabel")){
            if(magnet.isExpanded){
                file.setExpanded(false);
                substrate.setExpanded(false);
            }
            return true;
        }
        if(buttonLabel.equals("Delete")){
            magnet.deactiveteButton("Delete");
            substrateGrid.deleteSelectedMagnets();
            return true;
        }
        if(buttonLabel.equals("Group")){
            magnet.deactiveteButton("Group");
            substrateGrid.groupSelectedMagnets();
            return true;
        }
        if(buttonLabel.equals("Up Zone")){
            magnet.deactiveteButton("Up Zone");
            substrateGrid.changeSelectedMagnetsZone(true);
            return true;
        }
        if(buttonLabel.equals("Down Zone")){
            magnet.deactiveteButton("Down Zone");
            substrateGrid.changeSelectedMagnetsZone(false);
            return true;
        }
        if(buttonLabel.equals("Copy")){
            magnet.deactiveteButton("Copy");
            substrateGrid.copySelectedMagnetsToClipBoard();
            return true;
        }
        if(buttonLabel.equals("Paste")){
            if(substrateGrid.toPasteStructure.equals("")){
                magnet.deactiveteButton("Paste");
            } else{
                substrateGrid.togglePasteState();
            }
            return true;
        }
        if(buttonLabel.equals("Edit")){
            magnet.deactiveteButton("Edit");
            panelMenu.enableEditing();
            if(!substrateGrid.isLeftHidden)
                substrateGrid.toggleHideGrid("left");
            return true;
        }
        if(buttonLabel.equals("Cut")){
            magnet.deactiveteButton("Cut");
            substrateGrid.copySelectedMagnetsToClipBoard();
            substrateGrid.deleteSelectedMagnets();
            return true;
        }
        buttonLabel = substrate.mousePressedMethod();
        if(buttonLabel.equals("HeaderLabel")){
            if(substrate.isExpanded){
                file.setExpanded(false);
                magnet.setExpanded(false);
            }
            return true;
        }
        if(buttonLabel.equals("Grid")){
            substrateGrid.isRulerActive = !substrateGrid.isRulerActive;
            return true;
        }
        if(buttonLabel.equals("Light")){
            substrateGrid.isLightColor = !substrateGrid.isLightColor;
            return true;
        }
        if(buttonLabel.equals("Zoom In")){
            substrateGrid.zoomIn();
            substrate.deactiveteButton("Zoom In");
            return true;
        }
        if(buttonLabel.equals("Zoom Out")){
            substrateGrid.zoomOut();
            substrate.deactiveteButton("Zoom Out");
            return true;
        }
        if(buttonLabel.equals("Bullet")){
            substrateGrid.toggleBullet();
            return true;
        }
        if(buttonLabel.equals("Move")){
            substrateGrid.toggleMoving();
            return true;
        }
        //buttonLabel = others.mousePressedMethod();
        //if(buttonLabel.equals("HeaderLabel"))
        //    return true;
        return false;
    }
}
