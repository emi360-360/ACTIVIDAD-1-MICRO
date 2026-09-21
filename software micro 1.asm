; =========================================================
; PROGRAMA Z80
; EEPROM: 0000
; SRAM:   F800
; PPI:    40 - 43
; =========================================================

.org 0

; =========================================================
; PUERTOS DEL PRIMER 8255
; =========================================================

PPI_PA   .equ 64
PPI_PB   .equ 65
PPI_PC   .equ 66
PPI_CTRL .equ 67


; =========================================================
; INICIO DEL PROGRAMA
; =========================================================

MAIN_START:

    ld sp,65535

    ; Puerto A = salida
    ; Puerto B = entrada
    ; Modo 0
    ld a,130
    out (PPI_CTRL),a


REINICIAR_PROG:

    ; Solicitar nombre y apellidos
    ld hl,MSJ_SOLICITAR
    call PRINT_STR

    ; Inicio del buffer en SRAM
    ld hl,BUFFER_NOMBRE

    ; Contador de letras
    ld b,0


; =========================================================
; LEER TECLADO
; =========================================================

LEER_TECLADO:

    ; Leer caracter
    in a,(PPI_PB)

    ; Si no hay caracter, esperar
    cp 0
    jr z,LEER_TECLADO

    ; ENTER
    cp 13
    jr z,MOSTRAR_RESULTADO

    ; ESPACIO
    cp 32
    jr z,ES_VALIDO

    ; Comprobar A-Z
    cp 65
    jr c,ERROR_CARACTER

    cp 91
    jr c,ES_LETRA

    ; Comprobar a-z
    cp 97
    jr c,ERROR_CARACTER

    cp 123
    jr nc,ERROR_CARACTER

    jr ES_LETRA


; =========================================================
; LETRA VALIDA
; =========================================================

ES_LETRA:

    inc b


ES_VALIDO:

    ; Mostrar caracter
    out (PPI_PA),a

    ; Guardar caracter en SRAM
    ld (hl),a
    inc hl

    jr LEER_TECLADO


; =========================================================
; ERROR
; =========================================================

ERROR_CARACTER:

    ld hl,MSJ_ERROR
    call PRINT_STR

    jr REINICIAR_PROG


; =========================================================
; MOSTRAR RESULTADO
; =========================================================

MOSTRAR_RESULTADO:

    ; Terminar cadena
    ld (hl),0

    ; Salto de linea
    ld a,10
    out (PPI_PA),a

    ld a,13
    out (PPI_PA),a

    ; Mostrar mensaje
    ld hl,MSJ_RESULTADO
    call PRINT_STR

    ; Pasar contador a A
    ld a,b

    ; C = decenas
    ld c,0


; =========================================================
; DIVIDIR ENTRE 10
; =========================================================

DIV_DIEZ:

    cp 10
    jr c,MOSTRAR_NUM

    sub 10
    inc c

    jr DIV_DIEZ


MOSTRAR_NUM:

    ; Guardar unidades
    ld b,a

    ; Comprobar decenas
    ld a,c
    cp 0
    jr z,MOSTRAR_UNI

    ; Convertir decenas a ASCII
    add a,48
    out (PPI_PA),a


MOSTRAR_UNI:

    ; Convertir unidades a ASCII
    ld a,b
    add a,48
    out (PPI_PA),a

    ; Salto de linea
    ld a,10
    out (PPI_PA),a

    ld a,13
    out (PPI_PA),a

    ; Detener programa
    halt


; =========================================================
; SUBRUTINA PARA MOSTRAR CADENAS
; =========================================================

PRINT_STR:

    ld a,(hl)

    ; Fin de cadena
    cp 0
    ret z

    ; Mostrar caracter
    out (PPI_PA),a

    ; Siguiente caracter
    inc hl

    jr PRINT_STR


; =========================================================
; MENSAJES
; =========================================================

MSJ_SOLICITAR:

    .db "Ingrese su nombre y apellidos: ",0


MSJ_ERROR:

    .db 10,13
    .db "[ERROR] Caracter no valido. Use solo letras y espacios.",10,13,0


MSJ_RESULTADO:

    .db "La cantidad de letras que tiene su nombre es: ",0


; =========================================================
; BUFFER EN SRAM
; =========================================================

.org 63488

BUFFER_NOMBRE:

    .fill 60


; =========================================================
; FIN DEL PROGRAMA
; =========================================================

.end