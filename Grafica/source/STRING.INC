; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        STRING.INC - Macros de funciones de operaciones con cadenas.
; --------------------------------------------------------------------------- 

            IFDEF _STRING_ASM
                PUBLIC  _fstrlen, _fstrcpy, _fistrcpy, _strcat, _strcmpn,
                PUBLIC  _toupper
            ELSE
                EXTRN   _fstrlen:NEAR, _fstrcpy:NEAR, _fistrcpy:NEAR,
                EXTRN   _strcat:NEAR, _strcmpn:NEAR, _toupper:NEAR
            ENDIF

; --------------------------------------------------------------------------- 
;     Calcular la longitud de una cadena ASCIIZ
;
;        Entrada:
;
;        seg:str = Cadena de texto ASCIIZ.
;
;        Salida:
;
;        cx = Longitud de la cadena.
; ---------------------------------------------------------------------------

fstrlen     MACRO       seg, orig

            push        seg OFFSET orig         ; Guardar par metros.
            call        _fstrlen                ; Llamar al procedimiento

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular la longitud de una cadena ASCIIZ
;
;        Entrada:
;
;        ds:str = Cadena de texto ASCIIZ.
;
;        Salida:
;
;        cx = Longitud de la cadena.
; ---------------------------------------------------------------------------

strlen      MACRO       str

            fstrlen     ds, str                 ; Calcular el tama¤o.

            ENDM

; --------------------------------------------------------------------------- 
;     Copiar una cadena ASCIIZ
;
;        Entrada:
;
;        dseg:dest = Cadena destino de texto ASCIIZ.
;        oseg:orig = Cadena origen de texto ASCIIZ.
; ---------------------------------------------------------------------------

fstrcpy     MACRO       dseg, dest, oseg, orig

            push        oseg OFFSET orig        ; Guardar par metros.
            push        dseg OFFSET dest        
            call        _fstrcpy                ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Copiar una cadena ASCIIZ
;
;        Entrada:
;
;        ds:dest = Cadena destino de texto ASCIIZ.
;        ds:orig = Cadena origen de texto ASCIIZ.
; ---------------------------------------------------------------------------

strcpy      MACRO       dest, orig

            fstrcpy     ds, dest, ds, orig      ; Copiar la cadena.

            ENDM

; --------------------------------------------------------------------------- 
;     Copiar una cadena ASCIIZ empezando por el final de la misma
;
;        Entrada:
;
;        dseg:dest = Cadena destino de texto ASCIIZ.
;        oseg:orig = Cadena origen de texto ASCIIZ.
; ---------------------------------------------------------------------------

fistrcpy    MACRO       dseg, dest, oseg, orig

            push        oseg OFFSET orig        ; Guardar par metros.
            push        dseg OFFSET dest        
            call        _fistrcpy               ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Copiar una cadena ASCIIZ empezando por el final de la misma
;
;        Entrada:
;
;        ds:dest = Cadena destino de texto ASCIIZ.
;        ds:orig = Cadena origen de texto ASCIIZ.
; ---------------------------------------------------------------------------

istrcpy     MACRO       dest, orig

            fistrcpy     ds, dest, ds, orig     ; Copiar la cadena.

            ENDM

; ---------------------------------------------------------------------------
;     Encadenar dos cadenas ASCIIZ
;
;        Entrada:
;
;        ds:dest = Cadena destino de texto ASCIIZ.
;        ds:orig = Cadena origen de texto ASCIIZ.
; ---------------------------------------------------------------------------

strcat      MACRO       dest, orig

            push        OFFSET orig OFFSET dest ; Guardar par metros.
            call        _strcat                 ; Llamar al procedimiento

            ENDM

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

strcmpn     MACRO       s1, s2, n

            push        n OFFSET s1 OFFSET s2   ; Guardar par metros.
            call        _strcmpn                ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Pasar todos los caracteres alfab‚ticos de una cadena
;     ASCIIZ a masy£sculas
;
;        Entrada:
;
;        ds:dest = Cadena de texto ASCIIZ.
; ---------------------------------------------------------------------------

toupper     MACRO       dest

            push        OFFSET dest             ; Guardar par metros.
            call        _toupper                ; Llamar al procedimiento

            ENDM
