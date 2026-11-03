import ddf.minim.*;
import ddf.minim.ugens.*;

class Game {

    Map map;
    Status status;

    int playerRow;
    int playerCol;
    int boulderMoveRate;

    int score;
    int collectedDiamonds;

    boolean isOver;
    boolean isFinished;

    // Håller reda på vilka stenar som är på väg nedåt och vilka
    // celler som redan har flyttats i nuvarande uppdatering.

    boolean[][] falling;
    boolean[][] moved;

    // Antal uppdateringar kvar innan en explosion försvinner.

    int explosionCounter;

    int playerFrame;
    int playerAnim;
    int playerAnimCycle;

    Timer countDown;

    PImage playerImage;
    PImage playerTileImage;

    Minim minim;
    AudioPlayer music;
    AudioSample boulderSound;
    AudioSample footstepSound;
    AudioSample gameOverSound;
    AudioSample diamondSound;

    public Game(int startScore)
    {
        playerFrame = 0;
        playerAnim = 0;
        playerAnimCycle = 0;
        collectedDiamonds = 0;
        score = startScore;

        playerImage = createImage(32,32,ARGB);
        playerTileImage = loadImage("player.png");
        playerImage.copy(playerTileImage, 0 * 32, 0 * 32, 32, 32, 0, 0, 32, 32);

        map = new Map();
        map.playerImage = playerImage;

        status = new Status(this);

        boulderMoveRate = 20;
        isOver = false;
        isFinished = false;

        falling = new boolean[map.nRows][map.nCols];
        moved = new boolean[map.nRows][map.nCols];
        explosionCounter = 0;

        // Initiera ljudsystem

        minim = new Minim(stenras_utmaningar.this);

        // Läs in ljud

        boulderSound = minim.loadSample("boulder.wav");
        footstepSound = minim.loadSample("footstep.wav");
        gameOverSound = minim.loadSample("gameover.wav");
        diamondSound = minim.loadSample("diamond.wav");

        // Läs in musik

        music = minim.loadFile("03_Chibi_Ninja.mp3");
        music.setGain(-10);
        music.play();

        // Placera spelaren

        placePlayer();

        // Starta timer

        countDown = new Timer(5 * 60 * 1000);
        countDown.start();
    }

    void draw()
    {
        map.draw();
        status.draw();
    }

    String timeLeft()
    {
        return countDown.prettyString();
    }

    void stopPlaying()
    {
        music.pause();
    }

    void placePlayer()
    {
        playerRow = int(random(map.nRows-2))+1;
        playerCol = int(random(map.nCols-2))+1;

        while (map.cell(playerRow,playerCol)!=BOULDER)
        {
            playerRow = int(random(map.nRows-2))+1;
            playerCol = int(random(map.nCols-2))+1;
        }

        map.setCell(playerRow,playerCol, PLAYER);
        map.centerViewPort(playerRow, playerCol);
    }

    void addDiamond()
    {
        // Spela diamantljud

        diamondSound.trigger();

        // Lägg till poäng

        collectedDiamonds += 1;

        // Öppna dörren när alla diamanter är uppsamlade

        if (collectedDiamonds == map.nDiamonds)
            map.doorOpen = true;
        else
            map.doorOpen = false;
    }

    void calcScore()
    {
        score += collectedDiamonds * 100 + countDown.timeLeft()/100;
    }

    void updatePlayer()
    {
        // Denna rutin ansvarar för att animera spelaren

        if (frameCount % 5 == 0)
        {
            playerFrame++;

            if (playerFrame==3)
            {
                playerFrame = 0;

                if (playerAnimCycle<3)
                    playerAnimCycle++;
            }

            if (playerAnimCycle<3)
                playerImage.copy(playerTileImage, (3 + playerFrame) * 32, playerAnim * 32, 32, 32, 0, 0, 32, 32);
            else
                playerImage.copy(playerTileImage, 1 * 32, 0 * 32, 32, 32, 0, 0, 32, 32);
        }
    }

    void checkCountDown()
    {
        if (countDown.isFinished())
            isOver = true;
    }

    public void updateViewPort()
    {
        if ((playerCol-map.viewPortCol==0))
            map.centerViewPortCol(playerRow, playerCol);
        if ((playerRow-map.viewPortRow==0))
            map.centerViewPortRow(playerRow, playerCol);
        if ((playerCol+3)>( map.viewPortCol+map.viewPortWidth))
            map.centerViewPortCol(playerRow, playerCol);
        if ((playerRow+3)>( map.viewPortRow+map.viewPortHeight))
            map.centerViewPortRow(playerRow, playerCol);
    }

    void movePlayer(int dr, int dc)
    {
        playerAnimCycle = 0;

        // Utmaning 3 - Knuffa en sten åt sidan om det är tomt bakom
        // den. Vi knuffar bara i sidled: uppåt orkar man inte lyfta
        // stenen och nedåt skulle den ändå bara falla.

        if ((dr == 0) &&
            (map.cell(playerRow, playerCol+dc) == BOULDER) &&
            (map.cell(playerRow, playerCol+2*dc) == EMPTY) &&
            (!falling[playerRow][playerCol+dc]))
        {
            moveObject(playerRow, playerCol+dc, playerRow, playerCol+2*dc);
            boulderSound.trigger();
        }

        if ((map.cell(playerRow+dr,playerCol+dc)!=WALL)&&
            (map.cell(playerRow+dr,playerCol+dc)!=BOULDER))
        {
            if (map.cell(playerRow+dr, playerCol+dc) == DIAMOND)
                addDiamond();
            else
                footstepSound.trigger();

            if ( map.cell(playerRow+dr, playerCol+dc) == DOOR )
            {
                if (map.doorOpen)
                {
                    isFinished = true;
                    calcScore();
                    map.setCell(playerRow,playerCol, EMPTY);
                    map.setCell(playerRow+dr,playerCol+dc, PLAYER);
                    playerRow+=dr;
                    playerCol+=dc;
                }
            }
            else
            {
                map.setCell(playerRow,playerCol, EMPTY);
                map.setCell(playerRow+dr,playerCol+dc, PLAYER);
                playerRow+=dr;
                playerCol+=dc;
            }
        }
        updateViewPort();
    }

    void movePlayerLeft()
    {
        playerAnim = 1;
        movePlayer(0,-1);
    }

    void movePlayerRight()
    {
        playerAnim = 2;
        movePlayer(0,1);
    }

    void movePlayerUp()
    {
        playerAnim = 3;
        movePlayer(-1,0);
    }

    void movePlayerDown()
    {
        playerAnim = 0;
        movePlayer(1,0);
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

        map.setCell(toRow, toCol, map.cell(fromRow, fromCol));
        map.setCell(fromRow, fromCol, EMPTY);

        falling[fromRow][fromCol] = false;
        moved[toRow][toCol] = true;
    }

    void updateObject(int row, int col)
    {
        // Regel 1 - Tomt under. Stenen eller diamanten faller ett steg.

        // ###     ###
        // #o#  -> #.#
        // #.#     #o#

        if (map.cell(row+1, col) == EMPTY)
        {
            moveObject(row, col, row+1, col);
            falling[row+1][col] = true;

            // Slår den i något spelar vi ljud direkt. Träffas
            // spelaren tar regel 2 hand om det.

            if ((map.cell(row+2, col) != EMPTY) && (map.cell(row+2, col) != PLAYER))
                boulderSound.trigger();

            return;
        }

        // Regel 2 - Något som faller träffar spelaren.

        if ((map.cell(row+1, col) == PLAYER) && (falling[row][col]))
        {
            if (map.cell(row, col) == DIAMOND)
            {
                // Utmaning 2 - En fallande diamant fångas av spelaren.

                map.setCell(row, col, EMPTY);
                falling[row][col] = false;
                addDiamond();
            }
            else
            {
                // Utmaning 4 - En fallande sten får spelaren att explodera.

                gameOverSound.trigger();
                explode(row+1, col);
                isOver = true;
                music.pause();
            }
            return;
        }

        // Regel 3 - Den ligger på något runt. Den rullar åt sidan
        // om det är tomt både bredvid och snett nedanför.

        // ...     ...
        // .o.  -> o..
        // .o.     .o.

        if (isRound(map.cell(row+1, col)))
        {
            if ((map.cell(row, col-1) == EMPTY) && (map.cell(row+1, col-1) == EMPTY))
            {
                moveObject(row, col, row, col-1);
                return;
            }

            if ((map.cell(row, col+1) == EMPTY) && (map.cell(row+1, col+1) == EMPTY))
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
        // Utmaning 4 - Spränger bort allt utom väggar och dörren i en
        // 3x3-ruta runt row, col. Cellerna visas som EXPLOSION under
        // några uppdateringar innan de blir tomma.

        for (int r = row-1; r <= row+1; r++)
            for (int c = col-1; c <= col+1; c++)
                if ((map.cell(r, c) != WALL) && (map.cell(r, c) != DOOR))
                {
                    map.setCell(r, c, EXPLOSION);
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
            for (int row = 0; row < map.nRows; row++)
                for (int col = 0; col < map.nCols; col++)
                    if (map.cell(row, col) == EXPLOSION)
                        map.setCell(row, col, EMPTY);
    }

    void moveBoulders()
    {
        // Stenarna fortsätter att röra sig även när spelet är slut,
        // så att vi ser explosionen och stenarna som rasar efteråt.

        if (isFinished)
            return;

        // Stenarna flyttas bara var boulderMoveRate:e bildruta.

        if (frameCount % boulderMoveRate != 0)
            return;

        updateExplosion();

        // Nollställ vilka stenar och diamanter som har flyttats.

        moved = new boolean[map.nRows][map.nCols];

        // Gå igenom grottan nerifrån och upp. Annars skulle en sten
        // som flyttats ett steg ned hittas igen på nästa rad och falla
        // hela vägen till botten på en gång. Ytterkanterna är alltid
        // väggar så dem behöver vi inte titta på.

        for (int row = map.nRows-2; row >= 1; row--)
            for (int col = 1; col < map.nCols-1; col++)
                if ((canFall(map.cell(row, col))) && (!moved[row][col]))
                    updateObject(row, col);
    }
}
