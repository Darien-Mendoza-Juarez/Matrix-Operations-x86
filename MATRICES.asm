;===========================================
;   matrices.asm
;   Libreria para operaciones con matrices
;===========================================

.286
.model small
.stack 64

.data
CADENA_ENTRADA  db 50,0,50 dup(0)

FILA_INICIO     db 0
COLUMNA_INICIO  db 0

.code

public leerMatriz, sumarMatrices, imprimirMatriz, transponerMatrices, DiagonalyTotalMatrices, SumaRenglones, SumaColumnas


;-------------------------------------------
; leerMatriz (version 1 sola linea)
; ENTRADA:
;   DI = offset de la matriz (16 bytes)
; SALIDA:
;   Matriz llena con los 16 primeros digitos '0'..'9' de la entrada.
;-------------------------------------------
leerMatriz proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov dx,OFFSET CADENA_ENTRADA
    mov byte ptr [CADENA_ENTRADA+1],0
    mov ah,0Ah
    int 21h

    mov cl,byte ptr [CADENA_ENTRADA+1]
    mov ch,0
    mov si,OFFSET CADENA_ENTRADA+2

    mov bx,16

parseChar:
    cmp cx,0
    je  finLectura

    cmp bx,0
    je  finLectura

    lodsb
    dec cx

    cmp al,'0'
    jb  noDigito
    cmp al,'9'
    ja  noDigito

    sub al,'0'
    mov byte ptr [di],al
    inc di
    dec bx
noDigito:
    jmp parseChar
finLectura:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
leerMatriz endp


;-------------------------------------------
; sumarMatrices
; ENTRADA:
;   [BP+6] = OFFSET MAT_A (matA)
;   [BP+4] = OFFSET MAT_B (matB)
;   [BP+2] = OFFSET MAT_SUMA (matSuma)
; SALIDA:
;   [MAT_SUMA] = [MAT_A] + [MAT_B]
;-------------------------------------------
sumarMatrices proc
    mov bp,sp
    add bp,06

    mov si,word ptr [bp]
    dec bp
    dec bp
    mov di,word ptr [bp]
    mov bx,word ptr [bp-2]

    push cx
    push ax

    mov cx,16

sumLoop:
    mov al,byte ptr [si]
    add al,byte ptr [di]
    mov byte ptr [bx],al

    inc si
    inc di
    inc bx
    loop sumLoop

    pop ax
    pop cx
    ret
sumarMatrices endp

;-------------------------------------------
; imprimirMatriz
; ENTRADA:
;   DI = matriz 4x4 (16 bytes)
;   DH = fila inicial
;   DL = columna inicial
; SALIDA:
;   Matriz impresa en pantalla.
;-------------------------------------------
imprimirMatriz proc
    push ax
    push bx
    push cx
    push dx
    push di

    mov byte ptr FILA_INICIO,dh
    mov byte ptr COLUMNA_INICIO,dl

    xor bx,bx

filaLoop:
    cmp bl,4
    jge finImp

    mov dh,byte ptr FILA_INICIO
    add dh,bl
    mov dl,byte ptr COLUMNA_INICIO
    mov ah,02h
    mov bh,0
    int 10h

    mov cx,4

colLoop:
    mov al,byte ptr [di]
    add al,'0'
    mov dl,al
    mov ah,02h
    int 21h

    mov dl,' '
    mov ah,02h
    int 21h

    inc di
    loop colLoop

    inc bl
    jmp filaLoop

finImp:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
imprimirMatriz endp

;-------------------------------------------
; transponerMatrices
; ENTRADA:
;   [BP+4] = OFFSET MAT_A
;   [BP+2] = OFFSET MAT_TRANS
; SALIDA:
;   [MAT_TRANS] = Transpuesta de [MAT_A]
;-------------------------------------------
transponerMatrices proc
    mov bp,sp
    add bp,4

    mov si, [bp]
    mov di, [bp-2]

    push ax
    
    mov al,[si+0]
    mov [di+0],al
    mov al,[si+4]
    mov [di+1],al
    mov al,[si+8]
    mov [di+2],al
    mov al,[si+12]
    mov [di+3],al

    mov al,[si+1]
    mov [di+4],al
    mov al,[si+5]
    mov [di+5],al
    mov al,[si+9]
    mov [di+6],al
    mov al,[si+13]
    mov [di+7],al

    mov al,[si+2]
    mov [di+8],al
    mov al,[si+6]
    mov [di+9],al
    mov al,[si+10]
    mov [di+10],al
    mov al,[si+14]
    mov [di+11],al

    mov al,[si+3]
    mov [di+12],al
    mov al,[si+7]
    mov [di+13],al
    mov al,[si+11]
    mov [di+14],al
    mov al,[si+15]
    mov [di+15],al

    pop ax
    ret
transponerMatrices endp

;-------------------------------------------
; DiagonalyTotalMatrices
; ENTRADA:
;   DI = OFFSET de la matriz (MAT_A)
; SALIDA:
;   BX = Suma de la Diagonal Principal
;   CX = Suma Total
;-------------------------------------------
DiagonalyTotalMatrices proc
    push ax
    push si
    push dx
    
    xor bx, bx
    xor cx, cx
    
    mov si, di
    mov dx, 16

bucleSuma:
    mov al, [si]
    xor ah, ah
    add cx, ax

    mov ax, si
    sub ax, di

    cmp ax, 0
    je esDiagonal
    
    cmp ax, 5
    je esDiagonal

    cmp ax, 10
    je esDiagonal

    cmp ax, 15
    je esDiagonal
    jmp noDiagonal

esDiagonal:
    mov al, [si]
    xor ah, ah
    add bx, ax

noDiagonal:
    inc si
    dec dx
    jnz bucleSuma

    pop dx
    pop si
    pop ax
    ret
DiagonalyTotalMatrices endp


;-------------------------------------------
; SumaColumnas
; ENTRADA:
;   DI = offset de la matriz (MAT_A)
;   SI = offset del vector de resultados (VECTOR_SUMA_COL)
; SALIDA:
;   [SI] contiene las 4 sumas de las columnas (byte a byte).
;-------------------------------------------
SumaColumnas proc
    push ax
    push cx
    push di
    push si
    push bx
    
    mov bx, 0
    mov cx, 4

columnaLoopC:
    push cx
    
    xor ah, ah
    
    mov cx, 4
    
    push di
    add di, bx
    
filaLoopC:
    mov al, [di]
    add ah, al
    add di, 4
    loop filaLoopC
    
    mov [si], ah
    inc si
    
    pop di
    inc bx
    
    pop cx
    loop columnaLoopC
    
    pop bx
    pop si
    pop di
    pop cx
    pop ax
    ret
SumaColumnas endp

;-------------------------------------------
; SumaRenglones
; ENTRADA:
;   DI = offset de la matriz (MAT_A)
;   SI = offset del vector de resultados (VECTOR_SUMA_REN)
; SALIDA:
;   [SI] contiene las 4 sumas de los renglones (byte a byte).
;-------------------------------------------
SumaRenglones proc
    push ax
    push cx
    push di
    push si
    
    mov cx, 4
    
filaLoopR:
    push cx

    xor ah, ah
    mov cx, 4

columnaLoop:
    mov al, [di]
    add ah, al
    inc di
    loop columnaLoop
    
    mov [si], ah
    inc si
    
    pop cx
    loop filaLoopR
    
    pop si
    pop di
    pop cx
    pop ax
    ret
SumaRenglones endp

end