class Text
{
    PFont statusFont;
    
    String leftTopText;
    String rightTopText;
    String leftBottomText;
    String rightBottomText;
    String centerText;
    
    public Text()
    {
        statusFont = createFont("Bangers.ttf",100,true);
        
        leftTopText = "";
        rightTopText = "";
        leftBottomText = "";
        rightBottomText = "";
        
        centerText = "";
    }
    
    public void setLeftTopText(String text)
    {
        leftTopText = text;    
    }
       
    public void setRightTopText(String text)
    {
        rightTopText = text;    
    }

    public void setLeftBottomText(String text)
    {
        leftBottomText = text;    
    }
       
    public void setRightBottomText(String text)
    {
        rightBottomText = text;    
    }

    public void setCenterText(String text)
    {
        centerText = text;    
    }

    public void draw()
    {
        textFont(statusFont);
        textAlign(LEFT, TOP);
        textSize(50);
        fill(0);
        text(leftTopText, 25, 25);        
        fill(255);
        text(leftTopText, 20, 20);
        
        textAlign(RIGHT, TOP);
        textSize(50);
        fill(0);
        text(rightTopText, width - 25, 25);        
        fill(255);
        text(rightTopText, width - 20, 20);
        
        textAlign(CENTER, CENTER);
        textSize(100);
        fill(0);
        text(centerText, width/2 + 10, height/2 + 10);
        fill(255);
        text(centerText, width/2, height/2);

        textAlign(LEFT, BOTTOM);
        textSize(50);
        fill(0);
        text(leftBottomText, 25, height - 25);        
        fill(255);
        text(leftBottomText, 20, height - 20);
        
        textAlign(RIGHT, BOTTOM);
        textSize(50);
        fill(0);
        text(rightBottomText, width - 25, height - 25);        
        fill(255);
        text(rightBottomText, width - 20, height - 20);
    }
}
    