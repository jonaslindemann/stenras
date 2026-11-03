# Del 4 – Fallande stenar

I Del 3 fick vi rutinen **moveBoulders()** färdigskriven. I denna del skall vi skriva den själva från grunden. Stenarna är det som gör Stenras! till ett spel – utan dem är det bara en labyrint med diamanter.

Samtidigt lär vi oss några viktiga saker inom spelprogrammering:

* Hur man **simulerar en värld** i ett rutnät med några få enkla regler.
* Varför **ordningen** man uppdaterar saker i spelar roll.
* Hur man håller reda på **tillstånd** som inte syns i rutnätet, t.ex. om en sten är på väg nedåt.

!!! info "Ladda ner mallen"

    Till denna del använder du mallen **stenras_mall_del4.zip**. Den innehåller lösningen från Del 3, men **moveBoulders()** i fliken **Game** är tom.

    [:material-download: Ladda ner stenras_mall_del4.zip](downloads/stenras_mall_del4.zip){ .md-button .md-button--primary }

    Se [Ladda ner kod](nedladdning.md) för hur du öppnar mallen i Processing.

## Reglerna för en sten

Innan vi skriver någon kod bestämmer vi hur en sten skall bete sig. Varje gång stenarna uppdateras tittar vi på varje sten för sig och använder den första regel som passar:

1. **Tomt under** – stenen faller ett steg nedåt.
1. **Spelaren under** – om stenen var på väg nedåt träffar den spelaren och spelet är slut.
1. **Något runt under** – om stenen ligger på en annan sten eller en diamant rullar den åt sidan, om det finns plats.
1. **Annars** – stenen ligger still.

I figurerna nedan betyder `o` en sten, `.` tomrum, `#` vägg och `P` spelaren.

```
Regel 1          Regel 3
###     ###      ...     ...
#o#  -> #.#      .o.  -> o..
#.#     #o#      .o.     .o.
```

!!! info "Cellautomater"

    En värld i ett rutnät där varje cell ändras efter enkla regler som bara beror på cellerna runt omkring kallas en **cellautomat**. Det mest kända exemplet är [Game of Life](https://sv.wikipedia.org/wiki/Game_of_Life). Samma idé används i många spel för att simulera sand, vatten, eld och fallande saker.

## Hur ofta skall stenarna flyttas?

**moveBoulders()** anropas från **draw()**, alltså ungefär 60 gånger per sekund. Om stenarna flyttades varje gång skulle de rasa ned blixtsnabbt. Vi använder därför en räknare, **moveCounter**, och flyttar bara stenarna var **boulderMoveRate**:e gång. Båda variablerna finns redan i **Game**-klassen.

Börja med att skriva följande i **moveBoulders()**:

```java
void moveBoulders()
{
    // Om spelet är slut flyttar vi inte stenarna längre.
    
    if (isOver)
        return;
        
    // Stenarna flyttas bara var boulderMoveRate:e gång rutinen 
    // anropas, annars skulle de falla alldeles för snabbt.
    
    moveCounter++;
    
    if (moveCounter < boulderMoveRate)
        return;
        
    moveCounter = 0;
    
    // Här kommer koden som flyttar stenarna.
}
```

**return** avslutar metoden direkt. Det gör koden lättare att läsa än att lägga allt inne i stora if-satser.

## Regel 1 – Stenar som faller

Vi skriver en egen metod, **updateBoulder(row, col)**, som tar hand om en enda sten. Då blir **moveBoulders()** kort och tydlig. Lägg till följande i **Game**-klassen:

```java
void updateBoulder(int row, int col)
{
    // Regel 1 - Tomt under stenen. Stenen faller ett steg.
    
    if (map[row+1][col] == EMPTY)
    {
        map[row][col] = EMPTY;
        map[row+1][col] = BOULDER;
    }
}
```

Sedan går vi igenom hela grottan i **moveBoulders()** och anropar **updateBoulder()** för varje sten. Ytterkanterna i grottan är alltid väggar, så dem hoppar vi över. Då behöver vi aldrig oroa oss för att titta utanför rutnätet när vi skriver `row+1`, `col-1` eller `col+1`.

```java
    // Här kommer koden som flyttar stenarna.
    
    for (int row = 1; row < nRows-1; row++)
        for (int col = 1; col < nCols-1; col++)
            if (map[row][col] == BOULDER)
                updateBoulder(row, col);
```

!!! example "Uppgift 1 – Vad händer?"

    Kör spelet och gräv bort gruset under en sten. Hur faller stenen? Faller den ett steg i taget, eller hamnar den direkt på botten?

### Ordningen spelar roll

Stenen hamnar direkt på botten! Varför?

Vi går igenom grottan **uppifrån och ned**. När stenen på rad 5 flyttas till rad 6 kommer loopen strax till rad 6 – och där hittar den samma sten igen och flyttar den till rad 7, och så vidare. Stenen flyttas många gånger under en och samma uppdatering.

Lösningen är att gå igenom grottan **nerifrån och upp**. En sten som faller hamnar då på en rad som vi redan har tittat på, och den flyttas bara en gång. Ändra den yttre loopen till:

```java
    // Gå igenom grottan nerifrån och upp. Annars skulle en sten
    // som flyttats ett steg ned hittas igen på nästa rad och falla
    // hela vägen till botten på en gång.
    
    for (int row = nRows-2; row >= 1; row--)
        for (int col = 1; col < nCols-1; col++)
            if (map[row][col] == BOULDER)
                updateBoulder(row, col);
```

!!! example "Uppgift 2 – Hastighet"

    Ändra **boulderMoveRate** i konstruktorn för **Game** till 2, 10 och 30. Hur påverkar det spelet? Vilket värde tycker du ger bäst spelkänsla?

## Regel 2 – Spelaren blir träffad

Nu vill vi att en sten som faller på spelaren avslutar spelet. Men vi måste vara försiktiga: om spelaren gräver sig in **under** en sten som ligger still, skall spelaren inte dö. Det är bara stenar som är **på väg nedåt** som är farliga.

Om en sten faller eller inte syns inte i rutnätet – där står det bara **BOULDER**. Vi behöver alltså spara den informationen någon annanstans. Vi lägger till ett nytt rutnät med **boolean**-värden, ett för varje cell, i **Game**-klassen:

```java
    boolean isOver;
    boolean isCompleted;
    
    // Håller reda på vilka stenar som är på väg nedåt.
    
    boolean[][] falling;
```

och skapar det i konstruktorn, efter `isOver = false;`:

```java
        falling = new boolean[nRows][nCols];
```

Alla värden i en ny **boolean**-array är **false** från början.

För att slippa upprepa samma kod flera gånger skriver vi en hjälpmetod som flyttar en sten:

```java
void moveBoulder(int fromRow, int fromCol, int toRow, int toCol)
{
    // Flyttar en sten från en cell till en annan.
    
    map[fromRow][fromCol] = EMPTY;
    map[toRow][toCol] = BOULDER;
    
    falling[fromRow][fromCol] = false;
}
```

Nu kan vi bygga ut **updateBoulder()**. När stenen faller markerar vi den som fallande. Om det inte är tomt under stenens nya plats slår den i något, och då spelar vi ett ljud direkt så att det hörs samtidigt som stenen landar. Om en fallande sten har spelaren under sig är spelet slut. Om stenen inte kan röra sig ligger den still.

```java
void updateBoulder(int row, int col)
{
    // Regel 1 - Tomt under stenen. Stenen faller ett steg.
    
    if (map[row+1][col] == EMPTY)
    {
        moveBoulder(row, col, row+1, col);
        falling[row+1][col] = true;
        
        // Slår stenen i något spelar vi ljud direkt. Träffas 
        // spelaren tar regel 2 hand om det.
        
        if ((map[row+2][col] != EMPTY) && (map[row+2][col] != PLAYER))
            boulderSound.trigger();
            
        return;
    }
    
    // Regel 2 - En fallande sten träffar spelaren. Spelet är slut.
    
    if ((map[row+1][col] == PLAYER) && (falling[row][col]))
    {
        boulderSound.trigger();
        isOver = true;
        return;
    }
    
    // Regel 4 - Stenen ligger still.
    
    falling[row][col] = false;
}
```

!!! example "Uppgift 3 – Testa farorna"

    1. Gräv dig in under en sten som ligger still. Överlever du?
    1. Gräv bort gruset under en sten och ställ dig sedan under den. Vad händer?
    1. Prova att springa förbi under en sten som faller. Hinner du?

!!! tip "Tillstånd utanför rutnätet"

    **falling** är ett exempel på att ett spelobjekt kan ha *tillstånd* som inte syns i bilden. I större spel brukar man därför låta varje sak vara ett eget objekt med egna variabler. I vårt rutnät är en extra array ett enkelt sätt att göra samma sak.

## Regel 3 – Stenar som rullar

I klassiska grottspel ligger stenar inte staplade på varandra – de rullar av åt sidan. Vi skriver först en metod som avgör vad stenar kan rulla av:

```java
boolean isRound(int cellType)
{
    // Stenar kan rulla av saker som är runda, dvs andra stenar
    // och diamanter.
    
    return (cellType == BOULDER) || (cellType == DIAMOND);
}
```

En sten rullar åt vänster om både cellen till vänster och cellen snett nedanför till vänster är tomma. Annars provar vi åt höger. Lägg till detta i **updateBoulder()**, mellan regel 2 och regel 4:

```java
    // Regel 3 - Stenen ligger på något runt. Den rullar åt sidan
    // om det är tomt både bredvid och snett nedanför.
    
    if (isRound(map[row+1][col]))
    {
        if ((map[row][col-1] == EMPTY) && (map[row+1][col-1] == EMPTY))
        {
            moveBoulder(row, col, row, col-1);
            return;
        }
        
        if ((map[row][col+1] == EMPTY) && (map[row+1][col+1] == EMPTY))
        {
            moveBoulder(row, col, row, col+1);
            return;
        }
    }
```

!!! example "Uppgift 4 – Vänster och höger"

    Sänk **boulderMoveRate** till 30 så att stenarna rör sig långsamt. Bygg en situation där en sten rullar åt vänster och en där en sten rullar åt höger. Ser du någon skillnad på hur de rör sig?

### En sten – en flytt

En sten som rullar åt **vänster** flyttar först ett steg åt sidan och faller sedan vid nästa uppdatering. En sten som rullar åt **höger** ser i stället ut att hoppa snett nedåt på en gång. Varför?

Det är samma problem som tidigare, fast i sidled. Loopen går igenom kolumnerna från vänster till höger. När en sten rullar till höger hamnar den i kolumnen som loopen tittar på härnäst – och där hittar vi stenen igen och låter den falla.

Den här gången kan vi inte bara vända på loopen, för då skulle problemet uppstå åt vänster i stället. Vi löser det med en regel som gäller i nästan alla simuleringar: **varje sak får bara flyttas en gång per uppdatering**. Vi lägger till ännu en **boolean**-array som håller reda på vilka celler som redan har flyttats:

```java
    // Håller reda på vilka celler som redan har flyttats i
    // nuvarande uppdatering.
    
    boolean[][] moved;
```

Skapa den i konstruktorn på samma sätt som **falling**:

```java
        moved = new boolean[nRows][nCols];
```

I **moveBoulder()** markerar vi att stenen har flyttats:

```java
    falling[fromRow][fromCol] = false;
    moved[toRow][toCol] = true;
```

I **moveBoulders()** nollställer vi **moved** innan loopen och hoppar över stenar som redan har flyttats:

```java
    // Nollställ vilka stenar som har flyttats.
    
    moved = new boolean[nRows][nCols];
    
    // Gå igenom grottan nerifrån och upp. ...
    
    for (int row = nRows-2; row >= 1; row--)
        for (int col = 1; col < nCols-1; col++)
            if ((map[row][col] == BOULDER) && (!moved[row][col]))
                updateBoulder(row, col);
```

Nu rullar stenarna likadant åt båda hållen.

??? note "Hela koden för stenarna"

    ```java
    boolean isRound(int cellType)
    {
        return (cellType == BOULDER) || (cellType == DIAMOND);
    }
    
    void moveBoulder(int fromRow, int fromCol, int toRow, int toCol)
    {
        map[fromRow][fromCol] = EMPTY;
        map[toRow][toCol] = BOULDER;
        
        falling[fromRow][fromCol] = false;
        moved[toRow][toCol] = true;
    }
    
    void updateBoulder(int row, int col)
    {
        if (map[row+1][col] == EMPTY)
        {
            moveBoulder(row, col, row+1, col);
            falling[row+1][col] = true;
            
            // Slår stenen i något spelar vi ljud direkt. Träffas 
            // spelaren tar regel 2 hand om det.
            
            if ((map[row+2][col] != EMPTY) && (map[row+2][col] != PLAYER))
                boulderSound.trigger();
                
            return;
        }
        
        if ((map[row+1][col] == PLAYER) && (falling[row][col]))
        {
            boulderSound.trigger();
            isOver = true;
            return;
        }
        
        if (isRound(map[row+1][col]))
        {
            if ((map[row][col-1] == EMPTY) && (map[row+1][col-1] == EMPTY))
            {
                moveBoulder(row, col, row, col-1);
                return;
            }
            
            if ((map[row][col+1] == EMPTY) && (map[row+1][col+1] == EMPTY))
            {
                moveBoulder(row, col, row, col+1);
                return;
            }
        }
        
        falling[row][col] = false;
    }

    void moveBoulders()
    {
        if (isOver)
            return;
            
        moveCounter++;
        
        if (moveCounter < boulderMoveRate)
            return;
            
        moveCounter = 0;
        
        moved = new boolean[nRows][nCols];
        
        for (int row = nRows-2; row >= 1; row--)
            for (int col = 1; col < nCols-1; col++)
                if ((map[row][col] == BOULDER) && (!moved[row][col]))
                    updateBoulder(row, col);
    }
    ```

    Hela lösningen finns i [stenras_losning_del4.zip](downloads/stenras_losning_del4.zip).

## Utmaningar

!!! example "Utmaning 1 – Rulla av väggar (lätt)"

    Ändra **isRound()** så att stenar även rullar av väggar. Blir spelet roligare eller svårare?

    *Tips:* Just nu finns det bara väggar runt kanten av grottan, och där är cellen snett nedanför alltid också en vägg. Skriv en metod **createInnerWalls()** som sätter ut några väggblock inne i grottan med **placeRandom()**, så att stenarna har något att rulla av.

!!! example "Utmaning 2 – Fallande diamanter (medel)"

    I klassiska grottspel faller diamanter precis som stenar. Gör om **moveBoulder()** och **updateBoulder()** så att de fungerar för både **BOULDER** och **DIAMOND**.

    *Tips:* Läs av vad som finns i cellen med `int cellType = map[row][col];` och skriv `cellType` i stället för `BOULDER`. Vad skall hända när en fallande diamant landar på spelaren?

!!! example "Utmaning 3 – Knuffa stenar (svår)"

    Låt spelaren knuffa en sten åt sidan om det är tomt på andra sidan stenen. Ändringen görs i **movePlayer()**. Knuffar man bara åt vänster och höger, eller även uppåt och nedåt? Varför?

!!! example "Utmaning 4 – Ras! (svår)"

    När en sten landar på spelaren skulle det kunna bli en explosion som spränger bort allt grus och alla stenar i en 3×3-ruta runt spelaren. Hur skulle du göra det? Behöver du ett nytt celltillstånd för att visa explosionen under några uppdateringar?

!!! tip "Lösningsförslag till utmaningarna"

    Försök själv först! Vill du se hur alla fyra utmaningarna kan lösas finns de i [stenras_utmaningar_del4.zip](downloads/stenras_utmaningar_del4.zip). Leta efter kommentarerna som börjar med **Utmaning** i fliken **Game**.
