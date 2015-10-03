; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        MATH.ASM - Procedimientos de las funciones matem ticas.
; --------------------------------------------------------------------------- 

.MODEL SMALL

_MATH_ASM   EQU         0

            INCLUDE     MATH.INC

; ---------------------------------------------------------------------------
;     Escribir un caracter en ds:[di] e incrementar di.
; ---------------------------------------------------------------------------

stchar      MACRO       char

            mov         byte ptr[di], char
            inc         di

            ENDM

; ---------------------------------------------------------------------------
;     Extraer un d¡gito de st(0), escribirlo en ds:[di] e incrementar di.
;
;        Modifica los registros:  ax
; ---------------------------------------------------------------------------

stdigit     MACRO

            fdup                                ; Duplicar st(0).
            frndint                             ; Truncar a entero st(0)
            fsub        st(1), st(0)            ; Eliminar la cifra.
            fistp       digito                  ; Extraer d¡gito.
            mov         ax, digito              ; ax = d¡gito
            fmul        diez                    ; Desplazar el punto decimal.
            add         ax, '0'                 ; ax = cifra en ASCII.
            stchar      al                      ; Escribir cifra.

            ENDM

; ---------------------------------------------------------------------------

.DATA

; ---------------------------------------------------------------------------
;     Constantes num‚ricas
; ---------------------------------------------------------------------------

diez        dd          10.0                    ; N£mero 10
dos         dd          2.0                     ; N£mero 2
media       dd          0.5                     ; N£mero 0.5
decima      dd          0.1                     ; N£mero 0.1

; ---------------------------------------------------------------------------

.CODE
.386

; --------------------------------------------------------------------------- 
;     Inicializar el coprocesador matem tico
;
;        Salida:
;
;        Si cf = 0: No error
;        Si cf = 1: Error al inicializar el coprocesador matem tico
; --------------------------------------------------------------------------- 

_initmath   PROC
            LOCAL       FPUControl:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            add         sp, LOCALSIZE

            ; Comprobar que haya una FPU en el sistema.
            fninit
            fnstcw      FPUControl              ; El valor por defecto
            cmp         FPUControl, 037Fh       ; para la palabra de control
            jne         @i2                     ; es 037Fh.
            clc

@i1:        ; Retornar del procedimiento.
            mov         sp, bp
            pop         bp
            ret

@i2:        ; Retornar indicando el error.
            stc
            jmp         @i1

_initmath   ENDP

; ---------------------------------------------------------------------------
;     Establecer el tipo de redondeo
;
;        Entrada:
;
;        rc = Tipo de redondeo.
; ---------------------------------------------------------------------------

_fstrc      PROC
            ARG         rc:WORD = ARGLEN
            LOCAL       FPUControl:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax dx

            ; Cargar la palabra de control y modificar
            ; el tipo de redondeo.
            fstcw       FPUControl              ; Guardar palabra control.
            mov         ax, FPUControl
            and         ax, not ROUNDMASK       ; Limpiar bits a modificar.
            mov         dx, rc
            and         dx, ROUNDMASK           ; Verificar opciones.
            or          ax, dx                  ; Establecer opciones.
            mov         FPUControl, ax
            fldcw       FPUControl              ; Carga palabra de control.

            ; Retornar del procedimiento.
            pop         dx ax
            mov         sp, bp
            pop         bp
            ret         ARGLEN

_fstrc      ENDP

; --------------------------------------------------------------------------- 
;     Convertir de ASCIIZ a flotante
;     Espacios, tabuladores y el signo de la mantisa son reconocidos como
;     elementos no v lidos
;
;        Entrada:
;
;        ds:si = Puntero a la cadena de texto ASCIIZ.
;
;        Salida:
;
;        ds:si = Puntero al primer elemento no reconocido.
;
;        Si cf = 0: No error
;           st(0) = N£mero flotante.
;        Si cf = 1: Error al convertir a flotante
; --------------------------------------------------------------------------- 

_atof_base  PROC
            LOCAL       esign:WORD, temp:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax cx dx

            ; Inicializar variables locales.
            cld
            xor         dx, dx                  ; dx = indicador de estado.
            mov         esign, 1                ; Signo del exponente.
            fldz                                ; st(0) = r = 0.

@afb1:      ; Procesar la parte entera.
            lodsb                               ; al = caracter.
            cmp         al, '0'                 ; Mientras al >= 0,
            jb          @afb2
            cmp         al, '9'                 ; y al <= 9, agregar
            ja          @afb2                   ; la nueva cifra.
            fmul        diez                    ; r = r * 10.
            sub         al, '0'                 ; al = cifra.
            cbw
            mov         temp, ax                ; temp = cifra.
            fiadd       temp                    ; r = (r * 10) + cifra.
            or          dx, 1                   ; Hay parte entera.
            jmp         @afb1                   ; Siguiente caracter.

@afb2:      ; Comprobar si hay parte fraccionaria.
            cmp         al, '.'                 ; Si al = punto decimal,
            jne         @afb5                   ; procesar parte decimal.
            fld         decima                  ; st(0) = d = 0.1, st(1) = r
            lodsb                               ; al = caracter.

@afb3:      ; Procesar parte fraccionaria.
            cmp         al, '0'                 ; Mientras al >= 0,
            jb          @afb4
            cmp         al, '9'                 ; y al <= 9, agregar
            ja          @afb4                   ; la nueva cifra.
            sub         al, '0'                 ; al = cifra.
            cbw
            mov         temp, ax                ; temp = cifra.
            fild        temp                    ; st(0) = cifra, st(1) = d.
            fmul        st(0), st(1)            ; st(0) = d * cifra.
            or          dx, 2                   ; Hay parte fraccionaria.
            faddp       st(2)                   ; st(1) = r += d * cifra
            fmul        decima                  ; st(0) = d *= 1.0
            lodsb                               ; Siguiente caracter.
            jmp         @afb3                    
@afb4:
            fdrop                               ; Eliminar d.

@afb5:      ; Comprobar que hasta el momento el n£mero haya sido v lido.
            test        dx, dx                  
            jnz         @afb6                   ; Sino es v lido, retornar
            fdrop                               ; indicando el error.
            stc                                 
            jmp         @afbG

@afb6:      ; Comprobar si hay parte exponencial.
            cmp         al, 'e'                 ; Si al == 'e'...
            je          @afb7
            cmp         al, 'E'                 ; o al == 'E', hay parte
            jne         @afbF                   ; exponencial. Procesarla.

@afb7:      ; Procesar el signo del exponente.
            lodsb
            cmp         al, '+'                 ; Si signo +, ignorar
            je          @afb8                   ; el caracter y continuar.
            cmp         al, '-'                 ; Si signo -, indicarlo y
            jne         @afb9                   ; continuar.
            mov         esign, -1               ; Signo exponente = -1.
@afb8:
            lodsb                               ; al = caracter.

@afb9:      ; Comprobar que a continuaci¢n hay al menos un d¡gito.
            cmp         al, '0'                 ; Si al < 0,
            jb          @afbF                     
            cmp         al, '9'                 ; o al > 9, terminar.
            ja          @afbF
            xor         cx, cx                  ; cx = exponente = 0.

@afbA:      ; Procesar los d¡gitos del exponente.
            cmp         al, '0'                 ; Mientras al >= 0,
            jb          @afbC                     
            cmp         al, '9'                 ; y al <= 9, agregar
            ja          @afbC                   ; la nueva cifra.
            xchg        ax, cx                  ; ax = exponente, cl =char.
            mov         dx, 10
            mul         dx
            jc          @afbB                   ; Overflow.
            sub         cl, '0'                 ; cl = cifra.
            xor         ch, ch                  ; cx = cifra
            add         ax, cx                  ; exp = exp * 10 + cifra.
            mov         cx, ax                  ; cx = exponente.
            lodsb                               ; Siguiente d¡gito.
            jmp         @afbA                    
@afbB:
            mov         ax, 0ffffh              ; ax = m ximo exponente.
            lodsb                               ; Siguiente d¡gito.
            jmp         @afbA                    

@afbC:      ; Comprobar el valor del exponente.
            jcxz        @afbF                   ; Si exponente = 0, ignorar.
            cmp         esign, 0
            jl          @afbE                   ; Si esign < 0 ...

@afbD:      ; Agregar exponente positivo al n£mero.
            fmul        diez                    ; r *= 10
            loop        @afbD
            jmp         @afbF                   ; Continuar.

@afbE:      ; Agregar exponente negativo al n£mero.
            fmul        decima                  ; r *= 0.1
            loop        @afbE

@afbF:      ; Indicar que no se a producido ning£n error.
            clc                                 ; No error.

@afbG:      ; Retornar del procedimiento.
            dec         si                      ; [si] = primer caracter
            pop         dx cx ax                ; no v lido.
            mov         sp, bp
            pop         bp
            ret

_atof_base  ENDP

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

_atof       PROC
            ARG         text:NEAR PTR = ARGLEN
            LOCAL       sign:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax

            ; Inicializar variables locales.
            cld
            mov         si, text                ; si = offset cadena ASCIIZ.
            mov         sign, 1                 ; Signo de la mantisa.

@af1:       ; Ignorar espacios y tabuladores.
            lodsb                               ; al = caracter.
            cmp         al, ' '                 ; Si al = espacio, ignorar
            je          @af1                    ; el caracter.
            cmp         al, 09h                 ; Si al = tabulador,
            je          @af1                    ; ignorar el caracter.

            ; Procesar el signo de la mantisa.
            cmp         al, '+'                 ; Si signo +, ignorar
            je          @af3                    ; el caracter y continuar.
            cmp         al, '-'                 ; Si signo -, indicarlo y
            jne         @af2                    ; continuar.
            mov         sign, -1                ; Signo mantisa = -1.
            jmp         @af3
@af2:
            dec         si

@af3:       ; Convertir el resto del n£mero.
            call        _atof_base
            jc          @af4                    ; Si error salir.
            fimul       sign                    ; Sino aplicar signo mantisa.

@af4:       ; Retornar del procedimiento.
            pop         ax
            mov         sp, bp
            pop         bp
            ret         ARGLEN

_atof       ENDP

; --------------------------------------------------------------------------- 
;     Convertir de ASCIIZ a flotante
;     El signo de la mantisa es reconocido como elemento no v lido
;
;        Entrada:
;
;        ds:text = Cadena de texto ASCIIZ.
;
;        Salida:
;
;        st(0) = N£mero flotante.
;        ds:si = Puntero al primer elemento no reconocido.
;
;        Si cf = 0: No error
;        Si cf = 1: Error al convertir a flotante
; --------------------------------------------------------------------------- 

_atonsf     PROC
            ARG         text:NEAR PTR = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax

            ; Inicializar variables locales.
            cld
            mov         si, text                ; si = offset cadena ASCIIZ.

@anf1:      ; Ignorar espacios y tabuladores.
            lodsb                               ; al = caracter.
            cmp         al, ' '                 ; Si al = espacio, ignorar
            je          @anf1                   ; el caracter.
            cmp         al, 09h                 ; Si al = tabulador,
            je          @anf1                   ; ignorar el caracter.
            dec         si

            ; Convertir el resto del n£mero.
            call        _atof_base

            ; Retornar del procedimiento.
            pop         ax
            pop         bp
            ret         ARGLEN

_atonsf     ENDP

; --------------------------------------------------------------------------- 
;     Convertir de entero a ASCIIZ
;
;        Entrada:
;
;        i = N£mero entero de tama¤o WORD
;        ds:text = Buffer para la cadena ASCIIZ.
; ---------------------------------------------------------------------------

_itoa       PROC
            ARG         i:WORD, text:NEAR PTR = ARGLEN

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        ax bx cx dx di

            ; Inicializar variables locales.
            mov         di, text                ; di = offset cadena ASCIIZ.
            mov         ax, i                   ; ax = entero.

            ; Determinar el tipo de n£mero.
            cmp         ax, 0                   ; ¨Es cero?.
            jne         @ia1
            stchar      '0'                     ; Escribir 0 y salir.
            jmp         @ia8
@ia1:
            jnl         @ia2                    ; Si es positivo, saltar...
            stchar      '-'                     ; Escribir signo negativo.
            neg         ax                      ; Pasar a positivo.

@ia2:       ; Obtener cada cifra y almacenarlas en la pila
            xor         bx, bx
            xor         cx, cx                  ; contador = 0
            mov         dl, 10
@ia3:
            div         dl                      ; ah = digito.
            add         ah, '0'                 ; ah = cifra en ASCII.
            mov         bl, ah                  ; bx = cifra en ASCII.
            push        bx                      ; Guardar cifra.
            inc         cx
            test        al, al                  ; Si cociente = cero,
            jz          @ia4                    ; saltar...
            xor         ah, ah
            jmp         @ia3                    ; Siguiente d¡gito.

@ia4:       ; Tomar las cifras almacenadas en la pila
            ; y pasarlar a la cadena de texto.
            pop         ax                      ; ax = cifra.
            stchar      al
            loop        @ia4                    ; Siguiente cifra.

@ia8:       ; Indicar final de cadena.
            stchar      0h

            ; Retornar del procedimiento.
            pop         di dx cx bx ax
            pop         bp
            ret         ARGLEN

_itoa       ENDP

; --------------------------------------------------------------------------- 
;     Convertir de flotante a ASCIIZ
;
;        Entrada:
;
;        st(0) = N£mero flotante.
;        ds:text = Buffer para la cadena ASCIIZ.
;        d = N£mero de cifras decimales.
;
;        Salida:
;
;        El n£mero flotante no es extraido de la pila.
;
;        Si cf = 0: No error
;        Si cf = 1: Error al convertir a ASCIIZ
; --------------------------------------------------------------------------- 

_ftoa       PROC
            ARG         text:NEAR PTR, d:WORD = ARGLEN
            LOCAL       digito:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            push        ax cx dx di

            ; Inicializar variables locales.
            mov         di, text                ; di = offset cadena ASCIIZ.

            ; Comprobar que se trate de un n£mero valido.
            fxam                                ; Examinar st(0).
            fstsw       ax                      ; ax = palabra de estado.
            mov         dx, ax
            and         ax, CONDMASK            ; Aplicar m scara.
            cmp         ax, ZERO                ; ¨Es cero?.
            je          @fa3
            cmp         ax, NORMAL              ; ¨Es normal?.
            je          @fa6
            stc                                 ; Terminar indicando el
            jmp         @faQ                    ; error.

@fa3:       ; Procesar el cero.
            stchar      '0'                     ; Escribir 0
            stchar      '.'                     ; Escribir punto decimal.
            mov         cx, d
@fa4:
            stchar      '0'                     ; Escribir tantos 0 como
            loop        @fa4                    ; decimales se desee.
            stchar      0h                      ; Indicar final de cadena.
            jmp         @faP

@fa6:       ; Indicar el signo del n£mero.
            and         dx, SIGNMASK            ; Aplicar m scara de signo.
            cmp         dx, NEGATIVO            ; ¨Es negativo?.
            jne         @fa8
            stchar      '-'                     ; Escribir signo negativo.
            fchs                                ; Pasar a positivo.

@fa8:       ; Desplazar la coma a la izquierda hasta que el
            ; n£mero tenga una cifra entera.
            xor         dx, dx                  ; dx = exponente.
@fa9:
            fld1
            fcomp                               ; Si el n£mero es mayor
            fstatus                             ; que 1, continuar.
            jc          @faA                    ; sino...
            fmul        diez                    ; desplazar a la izquierda,   
            dec         dx                      ; e decrementar exponente.
            jmp         @fa9

@faA:       ; Desplazar la coma a la derecha hasta que el
            ; n£mero tenga una cifra entera.
            fcom        diez                    ; Si el n£mero es menor
            fstatus                             ; que 10, continuar.
            jc          @faB                    ; sino...
            fdiv        diez                    ; desplazar a la derecha,   
            inc         dx                      ; e incrementar exponente.
            jmp         @faA

@faB:       ; Redondear a la £ltima cifra a visualizar.
            ; Para ello sumamos un 5 a la siguiente cifra despu‚s de la
            ; £ltima que va ha ser visualizada.
            fld         media                   ; st(0) = 0.5
            mov         cx, d                   ; contador = d.
            jcxz        @faD
@faC:
            fdiv        diez                    ; st(0) *= 10.   
            loop        @faC                    ; Repetir d veces.
@faD:
            fadd                                ; Sum mos el 5.

            ; Nos aseguramos de que el n£mero siga teniendo
            ; una £nica cifra entera.
            fcom        diez                    ; Si el n£mero es menor
            fstatus                             ; que 10, continuar.
            jc          @faE                    ; sino...
            fdiv        diez                    ; desplazar a la derecha,   
            inc         dx                      ; e incrementar exponente.

@faE:       ; Extraer el primer d¡gito.
            fstrc       TRUNC                   ; Activar el truncamiento.
            stdigit                             ; Escribir d¡gito.
            stchar      '.'                     ; Escribir punto decinal.

            ; Escribir la cantidad de cifras decimales indicadas.
            mov         cx, d                   ; contador = d.
@faF:
            stdigit                             ; Escribir d¡gito.
            loop        @faF

            ; Escribir la parte exponencial si existe.
            test        dx, dx                  ; Si exponente != 0,
            jnz         @faG                    ; saltar...
            stchar      0h                      ; Sino indicar final de
            jmp         @faP                    ; cadena y salir.
@faG:
            stchar      'E'                     ; Escribir indicador.
            itoa        dx, di                  ; Escribir el exponente.

@faP:       ; Indicar que no error.
            fstrc       NEAREST                 : Redondeo al m s cercano.
            clc

@faQ:       ; Retornar del procedimiento.
            pop         di dx cx ax
            mov         sp, bp
            pop         bp
            ret         ARGLEN

_ftoa       ENDP

; --------------------------------------------------------------------------- 
;     Calcular st(1) elevado a st(0), almacenando el resultado en st(1)
;     y extrayendo st(0) de la pila.
; ---------------------------------------------------------------------------

            ;     st(1) = x
            ;     st(0) = y
_fxpy       PROC
            LOCAL       sign:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE

            ; Inicializar variables locales.
            mov         sign, 1                 ; Signo del resultado.

            ; Comprobar si x es negativo.
            fxch                                ; st(0) = x, st(1) = y
            ftst
            fstatus
            ja          @fp4                    ; Saltar si positivo.
            jb          @fp1                    ; Saltar si negativo.

            ; Cualquier potencia de 0 es 0.
            fdrop                               ; Eliminar los elementos no
            fdrop                               ; necesarios.
            fldz                                ; Cargar 0.
            jmp         @fp5

@fp1:       ; X es negativo. Comprobar si y es fraccionario.
            fld         st(1)                   ; Carga una copia de y.
            frndint                             ; Redondear a entero y.
            fcom        st(2)                   ; Comparar INT(y) con y.
            fstatus
            je          @fp2                    ; Saltar si iguales.
            fdrop
            jmp         @fp4

@fp2:       ; X es negativo. Comprobar si y es par o impar.
            fmul        media                   ; y / 2.
            fdup                                ; Duplicar st(0).
            frndint                             ; Redondear a entero y/2.
            fcomp                               ; Comparar INT(y/2) con y/2.
            fstatus
            je          @fp3                    ; Saltar si par.
            mov         sign, -1                ; Impar. Salida negativa
@fp3:
            fdrop
            fchs                                ; x = abs(x).

@fp4:       ; Calcular x^y si x es positivo.
            fyl2x                               ; st(0) = y*log2(x).
            fdup                                ; Duplicar st(0).
            fstrc       TRUNC                   
            frndint                             ; Redondear a entero st(0).
            fstrc       NEAREST                 
            fxch                                ; Intercambiar st(0) y st(1)
            fsub        st(0), st(1)            ; Separar entera y frac.
            f2xm1                               ; st(0) = 2^frac(y*log2(x))-1
            fld1                                ; st(0) = 1
            fadd                                ; st(0) = 2^frac(y*log2(x))
            fscale                              ; st(0) = resultado.
            fxch
            fdrop

            ; Aplicar signo mantisa.
            fimul       sign

@fp5:       ; Retornar del procedimiento.
            mov         sp, bp
            pop         bp
            ret

_fxpy       ENDP

; ---------------------------------------------------------------------------
;     Calcular la exponencial de st(0), almacenando el resultado en st(0)
; --------------------------------------------------------------------------- 

_fexp       PROC

            fldl2e                              ; st(0) = log2(e).
            fmul                                ; str(0) = st(1)*log2(e)
            fdup                                ; Duplicar st(0)        
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

            ; Retornar del procedimiento.
            ret

_fexp       ENDP

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

_ffact      PROC

            ; Tomar la parte entera del n£mero flotante.
            fstrc       TRUNC                   ; Truncamiento.
            frndint                             ; Redondear a entero st(0).
            fstrc       NEAREST                 ; Redondeo al m s cercano.

            ; Comprobar si es un 0.
            ftst                                ; Comparar st(0) con 0.
            fstatus
            jne         @ft1                    ; Saltar si no 0.
            fdrop                               ; Eliminar st(0).
            fld1                                ; Cargar 1.
            jmp         @ft4                    ; Salir.

@ft1:       ; Calcular el factorial.
            fdup                                ; Duplicar st(0).
@ft2:
            fld1                                ; Cargar 1.
            fsub                                ; st(0) = st(0) - 1
            ftst                                ; Comparar st(0) con 0.
            fstatus
            je          @ft3                    ; Saltar si 0.
            fmul        st(1), st(0)
            jmp         @ft2
@ft3:       
            fdrop                               ; Eliminar st(0).

@ft4:       ; Retornar del procedimiento.
            ret       

_ffact      ENDP

; --------------------------------------------------------------------------- 
;     Reducir n£mero por un m£ltiplo de 2*pi
;
;        Entrada:
;
;        st(0) = N£mero flotante.
;
;        Salida:
;
;        st(0) = N£mero flotante resultado de reducir el de la entrada.
; ---------------------------------------------------------------------------

_fr2pi      PROC

            ; Obtener 2*pi.
            fldpi                               ; Cargar pi.
            fmul        dos                     ; st(0) = 2*pi.
            fxch

@fr1:       ; Realizar la reducci¢n.
            fprem1                              ; Reducci¢n.
            fstatus
            jp          @fr1                    ; Reducci¢n incompleta.

            ; Eliminar 2*pi.
            fxch
            fdrop

            ; Retornar del procedimiento.
            ret       

_fr2pi      ENDP

            END
