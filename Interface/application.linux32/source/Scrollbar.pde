class Scrollbar{
    float x, y, w, h, mx, my;
    boolean isVertical, isDragging, isFlipped;
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
        this.isFlipped = false;
        fullScroll = new HitBox(x, y, w, h);
        if(isVertical){
            auicon = sprites.orangeArrowUpIcon;
            adicon = sprites.orangeArrowDownIcon;
            minusArrow = new HitBox(x+(w-10)/2-5, y, 20, 20);
            plusArrow = new HitBox(x+(w-10)/2-5, y+h-20, 20, 20);
            float barH = ((h-40)/maxIndex)*foldSize;
            barH = (barH > h-40)?h-40:barH;
            float barPos = y+20+((h-40)/maxIndex)*index;
            bar = new HitBox(x, barPos, w, h);
        } else{
            auicon = sprites.orangeArrowLeftIcon;
            adicon = sprites.orangeArrowRightIcon;
            minusArrow = new HitBox(x, y, 20, 20);
            plusArrow = new HitBox(x+w-20, y, 20, 20);
            float barW = ((w-40)/maxIndex)*foldSize;
            barW = (barW > w-40)?w-40:barW;
            float barPos = x+20+((w-40)/maxIndex)*index;
            bar = new HitBox(barPos, y, w, h);
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
        } else{
            minusArrow = new HitBox(x, y, 20, 20);
            plusArrow = new HitBox(x+w-20, y, 20, 20);
        }
        index = (index>maxIndex-foldSize)?maxIndex-foldSize:index;
        index = (index<0)?0:index;
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
    
    void resetMaxIndex(){
        index = 0;
        maxIndex = 1;
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
            if(!isFlipped)
                rect(x, barPos, w, barH, 15);
            else
                rect(x, y+h-(barPos-y)-barH, w, barH, 15);
            if(!isFlipped)
                bar.updateBox(x, barPos, w, barH);
            else
                bar.updateBox(x, y+h-(barPos-y)-barH, w, barH);
        } else{
            image(auicon,x+5, y+(h-10)/2);
            image(adicon,x+w-15, y+(h-10)/2);
            float barW = ((w-40)/maxIndex)*foldSize;
            barW = (barW > w-40)?w-40:barW;
            float barPos = x+20+((w-40)/maxIndex)*index;
            if(!isFlipped)
                rect(barPos, y, barW, h, 15);
            else
                rect(x+w-(barPos-x)-barW, y, barW, h, 15);
            if(!isFlipped)
                bar.updateBox(barPos, y, barW, h);
            else
                bar.updateBox(x+w-(barPos-x)-barW, y, barW, h);
        }        
    }
    
    int getIndex(){
        return index;
    }
    
    void mousePressedMethod(){
        if(plusArrow.collision(mouseX, mouseY)){
            if(!isFlipped)
                incrementIndex();
            else
                decreaseIndex();
        }
        else if(minusArrow.collision(mouseX, mouseY)){
            if(!isFlipped)
                decreaseIndex();
            else
                incrementIndex();
        }
        else if(bar.collision(mouseX, mouseY))
            isDragging = true;
    }
    
    boolean mouseDraggedMethod(){
        if(isDragging){
            if(!fullScroll.collision(mouseX, mouseY)){
                isDragging = false;
                return false;
            }
            if(isVertical){
                if(!isFlipped)
                    index = int((mouseY/scaleFactor - y - 20)/((h-40)/maxIndex));
                else
                    index = maxIndex - int((mouseY/scaleFactor - y - 20)/((h-40)/maxIndex));
            } else{
                if(!isFlipped)
                    index = int((mouseX/scaleFactor - x - 20)/((w-40)/maxIndex));
                else
                    index = maxIndex - int((mouseX/scaleFactor - x - 20)/((w-40)/maxIndex));
            }
            if(index>maxIndex-foldSize){
                index = maxIndex-foldSize;
                if(index < 0)
                    index = 0;
            }
            else if (index < 0)
                index = 0;
            return true;
        }
        return false;
    }
    
    boolean mouseWheelMethod(float value){
        if(fullScroll.collision(mouseX, mouseY)){
            if(value > 0){
                if(!isFlipped){
                    incrementIndex();
                } else{
                    decreaseIndex();
                }
            } else{
                if(!isFlipped){
                    decreaseIndex();
                } else{
                    incrementIndex();
                }
            }
            return true;
        }
        return false;
    }
}