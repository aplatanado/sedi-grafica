; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        STRING.ASM - Procedimientos de las funciones de operaciones
;                     con cadenas.
; ---------------------------------------------------------------------------

.MODEL SMALL

_STRING_ASM EQU         0

            INCLUDE     STRING.INC

; ---------------------------------------------------------------------------

.CODE
.386

; --------------------------------------------------------------------------- 
;     Calcular la longitud de una cadena ASCIIZ
;
;        Entrada:
;
;        orig = Cadena de texto ASCIIZ.
;
;        Salida:
;
;        cx = Longitud de la cadena.
; ---------------------------------------------------------------------------

_fstrlen    PROC
            ARG         orig:FAR PTR = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax si ds

            ; Buscar el final de la cadena.
            xor         cx, cx                  ; cx = contador = 0.
            lds         si, orig                ; ds:si = puntero a la cadena
            cld
@sl1:
            lodsb                               ; al = caracter de cadena.
            test        al, al                  ; Si al = NULL salir.
            jz          @sl2
            inc         cx                      ; Si no incrementar cx y
            jmp         @sl1                    ; repetir.

@sl2:       ; Retornar del procedimiento.
            pop         ds si ax
            pop         bp
            ret         ARGLEN

_fstrlen    ENDP

; --------------------------------------------------------------------------- 
;     Copiar una cadena ASCIIZ
;
;        Entrada:
;
;        dest = Cadena destino de texto ASCIIZ.
;        orig = Cadena origen de texto ASCIIZ.
; ---------------------------------------------------------------------------

_fstrcpy    PROC
            ARG         dest:FAR PTR, orig:FAR PTR = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        cx si di ds es

            ; Cargar acceso a las cadenas.
            lds         si, orig
            les         di, dest

            ; Copiar la cadena.
            strlen      si                      ; cx = longitud origen.
            inc         cx
            cld
            rep movsb                           ; Copiar cadena.

            ; Retornar del procedimiento.
            pop         es ds di si cx
            pop         bp
            ret         ARGLEN

_fstrcpy    ENDP

; ---------------------------------------------------------------------------
;     Copiar una cadena ASCIIZ empezando por el final de la misma
;
;        Entrada:
;
;        dest = Cadena destino de texto ASCIIZ.
;        orig = Cadena origen de texto ASCIIZ.
; ---------------------------------------------------------------------------

_fistrcpy   PROC
            ARG         dest:FAR PTR, orig:FAR PTR = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        cx si di ds es

            ; Cargar acceso a las cadenas.
            lds         si, orig                ; ds:si = cadena origen.
            les         di, dest                ; es:di = cadena destino.
            strlen      si                      ; cx = longitud origen.
            add         si, cx                  ; ds:si = fin cadena origen.
            add         di, cx                  ; es:di = fin cadena destino.
            inc         cx

            ; Copiar la cadena.
            std
            rep movsb                           ; Copiar cadena.

            ; Retornar del procedimiento.
            pop         es ds di si cx
            pop         bp
            ret         ARGLEN

_fistrcpy   ENDP

; ---------------------------------------------------------------------------
;     Encadenar dos cadenas ASCIIZ
;
;        Entrada:
;
;        ds:dest = Cadena destino de texto ASCIIZ.
;        ds:orig = Cadena origen de texto ASCIIZ.
; ---------------------------------------------------------------------------

_strcat     PROC
            ARG         dest:NEAR PTR, orig:NEAR PTR = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        cx si di

            ; Encadenar las dos cadenas.
            mov         si, orig                ; si = offset origen
            mov         di, dest                ; di = offset destino.
            strlen      di                      ; cx = longitud destino.
            add         di, cx
            strcpy      di, si                  ; Copiar la cadena origen.

            ; Retornar del procedimiento.
            pop         di si cx
            pop         bp
            ret         ARGLEN

_strcat     ENDP

; ---------------------------------------------------------------------------
;     Comparar los n primeros caracteres de dos cadenas ASCIIZ
;
;        Entrada:
;
;        ds:s1 = Cadena destino de texto ASCIIZ.
;        ds:s2 = Cadena origen de texto ASCIIZ.
;        n = N£mero de caracteres a comparar.
;
;        Salida:
;
;        El registro de flags se actualiza como lo har¡a
;        con la instrucci¢n cmp
; ---------------------------------------------------------------------------

_strcmpn    PROC
            ARG         dest:NEAR PTR, orig:NEAR PTR, n:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        cx si di es

            ; Cargar acceso a las cadenas.
            mov         si, orig                ; si = offset origen.
            mov         cx, ds
            mov         es, cx                  ; es = segmento destino.
            mov         di, dest                ; di = offset destino.

            ; Comparar sucesivamente n caracteres.
            cld
            mov         cx, n                   ; cx = n§ de caracteres.
            rep cmpsb

            ; Retornar del procedimiento.
            pop         es di si cx
            pop         bp
            ret         ARGLEN

_strcmpn    ENDP

; ---------------------------------------------------------------------------
;     Pasar todos los caracteres alfab‚ticos de una cadena
;     ASCIIZ a masy£sculas
;
;        Entrada:
;
;        ds:dest = Cadena de texto ASCIIZ.
; ---------------------------------------------------------------------------

_toupper    PROC
            ARG         dest:NEAR PTR = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax si

            ; Cargar acceso a la cadena.
            mov         si, dest                ; si = offset cadena.

@tp1:       ; Realizar la conversi¢n.
            mov         al, [si]                ; al = caracter.
            test        al, al                  ; Salir si hemos alcanzado
            jz          @tp3                    ; el final de la cadena.
            cmp         al, 'a'                 ; Ignorar si no es un
            jb          @tp2                    ; caracter alfab‚tico en   
            cmp         al, 'z'                 ; min£sculas.
            ja          @tp2
            sub         al, 'a' - 'A'           ; Pasar a may£sculas.
            mov         [si], al                ; Guardar.
@tp2:
            inc         si
            jmp         @tp1                    ; Siguiente caracter.

@tp3:       ; Retornar del procedimiento.
            pop         si ax
            pop         bp
            ret         ARGLEN

_toupper    ENDP

            END
