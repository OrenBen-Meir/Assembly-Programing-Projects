assume cs:cseg, ds:cseg
cseg segment
org 100h; for .com
start0: 
jmp start

;variables
ModeInstructions db 'Press 0 to set to text edit mode, 1 to draw mode, any other key wont work',0

UpArrow dw 4800h ;Up arrow keyboard scan code
DownArrow dw 5000h ;Down arrow keyboard scan code
RightArrow dw 4D00h ;Right arrow keyboard scan code
LeftArrow dw 4B00h ;Left arrow keyboard scan code

Mode db 0 ;0 if textEdit mode, 1 if drawMode
Quitkey dw 1C0Dh;value of a quit key (ENTER key)
String db 1920 dup(' '),0;stores string used to store buffer contents that arent in new line, 80 characters per row and 24 rows
StringSize dw 1920;Size of string
Location dw 0 ;Location of cursor
CursorCharacter db 254; ■ character used to represent a blinking cursor in an empty slot

FileName db 'OrenText.txt',0
Handle dw ?

Buffer db 1968 dup(' '),0
BufferSize dw 1968

;functions
setMode: ;prompts user to set the mode
	call ClearScreen
	call print_Instructions_To_SetMode
	setMode_keyLoop:
		sub ax,ax
		int 16h
		sub al,'0'
		cmp al,1
		ja setMode_keyLoop
	mov Mode,al 
	call ClearScreen	
	mov al,Mode
	add al,'0'
	mov es:[3840],al
	mov BYTE PTR es:[3841],0fh
	ret	

ClearScreen: ;clears screen
	mov ah,71h
	push cx
	push bx
	mov al,' '
	mov cx,1920;80*25
	sub bx,bx
	LClearScreen: 
	mov es:[bx],ax
	add bx,2
	loop LClearScreen
	pop bx
	pop cx
	ret	
	
print_Instructions_To_SetMode: ;prints instructions to set the mode
	sub bx,bx 
	print_Instructions_To_SetModeLoop:
	mov al,ModeInstructions[bx]
	shl bx,1
	mov es:[bx],al
	shr bx,1
	inc bx  
	cmp ModeInstructions[bx],0 
	jne print_Instructions_To_SetModeLoop
	ret

setStringToVideo: ;sets contents of the String to video
	sub bx,bx 
	setStringToVideoLoop:
	mov al,String[bx]
	shl bx,1
	mov es:[bx],al
	shr bx,1
	inc bx  
	cmp String[bx],0 
	jne setStringToVideoLoop
	ret
	
PlaceCursor: ;Displays cursor on video
	push ax
	mov bx,Location
	shl bx,1
	cmp BYTE PTR es:[bx],' '
	jne SetBlink
		mov al,CursorCharacter
		mov BYTE PTR es:[bx],al
	SetBlink:
	inc bx 
	mov BYTE PTR es:[bx],0F1h
	pop ax
	ret		
RemoveCursor: ;Removes cursor on video
	push ax
	mov bx,Location
	shl bx,1
	mov al,CursorCharacter
	cmp BYTE PTR es:[bx],al
	jne RemoveBlink
		mov BYTE PTR es:[bx],' '
	RemoveBlink:
	inc bx 
	mov BYTE PTR es:[bx],071h
	pop ax
	ret
	
MoveUp:;Moves cursor and location up
	mov ax,Location
	sub ax,80
	cmp location,80
	jb MoveUpReturn
	call RemoveCursor
	mov location,ax
	call PlaceCursor	
	MoveUpReturn:
	ret
MoveDown:;Moves cursor and location down
	mov ax,location
	add ax,80
	cmp ax,StringSize
	jge MoveDownReturn
	call RemoveCursor
	mov location,ax
	call PlaceCursor	
	MoveDownReturn:
	ret
MoveRight:;Moves cursor and location right
	mov ax,StringSize
	dec ax 
	cmp location,ax 
	je MoveRightReturn
	call RemoveCursor
	inc location
	call PlaceCursor
	MoveRightReturn:
	ret
MoveLeft:;Moves cursor and location left
	mov ax,location
	dec ax 
	cmp ax,0
	jl MoveLeftReturn
	call RemoveCursor
	mov Location,ax
	call PlaceCursor
	MoveLeftReturn:
	ret	
	
ArrowTest:;Moves cursor based on arrow key if such key is pressed. arguments(ax = scan code from int16h)
;returns bx=1 if movement occures, bx=0 if otherwise
	
	push ax
	;if Up
	cmp ax,UpArrow
	jne DownTest
	call MoveUp
	jmp SetBX1
	;if Down
	DownTest:
	cmp ax,DownArrow
	jne RightTest
	call MoveDown
	jmp SetBX1
	;if Right
	RightTest:
	cmp ax,RightArrow
	jne LeftTest
	call MoveRight
	jmp SetBX1
	;if Left
	LeftTest:
	cmp ax,LeftArrow
	jne SetBX0
	call MoveLeft
	jmp SetBX1
	
	SetBX1:
	mov bx,1
	jmp EndArrowTest
	
	SetBX0:
	sub bx,bx
	
	EndArrowTest:
	pop ax
	ret
ClearStringAndDisplay:
	sub bx,bx
	ClearStringAndDisplayL:
		mov String[bx],' '
		inc bx
	cmp bx,StringSize
	jb ClearStringAndDisplayL	
	call setStringToVideo
	call PlaceCursor
	ret
BackSpace:;Backspaces from location
	cmp Location,0
	je BackSpaceReturn
	call MoveLeft
	mov bx,location
	mov cx,StringSize
	dec cx
	againBackSpaceLoop:
		cmp bx,cx 
		jae doneBackSpaceLoop
		
		inc bx
		mov al,String[bx]
		dec bx
		mov String[bx],al
		
		inc bx
		
		jmp againBackSpaceLoop
	doneBackSpaceLoop:
	
	mov BYTE PTR String[bx],' '
	
	call setStringToVideo
	call PlaceCursor
	
	BackSpaceReturn:
	ret
insertKey:;inserts character arguments(al = character value)
	push ax 
	mov bx,StringSize
	dec bx 
	
	againInsertKeyLoop:
		cmp bx,location
		jbe doneInsertKeyLoop
		
		dec bx
		mov al,String[bx]
		inc bx
		mov String[bx],al
		
		dec bx 
		
		jmp againInsertKeyLoop
	doneInsertKeyLoop:
	
	pop ax
	
	mov String[bx],al 
	
	call setStringToVideo
	call PlaceCursor
	call MoveRight	
	ret		

DrawInsertKey:; converts values of al to appropriate values and inserts them arguments(al = character value)

	Case1:
		cmp al,'1'
		jne Case1shift
		mov al,192 
		jmp Break
	Case1shift:
		cmp al,'!'
		jne Case2
		mov al,200   
		jmp Break	
		
	Case2:
		cmp al,'2'
		jne Case2shift
		mov al,193 
		jmp Break
	Case2shift:
		cmp al,'@'
		jne Case3
		mov al,202   
		jmp Break	

	Case3:
		cmp al,'3'
		jne Case3shift
		mov al,217  
		jmp Break
	Case3shift:
		cmp al,'#'
		jne Case4
		mov al,188    
		jmp Break
		
	Case4:
		cmp al,'4'
		jne Case4shift
		mov al,195   
		jmp Break
	Case4shift:
		cmp al,'$'
		jne Case5
		mov al,204     
		jmp Break		

	Case5:
		cmp al,'5'
		jne Case5shift
		mov al,197    
		jmp Break
	Case5shift:
		cmp al,'%'
		jne Case6
		mov al,206      
		jmp Break	

	Case6:
		cmp al,'6'
		jne Case6shift
		mov al,180     
		jmp Break
	Case6shift:
		cmp al,'^'
		jne Case7
		mov al,185       
		jmp Break
		
	Case7:
		cmp al,'7'
		jne Case7shift
		mov al,218      
		jmp Break
	Case7shift:
		cmp al,'&'
		jne Case8
		mov al,201        
		jmp Break	

	Case8:
		cmp al,'8'
		jne Case8shift
		mov al,194       
		jmp Break
	Case8shift:
		cmp al,'*'
		jne Case9
		mov al,203         
		jmp Break

	Case9:
		cmp al,'9'
		jne Case9shift
		mov al,191       
		jmp Break
	Case9shift:
		cmp al,'('
		jne Case0
		mov al,187          
		jmp Break	

	Case0:
		cmp al,'0'
		jne Case0shift
		mov al,179        
		jmp Break
	Case0shift:
		cmp al,')'
		jne CaseMinus
		mov al,186           
		jmp Break
	
	CaseMinus:
		cmp al,'-'
		jne CaseMinusShift
		mov al,196        
		jmp Break
	CaseMinusShift:
		cmp al,'_'
		jne DrawInsertKeyReturn
		mov al,205            
	Break:
	mov bx,Location
	mov String[bx],al 
	call setStringToVideo
	
	DrawInsertKeyReturn:
	ret
			
edit:;edits string and corresponding video in accordance to the value of the key as in Text Edit Mode. arguments: ax=scan code of key 	
	;arrow keys
	call ArrowTest	
	cmp bx,0
	jne editReturn
	
	;backspace
	cmp ax,0E08h	    
	jne EditInsertTest
	call BackSpace
	jmp editReturn
	
	;any other key 	
	EditInsertTest:
	call insertKey
	
	editReturn:
	ret
		
draw:;edits string and corresponding video in accordance to the value of the key as in Draw Mode. arguments: ax=scan code of key 	
	;arrow keys
	call ArrowTest
	cmp bx,0
	jne DrawReturn
	
	;backspace
	cmp ax,0E08h
	jne ClearTest
		mov bx,Location
		mov String[bx],' '
		call setStringToVideo
		call PlaceCursor
	jmp DrawReturn
	
	;clear if pressed c or C
	ClearTest:
	cmp al,'c'
	je Clear
	cmp al,'C'
	jne DrawInsertTest
		Clear:
		call ClearStringAndDisplay
	jmp DrawReturn
	
	;any other key 
	DrawInsertTest:
	call DrawInsertKey
	
	DrawReturn:
	ret
		
createFile:;creates and opens new file 
	Mov ah,3ch
	mov dx,offset FileName
	mov cx,6
	int 21h
	mov Handle,ax 
	jc Create_error
	ret
Create_error:;error handling for createFile
add al,'0'
mov BYTE PTR es:[160],al
sub al,'0'
mov BYTE PTR es:[162],'O'
jmp LastLine	

openFile:
	mov ax,3d02h 
    mov dx,offset FileName
    int 21h 
    jc Open_error 
    mov Handle,ax
    ret
Open_error:;error handling for createFile
	add al,'0'
	mov BYTE PTR es:[640],al
	sub al,'0'
	mov BYTE PTR es:[642],'O'
	cmp ax,2
	jne LastLineJump
	ret
	LastLineJump: jmp LastLine
			
closeFile:;closes file
	mov ah,3eh
	mov bx,Handle
	int 21h
	jc Close_error
	ret
Close_error:;error handling for closeFile
add al,'0'
mov BYTE PTR es:[480],al
sub al,'0'
mov BYTE PTR es:[482],'C'
jmp LastLine

readFileToBuffer:
	mov	ah,3fh 
    mov bx,Handle 
    mov cx,BufferSize 
    mov dx,offset Buffer 
    int 21h 
    jc read_error
read_error:
add al,'0'
mov BYTE PTR es:[800],al
sub al,'0'
mov BYTE PTR es:[802],'R'
jmp closeFile

writeBufferToFile:;writes contents of the buffer to string
	mov ah,40h
	mov bx,Handle 
	mov cx,BufferSize
	mov dx,offset Buffer
	int 21h
	jc Write_error
	ret
Write_error:
add al,'0'
mov BYTE PTR es:[320],al
sub al,'0'
mov BYTE PTR es:[322],'W'
jmp closeFile	
		
CopyStringToBuffer:;copies string contents to buffer while adding new line characters every 81th character of string
	sub bx,bx 
	sub cx,cx 
	CopyStringToBufferL1:
		mov dx,cx
		add dx,80
		CopyStringToBufferL2:
		
			push bx 
			mov bx,cx 
			mov al,String[bx]
			pop bx 
			
			mov Buffer[bx],al
			
			inc bx
			inc cx 
			
			cmp cx,dx 
			jb CopyStringToBufferL2
		mov Buffer[bx],13
		inc bx 
		mov Buffer[bx],10
		inc bx 
		cmp cx,StringSize
		jb CopyStringToBufferL1
	ret
	
writeStingToFile:;writes contents of string to buffer and then buffer to file
	call CopyStringToBuffer
	call writeBufferToFile
	ret		

CopyBufferToString:; copies buffer to string
	sub cx,cx
	sub bx,bx
	CopyBufferToStringL:
		cmp Buffer[bx],10
		je CopyBufferToString_increment
		cmp Buffer[bx],13
		je CopyBufferToString_increment
			mov al,Buffer[bx]
			push bx
			mov bx,cx 
			mov String[bx],al
			pop bx
			
			inc cx
	CopyBufferToString_increment:	
	inc bx 
	cmp cx,StringSize
	jb CopyBufferToStringL
	ret

setFileAndString:;creates/opens a file and sets up string
	call openFile
	cmp ax,2
	jne ReadFileToString
		call createFile
		jmp setFileAndStringReturn
	ReadFileToString:
		call readFileToBuffer
		call CopyBufferToString
		call createFile
	setFileAndStringReturn:	
	ret
	
start:

mov ax,0B800h
mov es,ax ;sets es to video segment

;set textEdit or draw mode
call setMode

;sets File and string
call setFileAndString

;set String to video
call setStringToVideo

;Sets cursor
call PlaceCursor

ctrl:

;write to keyboard
sub ax,ax
int 16h

;if key==quitkey jmp to QuitProgram
cmp ax,Quitkey
jne TestIfModeToggle
jmp QuitProgram

;if press F1, mode is toggled
TestIfModeToggle:
cmp ax,3B00h
jne TestIfTextEditMode
xor Mode,1
mov al,Mode
add al,'0'
mov es:[3840],al
jmp ctrl 

;if textEdit mode, call edit function
TestIfTextEditMode:
cmp Mode,0 
jne TestIfDrawMode
call edit
jmp ctrl

;else call draw function
TestIfDrawMode:
call draw
jmp ctrl

QuitProgram:

call ClearScreen;clears screen

;writes String to file 
call writeStingToFile

;close file 
call closeFile

LastLine:
INT 20h
cseg ends
	end start0