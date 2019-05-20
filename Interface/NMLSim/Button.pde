class Button{
    private String label, explanation;
    private PImage icon;
    private float x, y, fontSz;
    private color labelColor, explanationColor, explanationBox, selectedBox;
    private Boolean active, expanded;
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
        this.active = false;
        this.expanded = false;
        this.fontSz = 15;
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
        if(active){
            fill(selectedBox);
            stroke(selectedBox);
            rect(x, y, icon.width, icon.height);
        }
        image(icon, x, y);
    }

    public Boolean mousePressedMethod(){
    	Boolean collided = hitbox.collision(mouseX, mouseY);
        if(collided)
            active = !active;
        return collided;
    }
    
    public void onMouseOverMethod(){
        if(hitbox.collision(mouseX, mouseY)){
            int currTime = minute()*60*60 + second()*60 + millis();
            if(initialTime < 0)
                initialTime = currTime;
            if(currTime - initialTime > 2000){
                fill(explanationBox);
                stroke(explanationBox);
                rect(mouseX + 20, mouseY, textWidth(explanation), textAscent() + textDescent());
                fill(explanationColor);
                noStroke();
                text(explanation, mouseX + 20, mouseY + fontSz);
            }
        } else{
            initialTime = -1;
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