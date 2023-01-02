dosseg

.model small
.stack 1024h
.286
.data

brick struct
align word
BRstrength dw 1
BRbonus dw 0
BRrow dw 0
BRcol dw 0
align byte
BRcolour db 5
brick ends

ball struct
align word
Brvelocity dw 7
Bcvelocity dw 7
Bdisplay dw 1
Brow dw 0
Bcol dw 0
align byte
Bcolour db 5
ball ends
initialballx equ 350
initialbally equ 200
Brickwidth dw 80
Brickheight dw 30

Array_of_Bricks brick <2,0,60,80,2>,<2,0,60,180,2>,<2,0,60,280,2>,<1,0,60,380,2>,<1,0,60,480,2>
                brick <1,1,120,80,2>,<1,1,120,180,5>,<1,1,120,280,5>,<1,1,120,380,5>,<1,0,120,480,5>
                brick <1,1,180,180,2>,<1,1,180,380,5>,<200,1,180,80,0>,<200,1,180,480,1Fh>
Array_of_Balls ball <4,4,1,initialballx,initialbally,4>


currentLevel dw 0
currentBricks dw 12

BallsCount dw 1
BricksCount dw 12

BrickCol DW  200
DrawPixCol DW 0
BrickRow  dw 100
DrawPixRow dw 0
BrickColor  db 5
DrawPixColor db 0


Ballcol DW  initialballx
BallRow  dw initialbally
BlackBallcol dw 0

BlackBallrow dw 0
BallColor  db 0

BallSize dw 15
;===========Collision=================
currentCol dw 0
currentRow dw 0
collided dw 0

lowerx dw 0
lowery dw 0
;============Collision=================

;----------------For timer------------------
second dw 0
syssecond db 0
timer dw 160 ; start of timer in seconds
;------------------------------------------------------
;======================Bar=================
align word
barwidth dw 100
barheight dw 15
barRow dw 430
barCol dw 300
align byte
Barcolor db 1Fh
bartempcolor db 0
align word
xtemp dw 0
ytemp dw 0

barvelocity dw 25
;=========================================




;------------------------------------------------------
align word
lives dw 3
heartsymbol dw 0403h 
;----------------------------------------------------

align byte
TradeMark db "@Khagga$"
welcome db "Click to Continue !$"
exitmsg db "Aap bohot great ho !$"
gameName db "Enter your Name: $"
levelOnemsg1 db "Name: $"
levelOnemsg2 db "Lives: $"
levelOnemsg3 db "Score: $"
levelOnemsg4 db "Timer: $"
num db 30
colour db 01010110b
mainMenu1 db "Start Game$"
mainMenu2 db "ScoreBoard$"
mainMenu3 db "Instructions$"
mainMenu4 db "Exit$"
mainMenu5 db "Resume$"

Pausemsg1 db "Game Paused$"
Pausemsg2 db "           $"

startgamemsg1 db ">>> Start New Game.$"
scoreboardmsg1 db ">>> Open the ScoreBoard of all Players.$"
instructionsmsg1 db ">>> Check out the instructions regarding playing this game.$"
exitmsg1 db ">>> Exit the Game.$"
resumemsg1 db ">>> Play as a last Player.$"
losingmsg db "Better Luck Next Time ! Meri jaan Game seekh kr ao$"
winningmsg db "Being too Happy isn't better for your health.Whatever,Nice Work$"
instructmsg db "INSTRUCTIONS$"
Instruction1 db "1- Enter Start Game if you are a new player.$"
Instruction2 db "2- Resume Game tp play as a last player.$"
Instruction3 db "3- Use Left and Right Key to move Bar.$"
Instruction4 db "4- Some Bricks have Bonus Score.$"

;----------Mouse control-----------
xcoor dw 0
ycoor dw 0
;XUL YUL XDR YDR
;------------------Menu Page Buttons--------------------------
fullScreen dw 0,0,640,480
startgamebox dw 115, 300, 210, 320
instrunctionsbox dw 105,400,215,415
resumebox dw 260,350,325,365
scoreboardBox dw 390,300,485,320
exitbox dw 415,395,460,413
;----------------Indexes of Menu buttons-----------------------
count db 0 ; keeps count of number of digits to be printed, used in output func,
;------------Mouse control--------

;----------------Display leaderboaard-----------
isName db 0
dLBcursorR db 0
dLBcursorC db 0


;----------------For score-----------
score dw 0
;----------------For file handling---------------------------
fileopened dw 0
file_name db 'score.txt&'
scoreHandler dw 0 ;file handler for score.txt
chTraversal db 0 
chTraversalcount dw 0 ;first is for traversal character, second is for traversal count
ubltemp dw 0
userSize dw 0 ;Size of username
playerName db 0 ;this variable must be at last
;------------------------------------------------------


.code
;-----------------------------------------------------
; Main Driver Function
;-----------------------------------------------------
main proc
mov ax, @data
mov ds, ax


call welcomePage
call mainMenuprint
call startinglevels


mov ah,4ch
int 21h
main endp

;--------------------------------------------------------
; Turns the Screen Background Colour to BLack
;--------------------------------------------------------
clearscreen proc uses ax dx 
mov ah,6
mov al,0

mov cx,0
mov dh,80
mov dl,80
mov bh,00
int 10h

ret
clearscreen endp

;-------------------------------------------------------------
; Checks if Mouse CLicked on the certain places or not
; Out thorugh ax     ax=1[True] -> ax=0[Fal]
;-------------------------------------------------------------
boundCheck PROC
    push bp
    mov bp,sp
    mov si,[bp+4]
    push bx
    mov ax, 0
    
    mov bx, xcoor               ; xcoor should be the coordinate of where mouse clicked 
    cmp bx, [si]      ;startgamebox should have value of  x-axis upper left   | XUL == XDL
    jl bCexit                   ;if mouse click is less than  XUL then exit  
    cmp bx, [si + 4]  ;else check for x-axis upper right | XUR == XDR 
    jg bCexit                   ;if mouse click is greater than  XUR then exit
    mov bx, ycoor               ;now do the same thing for ycoor
    cmp bx, [si + 2]  ;     
    jl bCexit
    cmp bx, [si + 6]
    jg bCexit
    mov ax, 1
    
    bCexit:
    pop bx
    pop bp
    ret 2
boundCheck endp


DrawBar proc uses cx ax 
mov ax, barCol
    mov DrawPixCol,ax
    mov ax, barRow
    mov DrawPixRow,ax
    mov al,Barcolor
    mov DrawPixColor,al

    mov cx,barheight  
    Row3:  ;Runs for each row
        push cx ;save cx
        push word ptr DrawPixCol ; save DrawPixCol


        push ax
        push bx
        mov cx,barwidth 
        MOV AL, DrawPixColor
        MOV DX, DrawPixRow
        MOV AH, 0Ch

        Col3:
         
        push cx
            MOV CX, DrawPixCol
            INT 10H

            pop cx
        
            inc DrawPixCol
        loop Col3

        pop bx
        pop ax
        inc DrawPixRow 

        pop word ptr DrawPixCol ; restore DrawPixCol
        pop cx

    loop Row3
ret
DrawBar endp
DrawBlackBall proc 

push ax
push cx
push dx
push bx
    mov ax, Ballcol
    mov DrawPixCol,ax
    mov ax, BallRow
    mov DrawPixRow,ax
    mov DrawPixColor,0

    mov cx, BallSize
    Row:  ;Runs for each row
        push cx ;save cx
        push word ptr DrawPixCol ; save DrawPixCol

        mov cx, BallSize

        push ax
        ; push bx
        MOV AH, 0Ch
        MOV AL, DrawPixColor
        MOV DX, DrawPixRow
        ; using reg for drawing instead of memory location
        ; mov bx, DrawPixCol


        Col:
        
        push cx
  
            MOV CX, DrawPixCol
            INT 10H

        pop cx
        
            inc DrawPixCol


        loop Col

        ; pop bx
        pop ax

        inc DrawPixRow 

        pop word ptr DrawPixCol ; restore DrawPixCol
        pop cx
        ; add DrawPixCol, cx
    loop Row



    
pop bx
pop dx
pop cx
pop ax
ret 
DrawBlackBall endp

DrawPixel PROC uses ax bx cx dx



    MOV AH, 0Ch
    MOV AL, DrawPixColor
    MOV CX, DrawPixCol
    MOV DX, DrawPixRow
    INT 10H

  

    ret

DrawPixel endp
DrawBall proc uses ax cx

    mov ax, Ballcol
    mov DrawPixCol,ax
    mov ax, BallRow
    mov DrawPixRow,ax
    mov al, BallColor
    mov DrawPixColor,al

    mov cx,BallSize  
    Row2:  ;Runs for each row
        push cx ;save cx
        push word ptr DrawPixCol ; save DrawPixCol


        push ax
        ; push bx
        mov cx,BallSize 
        MOV AL, DrawPixColor
        MOV DX, DrawPixRow
        MOV AH, 0Ch
        
        Col2:
         
        push cx
            MOV CX, DrawPixCol
            INT 10H

        pop cx
        
            inc DrawPixCol
        loop Col2

        ; pop bx
        pop ax
        inc DrawPixRow 

        pop word ptr DrawPixCol ; restore DrawPixCol
        pop cx

    loop Row2
ret
DrawBall endp




DrawBrick PROC Uses ax bx dx cx 


    mov ax, BrickCol
    mov DrawPixCol,ax
    mov ax, BrickRow
    mov DrawPixRow,ax
    mov al, BrickColor
    mov DrawPixColor,al

    mov cx,Brickheight  ;
    Row1:  ;Runs for each row
        push cx ;save cx
        push word ptr DrawPixCol ; save DrawPixCol

        mov cx,Brickwidth
        Col1:  
            MOV AH, 0Ch
    call DrawPixel
            inc DrawPixCol
        loop Col1

        inc DrawPixRow 

        pop word ptr DrawPixCol ; restore DrawPixCol
        pop cx

    loop Row1

ret
DrawBrick Endp

;------------------------------------------------------------------------------------
; MainMenuprint functions Displays the Main Menu Page Which includes 5 different Options
; Start Game-> For new Player        Resume-> if the user played last time as well
;------------------------------------------------------------------------------------
mainMenuprint proc uses ax dx bx 

call clearscreen
sub colour,2
cmp colour,0
jne itsok

inc colour
itsok:
call BrickBreakerPrint
;Vertical line 1
mov ah,6
mov al,0
mov BH,colour
mov ch,2  
mov cl,7  ;right
mov dh,15  ;down
mov dl,8  ;left
int 10h

;horizontal line 1
mov ah,6
mov al,0
mov BH,colour
mov ch,1  
mov cl,9  ;right
mov dh,1  ;down
mov dl,70  ;left
int 10h

add colour,2

;Printing Menus on the screen

;------------------Start Game--------------------------

mov ah,02h
mov bh,0
mov dh,19
mov dl,15
int 10h

mov dx,offset mainMenu1
mov ah,9
int 21h

;------------------ScoreBoard--------------------------

mov ah,02h
mov bh,0
mov dh,19
mov dl,50
int 10h

mov dx,offset mainMenu2
mov ah,9
int 21h

;------------------Instructions--------------------------

mov ah,02h
mov bh,0
mov dh,25
mov dl,14
int 10h

mov dx,offset mainMenu3
mov ah,9
int 21h

;------------------Exit--------------------------

mov ah,02h
mov bh,0
mov dh,25
mov dl,53
int 10h

mov dx,offset mainMenu4
mov ah,9
int 21h

;-----------------TradeMark-------------------------
mov ah,02h
mov bh,0
mov dh,0
mov dl,72
int 10h

mov dx,offset TradeMark
mov ah,9
int 21h

;-----------------Resume-------------------------
mov ah,02h
mov bh,0
mov dh,22
mov dl,34
int 10h

mov dx,offset mainMenu5
mov ah,9
int 21h

call detectMenuSelect
ret
mainMenuprint endp

;--------------------------------------------------------------------------------
; Procedure 'detectMenuSelect' transfers to the selected page through mouse click
;--------------------------------------------------------------------------------
detectMenuSelect proc uses ax dx cx bx




add colour,1
mov ax, 1  ;displaying mouse
int 33h
keepgoing:


push ax
mov ah,01     ;checking if any key pressed
int 16h
Jz nokeypressed2
mov ah,0
int 16h

cmp ah, 01h
jne notreturn
jmp welcomePagemove
;call welcomePage
nokeypressed2:
notreturn:
pop ax








mov ax, 3  
int 33h

mov xcoor, cx ;storing values in variable
mov ycoor, dx ;storing values in variable

; check status of button pressed
mov ax, 5
mov bx, 0
int 33h

cmp ax, 1
jne noleftclick
add colour,1

mov si,offset startgamebox
push si
call boundCheck ;check if cursor is in right position or not
cmp ax, 1
je startgameselected

mov si,offset resumebox
push si
call boundCheck ;check if cursor is in right position or not
cmp ax, 1
je resumeGame

mov si,offset instrunctionsbox
push si
call boundCheck ;check if cursor is in right position or not
cmp ax, 1
je displayInstructions

mov si,offset exitbox
push si
call boundCheck ;check if cursor is in right position or not
cmp ax, 1
je exitselected

mov si,offset scoreboardBox
push si
call boundCheck ;check if cursor is in right position or not
cmp ax, 1
je displayScoreBoard
noleftclick:
;-------------------------------------------------------------------------------
; Hover Functionality
;-------------------------------------------------------------------------------
mov si,offset startgamebox
push si
call boundCheck
cmp ax,1
je hover1

mov si,offset scoreboardBox
push si
call boundCheck
cmp ax,1
je hover2

mov si,offset instrunctionsbox
push si
call boundCheck
cmp ax,1
je hover3

mov si,offset exitbox
push si
call boundCheck
cmp ax,1
je hover4

mov si,offset resumebox
push si
call boundCheck
cmp ax,1
je hover5

jmp nothing
hover1:

;----------setting the cursor position
mov ah,2
mov bh,0
mov dh,29
mov dl,1
int 10h

mov dx,offset startgamemsg1
mov ah,9
int 21h
;-------resetting the cursor-------------
mov ah,2
mov bh,0
mov dh,29
mov dl,1
int 10h

;---------------------Start Button Hover--------------------------------------
mov ah,6
mov al,0
mov BH,colour
mov ch,20  
mov cl, 14  ;right
mov dh,20  ;down
mov dl,26  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,18  
mov cl, 14  ;right
mov dh,18  ;down
mov dl,26  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,18  
mov cl, 13  ;right
mov dh,20  ;down
mov dl,13  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,18  
mov cl, 26  ;right
mov dh,20  ;down
mov dl,26  ;left
int 10h
jmp done1


hover2:

;----------setting the cursor position
mov ah,2
mov bh,0
mov dh,29
mov dl,1
int 10h

mov dx,offset scoreboardmsg1
mov ah,9
int 21h
;-------resetting the cursor-------------
mov ah,2
mov bh,0
mov dh,29
mov dl,1
int 10h
;---------------------ScoreBoard Hover--------------------------------------


mov ah,6
mov al,0
mov BH,colour
mov ch,18  
mov cl, 61  ;right
mov dh,20  ;down
mov dl,61  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,18  
mov cl, 48  ;right
mov dh,20  ;down
mov dl,48  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,18  
mov cl, 48  ;right
mov dh,18  ;down
mov dl,61  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,20  
mov cl,48  ;right
mov dh,20  ;down
mov dl,61  ;left
int 10h



jmp done1


hover3:

;----------setting the cursor position
mov ah,2
mov bh,0
mov dh,29
mov dl,1
int 10h

mov dx,offset instructionsmsg1
mov ah,9
int 21h
;-------resetting the cursor-------------
mov ah,2
mov bh,0
mov dh,29
mov dl,1
int 10h
;---------------------Instruction Hover--------------------------------------

mov ah,6
mov al,0
mov BH,colour
mov ch, 24 
mov cl, 13  ;right
mov dh,24  ;down
mov dl,26  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch, 26 
mov cl, 13  ;right
mov dh,26  ;down
mov dl,26  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch, 24 
mov cl, 13  ;right
mov dh,26  ;down
mov dl,13  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch, 24 
mov cl, 26  ;right
mov dh,26  ;down
mov dl,26  ;left
int 10h

jmp done1

hover4:

;----------setting the cursor position
mov ah,2
mov bh,0
mov dh,29
mov dl,1
int 10h

mov dx,offset exitmsg1
mov ah,9
int 21h
;-------resetting the cursor-------------
mov ah,2
mov bh,0
mov dh,29
mov dl,1
int 10h
;---------------------Exit Hover--------------------------------------


mov ah,6
mov al,0
mov BH,colour
mov ch, 24 
mov cl, 58  ;right
mov dh,26  ;down
mov dl,58  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch, 24 
mov cl, 51  ;right
mov dh,26  ;down
mov dl,51  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch, 24 
mov cl, 51  ;right
mov dh,24  ;down
mov dl,58  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch, 26 
mov cl, 51  ;right
mov dh,26  ;down
mov dl,58  ;left
int 10h

jmp done1

hover5:

;----------setting the cursor position
mov ah,2
mov bh,0
mov dh,29
mov dl,1
int 10h

mov dx,offset resumemsg1
mov ah,9
int 21h
;-------resetting the cursor-------------
mov ah,2
mov bh,0
mov dh,29
mov dl,1
int 10h
;---------------------Resume Hover--------------------------------------


mov ah,6
mov al,0
mov BH,colour
mov ch, 23 
mov cl, 33  ;right
mov dh,23  ;down
mov dl,41  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch, 21 
mov cl, 33  ;right
mov dh,21  ;down
mov dl,41  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch, 21 
mov cl, 32  ;right
mov dh,23  ;down
mov dl,32  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch, 21 
mov cl, 41  ;right
mov dh,23  ;down
mov dl,41  ;left
int 10h

jmp done1

nothing:

mov si,0
;------------------------------footer--------------------------
mov ah,6
mov al,0
mov BH,00
mov ch, 29 
mov cl, 0  ;right
mov dh,29  ;down
mov dl,80  ;left
int 10h

;---------------------Resume Hover--------------------------------------


mov ah,6
mov al,0
mov BH,0
mov ch, 23 
mov cl, 33  ;right
mov dh,23  ;down
mov dl,41  ;left
int 10h

mov ah,6
mov al,0
mov BH,0
mov ch, 21 
mov cl, 33  ;right
mov dh,21  ;down
mov dl,41  ;left
int 10h

mov ah,6
mov al,0
mov BH,0
mov ch, 21 
mov cl, 32  ;right
mov dh,23  ;down
mov dl,32  ;left
int 10h

mov ah,6
mov al,0
mov BH,0
mov ch, 21 
mov cl, 41  ;right
mov dh,23  ;down
mov dl,41  ;left
int 10h



;---------------------Exit Hover--------------------------------------


mov ah,6
mov al,0
mov BH,0
mov ch, 24 
mov cl, 58  ;right
mov dh,26  ;down
mov dl,58  ;left
int 10h

mov ah,6
mov al,0
mov BH,0
mov ch, 24 
mov cl, 51  ;right
mov dh,26  ;down
mov dl,51  ;left
int 10h

mov ah,6
mov al,0
mov BH,0
mov ch, 24 
mov cl, 51  ;right
mov dh,24  ;down
mov dl,58  ;left
int 10h

mov ah,6
mov al,0
mov BH,0
mov ch, 26 
mov cl, 51  ;right
mov dh,26  ;down
mov dl,58  ;left
int 10h

;---------------------ScoreBoard Hover--------------------------------------



mov ah,6
mov al,0
mov BH,0
mov ch,18  
mov cl, 61  ;right
mov dh,20  ;down
mov dl,61  ;left
int 10h

mov ah,6
mov al,0
mov BH,0
mov ch,18  
mov cl, 48  ;right
mov dh,20  ;down
mov dl,48  ;left
int 10h

mov ah,6
mov al,0
mov BH,0
mov ch,18  
mov cl, 48  ;right
mov dh,18  ;down
mov dl,61  ;left
int 10h

mov ah,6
mov al,0
mov BH,00
mov ch,20  
mov cl,48  ;right
mov dh,20  ;down
mov dl,61  ;left
int 10h

;---------------------Start Button Hover--------------------------------------
mov ah,6
mov al,0
mov BH,00
mov ch,20  
mov cl, 14  ;right
mov dh,20  ;down
mov dl,26  ;left
int 10h

mov ah,6
mov al,0
mov BH,00
mov ch,18  
mov cl, 14  ;right
mov dh,18  ;down
mov dl,26  ;left
int 10h

mov ah,6
mov al,0
mov BH,00
mov ch,18  
mov cl, 13  ;right
mov dh,20  ;down
mov dl,13  ;left
int 10h

mov ah,6
mov al,0
mov BH,00
mov ch,18  
mov cl, 26  ;right
mov dh,20  ;down
mov dl,26  ;left
int 10h

;---------------------Instruction Hover--------------------------------------

mov ah,6
mov al,0
mov BH,0
mov ch, 24 
mov cl, 13  ;right
mov dh,24  ;down
mov dl,26  ;left
int 10h

mov ah,6
mov al,0
mov BH,0
mov ch, 26 
mov cl, 13  ;right
mov dh,26  ;down
mov dl,26  ;left
int 10h

mov ah,6
mov al,0
mov BH,0
mov ch, 24 
mov cl, 13  ;right
mov dh,26  ;down
mov dl,13  ;left
int 10h

mov ah,6
mov al,0
mov BH,0
mov ch, 24 
mov cl, 26  ;right
mov dh,26  ;down
mov dl,26  ;left
int 10h
;---------------------Start Button Hover--------------------------------------

done1:

mov ax, 1  ;displaying mouse
int 33h

mov ax, 5
mov bx, 0
int 33h
;pop ax ;instead of calling 33h getting value again

cmp ax, 2
jne keepgoing

exitselected:
call ExitPage

resumeGame:
call resume
call startinglevels

startgameselected:
call startgamepage

returnmainmenu:
call mainMenuprint

displayScoreBoard:
call displayLeaderBoard 

displayInstructions:
call instructionPage




ret

detectMenuSelect endp


;description
displayPause PROC
    pusha
    checkingreturn:
    mov ah,01     ;checking if any key pressed
    int 16h
    Jz nokeypressed3
    mov ah,0
    int 16h

    cmp ah, 01h
    jne notmain
    jmp returnmainmenu
    nokeypressed3:
    notmain:

    jmp checkingreturn
    popa
ret
displayPause ENDP


instructionPage proc
;Changing Page Numebr to 2
mov ah,05h 
mov al,2
int 10h

;Setting Video mode in new page
mov ah,0
mov al,12h
int 10h

mov ah,6
mov al,0
mov cx,0
mov dh,80
mov dl,80
mov bh,00
int 10h

;----------Title------------
mov ah,2
mov dh,1
mov dl,32
int 10h

mov dx,offset instructmsg
mov ah,9
int 21h

;----------------------------------------

mov ah,2
mov dh,9
mov dl,19
int 10h

mov dx,offset Instruction1
mov ah,9
int 21h

mov ah,2
mov dh,11
mov dl,19
int 10h

mov dx,offset Instruction2
mov ah,9
int 21h

mov ah,2
mov dh,13
mov dl,19
int 10h

mov dx,offset Instruction3
mov ah,9
int 21h

mov ah,2
mov dh,15
mov dl,19
int 10h

mov dx,offset Instruction4
mov ah,9
int 21h
stay:
mov ah,0
int 16h

cmp ah, 01h
jne stay
mov colour,5
call mainMenuprint

ret
instructionPage endp
;---------------------------------------------------------------
; Procedure 'ExitPage' Displays the last page after game ends
;---------------------------------------------------------------
ExitPage proc uses ax dx bx cx
call clearscreen
;Changing Page Numebr to 2
mov ah,05h 
mov al,2
int 10h

;Setting Video mode in new page
mov ah,0
mov al,12h
int 10h

;Setting the backgorund of the screen to black
mov ah,6
mov al,0
mov cx,0
mov dh,80
mov dl,80
mov bh,00
int 10h

;setting the position of the cursor
mov ah,2
mov dh,14
mov dl,28
int 10h

;Printing the message
mov dx,offset exitmsg
mov ah,9
int 21h

;Resetting Curson Position
mov ah,2
mov dh,0
mov dl,0
int 10h

mov ax, 0  ;Removing mouse [pointer]
int 33h

mov ah,4ch ;Exiting program
int 21h
ret
ExitPage endp

;-----------------------------------------------------------------
; Procedure 'StartGamePage' displayes all the graphics of the start game
; calls procedurs like 'BrickBreakerPrint'
;------------------------------------------------------------------

startgamepage proc uses ax dx cx bx

mov lives,3
call clearscreen
mov al,1
add colour,al


;Changing Page Numebr to 2
mov ah,05h 
mov al,2
int 10h



mov di,offset Array_of_Bricks
mov cx,BricksCount

enteringValues:


mov [di].BRstrength,1
mov [di].BRcolour,3



add di,sizeof brick
loop enteringValues


;Setting Video mode in new page
mov ah,0
mov al,12h
int 10h

call BrickBreakerPrint
sub colour,10

mov ax, 0  ;Removing mouse [pointer]
int 33h

;setting the position of the cursor
mov ah,2
mov dh,22
mov dl,24
int 10h

;Printing the message
mov dx,offset gameName
mov ah,9
int 21h

;setting the position of the cursor
mov ah,2
mov dh,22
mov dl,41
int 10h
mov cx,0
call takeuserName
mov userSize,cx
mov cx,0
call startinglevels

ret
startgamepage endp



startinglevels proc uses ax dx bx cx di

mov BricksCount,12
mov ax,BricksCount
mov currentBricks,ax

mov di,offset Array_of_Balls

neg [di].Brvelocity

mov ax,0  ;Removing mouse [pointer]
int 33h


call clearscreen


;-----------------------------Upper Bar---------------------------

mov colour,00101001b
mov ah,6
mov al,0
mov BH,colour
mov ch,1  
mov cl,0  ;left
mov dh,1  ;down
mov dl,80  ;right
int 10h

;-----------------------left Bar--------------------------------------

mov colour,00101001b
mov ah,6
mov al,0
mov BH,colour
mov ch,1  ;up
mov cl,0  ;left
mov dh,23  ;down
mov dl,1  ;right
int 10h

;----------------Right Bar--------------------------
mov colour,00101001b

mov ah,6
mov al,0
mov BH,colour
mov ch,1 ;up
mov cl,78  ;left
mov dh,23  ;down
mov dl,79 ;right
int 10h

;---------------Bottom Bar----------------------

mov colour,00101001b

mov ah,6
mov al,0
mov BH,colour
mov ch,29 ;up
mov cl,0  ;left
mov dh,30  ;down
mov dl,79 ;right
int 10h

;setting the position of the cursor
mov ah,02h
mov bh,0
mov dh,0
mov dl,0
int 10h

mov dx,offset levelOnemsg1
mov ah,9
int 21h

mov dx,offset playerName
mov ah,9
int 21h


;setting the position of the cursor
call displayheart

mov ah,02h
mov bh,0
mov dh,0
mov dl,25
int 10h

mov dx,offset levelOnemsg3
mov ah,9
int 21h

mov ah,02h
mov bh,0
mov dh,0
mov dl,46
int 10h

mov dx,offset levelOnemsg4
mov ah,9
int 21h

nextlevel:
mov ax,currentLevel
cmp ax,3
jne notend
call WinningPage
notend:
inc currentLevel

mov ax,currentLevel

.if(ax==2)

mov di,offset Array_of_Bricks
mov cx,BricksCount

keepResetting:

mov [di].BRstrength,2
mov [di].BRcolour,3

add di,sizeof brick
loop keepResetting

add BricksCount,2
mov ax,BricksCount
mov currentBricks,ax

mov di,offset Array_of_Balls
mov ax,[di].Bcvelocity
cmp ax,0
jnl canletgo3
neg [di].Bcvelocity
canletgo3:
add [di].Bcvelocity,1


mov ax,[di].Brvelocity
cmp ax,0
jnl canletgo2
neg [di].Brvelocity
canletgo2:
add [di].Brvelocity,1

neg [di].Brvelocity
mov [di].Brow,375
mov [di].Bcol,300
add barvelocity,5
sub barwidth,9
.endif

.if(ax==3)

mov di,offset Array_of_Bricks
mov cx,BricksCount

sub cx,2

keepResetting1:

mov [di].BRstrength,3
mov [di].BRcolour,7

add di,sizeof brick
loop keepResetting1


mov ax,BricksCount
mov currentBricks,ax
mov di,offset Array_of_Balls
mov ax,[di].Bcvelocity
cmp ax,0
jnl canletgo
neg [di].Bcvelocity
canletgo:
add [di].Bcvelocity,1


mov ax,[di].Brvelocity
cmp ax,0
jnl canletgo1
neg [di].Brvelocity
canletgo1:
add [di].Brvelocity,1

neg [di].Brvelocity

mov [di].Brow,375
mov [di].Bcol,300
add barvelocity,5
sub barwidth,9
.endif



mov di,offset Array_of_Bricks
mov cx,BricksCount



keepDrawing:
mov ax, [di].BRrow
mov BrickRow,ax
mov ax,[di].BRcol
mov BrickCol,ax
mov al,[di].BRcolour
mov BrickColor,al


call DrawBrick
add di,sizeof brick
loop keepDrawing


mov syssecond, 61
outerKeepDrawing:

mov ax,xtemp
cmp ax,barcol
call DrawBar
;----------Drawing Brick---------------------
push cx
mov ah,01     ;checking if any key pressed
int 16h
Jz nokeypressed
mov ah,0
int 16h

 cmp ah, 01h
jne notPause

call pausefunction
notPause:


cmp ah,04dh
jne notright     ;checking if right key is pressed

mov ax,barcol
mov xtemp,ax
mov ax,barvelocity
add barcol,ax
mov ax,barcol

add ax,barwidth

.if(ax>640)
mov ax,barvelocity
sub barcol,ax
add ax,2
jmp nokeypressed
.endif

mov cx,barcol
sub cx,xtemp

mov ax, barcol
mov ytemp,ax


mov ax,xtemp
mov barcol,ax
mov ax,barvelocity
sub barcol,ax
;sub barcol, 150

mov ax,barwidth   ;reserving Barwidth's value to return
;add cx, 150
mov barwidth,cx
mov cx,barvelocity
add barwidth,cx


mov Barcolor,0       ;Drawing black bar

call DrawBar          
mov barcolor,1Fh       
mov barwidth,ax         ;returning Barwidth Value

mov ax,ytemp
mov barcol,ax   

notright:

cmp ah,04bh
jne notleft  ;checking if left key is pressed

mov ax,barcol
mov xtemp,ax
mov ax,barvelocity
sub barcol,ax

mov ax,barcol

cmp ax,0
jg noleftboundary
mov ax,barvelocity
add barcol,ax
jmp nokeypressed
noleftboundary:


mov cx,barcol
sub cx,xtemp

mov ax, barcol
mov ytemp,ax

neg cx
mov ax,barwidth
add barcol,ax


mov ax,barwidth
;add cx,150
mov barwidth,cx
mov bx,barvelocity
add barwidth,bx

mov barcolor,0

call DrawBar    

mov barcolor,1Fh       
mov barwidth,ax         ;returning Barwidth Value
mov ax,ytemp
mov barcol,ax



notleft:
;----------Drawing Brick------------------

nokeypressed:

pop cx







mov di,offset Array_of_Balls
mov cx,BallsCount

push BallRow ; to make previous ball black
push Ballcol
keepDrawing1:
; mov ax, [di].Brow
; mov BallRow,ax
pop Ballcol
pop BallRow
; mov ax,[di].Bcol
; mov Ballcol,ax
push [di].Brow ; to make previous ball black
push [di].Bcol
push cx

mov ah, 2ch
int 21h
.if(dh != sysSecond)
; inc second
mov sysSecond, dh

; mov ax, second
sub timer, 1

mov ah,02h
mov bh,0
mov dh,0
mov dl,53
int 10h

mov ax, timer
mov bl, 60
div bl


xor ah, ah
call output1

mov dx, ':'
mov ah, 2
int 21h

mov ax, timer
mov bl, 60
div bl

mov al, ah
xor ah, ah
push ax

cmp ax, 9
jg skipzero
mov dl, '0'
mov ah, 2
int 21h
skipzero:

pop ax
call output1

cmp timer, 0
jle gotoulbFun
cmp lives, 0
jg continuePlaying

gotoulbFun:
call updateLeaderBoard
mov ah, 4ch
int 21h
continuePlaying:
.endif


 
   xor bx,bx
         MOV CX, 0
         mov dx,04444h
         
         mov al,0
         MOV AH, 86H
         INT 15H
       pop cx


; mov ax, [di].Brow
; mov BallRow,ax
; mov ax,[di].Bcol
; mov Ballcol,ax
call DrawBlackBall




mov ax, [di].Brow
mov BallRow,ax
mov ax,[di].Bcol
mov Ballcol,ax
mov al,[di].Bcolour
mov BallColor,al

call DrawBall

;-----------------------left Bar--------------------------------------
pusha
mov colour,00101001b
mov ah,6
mov al,0
mov BH,colour
mov ch,2  ;up
mov cl,0  ;left
mov dh,23  ;down
mov dl,1  ;right
int 10h
popa
;--------------------------------------------------------------------

mov ax,[di].Brvelocity
add [di].Brow,ax


mov ax,[di].Brow
cmp ax,443

jbe nocollision2


neg [di].Brvelocity

mov ax,barRow
sub ax,30
mov [di].Brow,ax
mov ax,barcol
add ax,10
mov [di].Bcol,ax

;-------------erasing lives-----------
pusha
mov ah,02h
mov bh,0
mov dh,0
mov dl,67
int 10h
mov dx,offset levelOnemsg2
mov ah,9
int 21h



mov ah,09h
mov al,' '
mov bh,0
mov bl,04H
mov cx,lives
int 10h

;------------Printing new lives--------------
dec lives

mov ax,lives
cmp ax,0
jg notneedofexit
call updateLeaderBoard
; mov ah, 4ch
; int 21h
notneedofexit:
mov ah,09h
mov al,03h
mov bh,0
mov bl,04H
mov cx,lives
int 10h
popa

nocollision2:
cmp ax,38

ja nocoll
neg [di].Brvelocity
nocoll:

mov ax,[di].Bcvelocity
add [di].Bcol,ax



mov ax,[di].Bcol
cmp ax,602
jbe nocollision1
neg [di].Bcvelocity

nocollision1:

cmp ax,24
ja nocoll1
neg [di].Bcvelocity

nocoll1:

mov ax,[di].Bcol
mov currentCol,ax
mov ax,[di].Brow
mov currentRow,ax


mov si,di
call checkCollision

cmp collided,1
jne notcollided
mov ax,[di].Brvelocity
add [di].Brow,ax
mov ax,[di].Bcvelocity
add [di].Bcol,ax
notcollided:


;------------if level completed--------------------------------------

mov ax,currentLevel

.if(ax>1)
mov ax,currentBricks
cmp ax,2
jle nextlevel
.endif

pusha
mov ax,currentBricks
cmp ax,0
jg notcompleted


jmp nextlevel
notcompleted:



popa

;------------------------------------------------------------


pusha
call checkBarcollision
popa
cmp collided,1
jne notcollided1
mov ax,[di].Brvelocity
add [di].Brow,ax
mov ax,[di].Bcvelocity
add [di].Bcol,ax
notcollided1:


add di,sizeof ball

dec cx
jne keepDrawing1

jmp outerKeepDrawing


mov ah,4ch 
int 21h
startinglevels endp


WinningPage proc
call clearscreen
;Changing Page Numebr to 2
mov ah,05h 
mov al,2
int 10h

;Setting Video mode in new page
mov ah,0
mov al,12h
int 10h

;Setting the backgorund of the screen to black
mov ah,6
mov al,0
mov cx,0
mov dh,80
mov dl,80
mov bh,00
int 10h

;setting the position of the cursor
mov ah,2
mov dh,14
mov dl,15
int 10h

;Printing the message
mov dx,offset winningmsg
mov ah,9
int 21h

;Resetting Curson Position
mov ah,2
mov dh,0
mov dl,0
int 10h

mov ax, 0  ;Removing mouse [pointer]
int 33h

push ax
notreturn5:
nokeypressed5:
mov ah,01     ;checking if any key pressed
int 16h
Jz nokeypressed5
mov ah,0
int 16h

cmp ah, 01h
jne notreturn5
call mainMenuprint
;call welcomePage


pop ax
ret
WinningPage endp

;Page displays when player loses the game
losingpage proc
call clearscreen
;Changing Page Numebr to 2
mov ah,05h 
mov al,2
int 10h

;Setting Video mode in new page
mov ah,0
mov al,12h
int 10h

;Setting the backgorund of the screen to black
mov ah,6
mov al,0
mov cx,0
mov dh,80
mov dl,80
mov bh,00
int 10h

;setting the position of the cursor
mov ah,2
mov dh,14
mov dl,15
int 10h

;Printing the message
mov dx,offset losingmsg
mov ah,9
int 21h

;Resetting Curson Position
mov ah,2
mov dh,0
mov dl,0
int 10h

mov ax, 0  ;Removing mouse [pointer]
int 33h

push ax
notreturn4:
nokeypressed4:
mov ah,01     ;checking if any key pressed
int 16h
Jz nokeypressed4
mov ah,0
int 16h

cmp ah, 01h
jne notreturn4
call mainMenuprint
;call welcomePage


pop ax
ret
losingpage endp

;-------------------------------------------------------------------------------
;All the collision between ball and bricks is done in procedure 'CheckCollision'
;--------------------------------------------------------------------------------
checkCollision proc



push ax
push cx
push di
mov di,offset Array_of_Bricks

mov cx,BricksCount

checking1:

mov ax,[di].BRstrength
.if(ax<1)
jmp nocollision
.endif

mov ax,[di].BRcol
add ax,Brickwidth
cmp currentCol,ax
jnl nocollision

mov ax,currentCol
add ax,BallSize
cmp ax,[di].BRCol
jl nocollision

mov ax,[di].BRrow
add ax,Brickheight

cmp ax,currentRow
jl nocollision

mov ax,BallSize
add ax,currentRow
cmp ax,[di].BRrow
jl nocollision

jmp collisionOccured


nocollision:
add di,sizeof brick
loop checking1



mov collided,0
pop di
pop cx
pop ax

ret
collisionOccured:
call beep

mov ax,[di].BRstrength
cmp ax,3
jg noScore
.if([di].BRbonus == 1)
add Score, 5
.else
inc Score
.endif

noScore:

mov ah,02h
mov bh,0
mov dh,0
mov dl,32
int 10h

mov ax, score
call output1

mov collided,1


mov ax, [si].Bcvelocity
cmp ax, 0
jl notleft1

mov ax,[di].BRcol
mov lowerx,ax
mov ax,[si].Bcvelocity
add lowerx,ax

mov ax,currentCol
add ax,ballsize
cmp ax,lowerx
jg notleft1

mov ax,[di].BRrow
mov lowery,ax
mov ax,[si].Bcvelocity
add lowery,ax

mov ax,currentRow
add ax,ballsize
cmp ax,lowery
jl notleft1

mov ax,[di].BRrow
add ax,Brickheight
mov lowery,ax
mov ax, [si].Bcvelocity
sub lowery,ax

mov ax,currentRow
cmp ax,lowery
jg notleft1



neg [si].Bcvelocity
jmp donecollision1
notleft1:


mov ax,[si].Bcvelocity

cmp ax,0
jg notright1


mov ax,[di].BRcol
add ax,Brickwidth
mov dx,[si].Bcvelocity
neg dx
sub ax,dx
mov lowerx,ax

mov ax,currentCol
cmp ax,lowerx
jl notright1

mov ax,[di].BRrow
add ax,dx
mov lowery,ax

mov ax,currentRow
add ax,ballsize
cmp ax,lowery
jl notright1
mov ax,[di].BRrow
add ax,Brickheight
sub ax,dx
mov lowery,ax
mov ax,currentRow
cmp ax,lowery
jg notright1



neg [si].Bcvelocity
jmp donecollision1

notright1:

mov ax,[si].Brvelocity
cmp ax,0
jl notup

mov ax,currentCol
add ax,ballsize
mov lowerx,ax
mov ax,[di].BRcol
add ax,[si].Brvelocity

cmp lowerx,ax
jl notup

mov ax,[di].Bcol
add ax,Brickwidth
sub ax,[si].Brvelocity
mov lowery,ax

mov ax,currentCol
cmp ax,lowery
jg notup

mov ax,currentRow
add ax,ballsize
mov lowery,ax

mov ax,[di].BRrow
add ax,[si].Brvelocity
cmp lowery,ax

jg notup



neg [si].Brvelocity
jmp donecollision1
notup:

mov dx,[si].Brvelocity
cmp dx,0

jg notdown
neg dx
mov ax,[di].BRcol
add ax,[si].Brvelocity
mov lowerx,ax
mov ax,currentCol
add ax,ballsize
cmp ax,lowerx

jl notdown
mov ax,[di].BRcol
add ax,Brickwidth
sub ax,dx
mov lowerx,ax
mov ax,currentCol
cmp ax,lowerx
jg notdown
mov ax,[di].BRrow
add ax,Brickheight
sub ax,dx
mov lowerx,ax

mov ax,currentRow
cmp ax,lowerx
jl notdown

neg [si].Brvelocity
jmp donecollision1

notdown:
neg [si].Brvelocity
neg [si].Bcvelocity

donecollision1:


dec [di].BRstrength

mov ax,[di].BRstrength

.if(ax<1)
dec currentBricks
.endif
mov ax,currentLevel

.if (ax>1)
mov ax,[di].BRstrength
cmp ax,3
jl nocolourchange
push dx
mov dl,[di].BrickColor
cmp dl,0
jne noneedtoblack
mov BrickColor,0
jmp skip5

noneedtoblack:
mov BrickColor,1Fh
skip5:
pop dx
jmp nopermanentchange
.endif
nocolourchange:
mov al,byte ptr [di].BRstrength
mov BrickColor,al
nopermanentchange:

mov ax, [di].BRrow
mov BrickRow,ax
mov ax,[di].BRcol
mov BrickCol,ax

call DrawBrick

jmp brickbroken


brickbroken:
pop di
pop cx
pop ax
ret
checkCollision endp


;seek to end of file, preserves no registers 
; returns ususal answer in ax
seekEOF PROC uses bx cx dx
    mov al, 2
    mov bx, scoreHandler
    xor cx, cx
    xor dx, dx
    mov ah, 42h
    int 21h ; seek...
    ret
seekEOF ENDP

;Traverse a file backwards until 2nd '$' or first 0 is met
;Requires file to be opened for read before call
;Requires strings to be terminated by '$'
;Returns offset of first element of last string in file
;limit might be 2^16
;Return 0 in ax if error occurs while reading (not while seeking)
fileBackTraversal PROC
    push bp
    mov bp, sp

    pusha
    mov chTraversal, 0
    mov chTraversalcount, 0

    mov al, [bp + 4] ; seek of EOF
    mov bx, scoreHandler
    mov cx, -1
    mov dx, -2 ;traverse through '$' and one character before it
    mov ah, 42h
    int 21h ; seek...
    
    cmp ax, 0
    je fbtError ;if there is no character in file seek will return 0 in ax
    inc chTraversalcount
    ;add chTraversalcount, 2
    ; if there is a string then it is terminated by '$', Ignore that '$'
    
    
    ; mov bx, scoreHandler
    ; mov dx, offset chTraversal
    ; mov cx, 1
    ; mov ah, 3fh
    ; int 21h ; read from file...
    ; jc fbtError    
    ; inc chTraversalcount


    fBTloop1:

        mov bx, scoreHandler
        mov dx, offset chTraversal
        mov cx, 1
        mov ah, 3fh
        int 21h ; read from file...
        jc fbtError
        cmp ax, 0
        je endTreversal
        cmp chTraversal, '$'
        je endTreversal
        inc chTraversalcount    
        

            ; move pointer backwards two place (one place cuz of read int and another place to actually traverse backwards )
            mov al, 1 ; seek of EOF
            mov cx, -1
            mov dx, -2
            mov ah, 42h
            int 21h ; seek...
            cmp ax, 0
            je head ;if there is no character in file seek will return 0 in ax
        jmp fBTloop1

    head:
    popa
    pop bp
    inc chTraversalcount    

    ret 2

    fbtError:
    popa
    pop bp
    mov ax, 0
    ret 2
    endTreversal:
    popa
    pop bp
    ret 2
fileBackTraversal ENDP

;write score into file 
writeScore PROC
    push bp
    mov bp, sp
    push si
    push ax
    push bx
    push cx
    push dx

    mov ax, score
    ; parse a 4 digit score from score variable into string format
    mov dx,0
    mov cx,4
    repeat2:

        mov dx,0
        mov bx,10
        div bx ; divide ax with bx and store remainder in dx and quotient in ax
        mov bx,ax
        add dx,48
        push dx
    loop repeat2

    ; move that string to .data to write it in file
    mov cx,4
    mov si, [bp + 4]
    print:
    pop dx
    mov [si], dx
    inc si
    loop print
    mov [si], byte ptr '$'

    sub si, 4

    mov ah, 40h   ; writing into the file
    mov bx, scoreHandler
    mov dx, si
    mov cx, 5
    int 21h
    ; if error occurs allah hafiz mera putar

    pop dx
    pop cx
    pop bx
    pop ax
    pop si
    pop bp
    ret 2
writeScore ENDP

;description
oneStringBack PROC
    ;seek file pointer to the start of last string in file
    mov al, 1
    mov bx, scoreHandler
    mov cx, -1
    mov dx, chTraversalcount
    neg dx
    mov ah, 42h
    int 21h ; seek...
    ret
oneStringBack ENDP

;description
; recieve a an offset of decimal ascii string containing 4-digits in si
stringToAscii PROC
    push bp
    mov bp, sp
    push si

    push bx
    push dx

    mov bx, 1000
    ; mov si, [bp + 4]
    xor ax, ax
    mov al, [si]
    sub ax, 48
    mul bx
    mov bx, ax

    mov dx, 100
    xor ax, ax
    mov al, [si + 1]
    sub ax, 48
    mul dl
    add bx, ax

    mov dl, 10
    xor ax, ax
    mov al, [si + 2]
    sub ax, 48
    mul dl
    add bx, ax

    xor ax, ax
    mov al, [si + 3]
    sub ax, 48
    add bx, ax


    mov ax, bx
    pop dx
    pop bx

    pop si
    pop bp
    ret
stringToAscii ENDP

; gets two strings in one 2d array as a member of .data -> string
; recieves size of both strings 
; returns 1 in ax if strings are equal
; returns 0 in ax if strings are not equal
c2dSfirstArraySize equ [bp + 6]
c2dSsecondArraySize equ [bp + 4]
compare2dString PROC
    push bp
    mov bp, sp
    pusha
    ;ax contains size of second array
    ;dx contains size of first array
    mov ax, c2dSsecondArraySize
    mov dx, c2dSfirstArraySize
    mov cx, 2
    cmp ax, dx
    jne c2dSexit

    mov si, offset playerName ; first array
    mov di, offset playerName
    add di, dx ; second array

    dec si
    dec di

    mov cx, ax
    firstloop:
        cmp cx, 1
        je c2dSexit
        inc si
        inc di
        mov dl, [di]
        cmp dl, 'Z'
        jb dxisCapital
        ;if letter in dx is not capital
        cmp dl,  [si]
        loope firstloop
        inc cx
       
        sub dl, 32
        cmp dl, [si]
        loope firstloop
        inc cx
        jmp c2dSexit

        dxisCapital:
        cmp dl, [si]
        loope firstloop
        inc cx
        add dl, 32
        cmp dl, [si]
        loope firstloop
        inc cx
        jmp c2dSexit


    c2dSexit:
    cmp cx, 1
    jne notequal
    popa
    mov ax, 1
    pop bp
    ret 4
    ; jmp outof
    notequal:
    popa
    mov ax, 0
    pop bp
    ret 4
; outof:
;     popa
;     pop bp
;     ret 4
compare2dString ENDP

;move cursor to eof and then write score as well as name given in string 
appendatEof PROC
    call seekEOF
    jc aaTEOFExit
    push si
    call writeScore
    mov ah, 40h   ; writing into the file
    mov bx, scoreHandler
    mov dx, offset playerName
    mov cx, userSize
    int 21h

aaTEOFExit:
    ret
appendatEof ENDP

; returns number of characters read in chTraversal count
; returns 0 if error occurs else 1
resume PROC
    pusha

    cmp fileopened, 1
    je rfileExists

    mov ah, 3dh     ; open an existig file
    mov al, 02h
    mov dx, offset file_name
    int 21h
    jc rfileDoesNotExists
    mov scoreHandler, ax
    mov fileopened, 1


    jmp rfileExists

    ;if file doesn't exist create it
    ;to create a new file.
    rfileDoesNotExists:
    mov ah, 3ch
    mov dx, offset file_name
    mov cl, 2                 ; read and write 
    int 21h
    jc rmiddlepoint
    mov scoreHandler, ax
    mov fileopened, 1

    jmp rfileExists
    rmiddlepoint:
    jmp rerror


    rfileExists:
    call seekEOF
    ; get the address of the start of last string in file 

    mov ax, 2
    push ax
    call fileBackTraversal
    cmp ax, 0
    je rhead

    ;read last string in file
    mov bx, scoreHandler
    mov dx, offset playername
    mov cx, chTraversalcount
    mov userSize, cx
    mov ah, 3fh
    int 21h ; read from file...
    jc rerror
    jmp rclosefile

     ;Closing the file
    rhead:
    mov ah, 3eh
    mov bx, scoreHandler
    int 21h
    jc rerror
    popa
    mov ax, 0
    ret 


    rclosefile:
    mov al, 0
    mov bx, scoreHandler
    mov cx, 0
    mov dx, 0
    mov ah, 42h
    int 21h ; seek...
    jc rerror
    ; mov ah, 3eh
    ; mov bx, scoreHandler
    ; int 21h
    ; jc rerror
    popa
    mov ax, 1
    ret 

    rerror:
    mov dx, 'l'
    mov ah, 2
    int 21h
    popa
    mov ax, 0
    ret
resume ENDP


;update leaderboard
;recieve size of first array in string using username size for this purpose
;recieves 1 in fileopened to skip the file opening process (for resume function)
updateLeaderBoard PROC
    pusha
    cmp fileopened, 1
    je uBLfileExists

    xor cx, cx
    xor bx, bx
    
    mov ah, 3dh     ; open an existig file
    mov al, 02h
    mov dx, offset file_name
    int 21h
    jc uLBfileDoesNotExists
    mov scoreHandler, ax
    mov fileopened, 1
    ;call seekEOF 
    ; jc uBLmiddlepoint

    jmp uBLfileExists

    ;if file doesn't exist create it
    ;to create a new file.
    uLBfileDoesNotExists:
    mov ah, 3ch
    mov dx, offset file_name
    mov cl, 2                 ; read and write only
    int 21h
    jc uBLmiddlepoint
    mov scoreHandler, ax
    mov fileopened, 1

    jmp uBLfileExists
    uBLmiddlepoint:
    jmp uBLerror


    uBLfileExists:
    call seekEOF
    ; there will always be a name in string ; whether a used one from resume or new game 
    mov si, offset playername
    add si, userSize ; the size of that playername is stored in userSize variable

    ; if new file is created just write the score at the end
    mov ax, 2
    push ax
    call fileBackTraversal
    cmp ax, 0 
    je writeAtEnd

    ;else start reading
    mov ax, 2 ; ax = 2 pushed in fileBackTraversal which means end of file, ax = 1 means current position of file
    uBLreadwholefile:
    push ax
    call fileBackTraversal
    cmp ax, 0
    je uBLclosefile ; if error occurs jump to closefile

    ;read last string in file
    mov bx, scoreHandler
    mov dx, si
    mov cx, chTraversalcount
    mov ah, 3fh
    int 21h ; read from file...
    jc uBLerror

    cmp ubltemp, 1
    jne nameNotfound 

    ; if name is found that means current iteration has score associated with that name

    ;seek file pointer to the start of last string in file | last string in file corresponds to the current string in si
    call oneStringBack
    jc uBLerror
    ; cmp ax, 0
    ; je uBLclosefile

    call stringToAscii
    cmp ax, score ; old score compared with new score
    ja tempjump   ; if old score is greater no need to update it
    ; else write it in file
    ; mov dl, 'y'
    ; mov ah, 2
    ; int 21h

    push si
    call writeScore
    call seekEOF

tempjump:
    
    call displayLeaderBoard 
    mov ubltemp, 0
    jmp uBLclosefile

    nameNotfound:

    ; check two strings to see if they are equal
    push userSize
    push chTraversalcount
    call compare2dString
    cmp ax, 0
    je uBLnotequal
    mov ubltemp, 1 ;flag the next iteration


    ; mov dl, '='
    ; mov ah, 2
    ; int 21h    

    uBLnotequal:
    

    ;seek file pointer to the start of last string in file
    call oneStringBack
    jc uBLerror
    cmp ax, 0
    je writeAtEnd

    mov ax, 1
    jmp uBLreadwholefile
writeAtEnd:
    call appendatEof
    call displayLeaderBoard 

    ;Closing the file
    uBLclosefile:
    mov ah, 3eh
    mov bx, scoreHandler
    int 21h
    popa
    ret 


    uBLerror:
    mov dx, 'e'
    mov ah, 2
    int 21h
    popa
    ret 
updateLeaderBoard ENDP 

; diplay new line
newLine PROC
    push ax
    push dx

    mov dl, 10
    mov ah, 2
    int 21h

    mov dl, 13
    mov ah, 2
    int 21h
    
    pop dx
    pop ax
    ret 
newLine ENDP

; print a 2d string array based on $ and size
; recieves address of 2d and size in stack
; removes parameters from stack
; requires each array to end with $
x_offset equ [bp + 4]
y_size equ [bp + 6]
printer PROC
    push bp
    mov bp, sp
    push si
    push cx
    push ax
    push dx
    mov si, x_offset
    mov cx, y_size

    nextString:
        mov dl, [si]
        inc si
        cmp dl, '$'
        je AStringEnded ; first value can be '$' so cmp at start
        mov ah, 2
        int 21h
        jmp nextString
        AStringEnded:
        call newLine
        loop nextString

    pop dx
    pop ax
    pop cx
    pop si
    pop bp
    ret 4
printer ENDP

;display leader board 
;recieves 1 in stack to skip the file opening process (for resume function)
displayLeaderBoard PROC
    pusha
    
    
    cmp fileopened, 1
    je fileExists

    mov ah, 3dh     ; open an existig file
    mov al, 02h
    mov dx, offset file_name
    int 21h
    jc fileDoesNotExists
    mov scoreHandler, ax
    mov fileopened, 1


    call seekEOF
    jc middlepointforerror

    jmp fileExists

    ;if file doesn't exist create it
    ;to create a new file.
    fileDoesNotExists:
    mov ah, 3ch
    mov dx, offset file_name
    mov cl, 2                 ; read and write only
    int 21h
    jc middlepointforerror
    mov scoreHandler, ax
    mov fileopened, 1

    jmp fileExists
    middlepointforerror:
    jmp error


    fileExists:
    call seekEOF
    ; get the address of the start of last string in file 

    call clearscreen
   
    mov dLBcursorR, 1
    mov dLBcursorC, 30

    mov ah,02h
    mov bh,0
    mov dh, dLBcursorR
    mov dl, dLBcursorC
    int 10h

    mov dx, offset mainMenu2
    mov ah, 9
    int 21h
    mov dLBcursorR, 2

    mov ax, 2
    readwholefile:

    push ax
    call fileBackTraversal
    cmp ax, 0
    je closefile

    ;read last string in file
    mov bx, scoreHandler
    mov dx, offset playername
    mov cx, chTraversalcount
    mov ah, 3fh
    int 21h ; read from file...
    jc error

    

    .if(isName == 0)
    add dLBcursorR, 1 ; cursor row position, first row line will be printed at dLBcursorR + 1
                      ;change every time name is detected
    mov dLBcursorC, 20 ; cursor col position for name
    mov isName, 1
    .else
    
    mov dLBcursorC, 40 ; cursor col position for score
    mov isName, 0
    .endif

    ; setting cursor
    mov ah,02h
    mov bh,0
    mov dh, dLBcursorR
    mov dl, dLBcursorC
    int 10h

    ;display last string in file
    mov dx, 1
    push dx
    mov dx, offset playername
    push dx   
    call printer

    

    ;seek file pointer to the start of last string in file
    mov al, 1
    mov bx, scoreHandler
    mov cx, -1
    mov dx, chTraversalcount
    neg dx
    mov ah, 42h
    int 21h ; seek...
    jc error
    cmp ax, 0
    je closefile

    mov ax, 1
    jmp readwholefile


    ;Closing the file
    closefile:
    ; mov ah, 3eh
    ; mov bx, scoreHandler
    ; int 21h
    call displayPause
    popa
    ret 


    error:
    mov dx, 'e'
    mov ah, 2
    int 21h
    popa
    ret 
displayLeaderBoard ENDP




;-------------------------------------------------------------------------------
;All the collision between ball and bar is done in procedure 'CheckBarcollision'
;--------------------------------------------------------------------------------
checkBarcollision PROC

push ax
push cx
push di



mov ax,barcol
add ax,barwidth
cmp currentCol,ax
jnl nocollision4

mov ax,currentCol
add ax,BallSize
cmp ax,barcol
jl nocollision4

mov ax,barRow
add ax,barheight

cmp ax,currentRow
jl nocollision4

mov ax,BallSize
add ax,currentRow
cmp ax,barRow
jl nocollision4

jmp collisionOccured41


nocollision4:


mov collided,0
pop di
pop cx
pop ax
ret
collisionOccured41:


mov collided,1

mov ax, [si].Bcvelocity
cmp ax, 0
jl notleft2

mov ax,barcol
mov lowerx,ax
mov ax,[si].Bcvelocity
add lowerx,ax

mov ax,currentCol
add ax,ballsize
cmp ax,lowerx
jg notleft2

mov ax,barRow
mov lowery,ax
mov ax,[si].Bcvelocity
add lowery,ax

mov ax,currentRow
add ax,ballsize
cmp ax,lowery
jl notleft2

mov ax,barRow
add ax,barheight
mov lowery,ax
mov ax, [si].Bcvelocity
sub lowery,ax

mov ax,currentRow
cmp ax,lowery
jg notleft2




neg [si].Bcvelocity
jmp donecollision2
notleft2:


mov ax,[si].Bcvelocity
cmp ax,0
jg notright2


mov ax,barcol
add ax,barwidth
mov dx,[si].Bcvelocity
neg dx
sub ax,dx
mov lowerx,ax

mov ax,currentCol
cmp ax,lowerx
jl notright2

mov ax,barRow
add ax,dx
mov lowery,ax

mov ax,currentRow
add ax,ballsize
cmp ax,lowery
jl notright2
mov ax,barRow
add ax,barheight
sub ax,dx
mov lowery,ax
mov ax,currentRow
cmp ax,lowery
jg notright2


neg [si].Bcvelocity
jmp donecollision2

notright2:

mov ax,[si].Brvelocity
cmp ax,0
jl notup2

mov ax,currentCol
add ax,ballsize
mov lowerx,ax
mov ax,barcol
add ax,[si].Brvelocity

cmp lowerx,ax
jl notup2

mov ax,barcol
add ax,barwidth
sub ax,[si].Brvelocity
mov lowery,ax

mov ax,currentCol
cmp ax,lowery
jg notup2

mov ax,currentRow
add ax,ballsize
mov lowery,ax

mov ax,barRow
add ax,[si].Brvelocity
cmp lowery,ax

jg notup2

;-------------------physics for left half of the bar-----------------------------------
mov dx,0
mov ax,barwidth
 mov bx,3
 div bx
mov bx,barcol

add bx,ax
sub bx,9
mov dx,currentCol
sub dx,ballsize
cmp dx,bx
jg notlefthalf
mov ax,[si].Bcvelocity
cmp ax,0
jl notlefthalf
neg [si].Bcvelocity
notlefthalf:
;-------------------physics for right half of the bar-----------------------------------
mov dx,0
mov ax,barwidth
 mov bx,3
 div bx
 mov dx,barcol
add dx,barwidth
sub dx,ax
mov lowerx,dx
mov ax,currentCol
cmp ax,lowerx
jl notrighthalf
mov ax,[si].bcvelocity
cmp ax,0
jg notrighthalf

neg [si].Bcvelocity
notrighthalf:

neg [si].Brvelocity
jmp donecollision2
notup2:

mov dx,[si].Brvelocity
cmp dx,0

jg notdown2
neg dx
mov ax,barcol
add ax,[si].Brvelocity
mov lowerx,ax
mov ax,currentCol
add ax,ballsize
cmp ax,lowerx

jl notdown2
mov ax,barcol
add ax,barwidth
sub ax,dx
mov lowerx,ax
mov ax,currentCol
cmp ax,lowerx
jg notdown2
mov ax,barRow
add ax,barheight
sub ax,dx
mov lowerx,ax

mov ax,currentRow
cmp ax,lowerx
jl notdown2



neg [si].Brvelocity
jmp donecollision2

notdown2:
neg [si].Brvelocity
neg [si].Bcvelocity

donecollision2:


pop di
pop cx
pop ax
ret

checkBarcollision ENDP



pausefunction proc uses ax bx dx

;setting the position of the cursor
mov ah,02h
mov bh,0
mov dh,1
mov dl,34
int 10h

mov dx,offset Pausemsg1
mov ah,9
int 21h


letsgo:


mov ah,0
int 16h

cmp ah, 01h

jne letsgo
mov colour,00101001b
mov ah,6
mov al,0
mov BH,colour
mov ch,1  
mov cl,0  ;left
mov dh,1  ;down
mov dl,80  ;right
int 10h


ret
pausefunction endp
displayheart proc uses ax dx cx bx

mov ah,02h
mov bh,0
mov dh,0
mov dl,67
int 10h

mov dx,offset levelOnemsg2
mov ah,9
int 21h


mov ah,09h
mov al,03h
mov bh,0
mov bl,04H
mov cx,lives
int 10h
ret
displayheart endp




;-----------------------------------------------------------------
; Procedure 'welcomePage' displayes all the graphics of the welcome page
; calls procedurs like 'BrickBreakerPrint'
;------------------------------------------------------------------
welcomePage proc
welcomePagemove::
push ax
push bx
push cx
push dx
;setting Video Mode
mov ah,0
mov al,12h
int 10h
mov ax,0

;Setting Background Colour
mov ah,06h
xor al,al
xor cx,cx
mov dh,30
mov dl,80
mov bh,00h
int 10h

;horizontal line 1
mov ah,6
mov al,0
mov BH,colour
mov ch,1  
mov cl,9  ;right
mov dh,1  ;down
mov dl,70  ;left
int 10h

;horizontal line 2
;mov ah,6
;mov al,1
;mov BH,colour
;mov ch,0  
;mov cl,9  ;right
;mov dh,10  ;down
;mov dl,70  ;left
;int 10h

;Vertical line 1
mov ah,6
mov al,0
mov BH,colour
mov ch,2  
mov cl,7  ;right
mov dh,15  ;down
mov dl,8  ;left
int 10h

;Vertical line 2
;mov ah,6
;mov al,9
;mov BH,colour
;mov ch,0  
;mov cl,69  ;right
;mov dh,10  ;down
;mov dl,70  ;left
;int 10h


;setting Cursor
mov ah,02h
mov bh,0
mov dh,5
mov dl,33
int 10h

call BrickBreakerPrint

;setting the cursor position
mov ah,02h
mov bh,00h
mov dh,20  ;Row NUmber
mov dl,28  ;Column number
int 10h

;printing the message
mov dx,offset welcome
mov ah,9
int 21h

mov ah,02h
mov bh,00h
mov dh,22  ;Row NUmber
mov dl,31  ;Column number
int 10h


;-----------------------------------------------------------------------
; Code to detect the mouse click
;-----------------------------------------------------------------------
mov ax, 1  ;displaying mouse
int 33h
keepgoing1:



push ax
mov ah,01     ;checking if any key pressed
int 16h
Jz nokeypressed1
mov ah,0
int 16h

cmp ah, 01h
jne notexit
call ExitPage
nokeypressed1:
notexit:
pop ax




mov ax, 5
mov bx, 0
int 33h

cmp ax, 1
jne noleftclick1

;----------------------------------------------------------------------------------------------------------
;bound check checks if a click pressed is in boundaries defined by startgamebox array
;-
mov si,offset fullScreen
push si
call boundCheck ;check if cursor is in right position or not

cmp ax, 1
je exit

noleftclick1:



mov ax, 5
mov bx, 0
int 33h
;pop ax ;instead of calling 33h getting value again

cmp ax, 2
jne keepgoing1


exit:

pop dx
pop cx
pop bx
pop ax
ret
welcomePage endp


; recieves a value in ax and displays its decimal
; preserves no value for the sake of efficiency
output1 proc uses cx
mov cx, 0
continuepushing:
mov DX, 0
mov BX, 10
div BX
push DX
inc cx
cmp AX, 0
jne continuepushing
continuepopping:
pop DX
add DX, 48
mov AH, 02h
int 21h
dec cx
cmp cx,0
jne continuepopping
stoppopping:
;mov DX, 10
;mov AH, 02
;int 21h
ret
output1 endp
;------------------------------------------------------------
; Procedure 'TakeuserName' Takes Player Name from the user
;------------------------------------------------------------
takeuserName proc uses ax dx bx
mov si,offset playerName
repeat1:
mov ah,1
int 21h
cmp al,13
je done
mov [si],al
add si,1
inc cx
jmp repeat1
done:
inc cx
mov al,'$'
mov [si],al
ret
takeuserName endp

;----------------------------------------------------------------------------
;PROCEDURE 'BrickBreakerPrint' Prints the Logo of the Game "Brick Breaker"
;----------------------------------------------------------------------------

BrickBreakerPrint proc uses dx cx bx ax
; Printing B
mov ah,6
mov al,5
mov BH,colour
mov ch,2  
mov cl, 12  ;right
mov dh,7  ;down
mov dl,12  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,7 
mov cl,12  ;right
mov dh,7  ;down
mov dl,15  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,5 
mov cl,12  ;right
mov dh,5  ;down
mov dl,15  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,3 
mov cl,12  ;right
mov dh,3  ;down
mov dl,15  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,4  
mov cl, 16  ;right
mov dh,4  ;down
mov dl,16  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,6  
mov cl, 16  ;right
mov dh,6  ;down
mov dl,16  ;left
int 10h

;printing R -----------------------------------------------------------

mov ah,6
mov al,5
mov BH,colour
mov ch,2  
mov cl,18  ;right
mov dh,7  ;down
mov dl,18  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,3 
mov cl,19  ;right
mov dh,3  ;down
mov dl,21  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,4  
mov cl, 22  ;right
mov dh,4  ;down
mov dl,22  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,5 
mov cl,19  ;right
mov dh,5  ;down
mov dl,21  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,6  
mov cl, 22  ;right
mov dh,7  ;down
mov dl,22  ;left
int 10h

;Printing I----------------------------------------
mov ah,6
mov al,0
mov BH,colour
mov ch,3  
mov cl,24  ;right
mov dh,7  ;down
mov dl,24  ;left
int 10h

;Printing C---------------------------------------------
mov ah,6
mov al,0
mov BH,colour
mov ch,4  
mov cl,26  ;right
mov dh,6  ;down
mov dl,27  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,3 
mov cl,28  ;right
mov dh,3  ;down
mov dl,30  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,7 
mov cl,28  ;right
mov dh,7  ;down
mov dl,30  ;left
int 10h

;Printing K----------------------------------------
mov ah,6
mov al,0
mov BH,colour
mov ch,3  
mov cl,32  ;right
mov dh,7  ;down
mov dl,32  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,5 
mov cl,33  ;right
mov dh,5  ;down
mov dl,34  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,4 
mov cl,35  ;right
mov dh,4 ;down
mov dl,36  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,3 
mov cl,37  ;right
mov dh,3 ;down
mov dl,38  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,6 
mov cl,35  ;right
mov dh,6  ;down
mov dl,36  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,7 
mov cl,37  ;right
mov dh,7  ;down
mov dl,38  ;left
int 10h



;Printing Breaker's B--------------------------------------
; Printing B
mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 26  ;right
mov dh,14  ;down
mov dl,26  ;left
int 10h


mov ah,6
mov al,0
mov BH,colour
mov ch,10 
mov cl,26  ;right
mov dh,10  ;down
mov dl,29  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,12 
mov cl,26  ;right
mov dh,12  ;down
mov dl,29  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,14 
mov cl,26  ;right
mov dh,14  ;down
mov dl,29  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,11  
mov cl,30  ;right
mov dh,11  ;down
mov dl,30  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,13  
mov cl, 30  ;right
mov dh,13  ;down
mov dl,30  ;left
int 10h

;printing R -----------------------------------------------------------

mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 32  ;right
mov dh,14  ;down
mov dl,32  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 32  ;right
mov dh,10  ;down
mov dl,35  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,12  
mov cl, 32  ;right
mov dh,12  ;down
mov dl,35  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,11  
mov cl,36  ;right
mov dh,11  ;down
mov dl,36  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,13  
mov cl,36  ;right
mov dh,14  ;down
mov dl,36  ;left
int 10h

;printing E -----------------------------------------------------------

mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 38  ;right
mov dh,14  ;down
mov dl,38  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 39  ;right
mov dh,10  ;down
mov dl,41  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,12  
mov cl, 39  ;right
mov dh,12  ;down
mov dl,41  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,14  
mov cl, 39  ;right
mov dh,14  ;down
mov dl,41  ;left
int 10h

;printing A -----------------------------------------------------------

mov ah,6
mov al,0
mov BH,colour
mov ch,12  
mov cl, 43  ;right
mov dh,14  ;down
mov dl,43  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,11  
mov cl, 44  ;right
mov dh,11  ;down
mov dl,45  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 46  ;right
mov dh,10  ;down
mov dl,47  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,11  
mov cl, 48  ;right
mov dh,11  ;down
mov dl,49  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,12  
mov cl, 50  ;right
mov dh,14  ;down
mov dl,50  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,13  
mov cl, 43  ;right
mov dh,13  ;down
mov dl,50  ;left
int 10h

;printing K -----------------------------------------------------------

mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 52  ;right
mov dh,14  ;down
mov dl,52  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,12  
mov cl, 53  ;right
mov dh,12  ;down
mov dl,54  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 57  ;right
mov dh,10  ;down
mov dl,58  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,11  
mov cl, 55  ;right
mov dh,11  ;down
mov dl,56  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,13  
mov cl, 55  ;right
mov dh,13  ;down
mov dl,56  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,14  
mov cl, 57  ;right
mov dh,14  ;down
mov dl,58  ;left
int 10h

;Printing E----------------------------------------------
mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 60  ;right
mov dh,14  ;down
mov dl,60  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 61  ;right
mov dh,10  ;down
mov dl,63  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,12  
mov cl, 61  ;right
mov dh,12  ;down
mov dl,63  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,14  
mov cl, 61  ;right
mov dh,14  ;down
mov dl,63  ;left
int 10h

;Printing R----------------------------------------------
mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 65  ;right
mov dh,14  ;down
mov dl,65  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,10  
mov cl, 66  ;right
mov dh,10  ;down
mov dl,68  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,12  
mov cl, 66  ;right
mov dh,12  ;down
mov dl,68  ;left
int 10h

mov ah,6
mov al,0
mov BH,colour
mov ch,11  
mov cl, 69  ;right
mov dh,11  ;down
mov dl,69  ;left
int 10h


mov ah,6
mov al,0
mov BH,colour
mov ch,13  
mov cl, 69  ;right
mov dh,14  ;down
mov dl,69  ;left
int 10h
ret
BrickBreakerPrint endp

beep proc
        push ax
        push bx
        push cx
        push dx
        mov     al, 182         ; Prepare the speaker for the
        out     43h, al         ;  note.
        mov     ax, 400        ; Frequency number (in decimal)
                                ;  for middle C.
        out     42h, al         ; Output low byte.
        mov     al, ah          ; Output high byte.
        out     42h, al 
        in      al, 61h         ; Turn on note (get value from
                                ;  port 61h).
        or      al, 10000111b   ; Set bits 1 and 0.
        out     61h, al         ; Send new value.
        mov     bx, 1          ; Pause for duration of note.
.pause1:
        mov     cx, 65535
.pause2:
        dec     cx
        jne     .pause2
        dec     bx
        jne     .pause1
        in      al, 61h         ; Turn off note (get value from
                                ;  port 61h).
        and     al, 11110100b   ; Reset bits 1 and 0.
        out     61h, al         ; Send new value.

        pop dx
        pop cx
        pop bx
        pop ax

ret
beep endp

end main

