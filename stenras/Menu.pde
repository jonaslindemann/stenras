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
    
    public Menu()
    {
        title = "Stenras!";
        
        menuItems = new StringList();
        
        selectedMenu = 0;
        
        menuFont = createFont("Bangers.ttf",100,true);
        backgroundImage = loadImage("menu.png");
        backgroundImage.filter(BLUR, 6);
        
        minim = new Minim(stenras.this);
        music = minim.loadFile("05_Come_and_Find_Me.mp3");
    }
    
    public void addMenuItem(String text)
    {
        menuItems.append(text);    
    }
    
    public void changeMenuItem(int idx, String text)
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

    public void stopMusic()
    {
        music.pause();    
    }
   
    public void draw()
    {
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
    