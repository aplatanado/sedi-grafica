; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        CALC.INC - Macros de las funciones de calculadora.
; --------------------------------------------------------------------------- 

            IFDEF _CALC_ASM
                PUBLIC  _topolaca, _calcular
            ELSE
                EXTRN   _topolaca:NEAR, _calcular:NEAR
            ENDIF

; --------------------------------------------------------------------------- 
;     Convertir una expresi¢n infija a notaci¢n polaca inversa
;
;        Entrada:
;
;        ds:expr = Cadena de texto ASCIIZ de la expresi¢n.
;
;        Salida:
;
;        Si cf = 0: No error
;           ax = Manejador de la pila con la expresi¢n en notaci¢n polaca.
;        Si cf = 1: Error durante la conversi¢n
;           ax = C¢digo del error.
; ---------------------------------------------------------------------------

topolaca    MACRO       expr

            push        OFFSET expr             ; Guardar par metros.
            call        _topolaca               ; Llamar al procedimiento

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular el resultado de una expresi¢n matem tica
;
;        Entrada:
;
;        handler = Manejador de la pila con la expresi¢n en notaci¢n polaca.
;        st(0) = Valor de la incognita x.
;
;        Salida:
;
;        Si cf = 0: No error
;           st(0) = Valor resultante del c lculo.
;        Si cf = 1: Error durante el c lculo
;           ax = C¢digo del error.
; ---------------------------------------------------------------------------

calcular    MACRO       handler

            push        handler                 ; Guardar par metros.
            call        _calcular               ; Llamar al procedimiento

            ENDM

