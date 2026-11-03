class Timer {
 
    int savedTime; // When Timer started
    int totalTime; // How long Timer should last
  
    Timer(int tempTotalTime) 
    {
        totalTime = tempTotalTime;
    }
  
    void start() {
        savedTime = millis(); 
    }
  
    boolean isFinished() 
    { 
        int passedTime = millis()- savedTime;
        if (passedTime > totalTime) 
        {
            return true;
        } 
        else 
        {
            return false;
        }
    }
    
    int timeLeft()
    {
        int passedTime = millis() - savedTime;
        int left = totalTime - passedTime;  
        return left;
    }
    
    String prettyString()
    {
        int passedTime = millis() - savedTime;
        int timeLeft = totalTime - passedTime;
        
        int minutes = (timeLeft/(60*1000));
        int seconds = (timeLeft/1000) - minutes * 60;
        
        if (!isFinished())
            return str(minutes)+":"+str(seconds);
        else
            return "--:--";
    }
}