import ddf.minim.*;
import ddf.minim.ugens.*;

// Konstanter för att definiera material i vår grotta

final int EMPTY = 0;
final int GRAVEL = 1;
final int WALL = 2;
final int BOULDER = 3;
final int PLAYER = 4;
final int OUTSIDE = 5;
final int DIAMOND = 6;
final int DOOR = 7;

// Vår spelklass

class Game extends Map {
    
    // Bilder som vi använder för uppritning

    PImage gravelImage;
    PImage emptyImage;
    PImage wallImage;
    PImage boulderImage;
    PImage playerImage;
    PImage playerTileImage;
    PImage diamondImage;
    PImage doorImage;
    PImage closedDoorImage;
    PImage openDoorImage;
    PImage diamondTiles;
    
    // Antal stenar i grottan
    
    int nBoulders;
    
    // Antal tomrum
    
    int nEmpty;
    
    // Antal diamanter
    
    int nDiamonds;
    
    // Spelarens position
    
    int playerRow;
    int playerCol;   
    
    // Poängräknare
    
    int lives;
    int score;
    
        
    // Spelhastighet
    
    int boulderMoveRate;
    int moveCounter;
    
    boolean isOver;
    boolean isCompleted;
    
    // Ljudsystem
    
    Minim minim;
    
    // Ljud för olika händelser
    
    AudioSample diamondSound; 
    AudioSample footstepSound;
    AudioSample boulderSound;
           
    public Game(int rows, int cols, int factor) 
    {
        // Initiera Map-klassen
        
        super(rows, cols, factor);
        
        // Läs in bilder

        gravelImage = loadImage("gravel.png");
        emptyImage = loadImage("empty.png");
        wallImage = loadImage("wall2.png");
        boulderImage = loadImage("boulder.png");
        diamondImage = createImage(64, 64, ARGB);
        openDoorImage = loadImage("door.png");
        closedDoorImage = loadImage("doorClosed.png");
        diamondTiles = loadImage("diamonds.png");
        
        // Kopiera in en bild från tile-bilden för diamanter
        
        diamondImage.copy(diamondTiles, 0, 0, 32, 32, 0, 0, 64, 64); 
        
        // Skapa spelar bilden from tile-bilden.
        
        playerImage = createImage(32,32,ARGB);
        playerTileImage = loadImage("player.png");
        playerImage.copy(playerTileImage, 3 * 32, 1 * 32, 32, 32, 0, 0, 32, 32);   
        
        // Räkna ut hur många stenar, tomrum och diamanter det skall finnas.
        
        nBoulders = int(0.15*nRows*nCols);
        nEmpty = int(0.25*nRows*nCols);
        nDiamonds = int(0.05*nRows*nCols);  
        
        // Initiera ljudssystemet
        
        minim = new Minim(stenras_mall_del3.this);        
        
        // Läs in ljudfiler
        
        diamondSound = minim.loadSample("diamond.wav");
        footstepSound = minim.loadSample("footstep.wav");
        boulderSound = minim.loadSample("boulder.wav");

        // Nollställ poängräknaren

        score = 0;
        
        // Sätt spelhastighet
        
        boulderMoveRate = 10;
        moveCounter = 0;
        isOver = false;
                
        // Skapa vår grotta
        
        createGravel();
        createWalls();
        createEmpty();
        createBoulders();
        createDiamonds();        
    }
    
    void movePlayer(int dr, int dc)
    {       
        // Kontrollera att vi inte går igenom väggar eller stenar
        
        if ((map[playerRow+dr][playerCol+dc]!=WALL)&&
            (map[playerRow+dr][playerCol+dc]!=BOULDER))
        {
            // Ändra spelarbilden
            
            if (dc == -1)
                playerImage.copy(playerTileImage, 3 * 32, 1 * 32, 32, 32, 0, 0, 32, 32);   
            if (dc == 1)
                playerImage.copy(playerTileImage, 3 * 32, 2 * 32, 32, 32, 0, 0, 32, 32);   
            if (dr == -1)
                playerImage.copy(playerTileImage, 3 * 32, 3 * 32, 32, 32, 0, 0, 32, 32);   
            if (dr == 1)
                playerImage.copy(playerTileImage, 3 * 32, 0 * 32, 32, 32, 0, 0, 32, 32);   
            
            
            // Spela ljud
            
            footstepSound.trigger();
            
            // Kontrollera om position vi skall flytta till är en 
            // diamatn
            
            if (map[playerRow+dr][playerCol+dc]==DIAMOND)
            {
                score = score + 1;
                isCompleted = (score == nDiamonds); 
                diamondSound.trigger();
            }
            
            // Sätt nuvarande spelposition i grottan till EMPTY
        
            map[playerRow][playerCol] = EMPTY;
            
            // placera spelaren i grottan dr, dc anger förflyttning
            
            map[playerRow+dr][playerCol+dc] = PLAYER;
            
            playerRow += dr;
            playerCol += dc;
        }
    }
    
    void placePlayer()
    {
        // Placera spelare slumpmässigt i grottan
        
        playerRow = int(random(nRows-2))+1;    
        playerCol = int(random(nCols-2))+1;
                
        map[playerRow][playerCol] = PLAYER;
        
        // Centrera vyn runt spelaren
        
        centerViewPort(playerRow, playerCol);
    }     
    
    void placeRandom(int r0, int r1, int c0, int c1, int value)
    {
        // Placerar ut cellvärde slumpmässgit mellan r0->r1 och c0->c1
        
        int r = int(random(r0, r1));
        int c = int(random(c0, c1));
        
        // Om nuvarande cell innehåller är en diamant försöker vi igen.
        
        while (map[r][c] == DIAMOND)
        {
            r = int(random(r0, r1));
            c = int(random(c0, c1));
        }
        
        map[r][c] = value;
    }            
    
    void createGravel()
    {
        // Fyller område med grus.
        
        fillRect(0,nRows-1, 0, nCols-1, GRAVEL);  
    }
    
    void createEmpty()
    {
        // Skapar slumpmässiga tomrum i grottan.
        
        for (int i=0; i<nBoulders; i++)
            placeRandom(1, nRows-2, 1, nCols-1, EMPTY);
    }
       
    void createBoulders()
    {
        // Sätter ut stenar i grottan.
        
        for (int i=0; i<nBoulders; i++)
            placeRandom(1, nRows-2, 1, nCols-1, BOULDER);
    }
    
    void createWalls()
    {
        // Skapar väggar i grottan.
        
        for (int row=0; row<nRows; row++)
        {
            map[row][0] = WALL;
            map[row][nCols-1] = WALL;
        }
        for (int col=0; col<nCols; col++)
        {
            map[0][col] = WALL;
            map[nCols-1][col] = WALL;
        }
    }
    
    void createDiamonds()
    {
        // Sätter ut diamanter i grottan
        
        for (int i=0; i<nDiamonds; i++)
            placeRandom(1,nRows-2,1,nCols-1,DIAMOND);
    }
    
    void drawCell(int cellType, int x, int y)
    {
        // Ritar ut våra olika typer av celler i grottan
        
        switch(cellType)
        {
            case GRAVEL:
                image(gravelImage, x, y, cellWidth * magFac, cellWidth * magFac);
                break;
            case EMPTY:
                image(emptyImage, x, y, cellWidth * magFac, cellWidth * magFac);               
                break;
            case BOULDER:
                image(emptyImage, x, y, cellWidth * magFac, cellWidth * magFac);               
                image(boulderImage, x, y, cellWidth * magFac, cellWidth * magFac);               
                break;
            case DIAMOND:
                image(gravelImage, x, y, cellWidth * magFac, cellWidth * magFac);               
                image(diamondImage,x, y, cellWidth * magFac, cellWidth * magFac);               
                break;
            case WALL:
                image(wallImage, x, y, cellWidth * magFac, cellWidth * magFac);               
                break;
            case PLAYER:
                image(emptyImage, x, y, cellWidth * magFac, cellWidth * magFac);               
                image(playerImage, x, y, cellWidth * magFac, cellWidth * magFac);               
                break;
            case OUTSIDE:
                break;
        }
    }

    void moveBoulders()
    {
        // Flyttar stenar om det finns tomrum (EMPTY) under dem 
        // eller om det finns tomrum vänster eller höger om stenen.
        
        // Om spelet är slut flyttar vi inte stenarna längre.
        
        if (isOver)
            return;
            
        // För att inte stenarna skall ramla för snabbt, använder
        // vi en räknare, moveCounter, för att bestämma när stenarna skall
        // Flyttas. För varje gång vi anropar denna rutin ökar vi moveCounter
        // med 1. När moveCounter == boulderMoveRate sätter vi den till 0 igen, då
        // kommer stenarna att flyttas igen.
                        
        if (moveCounter == 0)
        {            
            for (int row =nRows-2; row>=0; row--)
                for(int col = 0; col<nCols; col++)
                {
                    // ###     ###
                    // #o#  -> #.#
                    // #.#     #o#
                    
                    if (map[row][col] == BOULDER)
                    {
                        if (map[row+1][col] == EMPTY)
                        {
                            map[row][col] = EMPTY;
                            map[row+1][col] = BOULDER;
                            
                            if (map[row+2][col] == PLAYER)
                            {
                                isOver = true;
                            }
                            
                            if (map[row+2][col] != EMPTY)
                                boulderSound.trigger();
                        }
                    }
                
                    // ###     ###
                    // .o.  -> ...
                    // .o.     oo.
                    //
                    if (map[row][col] == BOULDER)
                    {
                        if (map[row+1][col] == BOULDER)
                        {
                            if ((col!=0)&&(col<nCols-1))
                            {
                                if ((map[row+1][col-1] == EMPTY)&&(map[row][col-1] == EMPTY))
                                {
                                    map[row][col] = EMPTY;
                                    map[row][col-1] = BOULDER;
                                } 
                                else if ((map[row+1][col+1] == EMPTY)&&(map[row][col+1] == EMPTY))
                                {
                                    map[row][col] = EMPTY;
                                    map[row][col+1] = BOULDER;
                                }
                            }
                        }
                    }
            }
        }
        
        moveCounter++;
        
        if (moveCounter == boulderMoveRate)
            moveCounter = 0;
    }        
}