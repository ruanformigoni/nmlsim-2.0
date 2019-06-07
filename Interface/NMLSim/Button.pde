class Button{
    private String label, explanation;
    private PImage icon;
    private float x, y;
    private color labelColor, explanationColor, explanationBox, selectedBox, mouseOverColor, mouseOverExpandedColor;
    private Boolean active, expanded, isValid, isMouseOver, explanationOnRight, isTransparent;
    private HitBox hitbox;
    private int initialTime = -1;
    
    public Button(String label, String explanation, PImage icon, float x, float y){
        this.label = label;
        this.explanation = explanation;
        this.icon = icon;
        this.x = x;
        this.y = y;
        this.labelColor = color(255, 255, 255);
        this.explanationColor = color(255, 255, 255);
        this.explanationBox = color(212, 85, 0);
        this.selectedBox = color(200, 113, 55);
        this.mouseOverColor = color(83,108,83);
        this.mouseOverExpandedColor = color(45,80,22);
        this.active = false;
        explanationOnRight = true;
        isTransparent = false;
        this.expanded = false;
        this.isValid = true;
        this.isMouseOver = false;
        hitbox = new HitBox(x, y, icon.width, icon.height);
    }
    
    public void drawSelf(){
        textSize(fontSz);
        if(expanded){
            float offset = (icon.height - (textAscent()+textDescent()))/2;
            textSize(fontSz);
            fill(labelColor, (isTransparent)?128:255);
            stroke(labelColor, (isTransparent)?128:255);
            text(label, x + icon.width + 5, y + icon.height - textDescent() - offset);
        }
        if(!isValid)
            isMouseOver = false;
        if(active){
            fill(selectedBox, (isTransparent)?128:255);
            stroke(selectedBox, (isTransparent)?128:255);
            rect(x, y, icon.width, icon.height);
        } else if(isMouseOver){
            if(!expanded){
                fill(mouseOverColor, (isTransparent)?128:255);
                stroke(mouseOverColor, (isTransparent)?128:255);
            } else{
                fill(mouseOverExpandedColor, (isTransparent)?128:255);
                stroke(mouseOverExpandedColor, (isTransparent)?128:255);
            }
            rect(x, y, icon.width, icon.height);
        }

        tint((isTransparent)?128:255);
        image(icon, x, y);
        tint(255);
    }

    String getLabel(){
        return label;
    }

    public Boolean mousePressedMethod(){
    	if(!isValid || isTransparent)
            return false;
        Boolean collided = hitbox.collision(mouseX, mouseY);
        if(collided)
            active = !active;
        return collided;
    }
    
    public void onMouseOverMethod(){
        if(!isValid || isTransparent)
            return;
        if(hitbox.collision(mouseX, mouseY)){
            isMouseOver = true;
            int currTime = minute()*60*60 + second()*60 + millis();
            if(initialTime < 0)
                initialTime = currTime;
            if(currTime - initialTime > 2000){
                fill(explanationBox);
                stroke(explanationBox);
                if(explanationOnRight)
                    rect(x+icon.width, y, textWidth(explanation)+10, textAscent() + textDescent(), 5);
                else
                    rect(x-10-textWidth(explanation), y, textWidth(explanation)+10, textAscent() + textDescent(), 5);
                fill(explanationColor);
                noStroke();
                if(explanationOnRight)
                    text(explanation, x+icon.width+5, y + fontSz);
                else
                    text(explanation, x-5-textWidth(explanation), y + fontSz);
            }
        } else{
            initialTime = -1;
            isMouseOver = false;
        }
    }
    
    public void deactivate(){
        this.active = false;
    }
    
    public void setExpanded(Boolean opt){
        expanded = opt;
    }
    
    public void setPosition(float x, float y){
        this.x = x;
        this.y = y;
        hitbox.updateBox(x, y, icon.width, icon.height);
    }
    
    public float getWidth(){
        textSize(fontSz);
        if(expanded){
            return icon.width + textWidth(label) + 5;
        } else{
            return icon.width;
        }
    }
    
    public float getHeight(){
        return icon.height;
    }
}

class TextButton{
    private String label, content = "";
    private float x, y, w;
    private color labelColor, selectedColor, mouseOverColor, buttonColor;
    private Boolean isSelected, isValid, isTyping;
    private HitBox hitbox;
    
    TextButton(String label, float x, float y, float w){
        this.x = x;
        this.y = y;
        this.label = label;
        labelColor = color(255,255,255);
        selectedColor = color(212,85,0);
        mouseOverColor = color(83,108,83);
        buttonColor = color(45,80,22);
        isSelected = false;
        isValid = true;
        isTyping = false;
        textSize(fontSz);
        hitbox = new HitBox(x, y, w, textAscent()+textDescent());
    }
    
    void drawSelf(){
        textSize(fontSz);
        float h = textAscent()+textDescent();
        if(isSelected){
            fill(selectedColor);
            stroke(selectedColor);
        } else if(hitbox.collision(mouseX, mouseY)){
            fill(mouseOverColor);
            stroke(mouseOverColor);
        } else{
            fill(buttonColor);
            stroke(buttonColor);
        }
        rect(x, y, w, h, 5);
        fill(labelColor);
        noStroke();
        String aux = label;
        while(textWidth(aux) > w-10)
            if(isTyping)
                aux = aux.substring(1, aux.length());
            else
                aux = aux.substring(0, aux.length()-1);
        text(aux, x+5, y+fontSz);
    }

    public Boolean mousePressedMethod(){
        if(!isValid)
            return false;
        Boolean collided = hitbox.collision(mouseX, mouseY);
        if(collided)
            isSelected = !isSelected;
        return collided;
    }
    
    public void unselect(){
        isSelected = false;
    }
    
    String getText(){
        return label;
    }
    
    boolean keyPressedMethod(){
        if(!isValid)
            return false;
        if(isSelected){
            if(key == BACKSPACE){
                if(label.length() > 0){
                    this.label = label.substring(0, label.length()-1);
                }
            } else if (key == ENTER | key == TAB){
                unselect();
            } else if((keyCode > 64 && keyCode < 91) || (keyCode > 95 && keyCode < 106) || keyCode == 107 || keyCode == 109 || (keyCode > 43 && keyCode < 47)){
                label += key;
            }
            return true;
        }
        return false;
    }
    
    public String getButtonContent(){
        return content;
    }
    
    public void setButtonContent(String c){
        content = c;
    }

    public void deactivate(){
        this.isSelected = false;
    }
    
    public void select(){
        isSelected = true;
    }
    
    public void setPosition(float x, float y){
        this.x = x;
        this.y = y;
        textSize(fontSz);
        hitbox.updateBox(x, y, w, textAscent()+textDescent());
    }
    
    void setWidth(float w){
        this.w = w;
        textSize(fontSz);
        hitbox.updateBox(x, y, w, textAscent()+textDescent());
    }
    
    void setText(String s){
        label = s;
    }
}