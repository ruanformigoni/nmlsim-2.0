public class VectorTextBox{
    private boolean isActive;
    private String label;
    private ArrayList <String> texts;
    private float x, y, w;
    private color normal, selection, invalid, boxColor, fontColor, insideFontColor, editing;
    private ArrayList<HitBox> hitboxes;
    private ArrayList<Boolean> isValid;
    private String validationType;
    private int fields, selectedIndex;
    
    public VectorTextBox(String label, float xPosition, float yPosition, float boxWidth, int fields){
        this.label = label;
        this.x = xPosition;
        this.y = yPosition;
        this.w = boxWidth/2;
        this.fields = fields;
        this.isActive = true;
        this.normal = color(45,80,22);
        this.fontColor = color(255,255,255);
        this.insideFontColor = color(45,80,22);
        this.boxColor = color(255,255,255);
        this.selection = color(255,153,85);
        this.invalid = color(255,0,0);
        this.editing = color(#FFE6D5);
        this.isActive = true;
        this.selectedIndex = -1;
        texts = new ArrayList<String>();
        hitboxes = new ArrayList<HitBox>();
        isValid = new ArrayList<Boolean>();
        for(int i=0; i<fields; i++){
            texts.add("");
            isValid.add(false);
        }
        textSize(fontSz);
        for(int i=0; i<fields; i++){
            this.hitboxes.add(new HitBox(x+w+(((w-(fields-1)*5)/fields)*i + i*5), y, (w-(fields-1)*5)/fields, textAscent() + textDescent()));
        }
    }
    
    public void drawSelf(){
        textSize(fontSz);
        fill(fontColor);
        stroke(fontColor);
        String auxl = label;
        while(textWidth(auxl) > w)
            auxl = auxl.substring(0, auxl.length()-1);
        text(auxl, x, y+fontSz);
        
        for(int i=0; i<fields; i++){
            if(i == selectedIndex)
                fill(editing);
            else if(isValid.get(i))
                fill(boxColor);
            else
                fill(selection);
            if(i == selectedIndex){
                stroke(selection);
            } else if(isValid.get(i)){
                stroke(normal);
            } else{
                stroke(invalid);
            }
            float h = textAscent() + textDescent();
            rect(x+w+(((w-(fields-1)*5)/fields)*i + i*5), y, (w-(fields-1)*5)/fields, h, 5);
            
            String aux = texts.get(i);
            while(textWidth(aux) > (w-(fields-1)*5)/fields-2){
                aux = aux.substring(1, aux.length());
            }
            fill(insideFontColor);
            stroke(insideFontColor);
            text(aux, 5+x+w+(((w-(fields-1)*5)/fields)*i + i*5), y+fontSz);
        }
    }
    
    public void setLabel(String newLabel){
        this.label = newLabel;
    }
    
    public String getText(){
        String textAux = "";
        for(int i=0; i<fields; i++)
            textAux += texts.get(i) + ",";
        return textAux;
    }
    
    public void setText(String text){
        String[] textAux = text.split(",");
        for(int i=0; i<fields; i++)
            texts.set(i, textAux[i]);
        validateText();
    }
    
    public boolean mousePressedMethod(){
        if(!isActive)
            return false;
        selectedIndex = -1;
        for(int i=0; i<fields; i++){
            if(hitboxes.get(i).collision(mouseX, mouseY)){
                selectedIndex = i;
                break;
            }
        }
        if (selectedIndex == -1)
            unselect();
        return (selectedIndex != -1);
    }
    
    public boolean keyPressedMethod(){
        if(!isActive)
            return false;
        if(selectedIndex >= 0){
            if(key == BACKSPACE){
                if(texts.get(selectedIndex).length() > 0){
                    texts.set(selectedIndex, texts.get(selectedIndex).substring(0, texts.get(selectedIndex).length()-1));
                }
            } else if (key == ENTER | key == TAB){
                selectedIndex++;
                if(selectedIndex >= fields)
                    unselect();
            } else if((keyCode > 64 && keyCode < 91) || (keyCode > 95 && keyCode < 106) || keyCode == 107 || keyCode == 109 || (keyCode > 43 && keyCode < 47) || (keyCode > 47 && keyCode < 58)){
                texts.set(selectedIndex, texts.get(selectedIndex)+key);
            }
            return true;
        }
        return false;
    }
    
    public void unselect(){
        selectedIndex = -1;
        validateText();
    }
    
    public void select(){
        selectedIndex = 0;
    }
    
    public boolean isSelected(){
        return selectedIndex != -1;
    }
    
    public void resetText(){
        for(int i=0; i<fields; i++)
            this.texts.set(i, "");
    }
    
    public void setValidationType(String type){
        validationType = type;
    }
    
    public boolean validateText(){
        for(int i=0; i<fields; i++){
            if(validationType.equals("String") && texts.get(i) != "" && !texts.get(i).contains(";") && !texts.get(i).contains("$")){
                isValid.set(i, true);
            } else if(validationType.equals("Integer")){
                try{
                    Integer.parseInt(texts.get(i));
                    isValid.set(i, true);
                } catch(NumberFormatException e){
                    isValid.set(i, false);
                }
            } else if(validationType.equals("Float")){
                try{
                    Float.parseFloat(texts.get(i));
                    isValid.set(i, true);
                } catch(NumberFormatException e){
                    isValid.set(i, false);
                }
            } else if(validationType.equals("IntegerPos")){
                try{
                    int aux = Integer.parseInt(texts.get(i));
                    if(aux > 0){
                        isValid.set(i, true);
                    } else{
                        isValid.set(i, false);
                        return false;
                    }
                } catch(NumberFormatException e){
                    isValid.set(i, false);
                }
            } else if(validationType.equals("FloatPos")){
                try{
                    float aux = Float.parseFloat(texts.get(i));
                    if(aux > 0.0f){
                        isValid.set(i, true);
                    } else{
                        isValid.set(i, false);
                        return false;
                    }
                } catch(NumberFormatException e){
                    isValid.set(i, false);
                }
            } else{
                isValid.set(i, false);
            }
        }
        for(int i=0; i<isValid.size(); i++)
            if(!isValid.get(i))
                return false;
        return true;
    }
    
    public void updatePosition(float x, float y){
        this.x = x;
        this.y = y;
        textSize(fontSz);
        for(int i=0; i<fields; i++){
            this.hitboxes.get(i).updateBox(x+w+(((w-(fields-1)*5)/fields)*i + i*5), y, (w-(fields-1)*5)/fields, textAscent() + textDescent());
        }
    }
}