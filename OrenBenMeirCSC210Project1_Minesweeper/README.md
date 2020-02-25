# Instructions 

To assemble the .asm file (named oren1) and then open it successfully, the following actions are needed to be done:
1. Download DOSBox and tasm
2. Place tasm in the same directory as your .asm file
3. Open DOSBox
4. Go to the directory the .asm file is in DOSBox
5. Write the following commands in order to assemble the .asm file and create a COM file:
    
		tasm orem1
	
		tlink oren1 /t
6. Write the following command to open the COM file:

	oren1
	
In this program you will play minesweeper.
To test if the program is running correctly, an excel sheet was placed which shows what items are in each cell of the grid. 

## How to play minesweeper:
All keys inputted must not be shifted
controls:
* q: quit game
* r: replay if game is finished or
* a: move left
* s: move down
* d: move right
* w: move up
* f: to set or remove a flag on an element
* e: to check and reveal what is under any unflagged element whose contents are unknown. This will not work for any flagged element or an element that is already revealed (i.e. any element with the number of adjacent bombs on it). If there is a bomb under the element, you lose the game.

If you manage to reveal every element with no bombs hidden, you win.
