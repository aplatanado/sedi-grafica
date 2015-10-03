; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        MAIN.ASM - C¢digo principal del programa.
; ---------------------------------------------------------------------------

.MODEL SMALL
.STACK 0100h

            INCLUDE     SYSTEM.INC              ; Funciones del sistema.
            INCLUDE     GRAPH.INC               ; Funciones gr ficas.
            INCLUDE     MATH.INC                ; Funciones matem ticas.
            INCLUDE     STRING.INC              ; Funciones de cadenas.
            INCLUDE     STACK.INC               ; Funciones de pila.
            INCLUDE     CALC.INC                ; Funciones de calculadora.
            INCLUDE     INPUT.INC               ; Funciones de entrada.
            INCLUDE     ERROR.INC               ; C¢digos de error.

; ---------------------------------------------------------------------------
;     Par metros de las barras de la aplicaci¢n
; ---------------------------------------------------------------------------

            ; Longitudes referentes a los textos en las barras.
BARTXTMG    EQU         4                       ; Margen del texto (pel).

            ; Colores de las barras.
BARCOLOR    EQU         BLANCO                  ; Color de las barras.
L3DCOLOR    EQU         BLANCO + INTENSIDAD     ; Borde luminoso.
D3DCOLOR    EQU         GRIS                    ; Borde oscuro.

            ; Posici¢n de la barra de opciones.
OPBARX2     EQU         SCRWIDTH-1              ; Coordenada X2 barra (pel).
OPBARY2     EQU         SCRHEIGHT-1             ; Coordenada Y2 barra (pel).
OPBARX1     EQU         0                       ; Coordenada X1 barra (pel).
OPBARY1     EQU         SCRHEIGHT-2*BARTXTMG-SCRYCHAR
                                                ; Coordenada Y1 barra (pel).

            ; Posici¢n de la barra del cursor.
CRBARX1     EQU         0                       ; Coordenada X1 barra (pel).
CRBARY1     EQU         0                       ; Coordenada Y1 barra (pel).
CRBARX2     EQU         SCRWIDTH - 1            ; Coordenada X2 barra (pel). 
CRBARY2     EQU         2*BARTXTMG+SCRYCHAR-1   ; Coordenada Y2 barra (pel).

            ; Posici¢n de los separadores de la barra del cursor.
CRNUMDEC    EQU         15                      ; N§ decimales barra cursor.
CRFIELDSIZE EQU         29                      ; Tama¤o de cada campo.
CRDIV1      EQU         SCRXCHAR*CRFIELDSIZE    ; Posici¢n primera divisi¢n.
CRDIV2      EQU         2*SCRXCHAR*CRFIELDSIZE  ; Posici¢n segunda divisi¢n.

; ---------------------------------------------------------------------------
;     Par metros de la gr fica
; ---------------------------------------------------------------------------

            ; Colores para el trazado de la gr fica.
AXISCOLOR   EQU         BLANCO+INTENSIDAD       ; Color de los ejes.
GRCOLOR     EQU         ROJO                    ; Color de la g fica.
SEGCOLOR    EQU         GRIS                    ; Color indicadores divisi¢n

            ; Longitudes referentes a los textos en las barras.
GRTXTMG     EQU         2                       ; Margen del texto (pel).
GRNUMDEC    EQU         1                       ; N§ decimales ejes gr fica.
GRFIELDSIZE EQU         9                       ; Tama¤o de cada campo.
 
            ; M rgenes de los ejes de la gr fica.
GRXRMARGIN  EQU         SCRXCHAR*GRFIELDSIZE/2  ; Margen derecho gr fica.
GRYTMARGIN  EQU         10                      ; Margen superior gr fica.
GRYBMARGIN  EQU         SCRYCHAR+2*GRTXTMG      ; Margen inferior gr fica.
GRXLMARGIN  EQU         SCRXCHAR*GRFIELDSIZE+2*GRTXTMG
                                                ; Margen izquierdo gr fica.

            ; Otros par metros para el trazado de la gr fica.
GRLENSEG    EQU         10                      ; Longitud divisiones.
GRDIVX      EQU         5                       ; Divisiones en X.
GRDIVY      EQU         8                       ; Divisiones en Y.
GRWIDTH     EQU         SCRWIDTH-GRXLMARGIN-GRXRMARGIN-2*GRLENSEG
                                                ; Ancho de la gr fica.
GRHEIGTH    EQU         OPBARY1-CRBARY2-GRYTMARGIN-GRYBMARGIN-2*GRLENSEG-1
                                                ; Alto de la gr fica.
NUMOFDATA   EQU         GRWIDTH                 ; Cantidad de datos en tabla.

            ; Coodenadas para el eje X.
AXISXX1     EQU         GRXLMARGIN              ; Coordenada X1 eje X (pel).
AXISXX2     EQU         SCRWIDTH-GRXRMARGIN-1   ; Coordenada X2 eje X (pel).
AXISXY1     EQU         OPBARY1-GRYBMARGIN-GRLENSEG-1
                                                ; Coordenada Y1 eje X (pel).
AXISXY2     EQU         OPBARY1-GRYBMARGIN-GRLENSEG-1
                                                ; Coordenada Y2 eje X (pel).

            ; Coodenadas para el eje Y.
AXISYX1     EQU         GRXLMARGIN+GRLENSEG     ; Coordenada X1 eje Y (pel).
AXISYX2     EQU         GRXLMARGIN+GRLENSEG     ; Coordenada X2 eje Y (pel).
AXISYY1     EQU         CRBARY2+GRYTMARGIN+1    ; Coordenada Y1 eje Y (pel).
AXISYY2     EQU         OPBARY1-GRYBMARGIN-1    ; Coordenada Y2 eje Y (pel).

; ---------------------------------------------------------------------------
;     Par metros de los cuadros de entrada de los l¡mites de los ejes.
; ---------------------------------------------------------------------------

            ; Par metros de los cuadros de entrada en general.
INNUMDEC    EQU         15                      ; N§ de decimales.
INXMARGIN   EQU         2                       ; Margen X del texto (char).
INYMARGIN   EQU         1                       ; Margen Y del texto (char).

            ; Par metros de los cuadros de entrada de los
            ; l¡mites de los ejes.
IASIZE      EQU         30                      ; Tama¤o l¡nea de entrada.
IACHWIDTH   EQU         IASIZE+12               ; Ancho del cuadro (char).
IAWIDTH     EQU         IACHWIDTH*SCRXCHAR      ; Ancho del cuadro.
IACHHEIGHT  EQU         5                       ; Alto del cuadro (char).
IAHEIGHT    EQU         IACHHEIGHT*SCRYCHAR     ; Alto del cuadro.

            ; Coordenadas de los cuadros de entrada de los
            ; l¡mites de los ejes.
IAX1        EQU         (SCRWIDTH-IAWIDTH)/2    ; Coordenada X1.
IAX2        EQU         IAX1+IAWIDTH-1          ; Coordenada X2.
IAY1        EQU         (SCRHEIGHT-IAHEIGHT)/2  ; Coordenada Y1.
IAY2        EQU         IAY1+IAHEIGHT-1         ; Coordenada Y2.

            ; Coordenadas de las etiquetas de las l¡neas de entrada.
IAXNMIN     EQU         IAX1+(INXMARGIN*SCRXCHAR)
IAYNMIN     EQU         IAY1+(INYMARGIN*SCRYCHAR)
IAXNMAX     EQU         IAX1+(INXMARGIN*SCRXCHAR)
IAYNMAX     EQU         IAY1+((INYMARGIN+2)*SCRYCHAR)

            ; Coordenadas de las l¡neas de entrada.
IAXINMIN    EQU         IAX2-(INXMARGIN+IASIZE)*SCRXCHAR+1
IAYINMIN    EQU         IAYNMIN                
IAXINMAX    EQU         IAX2-(INXMARGIN+IASIZE)*SCRXCHAR+1
IAYINMAX    EQU         IAYNMAX                

; ---------------------------------------------------------------------------
;     Par metros del cuadro de entrada de la funci¢n.
; ---------------------------------------------------------------------------

            ; Par metros del cuadro de entrada de la funci¢n.
IFXSIZE     EQU         72                      ; Tama¤o l¡nea de entrada.
IFYSIZE     EQU         4                       ; N§ de l¡neas.
IFCHWIDTH   EQU         IFXSIZE+2*INXMARGIN     ; Ancho del cuadro (char).
IFWIDTH     EQU         IFCHWIDTH*SCRXCHAR      ; Ancho del cuadro.
IFCHHEIGHT  EQU         IFYSIZE+2*INYMARGIN+2   ; Alto del cuadro (char).
IFHEIGHT    EQU         IFCHHEIGHT*SCRYCHAR     ; Alto del cuadro.

            ; Coordenadas del cuadro de entrada de la funci¢n.
IFX1        EQU         (SCRWIDTH-IFWIDTH)/2    ; Coordenada X1.
IFX2        EQU         IFX1+IFWIDTH-1          ; Coordenada X2.
IFY1        EQU         (SCRHEIGHT-IFHEIGHT)/2  ; Coordenada Y1.
IFY2        EQU         IFY1+IFHEIGHT-1         ; Coordenada Y2.

            ; Coordenada de la etiqueta de entrada.
IFXTEXT     EQU         IFX1+(INXMARGIN*SCRXCHAR)
IFYTEXT     EQU         IFY1+(INYMARGIN*SCRYCHAR)

            ; Coordenadas de la l¡nea de entrada.
IFXINLINE   EQU         IFX1+(INXMARGIN*SCRXCHAR)
IFYINLINE   EQU         IFY2-(INYMARGIN+IFYSIZE)*SCRYCHAR+1
                        
; ---------------------------------------------------------------------------
;     Otros par metros gr ficos
; ---------------------------------------------------------------------------

            ; Par metros de los cuadros de mensaje.
MBXMARGIN   EQU         4                       ; Margen X del texto (char).
MBYMARGIN   EQU         1                       ; Margen Y del texto (char).
MBCHHEIGHT  EQU         6                       ; Alto del cuadro (char).
MBHEIGHT    EQU         MBCHHEIGHT*SCRYCHAR     ; Alto del cuadro.
MBY1        EQU         (SCRHEIGHT-MBHEIGHT)/2  ; Coordenada Y1.
MBY2        EQU         MBY1+MBHEIGHT-1         ; Coordenada Y2.

            ; Par metros del cursor.
INVALIDIDX  EQU         -1                      ; Öndice inv lido.
CRCOLOR     EQU         AMARILLO                ; Color del cursor.
CRWIDTH     EQU         4                       ; Medio ancho del cursor.
CRSAVEX2    EQU         15                      ; Coordenadas para el  rea
CRSAVEY2    EQU         CRSAVEPOS+8             ; de v¡deo recuperado.
SMOOTHSHF   EQU         1                       ; Desplazamiento suave.
SPEEDSHF    EQU         10                      ; Desplazamiento r pido.

            ; Areas de la memoria de video no visibles.
MBSAVEPOS   EQU         SCRHEIGHT               ; Area para cuadro de texto.
INSAVEPOS   EQU         MBSAVEPOS+MBHEIGHT      ; Area para entrada datos.
CRSAVEPOS   EQU         INSAVEPOS+IFHEIGHT      ; Area para cursor.
                           
; --------------------------------------------------------------------------- 
;     Mostrar un cuadro de mensaje con el texto indicado
;
;        Entrada:
;
;        ds:text = Texto del cuadro de mensaje.
; --------------------------------------------------------------------------- 

msgbox      MACRO       text

            push        text                    ; Guardar par metros.
            call        _msgbox                 ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Desplazar el cursor a la izquierda
;
;        Entrada:
;
;        count = Cantidad de puntos en la que desplazarse.
; ---------------------------------------------------------------------------

shlcursor   MACRO       count

            push        count                   ; Guardar par metros.
            call        _shlcursor              ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Desplazar el cursor a la derecha
;
;        Entrada:
;
;        count = Cantidad de puntos en la que desplazarse.
; ---------------------------------------------------------------------------

shrcursor   MACRO       count

            push        count                   ; Guardar par metros.
            call        _shrcursor              ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Calcular las coordenadas para centrar un texto en pantalla.
;
;        Entrada:
;
;        cx = Longitud del texto a centrar.
;
;        Salida
;
;        ax = Coordenadas del texto centrado.
; ---------------------------------------------------------------------------

centertext  MACRO

            mov         ax, SCRCHWIDTH          ; ax = ancho pantalla (char)
            sub         ax, cx
            shr         ax, 1
            shl         ax, 3                   ; ax = coordenada X1.

            ENDM

; ---------------------------------------------------------------------------

.DATA

; ---------------------------------------------------------------------------
;     Cadenas de caracteres de prop¢sito general empleadas por el programa    
; ---------------------------------------------------------------------------

info        db          'Trazador de funciones en pantalla gr fica - '
            db          'Ver. 1.0', 0dh, 0ah, 'Por: Jes£s M. Torres Jorge'
            db          2 DUP(0dh, 0ah), '$'

            ; Buffer de uso general
strbuffer   db          320 dup(?)

; ---------------------------------------------------------------------------
;     Cadenas requeridas por los elementos de la pantalla
; ---------------------------------------------------------------------------

xcurstr     db          'X =', 00h
xminstr     db          'XMIN =', 00h
xmaxstr     db          'XMAX =', 00h

ycurstr     db          'Y =', 00h
yminstr     db          'YMIN =', 00h
ymaxstr     db          'YMAX =', 00h

funcstr     db          'Introduzca la funci¢n a representar:', 00h

opkeystr    db          ' Alt-X        F1      F2      F3         '
            db          ' F5             F9               ', 00h
optionstr   db          '       Salir     "X"     "Y"     Funci¢n '
            db          '    Actualizar     Cursor On/Off ', 00h

promptstr   db          '-- Pulse una tecla para continuar --', 00h

; ---------------------------------------------------------------------------
;     Mensajes de error empleados por el programa en modo texto
; ---------------------------------------------------------------------------

eno386      db          07h, 'Error: El programa requiere un 386 o superior.'
            db          0dh, 0ah, '$'

enofpu      db          07h, 'Error: El coprocesador matem tico no pudo ser '
            db          'encontrado.', 0dh, 0ah, '$'

enovga      db          07h, 'Error: El programa requiere una VGA o '
            db          'compatible.', 0dh, 0ah, '$'

enomem      db          07h, 'Error: No hay memoria suficiente.'
            db          0dh, 0ah, '$'

esyn        db          07h, 'Error: La funci¢n por defecto no es'
            db          ' representable.'
            db          0dh, 0ah, '$'

            ; Vector de mensajes de error.
errmsg      dw          ?
            dw          OFFSET eno386
            dw          OFFSET enofpu
            dw          OFFSET enovga
            dw          OFFSET enomem
            dw          OFFSET esyn

; ---------------------------------------------------------------------------
;     Mensajes de error empleados por el programa en modo texto
; ---------------------------------------------------------------------------

grenomem    db          '­NO HAY MEMORIA SUFICIENTE!', 00h
gresyn      db          '­ERROR DE SINTAXIS!', 00h
grenoval    db          '­EL VALOR ESPECIFICADO NO ES CORRECTO!', 00h
grenofunc   db          '­LA FUNCION INDICADA NO ES CORRECTA!', 00h

            ; Vector de mensajes de error.
grerrmsg    dw          ?
            dw          ?
            dw          ?
            dw          ?
            dw          OFFSET grenomem
            dw          OFFSET gresyn
            dw          OFFSET grenoval
            dw          OFFSET grenofunc

; ---------------------------------------------------------------------------
;     Variables requeridas para el c lculo
; ---------------------------------------------------------------------------

xmin        dq          -4.0                    ; Valor m¡nimo de X.
xmax        dq          10.0                    ; Valor m ximo de X.
xinc        dq          0.0                     ; Incremento de X.

ymin        dq          -2.0                    ; Valor m¡nimo de Y.
ymax        dq          2.0                     ; Valor m ximo de Y.
yinc        dq          0.0                     ; Pendiente de conversi¢n.

handler     HSTACK      00h                     ; Manejador de la pila.
datatable   dw          0ffffh                  ; Segmento tabla de datos.

            ; Buffer del texto de la funci¢n (160 caracteres).
function    db          '(x^3) * e^x / (e^x - 1)^2', 00h, 294 dup(?)

; ---------------------------------------------------------------------------
;     Variables requeridas para el cursor
; ---------------------------------------------------------------------------

curindex    dw          INVALIDIDX              ; Indice de datos del cursor.
showflag    dw          FALSE                   ; Indicador cursor visible.
xcurpos     dw          0                       ; Coordenadas del  rea del
ycurpos     dw          0                       ; cursor.

; ---------------------------------------------------------------------------

.CODE
.386

; --------------------------------------------------------------------------- 
;     Mostrar un cuadro de mensaje con el texto indicado
;
;        Entrada:
;
;        ds:text = Texto del cuadro de mensaje.
; --------------------------------------------------------------------------- 

_msgbox     PROC
            ARG         text:NEAR PTR = ARGLEN
            LOCAL       x1:WORD, x2:WORD, textlen:WORD, \
                        promptlen:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax cx si

            ; Calcular las coordenadas X de la ventana.
            mov         si, text
            strlen      promptstr               ; cx = longitud de promptstr
            mov         ax, cx                  ; ax = longitud de promptstr
            mov         promptlen, ax
            strlen      si                      ; cx = longitud de text.
            mov         textlen, cx
            cmp         ax, cx                  ; Buscamos la mayor para
            jbe         @mb1                    ; realizar los c lculos
            mov         cx, ax                  ; en base a ella.
@mb1:
            add         cx, 2*MBXMARGIN         ; cx = ancho cuadro (char).
            centertext
            mov         x1, ax
            shl         cx, 3                   ; cx = ancho cuadro (pixel).
            add         ax, cx                  
            dec         ax                      ; ax = coordenada X2.
            mov         x2, ax

            ; Preservar el contenido de la pantalla en el lugar
            ; donde se situar  el cuadro de mensaje.
            drawcpy     0, MBSAVEPOS, x1, MBY1, x2, MBY2

            ; Dibujar el cuadro de mensaje
            drawbox     x1, MBY1, x2, MBY2, BARCOLOR
            drawline    x1, MBY1, x2, MBY1, L3DCOLOR
            drawline    x1, MBY1, x1, MBY2, L3DCOLOR
            drawline    x1, MBY2, x2, MBY2, D3DCOLOR
            drawline    x2, MBY1, x2, MBY2, D3DCOLOR

            ; Dibujar el texto del cuadro.
            mov         cx, textlen
            centertext                          ; Centrar texto.
            mov         cx, MBY1
            add         cx, MBYMARGIN*SCRYCHAR
            push        cx
            drawtext    si, ax, cx, ROJO+INTENSIDAD
            mov         cx, promptlen
            centertext                          ; Centrar texto.
            pop         cx
            add         cx, 3*SCRYCHAR
            drawtext    promptstr, ax, cx, NEGRO

            ; Esperar la pulsaci¢n de una tecla.
            beep                                ; P¡tido por el speaker.
            readkey

            ; Restaurar el contenido de la pantalla.
            mov         cx, x2
            sub         cx, x1                  ; cx = x2 - x1
            mov         ax, MBY2
            sub         ax, MBY1                ; ax = y2 - y1
            add         ax, MBSAVEPOS
            drawcpy     x1, MBY1, 0, MBSAVEPOS, cx, ax

            ; Retornar del procedimiento.
            push        si cx ax
            mov         sp, bp
            pop         bp
            ret         ARGLEN

_msgbox     ENDP

; ---------------------------------------------------------------------------
;     Modificar los l¡mites del eje de las X
; ---------------------------------------------------------------------------

setXlimits  PROC
            LOCAL       hxmin:HINPUT, hxmax:HINPUT, xminflag:WORD, \
                        num:QWORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax dx si

            ; Preservar el contenido de la pantalla en el lugar
            ; donde se situar  el cuadro de entrada de datos.
            drawcpy     0, INSAVEPOS, IAX1, IAY1, IAX2, IAY2

            ; Dibujar el cuadro de entrada de datos.
            drawbox     IAX1, IAY1, IAX2, IAY2, BARCOLOR
            drawline    IAX1, IAY1, IAX2, IAY1, L3DCOLOR
            drawline    IAX1, IAY1, IAX1, IAY2, L3DCOLOR
            drawline    IAX1, IAY2, IAX2, IAY2, D3DCOLOR
            drawline    IAX2, IAY1, IAX2, IAY2, D3DCOLOR

            ; Dibujar el texto de las etiquetas del cuadro.
            drawtext    xminstr, IAXNMIN, IAYNMIN, NEGRO
            drawtext    xmaxstr, IAXNMAX, IAYNMAX, NEGRO

            ; Crear los controles de l¡nea de entrada necesarios.
            fld         xmin                    ; Cargar el m¡nimo.
            ftoa        strbuffer, CRNUMDEC
            inputline   IAXINMIN, IAYINMIN, IASIZE, 1, strbuffer
            jc          @xlC                    ; Saltar si error.
            mov         hxmin, ax               ; Guardar manejador.
            fdrop
            fld         xmax                    ; Cargar el m ximo.
            ftoa        strbuffer, CRNUMDEC
            inputline   IAXINMAX, IAYINMAX, IASIZE, 1, strbuffer
            jc          @xlB                    ; Saltar si error.
            mov         hxmax, ax               ; Guardar manejador.
            fdrop

            ; Establecer el estado de activaci¢n de los controles.
            mov         xminflag, TRUE          ; Control de xmin activo.
            sendmsg     hxmin, CMFOCUS, NOPARAM

            ; Esperar la pulsaci¢n de una tecla y realizar
            ; la acci¢n adecuada.
@xl1:       readkey
            cmp         ax, KBTAB               ; Saltar si se puls¢ el
            je          @xl3                    ; tabulador.
            cmp         ax, KBENTER             ; Saltar si se puls¢ ENTER
            je          @xl5
            cmp         ax, KBESC               ; Saltar si se puls¢ ESC.
            je          @xl9
            cmp         xminflag, TRUE          ; Enviar la tecla al
            je          @xl2                    ; control activo.
            sendmsg     hxmax, CMKEY, ax
            jmp         @xl1
@xl2:
            sendmsg     hxmin, CMKEY, ax
            jmp         @xl1
@xl3:
            cmp         xminflag, TRUE          ; Conmutar el estado de
            je          @xl4                    ; activaci¢n de controles.
            sendmsg     hxmax, CMNOFOCUS, NOPARAM
            sendmsg     hxmin, CMFOCUS, NOPARAM
            mov         xminflag, TRUE
            jmp         @xl1
@xl4:
            sendmsg     hxmin, CMNOFOCUS, NOPARAM
            sendmsg     hxmax, CMFOCUS, NOPARAM
            mov         xminflag, FALSE
            jmp         @xl1
@xl5:
            ; Convertir el valor indicado para xmin.
            mov         dx, OFFSET strbuffer
            sendmsg     hxmin, INBUFCPY, dx     
            atof        strbuffer
            jc          @xlE                    ; Saltar si error.
            cmp         byte ptr[si], 0
            jne         @xlD                    ; Saltar si error.
            fstp        num                     ; Guardar xmin.
            fld         num                     ; Cargar xmin.
            fxam
            fstsw       ax                      ; ax = palabra de estado.
            test        ax, NUMMASK
            jnz         @xlD                    ; Saltar si error.

            ; Convertir el valor indicado para xmax.
            sendmsg     hxmax, INBUFCPY, dx     
            atof        strbuffer               
            jc          @xlG                    ; Saltar si error.
            cmp         byte ptr[si], 0
            jne         @xlF                    ; Saltar si error.
            fstp        num                     ; Guardar xmax.
            fld         num                     ; Cargar xmax.
            fxam
            fstsw       ax                      ; ax = palabra de estado.
            test        ax, NUMMASK
            jnz         @xlF                    ; Saltar si error.
            
            ; Verificar que xmin sea menor que xmax.
            fcom        st(1)
            fstatus
            jbe         @xlF
            fstp        xmax                    ; Guardar xmax.
            fstp        xmin                    ; Guardar xmin.

@xl9:       ; Destruir los controles de entrada de datos.
            freeinput   hxmin
            freeinput   hxmax

@xlA:       ; Restaurar el contenido de la pantalla.
            mov         dx, INSAVEPOS+IAHEIGHT-1
            drawcpy     IAX1, IAY1, 0, INSAVEPOS, IAWIDTH-1, dx

            ; Retornar del procedimiento.
            pop         si dx ax
            mov         sp, bp
            pop         bp
            ret

@xlB:       ; Error durante la creaci¢n de los controles.
            freeinput   hxmin                   ; Destruir control.
@xlC:
            fdrop
            msgbox      grerrmsg[NOMEM*2]       ; Mensaje de error.
            jmp         @xlA

@xlD:       ; Error al especificar xmin.
            fdrop
@xlE:
            msgbox      grerrmsg[NOVAL*2]       ; Mensaje de error.
            sendmsg     hxmax, CMNOFOCUS, NOPARAM
            sendmsg     hxmin, CMFOCUS, NOPARAM ; Modificar estado de
            mov         xminflag, TRUE          ; activaci¢n.
            jmp         @xl1                    ; Otra tecla.

@xlF:       ; Error al especificar xmax.
            fdrop
@xlG:
            fdrop
            msgbox      grerrmsg[NOVAL*2]       ; Mensaje de error.
            sendmsg     hxmin, CMNOFOCUS, NOPARAM
            sendmsg     hxmax, CMFOCUS, NOPARAM ; Modificar estado de
            mov         xminflag, FALSE         ; activaci¢n.
            jmp         @xl1                    ; Otra tecla.

setXlimits  ENDP

; ---------------------------------------------------------------------------
;     Modificar los l¡mites del eje de las Y
; ---------------------------------------------------------------------------

setYlimits  PROC
            LOCAL       hymin:HINPUT, hymax:HINPUT, yminflag:WORD, \
                        num:QWORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax dx si

            ; Preservar el contenido de la pantalla en el lugar
            ; donde se situar  el cuadro de entrada de datos.
            drawcpy     0, INSAVEPOS, IAX1, IAY1, IAX2, IAY2

            ; Dibujar el cuadro de entrada de datos.
            drawbox     IAX1, IAY1, IAX2, IAY2, BARCOLOR
            drawline    IAX1, IAY1, IAX2, IAY1, L3DCOLOR
            drawline    IAX1, IAY1, IAX1, IAY2, L3DCOLOR
            drawline    IAX1, IAY2, IAX2, IAY2, D3DCOLOR
            drawline    IAX2, IAY1, IAX2, IAY2, D3DCOLOR

            ; Dibujar el texto de las etiquetas del cuadro.
            drawtext    yminstr, IAXNMIN, IAYNMIN, NEGRO
            drawtext    ymaxstr, IAXNMAX, IAYNMAX, NEGRO

            ; Crear los controles de l¡nea de entrada necesarios.
            fld         ymin                    ; Cargar el m¡nimo.
            ftoa        strbuffer, CRNUMDEC
            inputline   IAXINMIN, IAYINMIN, IASIZE, 1, strbuffer
            jc          @ylC                    ; Saltar si error.
            mov         hymin, ax               ; Guardar manejador.
            fdrop
            fld         ymax                    ; Cargar el m ximo.
            ftoa        strbuffer, CRNUMDEC
            inputline   IAXINMAX, IAYINMAX, IASIZE, 1, strbuffer
            jc          @ylB                    ; Saltar si error.
            mov         hymax, ax               ; Guardar manejador.
            fdrop

            ; Establecer el estado de activaci¢n de los controles.
            mov         yminflag, TRUE          ; Control de xmin activo.
            sendmsg     hymin, CMFOCUS, NOPARAM

            ; Esperar la pulsaci¢n de una tecla y realizar
            ; la acci¢n adecuada.
@yl1:       readkey
            cmp         ax, KBTAB               ; Saltar si se puls¢ el
            je          @yl3                    ; tabulador.
            cmp         ax, KBENTER             ; Saltar si se puls¢ ENTER
            je          @yl5
            cmp         ax, KBESC               ; Saltar si se puls¢ ESC.
            je          @yl9
            cmp         yminflag, TRUE          ; Enviar la tecla al
            je          @yl2                    ; control activo.
            sendmsg     hymax, CMKEY, ax
            jmp         @yl1
@yl2:
            sendmsg     hymin, CMKEY, ax
            jmp         @yl1
@yl3:
            cmp         yminflag, TRUE          ; Conmutar el estado de
            je          @yl4                    ; activaci¢n de controles.
            sendmsg     hymax, CMNOFOCUS, NOPARAM
            sendmsg     hymin, CMFOCUS, NOPARAM
            mov         yminflag, TRUE
            jmp         @yl1
@yl4:
            sendmsg     hymin, CMNOFOCUS, NOPARAM
            sendmsg     hymax, CMFOCUS, NOPARAM
            mov         yminflag, FALSE
            jmp         @yl1
@yl5:
            ; Convertir el valor indicado para ymin.
            mov         dx, OFFSET strbuffer
            sendmsg     hymin, INBUFCPY, dx     
            atof        strbuffer
            jc          @ylE                    ; Saltar si error.
            cmp         byte ptr[si], 0
            jne         @ylD                    ; Saltar si error.
            fstp        num                     ; Guardar ymin.
            fld         num                     ; Cargar ymin.
            fxam
            fstsw       ax                      ; ax = palabra de estado.
            test        ax, NUMMASK
            jnz         @ylD                    ; Saltar si error.

            ; Convertir el valor indicado para ymax.
            sendmsg     hymax, INBUFCPY, dx
            atof        strbuffer               
            jc          @ylG                    ; Saltar si error.
            cmp         byte ptr[si], 0
            jne         @ylF                    ; Saltar si error.
            fstp        num                     ; Guardar ymax.
            fld         num                     ; Cargar ymax.
            fxam
            fstsw       ax                      ; ax = palabra de estado.
            test        ax, NUMMASK
            jnz         @ylF                    ; Saltar si error.

            ; Verificar que ymin sea menor que ymax.
            fcom        st(1)
            fstatus
            jbe         @ylF
            fstp        ymax                    ; Guardar xmax.
            fstp        ymin                    ; Guardar xmin.

@yl9:       ; Destruir los controles de entrada de datos.
            freeinput   hymin
            freeinput   hymax

@ylA:       ; Restaurar el contenido de la pantalla.
            mov         dx, INSAVEPOS+IAHEIGHT-1
            drawcpy     IAX1, IAY1, 0, INSAVEPOS, IAWIDTH-1, dx

            ; Retornar del procedimiento.
            pop         si dx ax
            mov         sp, bp
            pop         bp
            ret

@ylB:       ; Error durante la creaci¢n de los controles.
            freeinput   hymin                   ; Destruir control.
@ylC:
            fdrop
            msgbox      grerrmsg[NOMEM*2]       ; Mensaje de error.
            jmp         @ylA

@ylD:       ; Error al especificar ymin.
            fdrop
@ylE:
            msgbox      grerrmsg[NOVAL*2]       ; Mensaje de error.
            sendmsg     hymax, CMNOFOCUS, NOPARAM
            sendmsg     hymin, CMFOCUS, NOPARAM ; Modificar estado de
            mov         yminflag, TRUE          ; activaci¢n.
            jmp         @yl1                    ; Otra tecla.

@ylF:       ; Error al especificar ymax.
            fdrop
@ylG:
            fdrop
            msgbox      grerrmsg[NOVAL*2]       ; Mensaje de error.
            sendmsg     hymin, CMNOFOCUS, NOPARAM
            sendmsg     hymax, CMFOCUS, NOPARAM ; Modificar estado de
            mov         yminflag, FALSE         ; activaci¢n.
            jmp         @yl1                    ; Otra tecla.

setYlimits  ENDP

; ---------------------------------------------------------------------------
;     Modificar la expresi¢n de la funci¢n a representar
; ---------------------------------------------------------------------------

setfunction PROC
            LOCAL       hfunc:HINPUT = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            and         sp, not 3
            push        eax dx si

            ; Preservar el contenido de la pantalla en el lugar
            ; donde se situar  el cuadro de entrada de datos.
            drawcpy     0, INSAVEPOS, IFX1, IFY1, IFX2, IFY2

            ; Dibujar el cuadro de entrada de datos.
            drawbox     IFX1, IFY1, IFX2, IFY2, BARCOLOR
            drawline    IFX1, IFY1, IFX2, IFY1, L3DCOLOR
            drawline    IFX1, IFY1, IFX1, IFY2, L3DCOLOR
            drawline    IFX1, IFY2, IFX2, IFY2, D3DCOLOR
            drawline    IFX2, IFY1, IFX2, IFY2, D3DCOLOR

            ; Dibujar el texto de la etiqueta del cuadro.
            drawtext    funcstr, IFXTEXT, IFYTEXT, NEGRO

            ; Crear el control de l¡nea de entrada.
            inputline   IFXINLINE, IFYINLINE, IFXSIZE, IFYSIZE, function
            jc          @fnC                    ; Saltar si error.
            mov         hfunc, ax               ; Guardar manejador.

            ; Establecer el estado de activaci¢n del control.
            sendmsg     hfunc, CMFOCUS, NOPARAM

            ; Esperar la pulsaci¢n de una tecla y realizar
            ; la acci¢n adecuada.
@fn1:       readkey
            cmp         ax, KBENTER             ; Saltar si se puls¢ ENTER
            je          @fn3
            cmp         ax, KBESC               ; Saltar si se puls¢ ESC.
            je          @fn4
            sendmsg     hfunc, CMKEY, ax        ; Enviar la tecla al
            jmp         @fn1                    ; control activo.
@fn3:
            mov         ax, OFFSET strbuffer    ; Copiar el buffer del
            sendmsg     hfunc, INBUFCPY, ax     ; control
            strlen      strbuffer
            jcxz        @fnD                    ; Saltar si no funci¢n.
            topolaca    strbuffer               ; Pasar a polaca.
            jc          @fnE                    ; Si error terminar.
            freestack   handler                 ; Liberar viejo manejador.
            mov         handler, ax             ; Guardar nuevo manejador.
            strcpy      function, strbuffer     ; Guardar funci¢n.

@fn4:       ; Destruir el control de entrada de datos.
            freeinput   hfunc

@fnA:       ; Restaurar el contenido de la pantalla.
            mov         dx, INSAVEPOS+IFHEIGHT-1
            drawcpy     IFX1, IFY1, 0, INSAVEPOS, IFWIDTH-1, dx

            ; Retornar del procedimiento.
            pop         si dx eax
            mov         sp, bp
            pop         bp
            ret

@fnC:       ; Error durante la creaci¢n del control.
            msgbox      grerrmsg[NOMEM*2]       ; Mensaje de error.
            jmp         @fnA

@fnD:       ; Error al especificar la funci¢n.
            msgbox      grerrmsg[NOFUNC*2]      ; Mensaje de error.
            jmp         @fn1                    ; Otra tecla.

@fnE:       ; Error durante el procesado de la funci¢n.
            cwde
            msgbox      grerrmsg[eax*2]         ; Mensaje de error.
            jmp         @fn1                    ; Otra tecla.

setfunction ENDP

; ---------------------------------------------------------------------------
;     Mostrar el cursor de la gr fica
; ---------------------------------------------------------------------------

showcursor  PROC

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            and         sp, not 3
            push        eax cx bx dx es

            ; Comprobar que sea posible mostrar el cursor.
            cmp         curindex, INVALIDIDX    ; Salir si ¡ndice inv lido.
            je          @sc4
            cmp         showflag, TRUE          ; Salir si ya visible.   
            je          @sc4

            ; Cargar acceso al dato actual.
            mov         es, datatable
            movzx       eax, curindex           ; eax = ¡ndice del dato.

            ; Cargar contador
            mov         cx, NUMOFDATA
            sub         cx, curindex

@sc1:       ; Buscar el primer dato representable.
            fld         es:qword ptr[eax*8]     ; st(0) = dato.
            fcom        ymax                    ; Mayor que ymax.
            fstatus
            ja          @sc2                    ; Saltar si lo fuese.
            jp          @sc2                    ; Saltar si no comparable.
            fcom        ymin                    ; Menor que ymin.
            fstatus
            jb          @sc2                    ; Saltar si lo fuese.
            mov         curindex, ax
            jmp         @sc3                    ; Dato representable.
@sc2:
            fdrop                               ; Eliminar dato.
            inc         eax                     ; Siguiente dato.
            loop        @sc1
            jmp         @sc4                    ; Terminar

@sc3:       ; C lcular las coordenadas del  rea del cursor.
            mov         cx, ax
            add         ax, AXISYX1+CRWIDTH     ; ax = Coordenada X2  rea.
            add         cx, AXISYX1-CRWIDTH     ; cx = Coordenada X1  rea.
            mov         xcurpos, cx             ; xcurpos = Coord. X1  rea.
            fdup                                ; Duplicar st(0).
            fsub        ymin                    ; st(0) = dato - ymin.
            fmul        yinc
            fistp       ycurpos                 ; Gurdar coordenada relativa.
            mov         cx, ycurpos
            mov         dx, AXISXY1-CRWIDTH
            sub         dx, cx                  ; dx = Coordenada Y1  rea.
            mov         ycurpos, dx             ; ycurpos = Coord. Y1  rea.
            mov         dx, AXISXY1+CRWIDTH
            sub         dx, cx                  ; dx = Coordenada Y2  rea.

            ; Mostrar el cursor.
            drawcpy     0, CRSAVEPOS, xcurpos, ycurpos, ax, dx
            drawline    xcurpos, ycurpos, ax, dx, CRCOLOR
            drawline    ax, ycurpos, xcurpos, dx, CRCOLOR

            ; Mostrar los valores de X e Y para la posici¢n
            ; actual del cursor.
            fld         xinc
            fimul       curindex                
            fadd        xmin                    ; st(0) = Valor de X.
            call        updcursor               ; Actualizar texto.

            ; Indicar que el cursor es visible.
            mov         showflag, TRUE

@sc4:       ; Retornar del procedimiento.
            pop         es dx cx bx eax
            mov         sp, bp
            pop         bp
            ret

showcursor  ENDP

; ---------------------------------------------------------------------------
;     Ocultar el cursor de la gr fica
; ---------------------------------------------------------------------------

hidecursor  PROC

            ; Comprobar que sea posible mostrar el cursor.
            cmp         curindex, INVALIDIDX    ; Salir si ¡ndice inv lido.
            je          @hc1
            cmp         showflag, FALSE         ; Salir si no visible.
            je          @hc1

            ; Ocultar el cursor.
            drawcpy     xcurpos, ycurpos, 0, CRSAVEPOS, CRSAVEX2, CRSAVEY2

            ; Ocultar los valores de X e Y para la posici¢n
            ; actual del cursor.
            fldz
            fldz
            call        updcursor               ; Actualizar texto.

            ; Indicar que el cursor no es visible.
            mov         showflag, FALSE

@hc1:       ; Retornar del procedimiento.
            ret

hidecursor  ENDP

; ---------------------------------------------------------------------------
;     Desplazar el cursor a la izquierda
;
;        Entrada:
;
;        count = Cantidad de puntos en la que desplazarse.
; ---------------------------------------------------------------------------

_shlcursor  PROC
            ARG         count:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax cx dx di es

            ; Comprobar que sea posible desplazar el cursor.
            cmp         curindex, INVALIDIDX    ; Salir si ¡ndice inv lido.
            je          @sl4
            cmp         showflag, FALSE         ; Salir si no visible.   
            je          @sl4

            ; Calcular el contador apropiado.
            mov         cx, count
            mov         di, curindex
            cmp         di, cx
            jae         @sl1
            mov         cx, di
@sl1:
            test        cx, cx
            jz          @sl4                    ; Salir si cx = 0.

            ; Cargar acceso al dato actual.
            mov         es, datatable
            sub         di, cx                  ; di = ¡ndice al dato.  
            mov         curindex, di
            mov         ax, di
            shl         di, 3                   ; es:di = puntero al dato.

            ; Ocultar el cursor.
            drawcpy     xcurpos, ycurpos, 0, CRSAVEPOS, CRSAVEX2, CRSAVEY2

            ; Comprobar que el dato actual sea representable.
            fld         es:qword ptr[di]        ; st(0) = dato.
            fcom        ymax                    ; Mayor que ymax.
            fstatus
            ja          @sl2                    ; Saltar si lo fuese.
            jp          @sl2                    ; Saltar si no comparable.
            fcom        ymin                    ; Menor que ymin.
            fstatus
            jb          @sl2                    ; Saltar si lo fuese.
            jmp         @sl3                    ; Dato representable.
@sl2:
            fdrop
            jmp         @sl4                    ; Terminar

@sl3:       ; C lcular las coordenadas del  rea del cursor.
            mov         ax, curindex
            mov         cx, ax
            add         ax, AXISYX1+CRWIDTH     ; ax = Coordenada X2  rea.
            add         cx, AXISYX1-CRWIDTH     ; cx = Coordenada X1  rea.
            mov         xcurpos, cx             ; xcurpos = Coord. X1  rea.
            fdup                                ; Duplicar st(0).
            fsub        ymin                    ; st(0) = dato - ymin.
            fmul        yinc
            fistp       ycurpos                 ; Gurdar coordenada relativa.
            mov         cx, ycurpos
            mov         dx, AXISXY1-CRWIDTH
            sub         dx, cx                  ; dx = Coordenada Y1  rea.
            mov         ycurpos, dx             ; ycurpos = Coord. Y1  rea.
            mov         dx, AXISXY1+CRWIDTH
            sub         dx, cx                  ; dx = Coordenada Y2  rea.

            ; Mostrar el cursor.
            drawcpy     0, CRSAVEPOS, xcurpos, ycurpos, ax, dx
            drawline    xcurpos, ycurpos, ax, dx, CRCOLOR
            drawline    ax, ycurpos, xcurpos, dx, CRCOLOR

            ; Mostrar los valores de X e Y para la posici¢n
            ; actual del cursor.
            fld         xinc
            fimul       curindex                
            fadd        xmin                    ; st(0) = Coordenada X.
            call        updcursor               ; Actualizar texto.

@sl4:       ; Retornar del procedimiento.
            pop         es di dx cx ax
            pop         bp
            ret         ARGLEN

_shlcursor  ENDP

; ---------------------------------------------------------------------------
;     Desplazar el cursor a la derecha
;
;        Entrada:
;
;        count = Cantidad de puntos en la que desplazarse.
; ---------------------------------------------------------------------------

_shrcursor  PROC
            ARG         count:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax cx dx di es

            ; Comprobar que sea posible desplazar el cursor.
            cmp         curindex, INVALIDIDX    ; Salir si ¡ndice inv lido.
            je          @sr4
            cmp         showflag, FALSE         ; Salir si no visible.   
            je          @sr4

            ; Calcular el contador apropiado.
            mov         di, curindex
            mov         cx, NUMOFDATA-1
            sub         cx, di
            cmp         cx, count
            jbe         @sr1
            mov         cx, count
@sr1:
            test        cx, cx
            jz          @sr4                    ; Salir si cx = 0.

            ; Cargar acceso al dato actual.
            mov         es, datatable
            add         di, cx                  ; di = ¡ndice al dato.
            mov         curindex, di
            mov         ax, di
            shl         di, 3                   ; es:di = puntero al dato.

            ; Ocultar el cursor.
            drawcpy     xcurpos, ycurpos, 0, CRSAVEPOS, CRSAVEX2, CRSAVEY2

            ; Comprobar que el dato actual sea representable.
            fld         es:qword ptr[di]        ; st(0) = dato.
            fcom        ymax                    ; Mayor que ymax.
            fstatus
            ja          @sr2                    ; Saltar si lo fuese.
            jp          @sr2                    ; Saltar si no comparable.
            fcom        ymin                    ; Menor que ymin.
            fstatus
            jb          @sr2                    ; Saltar si lo fuese.
            jmp         @sr3                    ; Dato representable.
@sr2:
            fdrop
            jmp         @sr4                    ; Terminar

@sr3:       ; C lcular las coordenadas del  rea del cursor.
            mov         cx, ax
            add         ax, AXISYX1+CRWIDTH     ; ax = Coordenada X2  rea.
            add         cx, AXISYX1-CRWIDTH     ; cx = Coordenada X1  rea.
            mov         xcurpos, cx             ; xcurpos = Coord. X1  rea.
            fdup                                ; Duplicar st(0).
            fsub        ymin                    ; st(0) = dato - ymin.
            fmul        yinc
            fistp       ycurpos                 ; Gurdar coordenada relativa.
            mov         cx, ycurpos
            mov         dx, AXISXY1-CRWIDTH
            sub         dx, cx                  ; dx = Coordenada Y1  rea.
            mov         ycurpos, dx             ; ycurpos = Coord. Y1  rea.
            mov         dx, AXISXY1+CRWIDTH
            sub         dx, cx                  ; dx = Coordenada Y2  rea.

            ; Mostrar el cursor.
            drawcpy     0, CRSAVEPOS, xcurpos, ycurpos, ax, dx
            drawline    xcurpos, ycurpos, ax, dx, CRCOLOR
            drawline    ax, ycurpos, xcurpos, dx, CRCOLOR

            ; Mostrar los valores de X e Y para la posici¢n
            ; actual del cursor.
            fld         xinc
            fimul       curindex                
            fadd        xmin                    ; st(0) = Coordenada X.
            call        updcursor               ; Actualizar texto.

@sr4:       ; Retornar del procedimiento.
            pop         es di dx cx ax
            pop         bp
            ret         ARGLEN

_shrcursor  ENDP

; ---------------------------------------------------------------------------
;     Actualizar el texto de la barra del cursor
;
;        Entrada:
;
;        st(0) = valor de la coordenada X del cursor.
;        st(1) = valor de la coordenada Y del cursor.
;
;        Salida:
;
;        Los valores de las coordenadas son eliminados.
; ---------------------------------------------------------------------------

updcursor  PROC

            ; Inicializar el procedimiento.
            push        ax cx

            ; Borrar el valor anterior de X.
            strlen      xcurstr
            inc         cx
            shl         cx, 3
            mov         ax, SCRXCHAR*(CRFIELDSIZE-2)
            drawbox     cx, BARTXTMG, ax, SCRYCHAR+BARTXTMG, BARCOLOR

            ; Dibujar el texto indicativo del valor de X.
            mov         ax, CRFIELDSIZE - 1
            ftoa        strbuffer, CRNUMDEC
            strlen      strbuffer
            sub         ax, cx
            shl         ax, 3
            drawtext    strbuffer, ax, BARTXTMG, NEGRO
            fdrop

            ; Borrar el valor anterior de Y.
            strlen      ycurstr
            add         cx, CRFIELDSIZE + 1
            shl         cx, 3
            mov         ax, SCRXCHAR*(2*CRFIELDSIZE-2)
            drawbox     cx, BARTXTMG, ax, SCRYCHAR+BARTXTMG, BARCOLOR

            ; Dibujar el texto indicativo del valor de Y.
            mov         ax, 2*CRFIELDSIZE - 1
            ftoa        strbuffer, CRNUMDEC
            strlen      strbuffer
            sub         ax, cx
            shl         ax, 3
            drawtext    strbuffer, ax, BARTXTMG, NEGRO
            fdrop

            ; Retornar del procedimiento.
            pop         cx ax
            ret

updcursor  ENDP

; ---------------------------------------------------------------------------
;     Dibujar la barra del cursor
; ---------------------------------------------------------------------------

cursorbar   PROC

            ; Dibujar la barra del cursor.
            drawbox     CRBARX1, CRBARY1, CRBARX2, CRBARY2, BARCOLOR
            drawline    CRBARX1, CRBARY1, CRBARX2, CRBARY1, L3DCOLOR
            drawline    CRBARX1, CRBARY1, CRBARX1, CRBARY2, L3DCOLOR
            drawline    CRBARX1, CRBARY2, CRBARX2, CRBARY2, D3DCOLOR
            drawline    CRBARX2, CRBARY1, CRBARX2, CRBARY2, D3DCOLOR
            drawline    CRDIV1-1, CRBARY1, CRDIV1-1, CRBARY2, D3DCOLOR
            drawline    CRDIV1, CRBARY1, CRDIV1, CRBARY2, L3DCOLOR
            drawline    CRDIV2-1, CRBARY1, CRDIV2-1, CRBARY2, D3DCOLOR
            drawline    CRDIV2, CRBARY1, CRDIV2, CRBARY2, L3DCOLOR

            ; Dibujar el texto de la etiqueta para el valor de X.
            strcpy      strbuffer, xcurstr
            drawtext    strbuffer, 8, BARTXTMG, NEGRO

            ; Dibujar el texto de la etiqueta para el valor de Y.
            strcpy      strbuffer, ycurstr
            drawtext    strbuffer, SCRXCHAR*(CRFIELDSIZE+1), BARTXTMG, NEGRO

            ; Retornar del procedimiento.
            ret

cursorbar   ENDP

; ---------------------------------------------------------------------------
;     Dibujar la barra de opciones de la aplicaci¢n
; ---------------------------------------------------------------------------

optionbar   PROC

            ; Dibujar la barra de opciones.
            drawbox     OPBARX1, OPBARY1, OPBARX2, OPBARY2, BARCOLOR
            drawline    OPBARX1, OPBARY1, OPBARX2, OPBARY1, L3DCOLOR
            drawline    OPBARX1, OPBARY1, OPBARX1, OPBARY2, L3DCOLOR
            drawline    OPBARX1, OPBARY2, OPBARX2, OPBARY2, D3DCOLOR
            drawline    OPBARX2, OPBARY1, OPBARX2, OPBARY2, D3DCOLOR

            ; Dibujar el texto de la barra.
            drawtext    opkeystr, 0, OPBARY1+BARTXTMG, ROJO
            drawtext    optionstr, 0, OPBARY1+BARTXTMG, NEGRO

            ; Retornar del procedimiento.
            ret

optionbar   ENDP

; ---------------------------------------------------------------------------
;     Actualizar la tabla de datos
;
;     Salida
;
;        Si cf = 0: No error
;        Si cf = 1: Error al actualizar la tabla de datos.
; ---------------------------------------------------------------------------

updatedata  PROC
            LOCAL       num:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        NUMOFDATA-1             ; num = NUMOFDATA-1
            and         sp, not 3
            push        eax dx di

            ; Prepararnos para recalcular la tabla de datos.
            mov         cx, NUMOFDATA           ; cx = n£mero de datos.
            fld         xmin                    ; st(0) = xmin
            fld         xmax                    ; st(0) = xmax
            fsub        st(0), st(1)            ; st(0) = xmax - xmin
            fidiv       num                     ; st(0) = incremento de X.
            fxch                                ; st(0) = xmin.

@ud1:       ; Recalcular para x = st(0).
            fdup                                ; Duplicar st(0).
            calcular    handler                 ; Calcular para x = st(0).
            jnc         @ud2                    ; Saltar si error.

            ; Error durante el c lculo de la funci¢n.
            resetpop    handler                 ; Resetear la pila.
            fdrop                               ; Eliminar X.
            cwde
            msgbox      grerrmsg[eax*2]         ; Mensaje de error.
            fdrop                               ; Eliminar incremento de X.
            stc                                 ; Indicar error.
            jmp         @ud3                    ; Salir.

@ud2:       ; Pasar al siguiente valor de X.
            resetpop    handler                 ; Resetear la pila.
            fstp        es:qword ptr[di]        ; Guardar resultado.
            fadd        st(0), st(1)            ; Incrementar X.    
            add         di, 8                   ; es:[di] = siguiente dato.
            loop        @ud1                    ; Calcular para la nueva X.
            fdrop
            fstp        xinc                    ; Guardar incremento de X.
            clc                                 ; No error.

@ud3:       ; Retornar del procedimiento.
            pop         di ax
            mov         sp, bp
            pop         bp
            ret

updatedata  ENDP

; ---------------------------------------------------------------------------
;     Dibujar las marcas de divisi¢n de la gr fica
; ---------------------------------------------------------------------------

drawdiv     PROC
            LOCAL       num:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax cx 

            ; Prepararnos para dibujar las marcas de divisi¢n horizontal.
            mov         cx, GRDIVX+1            ; cx = n§ de l¡neas.
            fld1                                ; st(0) = 1
            fld         xinc                    ; st(0) = xinc
            fdiv                                ; st(0) = 1/xinc
            fld         xmin                    ; st(0) = xmin
            fld         xmax                    ; st(0) = xmax
            fsub        st(0), st(1)            ; st(0) = xmax - xmin
            mov         num, GRDIVX             ; num = n§ de divisiones
            fidiv       num                     ; st(0) = incremento X.
            fld         st(1)                   ; st(0) = xmin

@dv1:       ; Calcular las coordenadas de la l¡nea de divisi¢n.
            fdup                                ; Duplicar st(0).
            fsub        st(0), st(3)            ; st(0) = st(0) - xmin
            fmul        st(0), st(4)
            fistp       num
            mov         ax, AXISYX1
            add         ax, num                 ; ax = coordenada X.

            ; Dibujar la marca de divisi¢n vertical.
            drawline    ax, AXISYY1, ax, AXISYY2, SEGCOLOR

            ; Dibujar el texto de las marcas de divisi¢n vertical.
            push        ax cx
            fdup
            ftoa        strbuffer, GRNUMDEC     ; strbuffer1 = texto.
            fdrop
            strlen      strbuffer               ; cx = longitud strbuffer1.
            shr         cx, 1                   ; cx = cx/2
            shl         cx, 3                   ; cx = 8*cx
            sub         ax, cx                  ; ax = Coordenada X texto.
            drawtext    strbuffer, ax, AXISYY2+GRTXTMG, AXISCOLOR
            pop         cx ax

            ; Prepararnos para la siguiente l¡nea.
            fadd        st(0), st(1)            ; Siguiente valor.
            loop        @dv1                    ; Siguiente l¡nea.
            fdrop
            fdrop
            fdrop                               ; Si hemos terminardo
            fdrop                               ; vaciar la pila.

            ; Prepararnos para dibujar las marcas de divisi¢n vertical.
            mov         cx, GRDIVY+1            ; cx = n§ de l¡neas.
            fld         ymax                    ; st(0) = ymax
            fsub        st(0), st(2)            ; st(0) = ymax - ymin
            mov         num, GRDIVY             ; num = n§ de divisiones
            fidiv       num                     ; st(0) = incremento Y.
            fld         st(2)                   ; st(0) = ymin

@dv2:       ; Calcular las coordenadas de la l¡nea de divisi¢n.
            fdup                                ; Duplicar st(0).
            fsub        st(0), st(4)            ; st(0) = st(0) - ymin
            fmul        st(0), st(3)
            fistp       num
            mov         ax, AXISXY1
            sub         ax, num                 ; ax = coordenada Y.

            ; Dibujar el texto de las marcas de divisi¢n vertical.
            push        ax cx
            fdup
            ftoa        strbuffer, GRNUMDEC     ; strbuffer1 = texto.
            fdrop
            strlen      strbuffer               ; cx = longitud strbuffer1.
            sub         cx, GRFIELDSIZE
            neg         cx                      ; cx = GRFIELDSIZE - cx
            shl         cx, 3                   ; cx = Coordenada X texto.
            sub         ax, SCRYCHAR/2          ; ax = Coordenada Y texto.
            drawtext    strbuffer, cx, ax, AXISCOLOR
            pop         cx ax

            ; Dibujar la marca de divisi¢n vertical.
            drawline    AXISXX1, ax, AXISXX2, ax, SEGCOLOR

            ; Prepararnos para la siguiente l¡nea.
            fadd        st(0), st(1)            ; Siguiente valor.
            loop        @dv2                    ; Siguiente l¡nea.
            fdrop                               ; Si hemos terminardo   
            fdrop                               ; vaciar la pila.

            ; Retornar del procedimiento.
            pop         cx ax
            mov         sp, bp
            pop         bp
            ret

drawdiv     ENDP

; ---------------------------------------------------------------------------
;     Actualizar la gr fica
; ---------------------------------------------------------------------------

updategraph PROC
            LOCAL       y1:WORD, y2:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax bx cx dx di es

            ; Cargar acceso a la tabla de datos.
            mov         es, datatable
            xor         di, di                  ; es:di = puntero a la tabla.

            ; Actualizar la tabla de datos.
            call        updatedata
            jc          @ugF                    ; Salir si error.

            ; Resetear el estado del cursor de la gr fica.
            call        hidecursor              ; Ocultar el cursor.
            mov         curindex, 0             ; Indice = 0;

            ; Prepararnos para dibujar la gr fica.
            mov         ax, AXISYX1             ; ax = coordenada X.
            mov         cx, NUMOFDATA           ; cx = n£mero de datos.
            fld         ymin                    ; st(0) = ymin
            fld         ymax                    ; st(0) = ymax
            fsub        st(0), st(1)            ; st(0) = ymax - ymin
            mov         y1, GRHEIGTH-1
            fidivr      y1                      ; st(0) = pendiente.
            fst         yinc                    ; Guardar pendiente.

            ; Limpiar la zona donde ser  dibujada la gr fica.
            drawbox     0, CRBARY2+1, SCRWIDTH-1, OPBARY1-1, NEGRO

            ; Dibujar las marcas de divisi¢n de la gr fica.
            call        drawdiv

@ug1:       ; Buscar un dato v lido para ser usado como punto de partida.
            fld         es:qword ptr[di]        ; st(0) = dato.
            fcom        ymax                    ; Mayor que ymax.
            fstatus
            ja          @ug3                    ; Saltar si lo fuese.
            jp          @ug2                    ; Saltar si no comparable.
            fcom        ymin                    ; Menor que ymin.
            fstatus
            jb          @ug4                    ; Saltar si lo fuese.
            mov         bx, FALSE
            jmp         @ug5                    ; Dato v lido.
@ug2:
            fdrop                               ; Eliminar dato.
            inc         ax
            add         di, 8
            loop        @ug1                    ; Siguiente dato.
            jmp         @ugE                    ; Terminar si datos acabados.

@ug3:       ; Intentar usar ymax como punto de partida.
            fdrop                               ; Eliminar st(0).
            fld         ymax                    ; Cargar ymax.
            mov         bx, TRUE                ; Indicar la condici¢n.
            jmp         @ug5                    ; Dato v lido.

@ug4:       ; Intentar usar ymin como punto de partida.
            fdrop                               ; Eliminar st(0).
            fld         ymin                    ; Cargar ymin.
            mov         bx, TRUE                ; Indicar la condici¢n.
            jmp         @ug5                    ; Dato v lido.

@ug5:       ; Usar el dato como punto de partida.
            fsub        st(0), st(2)            ; st(0) = dato - ymin.
            fmul        st(0), st(1)            ; st(0) = yinc*(dato-ymin).
            fistp       y1                      ; Guardar en y1.
            mov         dx, AXISXY1
            sub         dx, y1                  ; dx = Coordenada Y1
            mov         y1, dx                  ; y1 = Coordenada Y1
            add         di, 8
            dec         cx
            jz          @ugD                    ; Saltar si datos acabados.

@ug6:       ; Comprobar si el siguiente dato es v lido para ser usado
            ; como punto de estino.
            fld         es:qword ptr[di]        ; st(0) = dato.
            fcom        ymax                    ; Mayor que ymax.
            fstatus
            ja          @ug9                    ; Saltar si lo fuese.
            jp          @ug7                    ; Saltar si no comparable.
            fcom        ymin                    ; Menor que ymin.
            fstatus
            jb          @ugA                    ; Saltar si lo fuese.
            mov         bx, FALSE
            jmp         @ugC                    ; Dato v lido.
@ug7:
            fdrop                               ; Eliminar dato.
            cmp         bx, TRUE                ; Dibujar el punto anterior
            je          @ug8                    ; si es v lido.
            drawpoint   ax, y1, GRCOLOR         ; Dibujar punto.
@ug8:
            add         ax, 2
            add         di, 8
            dec         cx
            jnz         @ug1                    ; Buscar un dato v lido.
            jmp         @ugE                    ; Terminar si datos acabados.

@ug9:       ; Intentar usar ymax como punto de destino si
            ; el anterior fue v lido.
            fdrop                               ; Eliminar st(0).
            fld         ymax                    ; Cargar ymax.
            cmp         bx, TRUE
            jne         @ugB                    ; Dato v lido.
            inc         ax
            jmp         @ug5

@ugA:       ; Intentar usar ymin como punto de destino si
            ; el anterior fue v lido.
            fdrop                               ; Eliminar st(0).
            fld         ymin                    ; Cargar ymin.
            cmp         bx, TRUE
            jne         @ugB                    ; Dato v lido.
            inc         ax
            jmp         @ug5
@ugB:
            mov         bx, TRUE                ; Indicar la condici¢n.

@ugC:       ; Usar el dato como punto de destino.
            fsub        st(0), st(2)            ; st(0) = dato - ymin.
            fmul        st(0), st(1)            ; st(0) = yinc*(dato-ymin).
            fistp       y2                      ; Guardar en num.
            mov         dx, AXISXY1
            sub         dx, y2                  ; dx = Coordenada Y2
            mov         y2, dx                  ; y1 = Coordenada Y2

            ; Dibujar la l¡nea.
            mov         dx, ax                  ; dx = x1
            inc         ax                      ; ax = x2
            drawline    dx, y1, ax, y2, GRCOLOR

            ; Usar el punto de destino como nuevo origen.
            mov         dx, y2
            mov         y1, dx

            ; Pasar al siguiente dato.
            add         di, 8
            dec         cx
            jnz         @ug6                    ; Siguiente dato.
            jmp         @ugE                    ; Terminar si datos acabados.
            
@ugD:       ; Dibujar el £ltimo punto.
            cmp         bx, TRUE                ; S¢lo hacerlo si es v lido.
            je          @ugE
            drawpoint   ax, y1, GRCOLOR

@ugE:       ; Vaciar la pila de la FPU.
            fdrop
            fdrop

            ; Dibujar los ejes principales de la gr fica.
            drawline    AXISXX1, AXISXY1, AXISXX2, AXISXY2, AXISCOLOR
            drawline    AXISYX1, AXISYY1, AXISYX2, AXISYY2, AXISCOLOR

@ugF:       ; Retornar del procedimiento.
            pop         es di dx cx bx ax
            mov         sp, bp
            pop         bp
            ret

updategraph ENDP

.8086
; ---------------------------------------------------------------------------
;     Verificar tipo de procesador
;
;     Salida:
;
;        Si cf = 0: Procesador 386 o superior
;        Si cf = 1: Procesador inferior al 386
; ---------------------------------------------------------------------------

verifyCPU   PROC

            ; Comprobar si es un 8086.
            pushf
            pop         ax                      ; En los 8086 los bits 12 a
            and         ah, 0fh                 ; 15 siempre est n a 1.
            push        ax
            popf
            pushf
            pop         ax
            and         ah, 0f0h
            cmp         ah, 0f0h
            je          @v1                     ; Es un 8086.

            ; Comprobar si es un 80286
            or          ah, 0f0h                ; En los 80286 los bits 12
            push        ax                      ; a 15 siempre est n a 0.
            popf
            pushf
            pop         ax
            test        ah, 0f0h
            jz          @v1                     ; Es un 80286.
            clc                                 ; Es un 80386 o superior.

            ; Retornar del procedimiento.
            ret

@v1:        ; Retornar indicando el error.
            stc
            ret

verifyCPU   ENDP

; ---------------------------------------------------------------------------
;     Bucle principal de la aplicaci¢n
;
;     Salida:
;
;        ax = C¢digo de error.
;
;        Si cf = 0: No error
;        Si cf = 1: Error de ejecuci¢n de la aplicaci¢n
; ---------------------------------------------------------------------------

mainloop    PROC

            ; Verificar el tipo de procesador.
            call        verifyCPU
            jnc         @ml1                    ; Si 386+ continuar,
            mov         ax, NO386               
            jmp         @mlN                    ; sino terminar.

.386
@ml1:       ; Inicializar el coprocesador matem tico.
            initmath                            ; Inicializar.
            jnc         @ml2                    ; Si no error continuar,
            mov         ax, NOFPU               
            jmp         @mlN                    ; sino terminar.

@ml2:       ; Inicializar el modo gr fico.
            initgraph                           ; Inicializar.
            jnc          @ml3                    ; Si no error continuar,
            mov         ax, NOVGA
            jmp         @mlN                    ; sino terminar.

@ml3:       ; Inicializar el contenido de la pantalla.
            fldz                                ; Y = 0.0
            fldz                                ; X = 0.0
            call        cursorbar               ; Barra del cursor.
            call        updcursor               ; Texto barra cursor.
            call        optionbar               ; Barra de opciones.

            ; Reservar memoria para la tabla de datos.
            mov         ax, NUMOFDATA           ; ax = n§ de datos.
            shl         ax, 3                   ; ax = ax * 8.
            malloc      ax                      ; Memoria para la tabla.
            jnc         @ml4                    ; Si no error continuar,
            mov         ax, NOMEM
            jmp         @mlM                    ; sino terminar.
@ml4:
            mov         datatable, ax           ; Guardar segmento.

            ; Inicializar las variables para el c lculo.
            topolaca    function                ; Pasar a polaca.
            mov         handler, ax             ; Guardar manejador.
            jc          @mlM                    ; Si error terminar.

@ml5:       ; Bucle principal de la aplicaci¢n.
            readkey                             ; Leer tecla.
            cmp         ax, KBF1                ; Si se puls¢ F1 modificar
            je          @ml6                    ; l¡mites del eje X.
            cmp         ax, KBF2                ; Si se puls¢ F2 modificar
            je          @ml7                    ; l¡mites del eje Y.
            cmp         ax, KBF3                ; Si se puls¢ F3 modificar
            je          @ml8                    ; la funci¢n a representar.
            cmp         ax, KBF5                ; Si se puls¢ F5 actualizar
            je          @ml9                    ; la gr fica.
            cmp         ax, KBF9                ; Si se puls¢ F9 comprobar
            je          @mlA                    ; el estado del cursor.
            cmp         ax, KBLEFT              ; Si se puls¢ <-- o re. pag.
            je          @mlC                    ; desplazar el cursor a
            cmp         ax, KBPGUP              ; la izquierda.
            je          @mlD                    
            cmp         ax, KBRIGHT             ; Si se puls¢ --> o av. pag.
            je          @mlE                    ; desplazar el cursor a
            cmp         ax, KBPGDN              ; la derecha.
            je          @mlF                    
            cmp         ax, KBALTX              ; Si se puls¢ ALT + X,
            je          @mlM                    ; terminar la aplicaci¢n.
            jmp         @ml5
@ml6:
            call        setXlimits
            jmp         @ml5
@ml7:
            call        setYlimits
            jmp         @ml5
@ml8:
            call        setfunction
            jmp         @ml5
@ml9:
            call        updategraph             
            jmp         @ml5
@mlA:
            cmp         showflag, TRUE          ; Si el cursor no es visible
            je          @mlB                    ; ocultarlo.
            call        showcursor              ; Si no mostrarlo.
            jmp         @ml5
@mlB:
            call        hidecursor              ; Ocultalo.
            jmp         @ml5
@mlC:
            shlcursor   SMOOTHSHF
            jmp         @ml5
@mlD:
            shlcursor   SPEEDSHF
            jmp         @ml5
@mlE:
            shrcursor   SMOOTHSHF
            jmp         @ml5
@mlF:
            shrcursor   SPEEDSHF
            jmp         @ml5

@mlM:       ; Devolver el sistema a su estado original.            
            closegraph                          ; Modo de texto.

.8086
@mlN:       ; Retornar del procedimiento.
            ret

mainloop    ENDP

; ---------------------------------------------------------------------------
;     Funci¢n punto de entrada a la aplicaci¢n
; ---------------------------------------------------------------------------

main        PROC

            ; Liberar la memoria asignada al programa.
            mov         bx, sp
            shr         bx, 4                   ; bx = tama¤o pila p rrafos.
            inc         bx                      ; Corregir un posible resto.
            mov         ax, ss                  ; ax = segmento PILA.
            add         bx, ax                  
            mov         ax, ds                  ; ax = segmento PSP.
            sub         bx, ax                  ; bx = tama¤o en p rrafos.
            mov         ah, 4ah                 ; Servicio 4ah.
            int         21h                     ; Modificar tama¤o.

            ; Acceso al segmento de datos.
            mov         ax, @Data
            mov         ds, ax                  ; ds = segmento de datos.

            ; Mostrar info del programa.
            prnstr      info

            ; Iniciar el bucle principal de la aplicaci¢m.
            call        mainloop
            jnc         @m1                     ; Sino error salir.
            mov         bx, ax
            shl         bx, 1
            prnstr      errmsg[bx]              ; Mostrar mensaje de error.

@m1:        ; Liberar la memoria reservada.
            freestack   handler                 ; Liberar la pila.
            free        datatable               ; Liberar la tabla de datos.

            ; Salir de la aplicaci¢n.
            exit        

main        ENDP

            END         main

