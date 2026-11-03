final int OUTSIDE = -1;

class Map 
{   
    int[][] map;

    int cellWidth;    
    int magFac;
    
    int playerRow;
    int playerCol;    

    int nRows; 
    int nCols;
    
    int viewPortWidth;
    int viewPortHeight;
    int viewPortRow;
    int viewPortCol;
       
    public Map(int rows, int cols, int factor) 
    {
        nRows = rows;
        nCols = cols;
        cellWidth = 32;
        magFac = factor;
        
        viewPortWidth = width/(cellWidth * magFac) + 1; 
        viewPortHeight = height/(cellWidth * magFac) + 1;
        viewPortRow = 0;
        viewPortCol = 0;
                
        map = new int[nRows][nCols];
    }
                    
    int cell(int row, int col)
    {
        if ((row<0)||(row>=nRows))
            return OUTSIDE;
        if ((col<0)||(col>=nCols))
            return OUTSIDE;
            
        return map[row][col];
    }
    
    void setCell(int row, int col, int value)
    {
        map[row][col] = value;    
    }    
    
    void centerViewPort(int row, int col)
    {
        viewPortRow = row - viewPortHeight/2;
        viewPortCol = col - viewPortWidth/2;
    }
    
    void centerViewPortCol(int row, int col)
    {
        viewPortCol = col - viewPortWidth/2;
    }

    void centerViewPortRow(int row, int col)
    {
        viewPortRow = row - viewPortHeight/2;
    }
        
    void fillRect(int r0, int r1, int c0, int c1, int value)
    {
        for (int row = r0; row<=r1; row++)
            for(int col = c0; col<=c1; col++)
                map[row][col] = value;
    }
    
    void drawCell(int cellType, int x, int y)
    {
        
    }
                
    void draw()
    {
        int x, y;
        
        for (int row = viewPortRow; row<(viewPortHeight+viewPortRow); row++)
        {
            for (int col = viewPortCol; col<(viewPortWidth+viewPortCol); col++)
            {
                x = (col-viewPortCol) * cellWidth * magFac;
                y = (row-viewPortRow) * cellWidth * magFac;
                
                drawCell(cell(row, col), x, y);
            }
        }
    }          
}