; resuelve el segmento de datos
initr macro
	mov ax, @data
	mov ds, ax  ;
	mov es, ax  ; el segmento extra lo apuntamos al segmentos de datos	
endm
;limpia pantalla
clrscr macro
	MOV AH,0FH;		limpia pantalla
	INT 10H
	MOV AH,0
	INT 10H	
endm
; omite cursor
cursorOff macro
	mov ah,01h
	mov cx,02607h
	int 10h
endm
;ubica cursor
gotoxyM macro ren, col
	pusha
	mov RENGLON,ren
	mov COLUMNA,col
	push RENGLON
	push COLUMNA
	call gotoxy
	popa
endm
; obteniendo el tiempo
snapTime macro
	mov ah,02Ch
	int 21h
endm
;construyendo cadena de tiempo
constrCadT macro dirVect
	pusha
	push dirVect
	call strBuild
	popa
endm 
; imprimir cadena
impCad macro nomCad
	mov ah,09
	mov dx, offset nomCad
	int 21h
endm