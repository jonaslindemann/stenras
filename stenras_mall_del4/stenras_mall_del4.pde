// Vår spelklass

Game game;
Menu menu;
Text scoreText;
Text gameOverText;
Timer countDown; 

int totalScore;

// Flagga för att hantera tangentnedtryckningar.

boolean keyWasReleased;

final int MENU = 0;
final int PLAYING = 1;
final int GAME_OVER = 2;
final int QUIT = 3;

int gameMode;

// Initieringsfunktion

void setup() 
{
    // Definiera storleken på fönstret
    
    size(1024,768, P3D);
    
    // Nollställ totalpoäng
    
    totalScore = 0;
        
    // Sätt flagga för att hålla koll på när en tangent släpps upp.
    
    keyWasReleased = true;
    
    // Sätt game mode till menu
    
    gameMode = MENU;
    
    // Skapa vår meny
    
    menu = new Menu();
    menu.title = "Mitt spel";
    
    // Ladda bakgrunds bild här:
    
    menu.backgroundImage = loadImage("menu.png");
    
    menu.addMenuItem("Starta");
    menu.addMenuItem("Avsluta");
    
    // Skapa text för poäng
    
    scoreText = new Text();
    
    // Skapa text för game over skärm
    
    gameOverText = new Text();
    gameOverText.setCenterText("Game Over");

} //<>//

void draw()
{
    // Rensa bakgrund
    
    background(0);
    
    if (gameMode == MENU)
    {
        menu.draw();
        menu.checkKeys();
        
        if (menu.isSelected())
        {
            if (menu.selected()==0)
            {
                totalScore = 0;
                
                game = new Game(20, 20, 3);
                game.placePlayer();
                
                gameMode = PLAYING;
                
                // Starta nedräkning
                
                countDown = new Timer(5 * 60 * 1000);
                countDown.start();
                
            }
            if (menu.selected()==1)
                gameMode = QUIT;
                
            menu.reset();
        }
    }
    
    if (gameMode == PLAYING)
    {
        
        // Är en tangent nertryckt?
        
        if (keyPressed)
        {
            // Vänta tills dess att spelaren släpper tangenten innan 
            // vi går vidare.
            
            if (keyWasReleased)
            {
                // Sätt flaggan att tangenten fortfarande är nedtryckt.
                
                keyWasReleased = false;
                
                // Flytta spelaren beroende på vilken piltangent som är
                // nedtryckt.
    
                switch(keyCode) 
                {
                    case UP:
                        game.movePlayer(-1,0);
                        break;                    
                    case DOWN:
                        game.movePlayer(1,0);
                        break;                    
                    case LEFT:
                        game.movePlayer(0,-1);
                        break;                    
                    case RIGHT:
                        game.movePlayer(0,1);
                        break;                    
                }
                
                // Centrera vyn kring spelarens position.
                
                game.checkViewPort(game.playerRow, game.playerCol);
            }
        }
        else 
            keyWasReleased = true; // Om keypressed inte är sann har tangenten släppts upp.    
        
        // Rita vår grotta.
        
        game.moveBoulders();
        game.draw();
        
        // Rita poäng och nedräkning
        
        scoreText.setLeftTopText(countDown.prettyString());
        scoreText.setRightTopText("Diamonds: "+str(game.score)+"/"+str(game.nDiamonds));
        scoreText.setLeftBottomText("Score: "+str(totalScore));
        scoreText.setRightBottomText("");
        scoreText.draw();
        
        if (game.isCompleted)
        {
            totalScore = totalScore + game.score;
            
            game = new Game(20, 20, 3);
            game.placePlayer();
            
            gameMode = PLAYING;
            
            // Starta nedräkning
            
            countDown = new Timer(5 * 60 * 1000);
            countDown.start();            
        }
        
        if ((game.isOver)||(countDown.isFinished()))
            gameMode = GAME_OVER;
    }
    
    if (gameMode == GAME_OVER)
    {
        game.draw();
        scoreText.draw();
        gameOverText.draw();
                
        if (keyPressed)
            if (keyWasReleased)
                gameMode = MENU;
        else
            keyWasReleased = true;
    }
    
    if (gameMode == QUIT)
        exit();
        
}  