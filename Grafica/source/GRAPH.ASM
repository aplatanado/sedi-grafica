; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        GRAPH.ASM - Procedimientos de las funciones gr ficas.
; --------------------------------------------------------------------------- 

.MODEL SMALL

_GRAPH_ASM  EQU         0

            INCLUDE     GRAPH.INC

; ---------------------------------------------------------------------------

GRAPHSEG    EQU         0a000h                  ; Segmento gr fico.

; ---------------------------------------------------------------------------
;     Obtener la posici¢n f¡sica de un punto en la memoria
;
;        Entrada:
;
;        x = Coordenada X del punto.
;        y = Coordenada Y del punto.
;
;        Salida:
;
;        al = M scara de acceso.
;        di = Desplazamiento del byte del punto.
;
;        Modifica los registros:  ax cx dx
; ---------------------------------------------------------------------------

getpos      MACRO       x, y

            mov         ax, SCRCHWIDTH          ; ax = Ancho de pantalla.
            mul         y                       ; ax = 80 * y.
            mov         di, ax
            mov         ax, x                   ; ax = coordenada X.
            mov         cx, ax                  
            shr         ax, 3                   ; ax = ax/8
            add         di, ax                  ; di = offset del byte.

            and         cl, 07h                 ; cl = pos. del bit.
            mov         al, 80h                 ; al = 10000000b.
            shr         al, cl                  ; al = m scara.

            ENDM

; ---------------------------------------------------------------------------
;     Cargar la direcci¢n de la tabla de caracteres
;
;        Salida:
;
;        fs = Segmento que contiene la tabla.
;        bx = Desplazamiento del comienzo de la tabla.
; ---------------------------------------------------------------------------

ldtable     MACRO

            push        ax cx dx bp es
            
            mov         ax, 1130h               ; Informaci¢n de la tabla.
            mov         bh, 6h                  ; Tabla de 8x16.
            int         10h                     ; es:bp puntero a la tabla.
            mov         ax, es
            mov         fs, ax                          
            mov         bx, bp                  ; fs:bx puntero a la tabla.
            
            pop         es bp dx cx ax
            
            ENDM

; ---------------------------------------------------------------------------
;     Establecer el color con el que dibujar los puntos
;
;        Entrada:
;
;        color = Color con el que dibujar los puntos.
;
;        Modifica los registros:  ax dx
; ---------------------------------------------------------------------------

setcolor    MACRO       color

            xor         ax, ax                  
            mov         ah, color               ; ah = color.
            mov         dx, 03ceh               ; dx:[al] = reg. set/reset.
            out         dx, ax                  ; Cargar color.

            ENDM

; ---------------------------------------------------------------------------
;     Establecer el modo de funcionamiento de la VGA
;
;        Entrada:
;
;        modo = Byte indicador del modo de funcionamiento.
;
;        Modifica los registros:  ax dx
; ---------------------------------------------------------------------------

setmode     MACRO       modo

            mov         ax, 100h*modo + 0005h
            mov         dx, 03ceh               ; dx:[al] = reg. de modo. 
            out         dx, ax                  ; Habilitar modo.

            ENDM

; ---------------------------------------------------------------------------
;     Escribir un byte en la posici¢n es:[di] de la memoria de v¡deo
;
;        Entrada:
;
;        dato = Byte a escribir.
; ---------------------------------------------------------------------------

writebyte   MACRO       dato

            test        dato, es:[di]           ; Cargar latches VGA.
            mov         es:[di], dato           ; Escribir byte.

            ENDM

; ---------------------------------------------------------------------------

.DATA

oldmode     db          NOSCRMODE               ; Anterior modo de v¡deo.

; ---------------------------------------------------------------------------

.CODE
.386

; ---------------------------------------------------------------------------
;     Inicializar el modo gr fico
;
;        Salida:
;
;        Si cf = 0: No error
;        Si cf = 1: Error al inicializar el modo gr fico
; --------------------------------------------------------------------------- 

_initgraph  PROC

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax dx

            ; Obtener el modo de v¡deo actual.
            mov         ah, 0fh                 ; Funci¢n 0fh.
            int         10h                     ; Obtener modo de v¡deo.
            mov         dl, al                  ; dl = modo de v¡deo actual.

            ; Cambiar al modo gr fico.
            mov         al, SCRMODE             ; al = modo gr fico.
            xor         ah, ah                  ; Funci¢n 0h.
            int         10h                     ; Establecer modo de v¡deo.

            ; Comprobar que el modo solicitado est‚ activo.
            mov         ah, 0fh                 ; Funci¢n 0fh.
            int         10h                     ; Obtener modo de v¡deo.
            cmp         al, dl                  ; Si no son iguales
            jne         @ig1                    ; continuar...
            stc                                 ; en caso contrario indicar
            jmp         @ig3                    ; el error y salir.

@ig1:       ; Almacenar la informaci¢n del anterior modo de v¡deo
            ; si en necesario.
            cmp         oldmode, NOSCRMODE      ; Almacenar el modo si es
            jne         @ig2                    ; la primera vez que se
            mov         oldmode, dl             ; llama a la funci¢n.

@ig2:       ; Habilitar la escritura en todos los planos de bits.
            mov         ax, 0f02h               ; ah = 01111b.
            mov         dx, 03c4h               ; dx:[al] = reg. map mask. 
            out         dx, ax                  ; Habilitar escritura.

            ; Habilitar el modo 3 de escritura, el acceso a todos
            ; los bits de cada byte de la memoria de v¡deo, e inhabilitar
            ; la rotaci¢n de los datos escritos.
            setmode     03h                     ; Habilitar modo 3.
            mov         ax, 0ff08h              ; dx:[al] = reg. bit mask
            out         dx, ax                  ;  = 11111111b.
            mov         ax, 0003h               ; dx:[al] = reg. rotaci¢n. 
            out         dx, ax                  ; Cargar rotaci¢n = 0.
            clc                                 ; No error.

@ig3:       ; Retornar del procedimiento.
            pop         dx ax
            pop         bp
            ret         

_initgraph  ENDP

; ---------------------------------------------------------------------------
;     Terminar el modo gr fico
; --------------------------------------------------------------------------- 

_closegraph PROC

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax

            ; Volver al modo anterior, si es posible.
            mov         al, oldmode             ; al = modo gr fico.
            xor         ah, ah                  ; Funci¢n 0h.
            int         10h                     ; Establecer modo de v¡deo.

            ; Indicar que el modo gr fico no est  activo.
            mov         oldmode, NOSCRMODE

            ; Retornar del procedimiento.
            pop         ax
            pop         bp
            ret

_closegraph ENDP

; --------------------------------------------------------------------------- 
;     Dibujar un punto en pantalla
;
;        Entrada:
; 
;        x = Coordenada X del punto.
;        y = Coordenada Y del punto.
;        color = Color del punto.
; --------------------------------------------------------------------------- 

_drawpoint  PROC
            ARG         x:WORD, y:WORD ,color:BYTE = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax cx dx di es 

            ; Cargar segmento gr fico.
            mov         ax, GRAPHSEG
            mov         es, ax                  ; es = segmento gr fico.

            ; Dibujar el punto especificado.
            setcolor    color                   ; Cargar color.
            getpos      x, y                    ; Cargar posici¢n del punto.
            writebyte   al                      ; Escribir la m scara.

            ; Retornar del procedimiento.
            pop         es di dx cx ax
            pop         bp
            ret         ARGLEN

_drawpoint  ENDP

; --------------------------------------------------------------------------- 
;     Dibujar una l¡nea en pantalla (Algoritmo de Bresenham)
;
;        Entrada:
; 
;        x1 = Coordenada X del punto inicial.
;        y1 = Coordenada Y del punto inicial.
;        x2 = Coordenada X del punto final.
;        y2 = Coordenada Y del punto final.
;        color = Color de la l¡nea.
; --------------------------------------------------------------------------- 

_drawline   PROC
            ARG         x1:WORD, y1:WORD, x2:WORD, y2:WORD, \
                        color:BYTE = ARGLEN
            LOCAL       x:WORD, y:WORD, xdiff:WORD, ydiff:WORD, \
                        xunit:WORD, yunit:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax cx dx di es

            ; Cargar segmento gr fico.
            mov         ax, GRAPHSEG
            mov         es, ax                  ; es = segmento gr fico.

            ; Cargar el color de la l¡nea.
            setcolor    color

            ; Inicializar las variables locales de Y.
            mov         cx, y1                  ; cx = y1.
            mov         y, cx                   ; y = cx = y1.
            sub         cx, y2                  ; cx = y1 - y2.
            js          @l1                     ; Si negativo, salta...
            mov         ydiff, cx               ; Guardar diferencia.
            mov         yunit, -1               ; Guardar unidades neg.
            jmp         @l2                     ; Continuar.
@l1:
            neg         cx
            mov         ydiff, cx               ; Guardar diferencia en abs.
            mov         yunit, 1                ; Guardar unidades.

@l2:        ; Inicializar las variables locales de X.
            mov         ax, x1                  ; ax = x1.
            mov         x, ax                   ; x = ax = x1
            sub         ax, x2                  ; ax = x1 - x2.
            js          @l3                     ; Si negativo, salta...
            mov         xdiff, ax               ; Guardar diferencia.
            mov         xunit, -1               ; Guardar unidades neg.
            jmp         @l4                     ; Continuar.
@l3:
            neg         ax
            mov         xdiff, ax               ; Guardar diferencia en abs.
            mov         xunit, 1                ; Guardar unidades.

@l4:        ; Determinar la direcci¢n de dibujado.
            cmp         ax, cx                  ; Si xdiff > ydiff, contar
            jb          @l7                     ; en la direcci¢n Y,
            mov         cx, ax                  ; sino contar en la 
            inc         cx                      ; direcci¢n X.
            xor         dx, dx                  ; dx = t‚rmino error = 0.

@l5:        ; Dibujar el punto en pantalla. Direcci¢n X.
            push        cx dx
            getpos      x, y                    ; al = m scara, di = offset.
            writebyte   al                      ; Escribir la m scara.
            pop         dx cx

            ; Calcular la posici¢n del siguiente punto.
            mov         ax, x                   
            add         ax, xunit               ; Incrementar X.
            mov         x, ax                   
            add         dx, ydiff               ; error = error + ydiff.
            cmp         dx, xdiff               ; Si error < xdiff, 
            jb          @l6                     ; saltar al final.
            mov         ax, y                   
            add         ax, yunit               ; Si no incrementar Y.
            mov         y, ax
            sub         dx, xdiff               ; error = error - xdiff.
@l6:
            loop        @l5                     ; Siguiente punto.
            jmp         @lA                     ; Terminar el procedimiento.

@l7:        ; Contar en la direcci¢n Y.
            inc         cx                      ; contador = ydiff + 1.
            xor         dx, dx                  ; dx = t‚rmino error = 0.

@l8:        ; Dibujar el punto en pantalla.
            push        cx dx
            getpos      x, y                    ; al = m scara, di = offset.
            writebyte   al                      ; Escribir la m scara.
            pop         dx cx

            ; Calcular la posici¢n del siguiente punto.
            mov         ax, y                   
            add         ax, yunit               ; Incrementar Y.
            mov         y, ax
            add         dx, xdiff               ; error = error + xdiff.
            cmp         dx, ydiff               ; Si error < ydiff, 
            jb          @l9                     ; saltar al final.
            mov         ax, x                   
            add         ax, xunit               ; Si no incrementar X.
            mov         x, ax                   
            sub         dx, ydiff               ; error = error - ydiff.
@l9:
            loop        @l8                     ; Siguiente punto.
            
@lA:        ; Retornar del procedimiento.
            pop         es di dx cx ax
            mov         sp, bp
            pop         bp
            ret         ARGLEN

_drawline   ENDP

; --------------------------------------------------------------------------- 
;     Dibujar un rect ngulo en pantalla
;        (Los valores indicados para las coordenadas X son alineados
;        a un l¡mite m£ltiplo de SCRXCHAR)
;
;        Entrada:
; 
;        x1 = Coordenada X del punto inicial.
;        y1 = Coordenada Y del punto inicial.
;        x2 = Coordenada X del punto final.
;        y2 = Coordenada Y del punto final.
;        color = Color de relleno del rect ngulo.
; --------------------------------------------------------------------------- 

_drawbox    PROC
            ARG         x1:WORD, y1:WORD, x2:WORD, y2:WORD, \
                        color:BYTE = ARGLEN
            LOCAL       xinit:WORD, yinit:WORD, xdiff:WORD, \
                        ydiff:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax bx cx dx di es 
            
            ; Cargar segmento gr fico.
            mov         ax, GRAPHSEG
            mov         es, ax                  ; es = segmento gr fico.

            ; Determinar las dimensiones X del rect ngulo y la
            ; coordenada X inicial.
            mov         ax, x2
            sub         ax, x1                  ; ax = x2 - x1.
            jns         @b1                     ; Si positivo, saltar...
            neg         ax
            mov         dx, x2
            mov         xinit, dx               ; xinit = x2.
            jmp         @b2                     ; Continuar.
@b1:
            mov         dx, x1
            mov         xinit, dx               ; xinit = x1.
@b2:
            shr         ax, 3                   ; ax = abs(x2 - x1)/8
            inc         ax                      ; xdiff = valor inicial
            mov         xdiff, ax               ; del contador horizontal.
            
            ; Determinar las dimensiones Y del rect ngulo y la
            ; coordenada Y inicial.
            mov         ax, y2
            sub         ax, y1                  ; ax = y2 - y1.
            jns         @b3                     ; Si positivo, saltar...
            neg         ax
            mov         dx, y2
            mov         yinit, dx               ; yinit = y2.
            jmp         @b4                     ; Continuar.
@b3:
            mov         dx, y1
            mov         yinit, dx               ; yinit = y1.
@b4:
            inc         ax                      ; ax = abs(y2 - y1) + 1.
            mov         ydiff, ax               ; ydiff = valor inicial
                                                ; del contador horizontal.
            
            ; Cargar el color y la posici¢n real del primer punto.
            ; Al ignorar la m scara de bits estamos alineando a X.
            setcolor    color                   ; Cargar color.
            getpos      xinit, yinit            ; di = offset del punto.
            mov         bx, di                  ; bx = offset del punto.

            ; Inicializar registros para dibujar el rect ngulo.
            mov         al, 0ffh                ; al = m scara de puntos.
            mov         cx, ydiff               ; cx = contador vertical.
            mov         dx, xdiff               ; dx = contador horizontal.
            cld

@b5:        ; Bucle para el trazado de todas las l¡neas.
            xchg        cx, dx                  ; cx = contador horizontal.
            mov         di, bx                  ; di = offset del byte.
            rep stosb                           ; Trazar toda la l¡nea.
            add         bx, SCRCHWIDTH          ; bx = siguiente l¡nea.
            mov         cx, dx                  ; cx = contador vertical.
            mov         dx, xdiff               ; dx = contador horizontal.
            loop        @b5                     ; Trazar todas las l¡neas.
           
            ; Retornar del procedimiento.
            pop         es di dx cx bx ax
            mov         sp, bp
            pop         bp
            ret         ARGLEN

_drawbox    ENDP

; --------------------------------------------------------------------------- 
;     Imprimir un caracter en pantalla
;        (Los valores indicados para las coordenadas X son alineados
;        a un l¡mite m£ltiplo de SCRXCHAR)
;
;        Entrada:
; 
;        char = Caracter a imprimir.
;        x = Coordenada X inicial.
;        y = Coordenada Y inicial.
;        color = Color del texto.
; --------------------------------------------------------------------------- 

_drawchar   PROC
            ARG         char:WORD, x:WORD, y:WORD, color:BYTE = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax bx cx dx di es fs
           
            ; Cargar segmento gr fico.
            mov         ax, GRAPHSEG
            mov         es, ax                  ; es = segmento gr fico.

            ; Cargar el color y el desplazamiento del byte del punto.
            ; Al ignorar la m scara de bits estamos alineando a X.
            setcolor    color                   ; Cargar color.
            getpos      x, y                    ; di = offset del punto.

            ; Cargar la direcci¢n de la tabla de caracteres.
            ldtable                             ; fs:[bx] = tabla.

            ; C lcular la posici¢n del caracter en la tabla.
            mov         ax, char                ; ax = caracter.
            shl         ax, 4                   ; ax = ax*8.
            add         bx, ax                  ; bx = offset del caracter.

            ; Dibujar el caracter.
            mov         cx, SCRYCHAR            ; cx = n£mero de l¡neas.
@c1:
            mov         al, fs:[bx]             ; al = l¡nea del caracter.
            writebyte   al                      ; Escribir la l¡nea.
            add         di, SCRCHWIDTH
            inc         bx
            loop        @c1                     ; Siguiente l¡nea.

            ; Retornar del procedimiento.
            pop         fs es di dx cx bx ax
            pop         bp
            ret         ARGLEN

_drawchar   ENDP

; ---------------------------------------------------------------------------
;     Imprimir n caracteres de una cadena de texto en pantalla
;        (Los valores indicados para las coordenadas X son alineados
;        a un l¡mite m£ltiplo de SCRXCHAR)
;
;        Entrada:
; 
;        text = Cadena de texto ASCIIZ.
;        n = N§ de caracteres a imprimir.
;        x = Coordenada X inicial.
;        y = Coordenada Y inicial.
;        color = Color del texto.
; --------------------------------------------------------------------------- 

_drawnchar  PROC
            ARG         text:FAR PTR, n:WORD, x:WORD, y:WORD, \
                        color:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax cx dx si ds

            ; Inicializar variables locales.
            cld
            lds         si, text                ; ds:si = texto.
            mov         dx, x                   ; dx = coordenada Y.
            mov         cx, n                   ; cx = N§ de caracteres.
            jcxz        @nc2                    ; Salir si cx = 0.

@nc1:       ; Bucle para el trazado de la cadena.
            lodsb                               ; al = caracter.
            test        al, al                  ; Salir si se alcanz¢
            jz          @nc2                    ; un caracter igual a 0.
            xor         ah, ah                  ; ax = caracter.
            drawchar    ax, dx, y, color        ; Dibujar el caracter.
            add         dx, SCRXCHAR
            loop        @nc1                    ; Siguiente caracter.

@nc2:       ; Retornar del procedimiento.
            pop         ds si dx cx ax
            pop         bp
            ret         ARGLEN

_drawnchar  ENDP

; --------------------------------------------------------------------------- 
;     Copiar un bloque entre dos posiciones de la memoria de v¡deo.
;        (Los valores indicados para las coordenadas X son alineados
;        a un l¡mite m£ltiplo de SCRXCHAR)
;
;        Entrada:
; 
;        x = Coordenada X de destino.
;        y = Coordenada Y de destino.
;        x1 = Coordenada X del punto inicial del bloque origen.
;        y1 = Coordenada Y del punto inicial del bloque origen.
;        x2 = Coordenada X del punto final del bloque origen.
;        y2 = Coordenada Y del punto final del bloque origen.
; --------------------------------------------------------------------------- 

_drawcpy    PROC
            ARG         x:WORD, y:WORD, x1:WORD, y1:WORD, \
                        x2:WORD, y2:WORD = ARGLEN
            LOCAL       xinit:WORD, yinit:WORD, xdiff:WORD, \
                        ydiff:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax bx cx dx si di ds es

            ; Determinar las dimensiones X del bloque y la
            ; coordenada X inicial.
            mov         ax, x2
            sub         ax, x1                  ; ax = x2 - x1.
            jns         @cp1                    ; Si positivo, saltar...
            neg         ax
            mov         dx, x2
            mov         xinit, dx               ; xinit = x2.
            jmp         @cp2                    ; Continuar.
@cp1:
            mov         dx, x1
            mov         xinit, dx               ; xinit = x1.
@cp2:
            shr         ax, 3                   ; ax = abs(x2 - x1)/8
            inc         ax                      ; xdiff = valor inicial
            mov         xdiff, ax               ; del contador horizontal.
            
            ; Determinar las dimensiones Y del bloque y la
            ; coordenada Y inicial.
            mov         ax, y2
            sub         ax, y1                  ; ax = y2 - y1.
            jns         @cp3                    ; Si positivo, saltar...
            neg         ax
            mov         dx, y2
            mov         yinit, dx               ; yinit = y2.
            jmp         @cp4                    ; Continuar.
@cp3:
            mov         dx, y1
            mov         yinit, dx               ; yinit = y1.
@cp4:
            inc         ax                      ; ax = abs(y2 - y1) + 1.
            mov         ydiff, ax               ; ydiff = valor inicial
                                                ; del contador horizontal.

            ; Habilitar el modo 1 de escritura.
            setmode     01h

            ; Cargar punteros a los bloques de destino y fuente.
            mov         ax, GRAPHSEG
            mov         ds, ax                  ; ds = segmento gr fico.
            mov         es, ax                  ; es = segmento gr fico.
            getpos      x, y                    ; di = offset destino.
            mov         bx, di                  ; bx = offset destino.
            getpos      xinit, yinit            ; di = offset fuente.
            mov         dx, di                  ; dx = offset fuente.

            ; Inicializar registros para realizar la copia.
            mov         cx, ydiff               ; cx = contador vertical.
            cld

@cp5:       ; Bucle para el copiado de todas las l¡neas.
            push        cx                      ; Guardar contador vertical.
            mov         cx, xdiff               ; cx = contador horizontal.
            mov         si, dx                  ; di = offset fuente.
            mov         di, bx                  ; di = offset destino.
            rep movsb                           ; Copiar toda la l¡nea.
            add         dx, SCRCHWIDTH          ; dx = siguiente l¡nea.
            add         bx, SCRCHWIDTH          ; bx = siguiente l¡nea.
            pop         cx                      ; cx = contador vertical.
            loop        @cp5                    ; Trazar todas las l¡neas.

            ; Habilitar el modo 3 de escritura.
            setmode     03h

            ; Retornar del procedimiento.
            pop         es ds di si dx cx bx ax
            mov         sp, bp
            pop         bp
            ret         ARGLEN

_drawcpy    ENDP

            END
