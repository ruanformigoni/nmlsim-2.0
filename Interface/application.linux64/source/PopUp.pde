public class PopUp{
    float x, y, w, h;
    String text;
    ArrayList <TextButton> options;
    int timer, timeLimit;
    color green = color(45, 80, 22), orange = color(212, 85, 0);
    boolean isActive, fadeBackground, isTimer;
    
    public PopUp(float x, float y, float w, float h, String text){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.text = text;
        isActive = false;
        fadeBackground = true;
        options = new ArrayList<TextButton>();
        isTimer = false;
    }
    
    void activate(){
        isActive = true;
    }
    
    void deactivate(){
        isActive = false;
    }
    
    void setAsTimer(int limit){
        isTimer = true;
        timer = 0;
        timeLimit = limit;
    }
    
    void drawSelf(){
        if(timer >= timeLimit && isTimer)
            deactivate();
        timer++;
        if(isActive){
            if(fadeBackground){
                stroke(255, 255, 255, 125);
                fill(255, 255, 255, 125);
                rect(0, 0, width*scaleFactor, height*scaleFactor);
            }
            
            stroke(orange);
            fill(green);
            rect(x, y, w, h);
            
            fill(255);
            stroke(255);
            textSize(fontSz);
            int count = (options.size() > 0)?2:1;
            for(int i=0; i<text.length(); i++)
                if(text.charAt(i) == '\n')
                    count++;
            text(text, x+(w-textWidth(text))/2, y+fontSz+(h - (textAscent()+textDescent())*count)/2);
            
            count = 0;
            for(TextButton opt : options){
                opt.setWidth((w-10)/options.size());
                opt.setPosition(x+5+count*((w-10)/options.size()), y+h-textAscent()-textDescent()-5);
                count++;
                opt.drawSelf();
            }
        }
    }    
}

public class PopUpCenter{
    PopUp pop = new PopUp(0,0,0,0,"");
    
    void setPopUp(PopUp pop){
        this.pop = pop;
    }
    
    void drawSelf(){
        pop.drawSelf();
    }
    
    boolean isActive(){
        return pop.isActive;
    }    
}