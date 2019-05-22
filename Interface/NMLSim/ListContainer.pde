class ListContainer{
    String label, editionField;
    float x, y, w, h;
    int maxIndex;
    boolean deleteEnabled, editEnabled, upEnabled, downEnabled;
    Scrollbar scroll;
    ArrayList<String> items;
    ArrayList<Button> delete;
    ArrayList<Button> edit;
    ArrayList<Button> up;
    ArrayList<Button> down;
    color textColor;
    
    ListContainer(String label, float x, float y, float w, float h){
        this.label = label;
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        deleteEnabled = false;
        editEnabled = false;
        upEnabled = false;
        downEnabled = false;
        editionField = "";
        items = new ArrayList<String>();
        delete = new ArrayList<Button>();
        edit = new ArrayList<Button>();
        up = new ArrayList<Button>();
        down = new ArrayList<Button>();
        maxIndex = int((h-25)/25);
        scroll = new Scrollbar(x+w-20,y,20,h,1, maxIndex,true);
        textColor = color(255,255,255);
    }
    
    boolean isIn(String element){
        return items.contains(element);
    }
    
    ArrayList <String> getItems(){
        return items;
    }
    
    void clearList(){
        items.clear();
        delete.clear();
        edit.clear();
        up.clear();
        down.clear();
        scroll.resetMaxIndex();
    }
    
    void setPositionAndSize(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        maxIndex = int((h-25)/25);
        scroll.redefine(x+w-20,y,20,h, maxIndex);
    }
    
    void addItem(String item){
        if(items.size() > 0)
            scroll.increaseMaxIndex();
        items.add(item);
        if(deleteEnabled)
            delete.add(new Button("Delete", "Deletes this item from the list", sprites.nanoDeleteIconWhite, 0, 0));
        if(editEnabled)
            edit.add(new Button("Edit", "Load this item from list to edition", sprites.nanoEditIconWhite, 0, 0));
        if(upEnabled)
            up.add(new Button("Up", "Raise this item one position in the list", sprites.nanoArrowUpIconWhite, 0, 0));
        if(downEnabled)
            down.add(new Button("Down", "Lower this item one position in the list", sprites.nanoArrowDownIconWhite, 0, 0));
    }
    
    void drawSelf(){
        textSize(fontSz);
        float auxY = y+15;
        fill(textColor);
        noStroke();
        text(label, x, y+5);
        int currIndex = scroll.getIndex();
        if(currIndex >= 0){
            for(int i=0; i<maxIndex; i++){
                if(items.size() <= i+currIndex)
                    break;
                String textAux = items.get(i+currIndex);
                float space = w - 25 -((deleteEnabled)?20:0) -((editEnabled)?20:0) -((upEnabled)?20:0) -((downEnabled)?20:0);
                while(textWidth(textAux) > space)
                    textAux = textAux.substring(0, textAux.length()-1);
                textAux += " ";
                while(textWidth(textAux) < space - 10)
                    textAux += "-";
                text(textAux, x, auxY+fontSz);
                float auxX = x+w-40;
                auxY+=2;
                if(deleteEnabled){
                    delete.get(i+currIndex).setPosition(auxX, auxY);
                    auxX -= 20;
                    delete.get(i+currIndex).drawSelf();                
                }
                if(editEnabled){
                    edit.get(i+currIndex).setPosition(auxX, auxY);
                    auxX -= 20;
                    edit.get(i+currIndex).drawSelf();                
                }
                if(downEnabled){
                    down.get(i+currIndex).setPosition(auxX, auxY);
                    auxX -= 20;
                    down.get(i+currIndex).drawSelf();                
                }
                if(upEnabled){
                    up.get(i+currIndex).setPosition(auxX, auxY);
                    auxX -= 20;
                    up.get(i+currIndex).drawSelf();                
                }
                auxY += 25;
            }
        }
        scroll.drawSelf();
    }
    
    String getEditionField(){
        return editionField;
    }
    
    boolean mousePressedMethod(){
        scroll.mousePressedMethod();
        int index;
        if(deleteEnabled){
            for(index=0; index<delete.size(); index++){
                if(delete.get(index).mousePressedMethod()){
                    break;
                }
            }
            if(index < delete.size()){
                scroll.decreaseMaxIndex();
                items.remove(index);
                delete.remove(index);
                if(editEnabled)
                    edit.remove(index);
                if(upEnabled)
                    up.remove(index);
                if(downEnabled)
                    down.remove(index);
                return true;
            }
        }
        if(editEnabled){
            for(index=0; index<edit.size(); index++){
                if(edit.get(index).mousePressedMethod())
                    break;
            }
            if(index < edit.size()){
                edit.get(index).deactivate();
                editionField = items.get(index);
                return true;
            } else{
                editionField = "";
            }
        }
        if(upEnabled){
            for(index=0; index<up.size(); index++){
                if(up.get(index).mousePressedMethod())
                    break;
            }
            if(index < up.size()){
                up.get(index).deactivate();
                if(index > 0){
                    String temp = items.get(index-1);
                    items.set(index-1, items.get(index));
                    items.set(index, temp);
                }
            }
        }
        if(downEnabled){
            for(index=0; index<down.size(); index++){
                if(down.get(index).mousePressedMethod())
                    break;
            }
            if(index < up.size()){
                down.get(index).deactivate();
                if(index < items.size()-1){
                    String temp = items.get(index+1);
                    items.set(index+1, items.get(index));
                    items.set(index, temp);
                }
            }
        }
        return false;
    }
    
    void mouseDraggedMethod(){
        scroll.mouseDraggedMethod();
    }
    
    void mouseWheelMethod(float value){
        scroll.mouseWheelMethod(value);
    }
}
