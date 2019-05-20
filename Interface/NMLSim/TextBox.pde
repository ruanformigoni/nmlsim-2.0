public class TextBox{
    private boolean isSelected, isValidated;
    private String label, text;
    private float x, y, w, fontSz;
    private color normal, selection, invalid, boxColor, fontColor, insideFontColor, editing;
    private HitBox hitbox;
    private String validationType;
    
    public TextBox(String label, float xPosition, float yPosition, float boxWidth, float fontSize){
        this.label = label;
        this.x = xPosition;
        this.y = yPosition;
        this.w = boxWidth/2;
        this.normal = color(45,80,22);
        this.fontColor = color(255,255,255);
        this.insideFontColor = color(45,80,22);
        this.boxColor = color(255,255,255);
        this.selection = color(255,153,85);
        this.invalid = color(255,0,0);
        this.editing = color(#FFE6D5);
        this.isValidated = false;
        this.isSelected = false;
        this.fontSz = fontSize;
        this.text = "";
        textSize(fontSz);
        this.hitbox = new HitBox(x+w, y, w, textAscent() + textDescent());
    }

    public TextBox(String label, float xPosition, float yPosition, float boxWidth){
        this.label = label;
        this.x = xPosition;
        this.y = yPosition;
        this.w = boxWidth;
        this.normal = color(45,80,22);
        this.fontColor = color(255,255,255);
        this.insideFontColor = color(45,80,22);
        this.boxColor = color(255,255,255);
        this.selection = color(255,153,85);
        this.invalid = color(255,0,0);
        this.isValidated = false;
        this.isSelected = false;
        this.fontSz = 30;
        this.text = "";
        textSize(this.fontSz);
        this.hitbox = new HitBox(x+w, y, w, textAscent() + textDescent());
    }
    
    public void drawSelf(){
        textSize(fontSz);
        fill(fontColor);
        stroke(fontColor);
        String auxl = label;
        while(textWidth(auxl) > w)
            auxl = auxl.substring(0, auxl.length()-1);
        text(auxl, x, y+fontSz);
        
        if(isSelected)
            fill(editing);
        else if(isValidated)
            fill(boxColor);
        else
            fill(selection);
        if(isSelected){
            stroke(selection);
        } else if(isValidated){
            stroke(normal);
        } else{
            stroke(invalid);
        }
        float h = textAscent() + textDescent();
        rect(x+w, y, w, h);
        
        String aux = text;
        while(textWidth(aux) > w){
            aux = aux.substring(1, aux.length());
        }
        fill(insideFontColor);
        stroke(insideFontColor);
        text(aux, x+w+5, y+fontSz);        
    }
    
    public void setLabel(String newLabel){
        this.label = newLabel;
    }
    
    public String getText(){
        return text;
    }
    
    public void setText(String text){
        this.text = text;
        validateText();
    }
    
    public void setFontSize(float fontSize){
        this.fontSz = fontSize;
    }
    
    public boolean mousePressedMethod(){
        boolean collided = hitbox.collision(mouseX, mouseY);
        isSelected = collided;
        if (!collided)
            unselect();
        return collided;
    }
    
    public void setPosition(float x, float y){
        this.x = x;
        this.y = y;
        textSize(fontSz);
        this.hitbox.updateBox(x+w, y, w, textAscent() + textDescent());
    }
    
    public boolean keyPressedMethod(){
        if(isSelected){
            if(key == BACKSPACE){
                if(text.length() > 0){
                    this.text = text.substring(0, text.length()-1);
                }
            } else if (key == ENTER | key == TAB){
                unselect();
            } else {
                text += key;
            }
            return true;
        }
        return false;
    }
    
    public boolean isSelected(){
        return isSelected;
    }
    
    public boolean isValid(){
        return isValidated;
    }
    
    public void unselect(){
        isSelected = false;
        validateText();
    }
    
    public void select(){
        isSelected = true;
    }
    
    public void setInvalid(){
        this.isValidated = false;
    }
    
    public void setValid(){
        this.isValidated = true;
    }
    
    public void resetText(){
        this.text = "";
    }
    
    public void setValidationType(String type){
        validationType = type;
    }
    
    public void validateText(){
        if(validationType.equals("String") & text != "")
            setValid();
        else if(validationType.equals("Integer")){
            try{
                Integer.parseInt(text);
                setValid();
            } catch(NumberFormatException e){
                resetText();
                setInvalid();
            }
        } else if(validationType.equals("Float")){
            try{
                Float.parseFloat(text);
                setValid();
            } catch(NumberFormatException e){
                resetText();
                setInvalid();
            }
        }
    }
    
    public void updatePosition(float x, float y){
        this.x = x;
        this.y = y;
        textSize(fontSz);
        hitbox.updateBox(x+w, y, w, textAscent() + textDescent());
    }
}