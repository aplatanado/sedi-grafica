; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        SYSTEM.ASM - Procedimientos de las funciones del sistema.
; ---------------------------------------------------------------------------

.MODEL SMALL

_SYS_ASM    EQU         0

            INCLUDE     SYSTEM.INC

; ---------------------------------------------------------------------------

.CODE
.386

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

_malloc    PROC
            ARG         blksize:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        bx

            ; Convertir la cantidad en bytes a cantidad en p rrafos.
            mov         ax, blksize             ; ax = cantidad en bytes.
            mov         bx, ax
            shr         bx, 4                   ; bx = 16 bytes / p rrafo.
            test        ax, 0fh                 ; Comprobar si hay resto.
            jz          @m1
            inc         bx                      ; Compensar el resto.

@m1:        ; Reservar la cantidad de memoria deseada.
            mov         ah, 48h                 ; Servicio 48h.
            int         21h                     ; Reservar memoria.

            ; Retornar del procedimiento.
            pop         bx
            pop         bp
            ret         ARGLEN

_malloc     ENDP

; --------------------------------------------------------------------------- 
;     Modificar la cantidad de memoria reservada en un bloque
; 
;        Entrada:
; 
;        seg = Segmento del bloque de memoria a liberar.
;        blksize = Cantidad de memoria requerida en bytes.
; 
;        Salida:
; 
;        Si cf = 0: No error
;        Si cf = 1: Error al modificar el tama¤o de bloque indicado
; --------------------------------------------------------------------------- 

_realloc    PROC
            ARG         segm:WORD, blksize:WORD = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax bx es

            ; Convertir la cantidad en bytes a cantidad en p rrafos.
            mov         ax, blksize             ; ax = cantidad en bytes.
            mov         bx, ax
            shr         bx, 4                   ; bx = 16 bytes / p rrafo.
            test        ax, 0fh                 ; Comprobar si hay resto.
            jz          @r1
            inc         bx                      ; Compensar el resto.

@r1:        ; Modificar el tama¤o del segmento de memoria especificado.
            mov         ax, segm
            mov         es, ax                  ; es = bloque reservado.
            mov         ah, 4ah                 ; Servicio 4ah.
            int         21h                     ; Modificar tama¤o.

            ; Retornar del procedimiento.
            pop         es bx ax
            pop         bp
            ret         ARGLEN

_realloc    ENDP

            END
