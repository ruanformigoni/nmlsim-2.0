class HitBox{
    private float x, y, w, h;
    
    HitBox(float xPos, float yPos, float boxWidth, float boxHeight){
        x = xPos*scaleFactor;
        y = yPos*scaleFactor;
        w = boxWidth*scaleFactor;
        h = boxHeight*scaleFactor;
    }
    
    public void updateBox(float xPos, float yPos, float boxWidth, float boxHeight){
        x = xPos*scaleFactor;
        y = yPos*scaleFactor;
        w = boxWidth*scaleFactor;
        h = boxHeight*scaleFactor;
    }
    
    public void drawSelf(){
        stroke(255, 0, 0);
        noFill();
        rect(x/scaleFactor, y/scaleFactor, w/scaleFactor, h/scaleFactor);
    }
    
    public boolean collision(float px, float py){
        return (px > x && px < (x + w) && py > y && py < (y+h));
    }
    
    public boolean collision(HitBox other){
        return (other.x+other.w > x && other.x < (x + w) && other.y+other.h > y && other.y < (y+h));
    }
}