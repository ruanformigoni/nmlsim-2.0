class CheckBox{
    String label;
    float x, y, w, h, fontSz;
    color boxColor, strokeColor, checkColor, fontColor;
    boolean isChecked;
    HitBox hitbox;
    
    public CheckBox(String label, float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.isChecked = false;
        this.fontSz = 30;
        this.label = label;
        boxColor = color(45, 80, 22);
        strokeColor = color(255, 255, 255);
        checkColor = color(212, 85, 0);
        fontColor = color(255, 255, 255);
        textSize(fontSz);
        this.hitbox = new HitBox(this.x+textWidth(this.label) + 10, this.y, this.w, this.h);
    }
    
    void drawSelf(){
        float centerFactor = h-(textAscent()+textDescent());
        textSize(fontSz);
        fill(fontColor);
        stroke(fontColor);
        text(label, x, y+(textAscent()+textDescent())-((centerFactor > 0)?centerFactor:0));
        
        fill(boxColor);
        strokeWeight(3);
        stroke(strokeColor);
        rect(x+textWidth(label) + 10, y, w, h);
        fill(checkColor);
        stroke(checkColor);
        if(isChecked){
            line(x + textWidth(label) + 20, y+10, x + textWidth(label) + w, y+h-10);
            line(x + textWidth(label) + w, y+10, x + textWidth(label) + 20, y+h-10);
        }
        strokeWeight(1);
    }
    
    boolean mousePressedMethod(){
        boolean collided = hitbox.collision(mouseX, mouseY);
        if(collided){
            this.isChecked = !this.isChecked;
        }
        return collided;
    }
}