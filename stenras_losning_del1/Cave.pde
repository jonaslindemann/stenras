
final int EMPTY = 0;
final int GRAVEL = 1;
final int WALL = 2;
final int BOULDER = 3;
final int PLAYER = 4;
final int OUTSIDE = 5;
final int DIAMOND = 6;
final int DOOR = 7;

class Cave extends Map {

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
    
    int nBoulders;
    int nEmpty;
    int nDiamonds;
       
    public Cave(int rows, int cols, int factor) 
    {
        super(rows, cols, factor);

        gravelImage = loadImage("gravel.png");
        emptyImage = loadImage("empty.png");
        wallImage = loadImage("wall2.png");
        boulderImage = loadImage("boulder.png");
        diamondImage = createImage(64, 64, ARGB);
        openDoorImage = loadImage("door.png");
        closedDoorImage = loadImage("doorClosed.png");
        diamondTiles = loadImage("diamonds.png");
        
        diamondImage.copy(diamondTiles, 0, 0, 32, 32, 0, 0, 64, 64);       
        
        playerImage = createImage(32,32,ARGB);
        playerTileImage = loadImage("player.png");
        playerImage.copy(playerTileImage, 0 * 32, 0 * 32, 32, 32, 0, 0, 32, 32);   
        
        nBoulders = int(0.15*nRows*nCols);
        nEmpty = int(0.25*nRows*nCols);
        nDiamonds = int(0.05*nRows*nCols);        
        
        fillMap();
    }
    
    void placePlayer()
    {
        playerRow = int(random(nRows-2))+1;    
        playerCol = int(random(nCols-2))+1;
                
        map[playerRow][playerCol] = PLAYER;
        centerViewPort(playerRow, playerCol);
    }     
    
    void placeRandom(int r0, int r1, int c0, int c1, int value)
    {
        int r = int(random(r0, r1));
        int c = int(random(c0, c1));
        
        while (map[r][c] == DIAMOND)
        {
            r = int(random(r0, r1));
            c = int(random(c0, c1));
        }
        
        map[r][c] = value;
    }            
    
    void createGravel()
    {
        fillRect(0,nRows-1, 0, nCols-1, GRAVEL);  
    }
    
    void createEmpty()
    {
        for (int i=0; i<nBoulders; i++)
            placeRandom(1, nRows-2, 1, nCols-1, EMPTY);
    }
       
    void createBoulders()
    {
        for (int i=0; i<nBoulders; i++)
            placeRandom(1, nRows-2, 1, nCols-1, BOULDER);
    }
    
    void createWalls()
    {
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
        for (int i=0; i<nDiamonds; i++)
            placeRandom(1,nRows-2,1,nCols-1,DIAMOND);
    }
    
    void placeDoor()
    {
        placeRandom(1,nRows-2,1,nCols-1,DOOR);        
    }        
    
    void fillMap()
    {
        createGravel();
        createWalls();
        createEmpty();
        createBoulders();
        createDiamonds();
        placeDoor();
    }
        
    void drawCell(int cellType, int x, int y)
    {
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
            case DOOR:
                if (doorOpen)
                {
                    image(emptyImage, x, y, cellWidth * magFac, cellWidth * magFac);               
                    image(openDoorImage, x, y, cellWidth * magFac, cellWidth * magFac);
                }
                else
                {
                    image(emptyImage, x, y, cellWidth * magFac, cellWidth * magFac);               
                    image(closedDoorImage, x, y, cellWidth * magFac, cellWidth * magFac);                            
                }
                break;
        }
    }
}