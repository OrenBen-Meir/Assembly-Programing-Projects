;This program will run Minesweeper

assume cs:cseg, ds:cseg
cseg segment
org 100h; for .com
start0:	jmp start
	
;JUMPS;for tasm

;variables
Map db 50 dup(0);map is created with no bombs added, it is a 5x10 grid
ElementsLeft db 38 ; how many unopened blocks without bombs
R db 5; Number of rows in Map
C db 10; Number of columns in Map
y db 0; Which row cursor is on
X db 0; Which column cursor is on

;The arrays below represent text below the grid
PrintLine1 db 'Press a,s,d, and w to move. Press e to reveal an element marked as ',254,'.',0
PrintLine2 db 'You can not reveal a flagged element. Press f to set a flag.',0
PrintLine3 db 'Use q to quit. A message will pop below if you win,lose or quit. Have fun!',0

;arrays below represent text if the game ends
QuitString db 'You Quit. Press r to replay. Press other keys to exit game.',0
WinString db 'You win! Press r to replay. Press other keys to exit game.',0
LoseString db 'You lose :(  Press r to replay. Press other keys to exit game.',0	

;Procedures are placed here 
MapBuild:
	sub cx,cx
	MapBuildL1:
		mov dx,0
		MapBuildL2:
			call BxIndexSet
			mov BYTE PTR es:[bx],254
			inc bx
			mov BYTE PTR es:[bx],71h
			inc dl
			cmp dl,C 
			jb MapBuildL2
		inc cl 	
		cmp cl,R
		jb MapBuildL1
ret
ClearScreen:;clears screen
	mov ah,0fh
	push cx
	push bx
	mov al,' '
	mov cx,2000;80*25
	sub bx,bx
	LClearScreen: 
	mov es:[bx],ax
	add bx,2
	loop LClearScreen
	pop bx
	pop cx
	ret		
BxIndexSet:;args cl (for row indices) and dl (for collum indices) and converts to location in video, dh=0 and ch=0
	push ax
	sub ax,ax
	mov al,cl
	mov ah,160
	mul ah
	add ax,dx
	add ax,dx
	mov bx,ax
	pop ax
	ret
XYindexSetToBx:
	push cx
	push dx
	sub cx,cx
	sub dx,dx
	mov cl,y
	mov dl,x
	call BxIndexSet
	pop dx
	pop cx
	ret
PlaceCursor:
	call XYindexSetToBx
	inc bx
	mov BYTE PTR es:[bx],0F1h
	ret
RemoveCursor:
	call XYindexSetToBx
	inc bx
	mov BYTE PTR es:[bx],071h
	ret
PrintText:
	sub cx,cx
	mov cl,R 
	
	sub dx,dx	
	mov bx,dx
	PrintLine1L:
	mov al,PrintLine1[bx]
	call BxIndexSet
	mov es:[bx],al 
	inc dx 
	mov bx,dx 
	cmp BYTE PTR PrintLine1[bx],0
	jne PrintLine1L
	
	inc cl
	
	sub dx,dx	
	mov bx,dx
	PrintLine2L:
	mov al,PrintLine2[bx]
	call BxIndexSet
	mov es:[bx],al 
	inc dx 
	mov bx,dx 
	cmp BYTE PTR PrintLine2[bx],0
	jne PrintLine2L			
	
	inc cl
	
	sub dx,dx	
	mov bx,dx
	PrintLine3L:
	mov al,PrintLine3[bx]
	call BxIndexSet
	mov es:[bx],al 
	inc dx 
	mov bx,dx 
	cmp BYTE PTR PrintLine3[bx],0
	jne PrintLine3L
	
	ret
Quit:
	sub cx,cx
	mov cl,R 
	add cl,3
	
	sub dx,dx	
	mov bx,dx
	QuitL:
	mov al,QuitString[bx]
	call BxIndexSet
	mov es:[bx],al 
	inc dx 
	mov bx,dx 
	cmp BYTE PTR QuitString[bx],0
	jne QuitL
	ret
LoseReveal:
	call XYindexSetToBx
	mov BYTE PTR es:[bx],'b' 
	sub cx,cx
	mov cl,R 
	add cl,3
	
	sub dx,dx	
	mov bx,dx
	LoseL:
	mov al,LoseString[bx]
	call BxIndexSet
	mov es:[bx],al 
	inc dx 
	mov bx,dx 
	cmp BYTE PTR LoseString[bx],0
	jne LoseL
	ret
WinReveal:	
	sub cx,cx
	mov cl,R 
	add cl,3
	
	sub dx,dx	
	mov bx,dx
	WinL:
	mov al,WinString[bx]
	call BxIndexSet
	mov es:[bx],al 
	inc dx 
	mov bx,dx 
	cmp BYTE PTR WinString[bx],0
	jne WinL
	ret
CountReveal:
	dec ElementsLeft
	
	;s=0
	mov bl,0
	
	;top=y-1
	mov cl,y
	cmp y,0
	je endTopAssignment
	dec cl
	endTopAssignment:
	
	;bottom=y+1
	mov ch,y
	inc ch
	
	;left=x-1
	mov dl,x
	cmp x,0
	je endLeftAssignment
	dec dl
	endLeftAssignment:
	
	;right=x+1
	mov dh,x
	inc dh
	
	;if(y==R-1)
	mov bh,R 
	dec bh 
	cmp y,bh
	jne countSkip2
	dec ch 
	
	;if(x==c-1)
	countSkip2:
	mov bh,C 
	dec bh 
	cmp x,bh
	jne countL1
	dec dh
	
	countL1:
		push dx
		countL2:	
			sub ax,ax
			mov al,cl
			mov ah,C 
			mul ah 
			add al,dl
			adc ah,0
			xchg ax,bx
			add al,Map[bx]
			xchg ax,bx
			
			inc dl
			
			cmp dl,dH 
			jbe countL2		
		pop dx
		
		inc cl
		
		cmp cl,ch
		jbe countL1
	
	add bl,'0'
	xchg bx,ax
	call XYindexSetToBx
	mov es:[bx],al
	
	ret
MoveUp:
	cmp y,0
	je MoveUpReturn
	call RemoveCursor
	dec y
	call PlaceCursor
	MoveUpReturn:
	ret
MoveDown:
	mov bl,R
	dec bl
	cmp y,bl
	je MoveDownReturn
	call RemoveCursor
	inc y
	call PlaceCursor
	MoveDownReturn:
	ret
MoveLeft:
	cmp x,0
	je MoveLeftReturn
	call RemoveCursor
	dec x
	call PlaceCursor
	MoveLeftReturn:
	ret
MoveRight:
	mov bl,C
	dec bl
	cmp x,bl
	je MoveRightReturn
	call RemoveCursor
	inc x
	call PlaceCursor
	MoveRightReturn:
	ret		
FlagToggle:
	call XYindexSetToBx
	
	cmp BYTE PTR es:[bx],254
	jne F_remove
	;setFlag
	mov BYTE PTR es:[bx],'f'
	jmp FlagToggleReturn 
	
	F_remove:	
	cmp BYTE PTR es:[bx],'f'
	jne FlagToggleReturn
	mov BYTE PTR es:[bx],254
	
	FlagToggleReturn:
	ret	
;program starts	
start:	
	;bombs are stored in Map
	mov BYTE PTR Map[5],1
	mov BYTE PTR Map[14],1
	mov BYTE PTR Map[16],1
	mov BYTE PTR Map[23],1
	mov BYTE PTR Map[24],1
	mov BYTE PTR Map[25],1
	mov BYTE PTR Map[26],1
	mov BYTE PTR Map[27],1
	mov BYTE PTR Map[32],1
	mov BYTE PTR Map[38],1
	mov BYTE PTR Map[41],1
	mov BYTE PTR Map[49],1
	
	;video is set up
	mov ax,0B800h
	mov es,ax 
	Call ClearScreen ;Clears Screen	
	call MapBuild
	call PrintText
	call PlaceCursor
	
ctrl: ;get key		
	sub ax,ax
	int 16h
	
	;tests key	
	
	;if key is 'q'
	cmp al,'q'
	jne upTest
	call Quit
	jmp endGame
	
	;if key is 'w'
	upTest:
	cmp al,'w'
	jne DownTest
	call MoveUp
	jmp ctrl

	;if key is 's'
	DownTest:
	cmp al,'s'
	jne LeftTest
	call MoveDown 
	jmp ctrl
	
	;if key is 'a'
	LeftTest:
	cmp al,'a'
	jne RightTest
	call MoveLeft 
	jmp ctrl

	;if key is 'd'
	RightTest:
	cmp al,'d'
	jne eTest
	call MoveRight
	jmp ctrl		
	
	;if key is 'e'
	eTest:
	cmp al,'e'
	je eTrue
	jmp flagTest
	;code for selecting a cell to reveal or not
	eTrue:	
	call XYindexSetToBx
	cmp BYTE PTR es:[bx],254
	jne ctrl
	
	sub ax,ax
	mov al,y
	mov ah,C
	mul ah
	add al,x
	adc ah,0
	xchg ax,bx
	cmp byte ptr Map[bx],1
	jne NoBomb
	
	call LoseReveal
	jmp endGame
	
	NoBomb:
	
	call CountReveal
	
	cmp ElementsLeft,0
	jne ctrl
	
	call WinReveal
	jmp endGame

	;if key is 'f'
	flagTest:
	cmp al,'f'
	jne ctrl
	call FlagToggle
	jmp ctrl
endGame:
sub ax,ax
int 16h
cmp al,'r'
jne endProgram
mov BYTE PTR ElementsLeft,38
mov BYTE PTR x,0
mov BYTE PTR y,0
jmp start
endProgram:
INT 20h
cseg ends
	end start0	
