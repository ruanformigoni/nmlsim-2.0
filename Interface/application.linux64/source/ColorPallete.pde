class ColorPallete{
    float x, y, w, h;
    color selectedColor, strokeColor, palleteColor;
    color[] colors;
    HitBox hitbox;
    ArrayList<HitBox> colorsBoxes;
    boolean isSelecting = false;
    
    ColorPallete(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        hitbox = new HitBox(x, y, w, h);
        colorsBoxes = new ArrayList<HitBox>();
        strokeColor = color(255,255,255);
        palleteColor = color(212,85,0);
        colors = new color[]{#008000,#000080,#FFFF00,#5500D4,#502D16,#1ECFD4,#00FF00,#000000,#FF8A00};
        for(int i=0; i<colors.length; i++)
            colorsBoxes.add(new HitBox(x, y, w, h));
        selectedColor = colors[int(random(colors.length))];
    }
    
    void drawSelf(){
        stroke(strokeColor);
        fill(selectedColor);
        rect(x, y, w, h, 5);
        if(isSelecting){
            float maxH = ceil(colors.length/3.0f)*(h+5)+5;
            float maxW = 3*(w+5)+5;
            fill(palleteColor);
            rect(x+w/2-maxW/2, y+h/2-maxH/2, maxW, maxH, 5);
            float auxY = y+h/2-maxH/2 + 5, auxX;
            for(int i=0; i<colors.length; i+=3){
                auxX = x+w/2-maxW/2+5;
                fill(colors[i]);
                rect(auxX, auxY, w, h, 5);
                colorsBoxes.get(i).updateBox(auxX, auxY, w, h);
                auxX += w+5;
                if(i+1 < colors.length){
                    fill(colors[i+1]);
                    rect(auxX, auxY, w, h, 5);
                    colorsBoxes.get(i+1).updateBox(auxX, auxY, w, h);
                    auxX += w+5;
                }
                if(i+2 < colors.length){
                    fill(colors[i+2]);
                    rect(auxX, auxY, w, h, 5);
                    colorsBoxes.get(i+2).updateBox(auxX, auxY, w, h);
                }
                auxY += h+5;
            }
        }
    }
    
    boolean mousePressedMethod(){
        boolean hit = false;
        if(isSelecting){
            int index;
            for(index=0; index<colorsBoxes.size(); index++)
                if(colorsBoxes.get(index).collision(mouseX, mouseY))
                    break;
            if(index < colorsBoxes.size()){
                this.selectedColor = colors[index];
                isSelecting = false;
                hit = true;
            }
        } else{
            hit = hitbox.collision(mouseX, mouseY);
            if(hit){
                isSelecting = true;
            }
        }
        return hit;
    }
    
    void updatePosition(float x, float y){
        this.x = x;
        this.y = y;
        hitbox.updateBox(x,y,w,h);
    }
    
    void resetColor(){
        selectedColor = colors[int(random(colors.length))];
    }
    
    Integer getColor(){
        return selectedColor;
    }
    
    void setColor(Integer myColor){
        selectedColor = myColor;
    }
}
