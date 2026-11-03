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
final int EXPLOSION = 8;

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

    // Antal väggblock inne i grottan

    int nWalls;

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

    // Håller reda på vilka stenar som är på väg nedåt.

    boolean[][] falling;

    // Håller reda på vilka celler som redan har flyttats i
    // nuvarande uppdatering.

    boolean[][] moved;

    // Antal uppdateringar kvar innan en explosion försvinner.

    int explosionCounter;

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
        nWalls = int(0.03*nRows*nCols);

        // Initiera ljudssystemet

        minim = new Minim(stenras_utmaningar_del4.this);

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

        falling = new boolean[nRows][nCols];
        moved = new boolean[nRows][nCols];
        explosionCounter = 0;

        // Skapa vår grotta

        createGravel();
        createWalls();
        createInnerWalls();
        createEmpty();
        createBoulders();
        createDiamonds();
    }

    void collectDiamond()
    {
        // Lägger till en diamant. När alla är uppsamlade är nivån klar.

        score = score + 1;
        isCompleted = (score == nDiamonds);
        diamondSound.trigger();
    }

    void movePlayer(int dr, int dc)
    {
        // Utmaning 3 - Knuffa en sten åt sidan om det är tomt bakom
        // den. Vi knuffar bara i sidled: uppåt orkar man inte lyfta
        // stenen och nedåt skulle den ändå bara falla.

        if ((dr == 0) &&
            (map[playerRow][playerCol+dc] == BOULDER) &&
            (map[playerRow][playerCol+2*dc] == EMPTY) &&
            (!falling[playerRow][playerCol+dc]))
        {
            moveObject(playerRow, playerCol+dc, playerRow, playerCol+2*dc);
        }

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
                collectDiamond();

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

    void createInnerWalls()
    {
        // Utmaning 1 - Sätter ut några väggblock inne i grottan så att
        // stenarna har något att rulla av.

        for (int i=0; i<nWalls; i++)
            placeRandom(1, nRows-2, 1, nCols-1, WALL);
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
                image(emptyImage, x, y, cellWidth * magFac, cellWidth * magFac);
                image(diamondImage,x, y, cellWidth * magFac, cellWidth * magFac);
                break;
            case WALL:
                image(wallImage, x, y, cellWidth * magFac, cellWidth * magFac);
                break;
            case PLAYER:
                image(emptyImage, x, y, cellWidth * magFac, cellWidth * magFac);
                image(playerImage, x, y, cellWidth * magFac, cellWidth * magFac);
                break;
            case EXPLOSION:
                // Utmaning 4 - Ritar en fladdrande eldboll.

                image(emptyImage, x, y, cellWidth * magFac, cellWidth * magFac);
                pushStyle();
                noStroke();
                fill(255, random(80, 200), 0);
                float size = cellWidth * magFac * random(0.6, 1.1);
                ellipse(x + cellWidth * magFac / 2, y + cellWidth * magFac / 2, size, size);
                popStyle();
                break;
            case OUTSIDE:
                break;
        }
    }

    boolean isRound(int cellType)
    {
        // Saker kan rulla av andra stenar, diamanter och väggar.

        // Utmaning 1 - Stenar rullar även av väggar.

        return (cellType == BOULDER) || (cellType == DIAMOND) || (cellType == WALL);
    }

    boolean canFall(int cellType)
    {
        // Utmaning 2 - Både stenar och diamanter faller.

        return (cellType == BOULDER) || (cellType == DIAMOND);
    }

    void moveObject(int fromRow, int fromCol, int toRow, int toCol)
    {
        // Flyttar det som finns i en cell (en sten eller en diamant)
        // till en annan cell och kommer ihåg att den redan har flyttats
        // i denna uppdatering.

        map[toRow][toCol] = map[fromRow][fromCol];
        map[fromRow][fromCol] = EMPTY;

        falling[fromRow][fromCol] = false;
        moved[toRow][toCol] = true;
    }

    void updateObject(int row, int col)
    {
        // Regel 1 - Tomt under. Stenen eller diamanten faller ett steg.

        // ###     ###
        // #o#  -> #.#
        // #.#     #o#

        if (map[row+1][col] == EMPTY)
        {
            moveObject(row, col, row+1, col);
            falling[row+1][col] = true;

            // Slår den i något spelar vi ljud direkt. Träffas
            // spelaren tar regel 2 hand om det.

            if ((map[row+2][col] != EMPTY) && (map[row+2][col] != PLAYER))
                boulderSound.trigger();

            return;
        }

        // Regel 2 - Något som faller träffar spelaren.

        if ((map[row+1][col] == PLAYER) && (falling[row][col]))
        {
            if (map[row][col] == DIAMOND)
            {
                // Utmaning 2 - En fallande diamant fångas av spelaren.

                map[row][col] = EMPTY;
                falling[row][col] = false;
                collectDiamond();
            }
            else
            {
                // Utmaning 4 - En fallande sten får spelaren att explodera.

                boulderSound.trigger();
                explode(row+1, col);
                isOver = true;
            }
            return;
        }

        // Regel 3 - Den ligger på något runt. Den rullar åt sidan
        // om det är tomt både bredvid och snett nedanför.

        // ...     ...
        // .o.  -> o..
        // .o.     .o.

        if (isRound(map[row+1][col]))
        {
            if ((map[row][col-1] == EMPTY) && (map[row+1][col-1] == EMPTY))
            {
                moveObject(row, col, row, col-1);
                return;
            }

            if ((map[row][col+1] == EMPTY) && (map[row+1][col+1] == EMPTY))
            {
                moveObject(row, col, row, col+1);
                return;
            }
        }

        // Regel 4 - Den ligger still.

        falling[row][col] = false;
    }

    void explode(int row, int col)
    {
        // Utmaning 4 - Spränger bort allt utom väggar i en 3x3-ruta
        // runt row, col. Cellerna visas som EXPLOSION under några
        // uppdateringar innan de blir tomma.

        for (int r = row-1; r <= row+1; r++)
            for (int c = col-1; c <= col+1; c++)
                if (map[r][c] != WALL)
                {
                    map[r][c] = EXPLOSION;
                    falling[r][c] = false;
                }

        explosionCounter = 4;
    }

    void updateExplosion()
    {
        // Räknar ned explosionen och tömmer cellerna när den är klar.

        if (explosionCounter == 0)
            return;

        explosionCounter--;

        if (explosionCounter == 0)
            for (int row = 0; row < nRows; row++)
                for (int col = 0; col < nCols; col++)
                    if (map[row][col] == EXPLOSION)
                        map[row][col] = EMPTY;
    }

    void moveBoulders()
    {
        // Stenarna fortsätter att röra sig även när spelet är slut,
        // så att vi ser explosionen och stenarna som rasar efteråt.

        // Stenarna flyttas bara var boulderMoveRate:e gång rutinen
        // anropas, annars skulle de falla alldeles för snabbt.

        moveCounter++;

        if (moveCounter < boulderMoveRate)
            return;

        moveCounter = 0;

        updateExplosion();

        // Nollställ vilka stenar och diamanter som har flyttats.

        moved = new boolean[nRows][nCols];

        // Gå igenom grottan nerifrån och upp. Annars skulle en sten
        // som flyttats ett steg ned hittas igen på nästa rad och falla
        // hela vägen till botten på en gång. Ytterkanterna är alltid
        // väggar så dem behöver vi inte titta på.

        for (int row = nRows-2; row >= 1; row--)
            for (int col = 1; col < nCols-1; col++)
                if ((canFall(map[row][col])) && (!moved[row][col]))
                    updateObject(row, col);
    }
}
