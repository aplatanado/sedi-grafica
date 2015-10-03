; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        INPUT.ASM - Procedimientos de las funciones los controles de
;                    entrada de datos.
; ---------------------------------------------------------------------------

.MODEL SMALL

_INPUT_ASM  EQU         0

            INCLUDE     SYSTEM.INC              ; Funciones del sistema.
            INCLUDE     GRAPH.INC               ; Funciones gr ficas.
            INCLUDE     STRING.INC              ; Funciones de cadenas.
            INCLUDE     INPUT.INC

; ---------------------------------------------------------------------------
;     Colores de los controles
; ---------------------------------------------------------------------------

BKGCOLOR    EQU         BLANCO + INTENSIDAD     ; Color de fondo.
L3DCOLOR    EQU         BLANCO + INTENSIDAD     ; Borde luminoso.
D3DCOLOR    EQU         GRIS                    ; Borde oscuro.
TXTCOLOR    EQU         NEGRO                   ; Color del texto.

; ---------------------------------------------------------------------------
;     Estructuras de informaci¢n y almacenamiento de los controles
; ---------------------------------------------------------------------------

            ; Estructura de informaci¢n general de los controles.
CTRL_INFO   STRUC

controlid   dw          ?                       ; Tipo de control.
controlproc dw          ?                       ; Procedimiento del control.
x1pos       dw          ?                       ; Coordenada X1 del control.
y1pos       dw          ?                       ; Coordenada Y1 del control.
x2pos       dw          ?                       ; Coordenada X2 del control.
y2pos       dw          ?                       ; Coordenada Y2 del control.
focusflag   dw          ?                       ; Indicador de foco.

CTRL_INFO   ENDS

            ; Estructura de informaci¢n de los controles de l¡nea de entrada.
INLINE_INFO STRUC

ctrlinfo    CTRL_INFO   ?                       ; Informaci¢n general.
inlwidth    dw          ?                       ; Ancho del control (char).
inlheight   dw          ?                       ; Alto del control (char).
cursorpos   dw          ?                       ; Indice cursor en buffer.
buffersize  dw          ?                       ; Tama¤o del buffer de texto.
buffer      db          ?                       ; Buffer de texto.

INLINE_INFO ENDS

            ; Accesos a los elementos de la estructura de informaci¢n
            ; general de los controles.
CTCONTROLID EQU         <es:CTRL_INFO[0].controlid>
CTPROC      EQU         <es:CTRL_INFO[0].controlproc>   
CTX1POS     EQU         <es:CTRL_INFO[0].x1pos>
CTY1POS     EQU         <es:CTRL_INFO[0].y1pos>
CTX2POS     EQU         <es:CTRL_INFO[0].x2pos>
CTY2POS     EQU         <es:CTRL_INFO[0].y2pos>
CTFOCUS     EQU         <es:CTRL_INFO[0].focusflag>

            ; Accesos a los elementos de la estructura de informaci¢n
            ; de los controles de l¡nea de entrada.
INWIDTH     EQU         <es:INLINE_INFO[0].inlwidth>
INHEIGHT    EQU         <es:INLINE_INFO[0].inlheight>
INCURPOS    EQU         <es:INLINE_INFO[0].cursorpos>
INBUFSIZE   EQU         <es:INLINE_INFO[0].buffersize>
INBUFFER    EQU         <es:INLINE_INFO[0].buffer>

; ---------------------------------------------------------------------------

.CODE
.386

; --------------------------------------------------------------------------- 
;     Crear un control de l¡nea de entrada de datos
;
;        Entrada:
;
;        x = Coordenada X del control (pixels).
;        y = Coordenada Y del control (pixels).
;        w = Ancho de la l¡nea de entrada de datos (char).
;        h = Alto de la l¡nea de entrada de datos (char).
;        ds:text = Texto por defecto para la l¡nea de entrada de datos.
;
;        Salida:
;
;        Si cf = 0: No error
;           ax = Manejador del control.
;        Si cf = 1: Error al crear el control
; ---------------------------------------------------------------------------

_inputline  PROC
            ARG         x:WORD, y:WORD, w:WORD, h:WORD, \
                        text:NEAR PTR = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        dx es

            ; Calcular el tama¤o del buffer de texto.
            mov         ax, w
            mul         h                       ; ax = tama¤o.
            jc          @il3                    ; Salir si overflow.

            ; Reservar la cantidad de memoria requerida.    
            mov         dx, ax                  ; dx = tama¤o.
            add         ax, SIZE INLINE_INFO-1  ; ax = Tama¤o estructura
            jc          @il3                    ; Saltar si overflow.
            malloc      ax                      ; Reservar memoria.
            jc          @il3                    ; Salir si error.

            ; Cargar la direcci¢n de acceso a la informaci¢n del control.
            mov         es, ax                  ; es:[0] = Info del control.

            ; Inicializar par metros de la estructura de informaci¢n.
            mov         INBUFSIZE, dx           ; Tama¤o del buffer.
            mov         CTCONTROLID, INLINEID   ; Tipo de control.
            mov         CTPROC, OFFSET inlineproc
            mov         CTFOCUS, FALSE          ; Sin foco.

            ; Incializar coordenadas X de la estructura de informaci¢n.
            mov         dx, x
            mov         CTX1POS, dx             ; Guardar coordenada X1.
            mov         ax, w
            mov         INWIDTH, ax             ; Guardar el ancho.
            shl         ax, 3                   ; Pasar a pixels el ancho.
            add         ax, dx
            dec         ax
            mov         CTX2POS, ax             ; Guardar coordenada X2.

            ; Incializar coordenadas Y de la estructura de informaci¢n.
            mov         dx, y
            mov         CTY1POS, dx             ; Guardar coordenada Y1.
            mov         ax, h
            mov         INHEIGHT, ax            ; Guardar el alto.
            shl         ax, 4                   ; Pasar a pixels el alto.
            add         ax, dx
            dec         ax
            mov         CTY2POS, ax             ; Guardar coordenada Y2.

            ; Inicializar el buffer de texto.
            mov         ax, text
            test        ax, ax                  ; Saltar si no se indic¢
            jz          @il1                    ; cadena por defecto.
            fstrcpy     es, INBUFFER, ds, ax    ; Copiar cadena por defecto.
            fstrlen     es, INBUFFER            ; cx = longitud cadena.
            mov         INCURPOS, cx            ; Posici¢n del cursor.
            jmp         @il2
@il1:
            mov         INBUFFER, 0             ; Buffer vac¡o.
            mov         INCURPOS, 0             ; Posici¢n del cursor.

@il2:       ; Indicar al control que puede ser inicializado.
            mov         ax, es
            sendmsg     ax, CMINIT, NOPARAM
            clc

@il3:       ; Retornar del procedimiento.
            pop         es dx
            pop         bp
            ret         ARGLEN

_inputline  ENDP

; ---------------------------------------------------------------------------
;     Destruir un control de entrada de datos
;
;        Entrada:
;
;        handler = Manejador del control.
;
;        Salida:
;
;        Si cf = 0: No error
;        Si cf = 1: Error al destruir el control
; ---------------------------------------------------------------------------

_freeinput  PROC
            ARG         handler:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp

            ; Liberar la memoria reservada.
            free        handler

            ; Retornar del procedimiento.
            pop         bp
            ret         ARGLEN   

_freeinput  ENDP

; ---------------------------------------------------------------------------
;     Enviar un mensaje al control indicado
;
;        Entrada:
;
;        handler = Manejador del control.
;        msg = Identificador del mensaje.
;        param = Par metro asociado al mensaje.
; ---------------------------------------------------------------------------

_sendmsg    PROC
            ARG         handler:WORD, msg:WORD, param:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        es

            ; Cargar la direcci¢n de acceso a la informaci¢n del control.
            mov         es, handler             ; es:[0] = Info del control.

            ; Llamar al procedimiento del control.
            push        param msg               ; Guardar par metros.
            call        CTPROC
                        
            ; Retornar del procedimiento.
            pop         es
            pop         bp
            ret         ARGLEN

_sendmsg    ENDP

; ---------------------------------------------------------------------------
;     Actualizar la visualizaci¢n del control de l¡nea de entrada
;
;        Entrada:
;
;        es:0 = Puntero a la estructura de informaci¢n del control.
; ---------------------------------------------------------------------------

updinline   PROC

            ; Inicializar el procedimiento.
            push        ax bx cx dx si

            ; Redibujar el cuadro del control.
            mov         bx, CTY1POS
            drawbox     CTX1POS, bx, CTX2POS, CTY2POS, BKGCOLOR

            ; Prepararnos para dibujar el texto del control.
            mov         si, OFFSET INBUFFER     ; si = buffer de texto.
            fstrlen     es, si                  ; cx = longitud cadena.
            mov         dx, INWIDTH             ; dx = ancho del cuadro.
            mov         ax, INHEIGHT            ; ax = alto del cuadro.
            dec         ax
            jz          @ul2                    ; Saltar si 0 l¡neas.

@ul1:       ; Dibujar las l¡neas de texto.
            drawnchar   es, si, dx, CTX1POS, bx, TXTCOLOR
            cmp         dx, cx                  ; Saltar si se dibuj¢
            ja          @ul3                    ; todo el buffer.
            sub         cx, dx
            add         bx, SCRYCHAR
            add         si, dx                  ; Siguiente l¡nea.
            dec         ax
            jnz         @ul1

@ul2:       ; Dibujar la £ltima l¡nea de texto.
            dec         dx
            drawnchar   es, si, dx, CTX1POS, bx, TXTCOLOR

@ul3:       ; Comprobar si es necesario dibujar el cursor.
            cmp         CTFOCUS, FALSE          ; Si no se tiene el foco
            je          @ul4                    ; no se dibuja el cursor.

            ; Dibujar el cursor.
            mov         cx, INCURPOS            ; cx = posici¢n del cursor.
            mov         ax, cx                  ; ax = posici¢n del cursor.
            cwd                                 ; dx:ax = posici¢n cursor.
            div         INWIDTH                 ; al = offset l¡nea.
            cbw                                 ; ax = offset l¡nea.
            mov         bx, ax                  ; bx = offset l¡nea.
            mul         INWIDTH
            sub         cx, ax
            shl         cx, 3
            mov         dx, CTY1POS
            shl         bx, 4
            add         dx, bx                  ; dx = Coordenada Y.
            add         cx, CTX1POS             ; cx = Coordenada X.
            drawchar    '_', cx, dx, TXTCOLOR

@ul4:       ; Retornar del procedimiento.
            pop         si dx cx bx ax
            ret

updinline   ENDP

; ---------------------------------------------------------------------------
;     Inicializar el control de l¡nea de entrada indicado.
;
;        Entrada:
;
;        es:0 = Puntero a la estructura de informaci¢n del control.
; ---------------------------------------------------------------------------

initinline  PROC

            ; Inicializar el procedimiento.
            push        ax bx cx dx 

            ; Calcular las coordenadas del cuadro que rodea al control.
            mov         ax, CTX1POS
            dec         ax                      ; Coordenada X1
            mov         bx, CTY1POS
            dec         bx                      ; Coordenada Y1
            mov         cx, CTX2POS
            inc         cx                      ; Coordenada X2
            mov         dx, CTY2POS
            inc         dx                      ; Coordenada Y2

            ; Dibujar el cuadro que rodea al control.
            drawline    ax, bx, cx, bx, D3DCOLOR
            drawline    ax, bx, ax, dx, D3DCOLOR
            drawline    ax, dx, cx, dx, L3DCOLOR
            drawline    cx, bx, cx, dx, L3DCOLOR

            ; Actualizar la visualizaci¢n del control.
            call        updinline

            ; Retornar del procedimiento.
            pop         dx cx bx ax
            ret

initinline  ENDP

; ---------------------------------------------------------------------------
;     Procesar una pulsaci¢n de tecla
;
;        Entrada:
;
;        ax = C¢digo de scan de la tecla pulsada.
;        es:0 = Puntero a la estructura de informaci¢n del control.
; ---------------------------------------------------------------------------

keyprocess  PROC

            ; Inicializar el procedimiento.
            push        ax cx dx si

            ; Determinar de que tecla se trata
            cmp         ax, KBUP                ; Saltar si se puls¢ arriba.
            je          @kp1
            cmp         ax, KBDOWN              ; Saltar si se puls¢ abajo.
            je          @kp2
            cmp         ax, KBLEFT              ; Saltar si se puls¢ izq.
            je          @kp3  
            cmp         ax, KBRIGHT             ; Saltar si se puls¢ drcha.
            je          @kp4
            cmp         ax, KBHOME              ; Saltar si se puls¢ inicio.
            je          @kp5
            cmp         ax, KBEND               ; Saltar si se puls¢ fin.
            je          @kp6
            cmp         ax, KBBACKSPACE         ; Saltar si se puls¢ bs.   
            je          @kp7
            cmp         ax, KBDEL               ; Saltar si se puls¢ suprimir   
            je          @kp8
            cmp         al, 28h                 
            jb          @kpF
            cmp         al, 7ah
            ja          @kpF
            jmp         @kp9                    ; Saltar si caracter.
@kp1:
            mov         ax, INCURPOS            ; ax = posici¢n del cursor.
            cmp         ax, INWIDTH             ; Evitar sobrepasar el
            jb          @kpF                    ; borde superior.
            sub         ax, INWIDTH
            mov         INCURPOS, ax            ; Guardar posici¢n cursor.
            jmp         @kpF
@kp2:
            mov         ax, INCURPOS            ; ax = posici¢n del cursor.
            mov         si, OFFSET INBUFFER     ; si = puntero al buffer.
            add         si, ax
            fstrlen     es, si                  ; cx = longitud que queda.
            cmp         cx, INWIDTH             ; Evitar sobrepasar el
            jb          @kpF                    ; borde superior.
            add         ax, INWIDTH
            mov         INCURPOS, ax            ; Guardar posici¢n cursor.
            jmp         @kpF
@kp3:
            mov         ax, INCURPOS            ; ax = posici¢n del cursor.
            test        ax, ax                  ; Evitar sobrepasar el
            jz          @kpF                    ; borde izquierdo.
            dec         ax
            mov         INCURPOS, ax            ; Guardar posici¢n cursor.
            jmp         @kpF
@kp4:
            mov         ax, INCURPOS            ; ax = posici¢n del cursor.
            mov         si, OFFSET INBUFFER     ; si = puntero al buffer.
            add         si, ax
            cmp         es:byte ptr[si], 00h    ; Evitar sobrepasar el
            je          @kpF                    ; borde derecho.
            inc         ax
            mov         INCURPOS, ax            ; Guardar posici¢n cursor.
            jmp         @kpF
@kp5:
            mov         INCURPOS, 00h           ; Llevar al principio.
            jmp         @kpF
@kp6:
            fstrlen     es, INBUFFER            ; cx = longitud cadena.
            mov         INCURPOS, cx            ; Llevar al final.
            jmp         @kpF
@kp7:
            mov         ax, INCURPOS            ; ax = posici¢n del cursor.
            test        ax, ax                  ; Evitar sobrepasar el
            jz          @kpF                    ; borde izquierdo.
            mov         si, OFFSET INBUFFER     ; si = puntero al buffer.
            add         si, ax
            mov         ax, si
            dec         ax
            fstrcpy     es, ax, es, si          ; Copiar la cadena.
            dec         INCURPOS
            jmp         @kpF
@kp8:
            mov         ax, INCURPOS            ; ax = posici¢n del cursor.
            mov         si, OFFSET INBUFFER     ; si = puntero al buffer.
            add         si, ax
            cmp         es:byte ptr[si], 00h    ; Evitar sobrepasar el
            je          @kpF                    ; borde derecho.
            mov         ax, si
            inc         ax
            fstrcpy     es, si, es, ax          ; Copiar la cadena.
            jmp         @kpF
@kp9:
            mov         si, OFFSET INBUFFER     ; si = puntero al buffer.
            fstrlen     es, si                  ; cx = longitud cadena.
            mov         dx, INBUFSIZE           ; dx = tama¤o del buffer.
            dec         dx
            cmp         cx, dx                  ; Comprobar que el buffer
            jae         @kpF                    ; no est‚ lleno.
            mov         dx, INCURPOS            ; ax = posici¢n del cursor.
            add         si, dx
            mov         dx, si
            inc         dx
            fistrcpy    es, dx, es, si          ; Copiar la cadena.
            mov         es:byte ptr[si], al     ; Guardar caracter.
            inc         INCURPOS

@kpF:       ; Retornar del procedimiento.
            pop         si dx cx ax
            ret

keyprocess  ENDP

; ---------------------------------------------------------------------------
;     Procedimiento de los controles de l¡nea de entrada
;
;        Entrada:
;
;        es:0 = Puntero a la estructura de informaci¢n del control.
;        msg = Identificador del mensaje.
;        param = Par metro asociado al mensaje.
; ---------------------------------------------------------------------------

inlineproc  PROC
            ARG         msg:WORD, param:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax

            ; Determinar el tipo de mensaje.
            mov         ax, msg
            cmp         ax, CMINIT              ; Saltar si mensaje de 
            je          @ip1                    ; inicializaci¢n.
            cmp         ax, CMKEY               ; Saltar si mensaje de
            je          @ip2                    ; tecla pulsada.
            cmp         ax, CMFOCUS             ; Saltar si mensaje de
            je          @ip3                    ; toma el foco.
            cmp         ax, CMNOFOCUS           ; Saltar si mensaje de
            je          @ip4                    ; Perder el foco.
            cmp         ax, INBUFCPY            ; Saltar si mensaje de
            je          @ip5                    ; copiar el buffer de texto.
            jmp         @ip6
@ip1:
            call        initinline              ; Inicializar.
            jmp         @ip6
@ip2:
            mov         ax, param               ; ax = tecla.
            call        keyprocess
            call        updinline               ; Actualizar control.
            jmp         @ip6
@ip3:
            mov         CTFOCUS, TRUE           ; Indicar tener el foco.
            call        updinline               ; Actualizar control.
            jmp         @ip6
@ip4:
            mov         CTFOCUS, FALSE          ; Indicar no tener el foco.
            call        updinline               ; Actualizar control.
            jmp         @ip6
@ip5:
            mov         ax, param               ; Puntero buffer destino.
            fstrcpy     ds, ax, es, INBUFFER    ; Copiar la cadena.
                        
@ip6:       ; Retornar del procedimiento.
            pop         ax
            pop         bp
            ret         ARGLEN

inlineproc  ENDP

            END
