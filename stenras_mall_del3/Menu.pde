import ddf.minim.*;
import ddf.minim.ugens.*;
import javax.sound.midi.*;

class Menu 
{
    PImage backgroundImage;
    PFont menuFont;
    
    Minim minim;
    AudioPlayer music;
    AudioSample boulderSound;
    
    String title;
    StringList menuItems;
    int selectedMenu;
    boolean keyWasReleased;
    int chosenMenuItem;
    
    public Menu()
    {
        title = "Stenras!";
        
        menuItems = new StringList();
        
        selectedMenu = 0;
        chosenMenuItem = -1;
        
        menuFont = createFont("Bangers.ttf",100,true);
        
        backgroundImage = null;
        
        //backgroundImage = loadImage("menu.png");
        //backgroundImage.filter(BLUR, 6);
        
        /*
        minim = new Minim(stenras_mall_del3.this);
        music = minim.loadFile("05_Come_and_Find_Me.mp3");
        */
        
        keyWasReleased = true;
    }
    
    public void add(String text)
    {
        menuItems.append(text);    
    }
    
    public void changeItem(int idx, String text)
    {
        menuItems.set(idx, text);
    }
    
    public void playMusic()
    {
        music.rewind();
        music.play();
    }
    
    public void moveUp()
    {
        if (selectedMenu>0)
            selectedMenu--;
        else
            selectedMenu = menuItems.size()-1; 
    }
    
    public void moveDown()
    {
        if (selectedMenu<menuItems.size()-1)
            selectedMenu++;
        else
            selectedMenu = 0;         
    }
        
    public void selectMenuItem(int idx)
    {
        
    }
    
    public int selected()
    {
        return chosenMenuItem;    
    }
    
    public boolean isSelected()
    {
        return (chosenMenuItem != -1);    
    }
    
    public void reset()
    {
        chosenMenuItem = -1;    
    }

    public void stopMusic()
    {
        music.pause();    
    }
    
    public void checkKeys()
    {
        if (keyPressed)
        {
            // Vänta tills dess att spelaren släpper tangenten innan 
            // vi går vidare.
            
            if (keyWasReleased)
            {
                // Sätt flaggan att tangenten fortfarande är nedtryckt.
                
                keyWasReleased = false;
                    
                switch(keyCode) 
                {
                    case UP:
                        moveUp();
                        break;                    
                    case DOWN:
                        moveDown();
                        break;
                    case RETURN:
                    case ENTER:
                        chosenMenuItem = selectedMenu;
                        break;
                        
                }
            }
        }
        else
            keyWasReleased = true;
    }
   
    public void draw()
    {
        if (backgroundImage!=null)
            image(backgroundImage, 0, 0, width, height);
            
        textFont(menuFont);
        textAlign(CENTER, TOP);
        
        fill(0);
        text(title, width/2+10, 20+10);
        fill(255);
        text(title, width/2, 20);
        
        for (int i=0; i<menuItems.size(); i++)
        {
            if (i == selectedMenu)
                textSize(80);
            else
                textSize(60);

            fill(0);
            text(menuItems.get(i), width/2+10, height/2 - 60*4/2 + i*80+10);

            if (i == selectedMenu)
                fill(255);
            else
                fill(180);
    
            text(menuItems.get(i), width/2, height/2 - 60*4/2 + i*80);
        }
    }
}
    