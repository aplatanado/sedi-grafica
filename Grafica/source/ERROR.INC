; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        ERROR.INC - C¢digos de error de la aplicaci¢n.
; ---------------------------------------------------------------------------

NOERROR     EQU         0                       ; No error.
NO386       EQU         1                       ; CPU < 386.
NOFPU       EQU         2                       ; No coprocesador matem tico.
NOVGA       EQU         3                       ; No VGA o superior.
NOMEM       EQU         4                       ; No hay memoria suficiente.
SYNERR      EQU         5                       ; Error de sintaxis.
NOVAL       EQU         6                       ; Valor inv lido.
NOFUNC      EQU         7                       ; Funci¢n inv lida.
