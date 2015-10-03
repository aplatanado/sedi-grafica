; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        MATH.INC - Macros de funciones matem ticas.
; --------------------------------------------------------------------------- 

            IFDEF _MATH_ASM
                PUBLIC  _initmath, _fstrc, _atof, _atonsf, _itoa, _ftoa
                PUBLIC  _fxpy, _fexp, _ffact, _fr2pi
            ELSE
                EXTRN   _initmath:NEAR, _fstrc:NEAR, _atof:NEAR, 
                EXTRN   _atonsf:NEAR, _itoa:NEAR, _ftoa:NEAR, _fxpy:NEAR
                EXTRN   _fexp:NEAR, _ffact:NEAR, _fr2pi:NEAR
            ENDIF

; ---------------------------------------------------------------------------
;     Identificadores de tipos de n£meros
; ---------------------------------------------------------------------------

CONDMASK    EQU         0100010100000000b       ; M scara de tipo.
SIGNMASK    EQU         0000001000000000b       ; M scara de signo.
NUMMASK     EQU         0000000100000000b       ; M scara no n£mero finito.

UNSUPPORTED EQU         0000000000000000b       ; No soportado.
NAN         EQU         0000000100000000b       ; No es un n£mero.
NORMAL      EQU         0000010000000000b       ; N£mero normal.
INFINITY    EQU         0000010100000000b       ; Infinito.
ZERO        EQU         0100000000000000b       ; Cero.
EMPTY       EQU         0100000100000000b       ; Registro vac¡o.
DENORMAL    EQU         0100010000000000b       ; N£mero denormal.

POSITIVO    EQU         0000000000000000b       ; N£mero positivo.
NEGATIVO    EQU         0000001000000000b       ; N£mero negativo.

; ---------------------------------------------------------------------------
;     Identificadores de tipos de redondeo
; ---------------------------------------------------------------------------

ROUNDMASK   EQU         0000110000000000b       ; M scara de redondeo.

NEAREST     EQU         0000000000000000b       ; Al m s cercano.
DOWN        EQU         0000010000000000b       ; Al inferior.
UP          EQU         0000100000000000b       ; Al superior.
TRUNC       EQU         0000110000000000b       ; Trunca al inferior.

; ---------------------------------------------------------------------------
;     Macros de texto
; ---------------------------------------------------------------------------

fdrop       EQU         <fstp st(0)>            ; Eliminar elemento st(0).
fdup        EQU         <fld st(0)>             ; Duplicar st(0).

; ---------------------------------------------------------------------------
;     Cargar la palabra de estado del copro en el registro de flags
; ---------------------------------------------------------------------------

fstatus     MACRO

            push        ax

            fstsw       ax                      ; ax = palabra de estado.
            sahf                                ; flags = ah.

            pop         ax

            ENDM

; ---------------------------------------------------------------------------
;     Inicializar el coprocesador matem tico
;
;        Salida:
;
;        Si cf = 0: No error
;        Si cf = 1: Error al inicializar el coprocesador matem tico
; --------------------------------------------------------------------------- 

initmath    MACRO

            call        _initmath               ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------
;     Establecer el tipo de redondeo
;
;        Entrada:
;
;        rc = Tipo de redondeo.
; ---------------------------------------------------------------------------

fstrc       MACRO       rc

            push        rc                      ; Guardar par metros.
            call        _fstrc                  ; Llamar al procedimiento

            ENDM

; --------------------------------------------------------------------------- 
;     Convertir de ASCIIZ a flotante
;
;        Entrada:
;
;        ds:text = Cadena de texto ASCIIZ.
;
;        Salida:
;
;        ds:si = Puntero al primer elemento no reconocido.
;
;        Si cf = 0: No error
;           st(0) = N£mero flotante.
;        Si cf = 1: Error al convertir a flotante
; --------------------------------------------------------------------------- 

atof        MACRO       text

            push        OFFSET text             ; Guardar par metros.
            call        _atof                   ; Llamar al procedimiento

            ENDM

; --------------------------------------------------------------------------- 
;     Convertir de ASCIIZ a flotante
;     El signo de la mantisa es reconocido como elemento no v lido
;
;        Entrada:
;
;        ds:text = Puntero a la cadena de texto ASCIIZ.
;
;        Salida:
;
;        ds:si = Puntero al primer elemento no reconocido.
;
;        Si cf = 0: No error
;           st(0) = N£mero flotante.
;        Si cf = 1: Error al convertir a flotante
; --------------------------------------------------------------------------- 

atonsf      MACRO       text

            push        OFFSET text             ; Guardar par metros.
            call        _atonsf                 ; Llamar al procedimiento

            ENDM

; --------------------------------------------------------------------------- 
;     Convertir de entero a ASCIIZ
;
;        Entrada:
;
;        i = N£mero entero de tama¤o WORD
;        ds:text = Puntero al buffer para la cadena ASCIIZ.
; ---------------------------------------------------------------------------

itoa        MACRO       i, text

            push        text i                  ; Guardar par metros.
            call        _itoa                   ; Llamar al procedimiento

            ENDM

; --------------------------------------------------------------------------- 
;     Convertir de flotante a ASCIIZ
;
;        Entrada:
;
;        st(0) = N£mero flotante.
;        ds:text = Puntero al buffer para la cadena ASCIIZ.
;        d = N£mero de cifras decimales.
;
;        Salida:
;
;        El n£mero flotante no es extraido de la pila.
;
;        Si cf = 0: No error
;        Si cf = 1: Error al convertir a ASCIIZ
; --------------------------------------------------------------------------- 

ftoa        MACRO       text, d

            push        d OFFSET text           ; Guardar par metros.
            call        _ftoa                   ; Llamar al procedimiento

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular st(1) elevado a st(0), almacenando el resultado en st(1)
;     y extrayendo st(0) de la pila.
; --------------------------------------------------------------------------- 

fxpy        MACRO

            call        _fxpy                   ; Llamar al procedimiento            

            ENDM

; ---------------------------------------------------------------------------
;     Calcular la exponencial de st(0), almacenando el resultado en st(0)
; --------------------------------------------------------------------------- 

fexp        MACRO

            call        _fexp                   ; Llamar al procedimiento            

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular el logaritmo neperiano de st(0), almacenando
;     el resultado en st(0)
; --------------------------------------------------------------------------- 

fln         MACRO

            fldl2e                              ; st(0) = log2(e).
            fld1                                ; st(0) = 1
            fdivr                               ; st(0) = 1/log2(e)   
            fxch                                ; Intercambiar st(0) y st(1)
            fyl2x                               ; st(0) = st(1)*log2(st(0)).

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular el logaritmo base 10 de st(0), almacenando
;     el resultado en st(0)
; --------------------------------------------------------------------------- 

flog10      MACRO

            fldl2t                              ; st(0) = log2(10).
            fld1                                ; st(0) = 1
            fdivr                               ; st(0) = 1/log2(10)   
            fxch                                ; Intercambiar st(0) y st(1)
            fyl2x                               ; st(0) = st(1)*log2(st(0)).

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular el seno de st(0), almacenando el resultado en st(0)
; --------------------------------------------------------------------------- 

frsin       MACRO

            call        _fr2pi                  ; Reducir.
            fsin                                ; Seno.

            ENDM

; ---------------------------------------------------------------------------
;     Calcular el coseno de st(0), almacenando el resultado en st(0)
; --------------------------------------------------------------------------- 

frcos       MACRO

            call        _fr2pi                  ; Reducir.
            fcos                                ; Coseno.

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular el tangente de st(0), almacenando el resultado en st(0)
; --------------------------------------------------------------------------- 

frtan       MACRO

            call        _fr2pi                  ; Reducir.
            fptan                               ; Tangente.
            fdiv

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular el arcoseno de st(0), almacenando el resultado en st(0)
; --------------------------------------------------------------------------- 

fasin       MACRO

            ; asin = atan (x / sqrt(1 - x^2)).
            fdup                                ; Duplicar st(0).
            fmul        st(0), st(0)            ; x^2.
            fld1                                ; Cargar 1.
            fsubr                               ; 1 - x^2.
            fsqrt                               ; sqrt (1 - x^2).
            fpatan

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular el arcocoseno de st(0), almacenando el resultado en st(0)
; --------------------------------------------------------------------------- 

facos       MACRO

            ;acos = atan (sqrt(1 - x^2) / x)

            fdup                                ; Duplicar st(0).
            fmul        st(0), st(0)            ; x^2.
            fld1                                ; Cargar 1.
            fsubr                               ; 1 - x^2.
            fsqrt                               ; sqrt (1 - x^2).
            fxch
            fpatan

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular el factorial de la parte entera de un n£mero flotante
;
;        Entrada:
;
;        st(0) = N£mero flotante.
;
;        Salida:
;
;        st(0) = Factorial del n£mero flotante.
; ---------------------------------------------------------------------------

ffact       MACRO

            call        _ffact                  ; Llamar al procedimiento

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular el seno hiperb¢lico de st(0), almacenando el
;     resultado en st(0)
; --------------------------------------------------------------------------- 

fsinh       MACRO

            fdup                                ; Duplicar st(0).
            fexp                                ; st(0) = exp(x)
            fxch                                
            fchs                                ; st(0) = -st(0)
            fexp                                ; st(0) = exp(-x)
            fsub                                ; st(0) = exp(x) - exp(-x)
            fld1                                ; Cargar 1.
            fdup                                ; Duplicar 1.
            fadd                                ; st(0) = 2.
            fdiv                                ; st(0) = sinh(x).

            ENDM

; ---------------------------------------------------------------------------
;     Calcular el coseno hiperb¢lico de st(0), almacenando el
;     resultado en st(0)
; --------------------------------------------------------------------------- 

fcosh       MACRO

            fdup                                ; Duplicar st(0).
            fexp                                ; st(0) = exp(x)
            fxch                                
            fchs                                ; st(0) = -st(0)
            fexp                                ; st(0) = exp(-x)
            fadd                                ; st(0) = exp(x) + exp(-x)
            fld1                                ; Cargar 1.
            fdup                                ; Duplicar 1.
            fadd                                ; st(0) = 2.
            fdiv                                ; st(0) = cosh(x).

            ENDM

; --------------------------------------------------------------------------- 
;     Calcular la tangente hiperb¢lica de st(0), almacenando el
;     resultado en st(0)
; --------------------------------------------------------------------------- 

ftanh       MACRO

            fdup                                ; Duplicar st(0).
            fexp                                ; st(0) = exp(x)
            fxch
            fchs                                ; st(0) = -st(0)
            fexp                                ; st(0) = exp(-x)
            fdup                                ; Duplicar st(0).
            fadd        st(0), st(2)            ; st(0) = exp(x) + exp(-x)
            fxch
            fsubp       st(2), st(0)            ; st(0) = exp(x) - exp(-x)
            fdiv

            ENDM

; --------------------------------------------------------------------------- 
;     Cargar en st(0) la constante e
; --------------------------------------------------------------------------- 

flde        MACRO

            fldl2e                              ; st(0) = log2(e).
            fdup                                ; Duplicar st(0).
            fstrc       TRUNC                   
            frndint                             ; Redondear a entero st(0).
            fstrc       NEAREST                 
            fxch                                ; Intercambiar st(0) y st(1)
            fsub        st(0), st(1)            ; Separar entera y frac.
            f2xm1                               ; st(0) = 2^frac(log2(e))-1
            fld1                                ; st(0) = 1
            fadd                                ; st(0) = 2^frac(log2(e))   
            fscale                              ; st(0) = e
            fxch
            fdrop

            ENDM

