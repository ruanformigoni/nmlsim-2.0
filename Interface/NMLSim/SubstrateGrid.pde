class SubstrateGrid{
    float x, y, w, h, cellW, cellH, gridW, gridH, leftHiddenAreaW, leftHiddenAreaH, rightHiddenAreaW, rightHiddenAreaH, bulletVS, bulletHS, normalization;
    int zoomFactor, xPos, yPos;
    color darkBG, lightBG, darkRuler, lightRuler, darkBullet, lightBullet;
    boolean isLightColor, isLeftHidden, isRightHidden, isRulerActive, isBulletActive;
    HitBox fullAreaHitbox, leftHidden, rightHidden;
    Scrollbar vScroll, hScroll;
    
    SubstrateGrid(float x, float y, float w, float h, float cellW, float cellH, float gridW, float gridH){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        normalization = (cellW > cellH)?cellH:cellW;
        this.cellW = cellW/normalization;
        this.cellH = cellH/normalization;
        this.gridW = gridW/normalization;
        this.gridH = gridH/normalization;
        zoomFactor = 100;
        
        isLightColor = true;
        darkBG = color(128,128,128);
        darkRuler = color(242,242,242);
        darkBullet = color(242,242,242);
        lightBG = color(255,255,255);
        lightRuler = color(128,128,128);
        lightBullet = color(128,128,128);
        
        fullAreaHitbox = new HitBox(x, y, w-20, h-20);
        vScroll = new Scrollbar(this.x+this.w-20, this.y, 20, this.h-20, int(this.gridH), int(this.h/(this.cellH*this.zoomFactor/10)), true);
        vScroll.isFlipped = true;
        hScroll = new Scrollbar(this.x, this.y+this.h-20, this.w-20, 20, int(this.gridW), int(this.w/(this.cellW*this.zoomFactor/10)), false);
        this.w -= 20;
        this.h -= 20;
        
        isLeftHidden = false;
        isRightHidden = false;
        isRulerActive = true;
        isBulletActive = true;
    }
    
    void setBulletSpacing(float vs, float hs){
        bulletHS = hs/normalization;
        bulletVS = vs/normalization;
    }
    
    void toggleBullet(){
        isBulletActive = !isBulletActive;
    }
    
    void setHiddenDimensions(float lh, float lw, float rh, float rw){
        leftHiddenAreaH = lh;
        leftHiddenAreaW = lw;
        rightHiddenAreaH = rh;
        rightHiddenAreaW = rw;
        leftHidden = new HitBox(x, y+h+20-lh, lw, lh);
        rightHidden = new HitBox(x+w-rw-4, y+h+20-rh, rw+4, rh);
    }
    
    void drawSelf(){
        if(isLightColor){
            fill(lightBG);
            stroke(lightBG);
            rect(x, y, w, h);
        } else{
            fill(darkBG);
            stroke(darkBG);
            rect(x, y, w, h);
        }

        if(isRulerActive){
            float cont = 0;
            float cellPxW = cellW*zoomFactor/10;
            float auxX = x;
            float cellPxH = cellH*zoomFactor/10;
            float auxY = y+h;
            if(isLightColor)
                stroke(lightRuler);
            else
                stroke(darkRuler);
            while(auxX < x+w && cont <= gridW){
                float temp = (gridH/cellH)*cellPxH;
                line(auxX, y+h, auxX, y+h-((temp>h)?h:temp));
                auxX += cellPxW;
                cont += cellW;
            }
            cont = 0;
            while(auxY > y && cont <= gridH){
                float temp = (gridW/cellW)*cellPxW;
                line(x, auxY, x+((temp>w)?w:temp), auxY);
                auxY -= cellPxH;
                cont += cellH;
            }
        }
        
        if(isBulletActive){
            if(isLightColor){
                fill(lightBullet);
                stroke(lightBullet);
            } else{
                fill(darkBullet);
                stroke(darkBullet);
            }
            float contW = bulletHS/2, contH = bulletVS/2;
            float cellPxW = cellW*zoomFactor/10;
            float auxX = x+(bulletHS*zoomFactor/20)/* - hScroll.getIndex()*zoomFactor/10*/;
            float cellPxH = cellH*zoomFactor/10;
            float auxY = y+h-(bulletVS*zoomFactor/20);
            //while(auxX < 0)
            //    auxX += bulletHS*zoomFactor/10;
            while(auxY >= y && contH <= gridH){
                while(auxX-cellPxW <= x+w && contW <= gridW){
                    ellipseMode(CORNER);
                    ellipse(auxX-cellPxW, auxY, cellPxW, cellPxH);
                    auxX += (bulletHS*zoomFactor/10);
                    contW  += bulletHS;
                }
                contW = bulletHS/2;
                auxX = x+(bulletHS*zoomFactor/20);
                auxY -= (bulletVS*zoomFactor/10);
                contH += bulletVS;
            }
        }
        
        vScroll.drawSelf();
        hScroll.drawSelf();
    }
        
    void mousePressedMethod(){
        vScroll.mousePressedMethod();
        hScroll.mousePressedMethod();
        if(isLeftHidden && leftHidden.collision(mouseX, mouseY))
            return;
        if(isRightHidden && rightHidden.collision(mouseX, mouseY))
            return;
    }
    
    void mouseDraggedMethod(){
        vScroll.mouseDraggedMethod();
        hScroll.mouseDraggedMethod();
        if(isLeftHidden && leftHidden.collision(mouseX, mouseY))
            return;
        if(isRightHidden && rightHidden.collision(mouseX, mouseY))
            return;
    }
    
    void toggleHideGrid(String side){
        if(side.equals("left")){
            isLeftHidden = !isLeftHidden;
        } else if(side.equals("right")){
            isRightHidden = ! isRightHidden;
        }
        if(isLeftHidden & isRightHidden){
            hScroll.redefine(x+leftHiddenAreaW, y+h, w-leftHiddenAreaW-rightHiddenAreaW, 20, int((w-leftHiddenAreaW-rightHiddenAreaW)/(cellW*zoomFactor/10)));
        } else if(isLeftHidden){
            hScroll.redefine(x+leftHiddenAreaW, y+h, w-leftHiddenAreaW, 20, int((w-leftHiddenAreaW)/(cellW*zoomFactor/10)));
        } else if(isRightHidden){
            hScroll.redefine(x, y+h, w-rightHiddenAreaW, 20, int((w-rightHiddenAreaW)/(cellW*zoomFactor/10)));
        } else{
            hScroll.redefine(x, y+h, w, 20, int(w/(cellW*zoomFactor/10)));
        }
    }
    
    void zoomIn(){
        zoomFactor += 10;
        if(zoomFactor > 500)
            zoomFactor = 500;
    }
    
    void zoomOut(){
        zoomFactor -= 10;
        if(zoomFactor < 10)
            zoomFactor = 10;
    }

    void mouseWheelMethod(float v){
        if(isLeftHidden && leftHidden.collision(mouseX, mouseY))
            return;
        if(isRightHidden && rightHidden.collision(mouseX, mouseY))
            return;
        if(fullAreaHitbox.collision(mouseX,mouseY) && keyPressed == true && keyCode == 17){
            if(v<0){
                zoomFactor += 10;
                if(zoomFactor > 500)
                    zoomFactor = 500;
            } else{
                zoomFactor -= 10;
                if(zoomFactor < 10)
                    zoomFactor = 10;
            }
            vScroll.redefine(x+w, y, 20, h, int(h/(cellH*zoomFactor/10)));
            toggleHideGrid("none");
            return;
        }
        vScroll.mouseWheelMethod(v);
        hScroll.mouseWheelMethod(v);
    }
}