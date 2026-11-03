// Vår spelklass

Game game;

int totalScore;

// Flagga för att hantera tangentnedtryckningar.

boolean keyWasReleased;

// Initieringsfunktion

void setup() 
{
    // Definiera storleken på fönstret
    
    size(1024,768, P3D);
              
    // Sätt flagga för att hålla koll på när en tangent släpps upp.
    
    keyWasReleased = true;    
} //<>//

void draw()
{
    // Rensa bakgrund
    
    background(0);

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
    
    game.draw();    
}  