
# This makefile creates the UASM binary for macOS 64-bit

TARGET1=uasm

ifndef DEBUG
DEBUG=0
endif

inc_dirs  = -IH

#cflags stuff

ifeq ($(DEBUG),0)
extra_c_flags = -DNDEBUG -O3 -Wno-parentheses -Wno-pointer-sign -Wno-switch -Wno-comment -Wno-unsequenced -Wno-enum-conversion -Wno-incompatible-pointer-types
#-funsigned-char -fwritable-strings
OUTD=GccUnixR
else
extra_c_flags = -DDEBUG_OUT -g
OUTD=GccUnixD
endif

c_flags = -D __UNIX__ $(extra_c_flags)

.SUFFIXES:
.SUFFIXES: .c .o

include gccmod.inc

#.c.o:
#	$(CC) -c $(inc_dirs) $(c_flags) -o $(OUTD)/$*.o $<
$(OUTD)/%.o: %.c
	$(CC) -c $(inc_dirs) $(c_flags) -o $(OUTD)/$*.o $<

all:  $(OUTD) $(OUTD)/$(TARGET1)

$(OUTD):
	mkdir $(OUTD)

$(OUTD)/$(TARGET1) : $(OUTD)/main.o $(proj_obj)
ifeq ($(DEBUG),0)
	$(CC) -D __UNIX__ $(OUTD)/main.o $(proj_obj) -o $@ -Wl,-S,-dead_strip,-dead_strip_dylibs
	strip -x $@
else
	$(CC) -D __UNIX__ $(OUTD)/main.o $(proj_obj) -o $@ -Wl
endif

$(OUTD)/msgtext.o: msgtext.c H/msgdef.h
	$(CC) -c $(inc_dirs) $(c_flags) -o $*.o msgtext.c

$(OUTD)/reswords.o: reswords.c H/instruct.h H/special.h H/directve.h H/opndcls.h H/instravx.h
	$(CC) -c $(inc_dirs) $(c_flags) -o $*.o reswords.c

######

clean:
	rm -f $(OUTD)/$(TARGET1)
	rm -f $(OUTD)/*.o
	rm -f $(OUTD)/*.map

