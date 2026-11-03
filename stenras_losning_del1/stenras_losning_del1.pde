Game game;

void setup() 
{
    size(1024,768, P3D);
    game = new Game(0);
}

void draw()
{
    background(0);
    game.draw();
}  //<>//