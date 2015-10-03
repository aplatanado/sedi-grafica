; ---------------------------------------------------------------------------
;     Programa: Trazador de funciones en pantalla gr fica
;     Versi¢n: 1.0
;     Plataforma: DOS (386+)
;     Por: Jes£s Miguel Torres Jorge
;        CALC.INC - Procedimientos de las funciones de calculadora.
; --------------------------------------------------------------------------- 

.MODEL SMALL

_CALC_ASM   EQU         0

            INCLUDE     STRING.INC              ; Macros de cadenas.
            INCLUDE     MATH.INC                ; Funciones matem ticas.
            INCLUDE     STACK.INC               ; Funciones de pila.
            INCLUDE     ERROR.INC               ; C¢digos de error.
            INCLUDE     CALC.INC

; ---------------------------------------------------------------------------

OPBINMASK   EQU         000040000h              ; M scara operador binario.
OPUNIMASK   EQU         000020000h              ; M scara operador unitario.
VARMASK     EQU         000010000h              ; M scara variables.

OPID        EQU         0fff00000h              ; Id. c¢digos de operador.

OPBINID     EQU         OPID + OPBINMASK        ; Id. operador binario.
OPUNIID     EQU         OPID + OPUNIMASK        ; Id. operador unitario.
VARID       EQU         OPID + VARMASK          ; Id. variables.

FIRSTOPBIN  EQU         1                       ; Primer operador binario

OPAPAR      EQU         1                       ; Abrir par‚ntesis.
OPCPAR      EQU         2                       ; Cerrar par‚ntesis.
OPPOT       EQU         3                       ; x elevado y.
OPMUL       EQU         4                       ; Producto.
OPDIV       EQU         5                       ; Divisi¢n.
OPADD       EQU         6                       ; Suma.
OPSUB       EQU         7                       ; Resta.

LASTOPBIN   EQU         7                       ; Ultimo operador binario
FIRSTOPUNI  EQU         7                       ; Primer operador unitario

OPCHS       EQU         7                       ; Cambio de signo.
OPABS       EQU         8                       ; Valor absoluto.
OPSQRT      EQU         9                       ; Raiz cuadrada.
OPEXP       EQU         10                      ; Exponencial.
OPLN        EQU         11                      ; Logaritmo neperiano.
OPLOG       EQU         12                      ; Logaritmo base 10.
OPSINH      EQU         13                      ; Seno hiperb¢lico.
OPCOSH      EQU         14                      ; Coseno hiperb¢lico.
OPTANH      EQU         15                      ; Tangente hiperb¢lica.
OPSIN       EQU         16                      ; Seno.
OPCOS       EQU         17                      ; Coseno.
OPTAN       EQU         18                      ; Tangente.
OPASIN      EQU         19                      ; Arcoseno.
OPACOS      EQU         20                      ; Arcocoseno.
OPATAN      EQU         21                      ; Arcotangente.
OPFACT      EQU         22                      ; Factorial.

LASTOPUNI   EQU         22                      ; Ultimo operador unitario.
FIRTSVAR    EQU         23                      ; Primer variable.

VAREXP      EQU         23                      ; N£mero e.
VARPI       EQU         24                      ; N£mero pi.
VARX        EQU         25                      ; Inc¢gnita X.

LASTVAR     EQU         25                      ; Ultima variable.
NUMOFOP     EQU         LASTVAR                 ; N£mero de operadores.

; ---------------------------------------------------------------------------
;     Pasar una expresi¢n infija en una cadena a una pila
;
;        Entrada:
;
;        handler = Manejador de la pila.
;        ds:expr = Cadena de texto ASCIIZ de la expresi¢n.
;
;        Salida:
;
;        Si cf = 0: No error
;        Si cf = 1: Error de sintaxis
; ---------------------------------------------------------------------------

convstack   MACRO       handler, expr

            push        OFFSET expr handler     ; Guardar par metros.
            call        _convstack              ; Llamar al procedimiento

            ENDM

; ---------------------------------------------------------------------------

.DATA

; ---------------------------------------------------------------------------
;     Cadenas identificadoras de los operadores y variables.
; ---------------------------------------------------------------------------

strapar     db          '(', 00h                ; Abrir par‚ntesis.
strcpar     db          ')', 00h                ; Cerrar par‚ntesis.
strpot      db          '^', 00h                ; x elevado y.
strmul      db          '*', 00h                ; Producto.
strdiv      db          '/', 00h                ; Divisi¢n.
stradd      db          '+', 00h                ; Suma.
strsub      db          '-', 00h                ; Resta o cambio de signo.
strabs      db          'ABS', 00h              ; Valor absoluto.
srtsqrt     db          'SQRT', 00h             ; Raiz cuadrada.
strexp      db          'EXP', 00h              ; Exponencial.
strln       db          'LN', 00h               ; Logaritmo neperiano.
strlog      db          'LOG', 00h              ; Logaritmo base 10.
strsinh     db          'SINH', 00h             ; Seno hiperb¢lico.
strcosh     db          'COSH', 00h             ; Coseno hiperb¢lico.
strtanh     db          'TANH', 00h             ; Tangente hiperb¢lica.
strsin      db          'SIN', 00h              ; Seno.
strcos      db          'COS', 00h              ; Coseno.
strtan      db          'TAN', 00h              ; Tangente.
strasin     db          'ASIN', 00h             ; Arcoseno.
stracos     db          'ACOS', 00h             ; Arcocoseno.
stratan     db          'ATAN', 00h             ; Arcotangente.
strfact     db          'FACT', 00h             ; Factorial.
stre        db          'E', 00h                ; N£mero e.
strpi       db          'PI', 00h               ; N£mero pi.
strx        db          'X', 00h                ; N£mero x.

            ; Vector de cadenas identificadoras de operadores y variables.
stropid     dw          OFFSET strapar
            dw          OFFSET strcpar
            dw          OFFSET strpot
            dw          OFFSET strmul
            dw          OFFSET strdiv
            dw          OFFSET stradd
            dw          OFFSET strsub
            dw          OFFSET strabs
            dw          OFFSET srtsqrt
            dw          OFFSET strexp
            dw          OFFSET strln
            dw          OFFSET strlog
            dw          OFFSET strsinh
            dw          OFFSET strcosh
            dw          OFFSET strtanh
            dw          OFFSET strsin
            dw          OFFSET strcos
            dw          OFFSET strtan
            dw          OFFSET strasin
            dw          OFFSET stracos
            dw          OFFSET stratan
            dw          OFFSET strfact
            dw          OFFSET stre
            dw          OFFSET strpi
            dw          OFFSET strx

; ---------------------------------------------------------------------------

.CODE
.386

; ---------------------------------------------------------------------------
;     Pasar una expresi¢n infija en una cadena a una pila
;
;        Entrada:
;
;        handler = Manejador de la pila.
;        ds:expr = Cadena de texto ASCIIZ de la expresi¢n.
;
;        Salida:
;
;        Si cf = 0: No error
;        Si cf = 1: Error de sintaxis
; ---------------------------------------------------------------------------

_convstack  PROC
            ARG         handler:HSTACK, expr:NEAR PTR = ARGLEN
            LOCAL       temp:QWORD, len:WORD = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            and         sp, not 3
            push        eax edx bx cx si di

            ; Pasar la cadena ASCIIZ a may£sculas.
            mov         si, expr                ; ds:si = expresi¢n.
            toupper     si

@cs1:       ; Comprobar si ahora viene un n£mero.
            atonsf      si                      ; st(0) = flotante.
            jc          @cs2                    ; Si error buscar operador.
            fstp        temp
            mov         eax, dword ptr temp
            mov         edx, dword ptr [temp+4] ; edx:eax = valor.
            stpush      handler                 ; Guardar valor en la pila.
            jmp         @cs1                    ; Siguiente n£mero.

@cs2:       ; Comprobar si ahora viene un operador.
            xor         eax, eax                ; Indice lista operadores.
            strlen      si                      ; cx = longitud de expr.
            mov         len, cx                 ; len = longitud de expr.
            mov         cx, NUMOFOP             ; cx = N§ de operadores.
@cs3:
            mov         di, stropid[eax*2]      ; di = puntero operador.
            push        cx
            strlen      di                      ; cx = longitud operador. 
            mov         dx, cx                  ; dx = longitud operador.
            pop         cx
            cmp         dx, len                 ; Garantizar que no se acabe
            ja          @cs4                    ; la cadena expr.
            strcmpn     di, si, dx              ; Saltar si el operador ha
            je          @cs5                    ; sido identificado.
@cs4:
            inc         eax                     ; Repetir para el siguiente
            loop        @cs3                    ; operador.

            ; Comprobar si hemos alcanzado el final de expr.
            cmp         byte ptr[si], 0
            je          @cs9                    ; Si es as¡ salir.
            stc                                 ; Sino indicar el error
            jmp         @csA                    ; de sintaxis y salir.

@cs5:       ; Determinar el tipo de operador y almacenarlo.
            push        dx                      ; Guardar longitud operador.
            xor         edx, edx
            inc         eax
            cmp         eax, FIRSTOPBIN         ; Comprobar si es un
            jb          @cs6                    ; operador binario
            cmp         eax, LASTOPBIN
            ja          @cs6
            or          edx, OPBINID            ; Indicarlo.
@cs6:
            cmp         eax, FIRSTOPUNI         ; Comprobar si es un
            jb          @cs7                    ; operador unitario
            cmp         eax, LASTOPUNI
            ja          @cs7
            or          edx, OPUNIID            ; Indicarlo.
@cs7:
            cmp         eax, FIRTSVAR           ; Comprobar si es una   
            jb          @cs8                    ; variable o constante.
            cmp         eax, LASTVAR
            ja          @cs8
            or          edx, VARID              ; Indicarlo.
@cs8:
            stpush      handler                 ; Guardar operador en pila.
            pop         dx
            add         si, dx                  ; di = siguiente elemento.
            jmp         @cs1                    ; Siguiente elemento.

@cs9:       ; Indicar que no se a producido ning£n error.
            clc                                 ; No error.

@csA:       ; Retornar del procedimiento.
            pop         di si cx bx edx eax
            mov         sp, bp
            pop         bp
            ret         ARGLEN

_convstack  ENDP

; --------------------------------------------------------------------------- 
;     Convertir una expresi¢n infija a notaci¢n polaca inversa
;
;        Entrada:
;
;        ds:expr = Cadena de texto ASCIIZ de la expresi¢n.
;
;        Salida:
;
;        Si cf = 0: No error
;           ax = Manejador de la pila con la expresi¢n en notaci¢n polaca.
;        Si cf = 1: Error durante la conversi¢n
;           ax = C¢digo del error.
; ---------------------------------------------------------------------------

_topolaca   PROC
            ARG         expr:NEAR PTR = ARGLEN
            LOCAL       hposfija:HSTACK, hinfija:HSTACK, \
                        hpila:HSTACK = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            push        00h 00h 00h             ; Manejadores = 00h.
            and         sp, not 3
            push        ecx edx esi

            ; Crear las pilas requeridas durante el proceso.
            mov         si, expr
            strlen      si                      ; cx = longitud de expr.
            inc         cx                      ; cx = cx + 1
            allocFIFO   cx                      ; Crear pila posfija.
            jc          @tpE                    ; ax = Manejador pila.
            mov         hposfija, ax            ; hposfija = Manejador pila.
            allocFIFO   cx                      ; Crear pila infija.
            jc          @tpE                    ; Saltar si error.
            mov         hinfija, ax             ; hinfija = Manejador pila.
            allocLIFO   cx                      ; Crear pila temporal.
            jc          @tpE                    ; Saltar si error.
            mov         hpila, ax               ; hpila = Manejador pila.

            ; Almacenar la expresi¢n infija en la pila correspondiente.
            convstack   hinfija, si
            jc          @tpF                    ; Saltar si error.

            ; Preparar las pilas para la conversi¢n.
            mov         eax, OPAPAR
            mov         edx, OPBINID            
            stpush      hpila                   ; A¤adir par‚ntesis izquierdo.
            mov         eax, OPCPAR
            stpush      hinfija                 ; A¤adir par‚ntesis derecho.

@tp1:       ; Extraer de la pila n£meros.
            stpop       hinfija                 ; edx:eax = elemento.
            mov         ecx, edx                
            not         ecx                     ; Comprobar si edx:eax
            test        ecx, OPID               ; tiene un n£mero.
            jz          @tpA                    ; Saltar si no n£mero.
@tp2:
            stpush      hposfija                ; Guardar n£mero.

@tp3:       ; Sacar operadores unitarios de la pila temporal.
            stpop       hpila                   ; edx:eax = operador.
            test        edx, OPUNIMASK
            jz          @tp4                    ; Saltar si no op. unitario.
            stpush      hposfija                ; Guardar operador.
            jmp         @tp3
@tp4:
            stpush      hpila                   ; Guardar operador.

@tp5:       ; Extraer de la pila operadores binarios.
            stpop       hinfija                 ; edx:eax = elemento.
            jc          @tpC                    ; Salir.
            mov         ecx, edx                
            not         ecx                     ; Comprobar si edx:eax
            test        ecx, OPBINID            ; tiene un operador binario.
            jnz         @tpF                    ; Si no indicar error.

            ; Comprobar si es un par‚ntesis derecho.
            cmp         eax, OPCPAR
            jne         @tp7                    ; Saltar si no par‚ntesis.

@tp6:       ; Sacar operadores de la pila temporal hasta encontrar
            ; un par‚ntesis izquierdo.
            stpop       hpila                   ; edx:eax = operador.
            cmp         eax, OPAPAR
            je          @tp5                    ; Saltar si par‚ntesis izq.
            stpush      hposfija                ; Guardar operador.
            jmp         @tp6

@tp7:       ; Sacar operadores binarios, de igual o mayor prioridad,
            ; de la pila temporal.
            mov         ecx, eax
@tp8:
            stpop       hpila                   ; edx:eax = operador.
            cmp         eax, ecx
            ja          @tp9                    ; Saltar si no m s prioridad
            cmp         eax, OPAPAR
            je          @tp9                    ; Saltar si par‚ntesis izq.
            stpush      hposfija                ; Guardar operador.
            jmp         @tp8

@tp9:
            stpush      hpila                   ; Guardar operador.
            mov         eax, ecx
            mov         edx, OPBINID
            stpush      hpila                   ; Guardar operador.
            jmp         @tp1

@tpA:       ; Comprobar si es una variable o constante.
            test        edx, VARMASK
            jnz         @tp2                    ; Saltar si variable.
            
            ; Comprobar si es un operador unitario.
            test        edx, OPUNIMASK
            jz          @tpB                    ; Saltar si no op. unitario.
            mov         edx, OPUNIID
            stpush      hpila                   ; Guardar operador.
            jmp         @tp1                    ; Siguiente elemento.

@tpB:       ; Comprobar si es un par‚ntesis izquierdo.
            cmp         eax, OPAPAR
            jne         @tpF                    ; Si no indicar error.
            stpush      hpila                   ; Guardar par‚ntesis.
            jmp         @tp1                    ; Siguiente elemento.

@tpC:       ; Devolver el manejador de la pila posfija.
            mov         ax, hposfija
            clc                                 ; No error.

@tpD:       ; Destruir las pilas no necesarias.
            pushf                               ; Guardar flags.
            freestack   hinfija                 ; Liberar infija.
            freestack   hpila                   ; Liberar pila temporal.
            popf                                ; Recuperar flags.
            
            ; Retornar del procedimiento
            pop         esi edx ecx
            mov         sp, bp
            pop         bp
            ret         ARGLEN

@tpE:       ; Errores de memoria insuficiente.
            mov         ax, NOMEM               ; Indicar falta de memoria.
            stc
            jmp         @tpD                    ; Salir.

@tpF:       ; Errores de sintaxis.
            freestack   hposfija                ; Liberar posfija.
            mov         ax, SYNERR              ; Indicar error de sintaxis.
            stc
            jmp         @tpD                    ; Salir

_topolaca   ENDP

; --------------------------------------------------------------------------- 
;     Calcular el resultado de una expresi¢n matem tica
;
;        Entrada:
;
;        handler = Manejador de la pila con la expresi¢n en notaci¢n polaca.
;        st(0) = Valor de la incognita x.
;
;        Salida:
;
;        Si cf = 0: No error
;           st(0) = Valor resultante del c lculo.
;        Si cf = 1: Error durante el c lculo
;           ax = C¢digo del error.
; ---------------------------------------------------------------------------

_calcular   PROC
            ARG         handler:HSTACK = ARGLEN
            LOCAL       xval:QWORD, num:QWORD, hpila:HSTACK = LOCALSIZE

            ; Inicializar el procedimiento.
            push        bp
            mov         bp, sp
            sub         sp, LOCALSIZE
            and         sp, not 3
            push        ecx edx

            ; Extraer de la FPU el valor de x.
            fstp        xval

            ; Crear las pilas requeridas durante el proceso.
            stacksize   handler                 ; ax = tama¤o pila.
            allocLIFO   ax                      ; Crear pila temporal.
            jnc         @cc1                    ; Saltar no si error.
            mov         ax, NOMEM               ; Indicar falta de memoria.
            stc
            jmp         @ccZZ                   ; Salir.
@cc1:
            mov         hpila, ax               ; hpila = Manejador pila.

@cc2:       ; Extraer cada elemento y determinar si es un n£mero.
            stpop       handler                 ; edx:eax = elemento.
            jc          @ccZY                   ; Terminar.
@cc3:
            mov         ecx, edx
            not         ecx                     ; Comprobar si edx:eax tiene
            test        ecx, OPID               ; un n£mero.
            jz          @cc4                    ; Saltar si no n£mero.
            stpush      hpila                   ; Guardar n£mero en pila.
            jmp         @cc2                    ; Siguiente elemento.

@cc4:       ; No es un n£mero. Determinar de que tipo de elemento se trata.
            cmp         edx, OPBINID
            je          @cc5                    ; Saltar si operador binario.
            cmp         edx, OPUNIID
            je          @cc6                    ; Saltar si operador unitario.
            cmp         edx, VARID
            je          @cc7                    ; Saltar si variable.
            freestack   hpila                   ; Liberar pila temporal.
            mov         ax, SYNERR              ; Indicar error de sintaxis.
            stc
            jmp         @ccZZ                   ; Salir.

@cc5:       ; Es un operador binario.
            ; Cargar operandos en la pila de la FPU.
            push        eax                     ; Preservar operador.
            stpop       hpila                   ; edx:eax = operando 2.
            mov         dword ptr num, eax
            mov         dword ptr [num+4], edx
            fld         num                     ; Cargar operando 2.
            stpop       hpila                   ; edx:eax = operando 1.
            mov         dword ptr num, eax
            mov         dword ptr [num+4], edx
            fld         num                     ; Cargar operando 1.
            pop         eax                     ; Recuperar operador.
            fxch                                ; Intercambiar operandos.

            ;Determinar de que operador se trata.
            cmp         eax, OPPOT              ; x elevado y.
            je          @cc8
            cmp         eax, OPMUL              ; Producto.
            je          @cc9
            cmp         eax, OPDIV              ; Divisi¢n.
            je          @ccA
            cmp         eax, OPADD              ; Suma.
            je          @ccD
            cmp         eax, OPSUB              ; Resta.
            je          @ccE
            freestack   hpila                   ; Liberar pila temporal.
            fdrop                               ; Quitar operandos de la
            fdrop                               ; pila de la FPU.
            mov         ax, SYNERR              ; Indicar error de sintaxis.
            stc
            jmp         @ccZZ                   ; Salir.

@cc6:       ; Es un operador unitario.
            ; Cargar operando en la pila de la FPU.
            push        eax                     ; Preservar operador.
            stpop       hpila                   ; edx:eax = operando.
            mov         dword ptr num, eax
            mov         dword ptr [num+4], edx
            fld         num                     ; Cargar operando.
            pop         eax                     ; Recuperar operador.

            ;Determinar de que operador se trata.
            cmp         eax, OPCHS              ; Cambio de signo.
            je          @ccF
            cmp         eax, OPABS              ; Valor absoluto.
            je          @ccG
            cmp         eax, OPSQRT             ; Raiz cuadrada.
            je          @ccH
            cmp         eax, OPEXP              ; Exponencial
            je          @ccI
            cmp         eax, OPLN               ; Logaritmo neperiano.
            je          @ccJ
            cmp         eax, OPLOG              ; Logaritmo base 10.
            je          @ccK
            cmp         eax, OPSINH             ; Seno hiperb¢lico.
            je          @ccL
            cmp         eax, OPCOSH             ; Coseno hiperb¢lico.
            je          @ccM
            cmp         eax, OPTANH             ; Tangente hiperb¢lica.
            je          @ccN
            cmp         eax, OPSIN              ; Seno.
            je          @ccO
            cmp         eax, OPCOS              ; Coseno.
            je          @ccP
            cmp         eax, OPTAN              ; Tangente.
            je          @ccQ
            cmp         eax, OPASIN             ; Arcoseno.
            je          @ccR
            cmp         eax, OPACOS             ; Arcocoseno.
            je          @ccS
            cmp         eax, OPATAN             ; Arcotangente.
            je          @ccT
            cmp         eax, OPFACT             ; Factorial.
            je          @ccV



            freestack   hpila                   ; Liberar pila temporal.
            fdrop                               ; Quitar operando FPU.
            mov         ax, SYNERR              ; Indicar error de sintaxis.
            stc
            jmp         @ccZZ                   ; Salir.

@cc7:       ; Es una variable.
            ;Determinar de que variable se trata.
            cmp         eax, VAREXP             ; N£mero e.
            je          @ccW
            cmp         eax, VARPI              ; N£mero pi.
            je          @ccX
            cmp         eax, VARX               ; Inc¢gnita X.
            je          @ccY
            freestack   hpila                   ; Liberar pila temporal.
            mov         ax, SYNERR              ; Indicar error de sintaxis.
            stc
            jmp         @ccZZ                   ; Salir.

            ; Realizar las acciones correspondientes.
@cc8:       fxpy                                ; x elevado y.
            jmp         @ccZX                   ; Guardar resultado.

@cc9:       fmul                                ; Producto.
            jmp         @ccZX                   ; Guardar resultado.
            
@ccA:       ; Comprobar si el siguiente operador es ATAN
            stpop       handler                 ; edx:eax = elemento.
            jc          @ccC                    ; Saltar si underflow.
            mov         ecx, edx                
            not         ecx                     ; Comprobar si edx:eax tiene
            test        ecx, OPUNIID            ; un operador unitario
            jnz         @ccB                    ; Saltar si no.
            cmp         eax, OPATAN             
            je          @ccR                    ; Saltar si arcotangente.
@ccB:
            fdiv                                ; Divisi¢n.
            fstp        num                     ; num = resultado.
            mov         eax, dword ptr num
            mov         edx, dword ptr [num+4]  ; edx:eax = resultado
            stpush      hpila                   ; Guardar resultado.
            jmp         @cc3                    ; Siguiente elemento.
@ccC:
            fdiv                                ; Divisi¢n.
            freestack   hpila                   ; Liberar pila temporal.
            clc                                 ; No error.
            jmp         @ccZZ                   ; Terminar.

@ccD:       fadd                                ; Suma.
            jmp         @ccZX                   ; Guardar resultado.

@ccE:       fsub                                ; Resta.
            jmp         @ccZX                   ; Guardar resultado.

@ccF:       fchs                                ; Cambio de signo.
            jmp         @ccZX                   ; Guardar resultado.

@ccG:       fabs                                ; Valor absoluto.
            jmp         @ccZX                   ; Guardar resultado.

@ccH:       fsqrt                               ; Raiz cuadrada.
            jmp         @ccZX                   ; Guardar resultado.

@ccI:       fexp                                ; Exponencial.
            jmp         @ccZX                   ; Guardar resultado.

@ccJ:       fln                                 ; Logaritmo neperiano.
            jmp         @ccZX                   ; Guardar resultado.
           
@ccK:       flog10                              ; Logaritmo base 10.
            jmp         @ccZX                   ; Guardar resultado.

@ccL:       fsinh                               ; Seno hiperb¢lico.
            jmp         @ccZX                   ; Guardar resultado.

@ccM:       fcosh                               ; Coseno hiperb¢lico.
            jmp         @ccZX                   ; Guardar resultado.

@ccN:       ftanh                               ; Tangente hiperb¢lico.
            jmp         @ccZX                   ; Guardar resultado.

@ccO:       frsin                               ; Seno.
            jmp         @ccZX                   ; Guardar resultado.

@ccP:       frcos                               ; Coseno.
            jmp         @ccZX                   ; Guardar resultado.

@ccQ:       frtan                               ; Tangente.
            jmp         @ccZX                   ; Guardar resultado.

@ccR:       fasin                               ; Arcoseno.
            jmp         @ccZX                   ; Guardar resultado.

@ccS:       facos                               ; Arcocoseno.
            jmp         @ccZX                   ; Guardar resultado.

@ccT:       fld1                                
@ccU:       fpatan                              ; Arcotangente.
            jmp         @ccZX                   ; Guardar resultado.

@ccV:       ffact                               ; Factorial.
            jmp         @ccZX                   ; Guardar resultado.

@ccW:       flde                                ; N£mero e.
            jmp         @ccZX                   ; Guardar resultado.

@ccX:       fldpi                               ; N£mero pi.
            jmp         @ccZX                   ; Guardar resultado.

@ccY:       mov         eax, dword ptr xval     ; Inc¢gnita X.
            mov         edx, dword ptr [xval+4] ; edx:eax = resultado
            stpush      hpila                   ; Guardar resultado.
            jmp         @cc2                    ; Siguiente elemento.

@ccZX:      ; Sacar resultado de la FPU y cargarlo en la pila temporal.
            fstp        num                     ; num = resultado.
            mov         eax, dword ptr num
            mov         edx, dword ptr [num+4]  ; edx:eax = resultado
            stpush      hpila                   ; Guardar resultado.
            jmp         @cc2                    ; Siguiente elemento.

@ccZY:      ; Cargar resultado en la FPU.
            stpop       hpila                   ; edx:eax = resultado.
            mov         dword ptr num, eax
            mov         dword ptr [num+4], edx
            fld         num                     ; Cargar resultado.
            freestack   hpila                   ; Liberar pila temporal.
            clc                                 ; No error.

@ccZZ:      ; Retornar del procedimiento.
            pop         edx ecx
            mov         sp, bp
            pop         bp
            ret         ARGLEN

_calcular   ENDP

            END
