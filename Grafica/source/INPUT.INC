; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        INPUT.INC - Macros de las funciones de los controles de
;                    entrada de datos.
; --------------------------------------------------------------------------- 

            IFDEF _INPUT_ASM
                PUBLIC  _inputline, _freeinput, _sendmsg
            ELSE
                EXTRN   _inputline:NEAR, _freeinput:NEAR, _sendmsg:NEAR
            ENDIF

; ---------------------------------------------------------------------------

HINPUT      TYPEDEF     WORD                    ; Manejador del control.

; ---------------------------------------------------------------------------
;     Identificadores de tipos de controles
; ---------------------------------------------------------------------------

INLINEID    EQU         1                       ; L¡nea de entrada.

; ---------------------------------------------------------------------------
;     Identificadores de mensajes
; ---------------------------------------------------------------------------

            ; Mensajes para los controles en general.
CMBASE      EQU         8000h
CMINIT      EQU         CMBASE + 1              ; Inicializar control.
CMKEY       EQU         CMBASE + 2              ; Tecla pulsada
CMFOCUS     EQU         CMBASE + 3              ; Tomar el foco.
CMNOFOCUS   EQU         CMBASE + 4              ; Perder el foco.

            ; Mensajes para los controles de l¡nea de entrada.
INBASE      EQU         4000h
INBUFCPY    EQU         INBASE + 1              ; Copiar el buffer de texto.

; ---------------------------------------------------------------------------
;     Identificadores de par metros de mensajes
; ---------------------------------------------------------------------------

NOPARAM     EQU         0                       ; Par metro no requerido.

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

inputline   MACRO       x, y, w, h, text

            push        OFFSET text h w y x     ; Guardar par metros.
            call        _inputline              ; Llamar al procedimiento

            ENDM

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

freeinput   MACRO       handler
            
            push        handler                 ; Guardar par metros.
            call        _freeinput              ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Enviar un mensaje al control indicado
;
;        Entrada:
;
;        handler = Manejador del control.
;        msg = Identificador del mensaje.
;        param = Par metro asociado al mensaje.
; ---------------------------------------------------------------------------

sendmsg     MACRO       handler, msg, param
           
            push        param msg handler       ; Guardar par metros.
            call        _sendmsg                ; Llamar al procedimiento

            ENDM
