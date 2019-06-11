class SpriteCenter{
    public PImage copyIconWhite, openIconWhite, saveIconWhite, saveAsIconWhite, newIconWhite, lineAddWhite, editIconWhite, moveIconWhite, deleteIconWhite, pinIconWhite;
    public PImage pasteIconWhite, groupIconWhite, gridIconWhite, zoomInIconWhite, zoomOutIconWhite, bulletsIconWhite, lightIconWhite, zoneUpIconWhite, zoneDownIconWhite;
    public PImage undoIconWhite, redoIconWhite, orangeArrowUpIcon, orangeArrowDownIcon, smallSaveIconWhite, smallNewIconWhite, nanoNewIconWhite, nanoArrowDownIconWhite;
    public PImage nanoDeleteIconWhite, nanoEditIconWhite, nanoZoneUpIconWhite, nanoZoneDownIconWhite, smallDeleteIconWhite, nanoArrowUpIconWhite,smallSaveTemplateIconWhite;
    public PImage smallDefaultIconWhite, smallEditIconWhite, orangeArrowLeftIcon, orangeArrowRightIcon, cutIconWhite, forwardIconWhite, backwardIconWhite, playIconWhite;
    public PImage pauseIconWhite, stopIconWhite, chartIconWhite, simulationIconWhite, arrowUpIconWhite, arrowDownIconWhite, medSaveAsIconWhite;
    
    public SpriteCenter(){
        nanoArrowUpIconWhite = loadImage("../Sprites/arrowUpIconWhite.png");
        nanoArrowUpIconWhite.resize(15,15);
        nanoArrowDownIconWhite = loadImage("../Sprites/arrowDownIconWhite.png");
        nanoArrowDownIconWhite.resize(15,15);
        arrowUpIconWhite = loadImage("../Sprites/arrowUpIconWhite.png");
        arrowUpIconWhite.resize(25,25);
        arrowDownIconWhite = loadImage("../Sprites/arrowDownIconWhite.png");
        arrowDownIconWhite.resize(25,25);
        copyIconWhite = loadImage("../Sprites/copyIconWhite.png");
        copyIconWhite.resize(35,35);
        cutIconWhite = loadImage("../Sprites/cutIconWhite.png");
        cutIconWhite.resize(35,35);
        openIconWhite = loadImage("../Sprites/openIconWhite.png");
        openIconWhite.resize(35,35);
        saveIconWhite = loadImage("../Sprites/saveIconWhite.png");
        saveIconWhite.resize(35,35);
        smallSaveIconWhite = loadImage("../Sprites/saveIconWhite.png");
        smallSaveIconWhite.resize(20,20);
        smallSaveTemplateIconWhite = loadImage("../Sprites/saveTemplateIconWhite.png");
        smallSaveTemplateIconWhite.resize(20,20);
        saveAsIconWhite = loadImage("../Sprites/saveAsIconWhite.png");
        saveAsIconWhite.resize(35,35);
        medSaveAsIconWhite = loadImage("../Sprites/saveAsIconWhite.png");
        medSaveAsIconWhite.resize(20,20);
        newIconWhite = loadImage("../Sprites/newIconWhite.png");
        newIconWhite.resize(35,35);
        smallNewIconWhite = loadImage("../Sprites/newIconWhite.png");
        smallNewIconWhite.resize(20,20);
        nanoNewIconWhite = loadImage("../Sprites/newIconWhite.png");
        nanoNewIconWhite.resize(15,15);
        lineAddWhite = loadImage("../Sprites/lineAddWhite.png");
        lineAddWhite.resize(35,35);
        editIconWhite = loadImage("../Sprites/editIconWhite.png");
        editIconWhite.resize(35,35);
        smallEditIconWhite = loadImage("../Sprites/editIconWhite.png");
        smallEditIconWhite.resize(20,20);
        nanoEditIconWhite = loadImage("../Sprites/editIconWhite.png");
        nanoEditIconWhite.resize(15,15);
        moveIconWhite = loadImage("../Sprites/moveIconWhite.png");
        moveIconWhite.resize(35,35);
        deleteIconWhite = loadImage("../Sprites/deleteIconWhite.png");
        deleteIconWhite.resize(35,35);
        smallDeleteIconWhite = loadImage("../Sprites/deleteIconWhite.png");
        smallDeleteIconWhite.resize(20,20);
        nanoDeleteIconWhite = loadImage("../Sprites/deleteIconWhite.png");
        nanoDeleteIconWhite.resize(15,15);
        pinIconWhite = loadImage("../Sprites/pinIconWhite.png");
        pinIconWhite.resize(35,35);
        pasteIconWhite = loadImage("../Sprites/pasteIconWhite.png");
        pasteIconWhite.resize(35,35);
        groupIconWhite = loadImage("../Sprites/groupIconWhite.png");
        groupIconWhite.resize(35,35);
        gridIconWhite = loadImage("../Sprites/gridIconWhite.png");
        gridIconWhite.resize(35,35);
        zoomInIconWhite = loadImage("../Sprites/zoomInIconWhite.png");
        zoomInIconWhite.resize(35,35);
        zoomOutIconWhite = loadImage("../Sprites/zoomOutIconWhite.png");
        zoomOutIconWhite.resize(35,35);
        bulletsIconWhite = loadImage("../Sprites/bulletsIconWhite.png");
        bulletsIconWhite.resize(35,35);
        lightIconWhite = loadImage("../Sprites/lightIconWhite.png");
        lightIconWhite.resize(35,35);
        zoneUpIconWhite = loadImage("../Sprites/zoneUpIconWhite.png");
        zoneUpIconWhite.resize(35,35);
        nanoZoneUpIconWhite = loadImage("../Sprites/zoneUpIconWhite.png");
        nanoZoneUpIconWhite.resize(15,15);
        zoneDownIconWhite = loadImage("../Sprites/zoneDownIconWhite.png");
        zoneDownIconWhite.resize(35,35);
        nanoZoneDownIconWhite = loadImage("../Sprites/zoneDownIconWhite.png");
        nanoZoneDownIconWhite.resize(15,15);
        undoIconWhite = loadImage("../Sprites/undoIconWhite.png");
        undoIconWhite.resize(35,35);
        redoIconWhite = loadImage("../Sprites/redoIconWhite.png");
        redoIconWhite.resize(35,35);
        smallDefaultIconWhite = loadImage("../Sprites/defaultIconWhite.png");
        smallDefaultIconWhite.resize(20,20);
        orangeArrowDownIcon = loadImage("../Sprites/orangeArrowDownIcon.png");
        orangeArrowDownIcon.resize(10,10);
        orangeArrowUpIcon = loadImage("../Sprites/orangeArrowUpIcon.png");
        orangeArrowUpIcon.resize(10,10);
        orangeArrowLeftIcon = loadImage("../Sprites/orangeArrowLeftIcon.png");
        orangeArrowLeftIcon.resize(10,10);
        orangeArrowRightIcon = loadImage("../Sprites/orangeArrowRightIcon.png");
        orangeArrowRightIcon.resize(10,10);
        forwardIconWhite = loadImage("../Sprites/forwardIconWhite.png");
        forwardIconWhite.resize(25,25);
        backwardIconWhite = loadImage("../Sprites/backwardIconWhite.png");
        backwardIconWhite.resize(25,25);
        playIconWhite = loadImage("../Sprites/playIconWhite.png");
        playIconWhite.resize(25,25);
        pauseIconWhite = loadImage("../Sprites/pauseIconWhite.png");
        pauseIconWhite.resize(25,25);
        stopIconWhite = loadImage("../Sprites/stopIconWhite.png");
        stopIconWhite.resize(25,25);
        simulationIconWhite = loadImage("../Sprites/simulationIconWhite.png");
        simulationIconWhite.resize(25,25);
        chartIconWhite = loadImage("../Sprites/chartIconWhite.png");
        chartIconWhite.resize(25,25);
    }
}