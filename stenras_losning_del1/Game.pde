
class Game {
    
    Cave cave;
           
    int score;
    int collectedDiamonds;    
    
    boolean isOver;
    boolean isFinished;
              
    public Game(int startScore)
    {
        collectedDiamonds = 0;
        score = startScore;
        isOver = false;
        isFinished = false;
        
        cave = new Cave(20, 20, 3);
        cave.placePlayer();
    }
    
    void draw()
    {
        cave.draw();
    }
            
}    
    