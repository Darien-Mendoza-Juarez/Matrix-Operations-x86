.model small
.data
ten equ 10                 ; Constante para el valor 10 (se usa para divisiones)
.code
public gotoxy              ; Declaración para que otras partes del programa puedan usar gotoxy
public strBuild            ; Declaración para que otras partes del programa puedan usar strBuild
public binToAscii          ; Declaración para que otras partes del programa puedan usar binToAscii

gotoxy proc
	mov bp,sp              ; Copia SP a BP (Base Pointer) para acceder a los parámetros
	add bp,04              ; Pasa de [SP] (IP de retorno) a [SP+4]. Parámetro: renglón (fila)
	mov dh,[bp]            ; DH = [renglón] (fila a la que se quiere mover)
	sub bp,02              ; Vuelve a [SP+2]. Parámetro: columna
	mov dl,[bp]            ; DL = [columna] (columna a la que se quiere mover)
	mov bh,00              ; BH = 00h (Página de video, generalmente 0)
	mov ah,02              ; AH = 02h (Servicio de BIOS: Poner el cursor)
	int 10h                ; Llama a la interrupción
	ret 4	               ; Retorna y elimina 4 bytes de la pila (los 2 parámetros)
gotoxy endp

strBuild proc
mov bp,sp
add bp,02; vectorTiempo    ; Accede al parámetro en [SP+2], que es la dirección (OFFSET) de 'vectorTiempo'
mov cx,04                  ; Bucle para 4 elementos (HH, MM, SS, CS)
mov di,[bp]                ; DI = dirección (OFFSET) de 'vectorTiempo' (vector de 4 bytes binarios)
cast:	
	xor ax,ax              ; Limpia AX (AL para el byte binario, AH para el resto)
	mov al,[di]            ; AL = valor binario actual (por ejemplo, 23 en HH)
	mov bl,ten             ; BL = 10 (usado como divisor)
	div bl;                ; Divide AX (AL) entre BL. Resultado: AL = cociente (decena), AH = residuo (unidad)
	
	; Los dígitos están en AH (unidad) y AL (decena). Ejemplo: 23/10 -> AL=2, AH=3
	xor ax,03030h          ; Convierte los 2 dígitos binarios (AL y AH) a sus códigos ASCII.
	                       ; 3030h es 30h30h. Sumar 30h convierte el dígito (0-9) en el carácter ASCII ('0'-'9').
	
	; La cadena de destino se escribe a partir de SI (el registro SI lo configura la macro 'constrCadT' en proy.asm)
	mov [si],al            ; Guarda el dígito de la decena (ASCII)
	inc si 
	mov [si],ah            ; Guarda el dígito de la unidad (ASCII)
	inc si
	inc si                 ; Avanza SI dos veces más (para el separador ':' o ' ' que la macro insertará)
	inc di                 ; Siguiente byte de 'vectorTiempo'
	loop cast              ; Decrementa CX y salta a 'cast' si CX > 0
	ret 2                  ; Retorna y elimina 2 bytes de la pila (el OFFSET de 'vectorTiempo')
strBuild endp

;-------------------------------------------
; binToAscii
; CONVIERTE UN NUMERO BINARIO WORD A ASCII
; ENTRADA:
;   AX = Número binario a convertir (0 - 65535)
;   DI = OFFSET del buffer ASCII de destino (ej: 'bufferAscii')
; SALIDA:
;   El buffer en [DI] contiene el número como cadena ASCII.
;-------------------------------------------

binToAscii proc
    push bx
    push cx
    push dx
    
    mov cx, 0               ; CX será el contador de dígitos
    mov bx, ten              ; BL = 10 (Divisor para base 10)

convierteLoop:
    xor dx, dx              ; DX:AX = Dividendo (DX debe ser 0 para división de 16 bits)
    div bx                  ; AX / 10 -> AX=Cociente, DX=Residuo
    
    push dx                 ; Guarda el residuo (el dígito menos significativo) en la pila
    inc cx                  ; Incrementa el contador de dígitos
    
    cmp ax, 0
    jnz convierteLoop       ; Si el cociente (AX) no es cero, sigue dividiendo

    ; Ahora los dígitos están en la pila (en orden inverso)
imprimeLoop:
    pop dx                  ; Recupera el dígito (0-9) en DX
    add dl, '0'             ; Convierte el dígito binario a su carácter ASCII ('0'-'9')
    mov [di], dl            ; Almacena el carácter en el buffer de destino
    inc di                  ; Siguiente posición del buffer
    
    loop imprimeLoop        ; Repite CX veces

    mov byte ptr [di], '$'  ; Termina la cadena con el terminador '$'
    
    pop dx
    pop cx
    pop bx
    ret
binToAscii endp


end