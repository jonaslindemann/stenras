# Del 3 – Menyer och poäng

I denna del skall vi lägga till menyer, trillande stenar och poängräkning.

!!! info "Ladda ner mallen"

    Till denna del använder du mallen **stenras_mall_del3.zip**.

    [:material-download: Ladda ner stenras_mall_del3.zip](downloads/stenras_mall_del3.zip){ .md-button .md-button--primary }

    Se [Ladda ner kod](nedladdning.md) för hur du öppnar mallen i Processing.

## Spellägen

Det flesta spel har normalt ett antal olika lägen som man växlar mellan typiskt:

 1. Menyläge
 1. Spelläge
 1. Spel avslutat
 1. Avsluta

Vi definierar dessa i huvudprogrammet som konstanter för att lättare hålla reda på dessa i resten av programmet.

```java
// Variabler för spellägem

final int MENU = 0;
final int PLAYING = 1;
final int GAME_OVER = 2;
final int QUIT = 3;
```

Vi lägger också till en variabel som anger vilket läge vi befinner oss i:

```java
int gameMode;
```

Vi skall också lägga till en varibel för menyn:

```java
// Vår spelklass

Game game;
Menu menu; // <----
```

I setup() lägger initierar vi gameMode variabeln och meny-objektet:

```java
void setup() 
{
    // Definiera storleken på fönstret
    
    size(1024,768, P3D);
            
    // Sätt flagga för att hålla koll på när en tangent släpps upp.
    
    keyWasReleased = true;
    
    // Sätt game mode till menu
    
    gameMode = MENU;
    
    // Skapa vår meny
    
    menu = new Menu();
    menu.title = "Mitt spel";
    ...
```

Ändra menu.title till namnet på ditt spel.

Vi kan också lägga till en bakgrundsbild i meyn genom följande kod:

```java
    menu.backgroundImage = loadImage("menu.png");
```

Bildfilen som anges i loadImage(...) läggs i mappen data i sketch-foldern. **menu.png** följer med i mallen för spelet.

Menyerna i spelet läggs till genom att anropa metoden add(...) på menu-objektet. I detta läge behöver vi 2 menyalternativ, ett alterntiv för att starta spelet och ett för att avsluta spelet. Menyn för att starta spelet läggs till med följande kommando:

```java
    menu.add("Starta");
```

!!! example "Uppgift 1"

    Lägg till menyn "Avsluta".

I nästa steg skall vi dela upp **draw()** metoden i delar som motsvara våra spellägen. Vi börjar med att lägga till meny-läget:

```java
void draw()
{
    // Rensa bakgrund
    
    background(0);
    
    if (gameMode == MENU)
    {
        menu.draw();
    }
```

Koden vi skrev för spelläget skall läggas in i spelläget **PLAYING**

```java
    if (gameMode == PLAYING)
    {
        
        // Är en tangent nertryckt?
        
        if (keyPressed)
        {
            ...
        }
        else 
            keyWasReleased = true; // Om keypressed inte är sann har tangenten släppts upp.    
        
        // Rita vår grotta.
        
        game.draw();
    }
```

När vi ändå är i farten lägger vi till till spelläget **GAME_OVER** och **QUIT**:

```java
    if (gameMode == GAME_OVER)
    {
        gameMode = GAME_MENU
    }
    
    if (gameMode == QUIT)
        exit();
```

Det vi gjort nu är att dela upp **draw()** rutinen i ett antal delar som anropas beroned på vilket spelläge vi befinner oss i. Kör vi programmet nu skall en meny visas på skärmen. Menyn är dock inte aktiv. Detta skall vi ändra på i nästa steg:

## Spelmenyn

I spelmenyer brukar man kunna ändra alternativ för spelet, starta spelet och avsluta spelet. För att menyn skall fungera måste vi först lägga till ett anrop till **menu.checkKeys()**. Denna funktion hanterar val i menyn. Om ett val i menyn gjorts returnerar **menu.isSelected()** true. Vilket alternativ som valts kan man ta reda på genom att anropa **menu.selected()**. Med hjälp av dessa funktioner kan vi nu sätta ihop koden som behövs för att menyn skall kunna fungera:

```java
    if (gameMode == MENU)
    {
        // Rita upp menyn

        menu.draw();

        // Kontrollera om menyn uppdaterats med 
        // tangentbordet

        menu.checkKeys();

        // Kontrollera om ett menyval har gjorts
        
        if (menu.isSelected())
        {
            // Menyval 0 har valts (Starta spel)

            if (menu.selected()==0)
            {
                // Skapa en ny spelomgång och placera
                // spelaren

                game = new Game(20, 20, 3);
                game.placePlayer();

                // Ändra spelläget till PLAYING. Detta
                // Startar spelet nästa gång draw() anropas.
                
                gameMode = PLAYING;
                
            }    

            // Här skall menyvalet för att avsluta 
            // läggas till

            menu.reset();
        }
    }
```
 
!!! example "Uppgift 2"

    Lägg till en if-sats för alternativet avsluta.

## Poängräkning och tidtagning 

Poäng i spelet får man när man samlar ihop alla diamanter i spelet. För att göra det lite svårare kommer vi spelaren få en max tid på sig att samla alla diamanter. När tiden är slut är spelet också slut. När man klarat en nivå får man alla poäng från den tidigare nivån.

För att hantera poängräkningen lägger vi till en variabel **totalScore** och en timer för nedräkningen:

```java
Timer countDown; 

int totalScore;
```

I **setup()** initialiserar vi totalScore. Timern skapar vi när vi startar ett nytt spel.

```java
void setup() 
{
    // Definiera storleken på fönstret
    
    size(1024,768, P3D);
    
    // Nollställ totalpoäng
    
    totalScore = 0;
```

Vi måste också nollställa **totalScore** när ett nytt spel startas ifrån menyn och starta nedräkningen. i sätter tidsgränsen för en grotta till 5 minuter. Detta blir 5 * 60 * 1000 millisekunder vilket vi måste ge till vårt **Timer** objekt **countDown**.

```java
...
if (menu.selected()==0)
{
    // Nollställ poängräkning

    totalScore = 0;
    
    game = new Game(20, 20, 3);
    game.placePlayer();
    
    gameMode = PLAYING;
    
    // Starta nedräkning
    
    countDown = new Timer(5 * 60 * 1000);
    countDown.start();
    
}
...
```

## Utskrift av poängen och tid

För att visa spelets status skall vi använda ett speciellt objekt **Text**. Vi deklarerar detta objekt i vårt huvudprogram:

```java
// Vår spelklass

Game game;
Menu menu;
Timer countDown;
Text scoreText; // <-- Lägg till här
```

Vi skapar objektet i **setup()**:

```java
// Initieringsfunktion

void setup() 
{
    ...
    
    // Skapa text för poäng

    scoreText = new Text();
}
```

För att visa texten måste vi lägga till ett anrop till objektet i uppritningsfunktionen **draw()**. Uppritningen måste ske efter att vi ritat upp spelplanen med **game.draw()** annars kommer texten att skrivas över av spelplanen. I **draw()** lägger vi till:

```java
void draw()
{
    ...

    if (gameMode == PLAYING)
    {
        
        ...
        
        // Rita vår grotta.
        
        game.draw();

        // Visa poäng
        
        scoreText.setLeftTopText(countDown.prettyString());
        scoreText.setRightTopText("Diamonds: "+str(game.score)+"/"+str(game.nDiamonds));
        scoreText.setLeftBottomText("Score: "+str(totalScore));
        scoreText.setRightBottomText("");
        scoreText.draw();
        
    }
    
    ...
}
```

## Gå vidare till nästa nivå

Om man spelar spelet nu kommer man aldrig att gå vidare när man samlat alla diamanter. I de tidigare delarna satte vi en variabel **isCompleted** i **Game** objektet när alla diamanter var uppsamlade. Vi skall nu använda denna för att kontrollera om ett spel är slutfört. Efter uppritningen av poängtexten lägger vi till en if-sats som kontrollerar om nivån är klar, dvs **isCompleted** är **true**.

Om nivån är klar lägger vi till poängen för nivån till **totalScore**, och skapar en ny nivå och återstartar nedräkningen:

```java
void draw()
{
    ...

    if (gameMode == PLAYING)
    {
        
        ...
        
        // Rita vår grotta.
        
        ...

        // Är alla diamanter upplockade?        

        if (game.isCompleted)
        {
            totalScore = totalScore + game.score;
            
            game = new Game(20, 20, 3);
            game.placePlayer();
            
            gameMode = PLAYING;
            
            // Starta nedräkning
            
            countDown = new Timer(5 * 60 * 1000);
            countDown.start();            
        }                
    }
    
    ...
}
```

## Avsluta spelet när tiden är slut

Vi måste också kontrollera att nedräkningen inte kommit till noll. Om den är noll skall spelet avslutas. Vi lägger till en ytterligare if-sats efter vår förra if-sats för at kontrollera detta:

```java
void draw()
{
    ...

    if (gameMode == PLAYING)
    {
        
        ...
        
        // Rita vår grotta.
        
        ...

        // Är alla diamanter upplockade?

        if (game.isCompleted)
        {
            ...
        }                

        // Är nedräkningen 0

        if (countDown.isFinished())
            gameMode = GAME_OVER;        
    }
    
    ...
}
```

## Hantera att spelet är slut

När spelet är slut, dvs när **gameMode = GAME_OVER**, måste vi visa detta på något sätt för användaren. För att göra detta definierar vi först ett ytterligare **Text** objekt i huvudprogrammet:

```java
// Vår spelklass

Game game;
Menu menu;
Timer countDown;
Text scoreText;
Text gameOverText; // <-- Lägg till 

int totalScore;
```

Vi skapar objektet i **setup()**:

```java
void setup() 
{

    ...

    // Skapa text för poäng
    
    scoreText = new Text();
    
    // Skapa text för game over skärm
    
    gameOverText = new Text();
    gameOverText.setCenterText("Game Over");    
}
```

För att se till att texten visas måste vi uppdatera if-satsen för GAME_OVER vi skapade tidigare. Först ritar vi upp spelplanen där spelet avslutades. Sen ritar vi upp poängen och game over texten. Vi väntar också på att användaren skall trycka på en tangent för att gå tillbaka till menyn GAME_MENU.

```java
void draw()
{
    ...

    if (gameMode == PLAYING)
    {
        ...
    }
    
    if (gameMode == GAME_OVER)
    {
        // Rita upp nivån 

        game.draw();

        // Rita upp poängen

        scoreText.draw();

        // Rita "Game Over"

        gameOverText.draw();

        // Vänta på en tangent
                
        if (keyPressed)
            if (keyWasReleased)
                gameMode = MENU;
        else
            keyWasReleased = true;
    }

    ...
}
```

## Göra spelet svårare - Rörliga stenar

I mallkoden som finns på nätet finns en extra rutin i **Game**-objektet **moveBoulders()**. Denna rutin kollar alla blocken i nivån om det finns tomrum under eller vid sidan om dem. Om det finns tomrum så flyttas blocket. Rutinen kontrollerar också om spelaren finns under ett block. Om så är fallet sätts **isOver** variabeln i **Game**-objektet till true och spelet är slut. Hastigheten på blocken styrs av variabeln **boulderMoveRate**. 

För att få det hela att fungera anropar vi rutinen för varje uppritining i PLAYING.

```java
void draw()
{
    ...

    if (gameMode == PLAYING)
    {
        
        ...

        // Flytta blocken

        game.moveBoulders();
        
        // Rita vår grotta.
            
        game.draw();

        
    }
    
    ...
}
```

Vi måste också uppdatera vår if-sats för när spelet är slut till:

```java
void draw()
{
    ...

    if (gameMode == PLAYING)
    {

        ...        

        // Är nedräkningen 0 eller vi blev träffade av ett block

        if ((game.isOver)||(countDown.isFinished()))
            gameMode = GAME_OVER;        
    }
    
    ...
}
```

!!! example "Uppgift 3 – Experimentera med moveBoulders"

    Ändra hastigheten på blocken genom att ändra **game.boulderMoveRate** till 5, 10 och 20. Vad händer? Kan man använda detta för att göra spelet svårare? Isåfall hur? På vilka fler sätt kan man göra spelet svårare?

!!! tip "Hur fungerar moveBoulders()?"

    I [Del 4 – Fallande stenar](del4.md) skriver vi **moveBoulders()** själva från grunden och går igenom varför den fungerar som den gör.
