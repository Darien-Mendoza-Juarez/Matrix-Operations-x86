;------------------------------------------
;  Menú de operaciones con matrices + reloj
;  usando macros.inc y librería de proc + matrices
;------------------------------------------
include macros.inc

.286
.model small
.stack 64
.data
;--- cadenas del menu ---
TITULO      db 'OPERACIONES CON MATRICES','$'
OP_SUMA     db 'A) Suma de 2 Matrices','$'
OP_TRANSPUESTA db 'B) Obtener transpuesta','$'
OP_MULTIPLICACION db 'C) Multiplicar MATRICES','$'
OP_DIAGONAL db 'D) Diagonal Principal y Suma','$'
OP_SUMA_COL db 'E) Suma de Columnas de una matriz','$'
OP_SUMA_REN db 'F) Suma de Renglones de una matriz','$'

MSJ_OPC_INCOMPLETA db 'Opcion aun no implementada.',13,10
            db 'Presione ESC para regresar al menu.','$'
			
; --- matrices para las opciones
MAT_A        db 16 dup(0)
MAT_B        db 16 dup(0)
MAT_SUMA     db 16 dup(0)

MSJ_MAT_1     db 'Inserte la matriz 1 por renglon',13,10
            db 'ingresar los datos separados por ","','$'
MSJ_MAT_2     db 'Inserte la matriz 2 por renglon',13,10
            db 'ingresar los datos separados por ","','$'

MSJ_TITULO_IZ  db 'Estas son las matrices insertadas','$'
MSJ_TITULO_DER db 'Esta es la suma de las matrices','$'
MSJ_PRESS_I    db 'Presione I para ver la suma o ESC para regresar','$'


; --- matriz para opcion B (Transpuesta) ---
MAT_TRANS     db 16 dup(0)

MSJ_MAT_T_1     db 'Inserte la matriz para obtener su transpuesta',13,10
             db 'ingresar los datos separados por ","','$'
MSJ_TIT_ORIG   db 'Matriz original','$'
MSJ_TIT_TRANS  db 'Matriz transpuesta','$'
MSJ_PRESS_IT   db 'Presione I para ver la transpuesta o ESC para regresar','$'


;------- mensajes para opcion D (Diagonal y Total)----
MSJ_DIAG_T     db 'Inserte la matriz para obtener su Diagonal y Suma',13,10
MSJ_S_DIAG  db 'Suma de Diagonal Principal: ','$'
MSJ_S_TOTAL db 'Suma Total de Matriz: ','$'
BUFFER_DIAG  db 6 dup('$')
BUFFER_TOTAL db 6 dup('$')
MSJ_PRESS_ID   db 'Presione I para ver la diagonal y Suma o ESC para regresar','$'

; --- mensajes para Suma de Columnas/Renglones ---
MSJ_COLUMNA_TOTAL db 'La suma de las columnas es: ','$'
MSJ_RENGLON_TOTAL db 'La suma de los renglones es: ','$'
MSJ_PRESS_I_SC db 'Presione I para ver la suma o ESC para regresar','$' 
MSJ_COMA db ', ','$'

; --- Vectores para almacenar las sumas ---
VECTOR_SUMA_REN  db 4 dup(0)
VECTOR_SUMA_COL  db 4 dup(0)

; --- Buffers para imprimir resultados--- 
BUFFER_SUMA   db 6 dup('$')
BUFFER_RESULTADOS_REN db 30 dup('$')


; --- reloj estilo ckLib ---
TIEMPO      db 'HH:MM:SS:CS','$'
RENGLON     dw 0
COLUMNA     dw 0
VECTOR_TIEMPO db 4 dup(0)


.code
; procedimientos externos de la libreria
extrn gotoxy:proc, strBuild:proc, binToAscii:proc
extrn leerMatriz:proc, sumarMatrices:proc, imprimirMatriz:proc, transponerMatrices:proc, DiagonalyTotalMatrices:proc
extrn SumaRenglones:proc, SumaColumnas:proc


;------------------------------------------
; Actualiza la cadena "TIEMPO" y la imprime
; ENTRADA: Ninguna
; SALIDA: TIEMPO actualizado e impreso en pantalla
;------------------------------------------
UpdateClock PROC
    snapTime

    mov  VECTOR_TIEMPO,   ch
    mov  VECTOR_TIEMPO+1, cl
    mov  VECTOR_TIEMPO+2, dh
    mov  VECTOR_TIEMPO+3, dl

    mov  si, OFFSET TIEMPO
    mov  di, OFFSET VECTOR_TIEMPO
    constrCadT di

    gotoxyM 3,33
    impCad  TIEMPO
    ret
UpdateClock ENDP

;------------------------------------------
; Dibuja el menu principal
; ENTRADA: Ninguna
; SALIDA: Menu impreso en pantalla
;------------------------------------------
Menu PROC
    clrscr

    gotoxyM 1,28
    impCad  TITULO
    gotoxyM 5,20
    impCad  OP_SUMA
    gotoxyM 6,20
    impCad  OP_TRANSPUESTA
    gotoxyM 7,20
    impCad  OP_MULTIPLICACION
    gotoxyM 8,20
    impCad  OP_DIAGONAL
    gotoxyM 9,20
    impCad  OP_SUMA_COL
    gotoxyM 10,20
    impCad  OP_SUMA_REN
    ret
Menu ENDP

;------------------------------------------
; Pantalla temporal para opciones no implementadas
; ENTRADA: Ninguna
; SALIDA: Muestra mensaje y espera ESC
;------------------------------------------
OpcionIncompleta PROC
    clrscr

    gotoxyM 10,15
    impCad  MSJ_OPC_INCOMPLETA

EsperarESC:
    mov ah,00h
    int 16h

    cmp al,27
    jne EsperarESC

    ret
OpcionIncompleta ENDP

;------------------------------------------
; Pantalla para Opción A: Suma de matrices
; ENTRADA: Ninguna
; SALIDA: MAT_SUMA = MAT_A + MAT_B
;------------------------------------------
PantallaSumaMatrices PROC

    ; ===== PANTALLA 1 - Lectura de matrices =====
    clrscr

    gotoxyM 5,25
    impCad  MSJ_MAT_1

    gotoxyM 8,5
    mov di,OFFSET MAT_A
    call leerMatriz

    gotoxyM 13,25
    impCad  MSJ_MAT_2

    gotoxyM 16,5
    mov di,OFFSET MAT_B
    call leerMatriz

    gotoxyM 20,10
    impCad  MSJ_PRESS_I

EsperarI:
    mov ah,00h
    int 16h

    cmp al,27
    je  SalirPantallaA

    cmp al,'I'
    je  MostrarSuma
    cmp al,'i'
    je  MostrarSuma
    jmp EsperarI

SalirPantallaA:
    ret

MostrarSuma:
    ; ===== CALCULAR SUMA DE MATRICES =====
    push OFFSET MAT_A
    mov  dx,OFFSET MAT_B
    push dx
    mov  dx,OFFSET MAT_SUMA
    push dx
    call sumarMatrices
    pop ax
    pop ax
    pop ax

    ; ===== PANTALLA 2 - Mostrar resultados =====
    clrscr

    gotoxyM 3,10
    impCad  MSJ_TITULO_IZ

    gotoxyM 3,45
    impCad  MSJ_TITULO_DER

    ; imprimir matriz A
    mov di,OFFSET MAT_A
    mov dh,6
    mov dl,10
    call imprimirMatriz

    ; imprimir matriz B
    mov di,OFFSET MAT_B
    mov dh,11
    mov dl,10
    call imprimirMatriz

    ; imprimir matriz suma
    mov di,OFFSET MAT_SUMA
    mov dh,6
    mov dl,45
    call imprimirMatriz

EsperarEscA:
    mov ah,00h
    int 16h
    cmp al,27
    jne EsperarEscA

    ret
PantallaSumaMatrices ENDP


;------------------------------------------
; Pantalla para Opción B: Transpuesta
; ENTRADA: Ninguna
; SALIDA: MAT_TRANS = Transpuesta de MAT_A
;------------------------------------------
PantallaTranspuesta PROC

    ; ===== PANTALLA 1 - Lectura de matriz =====
    clrscr

    gotoxyM 5,20
    impCad  MSJ_MAT_T_1

    gotoxyM 8,5
    mov di,OFFSET MAT_A
    call leerMatriz

    gotoxyM 20,10
    impCad  MSJ_PRESS_IT

EsperarIB:
    mov ah,00h
    int 16h

    cmp al,27
    je  SalirPantallaB

    cmp al,'I'
    je  MostrarTransp
    cmp al,'i'
    je  MostrarTransp
    jmp EsperarIB

SalirPantallaB:
    ret

MostrarTransp:
    ; ===== CALCULAR TRANSPUESTA =====
    push OFFSET MAT_A
    mov  dx,OFFSET MAT_TRANS
    push dx
    call transponerMatrices
    pop  ax
    pop  ax

    ; ===== PANTALLA 2 - Mostrar resultados =====
    clrscr

    gotoxyM 3,10
    impCad  MSJ_TIT_ORIG

    gotoxyM 3,45
    impCad  MSJ_TIT_TRANS

    ; imprimir matriz original
    mov di,OFFSET MAT_A
    mov dh,6
    mov dl,10
    call imprimirMatriz

    ; imprimir matriz transpuesta
    mov di,OFFSET MAT_TRANS
    mov dh,6
    mov dl,45
    call imprimirMatriz

EsperarEscB:
    mov ah,00h
    int 16h
    cmp al,27
    jne EsperarEscB

    ret
PantallaTranspuesta ENDP


;------------------------------------------
; Pantalla para Opcion D: Diagonal Principal y Suma
; ENTRADA: Ninguna
; SALIDA: Muestra Suma Diagonal y Suma Total de MAT_A
;------------------------------------------
PantallaDiagonalyTotal PROC

    clrscr

    gotoxyM 5,20
    impCad  MSJ_MAT_1

    gotoxyM 8,5
    mov di,OFFSET MAT_A
    call leerMatriz

    gotoxyM 20,10
    impCad  MSJ_PRESS_IT

EsperarID:
    mov ah,00h
    int 16h

    cmp al,27
    je  SalirPantallaD

    cmp al,'I'
    je  MostrarDyTSuma
    cmp al,'i'
    je  MostrarDyTSuma
    jmp EsperarID

SalirPantallaD:
    ret

MostrarDyTSuma:
    mov di,OFFSET MAT_A
    call DiagonalyTotalMatrices ; Resultados: BX = Diagonal, CX = Total

    clrscr

    gotoxyM 3,10
    impCad  MSJ_TIT_ORIG

    mov di,OFFSET MAT_A
    mov dh,6
    mov dl,10
    call imprimirMatriz

    ; --- Mostrar Titulos de Resultados ---
    gotoxyM 3, 40
    impCad MSJ_S_DIAG

    gotoxyM 4, 40
    impCad MSJ_S_TOTAL

    ; --- Suma Diagonal (BX) ---
    gotoxyM 3, 70
    mov ax, bx
    mov di, OFFSET BUFFER_DIAG
    call binToAscii
    impCad BUFFER_DIAG

    ; --- Suma Total (CX) ---
    gotoxyM 4, 70
    mov ax, cx
    mov di, OFFSET BUFFER_TOTAL
    call binToAscii
    impCad BUFFER_TOTAL

EsperarEscD:
    mov ah,00h
    int 16h
    cmp al,27
    jne EsperarEscD

    ret
PantallaDiagonalyTotal ENDP


;------------------------------------------
; Pantalla para Opción E: Suma de Columnas
; ENTRADA: Ninguna
; SALIDA: Muestra las 4 sumas de columnas de MAT_A
;------------------------------------------
PantallaSumaColumnas PROC
    clrscr

    gotoxyM 5,20
    impCad MSJ_MAT_1

    gotoxyM 8,5
    mov di,OFFSET MAT_A
    call leerMatriz

    gotoxyM 20,10
    impCad MSJ_PRESS_I_SC

EsperarIE:
    mov ah,00h
    int 16h

    cmp al,27
    je  SalirPantallaE

    cmp al,'I'
    je  MostrarSumaC
    cmp al,'i'
    je  MostrarSumaC
    jmp EsperarIE

SalirPantallaE:
    ret

MostrarSumaC:
    mov di,OFFSET MAT_A
    mov si,OFFSET VECTOR_SUMA_COL
    call SumaColumnas

    clrscr

    gotoxyM 3,10
    impCad MSJ_TIT_ORIG
    mov di,OFFSET MAT_A
    mov dh,6
    mov dl,10
    call imprimirMatriz

    gotoxyM 6, 40
    impCad MSJ_COLUMNA_TOTAL

    mov si, OFFSET VECTOR_SUMA_COL
    mov cx, 4

imprimeResultadosC:
    push cx

    mov al, [si]
    xor ah, ah

    mov di, OFFSET BUFFER_SUMA
    call binToAscii

    impCad BUFFER_SUMA

    pop cx

    cmp cx, 1
    je  finBucleColumnas

    impCad MSJ_COMA

finBucleColumnas:
    inc si
    loop imprimeResultadosC

EsperarEscE:
    mov ah,00h
    int 16h
    cmp al,27
    jne EsperarEscE

    ret
PantallaSumaColumnas ENDP

;------------------------------------------
; Pantalla para Opción F: Suma de Renglones
; ENTRADA: Ninguna
; SALIDA: Muestra las 4 sumas de renglones de MAT_A
;------------------------------------------
PantallaSumaRenglones PROC
    clrscr

    ; ===== FASE 1: Lectura de Matriz =====
    gotoxyM 5,20
    impCad MSJ_MAT_1

    gotoxyM 8,5
    mov di,OFFSET MAT_A
    call leerMatriz

    gotoxyM 20,10
    impCad MSJ_PRESS_I_SC

EsperarIF:
    mov ah,00h
    int 16h

    cmp al,27
    je  SalirPantallaF

    cmp al,'I'
    je  MostrarSumaR
    cmp al,'i'
    je  MostrarSumaR
    jmp EsperarIF

SalirPantallaF:
    ret

MostrarSumaR:
    mov di,OFFSET MAT_A
    mov si,OFFSET VECTOR_SUMA_REN
    call SumaRenglones

    clrscr

    ;Imprimir Matriz Original
    gotoxyM 3,10
    impCad MSJ_TIT_ORIG
    mov di,OFFSET MAT_A
    mov dh,6
    mov dl,10
    call imprimirMatriz

    gotoxyM 6, 30
    impCad MSJ_RENGLON_TOTAL

    mov si, OFFSET VECTOR_SUMA_REN
    mov cx, 4

imprimeResultados:
    push cx

    mov al, [si]
    xor ah, ah

    mov di, OFFSET BUFFER_SUMA
    call binToAscii

    impCad BUFFER_SUMA

    pop cx

    cmp cx, 1
    je  finBucleRenglones

    impCad MSJ_COMA

finBucleRenglones:
    inc si
    loop imprimeResultados

EsperarEscF:
    mov ah,00h
    int 16h
    cmp al,27
    jne EsperarEscF

    ret
PantallaSumaRenglones ENDP


;------------------------------------------
;  PROCEDIMIENTO PRINCIPAL
;------------------------------------------
Main PROC FAR
    initr
    clrscr
    cursorOff

MenuPrincipal:
    call Menu

EsperaTecla:
    call UpdateClock

    mov ah,01h
    int 16h
    jz  EsperaTecla

    mov ah,00h
    int 16h

    cmp al,27
    je  Salir

    cmp al,'A'
    je  OpcionA
    cmp al,'a'
    je  OpcionA

    cmp al,'B'
    je  OpcionB
    cmp al,'b'
    je  OpcionB

    cmp al,'C'
    je  OpcionC
    cmp al,'c'
    je  OpcionC

    cmp al,'D'
    je  OpcionD
    cmp al,'d'
    je  OpcionD

    cmp al,'E'
    je  OpcionE
    cmp al,'e'
    je  OpcionE

    cmp al,'F'
    je  OpcionF
    cmp al,'f'
    je  OpcionF

    jmp MenuPrincipal

OpcionA:
    call PantallaSumaMatrices
    jmp  MenuPrincipal

OpcionB:
	call PantallaTranspuesta
    jmp  MenuPrincipal
OpcionC:
    call OpcionIncompleta
    jmp  MenuPrincipal
OpcionD:
    call PantallaDiagonalyTotal
    jmp  MenuPrincipal
OpcionE:
    call PantallaSumaColumnas
    jmp  MenuPrincipal
OpcionF:
    call PantallaSumaRenglones
    jmp  MenuPrincipal

Salir:
    clrscr
    mov ah,4Ch
    mov al,0
    int 21h
Main ENDP

END Main