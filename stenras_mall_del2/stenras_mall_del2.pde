Cave cave;

void setup() 
{
    size(1024,768, P3D);
    cave = new Cave(20,20,1);
}

void draw()
{
    background(0);
    cave.draw();
}   //<>//