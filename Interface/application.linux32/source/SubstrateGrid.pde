import java.util.Map;

class SubstrateGrid{
    float x, y, w, h, cellW, cellH, gridW, gridH, leftHiddenAreaW, leftHiddenAreaH, rightHiddenAreaW, rightHiddenAreaH, bulletVS, bulletHS, normalization, initMouseX, initMouseY;
    int zoomFactor, xPos, yPos, randomName = 0, randomGroup = 0;
    color darkBG, lightBG, darkRuler, lightRuler, darkBullet, lightBullet;
    boolean isLightColor, isLeftHidden, isRightHidden, isRulerActive, isBulletActive, isPasting = false, isMoving = false, isEditingMagnet = false, zoneViewMode = true;
    HitBox fullAreaHitbox, leftHidden, rightHidden;
    Scrollbar vScroll, hScroll;
    HashMap<String, Magnet> magnets;
    ArrayList<Magnet> selectedMagnets;
    ArrayList<String> zoneNames;
    StructurePanel structurePanel;
    ZonePanel zonePanel;
    String toPasteStructure = "";
    
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
        isRulerActive = false;
        isBulletActive = true;
        
        magnets = new HashMap<String, Magnet>();
        selectedMagnets = new ArrayList<Magnet>();
        zoneNames = new ArrayList<String>();
    }
    
    void reset(){
        zoomFactor = 10;
        magnets.clear();
        selectedMagnets.clear();
        zoneNames = null;
    }
    
    void setZonePanel(ZonePanel z){
        zonePanel = z;
    }
    
    void updateZoneNames(ArrayList<String> zoneNames){
        this.zoneNames = zoneNames;
        for(Magnet mag : magnets.values()){
            if(!zoneNames.contains(mag.getZoneName())){
                mag.changeZone("none",255);
            } else{
                mag.changeZone(mag.zone, zonePanel.getZoneColor(mag.zone));
            }
        }
    }
    
    void setStructurePanel(StructurePanel sp){
        structurePanel = sp;
    }
    
    void setBulletSpacing(float hs, float vs){
        bulletHS = hs;
        bulletVS = vs;
    }
    
    void addMagnet(String label, String structure){
        if(structure.contains(":")){
            ArrayList <Magnet> strMags = new ArrayList<Magnet>();
            String [] parts = structure.split(":");
            int index = 0;
            for(String str : parts){
                Magnet aux = new Magnet(str, label + "_" + index, zoneViewMode);
                index++;
                for(Magnet mag : magnets.values())
                    if(aux.collision(mag))
                        return;
                strMags.add(aux);
            }
            index = 0;
            for(Magnet mag : strMags){
                magnets.put(label + "_" + index, mag);
                index++;
            }
        } else{
            Magnet aux =  new Magnet(structure, label, zoneViewMode);
            for(Magnet mag : magnets.values())
                if(aux.collision(mag))
                    return;
            magnets.put(label, aux);
        }
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
    
    void deleteSelectedMagnets(){
        for(Magnet mag : selectedMagnets){
            magnets.remove(mag.name);
        }
        selectedMagnets.clear();
    }
    
    void copySelectedMagnetsToClipBoard(){
        toPasteStructure = getSelectedStructure();
    }
    
    void togglePasteState(){
        isPasting = !isPasting;
        if(toPasteStructure.equals(""))
            isPasting = false;
    }
    
    void groupSelectedMagnets(){
        for(Magnet mag : selectedMagnets){
            mag.addToGroup("RandomGroupName_"+randomGroup);
        }
        randomGroup++;
    }
    
    void linkSelectedMagnets(){
        if(selectedMagnets.size() < 2){
            unselectMagnets();
            return;
        }
        Magnet original = selectedMagnets.get(0);
        for(int i=1; i<selectedMagnets.size(); i++){
            if(!original.getMimic().equals(selectedMagnets.get(i).name) && !original.name.equals(selectedMagnets.get(i).name))
                selectedMagnets.get(i).addMimic(selectedMagnets.get(0).name);
        }
        unselectMagnets();
    }
    
    void unlinkSelectedMagnets(){
        for(Magnet mag : selectedMagnets){
            mag.removeMimic();
        }
        unselectMagnets();
    }
    
    void setMagnetMagnetization(String label, float magX, float magY){
        if(magnets.get(label) == null)
            return;
        magnets.get(label).setMagnetization(magX, magY);
    }
    
    void loadMagnetProperties(ArrayList<String> magnets){
        reset();
        for(String magnet : magnets){
            String name = magnet.substring(0, magnet.indexOf(";"));
            magnet = magnet.substring(magnet.indexOf(";")+1, magnet.length());
            addMagnet(name, magnet);
        }
    }
    
    ArrayList<String> getMagnetsProperties(){
        ArrayList<String> properties = new ArrayList<String>();
        for(Magnet mag : magnets.values()){
            properties.add(mag.name + ";" + mag.magStr);
        }
        return properties;
    }
    
    String getSelectedStructure(){
        if(selectedMagnets.size() == 0)
            return "";
        String structure = "";
        for(Magnet mag : selectedMagnets){
            structure += mag.magStr + ":";
        }
        structure = structure.substring(0, structure.length()-1);
        return structure;
    }
    
    String getSelectedMagnetsNames(){
        String names = "";
        for(Magnet mag : selectedMagnets){
            names += mag.name + " ";
        }
        if(!names.equals(""))
            names = names.substring(0,names.length()-1);
        return names;
    }
    
    void unselectMagnets(){
        for(Magnet mag : selectedMagnets){
            mag.isSelected = false;
        }
        selectedMagnets.clear();
    }
    
    void editSelectedMagnets(String newStrucutre, String oldName){
        magnets.remove(oldName);
        String name = newStrucutre.substring(0, newStrucutre.indexOf(";"));
        newStrucutre = newStrucutre.substring(newStrucutre.indexOf(";")+1, newStrucutre.length());
        addMagnet(name, newStrucutre);
    }
    
    void changeSelectedMagnetsZone(boolean isUP){
        if(zoneNames.size() == 0)
            return;
        for(Magnet mag : selectedMagnets){
            int i;
            for(i=0; i<zoneNames.size(); i++){
                if(zoneNames.get(i).equals(mag.getZoneName()))
                    break;
            }
            if(i == zoneNames.size()){
                i--;
            }
            if(isUP)
                i = (i+1)%zoneNames.size();
            else{
                i--;
                if(i < 0)
                    i = zoneNames.size()-1;
            }
            mag.changeZone(zoneNames.get(i),zonePanel.getZoneColor(zoneNames.get(i)));
        }
    }
    
    void changeSelectedMagnetsMagnetization(){
        for(Magnet mag : selectedMagnets){
            float xMag = mag.getXMag(), yMag = mag.getYMag();
            if(abs(xMag) > abs(yMag)){
                if(xMag > 0){
                    mag.setMagnetizationInStructure(0.141,-0.99);
                } else{
                    mag.setMagnetizationInStructure(0.141,0.99);
                }
            } else{
                if(yMag > 0){
                    mag.setMagnetizationInStructure(0.99,0.141);
                } else{
                    mag.setMagnetizationInStructure(-0.99,0.141);
                }
            }
        }
    }
    
    void flipSelectedMagnets(boolean isVerticalFlip){
        for(Magnet mag : selectedMagnets){
            if(isVerticalFlip){
                mag.verticalFlip();
            } else{
                mag.horizontalFlip();
            }
        }
    }
    
    void toggleZoneViewMode(){
        zoneViewMode = !zoneViewMode;
        for(Magnet mag : magnets.values()){
            mag.zoneViewMode = zoneViewMode;
        }
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
            float cont = xOrigin;
            float cellPxW = (normalization)*zoomFactor/10;
            float auxX = x;
            float cellPxH = (normalization)*zoomFactor/10;
            float auxY = y+h;
            if(isLightColor)
                stroke(lightRuler);
            else
                stroke(darkRuler);
            while(auxX < x+w && cont <= gridW){
                float temp = ((gridH-yOrigin)/cellH)*cellPxH;
                line(auxX, y+h, auxX, y+h-((temp>h)?h:temp));
                auxX += cellPxW;
                cont += cellW;
            }
            cont = yOrigin;
            while(auxY > y && cont <= gridH){
                float temp = ((gridW-xOrigin)/cellW)*cellPxW;
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

        try{
            for(Magnet mag : magnets.values()){
                mag.drawSelf(xOrigin, yOrigin, normalization, zoomFactor, x, y, w, h, cellW, cellH);
            }
            for(Magnet mag : magnets.values()){
                if(!mag.getMimic().equals("")){
                    Magnet mimicMag = magnets.get(mag.getMimic());
                    if(mimicMag == null){
                        mag.removeMimic();
                    } else{
                        float c1x = mag.getPixelCenterX(xOrigin, cellW, normalization, zoomFactor, x);
                        float c1y = mag.getPixelCenterY(yOrigin, cellH, normalization, zoomFactor, y, h);
                        float c2x = mimicMag.getPixelCenterX(xOrigin, cellW, normalization, zoomFactor, x);
                        float c2y = mimicMag.getPixelCenterY(yOrigin, cellH, normalization, zoomFactor, y, h);
                        fill(0,0,0,125);
                        stroke(0,0,0,125);
                        strokeWeight(5);
                        ellipse(c2x-5, c2y-5, 10, 10);
                        line(c2x, c2y, c1x, c1y);
                        strokeWeight(1);
                    }
                }
            }
        } catch(Exception e){
        }
        
        onMouseOverMethod();
        
        vScroll.drawSelf();
        hScroll.drawSelf();

        if(ctrlPressed && mousePressed){
            fill(255,255,255,125);
            stroke(0, 0, 0, 125);
            rect(initMouseX, initMouseY, (mouseX-initMouseX), (mouseY-initMouseY));
        }
    }
    
    void toggleMoving(){
        isMoving = !isMoving;
    }
    
    void onMouseOverMethod(){
        if(!fullAreaHitbox.collision(mouseX, mouseY) || (isLeftHidden && leftHidden.collision(mouseX, mouseY)) || (isRightHidden && rightHidden.collision(mouseX, mouseY))){
            cursor(ARROW);
            return;
        }
        
        if(isMoving && mousePressed == false)
            cursor(HAND);
        else if(isMoving && mousePressed == true)
            cursor(MOVE);
        else
            cursor(ARROW);
            
        if((structurePanel != null && !structurePanel.getSelectedStructure().equals("")) || isPasting){
            float xOrigin = hScroll.getIndex()*cellW, yOrigin = vScroll.getIndex()*cellH;
            String [] magnetsStr;
            if(isPasting){
                magnetsStr = toPasteStructure.split(":");
            }else{
                magnetsStr = structurePanel.getSelectedStructure().split(":");
            }
            float deltaX = (isBulletActive)?(int((xOrigin+(((mouseX/scaleFactor-x)*10)/normalization/zoomFactor)*cellW)/bulletHS)*bulletHS+bulletHS/2-cellH/2):(xOrigin+(((mouseX/scaleFactor-x)*10)/normalization/zoomFactor)*cellW);
            float deltaY = (isBulletActive)?(int((yOrigin-(((mouseY/scaleFactor-y-h)*10)/normalization/zoomFactor)*cellW)/bulletVS)*bulletVS+bulletVS/2-cellW/2):(yOrigin-(((mouseY/scaleFactor-y-h)*10)/normalization/zoomFactor)*cellW);
            float xRef = Float.parseFloat(magnetsStr[0].split(";")[9].split(",")[0]);
            float yRef = Float.parseFloat(magnetsStr[0].split(";")[9].split(",")[1]);
            for(String structure : magnetsStr){
                String parts[] = structure.split(";");
                
                parts[9] = "" + (Float.parseFloat(parts[9].split(",")[0])-xRef+deltaX) + "," + (Float.parseFloat(parts[9].split(",")[1])-yRef+deltaY);

                structure = "";
                for(int i=0; i<parts.length; i++){
                    structure += parts[i] + ";";
                }
                Magnet magAux = new Magnet(structure, "Magnet_Aux", zoneViewMode);
                magAux.isTransparent = true;
                magAux.drawSelf(xOrigin, yOrigin, normalization, zoomFactor, x, y, w, h, cellW, cellH);
            }
        }
    }
    
    void mousePressedMethod(){
        if(isMoving || ctrlPressed){
            initMouseX = mouseX;
            initMouseY = mouseY;
            return;
        }
        vScroll.mousePressedMethod();
        hScroll.mousePressedMethod();
        if(isLeftHidden && leftHidden.collision(mouseX, mouseY))
            return;
        if(isRightHidden && rightHidden.collision(mouseX, mouseY))
            return;
        if(!fullAreaHitbox.collision(mouseX, mouseY) || isEditingMagnet)
            return;
        if((structurePanel != null && !structurePanel.getSelectedStructure().equals("")) || isPasting){
            for(Magnet mag : selectedMagnets)
                mag.isSelected = false;
            selectedMagnets.clear();
            float xOrigin = hScroll.getIndex()*cellW, yOrigin = vScroll.getIndex()*cellH;
            String [] magnetsStr;
            if(isPasting){
                magnetsStr = toPasteStructure.split(":");
            }else{
                magnetsStr = structurePanel.getSelectedStructure().split(":");
            }
            float deltaX = (isBulletActive)?(int((xOrigin+(((mouseX/scaleFactor-x)*10)/normalization/zoomFactor)*cellW)/bulletHS)*bulletHS+bulletHS/2-cellH/2):(xOrigin+(((mouseX/scaleFactor-x)*10)/normalization/zoomFactor)*cellW);
            float deltaY = (isBulletActive)?(int((yOrigin-(((mouseY/scaleFactor-y-h)*10)/normalization/zoomFactor)*cellW)/bulletVS)*bulletVS+bulletVS/2-cellW/2):(yOrigin-(((mouseY/scaleFactor-y-h)*10)/normalization/zoomFactor)*cellW);
            float xRef = Float.parseFloat(magnetsStr[0].split(";")[9].split(",")[0]);
            float yRef = Float.parseFloat(magnetsStr[0].split(";")[9].split(",")[1]);
            String fullStr = "";
            for(String structure : magnetsStr){
                String parts[] = structure.split(";");
                float newMagX = (Float.parseFloat(parts[9].split(",")[0])-xRef+deltaX);
                float newMagY = (Float.parseFloat(parts[9].split(",")[1])-yRef+deltaY);
                if(newMagX < Float.parseFloat(parts[4])/2 || newMagX > gridW - Float.parseFloat(parts[4])/2)
                    return;
                if(newMagY < Float.parseFloat(parts[5])/2 || newMagY > gridH - Float.parseFloat(parts[5])/2)
                    return;
                parts[9] = "" + newMagX + "," + newMagY;
                structure = "";
                for(int i=0; i<parts.length; i++){
                    structure += parts[i] + ";";
                }
                fullStr += structure + ":";
            }
            fullStr = fullStr.substring(0, fullStr.length()-1);
            addMagnet("Magnet_" + randomName, fullStr);
            randomName++;
            return;
        }
        if(!shiftPressed){
            for(Magnet mag : selectedMagnets)
                mag.isSelected = false;
            selectedMagnets.clear();
        }
        for(Magnet mag : magnets.values()){
            if(mag.collision(mouseX, mouseY)){
                mag.isSelected = true;
                if(!mag.getGroup().equals("")){
                    for(Magnet otherMag : magnets.values()){
                        if(otherMag.getGroup().equals(mag.getGroup())){
                            otherMag.isSelected = true;
                            selectedMagnets.add(otherMag);
                        }
                    }
                } else{
                    selectedMagnets.add(mag);
                }
            }
        }
    }
    
    void mouseDraggedMethod(){
        vScroll.mouseDraggedMethod();
        hScroll.mouseDraggedMethod();
        if(isLeftHidden && leftHidden.collision(mouseX, mouseY))
            return;
        if(isRightHidden && rightHidden.collision(mouseX, mouseY))
            return;
        if(!fullAreaHitbox.collision(mouseX, mouseY))
            return;
        if(isMoving){
            if(mouseX < initMouseX-10){
                hScroll.incrementIndex();
            } else if(mouseX > initMouseX+10){
                hScroll.decreaseIndex();
            }
            if(mouseY > initMouseY+10){
                vScroll.incrementIndex();
            } else if(mouseY < initMouseY-10){
                vScroll.decreaseIndex();
            }
            return;
        }
        if(ctrlPressed && mousePressed){
            if(!shiftPressed)
                unselectMagnets();
            HitBox hit = new HitBox(((mouseX-initMouseX > 0)?initMouseX:mouseX), ((mouseY-initMouseY > 0)?initMouseY:mouseY), ((mouseX-initMouseX>0)?(mouseX-initMouseX):(-mouseX+initMouseX)), ((mouseY-initMouseY>0)?(mouseY-initMouseY):(-mouseY+initMouseY)));
            for(Magnet mag : magnets.values()){
                if(mag.collision(hit)){
                    mag.isSelected = true;
                    selectedMagnets.add(mag);
                }
            }
        }
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
        zoomFactor += 2;
        if(zoomFactor > 500)
            zoomFactor = 500;
        vScroll.redefine(x+w, y, 20, h, int(h/(normalization*zoomFactor/10)));
        toggleHideGrid("none");
    }
    
    void zoomOut(){
        zoomFactor -= 2;
        if(zoomFactor < 10)
            zoomFactor = 10;
        vScroll.redefine(x+w, y, 20, h, int(h/(normalization*zoomFactor/10)));
        toggleHideGrid("none");
    }

    void mouseWheelMethod(float v){
        if(isLeftHidden && leftHidden.collision(mouseX, mouseY))
            return;
        if(isRightHidden && rightHidden.collision(mouseX, mouseY))
            return;
        if(fullAreaHitbox.collision(mouseX,mouseY) && keyPressed == true && keyCode == 17){
            if(v<0){
                zoomIn();
            } else{
                zoomOut();
            }
            return;
        }
        vScroll.mouseWheelMethod(v);
        hScroll.mouseWheelMethod(v);
    }
}

class Magnet{
    float w, h, bottomCut, topCut, xMag, yMag, x, y;
    String magStr, name, groupName, zone, mimic = "";
    color clockZone;
    boolean isTransparent = false, isSelected = false, zoneViewMode = true;
    HitBox hitbox;
    
    /*MagStr = type;clockZone;magnetization;fixed;w;h;tk;tc;bc;position;zoneColor;mimic*/
    
    Magnet(String magStr, String name, boolean viewMode){
        this.magStr = magStr;
        this.zoneViewMode = viewMode;
        this.groupName = "";
        this.name = name;
        String parts[] = magStr.split(";");
        if(parts.length > 11){
            this.mimic = parts[11];
        }
        if(parts[2].contains(",")){
            String [] aux = parts[2].split(",");
            xMag = Float.parseFloat(aux[0]);
            yMag = Float.parseFloat(aux[1]);
        } else{
            yMag = Float.parseFloat(parts[2]);
            xMag = 1-abs(yMag);
        }
        zone = parts[1];
        w = Float.parseFloat(parts[4]);
        h = Float.parseFloat(parts[5]);
        topCut = Float.parseFloat(parts[7]);
        bottomCut = Float.parseFloat(parts[8]);
        String [] aux = parts[9].split(",");
        x = Float.parseFloat(aux[0]);
        y = Float.parseFloat(aux[1]);
        clockZone = Integer.parseInt(parts[10]);
        hitbox = new HitBox(0,0,0,0);
    }
    
    void editStructure(String newStructure){
        this.magStr = newStructure + ";" + mimic + ";";
        String parts[] = magStr.split(";");
        if(parts[2].contains(",")){
            String [] aux = parts[2].split(",");
            xMag = Float.parseFloat(aux[0]);
            yMag = Float.parseFloat(aux[1]);
        } else{
            yMag = Float.parseFloat(parts[2]);
            xMag = 1-abs(yMag);
        }
        zone = parts[1];
        w = Float.parseFloat(parts[4]);
        h = Float.parseFloat(parts[5]);
        topCut = Float.parseFloat(parts[7]);
        bottomCut = Float.parseFloat(parts[8]);
        String [] aux = parts[9].split(",");
        x = Float.parseFloat(aux[0]);
        y = Float.parseFloat(aux[1]);
        clockZone = Integer.parseInt(parts[10]);
    }
    
    void horizontalFlip(){
        if(topCut != 0 || bottomCut != 0){
            topCut *= -1;
            bottomCut *= -1;
            String [] parts = magStr.split(";");
            parts[7] = "" + topCut;
            parts[8] = "" + bottomCut;
            magStr = "";
            for(String part : parts){
                magStr += part + ";";
            }
        }
    }
    
    void verticalFlip(){
        if(topCut != bottomCut){
            float aux = topCut;
            topCut = bottomCut;
            bottomCut = aux;
            String [] parts = magStr.split(";");
            parts[7] = "" + topCut;
            parts[8] = "" + bottomCut;
            magStr = "";
            for(String part : parts){
                magStr += part + ";";
            }
        }
    }
    
    void addMimic(String mimicId){
        this.mimic = mimicId;
        String [] parts = magStr.split(";");
        if(parts.length > 11){
            parts[11] = mimic;
        }
        magStr = "";
        for(int i=0; i<parts.length; i++){
            magStr += parts[i] + ";";
        }
        if(parts.length <= 11){
            magStr += mimic + ";";
        }
    }
    
    void removeMimic(){
        this.mimic = "";
        String [] parts = magStr.split(";");
        if(parts.length > 11){
            parts[11] = "";
        }
        magStr = "";
        for(int i=0; i<parts.length; i++){
            magStr += parts[i] + ";";
        }
    }
    
    String getMimic(){
        return mimic;
    }
    
    String getZoneName(){
        return zone;
    }
    
    float getXMag(){
        return this.xMag;
    }
    
    float getYMag(){
        return this.yMag;
    }
    
    void setMagnetization(float xMag, float yMag){
        this.xMag = xMag;
        this.yMag = yMag;
    }
    
    void setMagnetizationInStructure(float xMag, float yMag){
        this.xMag = xMag;
        this.yMag = yMag;
        String [] parts = magStr.split(";");
        if(parts[2].contains(",")){
            parts[2] = xMag + "," + yMag + ",0";
            magStr = "";
            for(int i=0; i<parts.length; i++)
                magStr += parts[i] + ";";
        }
    }
    
    void changeZone(String zName, Integer zColor){
        String [] parts = magStr.split(";");
        parts[1] = zName;
        zone = zName;
        parts[10] = zColor.toString();
        clockZone = color(zColor);
        magStr = "";
        for(int i=0; i<parts.length; i++)
            magStr += parts[i] + ";";
    }
    
    void addToGroup(String group){
        this.groupName = group;
    }
    
    String getGroup(){
        return groupName;
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
                m.y-m.h/2+abs(m.topCut) <= y+h/2-abs(bottomCut) &&
                m.y+m.h/2-abs(m.bottomCut) >= y-h/2+abs(topCut))
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
    
    boolean collision(float px, float py){
        return hitbox.collision(px, py);
    }
    
    boolean collision(HitBox hit){
        return hitbox.collision(hit);
    }
        
    void drawArrow(float x0, float y0, float x1, float y1, float beginHeadSize, float endHeadSize){
        PVector d = new PVector(x1 - x0, y1 - y0);
        d.normalize();

        float coeff = 1.5;

        strokeCap(SQUARE);
        
        fill((zoneViewMode && !isSelected)?255:0, (isTransparent)?128:255);
        stroke((zoneViewMode && !isSelected)?255:0, (isTransparent)?128:255);
        
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

    float getPixelCenterX(float xOrigin, float cellW, float normalization, float zoomFactor, float gx){
        return (((x-xOrigin)/cellW)*normalization)*zoomFactor/10 + gx;
    }
    
    float getPixelCenterY(float yOrigin, float cellH, float normalization, float zoomFactor, float gy, float gh){
        return (((yOrigin-y)/cellH)*normalization)*zoomFactor/10 + gy + gh;
    }
    void drawSelf(float xOrigin,  float yOrigin, float normalization, float zoomFactor, float gx, float gy, float gw, float gh, float cellW, float cellH){
        float auxX = (((x-xOrigin)/cellW)*normalization)*zoomFactor/10 + gx;
        float auxY = (((yOrigin-y)/cellH)*normalization)*zoomFactor/10 + gy + gh;
        float auxW = (w/cellW*normalization)*zoomFactor/10;
        float auxH = (h/cellH*normalization)*zoomFactor/10;
        float auxTC = (topCut/cellH*normalization)*zoomFactor/10;
        float auxBC = (bottomCut/cellH*normalization)*zoomFactor/10;
        hitbox.updateBox(auxX-auxW/2,auxY-auxH/2,auxW,auxH);
        if(auxX-auxW > gx+gw || auxX+auxW < gx || auxY-auxH > gy+gh || auxY+auxH < gy)
            return;
        strokeWeight(2*zoomFactor/100+1);
        stroke(clockZone, (isTransparent)?128:255);
        if(isSelected){
            fill(255, 255, 255, 255);
        } else if(zoneViewMode){
            fill(clockZone, (isTransparent)?128:255);
        }else if(abs(xMag) > abs(yMag)){
            fill(200, 200, 200, (isTransparent)?128:255);
        } else if(yMag > 0){
            fill(#FF5555, (isTransparent)?128:255);
        } else{
            fill(#80B3FF, (isTransparent)?128:255);
        }
        beginShape();
        
        if(topCut > 0){
            vertex((auxX-auxW/2), auxY-auxH/2);
            vertex(auxX+auxW/2, auxY-auxH/2+((topCut/cellH*normalization)*zoomFactor/10));
        } else{
            vertex(auxX-auxW/2, auxY-auxH/2-((topCut/cellH*normalization)*zoomFactor/10));
            vertex(auxX+auxW/2, auxY-auxH/2);
        }
        if(bottomCut > 0){
            vertex(auxX+auxW/2, auxY+auxH/2-((bottomCut/cellH*normalization)*zoomFactor/10));
            vertex(auxX-auxW/2, auxY+auxH/2);
        } else{
            vertex(auxX+auxW/2, auxY+auxH/2);
            vertex(auxX-auxW/2, auxY+auxH/2+((bottomCut/cellH*normalization)*zoomFactor/10));
        }
        if(topCut > 0){
            vertex(auxX-auxW/2, auxY-auxH/2);
        } else{
            vertex(auxX-auxW/2, auxY-auxH/2-((topCut/cellH*normalization)*zoomFactor/10));
        }
        endShape();        
        
        drawArrow(
            auxX-(auxW/2)*xMag,
            auxY+(auxH/2-abs((yMag>0)?auxBC:auxTC))*yMag,
            auxX+(auxW/2)*xMag,
            auxY-(auxH/2-abs((yMag>0)?auxTC:auxBC))*yMag,
            0,((abs(xMag) > abs(yMag))?auxH/10:auxW/10));
        strokeWeight(1);
    }
}