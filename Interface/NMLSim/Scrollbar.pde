class Scrollbar{
    float x, y, w, h, mx, my;
    boolean isVertical, isDragging;
    color buttons, trail;
    int maxIndex, index, foldSize;
    HitBox plusArrow, minusArrow, bar, fullScroll;
    PImage auicon, adicon;
    
    Scrollbar(float x, float y, float w, float h, int maxIndex, int foldSize, boolean isVertical){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.maxIndex = maxIndex;
        this.foldSize = foldSize;
        buttons = color(255,153,85);
        trail = color(212,85,0);
        index = 0;
        this.isVertical = isVertical;
        this.isDragging = false;
        auicon = sprites.orangeArrowUpIcon;
        adicon = sprites.orangeArrowDownIcon;
        fullScroll = new HitBox(x, y, w, h);
        if(isVertical){
            minusArrow = new HitBox(x+(w-10)/2-5, y, 20, 20);
            plusArrow = new HitBox(x+(w-10)/2-5, y+h-20, 20, 20);
            float barH = ((h-40)/maxIndex)*foldSize;
            barH = (barH > h-40)?h-40:barH;
            float barPos = y+20+((h-40)/maxIndex)*index;
            bar = new HitBox(x, barPos, w, h);
        }
    }
    
    void redefine(float x, float y, float w, float h, int foldSz){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        foldSize = foldSz;
        fullScroll.updateBox(x, y, w, h);
        if(isVertical){
            minusArrow.updateBox(x+(w-10)/2-5, y, 20, 20);
            plusArrow.updateBox(x+(w-10)/2-5, y+h-20, 20, 20);
        }
    }
    
    void increaseMaxIndex(){
        this.maxIndex++;
    }
    
    void decreaseMaxIndex(){
        maxIndex--;
        if(maxIndex < 1)
            maxIndex = 1;
        index = (index>maxIndex-foldSize)?maxIndex-foldSize:index;
        index = (index<0)?0:index;
    }
    
    void incrementIndex(){
        index++;
        index = (index>maxIndex-foldSize)?maxIndex-foldSize:index;
        index = (index<0)?0:index;
    }
    
    void decreaseIndex(){
        index--;
        index = (index<0)?0:index;
    }
    
    void drawSelf(){
        fill(trail);
        stroke(trail);
        rect(x, y, w, h, 15);
                
        fill(buttons);
        stroke(buttons);
        if(isVertical){
            image(auicon,x+(w-auicon.width)/2, y+5);
            image(adicon,x+(w-auicon.width)/2, y+h-15);
            float barH = ((h-40)/maxIndex)*foldSize;
            barH = (barH > h-40)?h-40:barH;
            float barPos = y+20+((h-40)/maxIndex)*index;
            rect(x, barPos, w, barH, 15);
            bar.updateBox(x, barPos, w, barH);
        } else{
            image(auicon,x+5, y+(h-10)/2);
            image(adicon,x+w-5, y+(h-10)/2);
        }
    }
    
    int getIndex(){
        return index;
    }
    
    void mousePressedMethod(){
        if(plusArrow.collision(mouseX, mouseY))
            incrementIndex();
        else if(minusArrow.collision(mouseX, mouseY))
            decreaseIndex();
        else if(bar.collision(mouseX, mouseY))
            isDragging = true;
    }
    
    boolean mouseDraggedMethod(){
        if(isDragging){
            if(!fullScroll.collision(mouseX, mouseY)){
                isDragging = false;
                return false;
            }
            index = int((mouseY - y - 20)/((h-40)/maxIndex));
            if(index>maxIndex-foldSize)
                index = maxIndex-foldSize;
            else if (index < 0)
                index = 0;
            return true;
        }
        return false;
    }
    
    boolean mouseWheelMethod(float value){
        if(fullScroll.collision(mouseX, mouseY)){
            if(value > 0)
                incrementIndex();
            else
                decreaseIndex();
            return true;
        }
        return false;
    }
}