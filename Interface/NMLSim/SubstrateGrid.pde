import java.util.Map;

class SubstrateGrid{
    float x, y, w, h, cellW, cellH, gridW, gridH, leftHiddenAreaW, leftHiddenAreaH, rightHiddenAreaW, rightHiddenAreaH, bulletVS, bulletHS, normalization;
    int zoomFactor, xPos, yPos, randomName = 0;
    color darkBG, lightBG, darkRuler, lightRuler, darkBullet, lightBullet;
    boolean isLightColor, isLeftHidden, isRightHidden, isRulerActive, isBulletActive;
    HitBox fullAreaHitbox, leftHidden, rightHidden;
    Scrollbar vScroll, hScroll;
    HashMap<String, Magnet> magnets;
    StructurePanel structurePanel;
    
    SubstrateGrid(float x, float y, float w, float h, float cellW, float cellH, float gridW, float gridH){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        normalization = (cellW > cellH)?cellH:cellW;
        this.cellW = cellW;
        this.cellH = cellH;
        this.gridW = gridW;
        this.gridH = gridH;
        zoomFactor = 100;
        structurePanel = null;
        
        isLightColor = true;
        darkBG = color(128,128,128);
        darkRuler = color(242,242,242);
        darkBullet = color(242,242,242);
        lightBG = color(255,255,255);
        lightRuler = color(128,128,128);
        lightBullet = color(128,128,128);
        
        fullAreaHitbox = new HitBox(x, y, w-20, h-20);
        vScroll = new Scrollbar(this.x+this.w-20, this.y, 20, this.h-20, int(this.gridH/normalization), int(this.h/((this.cellH/normalization)*this.zoomFactor/10)), true);
        vScroll.isFlipped = true;
        hScroll = new Scrollbar(this.x, this.y+this.h-20, this.w-20, 20, int(this.gridW/normalization), int(this.w/((this.cellW/normalization)*this.zoomFactor/10)), false);
        this.w -= 20;
        this.h -= 20;
        
        isLeftHidden = false;
        isRightHidden = false;
        isRulerActive = true;
        isBulletActive = true;
        
        magnets = new HashMap<String, Magnet>();
    }
    
    void setStructurePanel(StructurePanel sp){
        structurePanel = sp;
    }
    
    void setBulletSpacing(float hs, float vs){
        bulletHS = hs;
        bulletVS = vs;
    }
    
    void addMagnet(String label, String structure){
        Magnet aux =  new Magnet(structure);
        for(Magnet mag : magnets.values())
            if(aux.collision(mag))
                return;
        magnets.put(label, aux);
    }
    
    void setGridSizes(float gridW, float gridH, float cellW, float cellH){
        normalization = (cellW > cellH)?cellH:cellW;
        this.cellW = cellW;
        this.cellH = cellH;
        this.gridW = gridW;
        this.gridH = gridH;
        this.w += 20;
        this.h += 20;
        vScroll = new Scrollbar(this.x+this.w-20, this.y, 20, this.h-20, int(this.gridH/normalization), int(this.h/((this.cellH/normalization)*this.zoomFactor/10)), true);
        vScroll.isFlipped = true;
        hScroll = new Scrollbar(this.x, this.y+this.h-20, this.w-20, 20, int(this.gridW/normalization), int(this.w/((this.cellW/normalization)*this.zoomFactor/10)), false);
        this.w -= 20;
        this.h -= 20;
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
        
        float xOrigin = hScroll.getIndex()*cellW, yOrigin = vScroll.getIndex()*cellH;
        
        if(isRulerActive){
            float cont = 0;
            float cellPxW = (cellW/normalization)*zoomFactor/10;
            float auxX = x;
            float cellPxH = (cellH/normalization)*zoomFactor/10;
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
            float bulletPxW = (cellW/normalization)*zoomFactor/10;
            float auxX = -(xOrigin+bulletHS/2);
            while(auxX < 0)
                auxX += bulletHS;
            auxX = (auxX/normalization)*zoomFactor/10 + x;
            float bulletPxH = (cellH/normalization)*zoomFactor/10;
            float auxY = yOrigin+bulletVS/2;
            while(auxY > 0)
                auxY -= bulletVS;
            auxY = (auxY/normalization)*zoomFactor/10 + y + h;
            while(auxY >= y && contH <= gridH){
                while(auxX-bulletPxW <= x+w && contW <= gridW){
                    ellipseMode(CORNER);
                    ellipse(auxX-bulletPxW, auxY, bulletPxW, bulletPxH);
                    auxX += ((bulletHS/normalization)*zoomFactor/10);
                    contW  += bulletHS;
                }
                contW = bulletHS/2;
                auxX = -(xOrigin+bulletHS/2);
                while(auxX < 0)
                    auxX += bulletHS;
                auxX = (auxX/normalization)*zoomFactor/10 + x;
                auxY -= ((bulletVS/normalization)*zoomFactor/10);
                contH += bulletVS;
            }
        }

        for(Magnet mag : magnets.values()){
            mag.drawSelf(xOrigin, yOrigin, normalization, zoomFactor, x, y, w, h);
        }
        
        onMouseOverMethod();
        
        vScroll.drawSelf();
        hScroll.drawSelf();
    }
    
    void onMouseOverMethod(){
        if(!fullAreaHitbox.collision(mouseX, mouseY) || (isLeftHidden && leftHidden.collision(mouseX, mouseY)) || (isRightHidden && rightHidden.collision(mouseX, mouseY)))
            return;
        if(structurePanel != null && !structurePanel.getSelectedStructure().equals("")){
            float xOrigin = hScroll.getIndex()*cellW, yOrigin = vScroll.getIndex()*cellH;
            String structure = structurePanel.getSelectedStructure();
            String parts[] = structure.split(";");
            parts[9] = (xOrigin+((mouseX/scaleFactor-x)*10)*normalization/zoomFactor) + "," + (yOrigin-(((mouseY/scaleFactor-y-h)*10)/zoomFactor)*normalization);
            structure = "";
            for(int i=0; i<parts.length; i++){
                structure += parts[i] + ";";
            }
            Magnet magAux = new Magnet(structure);
            magAux.drawSelf(xOrigin, yOrigin, normalization, zoomFactor, x, y, w, h);
        }
    }
    
    void mousePressedMethod(){
        vScroll.mousePressedMethod();
        hScroll.mousePressedMethod();
        if(isLeftHidden && leftHidden.collision(mouseX, mouseY))
            return;
        if(isRightHidden && rightHidden.collision(mouseX, mouseY))
            return;
        if(!fullAreaHitbox.collision(mouseX, mouseY))
            return;
        if(structurePanel != null && !structurePanel.getSelectedStructure().equals("")){
            float xOrigin = hScroll.getIndex()*cellW, yOrigin = vScroll.getIndex()*cellH;
            String structure = structurePanel.getSelectedStructure();
            String parts[] = structure.split(";");
            Float newMagX = (xOrigin+((mouseX/scaleFactor-x)*10)*normalization/zoomFactor);
            Float newMagY = (yOrigin-(((mouseY/scaleFactor-y-h)*10)/zoomFactor)*normalization);
            if(newMagX < Float.parseFloat(parts[4])/2 || newMagX > gridW - Float.parseFloat(parts[4])/2)
                return;
            if(newMagY < Float.parseFloat(parts[5])/2 || newMagY > gridH - Float.parseFloat(parts[5])/2)
                return;
            parts[9] = newMagX + "," + newMagY;
            structure = "";
            for(int i=0; i<parts.length; i++){
                structure += parts[i] + ";";
            }
            Magnet mAux = new Magnet(structure);
            for(Magnet mag : magnets.values()){
                if(mAux.collision(mag))
                    return;
            }
            addMagnet("Magnet_" + randomName,structure);
            randomName++;
        }
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
            hScroll.redefine(x+leftHiddenAreaW, y+h, w-leftHiddenAreaW-rightHiddenAreaW, 20, int((w-leftHiddenAreaW-rightHiddenAreaW)/((cellW/normalization)*zoomFactor/10)));
        } else if(isLeftHidden){
            hScroll.redefine(x+leftHiddenAreaW, y+h, w-leftHiddenAreaW, 20, int((w-leftHiddenAreaW)/((cellW/normalization)*zoomFactor/10)));
        } else if(isRightHidden){
            hScroll.redefine(x, y+h, w-rightHiddenAreaW, 20, int((w-rightHiddenAreaW)/((cellW/normalization)*zoomFactor/10)));
        } else{
            hScroll.redefine(x, y+h, w, 20, int(w/((cellW/normalization)*zoomFactor/10)));
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
            vScroll.redefine(x+w, y, 20, h, int(h/((cellH/normalization)*zoomFactor/10)));
            toggleHideGrid("none");
            return;
        }
        vScroll.mouseWheelMethod(v);
        hScroll.mouseWheelMethod(v);
    }
}

class Magnet{
    float w, h, bottomCut, topCut, xMag, yMag, x, y;
    String magStr;
    color clockZone;
    
    Magnet(String magStr){
        this.magStr = magStr;
        String parts[] = magStr.split(";");
        if(parts[2].contains(",")){
            String [] aux = parts[2].split(",");
            xMag = Float.parseFloat(aux[0]);
            yMag = Float.parseFloat(aux[1]);
        } else{
            yMag = Float.parseFloat(parts[2]);
            xMag = 1-abs(yMag);
        }
        w = Float.parseFloat(parts[4]);
        h = Float.parseFloat(parts[5]);
        topCut = Float.parseFloat(parts[7]);
        bottomCut = Float.parseFloat(parts[8]);
        String [] aux = parts[9].split(",");
        x = Float.parseFloat(aux[0]);
        y = Float.parseFloat(aux[1]);
        clockZone = Integer.parseInt(parts[10]);
    }
    
    boolean collision(Magnet m){
        return (m.x-m.w/2 < x+w/2 && m.x+m.w/2 > x-w/2 && m.y-m.h/2 < y+h/2 && m.y+m.h/2 > y-h/2);
    }
    
    void drawArrow(float x0, float y0, float x1, float y1, float beginHeadSize, float endHeadSize){
        PVector d = new PVector(x1 - x0, y1 - y0);
        d.normalize();

        float coeff = 1.5;

        strokeCap(SQUARE);
        fill(0);
        stroke(0);
        
        line(x0+d.x*beginHeadSize*coeff/1.0f, 
            y0+d.y*beginHeadSize*coeff/1.0f, 
            x1-d.x*endHeadSize*coeff/1.0f, 
            y1-d.y*endHeadSize*coeff/1.0f);
  
        float angle = atan2(d.y, d.x);
  
        pushMatrix();
        translate(x0, y0);
        rotate(angle+PI);
        triangle(-beginHeadSize*coeff, -beginHeadSize, 
         -beginHeadSize*coeff, beginHeadSize, 
         0, 0);
        popMatrix();

        pushMatrix();
        translate(x1, y1);
        rotate(angle);
        triangle(-endHeadSize*coeff, -endHeadSize, 
         -endHeadSize*coeff, endHeadSize, 
         0, 0);
        popMatrix();
    }
    
    void drawSelf(float xOrigin,  float yOrigin, float normalization, float zoomFactor, float gx, float gy, float gw, float gh){
        float auxX = ((x-xOrigin)/normalization)*zoomFactor/10 + gx;
        float auxY = ((yOrigin-y)/normalization)*zoomFactor/10 + gy + gh;
        float auxW = (w/normalization)*zoomFactor/10;
        float auxH = (h/normalization)*zoomFactor/10;
        if(auxX-auxW > gx+gw || auxX+auxW < gx || auxY-auxH > gy+gh || auxY+auxH < gy)
            return;
        strokeWeight(zoomFactor/100+1);
        stroke(clockZone);
        if(xMag > abs(yMag)){
            fill(200, 200, 200);
        } else if(yMag > 0){
            fill(#FF5555);
        } else{
            fill(#80B3FF);
        }
        beginShape();
        if(topCut > 0){
            vertex((auxX-auxW/2), auxY-auxH/2);
            vertex(auxX+auxW/2, auxY-auxH/2+((topCut/normalization)*zoomFactor/10));
        } else{
            vertex(auxX-auxW/2, auxY-auxH/2-((topCut/normalization)*zoomFactor/10));
            vertex(auxX+auxW/2, auxY-auxH/2);
        }
        if(bottomCut > 0){
            vertex(auxX+auxW/2, auxY+auxH/2-((bottomCut/normalization)*zoomFactor/10));
            vertex(auxX-auxW/2, auxY+auxH/2);
        } else{
            vertex(auxX+auxW/2, auxY+auxH/2);
            vertex(auxX-auxW/2, auxY+auxH/2+((bottomCut/normalization)*zoomFactor/10));
        }
        if(topCut > 0){
            vertex(auxX-auxW/2, auxY-auxH/2);
        } else{
            vertex(auxX-auxW/2, auxY-auxH/2-((topCut/normalization)*zoomFactor/10));
        }
        endShape();
        drawArrow(
            auxX-(auxW/2)*xMag,
            auxY+(auxH/2)*yMag,
            auxX+(auxW/2)*xMag,
            auxY-(auxH/2)*yMag,
            0,zoomFactor/100*2);
        strokeWeight(1);        
    }
}
