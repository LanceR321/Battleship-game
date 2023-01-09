// Lance Reyes
//  RedID: 823963277
//  COMPE 271 project
//  5/2/21



#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void printGrid(int x);
void set_zero(int array[8][8], int rows, int columns);
void set_space(char array[8][8], int rows, int columns);
void display(int array[8][8]);
void display_char(char array[8][8]);
int combo_check(int combo, int cannonballs);

void set_elements(int array[8][8], int targets, int mines, int subtract_cannon);

void rules();


int main( ) {
    
    
    printf("Welcome to Battleship \n");
    rules();
    
    printf("\n");
    
    int cannonballs = 30;
    int targets = 15;           //1   # of targets
    int game_over = 3;          //2   game over
    int subtract_cannon = 8;    //3   will remove cannonballs from user
    
    int input_row =0;
    int input_column=0;
    int rows = 8;
    int columns = 8;
    int combos = 0;
    int hits = 0;
    int subtract =0;
    
    char hit = '*';
    char miss = 'X';
    char mine = '!';
    char lost_cannon = '-';

    int play_again = 1;
    
    while (play_again == 1) {
    
    int array1 [rows][columns]; // array that has target locations/ mines etc
    char play_array[rows][columns];
    
    set_zero( array1,rows,columns);
    set_space(play_array, rows, columns);
    
    printf("    0   1   2   3   4   5   6   7\n");
    display_char(play_array);
    set_elements(array1, targets, game_over, subtract_cannon);
    //display(array1);  // test code, displays the integer array
     
    while (cannonballs != 0) {
   
    printf("Number of cannonballs left: %d \n", cannonballs);
    printf("%d of 15 targets hit \n", hits);
        
    printf("Combos: %d \n", combos);
        
    cannonballs = combo_check(combos,cannonballs);
   
    printf("Enter a row range 0-7: \n");
    scanf("%d", &input_row);
    
    printf("Enter a column range 0-7: \n");
    scanf("%d", &input_column);
        
        
    if (array1[input_row][input_column] == 1) {
        play_array[input_row][input_column] = hit;
        array1[input_row][input_column] = 5;        // 5 means coordinate was selected prior
        cannonballs--;
        combos++;
        hits++;
        
        if (hits == targets) {
            printf(" All targets destroyed: WINNER! ");
            break;
        }
        
    }
    
    if (array1[input_row][input_column] == 0) {
        play_array[input_row][input_column] = miss;
        array1[input_row][input_column] = 5;
        combos = 0;
        cannonballs--;
    }
        
        if (array1[input_row][input_column] == 3) {
                play_array[input_row][input_column] = lost_cannon;
                array1[input_row][input_column] = 5;
                combos = 0;
                subtract = rand() % 4;
            
                if(subtract == 0){
                subtract++;
                }
            cannonballs = cannonballs - subtract;
            printf("We lost %d cannonball(s)! \n" , subtract);
            }
            
        
    if (array1[input_row][input_column] == 2) {
        play_array[input_row][input_column] = mine;
        printf("    0   1   2   3   4   5   6   7\n");
        display_char(play_array);
        printf("Mine was hit, game over! \n");
        break;
    }
        
    rules();
    printf("\n");
    printf("    0   1   2   3   4   5   6   7\n");
    display_char(play_array);
  
    }
    
        
    if (cannonballs == 0 ) {
        printf("Not all targets found: YOU LOSE! \n");
        cannonballs = 30;
        combos = 0;
        hits = 0;

        
    }
    
    printf("Do you want to play again? \n ");
    printf("Press 0 for no  \n ");
    printf("Press 1 for yes  \n ");
    scanf("%d", &play_again);
        
        if( play_again == 1) {
         cannonballs = 30; // reset values
         combos = 0;
         hits = 0;
            
        }
        
    } // end of while play again
    
    printf("Program has ended.Thanks for playing! \n");
    
    return 0;
}




void printGrid(int x) {     //function prints the gridlines
    
    int row_num = 0;
    
    if (x ==1) {            // input 1 prints a horizontal line
        printf("  ---------------------------------");
    }

    if (x == 2) {            // input 2 finishes off the line and creates a newline
        printf("\n");
    }
    
    if (x==3 ) {
        printf("| ");         // at the end of a row end off with a | and create a newline for next row
        printf("\n");
    }
    
    if (x ==4) {               // input 4 creates the left line | before the array display
        printf("| ");
        row_num++;
    }
    
}

void set_zero(int array[8][8], int rows, int columns) { // intilizes array to zeros
    
    for (int x = 0; x < rows; x++) {
        
        for( int i= 0; i < columns; i++) {
            int zero = 0;
            array[x][i] = zero;

        }
    }
}

void display(int array[8][8]) {  // when called it shows the grid along with each element of the array
    
    printGrid(1);
    printGrid(2);
    int rows = 8;
    int columns = 8;

    for (int x = 0; x < rows; x++) {
        
        for( int i= 0; i < columns; i++) {
            printGrid(4);
            printf ("%d ", array[x][i]);
        }
        printGrid(3);
        printGrid(1);
        printGrid(2);
    }
    
}

void set_space(char array[8][8], int rows, int columns) {   // intilizes char array to whitespace
    
    for (int x = 0; x < rows; x++) {
        
        for( int i= 0; i < columns; i++) {
            char space = ' ';
            array[x][i] = space;

        }
    }
    
    
}


void display_char(char array[8][8]) {
    int row_num=0;
    printGrid(1);
    printGrid(2);
    printf("%d ", row_num);
    row_num++;
    int rows = 8;
    int columns = 8;

    for (int x = 0; x < rows; x++) {
        
        for( int i= 0; i < columns; i++) {
            printGrid(4);
            printf ("%c ", array[x][i]);

        }
        printGrid(3);
        printGrid(1);
        printGrid(2);
        
        if (row_num <8 ){
        printf("%d ", row_num);
        row_num++;
        }
    
    }
}
    
void set_elements(int array[8][8], int targets, int game_over, int subtract_cannon) {
    srand(time(0));
    int row = 0;
    int column = 0;
    int value = 0;
    int y_count = 0;
    int x_count = 0;
    int z_count = 0;
    
    while (column != 8 ) {
        
        value = rand() % 4;
    
            if ( row == 8) {
                row = 0;
                column++;
            }
       
            if (x_count != targets) {
                if (value == 1) {
                    array[row][column] = value;
                    x_count++;
                    }
                
                }
            
            if (y_count != game_over) {
                    if (value == 2) {
                        array[row][column] = value;
                        y_count++;
                        }
                }
            
            if (z_count != subtract_cannon) {
                    if (value == 3) {
                        array[row][column] = value;
                        z_count++;
                        }
                    }
        
                
            row++;
       
    } // end of while loop
    
    
    for (int t = 0; t < row; t++) { // pads extra 1's / targets when while loop comes short
        
        for( int i= 0; i < column; i++) {
           
            if (array[t][i] == 0) {
                array[t][i] = 1;
                x_count++;
                if (x_count >= 15){
                    break;
                }
            }

        }
        
    }
    
}

void rules() {
    
    printf("\n");
    printf("'*' == target hit \n");
    printf("'X' == miss \n");
    printf("'-' == cannonball(s) deducted \n");
    printf("'!' == game over \n");
    printf("Symbols can't be hit again");
}

int combo_check(int combos, int cannonballs) {
    
    if ((combos == 3) || (combos == 6) ) {
        if (combos == 3){
            cannonballs++;
            printf("%d combo rewards +1 cannonball \n", combos);
            
        }
        if (combos == 6){
            cannonballs= cannonballs + 3;
            printf("%d combo rewards +3 cannonball \n", combos);
        
    }
    
}
    return cannonballs;
}
