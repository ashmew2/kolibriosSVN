/* Copyright (C) 1995 DJ Delorie, see COPYING.DJ for details */
#include<libc/asm.h>
MK_C_SYM(unlink)
	jmp	C_SYM(remove)

