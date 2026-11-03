Cave cave;

boolean keyWasReleased;

void setup() 
{
    size(1024,768, P3D);
    
    cave = new Cave(20, 20, 3);
    cave.placePlayer();
    
    keyWasReleased = true;
} //<>//

void draw()
{
    background(0);
    
    if (keyPressed)
    {
        if (keyWasReleased)
        {
            keyWasReleased = false;

            switch(keyCode) 
            {
                case UP:
                    cave.movePlayer(-1,0);
                    break;                    
                case DOWN:
                    cave.movePlayer(1,0);
                    break;                    
                case LEFT:
                    cave.movePlayer(0,-1);
                    break;                    
                case RIGHT:
                    cave.movePlayer(0,1);
                    break;                    
            }
            
            cave.centerViewPort(cave.playerRow, cave.playerCol);
        }
    }
    else 
        keyWasReleased = true;    
    
    cave.draw();
}  