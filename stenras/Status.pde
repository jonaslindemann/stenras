class Status
{
    PFont statusFont;
    Game game;
    
    public Status(Game g)
    {
        game = g;
        statusFont = createFont("Bangers.ttf",100,true);
    }
       
    public void draw()
    {
        textFont(statusFont);
        textAlign(LEFT, TOP);
        textSize(50);
        fill(0);
        text("Diamonds: "+str(game.collectedDiamonds)+"/"+str(game.map.nDiamonds), 25, 25);        
        fill(255);
        text("Diamonds: "+str(game.collectedDiamonds)+"/"+str(game.map.nDiamonds), 20, 20);
        
        textAlign(RIGHT, TOP);
        textSize(50);
        fill(0);
        text("Countdown: "+game.timeLeft(), width - 25, 25);        
        fill(255);
        text("Countdown: "+game.timeLeft(), width - 20, 20);

        if (game.isOver)
        {
            textAlign(CENTER, CENTER);
            textSize(100);
            fill(0);
            text("Game Over", width/2 + 10, height/2 + 10);
            fill(255);
            text("Game Over", width/2, height/2);
        }

        if (game.isFinished)
        {
            textAlign(CENTER, CENTER);
            textSize(100);
            fill(0);
            text("Cave Completed!", width/2 + 10, height/2 + 10);
            fill(255);
            text("Cave Completed!", width/2, height/2);

            fill(0);
            text("Score : " + str(game.score), width/2 + 10, height/2 + 10 + 100);
            fill(255);
            text("Score : " + str(game.score), width/2, height/2 + 100);
        }
    }
}
    