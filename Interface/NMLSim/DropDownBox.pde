public class DropDownBox{
    private String label;
    private ArrayList<String> options;
    private float x, y, w;
    private int selectedOpt = -1;
    private boolean isSelected, isDropping, isActive;
    private color fontColor, insideFontColor, boxColor, normal, selected, invalid;
    private HitBox boxhit, arrowhit;
    private ArrayList<HitBox> optionshit;
    
    public DropDownBox(String label, float xPosition, float yPosition, float boxWidth){
        this.label = label;
        this.x = xPosition;
        this.y = yPosition;
        this.w = boxWidth/2;
        this.isActive = true;
        this.options = new ArrayList<String>();
        this.isSelected = false;
        this.isDropping = false;
        this.fontColor = color(255,255,255);
        this.boxColor = color(255,255,255);
        this.normal = color(45,80,22);
        this.selected = color(255,153,85);
        this.invalid = color(255,0,0);
        this.insideFontColor = color(45,80,22);
        textSize(fontSz);
        boxhit = new HitBox(x+w, y, w, textAscent()+textDescent());
        arrowhit = new HitBox(x + 2*w - fontSz, y, fontSz, textAscent()+textDescent());
        optionshit = new ArrayList<HitBox>();
    }
    
    public void drawSelf(){
        textSize(fontSz);
        float h = textAscent() + textDescent();
        fill(fontColor);
        stroke(fontColor);
        String auxl = label;
        while(textWidth(auxl) > w)
            auxl = auxl.substring(0, auxl.length()-1);
        text(auxl, x, y + fontSz);
        
        fill(boxColor);
        if(isSelected)
            stroke(selected);
        else if(selectedOpt >= 0)
            stroke(normal);
        else
            stroke(invalid);

        if(isDropping){
            rect(x+w, y, w, (options.size()+1)*(h+5)-5, 5);
        } else{
            rect(x+w, y, w, h, 5);
        }

        fill(insideFontColor);
        stroke(insideFontColor);
        if(selectedOpt >= 0){
            String aux = options.get(selectedOpt);
            while(textWidth(aux) > (w-fontSz-5))
                aux = aux.substring(0, aux.length()-1);
            text(aux, x+5+w, y+fontSz);
        }
        
        fill(normal);
        if(isDropping)
            triangle(x + 2*w - (h-5), y+h-5, x + 2*w - 5, y+h-5, x + 2*w - (h)/2, y+5);
        else
            triangle(x + 2*w - (h-5), y+5, x + 2*w - 5, y+5, x + 2*w - (h)/2, y+h-5);
            
        fill(insideFontColor);
        if(isDropping){
            line(x+w+5, y+h+5, x+2*w-5, y+h+5);
            for(int i=0; i<options.size(); i++){
                String aux = options.get(i);
                while(textWidth(aux) > w-5)
                    aux = aux.substring(0, aux.length()-1);
                text(aux, x+5+w, y+(i+1)*(h)+fontSz+5);
                optionshit.get(i).updateBox(x+w, y+(i+1)*(h)+5, w, h);
            }
        }
    }
    
    public void addOption(String opt){
        options.add(opt);
        optionshit.add(new HitBox(0,0,0,0));
    }
    
    public void removeOption(int index){
        options.remove(index);
        optionshit.remove(index);
    }
    
    public void removeAllOptions(){
        options.clear();
        optionshit.clear();
        resetOption();
    }
    
    public boolean mousePressedMethod(){
        if(!isActive)
            return false;
        isSelected = boxhit.collision(mouseX, mouseY);
        if(isDropping){
            for(int i=0; i<options.size(); i++)
                if(optionshit.get(i).collision(mouseX, mouseY)){
                    selectedOpt = i;
                    isDropping = false;
                }
        }
        isDropping = arrowhit.collision(mouseX, mouseY) & !isDropping;
        return isSelected;
    }
    
    public void setLabel(String newLabel){
        this.label = newLabel;
    }
    
    public String getSelectedOption(){
        if(selectedOpt < 0)
            return "";
        else
            return options.get(selectedOpt);
    }
    
    public void resetOption(){
        this.selectedOpt = -1;
    }    
    
    public void updatePosition(float x, float y){
        this.x = x;
        this.y = y;
        boxhit.updateBox(x, y, w, textAscent()+textDescent());
        arrowhit = new HitBox(x + 2*w - fontSz, y, fontSz, textAscent()+textDescent());
    }
}