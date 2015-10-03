; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        GRAPH.INC - Macros de funciones gr ficas.
; --------------------------------------------------------------------------- 

            IFDEF _GRAPH_ASM
                PUBLIC  _initgraph, _closegraph, _drawpoint, _drawline
                PUBLIC  _drawbox, _drawchar, _drawnchar, _drawcpy
            ELSE
                EXTRN   _initgraph:NEAR, _closegraph:NEAR, _drawpoint:NEAR,
                EXTRN   _drawline:NEAR, _drawbox:NEAR, _drawchar:NEAR
                EXTRN   _drawnchar:NEAR, _drawcpy:NEAR
            ENDIF

; ---------------------------------------------------------------------------
;     Caracter¡sticas del modo gr fico.
; ---------------------------------------------------------------------------

SCRMODE     EQU         12h                     ; Modo de v¡deo (640x480x16).
NOSCRMODE   EQU         0ffh                    ; Ning£n modo activo.

SCRCHWIDTH  EQU         80                      ; Ancho de pantalla (char).
SCRCHHEIGHT EQU         30                      ; Alto de pantalla (char).
SCRXCHAR    EQU         8                       ; Ancho de cada caracter.
SCRYCHAR    EQU         16                      ; Alto de cada caracter.

SCRWIDTH    EQU         SCRCHWIDTH * SCRXCHAR   ; Ancho de pantalla (pixels).
SCRHEIGHT   EQU         SCRCHHEIGHT * SCRYCHAR  ; Alto de pantalla (pixels).

; ---------------------------------------------------------------------------
;     Atributos de color permitidos
; ---------------------------------------------------------------------------

NEGRO       EQU         0
AZUL        EQU         1
VERDE       EQU         2
CIAN        EQU         3
ROJO        EQU         4
MAGENTA     EQU         5
MARRON      EQU         6
BLANCO      EQU         7
GRIS        EQU         8
INTENSIDAD  EQU         8
AMARILLO    EQU         MARRON + INTENSIDAD

; --------------------------------------------------------------------------- 
;     Inicializar el modo gr fico
;
;        Salida:
;
;        Si cf = 0: No error
;        Si cf = 1: Error al inicializar el modo gr fico
; --------------------------------------------------------------------------- 

initgraph   MACRO

            call        _initgraph              ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Terminar el modo gr fico
; --------------------------------------------------------------------------- 

closegraph  MACRO

            call        _closegraph             ; Llamar al procedimiento

            ENDM
         
; --------------------------------------------------------------------------- 
;     Dibujar un punto en pantalla
;
;        Entrada:
; 
;        x = Coordenada X del punto.
;        y = Coordenada Y del punto.
;        color = Color del punto.
; --------------------------------------------------------------------------- 

drawpoint   MACRO       x, y, color

            push        color y x               ; Guardar par metros.
            call        _drawpoint              ; Llamar al procedimiento

            ENDM

; --------------------------------------------------------------------------- 
;     Dibujar una l¡nea en pantalla
;
;        Entrada:
; 
;        x1 = Coordenada X del punto inicial.
;        y1 = Coordenada Y del punto inicial.
;        x2 = Coordenada X del punto final.
;        y2 = Coordenada Y del punto final.
;        color = Color de la l¡nea.
; --------------------------------------------------------------------------- 

drawline    MACRO       x1, y1, x2, y2, color

            push        color y2 x2 y1 x1       ; Guardar par metros.
            call        _drawline               ; Llamar al procedimiento

            ENDM

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

drawbox     MACRO       x1, y1, x2, y2, color

            push        color y2 x2 y1 x1       ; Guardar par metros.
            call        _drawbox                ; Llamar al procedimiento

            ENDM

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

drawchar    MACRO       char, x, y, color

            push        color y x char          ; Guardar par metros.
            call        _drawchar               ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Imprimir n caracteres de una cadena de texto en pantalla
;        (Los valores indicados para las coordenadas X son alineados
;        a un l¡mite m£ltiplo de SCRXCHAR)
;
;        Entrada:
; 
;        seg:text = Cadena de texto ASCIIZ.
;        n = N§ de caracteres a imprimir.
;        x = Coordenada X inicial.
;        y = Coordenada Y inicial.
;        color = Color del texto.
; --------------------------------------------------------------------------- 

drawnchar   MACRO       seg, text, n, x, y, color

            push        color y x n             ; Guardar par metros.
            push        seg OFFSET text 
            call        _drawnchar              ; Llamar al procedimiento

            ENDM

; --------------------------------------------------------------------------- 
;     Imprimir una cadena de texto en pantalla
;        (Los valores indicados para las coordenadas X son alineados
;        a un l¡mite m£ltiplo de SCRXCHAR)
;
;        Entrada:
; 
;        ds:text = Cadena de texto ASCIIZ.
;        x = Coordenada X inicial.
;        y = Coordenada Y inicial.
;        color = Color del texto.
; --------------------------------------------------------------------------- 

drawtext    MACRO       text, x, y, color

            drawnchar   ds, text, 0ffffh, x, y, color

            ENDM

; --------------------------------------------------------------------------- 
;     Copiar un bloque entre dos posiciones de la memoria de v¡deo.
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

drawcpy     MACRO       x, y, x1, y1, x2, y2

            push        y2 x2                   ; Guardar par metros.
            push        y1 x1
            push        y x         
            call        _drawcpy                ; Llamar al procedimiento

            ENDM

