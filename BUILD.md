# Instalado Turbo Assembler (TASM)

## Paso 1

Pirmero instala dosbox, el emulador de DOS:

    $ sudo apt-get install dosbox

## Paso 2

Descarga el paquete de Turbo Assempler (TASM) de
[aquí](http://www.phatcode.net/downloads.php?id=280&action=get&file=tasm5.zip).
Crear el directorio TASMINST en directorio del proyecto y descomprime allí el
contenido de los directorios DISK1, DISK2 y DISK3 del archivo comprimido.

## Paso 3

En la carpeta del proyecto, ejecuta dosbox:

    $ dosbox

Si el teclado no está en español:

    > keyb es

Monta la carpeta del proyecto en la unidad virtual C:

    > mount c .

Cambia al directorio del instalador y comienza la instalación:

    > C:
    > cd TASMINST
    > INSTALL

Cuando solicite la unidad fuente a utilizar, indica que es la C.

    Enter the SOURCE drive to use:  C

Entonces preguntará por la ruta a la fuente, que es \TASMINST. Continua con
la instalación con normalidad.

Al terminar, configura el PATH hacia TASM:

    > set PATH=%PATH%;C:\TASM\BIN

# Paso 4

Cambia al directorio del código fuente y compila:

    > cd GRAFICA\SOURCE
    > make

Si todo ha ido bien, el binario estará disponible en C:\GRAFICA\BIN

-- Jesús Torres <jmtorres@ull.es>
