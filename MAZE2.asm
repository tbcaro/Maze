
;Travis Caro
;CIS 253 
;
;MAZE (II)
;
;   Create an array to represent the Maze
;   Print and display the array in proper format as a navigatable Maze
;   
;   Create a pointer to the 'Man' in the maze
;   Use interupt to gather user input and compare
;   Based on user input, check where user wants to go and if that is possible
;       If path then move 'man' and cursor position. Redraw man and leave 'bread crumb'
;   
;       If wall then do not move pointer or cursor position and 'beep'
        



include 'emu8086.inc'

org 100h  

jmp MAIN

MAZE    DB	1,1,1,1,1,1,1,1,1,1,1,1,4
        DB	1,3,0,0,0,0,0,0,0,0,0,1,4
        DB	1,0,1,0,1,1,1,1,1,1,0,1,4
        DB	1,0,1,0,1,0,0,1,0,1,1,1,4
        DB	1,0,0,0,0,1,0,0,0,1,0,1,4
        DB	1,0,1,1,1,1,1,1,0,0,0,1,4
        DB	1,0,1,0,0,0,0,1,0,1,0,1,4
        DB	1,0,1,0,1,1,0,1,0,1,0,1,4
        DB	1,0,1,0,2,1,0,0,0,1,0,1,4
        DB	1,0,1,1,1,1,1,1,1,1,0,1,4
        DB	1,0,0,0,0,0,0,0,0,0,0,1,4
        DB	1,1,1,1,1,1,1,1,1,1,1,1,5     

;Go +13 through array to go +1 down
COLS = 13
ROWS = ($-MAZE)/COLS ; Get number of rows in MAZE Array

;'Man' will always start at top left corner of maze
;That is 1 full row (or the total number of columns) through maze +1
PTRman = MAZE + COLS + 1

;Set variables for initial position of 'man'
;Will be used for set cursor-position
x db 1
y db 1                
         
         
MAIN:

    LEA SI, MAZE
    LEA DI, PTRman
    
    CALL DRAW ;call procedure to render the maze datastructure to console                                       
     
    ; Insert Code for main functionality of the program
      
    
    MAINLOOP:
        ;Set cursor position
        GOTOXY x, y 
        
        ;Read for user input
        mov ah, 0
        int 16h
        
        ;Determine which key was pressed
        cmp ah, 11h
        je UP
        
        cmp ah, 1Eh
        je LEFT
        
        cmp ah, 1Fh
        je DOWN
        
        cmp ah, 20h
        je RIGHT
        
        ;If none of these, do nothing and jump back to loop
        jmp MAINCHECK
        
        
        UP: 
            ;Compare pointer to position directly above it
            cmp [DI-COLS], 1 
            ;If there is no wall, then jump to path code            
            jne PATHUP
            
            ;If there is a wall, beep and check again
            PUTC 07h
            jmp MAINCHECK
            
            PATHUP:
                ;Check and see if the position is the end goal, If so we're done
                cmp [DI-COLS], 2
                je DONE
                                                                   
                ;Place 'breadcrumb' where I was
                PUTC    250
                
                ;Update position variable and ptr to MAN
                sub DI, COLS
                sub y, 1
                
                ;Move cursor to new position and print man then check again
                GOTOXY x,y    
                PUTC    001
                
                jmp MAINCHECK
        
        LEFT:
            cmp [DI-1], 1
            jne PATHLEFT
            PUTC 07h
            jmp MAINCHECK
            
            PATHLEFT:
                cmp [DI-1], 2
                je DONE
                                      
                ;Place 'breadcrumb' where I was
                PUTC    250
                
                ;Update position variable and ptr to MAN    
                sub DI, 1
                sub x, 1
                
                ;Move cursor to new position and print man
                GOTOXY x, y    
                PUTC    001
                
                jmp MAINCHECK
            
        
        DOWN:
            cmp [DI+COLS], 1
            jne PATHDOWN
            PUTC 07h
            jmp MAINCHECK
            
            PATHDOWN:
                cmp [DI+COLS], 2
                je DONE
                    
                ;Place 'breadcrumb' where I was
                PUTC    250
                
                ;Update position variable and ptr to MAN
                add DI, COLS
                add y, 1
                
                ;Move cursor to new position and print man
                GOTOXY x,y    
                PUTC    001
                
                jmp MAINCHECK
            
        
        
        RIGHT:
            cmp [DI+1], 1
            jne PATHRIGHT
            PUTC 07h
            jmp MAINCHECK
            
            PATHRIGHT:
                cmp [DI+1], 2
                je DONE
                                                
                ;Place 'breadcrumb' where I was
                PUTC    250
                
                ;Update position variable and ptr to MAN    
                add DI, 1
                add x, 1
                
                ;Move cursor to new position and print man
                GOTOXY x,y    
                PUTC    001
                
                jmp MAINCHECK 
            
        
    MAINCHECK: ;Simple label that loops back to main
                ;Note* - A jump would work here with now decrement of cx
                ;but loop seems more logical/readable so I kept since I'm not using cx
        loop MAINLOOP
    
    DONE:
        ;When you reach goal, print out that the maze is completed
        GOTOXY 0, 20
        PRINT 'Congratulations! You have completed the maze!'
                       
RET
   
         
         
;Procedure to draw MAZE array
PROC DRAW                  
     
     ;Compare value of current position in array to determine what to print
     CHECK:                
        cmp [SI], 0
        je PATH 
        
        cmp [SI], 1
        je WALL
        
        cmp [SI], 2
        je GOAL
        
        cmp [SI], 3
        je MAN
        
        cmp [SI], 4
        je NEXTLINE
        
        ;This indicates the end of the array so it will jump to return
        cmp [SI], 5
        je DONECHECK 
              
    
    ;Print Space for path
    PATH:
        PUTC    32
        jmp RECHECK
    
    ;Print Wall                   
    WALL:
        PUTC    219
        jmp RECHECK 
    
    ;Print Goal    
    GOAL: 
        PUTC    6    
        jmp RECHECK     
    
    ;Print Man    
    MAN:
        PUTC    001
        jmp RECHECK    
    
    ;Go to next line                               
    NEXTLINE: 
        PRINTN 
        jmp RECHECK        
    
    ;Increment pointer to move through array and then recheck                           
    RECHECK: 
        inc SI
        loop CHECK     
                            
    DONECHECK:;RETURN
    
    ;Prints control instructions
    GOTOXY COLS+5,3
    PRINT 'W-UP'
    
    GOTOXY COLS+5,4
    PRINT 'A-LEFT'
    
    GOTOXY COLS+5,5
    PRINT 'S-DOWN'
    
    GOTOXY COLS+5,6
    PRINT 'D-RIGHT'
                                             
    RET 
    
ENDP DRAW 

    


DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
DEFINE_GET_STRING 
DEFINE_PRINT_STRING
DEFINE_SCAN_NUM
DEFINE_CLEAR_SCREEN
DEFINE_PTHIS
END
