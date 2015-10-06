.autodepend

ASM = TASM
LINK = TLINK
OBJDIR = .\obj
BINDIR = ..\bin

.asm.obj:
  $(ASM) $<, $(OBJDIR)

grafica.exe: system.obj string.obj stack.obj graph.obj math.obj \
             calc.obj input.obj main.obj

  $(LINK) /j$(OBJDIR) /x /3 $?, $(BINDIR)\grafica.exe

