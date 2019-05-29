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
        zoomFactor = 10;
        structurePanel = null;
        setGridSizes(gridW, gridH, cellW, cellH);
        
        isLightColor = true;
        darkBG = color(128,128,128);
        darkRuler = color(242,242,242);
        darkBullet = color(242,242,242);
        lightBG = color(255,255,255);
        lightRuler = color(128,128,128);
        lightBullet = color(128,128,128);
        
        fullAreaHitbox = new HitBox(x, y, w-20, h-20);
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
        normalization = ((w/(gridW/cellW)) < (h/(gridH/cellH)))?(w/(gridW/cellW)):(h/(gridH/cellH));
        this.cellW = cellW;
        this.cellH = cellH;
        this.gridW = gridW;
        this.gridH = gridH;
        this.w += 20;
        this.h += 20;
        vScroll = new Scrollbar(this.x+this.w-20, this.y, 20, this.h-20, int(this.gridH/this.cellH), int(this.h/normalization*this.zoomFactor/10), true);
        vScroll.isFlipped = true;
        hScroll = new Scrollbar(this.x, this.y+this.h-20, this.w-20, 20, int(this.gridW/this.cellW), int(this.w/normalization*this.zoomFactor/10), false);
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
            float cont = 0;//xOrigin*cellW;
            float cellPxW = (normalization)*zoomFactor/10;
            float auxX = x;
            float cellPxH = (normalization)*zoomFactor/10;
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
            cont = 0;//yOrigin*cellH;
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
            float bulletPxW = (normalization)*zoomFactor/10;
            float auxX = -(xOrigin+bulletHS/2);
            while(auxX < 0)
                auxX += bulletHS;
            auxX = auxX/cellW*(normalization)*zoomFactor/10 + x;
            float bulletPxH = (normalization)*zoomFactor/10;
            float auxY = yOrigin+bulletVS/2;
            while(auxY > 0)
                auxY -= bulletVS;
            auxY = auxY/cellH*(normalization)*zoomFactor/10 + y + h;
            while(auxY >= y && contH <= gridH){
                while(auxX-bulletPxW <= x+w && contW <= gridW){
                    ellipseMode(CORNER);
                    ellipse(auxX-bulletPxW, auxY, bulletPxW, bulletPxH);
                    auxX += (((bulletHS/cellW)*normalization)*zoomFactor/10);
                    contW  += bulletHS;
                }
                contW = bulletHS/2;
                auxX = -(xOrigin+bulletHS/2);
                while(auxX < 0)
                    auxX += bulletHS;
                auxX = auxX/cellW*(normalization)*zoomFactor/10 + x;
                auxY -= (((bulletVS/cellH)*normalization)*zoomFactor/10);
                contH += bulletVS;
            }
        }

        for(Magnet mag : magnets.values()){
            mag.drawSelf(xOrigin, yOrigin, normalization, zoomFactor, x, y, w, h, cellW, cellH);
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
            parts[9] = (xOrigin+(((mouseX/scaleFactor-x)*10)/normalization/zoomFactor)*cellW) + "," + (yOrigin-(((mouseY/scaleFactor-y-h)*10)/normalization/zoomFactor)*cellW);
            structure = "";
            for(int i=0; i<parts.length; i++){
                structure += parts[i] + ";";
            }
            Magnet magAux = new Magnet(structure);
            magAux.isTransparent = true;
            magAux.drawSelf(xOrigin, yOrigin, normalization, zoomFactor, x, y, w, h, cellW, cellH);
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
            Float newMagX = (xOrigin+(((mouseX/scaleFactor-x)*10)/normalization/zoomFactor)*cellW);
            Float newMagY = (yOrigin-(((mouseY/scaleFactor-y-h)*10)/normalization/zoomFactor)*cellW);
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
            hScroll.redefine(x+leftHiddenAreaW, y+h, w-leftHiddenAreaW-rightHiddenAreaW, 20, int(w/(normalization*zoomFactor/10)));
        } else if(isLeftHidden){
            hScroll.redefine(x+leftHiddenAreaW, y+h, w-leftHiddenAreaW, 20, int(w/(normalization*zoomFactor/10)));
        } else if(isRightHidden){
            hScroll.redefine(x, y+h, w-rightHiddenAreaW, 20, int(w/(normalization*zoomFactor/10)));
        } else{
            hScroll.redefine(x, y+h, w, 20, int(w/(normalization*zoomFactor/10)));
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
            vScroll.redefine(x+w, y, 20, h, int(h/(normalization*zoomFactor/10)));
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
    boolean isTransparent = false;
    
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
    
    float sign (float p1x, float p1y, float p2x, float p2y, float p3x, float p3y){
        return (p1x - p3x) * (p2y - p3y) - (p2x - p3x) * (p1y - p3y);
    }
    
    boolean pointInTriangle(float ptx, float pty, boolean isTopCut){
        float d1, d2, d3;
        boolean has_neg, has_pos;
    
        if(isTopCut){
            d1 = sign(ptx, pty, x-w/2, ((topCut>0)?y-h/2:y-h/2-topCut), x+w/2, ((topCut<0)?y-h/2:y-h/2+topCut));
            d2 = sign(ptx, pty, x+w/2, ((topCut<0)?y-h/2:y-h/2+topCut), ((topCut>0)?x-w/2:x+w/2), y-h/2+abs(topCut));
            d3 = sign(ptx, pty, ((topCut>0)?x-w/2:x+w/2), y-h/2+abs(topCut), x-w/2, ((topCut>0)?y-h/2:y-h/2-topCut));
        }else{
            d1 = sign(ptx, pty, x-w/2, ((bottomCut>0)?y+h/2:y+h/2+bottomCut), x+w/2, ((bottomCut<0)?y+h/2:y+h/2-bottomCut));
            d2 = sign(ptx, pty, x+w/2, ((bottomCut<0)?y+h/2:y+h/2-bottomCut), ((bottomCut>0)?x-w/2:x+w/2), y+h/2-abs(bottomCut));
            d3 = sign(ptx, pty, ((bottomCut>0)?x-w/2:x+w/2), y+h/2-abs(bottomCut), x-w/2, ((bottomCut>0)?y+h/2:y+h/2+bottomCut));
        }
    
        has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0);
        has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0);
    
        return !(has_neg && has_pos);
    }

    boolean collision(Magnet m){
        if(m.x-m.w/2 <= x+w/2 &&
                m.x+m.w/2 >= x-w/2 &&
                m.y-m.h/2+abs(m.topCut) < y+h/2-abs(bottomCut) &&
                m.y+m.h/2-abs(m.bottomCut) > y-h/2+abs(topCut))
                    return true;
        if(m.y > y){
            if(m.pointInTriangle(((topCut>0)?(x-w/2):(x+w/2)), y-h/2, false))
                return true;
        } else{
            if(m.pointInTriangle(((bottomCut>0)?(x-w/2):(x+w/2)), y+h/2, true))
                return true;
        }
        return false;
    }
    
    void drawArrow(float x0, float y0, float x1, float y1, float beginHeadSize, float endHeadSize){
        PVector d = new PVector(x1 - x0, y1 - y0);
        d.normalize();

        float coeff = 1.5;

        strokeCap(SQUARE);
        fill(0, (isTransparent)?128:255);
        stroke(0, (isTransparent)?128:255);
        
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
    
    void drawSelf(float xOrigin,  float yOrigin, float normalization, float zoomFactor, float gx, float gy, float gw, float gh, float cellW, float cellH){
        float auxX = (((x-xOrigin)/cellW)*normalization)*zoomFactor/10 + gx;
        float auxY = (((yOrigin-y)/cellH)*normalization)*zoomFactor/10 + gy + gh;
        float auxW = (w/cellW*normalization)*zoomFactor/10;
        float auxH = (h/cellH*normalization)*zoomFactor/10;
        if(auxX-auxW > gx+gw || auxX+auxW < gx || auxY-auxH > gy+gh || auxY+auxH < gy)
            return;
        strokeWeight(zoomFactor/100+1);
        stroke(clockZone, (isTransparent)?128:255);
        if(xMag > abs(yMag)){
            fill(200, 200, 200, (isTransparent)?128:255);
        } else if(yMag > 0){
            fill(#FF5555, (isTransparent)?128:255);
        } else{
            fill(#80B3FF, (isTransparent)?128:255);
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
