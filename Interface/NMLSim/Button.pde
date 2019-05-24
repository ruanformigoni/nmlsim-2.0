class Button{
    private String label, explanation;
    private PImage icon;
    private float x, y;
    private color labelColor, explanationColor, explanationBox, selectedBox, mouseOverColor, mouseOverExpandedColor;
    private Boolean active, expanded, isValid, isMouseOver;
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
            fill(labelColor);
            stroke(labelColor);
            text(label, x + icon.width + 5, y + icon.height - textDescent() - offset);
        }
        if(!isValid)
            isMouseOver = false;
        if(active){
            fill(selectedBox);
            stroke(selectedBox);
            rect(x, y, icon.width, icon.height);
        } else if(isMouseOver){
            if(!expanded){
                fill(mouseOverColor);
                stroke(mouseOverColor);
            } else{
                fill(mouseOverExpandedColor);
                stroke(mouseOverExpandedColor);
            }
            rect(x, y, icon.width, icon.height);
        }

        image(icon, x, y);
    }

    public Boolean mousePressedMethod(){
    	if(!isValid)
            return false;
        Boolean collided = hitbox.collision(mouseX, mouseY);
        if(collided)
            active = !active;
        return collided;
    }
    
    public void onMouseOverMethod(){
        if(!isValid)
            return;
        if(hitbox.collision(mouseX, mouseY)){
            isMouseOver = true;
            int currTime = minute()*60*60 + second()*60 + millis();
            if(initialTime < 0)
                initialTime = currTime;
            if(currTime - initialTime > 2000){
                fill(explanationBox);
                stroke(explanationBox);
                rect(x+icon.width, y, textWidth(explanation)+10, textAscent() + textDescent(), 5);
                fill(explanationColor);
                noStroke();
                text(explanation, x+icon.width+5, y + fontSz);
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