;----------------------------------------------------------------
;|								                                              |
;|	Tic-Tac-Toe						                                      |
;|								                                              |
;|	Author: Jordan Reed					                                |
;|								                                              |
;|	Date: 05/12/2021                                            |
;|                                                              |
;|	Description:                                                |
;|	     This program allows 2 people to play Tic-Tac-Toe.      |
;|                                                              |
;----------------------------------------------------------------

	.ORIG x3000

	JSR Init
	
	JSR Game

	JSR NewGame

	HALT

;--------------------------------
;                         
;	Initialization Function: Init
;	
;	Description:
;	     This function initializes all registers to 0, except for
;	     R6, which is initialized to the top of the stack, and R7,
;	     which is used for the PC. The spaces array is initialized
;	     to point to the relevant spaces in the gameboard, and set
;	     to be ' '.
;
;	Entry Parameters:
;	     R7 = Reserved for PC
;
;	Returns: NA
;
;	Register Usage:
;	     R0 Used for gameboard variable
;		Also used to print prompts, and
;		initialize player variables
;	     R1 Used to initialize spaces array
;	     R2 Used as row counter
;	     R3 Used as column counter
;	     R4 Used for advancing the row in the gameboard
;	     R5 Not used
;	     R6 Stack pointer
;	     R7 Reserved for PC
;
;	     Only R7 is preserved.
;
;	Function Operation:
;	     Initialize stack
;	     Initialize spaces array of pointers
;	     Print Welcome screen
;	     Set registers to 0
;	     Initialize player binary numbers
;	     Initialize all spaces in gameboard to ' '
;                         
;--------------------------------


Init	LD	R6, stack	; point R6 to top of stack

	ADD	R6, R6, #-1	; push R7
	STR	R7, R6, #0

	LD	R0, board
	LEA	R1, spaces
	
; initialize spaces to point to fillable spots in game board

	AND	R2, R2, #0
	ADD	R2, R2, #3	; row counter

	AND	R3, R3, #0
	ADD	R3, R3, #3	; column counter

	LD	R4, ROW_NUM

NEW_ROW	ADD	R0, R0, R4	; new row
	ADD	R0, R0, R4	; new row
	
NEW_COL	ADD	R0, R0, #5	; go to first spot in row
	STR	R0, R1, #0	; init. spaces
	ADD	R1, R1, #1	; inc spaces
	ADD	R0, R0, #3

	ADD	R3, R3, #-1
	BRp NEW_COL
	
	ADD	R3, R3, #3	; reset column counter
	
	ADD	R0, R0, #4	; add for end of row
	ADD	R0, R0, R4	; new row

	ADD	R2, R2, #-1	; dec row counter
	BRp NEW_ROW
	
; print welcome screen

	LEA	R0, initprompt
	PUTS
	JSR NewLine		; print newline char
	
; make sure everything is initialized to 0

	AND	R1, R1, #0
	AND	R2, R2, #0
	AND	R3, R3, #0
	AND	R4, R4, #0
	AND	R5, R5, #0

	LEA	R0, playerX
	STR	R1, R0, #0

	LEA	R0, playerO
	STR	R1, R0, #0

; initialize all spaces to ' '

	LD	R3, spaceCHAR

	ADD	R1, R1, #9	; counter for spaces array
	LEA	R0, spaces	; address of spaces
SP_LOOP	LDR	R2, R0, #0
	STR	R3, R2, #0
	ADD	R0, R0, #1
	ADD	R1, R1, #-1
	BRp SP_LOOP

	AND	R1, R1, #0
	AND	R2, R2, #0
	AND	R3, R3, #0

	LDR	R7, R6, #0	; pop R7
	ADD	R6, R6, #1
	
	RET

;-----------------
; local variables
;-----------------

stack		.FILL xFFFC	; stack address
ROW_NUM		.FILL #28	; number to advance to another row

;--------------------------------
;
;	Game Function: Game
;
;	Description:
;	     This function 'plays' the game of Tic-Tac-Toe.
;
;	Notes:
;	     Function needs variables gameboard and spaces to be set.
;	     It calls other functions: Input, Print, WinChck, and TieChck
;
;	Entry Parameters:
;	     R6 = Stack
;	     R7 = PC
;
;	Returns: NA
;
;	Register Usage:
;	     R0 Used to print prompts
;		Used to pass through to other functions
;	     R1 Used as XO counter, to alternate between X and O input
;	     R2 Not Used
;	     R3 Not Used
;	     R4 Not Used
;	     R5 Not used
;	     R6 Stack pointer
;	     R7 Reserved for PC
;	
;	     All registers preserved
;
;	Function Operation:
;	     Input: x or o
;		Update board and players
;	     Print
;	     Check for a win
;	     Check for a tie
;	     Win or tie: end game
;	     Loop
;
;--------------------------------

Game	ADD	R6, R6, #-1
	STR	R7, R6, #0	; push R7

	ADD	R6, R6, #-1
	STR	R1, R6, #0	; push R1
	
	ADD	R6, R6, #-1
	STR	R0, R6, #0	; push R0

	AND	R1, R1, #0
	ADD	R1, R1, #1	; XO counter

	JSR Print

X_IN	ADD	R0, R1, #0
	JSR Input
	BR UPDATE

O_IN	ADD	R0, R1, #0
	JSR Input
	ADD	R1, R1, #2	; reset XO counter

UPDATE	JSR Print

	JSR WinChck
	
	ADD	R0, R0, #-1	; check for win
	BRz GAME_EXIT

	JSR TieChck

	ADD	R0, R0, #-1	; check for tie
	BRz GAME_EXIT

	ADD	R1, R1, #-1	; alternate X input and O input
	BRz O_IN
	BR X_IN

GAME_EXIT LDR	R0, R6, #0	; pop R0
	ADD	R6, R6, #1

	LDR	R1, R6, #0	; pop R1
	ADD	R6, R6, #1

	LDR	R7, R6, #0	; pop R7
	ADD	R6, R6, #1

	RET

;--------------------------------
;
;	Input Function: Input
;
;	Description:
;	     This function gets input from both players X and O,
;	     and updates the corresponding space in the gameboard.
;
;	Notes:
;	     This function does some error handling, such as not overwriting
;	     an already filled space. It does not do bounds checking on the 
;	     input.
;	     Function calls: OUpdate, XUpdate, NewLine
;
;	Entry Parameters:
;	     R0 = 1 if needing X input, 0 if needing O input
;	     R6 = Stack
;	     R7 = PC
;
;	Returns: 1 if X, 0 if O
;
;	Register Usage:
;	     R0 Contains which input to use
;		Also contains prompts to print
;	     R1 Used to convert an ASCII value of a number to a number
;		Contains the spaces array
;	     R2 Used to hold the value stored in the gameboard
;	     R3 Holds ' ', to check if a space is empty
;	     R4 Has either 'X' or 'O'
;	     R5 Not used
;	     R6 Stack pointer
;	     R7 Reserved for PC
;	
;	     All registers preserved except R0
;
;	Function Operation:
;	     Checks to see if X or O
;	     Gets input
;	     Checks to see if space is filled
;		Loop if space is filled
;	     Fill space and update player binary number
;
;--------------------------------

Input	ADD	R6, R6, #-1
	STR	R7, R6, #0	; push R7

	ADD	R6, R6, #-1
	STR	R4, R6, #0	; push R4

	ADD	R6, R6, #-1
	STR	R3, R6, #0	; push R3

	ADD	R6, R6, #-1
	STR	R2, R6, #0	; push R2

	ADD	R6, R6, #-1
	STR	R1, R6, #0	; push R1
	
	ADD	R6, R6, #-1
	STR	R0, R6, #0	; push R0

START	LDR	R0, R6, #0	; read R0
	ADD	R0, R0, #-1
	BRn INPUT_O

INPUT_X	LD	R4, XSign	; load 'X'
	LEA	R0, Xinput
	BR INPUT

INPUT_O	LD	R4, OSign	; load 'O'
	LEA	R0, Oinput

INPUT	PUTS			; print instructions	
	GETC			; get ascii value of space
	OUT			; echo
	JSR NewLine

	LD	R1, asciiCon
	ADD	R0, R0, R1	; get number of ascii equivalent

	LEA	R1, spaces	; spaces array
	
	ADD	R1, R1, R0	; get space that player input
	ADD	R1, R1, #-1

	LDR	R2, R1, #0	; get value of that space
	LDR	R2, R2, #0

	LD	R3, spaceCh	; check if space is empty
	ADD	R2, R2, R3
	BRz UPSPACE

	LEA	R0, errorPrompt	; space is filled; loop again
	PUTS
	JSR NewLine
	BR START

UPSPACE	LDR	R2, R1, #0	; get address of space on board
	STR	R4, R2, #0	; update space with x or o

	LDR	R4, R6, #0	; read R0 into R4

	ADD	R4, R4, #-1
	BRnp OUPDATE

	JSR XUpdate		; update x player config
	BR IN_EXIT

OUPDATE	JSR OUpdate		; update o player config

IN_EXIT	LDR	R0, R6, #0	; pop R0
	ADD	R6, R6, #1

	LDR	R1, R6, #0	; pop R1
	ADD	R6, R6, #1

	LDR	R2, R6, #0	; pop R2
	ADD	R6, R6, #1

	LDR	R3, R6, #0	; pop R3
	ADD	R6, R6, #1

	LDR	R4, R6, #0	; pop R4
	ADD	R6, R6, #1

	LDR	R7, R6, #0	; pop R7
	ADD	R6, R6, #1

	RET

;-----------------
; local variables
;-----------------

asciiCon	.FILL x-30
spaceCh		.FILL x-20
XSign		.FILL x58	; 'X'
OSign		.FILL x4F	; 'O'

;--------------------------------
;
;	Update X Player Function: XUpdate
;
;	Description:
;	     This function updates the binary number holding
;	     the X player's positions. 
;	
;	Notes:
;	     Functions calls: Power2
;
;	Entry Parameters:
;	     R0 = position of X to update
;	     R6 = Stack
;	     R7 = PC
;
;	Returns: position of X to update
;
;	Register Usage:
;	     R0 Contains position of X to update
;		Pass number through to functions
;	     R1 Holds the value of the player X configuration
;	     R2 Contains address of the player X configuration
;	     R3 Not used
;	     R4 Not used
;	     R5 Not used
;	     R6 Stack pointer
;	     R7 Reserved for PC
;	
;	     All registers preserved
;
;	Function Operation:
;	     Calculate 2^n where n is the position picked.
;	     Add 2^n to the binary number and store in variable
;
;--------------------------------

XUpdate	ADD	R6, R6, #-1
	STR	R7, R6, #0	; push R7

	ADD	R6, R6, #-1
	STR	R2, R6, #0	; push R2

	ADD	R6, R6, #-1
	STR	R1, R6, #0	; push R1

	ADD	R6, R6, #-1
	STR	R0, R6, #0	; push R0

	ADD	R0, R0, #-1	; call 2^n where n is pos picked - 1
	JSR Power2

	LEA	R2, playerX	; R2 has address of playerX
	LDR	R1, R2, #0	; R1 has value of playerX

	ADD	R1, R1, R0	; add a 1 in the correct position of playerX
	STR	R1, R2, #0	; put updated number back in playerX

	LDR	R0, R6, #0	; pop R0
	ADD	R6, R6, #1

	LDR	R1, R6, #0	; pop R1
	ADD	R6, R6, #1

	LDR	R2, R6, #0	; pop R2
	ADD	R6, R6, #1

	LDR	R7, R6, #0	; pop R7
	ADD	R6, R6, #1

	RET

; maybe combine these 2 functions? pass through char?

;--------------------------------
;
;	Update O Player Function: OUpdate
;
;	Description:
;	     This function updates the binary number holding
;	     the O player's positions. 
;	
;	Notes:
;	     Functions calls: Power2
;
;	Entry Parameters:
;	     R0 = position of O to update
;	     R6 = Stack
;	     R7 = PC
;
;	Returns: position of O to update
;
;	Register Usage:
;	     R0 Contains position of O to update
;		Pass number through to functions
;	     R1 Holds the value of the player O configuration
;	     R2 Contains address of the player O configuration
;	     R3 Not used
;	     R4 Not used
;	     R5 Not used
;	     R6 Stack pointer
;	     R7 Reserved for PC
;	
;	     All registers preserved
;
;	Function Operation:
;	     Calculate 2^n where n is the position picked.
;	     Add 2^n to the binary number and store in variable
;
;--------------------------------

OUpdate	ADD	R6, R6, #-1
	STR	R7, R6, #0	; push R7

	ADD	R6, R6, #-1
	STR	R2, R6, #0	; push R2

	ADD	R6, R6, #-1
	STR	R1, R6, #0	; push R1

	ADD	R6, R6, #-1
	STR	R0, R6, #0	; push R0

	ADD	R0, R0, #-1	; call 2^n where n is pos picked - 1
	JSR Power2

	LEA	R2, playerO	; R2 has address of playerO
	LDR	R1, R2, #0	; R1 has value of playerO

	ADD	R1, R1, R0	; add a 1 in the correct position of playerO
	STR	R1, R2, #0	; put updated number back in playerO

	LDR	R0, R6, #0	; pop R0
	ADD	R6, R6, #1

	LDR	R1, R6, #0	; pop R1
	ADD	R6, R6, #1

	LDR	R2, R6, #0	; pop R2
	ADD	R6, R6, #1

	LDR	R7, R6, #0	; pop R7
	ADD	R6, R6, #1

	RET

;----------------------------
;|                          |
;| Global Variables/Prompts |
;|                          |
;----------------------------

playerX		.FILL #0	; holds player X configuration
playerO		.FILL #0	; holds player O configuration
spaceCHAR 	.FILL x20	; ' '

spaces		.BLKW 9		; array of pointers for blank spaces in board

board		.FILL gameboard

initprompt	.STRINGZ "Welcome to Tic-Tac-Toe!"
Xinput		.STRINGZ "Player X, pick a spot: "
Oinput		.STRINGZ "Player O, pick a spot: "
errorPrompt	.STRINGZ "Incorrect space. Try again."
tiePrompt	.STRINGZ "It's a tie! Game Over."


;--------------------------------
;
;	Print GameBoard Function: Print
;
;	Description:
;	     This function prints the gameboard to the screen
;
;	Entry Parameters:
;	     R6 = Stack
;	     R7 = PC
;
;	Returns: NA
;
;	Register Usage:
;	     R0 Contains address of gameboard to print
;	     R1 Not used
;	     R2 Not used
;	     R3 Not used
;	     R4 Not used
;	     R5 Not used
;	     R6 Stack pointer
;	     R7 Reserved for PC
;	
;	     All registers preserved
;
;	Function Operation:
;	     Get address of gameboard and print to screen
;
;--------------------------------

Print	ADD	R6, R6, #-1	; push R7
	STR	R7, R6, #0

	ADD	R6, R6, #-1	; push R0
	STR	R0, R6, #0

	LD	R0, board
	PUTS

	LDR	R0, R6, #0	; pop R0
	ADD	R6, R6, #1
	
	LDR	R7, R6, #0	; pop R7
	ADD	R6, R6, #1

	RET

;--------------------------------
;
;	Win Check Function: WinChck
;
;	Description:
;	     This function checks to see if either player has won 
;
;	Entry Parameters:
;	     R6 = Stack
;	     R7 = PC
;
;	Returns: 1 if a player has won
;
;	Register Usage:
;	     R0 Returns 1 if player has won
;	     R1 Value of player configurations
;	     R2 Win configuration array
;	     R3 Used for XO counter
;		Used for Win array counter
;	     R4 Not used
;	     R5 Not used
;	     R6 Stack pointer
;	     R7 Reserved for PC
;	
;	     All registers preserved except R0
;
;	Function Operation:
;	     Load player X number
;	     AND player X with all possible win configurations
;	     Load player O number
;	     AND player O with all possible win configurations
;	     If winner, print prompt and return 1
;
;--------------------------------

WinChck	ADD	R6, R6, #-1
	STR	R7, R6, #0	; push R7

	ADD	R6, R6, #-1
	STR	R1, R6, #0	; push R1

	ADD	R6, R6, #-1
	STR	R2, R6, #0	; push R2
	
	ADD	R6, R6, #-1
	STR	R3, R6, #0	; push R3

; load values into registers
	LD	R1, playerX
	LEA	R2, win

	AND	R3, R3, #0
	ADD	R3, R3, #1	; R3=1 for X and O counter

	ADD	R6, R6, #-1
	STR	R3, R6, #0	; push R3

	AND	R3, R3, #0
	ADD	R3, R3, #8	; 8, used for win config counter

CH_LP	ADD	R6, R6, #-1
	STR	R3, R6, #0	; push R3

	LDR	R3, R2, #0	; R3 has R2 value, first win config
	
	AND	R0, R1, R3	; check if winning config
	NOT	R3, R3
	ADD	R3, R3, #1
	ADD	R0, R0, R3
	BRz WINNER
	
	LDR	R3, R6, #0	; pop R3
	ADD	R6, R6, #1
	
	ADD	R2, R2, #1
	ADD	R3, R3, #-1
	BRp CH_LP

	LDR	R3, R6, #0	; pop R3, X and O counter
	ADD	R6, R6, #1

	ADD	R3, R3, #-1
	BRz OCHECK

Exit	LDR	R3, R6, #0	; pop R3
	ADD	R6, R6, #1

	LDR	R2, R6, #0	; pop R2
	ADD	R6, R6, #1

	LDR	R1, R6, #0	; pop R1
	ADD	R6, R6, #1

	LDR	R7, R6, #0	; pop R7
	ADD	R6, R6, #1

	RET

OCHECK	LD	R1, playerO
	LEA	R2, win

	ADD	R6, R6, #-1	; push counter
	STR	R3, R6, #0
	
	AND	R3, R3, #0
	ADD	R3, R3, #8

	BR CH_LP

WINNER	LEA	R0, winnerprompt
	PUTS
	JSR NewLine

	AND	R0, R0, #0	; put 1 in R0 to show winner
	ADD	R0, R0, #1
	
	LDR	R3, R6, #0	; pop R3
	ADD	R6, R6, #1

	LDR	R3, R6, #0
	ADD	R6, R6, #1	

	BR Exit
	

;-----------------
; local variables
;-----------------

winnerprompt	.STRINGZ "We have a winner!"
win		.FILL #7	; win configurations
		.FILL #56
		.FILL #448
		.FILL #273
		.FILL #84
		.FILL #73
		.FILL #146
		.FILL #292

;--------------------------------
;
;	Tie Check Function: TieChck
;
;	Description:
;	     This function checks to see if there is a tie
;
;	Notes:
;	     Function calls: NewLine
;
;	Entry Parameters:
;	     R6 = Stack
;	     R7 = PC
;
;	Returns: 1 if there is a tie, 0 if no tie
;
;	Register Usage:
;	     R0 Return 1 if there is a tie
;		Used to print prompt
;	     R1 Contains address of spaces array
;	     R2 Contains calue of address stored in spaces array (value in gameboard)
;	     R3 Contains spaces array counter
;	     R4 Contains ' ' to check if an empty space
;	     R5 Not used
;	     R6 Stack pointer
;	     R7 Reserved for PC
;	
;	     All registers preserved except R0
;
;	Function Operation:
;	     Load spaces array
;	     Load value stored in gameboard
;	     Check if space is empty
;		If empty space, exit with Return of 0
;	     Loop through entire spaces array
;	     Return 1 for a tie
;
;--------------------------------

TieChck	ADD	R6, R6, #-1
	STR	R7, R6, #0	; push R7

	ADD	R6, R6, #-1
	STR	R1, R6, #0	; push R1

	ADD	R6, R6, #-1
	STR	R2, R6, #0	; push R2
	
	ADD	R6, R6, #-1
	STR	R3, R6, #0	; push R3
	
	ADD	R6, R6, #-1
	STR	R4, R6, #0	; push R4

	LEA	R1, spaces	; holds address of spaces

	LDR	R0, R1, #0	; holds address stored in spaces array
	LDR	R2, R0, #0	; holds value of address in spaces array

	AND	R3, R3, #0
	ADD	R3, R3, #9	; spaces array counter

	AND	R4, R4, #0
	ADD	R4, R4, #9	; tie check counter

	LD	R4, spaceChar

TIE_LP	LDR	R2, R0, #0	; load value of current space
	ADD	R2, R2, R4	; check for empty space
	BRz NO_TIE

	ADD	R1, R1, #1	; inc array
	LDR	R0, R1, #0	; updated address stored in array
	ADD	R3, R3, #-1	; dec array counter
	BRp TIE_LP

	LEA	R0, tiePrompt
	PUTS
	JSR NewLine

	AND	R0, R0, #0
	ADD	R0, R0, #1	; 1 in R0 if there is a tie

	BR TIE_EXT

NO_TIE	AND	R0, R0, #0

TIE_EXT	LDR	R4, R6, #0	; pop R4
	ADD	R6, R6, #1

	LDR	R3, R6, #0	; pop R3
	ADD	R6, R6, #1

	LDR	R2, R6, #0	; pop R2
	ADD	R6, R6, #1

	LDR	R1, R6, #0	; pop R1
	ADD	R6, R6, #1

	LDR	R7, R6, #0	; pop R7
	ADD	R6, R6, #1

	RET

spaceChar	.FILL x-20

;--------------------------------
;
;	New Game Function: NewGame
;
;	Description:
;	     This function checks to see if the user would like
;	     to play a new game.
;
;	Notes:
;	     This function only preserves R7 if the player does not
;	     want to play a new game. Otherwise, no other registers
;	     are preserved.
;	     This function will accept either 'y' or 'Y' to play
;	     another game.
;
;	Entry Parameters:
;	     R6 = Stack
;	     R7 = PC
;
;	Returns: R7 has the address to return to
;
;	Register Usage:
;	     R0 Used to print prompts and get input
;	     R1 Contains 'y' and 'Y' to check for response
;	     R2 Not used
;	     R3 Not used
;	     R4 Not used
;	     R5 Not used
;	     R6 Stack pointer
;	     R7 Reserved for PC
;		Holds starting address of x3000 if new game requested
;
;	Function Operation:
;	     Ask player if new game requested
;	     Get player input
;	     Check for affirmative response
;
;--------------------------------

NewGame	ADD	R6, R6, #-1	; push R7
	STR	R7, R6, #0

	LEA	R0, newgameprompt
	PUTS			; print prompt
	GETC			; get player input

	ADD	R6, R6, #-1	; push R0
	STR	R0, R6, #0	; save player input

	OUT			; echo char to screen
	JSR NewLine

; checks if player said 'y' and 'Y'
; if player selects yes then restart
; else end program

	LDR	R0, R6, #0	; pop R0 (player input)
				; and push R0

	LD	R1, ychar	; load 'y'
	NOT	R1, R1
	ADD	R1, R1, #1	; -'y' for subtracting

	ADD	R0, R0, R1	; check if player said yes
	BRz NEW			; start over

	LDR	R0, R6, #0	; pop R0 (player input)
	ADD	R6, R6, #1

	LD	R1, Ychar	; load 'Y'
	NOT	R1, R1
	ADD	R1, R1, #1

	ADD	R0, R0, R1	; check if player said yes
	BRz NEW			; start over

	LDR	R7, R6, #0	; pop R7 if player said no
	ADD	R6, R6, #1
	BR NEW_EXIT

NEW	LD	R7, stAddr	; if starting over
	BR NEW_EXIT

NEW_EXIT RET

;-----------------
; local variables
;-----------------

newgameprompt	.STRINGZ "New Game? y/n: "
ychar		.FILL x79	; 'y'
Ychar		.FILL x59	; 'Y'
stAddr		.FILL x3000

;--------------------------------
;
;	2^n Function: Power2
;
;	Description:
;	     This function calculates 2^n
;
;	Entry Parameters:
;	     R0 = n
;	     R6 = Stack
;	     R7 = PC
;
;	Returns: R0 holds 2^n
;
;	Register Usage:
;	     R0 Contains n
;	     R1 Contains the running total
;	     R2 Not used
;	     R3 Not used
;	     R4 Not used
;	     R5 Not used
;	     R6 Stack pointer
;	     R7 Reserved for PC
;
;	All registers preserved except R0
;
;	Function Operation:
;	     
;	     int Power2(int n)
;	     {
;		int x = 1;
;		while(n > 0)
;		  {
;		    x += x;
;		    n -= 1;
;	     	  }
;	     	return x;
;	     }
;
;--------------------------------

Power2	ADD	R6, R6, #-1	; push R7
	STR	R7, R6, #0

	ADD	R6, R6, #-1	; push R1
	STR	R1, R6, #0

	AND	R1, R1, #0	; set R1 = 1
	ADD	R1, R1, #1

	ADD	R0, R0 #-1	; check if n=0
	BRn DONE

	ADD	R0, R0, #1	; reset R0
POW_LP	ADD	R1, R1, R1	; add R1 to itself, running total
	ADD	R0, R0, #-1
	BRp POW_LP

DONE	ADD	R0, R1, #0	; put R1 into R0
	
	LDR	R1, R6, #0	; pop R1
	ADD	R6, R6, #1

	LDR	R7, R6, #0	; pop R7
	ADD	R6, R6, #1

	RET

;--------------------------------
;
;	Print Newline Function: NewLine
;
;	Description:
;	     This function prints a newline to the screen
;
;	Entry Parameters:
;	     R6 = Stack
;	     R7 = PC
;
;	Returns: NA
;
;	Register Usage:
;	     R0 Used for printing \n to screen
;	     R1 Not used
;	     R2 Not used
;	     R3 Not used
;	     R4 Not used
;	     R5 Not used
;	     R6 Stack pointer
;	     R7 Reserved for PC
;
;	All registers preserved
;
;--------------------------------

NewLine	ADD	R6, R6, #-1	; push R7
	STR	R7, R6, #0

	ADD	R6, R6, #-1	; push R0
	STR	R0, R6, #0

	AND	R0, R0, #0	; load newline char
	ADD	R0, R0, #10
	OUT			; print \n

	LDR	R0, R6, #0	; pop R0
	ADD	R6, R6, #1

	LDR	R7, R6, #0	; pop R7
	ADD	R6, R6, #1

	RET

;-------------------------
;|                       |
;| More Global Variables |
;|     			 |
;-------------------------

gameboard	.FILL x2B	; border "+ - - - - - - - - - - - - +\n"
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2D
		.FILL x20
		.FILL x2B
		.FILL xA
		.FILL x7C	; first row "*        |       |        *\n"
		.FILL x20
		.FILL x20	
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL xA
		.FILL x7C	; second row "*        |       |        *\n"
		.FILL x20
		.FILL x20	
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL xA
		.FILL x7C	; third row "*       1|      2|      3 *\n"
		.FILL x20
		.FILL x20	
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x31
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x32
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x33
		.FILL x20
		.FILL x7C
		.FILL xA
	.FILL x7C	; fourth row "* -------+-------+------- *\n"
	.FILL x20
	.FILL x2D	
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2B
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2B
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x20
	.FILL x7C
	.FILL xA
		.FILL x7C	; fifth row "*        |       |        *\n"
		.FILL x20
		.FILL x20	
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL xA
		.FILL x7C	; sixth row "       |       |        *\n"
		.FILL x20
		.FILL x20	
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL xA
		.FILL x7C	; seventh row "*       4|      5|      6 *\n"
		.FILL x20
		.FILL x20	
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x34	; '4'
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x35	; '5'
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x36	; '6'
		.FILL x20
		.FILL x7C
		.FILL xA
	.FILL x7C	; eighth row "* -------+-------+------- *\n"
	.FILL x20
	.FILL x2D	
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2B
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2B
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x2D
	.FILL x20
	.FILL x7C
	.FILL xA
		.FILL x7C	; ninth row "*        |       |        *\n"
		.FILL x20
		.FILL x20	
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL xA
		.FILL x7C	; tenth row "*        |       |        *\n"
		.FILL x20
		.FILL x20	
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x7C
		.FILL xA
		.FILL x7C	; eleventh row "*       7|      8|      9 *\n"
		.FILL x20
		.FILL x20	
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x37
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x38
		.FILL x7C
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x20
		.FILL x39	; '9'
		.FILL x20
		.FILL x7C
		.FILL xA
	.FILL x2B	; border "***************************\n"
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2D
	.FILL x20
	.FILL x2B
	.FILL xA
	.FILL x0
	
	.END
