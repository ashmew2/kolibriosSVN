CC = kos32-gcc
LD = kos32-ld 

SDK_DIR:= $(abspath ../../..)

LDFLAGS = -static -S -nostdlib -T $(SDK_DIR)/sources/newlib/app.lds -Map txview.map --image-base 0

CFLAGS = -c -fno-ident -O2 -fomit-frame-pointer -U__WIN32__ -U_Win32 -U_WIN32 -U__MINGW32__ -UWIN32

INCLUDES= -I $(SDK_DIR)/sources/newlib/libc/include -I $(SDK_DIR)/sources/freetype/include
LIBPATH:= -L $(SDK_DIR)/lib -L /home/autobuild/tools/win32/mingw32/lib

SOURCES = main.c	\
	  fontlib.c     \
	  tview.c
 

OBJECTS =  $(patsubst %.c, %.o, $(SOURCES))


default: txview

txview: $(OBJECTS) Makefile
	$(LD) $(LDFLAGS) $(LIBPATH) -o txview $(OBJECTS) -lfreetype.dll -lpixlib.dll -lgcc -lc.dll -lapp
	objcopy txview -O binary


%.o : %.c Makefile $(SOURCES)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $<
