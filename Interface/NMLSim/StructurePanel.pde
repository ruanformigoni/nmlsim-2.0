class StructurePanel{
    float x, y, w, h;
    int foldSize;
    ArrayList <TextButton> structuresButtons;
    ArrayList <Button> delete;
    Scrollbar scroll;
    int selectedStructure, randomName;
    color panelColor, textColor;
    Button editButton, saveTemplateButton, saveButton;
    HashMap<String, String> structuresValues;
    boolean isEditing;
    
    StructurePanel(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        textSize(fontSz);
        foldSize = int((h-(textAscent() + textDescent())-35)/(textAscent() + textDescent()+5));
        scroll = new Scrollbar(x+w-20, y+textAscent()+textDescent()+10, 20, h-(textAscent()+textDescent())-35, 1, foldSize, true);
        selectedStructure = -1;
        randomName = 0;
        structuresButtons = new ArrayList<TextButton>();
        delete = new ArrayList<Button>();
        structuresValues = new HashMap<String, String>();
        panelColor = color(45,80,22);
        textColor = color(255,255,255);
        isEditing = false;
        
        editButton = new Button("Edit", "Enables the structure editing", sprites.smallEditIconWhite, x+w-30, y+h-20);
        editButton.explanationOnRight = false;
        saveButton = new Button("Save", "Disables the structure editing, saving all changes", sprites.smallSaveIconWhite, x+w-30, y+h-20);
        saveButton.isValid = false;
        saveButton.explanationOnRight = false;
        saveTemplateButton = new Button("Save Template", "Saves the selected magnets as a new structure", sprites.smallSaveTemplateIconWhite, x+w-60, y+h-20);
        saveTemplateButton.explanationOnRight = false;
    }
    
    void addStructure(String label, String structure){
        structuresValues.put(label, structure);
        for(int i=0; i<structuresButtons.size(); i++){
            if(structuresButtons.get(i).getText().equals(label)){
                return;
            }
        }
        structuresButtons.add(new TextButton(label, 0, 0, w-45));
        delete.add(new Button("Delete", "Delete the structure from the list", sprites.nanoDeleteIconWhite, 0, 0));
        delete.get(delete.size()-1).explanationOnRight = false;
        scroll.increaseMaxIndex();
    }
    
    void drawSelf(){
        textSize(fontSz);
        float aux = textAscent()+textDescent()+5;
        float auxY = y+aux+5;
        fill(panelColor);
        stroke(panelColor);
        rect(x, y, w, h, 15, 15, 0, 0);

        fill(textColor);
        noStroke();
        text("Structures Panel", x+10+((w-20)/2-textWidth("Structures Panel")/2), y+5+fontSz);
        int currIndex = scroll.getIndex();
        for(int i=0; i<structuresButtons.size(); i++){
            structuresButtons.get(i).isValid = false;
            delete.get(i).isValid = false;
        }
        if(currIndex >= 0){
            for(int iAux=0; iAux<foldSize; iAux++){
                if(structuresButtons.size() <= iAux+currIndex)
                    break;
                int i = iAux + currIndex;
                structuresButtons.get(i).setPosition(x+10, auxY);
                if(isEditing){
                    structuresButtons.get(i).setWidth(w-60);
                    structuresButtons.get(i).drawSelf();
                    structuresButtons.get(i).isValid = true;
                    delete.get(i).setPosition(x+w-45, (aux-20)/2+auxY);
                    delete.get(i).isValid = true;
                    delete.get(i).drawSelf();
                    delete.get(i).onMouseOverMethod();
                }
                else{
                    structuresButtons.get(i).setWidth(w-35);
                    structuresButtons.get(i).isTyping = false;
                    structuresButtons.get(i).drawSelf();
                    structuresButtons.get(i).isValid = true;
                }
                
                auxY += aux;
            }
        }
        saveTemplateButton.drawSelf();
        saveTemplateButton.onMouseOverMethod();
        if(isEditing){
            saveButton.drawSelf();
            saveButton.isValid = true;
            editButton.isValid = false;
            saveButton.onMouseOverMethod();
        }else{
            editButton.drawSelf();
            editButton.isValid = true;
            saveButton.isValid = false;
            editButton.onMouseOverMethod();
        }
        scroll.drawSelf();
    }
    
    void keyPressedMethod(){
        if(isEditing){
            for(int i=0; i<structuresButtons.size(); i++){
                if(structuresButtons.get(i).keyPressedMethod()){
                    structuresButtons.get(i).isTyping = true;
                }
            }
        }
    }
    
    void mouseDraggedMethod(){
        scroll.mouseDraggedMethod();
    }
    
    void mouseWheelMethod(float v){
        scroll.mouseWheelMethod(v);
    }
    
    void mousePressedMethod(){
        scroll.mousePressedMethod();
        if(editButton.mousePressedMethod()){
            isEditing = true;
            editButton.deactivate();
        }
        if(saveButton.mousePressedMethod()){
            isEditing = false;
            saveButton.deactivate();
            for(int i=0; i<structuresButtons.size(); i++){
                if(structuresButtons.get(i).getText().equals("")){
                    structuresButtons.get(i).setText("Structure" + randomName);
                    randomName++;
                }
            }
        }
        for(int i=0; i<structuresButtons.size(); i++){
            if(structuresButtons.get(i).mousePressedMethod())
                selectedStructure = i;
        }
        for(int i=0; i<structuresButtons.size(); i++){
            if(i != selectedStructure)
                structuresButtons.get(i).deactivate();
        }
        for(int i=0; i<delete.size(); i++){
            if(delete.get(i).mousePressedMethod()){
                delete.remove(i);
                structuresButtons.remove(i);
                scroll.decreaseMaxIndex();
                return;
            }
        }
    }
}