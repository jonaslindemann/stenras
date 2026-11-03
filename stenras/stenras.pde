Menu menu;
Game game;

final int START = 0;
final int MENU = 1;
final int PLAYING = 2;
final int GAME_OVER = 3;
final int FINISHED_MAP = 4;

int gameMode;
int lastMode;

boolean keyWasReleased;
boolean giveUp;

void setup() 
{
    size(1280,1024, P3D);
    //size(1024,768);
    //fullScreen(P3D);
    
    gameMode = MENU;
    lastMode = START;
    
    menu = new Menu();
    menu.addMenuItem("Start Game");
    menu.addMenuItem("Difficulty : NORMAL");
    menu.addMenuItem("Sound : ON");
    menu.addMenuItem("Exit");
      
    keyWasReleased = true;
    giveUp = false;
}

void keyPressed()
{
    if (key == 27)
        key = 0;        
}

void draw()
{
    background(0);
    
    switch (gameMode) 
    {
        case MENU:
            if (lastMode!=gameMode)
            {
                menu.stopMusic();
                menu.playMusic();
            }
            
            lastMode = gameMode;
                
            menu.draw();

            if (keyPressed)
            {
                if (keyWasReleased)
                {
                    keyWasReleased = false;
                    switch(keyCode) {
                        case UP:
                            menu.moveUp();
                            break;                        
                        case DOWN:
                            menu.moveDown();                        
                            break;
                        case ENTER:
                            switch(menu.selectedMenu) {
                                case 0:
                                    menu.stopMusic();
                                    
                                    game = new Game(0);
                                    
                                    lastMode = gameMode;
                                    gameMode = PLAYING;
                                    giveUp = false;
                                    
                                    break;
                                case 3:
                                    exit();
                                    break;
                            }
                            break;
                        default:
                        
                            break;
                    }
                }
            }
            else
                keyWasReleased = true;
                
            break;
        case PLAYING:
            if ( (!game.isOver) && (!giveUp) && (!game.isFinished))
            {
                background(0);
                
                game.moveBoulders();
                game.updatePlayer();
                game.checkCountDown();
                game.draw();
                
                if (keyPressed)
                {   
                    if (keyWasReleased)
                    {
                        keyWasReleased = false;
                        
                        switch(keyCode) 
                        {
                            case UP:
                                game.movePlayerUp();
                                break;
                            case DOWN:
                                game.movePlayerDown();
                                break;
                            case LEFT:
                                game.movePlayerLeft();
                                break;
                            case RIGHT:
                                game.movePlayerRight();
                                break;
                            case ESC:
                                giveUp = true;
                                break;
                                 //<>//
                        }
                    }
                }
                else
                    keyWasReleased = true;
            }
            else
            {
                if ( game.isOver )
                {
                    game.stopPlaying();
                    
                    lastMode = gameMode;
                    gameMode = GAME_OVER;
                }
                   
                if (giveUp)
                {
                    game.stopPlaying();
                    lastMode = gameMode;
                    gameMode = MENU;                   
                }
                
                if (game.isFinished)
                {
                    game.stopPlaying();
                    lastMode = gameMode;
                    gameMode = FINISHED_MAP;
                }
            }
                 //<>//
            break;
        case GAME_OVER:
       
            game.moveBoulders();
            game.draw();

            if (keyPressed)
            {
                if (keyWasReleased)
                {
                    keyWasReleased = false;
                    
                    lastMode = gameMode;
                    gameMode = MENU;                                       
                }
            }
            else
                keyWasReleased = true;

            
            break;
            
        case FINISHED_MAP:
       
            game.moveBoulders();
            game.draw();

            if (keyPressed)
            {
                if (keyWasReleased)
                {
                    keyWasReleased = false;
                    
                    game = new Game(game.score);
                    
                    lastMode = gameMode;
                    gameMode = PLAYING;
                    giveUp = false;
                }
            }
            else
                keyWasReleased = true;
            
            break;
    }
}