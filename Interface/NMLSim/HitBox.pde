class HitBox{
    private float x, y, w, h;
    
    HitBox(float xPos, float yPos, float boxWidth, float boxHeight){
        x = xPos;
        y = yPos;
        w = boxWidth;
        h = boxHeight;
    }
    
    public void updateBox(float xPos, float yPos, float boxWidth, float boxHeight){
        x = xPos;
        y = yPos;
        w = boxWidth;
        h = boxHeight;
    }
    
    public void drawSelf(){
        stroke(0, 255, 0);
        noFill();
        rect(x, y, w, h);
    }
    
    public boolean collision(float px, float py){
        return (px > x && px < (x + w) && py > y && py < (y+h));
    }
}