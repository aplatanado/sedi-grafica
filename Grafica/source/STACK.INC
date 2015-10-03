; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        STACK.INC - Macros de las funciones de pila.
; --------------------------------------------------------------------------- 

            IFDEF _STACK_ASM
                PUBLIC  _allocstack, _freestack, _stpush, _stpop,
                PUBLIC  _stacksize, _resetpop
            ELSE
                EXTRN   _allocstack:NEAR, _freestack:NEAR, _stpush:NEAR
                EXTRN   _stpop:NEAR, _stacksize:NEAR, _resetpop:NEAR
            ENDIF

; ---------------------------------------------------------------------------

HSTACK      TYPEDEF     WORD                    ; Manejador de la pila.

; ---------------------------------------------------------------------------
;     Identificadores de tipos de pila
; ---------------------------------------------------------------------------

FIFOSTACK   EQU         1                       ; Pila FIFO.
LIFOSTACK   EQU         2                       ; Pila LIFO.

; --------------------------------------------------------------------------- 
;     Crear una pila FIFO de almacenamiento
;
;        Entrada:
;
;        numitems = N£mero m ximo de elementos a almacenar.
;
;        Salida:
;
;        Si cf = 0: No error
;           ax = Manejador de la pila.
;        Si cf = 1: Error al crear la pila
; ---------------------------------------------------------------------------

allocFIFO   MACRO       numitems

            push        FIFOSTACK numitems      ; Guardar par metros.
            call        _allocstack             ; Llamar al procedimiento

            ENDM

; --------------------------------------------------------------------------- 
;     Crear una pila LIFO de almacenamiento
;
;        Entrada:
;
;        numitems = N£mero m ximo de elementos a almacenar.
;
;        Salida:
;
;        Si cf = 0: No error
;           ax = Manejador de la pila.
;        Si cf = 1: Error al crear la pila
; ---------------------------------------------------------------------------

allocLIFO   MACRO       numitems

            push        LIFOSTACK numitems      ; Guardar par metros.
            call        _allocstack             ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Destruir una pila de almacenamiento
;
;        Entrada:
;
;        handler = Manejador de la pila.
;
;        Salida:
;
;        Si cf = 0: No error
;        Si cf = 1: Error al destruir la pila
; ---------------------------------------------------------------------------

freestack   MACRO       handler
            
            push        handler                 ; Guardar par metros.
            call        _freestack              ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Almacenar un valor en la pila
;
;        Entrada:
;
;        handler = Manejador de la pila.
;        edx:eax = Valor a almacenar.
; ---------------------------------------------------------------------------

stpush      MACRO       handler
           
            push        handler                 ; Guardar par metros.
            call        _stpush                 ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Extraer un valor de la pila
;
;        Entrada:
;
;        handler = Manejador de la pila.
;
;        Salida:
;
;        edx:eax = Valor extraido.
;
;        Si cf = 0: No error
;        Si cf = 1: Error de underflow
; ---------------------------------------------------------------------------

stpop       MACRO       handler
            
            push        handler                 ; Guardar par metros.
            call        _stpop                  ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Calcular el n£mero m ximo de elementos que puede almacenar una pila.
;
;        Entrada:
;
;        handler = Manejador de la pila.
;
;        Salida:
;
;        ax = N£mero m ximo de elementos que puede almacenar.
; ---------------------------------------------------------------------------

stacksize   MACRO       handler

            push        handler                 ; Guardar par metros.
            call        _stacksize              ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Resetear la cima pop de la pila indicada.
;
;        Entrada:
;
;        handler = Manejador de la pila.
; ---------------------------------------------------------------------------

resetpop    MACRO       handler

            push        handler                 ; Guardar par metros.
            call        _resetpop               ; Llamar al procedimiento

            ENDM
