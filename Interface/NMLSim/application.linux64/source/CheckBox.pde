class CheckBox{
    String label;
    float x, y, w, boxSide;
    color boxColor, strokeColor, checkColor, fontColor;
    boolean isChecked, isActive;
    HitBox hitbox;
    
    public CheckBox(String label, float x, float y, float w){
        this.x = x;
        this.y = y;
        this.w = w/2;
        this.isChecked = false;
        this.label = label;
        boxColor = color(45, 80, 22);
        strokeColor = color(255, 255, 255);
        checkColor = color(212, 85, 0);
        fontColor = color(255, 255, 255);
        isActive = true;
        textSize(fontSz);
        boxSide = (textAscent()+textDescent());
        this.hitbox = new HitBox(x+w, this.y, boxSide, boxSide);
    }
    
    void drawSelf(){
        textSize(fontSz);
        fill(fontColor);
        stroke(fontColor);
        String aux = label;
        while(textWidth(aux) > w)
            aux = aux.substring(0, aux.length()-1);
        text(aux, x, y+fontSz);
        
        fill(boxColor);
        strokeWeight(3);
        stroke(strokeColor);
        rect(x+w, y, boxSide, boxSide,5);
        fill(checkColor);
        stroke(checkColor);
        if(isChecked){
            line(x + w + 5, y+5, x + w + boxSide - 5, y+boxSide-5);
            line(x + w + boxSide - 5, y+5, x + w + 5, y+boxSide-5);
        }
        strokeWeight(1);
    }
    
    void updatePosition(float x, float y){
        this.x = x;
        this.y = y;
        hitbox.updateBox(x+w,y,boxSide,boxSide);
    }
    
    boolean mousePressedMethod(){
        if(!isActive)
            return false;
        boolean collided = hitbox.collision(mouseX, mouseY);
        if(collided){
            this.isChecked = !this.isChecked;
        }
        return collided;
    }
}
