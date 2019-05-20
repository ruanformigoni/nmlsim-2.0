SpriteCenter sprites;
Header h;
SimulationPanel gp;

void setup(){
    size(1280, 720);
    sprites = new SpriteCenter();
    h = new Header(0, 0, 1280);
    gp = new SimulationPanel(0, 200, 300, 500);
}

void draw(){
    //background(45,80,22);
    background(200,200,200);
    h.drawSelf();
    gp.drawSelf();
}

void mousePressed(){
    h.mousePressedMethod();
    gp.mousePressedMethod();
}

void keyPressed(){
    gp.keyPressedMethod();
}