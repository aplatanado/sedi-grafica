; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        STACK.ASM - Procedimientos de las funciones de pila.
; --------------------------------------------------------------------------- 

.MODEL SMALL

_STACK_ASM  EQU         0

            INCLUDE     SYSTEM.INC              ; Funciones del sistema.
            INCLUDE     STACK.INC

; ---------------------------------------------------------------------------
;     Estructuras de informaci¢n y almacenamiento de la pila
; ---------------------------------------------------------------------------

            ; Estructura de cada elemento almacenado en la pila.
ITEM_STRUC  STRUC

lowval      dd          ?                       ; DD inferior del elemento.
highval     dd          ?                       ; DD superior del elemento.

ITEM_STRUC  ENDS

            ; Estructura de informaci¢n de la pila.
STACK_INFO  STRUC

stackid     dw          ?                       ; Tipo de pila.
pushitem    dw          ?                       ; Puntero cima para push.
popitem     dw          ?                       ; Puntero cima para pop.
lastitem    dw          ?                       ; Puntero al £ltimo elemento.
items       ITEM_STRUC  ?                       ; Almacen de elementos.

STACK_INFO  ENDS

            ; Accesos a los elementos de las estructuras.
STSTACKID   EQU         <es:STACK_INFO[0].stackid>
STPUSHITEM  EQU         <es:STACK_INFO[0].pushitem>
STPOPITEM   EQU         <es:STACK_INFO[0].popitem>
STLASTITEM  EQU         <es:STACK_INFO[0].lastitem>
STITEMS     EQU         <es:STACK_INFO[0].items>
ITEMLOW     EQU         <es:ITEM_STRUC[di].lowval>
ITEMHIGH    EQU         <es:ITEM_STRUC[di].highval>

; ---------------------------------------------------------------------------

.CODE
.386

; --------------------------------------------------------------------------- 
;     Crear una pila de almacenamiento
;
;        Entrada:
;
;        numitems = N£mero m ximo de elementos a almacenar.
;        stid  = Identificador del tipo de pila.
;
;        Salida:
;
;        ax = Manejador de la pila.
;
;        Si cf = 0: No error
;           ax = Manejador de la pila.
;        Si cf = 1: Error al crear la pila
; --------------------------------------------------------------------------- 

_allocstack PROC
            ARG         numitems:WORD, stid:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        dx es

            ; Reservar la cantidad de memoria requerida.
            mov         ax, numitems            ; ax = n£mero de elementos.
            shl         ax, 3                   ; ax = ax * 8
            jc          @as2                    ; Saltar si overflow.
            mov         dx, ax                   
            add         ax, SIZE STACK_INFO     ; ax = Tama¤o estructura pila
            jc          @as2                    ; Saltar si overflow.
            malloc      ax                      ; Reservar memoria.
            jc          @as2                    ; Salir si error.

            ; Cargar la direcci¢n de acceso a la informaci¢n de la pila.
            mov         es, ax                  ; es:[0] = Info de la pila.

            ; Inicializar cima push.
            mov         ax, OFFSET STITEMS      ; ax = offset de items
            mov         STPUSHITEM, ax          ; cima push = 1§ elemento.

            ; Inicializar puntero al £ltimo elemento.
            add         ax, dx
            mov         STLASTITEM, ax          ; Ultimo elemento.

            ; Inicializar indicador de tipo de pila.
            mov         ax, stid                ; ax = tipo de pila.
            mov         STSTACKID, ax           ; Indicar el tipo de pila.

            ; Determinar el tipo de pila
            cmp         ax, LIFOSTACK
            jne         @as1                    ; Saltar si FIFO.

            ; Inicializar cima pop (LIFO).
            mov         ax, STPUSHITEM
            mov         STPOPITEM, ax           ; cima pop = cima push.

@as1:       ; Inicializar cima pop (FIFO).
            mov         ax, STLASTITEM
            mov         STPOPITEM, ax           ; cima pop = £ltimo elemento

            ; Devolver el manejador de la pila
            mov         ax, es
            clc                                 ; No error.

@as2:       ; Retornar del procedimiento.
            pop         es dx
            pop         bp
            ret         ARGLEN

_allocstack ENDP

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

_freestack  PROC
            ARG         handler:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp

            ; Liberar la memoria reservada.
            free        handler

            ; Retornar del procedimiento.
            pop         bp
            ret         ARGLEN   

_freestack  ENDP

; ---------------------------------------------------------------------------
;     Almacenar un valor en la pila indicada (LIFO)
;
;        Entrada:
;
;        es:0 = Puntero a la estructura de informaci¢n de la pila.
;        edx:eax = Valor a almacenar.
; ---------------------------------------------------------------------------

_stpushLIFO PROC

            ; Inicializar el procedimiento.
            push        di

            ; Almacenar el valor.
            mov         di, STPUSHITEM          ; di = puntero a la cima.
            mov         ITEMLOW, eax
            mov         ITEMHIGH, edx           ; Guardar valor.

            ; Desplazar la cima evitando el acceso a zonas
            ; de memoria fuera de la pila.
            add         di, SIZE ITEM_STRUC     ; [di] = siguiente elemento.
            cmp         di, STLASTITEM          ; Saltar si nueva cima
            jna         @pul1                   ; <= fin pila.
            mov         di, OFFSET STITEMS      ; [di] = primer elemento.
@pul1:
            mov         STPUSHITEM, di          ; cima push = nueva cima.
            mov         STPOPITEM, di           ; cima pop = nueva cima.
                        
            ; Retornar del procedimiento.
            pop         di
            ret

_stpushLIFO ENDP

; ---------------------------------------------------------------------------
;     Almacenar un valor en la pila indicada (FIFO)
;
;        Entrada:
;
;        es:0 = Puntero a la estructura de informaci¢n de la pila.
;        edx:eax = Valor a almacenar.
; ---------------------------------------------------------------------------

_stpushFIFO PROC

            ; Inicializar el procedimiento.
            push        di

            ; Almacenar el valor.
            mov         di, STPUSHITEM          ; di = puntero a la cima.
            mov         ITEMLOW, eax
            mov         ITEMHIGH, edx           ; Guardar valor.

            ; Desplazar la cima evitando el acceso a zonas
            ; de memoria fuera de la pila.
            add         di, SIZE ITEM_STRUC     ; [di] = siguiente elemento.
            cmp         di, STLASTITEM          ; Saltar si nueva cima
            jna         @puf1                   ; <= fin pila.
            mov         di, OFFSET STITEMS      ; [di] = primer elemento.
@puf1:
            mov         STPUSHITEM, di          ; cima push = nueva cima.
                        
            ; Retornar del procedimiento.
            pop         di
            ret

_stpushFIFO ENDP

; ---------------------------------------------------------------------------
;     Almacenar un valor en la pila
;
;        Entrada:
;
;        handler = Manejador de la pila.
;        edx:eax = Valor a almacenar.
; ---------------------------------------------------------------------------

_stpush     PROC
            ARG         handler:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        es

            ; Cargar la direcci¢n de acceso a la informaci¢n de la pila.
            mov         es, handler             ; es:[0] = Info de la pila.

            ; Determinar el tipo de pila
            cmp         STSTACKID, LIFOSTACK    
            jne         @pu1                    ; Saltar si no LIFO.
            call        _stpushLIFO             ; Guardar el valor (LIFO).
            jmp         @pu2                    ; Salir.
@pu1:
            call        _stpushFIFO             ; Guardar el valor (FIFO).
                        
@pu2:       ; Retornar del procedimiento.
            pop         es
            pop         bp
            ret         ARGLEN

_stpush     ENDP

; ---------------------------------------------------------------------------
;     Extraer un valor de la pila (LIFO)
;
;        Entrada:
;
;        es:bx = Puntero a la estructura de informaci¢n de la pila.
;
;        Salida:
;
;        edx:eax = Valor extraido.
;
;        Si cf = 0: No error
;        Si cf = 1: Error de underflow
; ---------------------------------------------------------------------------

_stpopLIFO PROC

            ; Inicializar el procedimiento.
            push        di

            ; Detectar principio de la pila.
            mov         di, STPOPITEM           ; di = Puntero a la cima.
            mov         ax, OFFSET STITEMS      ; ax = Puntero principio pila
            cmp         di, ax
            jne         @pol1                   ; Saltar si principio pila.
            stc                                 ; Indicar underflow.             
            jmp         @pol2                    

@pol1:      ; Desplazar la cima.
            sub         di, SIZE ITEM_STRUC     ; [di] = elemento anterior.
            mov         STPOPITEM, di           ; cima pop = nueva cima.
            mov         STPUSHITEM, di          ; cima push = nueva cima.

            ; Extraer el valor de la pila.
            mov         eax, ITEMLOW
            mov         edx, ITEMHIGH
            clc                                 ; No underflow.

@pol2:      ; Retornar del procedimiento.
            pop         di
            ret

_stpopLIFO ENDP

; ---------------------------------------------------------------------------
;     Extraer un valor de la pila (FIFO)
;
;        Entrada:
;
;        es:bx = Puntero a la estructura de informaci¢n de la pila.
;
;        Salida:
;
;        edx:eax = Valor extraido.
;
;        Si cf = 0: No error
;        Si cf = 1: Error de underflow
; ---------------------------------------------------------------------------

_stpopFIFO PROC

            ; Inicializar el procedimiento.
            push        si di

            ; Cargar punteros de las cimas.
            mov         di, STPOPITEM           ; di = puntero a cima pop.
            mov         si, STPUSHITEM          ; si = puntero a cima push.

            ; Desplazar la cima evitando el acceso a zonas
            ; de memoria fuera de la pila.
            cmp         di, STLASTITEM          ; Saltar si nueva cima
            jne         @pof2                   ; != fin pila.
            mov         ax, OFFSET STITEMS      ; ax = Puntero principio pila
            cmp         si, ax
            jne         @pof1                   ; Saltar si no underflow.
            stc                                 ; Indicar underflow.
            jmp         @pof4                   ; Salir.
@pof1:
            mov         di, ax                  ; di = principio pila.
            jmp         @pof3
@pof2:
            add         di, SIZE ITEM_STRUC     ; [di] = elemento siguiente.
            cmp         di, si
            jne         @pof3                   ; Saltar si no underflow.
            stc                                 ; Indicar underflow.
            jmp         @pof4                   ; Salir.

@pof3:      ; Extraer el valor de la pila.
            mov         STPOPITEM, di           ; cima push = nueva cima.
            mov         eax, ITEMLOW
            mov         edx, ITEMHIGH
            clc                                 ; No principio de pila.

@pof4:      ; Retornar del procedimiento.
            pop         di si
            ret

_stpopFIFO ENDP

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

_stpop      PROC
            ARG         handler:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        es

            ; Cargar la direcci¢n de acceso a la informaci¢n de la pila.
            mov         es, handler             ; es:[0] = Info de la pila.

            ; Determinar el tipo de pila
            cmp         STSTACKID, LIFOSTACK
            jne         @po1                    ; Saltar si no LIFO.
            call        _stpopLIFO              ; Extraer el valor (LIFO).
            jmp         @po2                    ; Salir.
@po1:
            call        _stpopFIFO              ; Extraer el valor (FIFO).
                        
@po2:       ; Retornar del procedimiento.
            pop         es
            pop         bp
            ret         ARGLEN

_stpop      ENDP

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

_stacksize  PROC
            ARG         handler:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        es

            ; Cargar la direcci¢n de acceso a la informaci¢n de la pila.
            mov         es, handler             ; es:[0] = Info de la pila.

            ; Realizar el c lculo.
            mov         ax, STLASTITEM
            sub         ax, OFFSET STITEMS
            shr         ax, 3                   ; ax = ax / 8
            inc         ax                      ; ax = ax + 1

            ; Retornar del procedimiento.
            pop         es
            pop         bp
            ret         ARGLEN

_stacksize  ENDP

; ---------------------------------------------------------------------------
;     Resetear la cima pop de la pila indicada.
;
;        Entrada:
;
;        handler = Manejador de la pila.
; ---------------------------------------------------------------------------

_resetpop   PROC
            ARG         handler:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax es

            ; Cargar la direcci¢n de acceso a la informaci¢n de la pila.
            mov         es, handler             ; es:[0] = Info de la pila.

            ; Determinar el tipo de pila
            cmp         STSTACKID, LIFOSTACK    
            jne         @ro1                    ; Saltar si no LIFO.
            mov         STPOPITEM, OFFSET ITEMS ; Resetear (LILO).
            jmp         @ro2                    ; Salir.
@ro1:
            mov         ax, STLASTITEM
            mov         STPOPITEM, ax           ; Resetear (FIFO).
                        
@ro2:       ; Retornar del procedimiento.
            pop         es ax
            pop         bp
            ret         ARGLEN

_resetpop   ENDP

            END
