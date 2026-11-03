
final int EMPTY = 0;
final int GRAVEL = 1;
final int WALL = 2;
final int BOULDER = 3;
final int PLAYER = 4;
final int OUTSIDE = 5;
final int DIAMOND = 6;
final int DOOR = 7;

class Map 
{   
    int[][] map;

    int cellWidth;    
    int magFac;

    int nRows; 
    int nCols;
    int nBoulders;
    int nEmpty;
    int nDiamonds;
    int diamondFrame;
    
    int viewPortWidth;
    int viewPortHeight;
    int viewPortRow;
    int viewPortCol;
    
    boolean doorOpen;
    int doorCol;
    int doorRow;
    
    PImage gravelImage;
    PImage emptyImage;
    PImage wallImage;
    PImage boulderImage;
    PImage playerImage;
    PImage diamondImage;
    PImage doorImage;
    PImage closedDoorImage;
    PImage openDoorImage;
    PImage diamondTiles;    

    public Map() 
    {
        nRows = 20;
        nCols = 20;
        cellWidth = 32;
        magFac = 3;

        doorOpen = false;
        diamondFrame = 0;
        
        viewPortWidth = width/(cellWidth * magFac) + 1; 
        viewPortHeight = height/(cellWidth * magFac) + 1;
        viewPortRow = 0;
        viewPortCol = 0;
        
        nBoulders = int(0.15*nRows*nCols);
        nEmpty = int(0.25*nRows*nCols);
        nDiamonds = int(0.05*nRows*nCols);
        
        // Läs in bilder från data-katalogen

        gravelImage = loadImage("gravel.png");
        emptyImage = loadImage("empty.png");
        wallImage = loadImage("wall2.png");
        boulderImage = loadImage("boulder.png");
        diamondImage = createImage(64, 64, ARGB);
        openDoorImage = loadImage("door.png");
        closedDoorImage = loadImage("doorClosed.png");
        diamondTiles = loadImage("diamonds.png");
    
        map = new int[nRows][nCols];
        fillMap();
    }
                    
    int cell(int row, int col)
    {
        if ((row<0)||(row>=nRows))
            return OUTSIDE;
        if ((col<0)||(col>=nCols))
            return OUTSIDE;
            
        return map[row][col];
    }
    
    void setCell(int row, int col, int value)
    {
        map[row][col] = value;    
    }    
    
    void centerViewPort(int row, int col)
    {
        viewPortRow = row - viewPortHeight/2;
        viewPortCol = col - viewPortWidth/2;
    }
    
    void centerViewPortCol(int row, int col)
    {
        viewPortCol = col - viewPortWidth/2;
    }

    void centerViewPortRow(int row, int col)
    {
        viewPortRow = row - viewPortHeight/2;
    }
        
    void fillRect(int r0, int r1, int c0, int c1, int value)
    {
        for (int row = r0; row<=r1; row++)
            for(int col = c0; col<=c1; col++)
                map[row][col] = value;
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

    void draw()
    {
        int r, c;
        
        if (frameCount % 20 ==0)
        {
            diamondImage.copy(diamondTiles, diamondFrame * 32, 0 * 32, 32, 32, 0, 0, 64, 64);
            diamondFrame++;
            
            if (diamondFrame == 8)
                diamondFrame = 0;
        }
       
        for (int row = viewPortRow; row<(viewPortHeight+viewPortRow); row++)
        {
            for (int col = viewPortCol; col<(viewPortWidth+viewPortCol); col++)
            {
                c = (col-viewPortCol) * cellWidth * magFac;
                r = (row-viewPortRow) * cellWidth * magFac;
                
                switch(cell(row,col))
                {
                    case GRAVEL:
                        image(gravelImage, c, r, cellWidth * magFac, cellWidth * magFac);
                        break;
                    case EMPTY:
                        image(emptyImage, c, r, cellWidth * magFac, cellWidth * magFac);               
                        break;
                    case BOULDER:
                        image(emptyImage, c, r, cellWidth * magFac, cellWidth * magFac);               
                        image(boulderImage, c, r, cellWidth * magFac, cellWidth * magFac);               
                        break;
                    case DIAMOND:
                        image(gravelImage, c, r, cellWidth * magFac, cellWidth * magFac);               
                        image(diamondImage, c, r, cellWidth * magFac, cellWidth * magFac);               
                        break;
                    case WALL:
                        image(wallImage, c, r, cellWidth * magFac, cellWidth * magFac);               
                        break;
                    case PLAYER:
                        image(emptyImage, c, r, cellWidth * magFac, cellWidth * magFac);               
                        image(playerImage, c, r, cellWidth * magFac, cellWidth * magFac);               
                        break;
                    case OUTSIDE:
                        break;
                    case DOOR:
                        if (doorOpen)
                        {
                            image(emptyImage, c, r, cellWidth * magFac, cellWidth * magFac);               
                            image(openDoorImage, c, r, cellWidth * magFac, cellWidth * magFac);
                        }
                        else
                        {
                            image(emptyImage, c, r, cellWidth * magFac, cellWidth * magFac);               
                            image(closedDoorImage, c, r, cellWidth * magFac, cellWidth * magFac);                            
                        }
                        break;
                }
            }
        }
    }           
}