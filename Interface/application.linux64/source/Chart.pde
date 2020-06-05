class Chart{
    float x, y, w, h;
    ArrayList<float[][]> series;
    ArrayList<Integer> colors;
    ArrayList<String> labels;
    color background, axis, text, popUpColor;
    HitBox hitbox;
    
    Chart(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        background = color(200,200,200);
        text = color(0,0,0);
        axis = color(0,0,0);
        popUpColor = color(212,85,0);
        series = new ArrayList<float[][]>();
        colors = new ArrayList<Integer>();
        labels = new ArrayList<String>();
        hitbox = new HitBox(x, y, w, h);
    }
    
    void rescale(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        hitbox.updateBox(x, y, w, h);
    }
    
    void addSeires(String label, float[][] data, Integer seriesColor){
        series.add(data);
        colors.add(seriesColor);
        labels.add(label);
    }
    
    Float getLowerValue(){
        Float lower = null;
        for(int s=0; s<series.size(); s++){
            float[][] aux = series.get(s);
            for(int i=0; i<aux.length; i++){
                if(lower == null){
                    lower = aux[i][1];
                } else if(aux[i][1] < lower){
                    lower = aux[i][1];
                }
            }
        }
        if(lower != null && lower>0)
            lower = 0.0;
        return lower;
    }
    
    Float getHigherValue(){
        Float higher = null;
        for(int s=0; s<series.size(); s++){
            float[][] aux = series.get(s);
            for(int i=0; i<aux.length; i++){
                if(higher == null){
                    higher = aux[i][1];
                } else if(aux[i][1] > higher){
                    higher = aux[i][1];
                }
            }
        }
        if(higher != null && higher<=0)
            higher = 1.0;
        return higher;
    }
    
    Float getHigherX(){
        Float higher = null;
        for(int s=0; s<series.size(); s++){
            float[][] aux = series.get(s);
            for(int i=0; i<aux.length; i++){
                if(higher == null){
                    higher = aux[i][0];
                } else if(aux[i][0] > higher){
                    higher = aux[i][0];
                }
            }
        }
        return higher;
    }
    
    float getPixel(float value){
        float delta = -(h-15)/(getHigherValue() - getLowerValue());
        return (value-getLowerValue())*delta + h + y - 10;
    }
    
    void drawSerie(float[][]data){
        float delta = (w-15)/getHigherX();
        for(int i=0; i<data.length-1; i++){
            line(data[i][0]*delta+x+10, getPixel(data[i][1]), data[i+1][0]*delta+x+10, getPixel(data[i+1][1]));
        }
    }
    
    void drawSelf(){
        fill(background);
        stroke(background);
        rect(x, y, w, h, 5);
        if(series.size() == 0)
            return;
        stroke(axis);
        strokeWeight(3);
        line(x+10, y+5, x+10, y+h-10);
        line(x+10, getPixel(0), x+w-5, getPixel(0));

        for(int i=0; i<series.size(); i++){
            stroke(colors.get(i));
            drawSerie(series.get(i));
        }
        strokeWeight(1);
        onMouseOver();
    }
    
    void onMouseOver(){
        if(!hitbox.collision(mouseX,mouseY))
            return;
        textSize(fontSz);
        float w = 0, h;
        for(int i=0; i<labels.size(); i++)
            if(textWidth(labels.get(i)) > w)
                w = textWidth(labels.get(i));
        w += 30;
        h = labels.size()*(textAscent() + textDescent() + 5) + 5;
        fill(popUpColor);
        stroke(popUpColor);
        rect(x+this.w, y, w, h, 5);
        float auxY = y + 5;
        for(int i=0; i<labels.size(); i++){
            fill(colors.get(i));
            stroke(255, 255, 255);
            rect(x+this.w+5, auxY+2, 15, 15, 5);
            fill(255,255,255);
            noStroke();
            text(labels.get(i), x+this.w+25, auxY+fontSz);
            auxY += textAscent() + textDescent() + 5;
        }
    }
}
