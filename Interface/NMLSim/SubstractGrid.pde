class SubstractGrid{
    float x, y, w, h, cellW, cellH, gridW, gridH;
    int zoomFactor, xPos, yPos;
    color darkBG, lightBG, darkRuler, lightRuler, darkBullet, lightBullet;
    boolean isLightColor;
    HitBox fullAreaHitbox;
    Scrollbar vScroll, hScroll;
    
    SubstractGrid(float x, float y, float w, float h, float cellW, float cellH, float gridW, float gridH){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.cellW = cellW;
        this.cellH = cellH;
        this.gridW = gridW;
        this.gridH = gridH;
        zoomFactor = 100;
        
        isLightColor = true;
        darkBG = color(128,128,128);
        darkRuler = color(242,242,242);
        darkBullet = color(242,242,242);
        lightBG = color(242,242,242);
        lightRuler = color(128,128,128);
        lightBullet = color(128,128,128);
        
        fullAreaHitbox = new HitBox(x, y, w-20, h-20);
        vScroll = new Scrollbar(x+w-20, y, 20, h, int(gridH), int(h/(cellH*zoomFactor/10)), true);
        hScroll = new Scrollbar(x, y+h-20, w-20, 20, int(gridW), int(w/(cellW*zoomFactor/10)), false);
        this.w -= 20;
        this.h -= 20;
    }
    
    void drawSelf(){
        if(isLightColor){
            fill(lightBG);
            stroke(lightBG);
            rect(x, y, w, h);
            float cont = 0;
            float cellPxW = cellW*zoomFactor/10;
            float auxX = x;
            float cellPxH = cellH*zoomFactor/10;
            float auxY = y+h;
            while(auxX < x+w && cont <= gridW){
                stroke(lightRuler);
                float temp = (gridH/cellH)*cellPxH;
                line(auxX, y+h, auxX, y+h-((temp>h)?h:temp));
                auxX += cellPxW;
                cont += cellW;
            }
            cont = 0;
            while(auxY > y && cont <= gridH){
                stroke(lightRuler);
                float temp = (gridW/cellW)*cellPxW;
                line(x, auxY, x+((temp>w)?w:temp), auxY);
                auxY -= cellPxH;
                cont += cellH;
            }
        } else{
            fill(darkBG);
            stroke(darkBG);
            rect(x, y, w, h);
        }
        vScroll.drawSelf();
        hScroll.drawSelf();
    }
    
    void mousePressedMethod(){
        vScroll.mousePressedMethod();
        hScroll.mousePressedMethod();
    }
    
    void mouseDraggedMethod(){
        vScroll.mouseDraggedMethod();
        hScroll.mouseDraggedMethod();
    }
    
    void mouseWheelMethod(float v){
        if(fullAreaHitbox.collision(mouseX,mouseY)){
            if(v<0){
                zoomFactor += 10;
                if(zoomFactor > 500)
                    zoomFactor = 500;
            } else{
                zoomFactor -= 10;
                if(zoomFactor < 10)
                    zoomFactor = 10;
            }
            vScroll = new Scrollbar(x+w, y, 20, h, int(gridH), int(h/(cellH*zoomFactor/10)), true);
            hScroll = new Scrollbar(x, y+h, w-20, 20, int(gridW), int(w/(cellW*zoomFactor/10)), false);
            return;
        }
        vScroll.mouseWheelMethod(v);
        hScroll.mouseWheelMethod(v);
    }
}
