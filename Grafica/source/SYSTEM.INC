; --------------------------------------------------------------------------- 
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        SYSTEM.INC - Macros de funciones del sistema.
; --------------------------------------------------------------------------- 

            IFDEF _SYS_ASM
               PUBLIC   _malloc, _realloc
            ELSE
               EXTRN    _malloc:NEAR, _realloc:NEAR
            ENDIF

; ---------------------------------------------------------------------------
;     Indicadores de verdadero o falso.
; ---------------------------------------------------------------------------

TRUE        EQU         -1                      ; Valor de verdadero.
FALSE       EQU         0                       ; Valor de falso.

; ---------------------------------------------------------------------------
;     C¢digos de scan del teclado
; ---------------------------------------------------------------------------

KBESC       EQU         011bh                   ; Escape.
KBBACKSPACE EQU         0e08h                   ; Backspace.
KBTAB       EQU         0f09h                   ; Tabulador.
KBENTER     EQU         1c0dh                   ; Enter.

KBF1        EQU         3b00h                   ; F1.
KBF2        EQU         3c00h                   ; F2.
KBF3        EQU         3d00h                   ; F3.
KBF4        EQU         3e00h                   ; F4.
KBF5        EQU         3f00h                   ; F5.
KBF6        EQU         4000h                   ; F6.
KBF7        EQU         4100h                   ; F7.
KBF8        EQU         4200h                   ; F8.
KBF9        EQU         4300h                   ; F9.
KBF10       EQU         4400h                   ; F10.
KBF11       EQU         8500h                   ; F11.
KBF12       EQU         8600h                   ; F12.

KBHOME      EQU         4700h                   ; Inicio de p gina.
KBUP        EQU         4800h                   ; Arriba.
KBPGUP      EQU         4900h                   ; Retroceder p gina.
KBLEFT      EQU         4b00h                   ; A la izquierda.
KBRIGHT     EQU         4d00h                   ; A la derecha.
KBEND       EQU         4f00h                   ; Fin de p gina.
KBDOWN      EQU         5000h                   ; Abajo.
KBPGDN      EQU         5100h                   ; Avanzar p gina.
KBDEL       EQU         5300h                   ; Suprimir.

KBALTX      EQU         2d00h                   ; ALT + X.

; ---------------------------------------------------------------------------
;     Esperar la pulsaci¢n de una tecla y leer el caracter
;
;        Salida:
;
;        ax = C¢digo de scan de la tecla.
; --------------------------------------------------------------------------- 

readkey     MACRO

            xor         ah, ah                  ; Servicio 0.
            int         16h                     ; Leer tecla.

            ENDM

; ---------------------------------------------------------------------------
;     Emitir un pitido por el speaker
; --------------------------------------------------------------------------- 

beep        MACRO

            ; Guardar los registros afectados.
            push        ax dx

            ; Imprimir el caracter 07h.
            mov         dl, 07h                 ; dl = caracter.
            mov         ah, 02h                 ; Servicio 02h.
            int         21h                     ; Imprimir caracter.

            ; Restaurar los registros afectados.
            pop         dx ax

            ENDM

; ---------------------------------------------------------------------------
;     Imprimir una cadena por pantalla
;
;        Entrada:
;
;        msg = Cadena de caracteres a mostrar.
; --------------------------------------------------------------------------- 

prnstr      MACRO       msg

            ; Guardar los registros afectados.
            push        ax dx

            ; Imprimir la cadena especificada.
            mov         dx, OFFSET msg          ; dx = desp. de la cadena.
            mov         ah, 09h                 ; Servicio 09h.
            int         21h                     ; Imprimir cadena.

            ; Restaurar los registros afectados.
            pop         dx ax

            ENDM

; ---------------------------------------------------------------------------
;     Reservar un bloque de memoria
; 
;        Entrada:
; 
;        blksize = Cantidad de memoria requerida en bytes.
; 
;        Salida:
;
;        Si cf = 0: No error
;           ax = Valor del segmento para el bloque reservado.
;        Si cf = 1: Error al reservar la memoria
; --------------------------------------------------------------------------- 

malloc      MACRO       blksize

            push        blksize                 ; Guardar par metros.
            call        _malloc                 ; Llamar al procedimiento.

            ENDM

; --------------------------------------------------------------------------- 
;     Modificar la cantidad de memoria reservada en un bloque
; 
;        Entrada:
; 
;        segm = Segmento del bloque de memoria a liberar.
;        blksize = Cantidad de memoria requerida en bytes.
; 
;        Salida:
; 
;        Si cf = 0: No error
;        Si cf = 1: Error al modificar el tama¤o de bloque indicado
; --------------------------------------------------------------------------- 

realloc     MACRO       segm, blksize

            push        blksize segm            ; Guardar par metros.
            call        _realloc                ; Llamar al procedimiento.

            ENDM

; --------------------------------------------------------------------------- 
;     Liberar un bloque de memoria reservada
; 
;        Entrada:
; 
;        segm = Segmento del bloque de memoria a liberar.
;
;        Salida:
; 
;        Si cf = 0: No error
;        Si cf = 1: Error al liberar memoria
; ---------------------------------------------------------------------------

free        MACRO       segm

            ; Guardar los registros afectados.
            push        ax es

            ; Liberar el segmento de memoria especificado.
            mov         ax, segm
            mov         es, ax                  ; es = memoria a liberar.
            mov         ah, 49h                 ; Servicio 49h.
            int         21h                     ; Liberar memoria.

            ; Restaurar los registros afectados.
            pop         es ax

            ENDM

; --------------------------------------------------------------------------- 
;     Salir del programa
; 
;        Entrada:
; 
;        retval = Valor de retorno del programa.
; --------------------------------------------------------------------------- 

exit        MACRO       retval

            mov         ah, 4ch                 ; Servicio 4Ch,
            int         21h                     ; Salir al DOS.

            ENDM
