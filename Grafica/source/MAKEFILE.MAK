.autodepend

ASM = TASM
LINK = TLINK
OBJDIR = .\obj
BINDIR = ..\bin

.asm.obj:
  $(ASM) $<, $(OBJDIR)\$&.obj

grafica.exe: system.obj string.obj stack.obj graph.obj math.obj \
             calc.obj input.obj main.obj

  @cd $(OBJDIR)
  $(LINK) /x /3 $?, ..\$(BINDIR)\grafica.exe

