
# Instructions 

To assemble the .asm file (named oren2) and then open it successfully, the following actions are needed to be done:
1. Download DOSBox and tasm
2. Place tasm in the same directory as your .asm file
3. Open DOSBox
4. Go to the directory the .asm file is in DOSBox
5. Write the following commands in order to assemble the .asm file and create a COM file:
    
		tasm orem2
	
		tlink oren2 /t
6. Write the following command to open the COM file:

		oren2

## In this program you will be using a text editor

This program loads a file called 'OrenText.txt'. if the file doesn't exist in the directory, the program will create a file of the same name.
 
When you open the program, you will be prompted to choose two modes. By pressing 0, you pick the text edit mode. By pressing 1, you pick the draw mode. Pressing any other key will have no effect. 
In the bottom row, you will see either a 0 or 1. These will indicate what mode the program is in. It is 0 if it is text mode and 1 if in draw mode. You can press F1 to toggle between the two modes.
 
In both modes, you type characters into the program, use arrow keys to move through the screen, and you can press Enter to close the program. Press delete to delete a character the cursor is over. Pressing Enter will store the contents that you wrote into the file OrenText.txt. The character limit for the program is 1920 characters.
Below will explain the two modes.
 
#### Text edit mode: 
In this mode you can insert any character corresponding with the keyboard excluding Enter as discussed before. Type any character to insert and use backspace to remove a character. Both insertion and removal involve shifting sections of the text you are writing.
 

#### Draw mode: 
In this mode, only numbers, the minus key (which is marked by '-'), the shifted versions of the previous keys mentioned, and Enter will influence the text. Numbers and the minus key will represent lines that you can use to draw something in your program (like a box). Shifting these keys will create double lines. For example, pressing 1 will create a bottom left corner with a single line but pressing Shift+1 creates a double line version of a bottom left corner. 
 
You can use backspace to delete any character as well like in text edit mode, the main difference is in draw mode, it deleted a character located at the cursor and doesn’t shift any characters. You can press either 'c' or 'C' to clear all the characters displayed on the screen.
 
Below is a list outlining the keys and their corresponding character for draw mode.
The list follows the format: **Key, Draw Mode Character**
* -, │
* 0, ─
* 1, └
* 2, ┴
* 3, ┘
* 4, ├
* 5, ┼
* 6, ┤
* 7, ┌
* 8, ┬
* 9, ┐
