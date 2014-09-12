;freebsd = 1 ;uncomment for FreeBSD-specific changes

	format ELF64
	public _start
.data? fix section ".bss" writeable align 4
.data  fix section ".data" writeable align 4
.const fix section ".const" align 4
.code  fix section ".text" executable align 16
offset fix
ptr fix
struc label type {
  label . type }

extrn lzma_compress
extrn lzma_set_dict_size

.data?
infilename	dq	?
outfilename	dq	?
infile		dq	?
outfile		dq	?
inptr		dq	?
workmem		dq	?
insize		dd	?
outsize		dd	?
lzma_dictsize	dd	?
indelta		dd	?
strucstat	rq	18

if defined freebsd
st_atime_offset = 24
st_mtime_offset = 40
st_birthtime_offset = 104
st_size_offset = 72
else
st_atime_offset = 72
st_mtime_offset = 88
;st_birthtime_offset not defined
st_size_offset = 48
end if

public environ
environ		dq	?
public __progname
__progname	dq	?
ct1		db	256 dup (?)
ctn		dd	?
cti		db	?

.const
usage_str	db	'Written by diamond in 2006, 2007 specially for KolibriOS',13,10
		db	'LZMA compression library is copyright (c) 1999-2005 by Igor Pavlov',13,10
		db	13,10
		db	'Usage: kerpack <infile> [<outfile>]',13,10
usage_len	=	$ - offset usage_str
errload_str	db	'Cannot load input file',13,10
errload_len	=	$ - offset errload_str
outfileerr_str	db	'Cannot save output file',13,10
outfileerr_len	=	$ - offset outfileerr_str
nomem_str	db	'No memory',13,10
nomem_len	=	$ - offset nomem_str
too_big_str	db	'failed, output is greater than input.',13,10
too_big_len	=	$ - too_big_str
compressing_str	db	'Compressing ... '
compressing_len = $ - compressing_str

.data
done_str	db	'OK! Compression ratio: '
ratio		dw	'00'
		db	'%',13,10,13,10
done_len	=	$ - done_str

use_lzma	=	1

use_no_calltrick =	0
use_calltrick1	=	40h
use_calltrick2	=	80h

method			db	1

.code
; Write string from [rsi] of rdx bytes.
write_string:
; 1. Align stack on 16 bytes.
	push	rdi
; 2. Set rdi to 1 = descriptor for stdout.
	xor	edi, edi
	inc	edi
; 3. Do system call.
	call	write
; 4. Restore stack and return.
	pop	rdi
	ret

; Write string from [rsi] of rdx bytes and exit. Note that main code jumps (not calls) here,
; so we should not align the stack.
write_exit:
; 1. Call prev func.
	call	write_string
; 2. Do system call for exit.
; Note that this can be used as independent proc jumped (not called) to.
doexit:
	xor	edi, edi
	inc	edi
	call	exit

; Main procedure.
_start:
; 1. Parse command line.
; Linux: [rsp] = argc, rsp+8 = argv
; FreeBSD: [rdi] = argc, rdi+8 = argv
; 1a. Load argc and argv to registers,
; skip first argument (which is always program name)
if defined freebsd
	mov	ecx, [rdi]	; ecx = argc
	add	rdi, 16		; rdi = &argv[1]
else
	mov	ecx, [rsp]	; ecx = argc
	lea	rdi, [rsp+16]	; rdi = &argv[1]
end if
; 1b. Test for first filename parameter. If no, goto step 2.
	call	get_file_name
	jz	usage
; 1c. We got input file name, save it.
; Assume that output file name is the same; if no, we will rewrite it in step 1d.
	mov	[infilename], rax
	mov	[outfilename], rax
; 1d. Test for second filename parameter. If yes, rewrite assumption in step 1c and check that there are no 3rd parameter.
	call	get_file_name
	jz	@f
	mov	[outfilename], rax
	call	get_file_name
	jnz	usage
@@:
; 1e. Parsing is done, process to step 3.
	jmp	short cont
; 2. No arguments or too many arguments given; write message and exit.
usage:
	push	usage_len
	pop	rdx
	mov	rsi, offset usage_str
	jmp	write_exit
cont:
; 4. Load the input file.
; 4a. Do system call for stat - get file times and file size.
	mov	rdi, [infilename]
	mov	rsi, offset strucstat
	mov	r13, rsi
	call	stat
; 4b. Test result; if not 0 (0 is OK), goto 4e.
	test	rax, rax
	jnz	short infileerr
; 4c. Do system call for open.
	mov	rdi, [infilename]
	mov	rsi, offset open_mode
	call	fopen
; 4d. Test result; if not NULL, goto 4f.
	test	rax, rax
	jnz	short inopened
infileerr:
; 4e. Say error and abort.
	push	errload_len
	pop	rdx
	mov	rsi, offset errload_str
	jmp	write_exit
inopened:
	mov	r12, rax
; 4f. Check that the size is nonzero and less than 4G.
	mov	edi, [r13+st_size_offset]
	test	edi, edi
	jz	short infileerr
	cmp	dword [r13+st_size_offset+4], 0
	jnz	short infileerr
; 4g. Allocate memory for the input file.
	mov	[insize], edi
	call	malloc
	test	rax, rax
	jz	nomem
	mov	[infile], rax
; 4g. Read the input file to the allocated memory.
	mov	rdi, rax
	push	1
	pop	rsi
	mov	edx, [r13+st_size_offset]
	mov	rcx, r12
	call	fread
; 4h. Test result; must be equal to file size.
	cmp	eax, [r13+st_size_offset]
	jnz	infileerr
; 4i. Close the input file.
	mov	rdi, r12
	call	fclose
; 5. Calculate maximum size of the output.
	mov	edi, [insize]
	shr	edi, 3
	add	edi, [insize]
	add	edi, 400h	; should be enough for header
	mov	r12d, edi
; 6. Allocate memory for two copies of maximum output.
; 6a. Do system call.
	call	malloc
; 6b. Test return value. If ok, goto 6d.
	test	rax, rax
	jnz	short outmemok
; 6c. No memory; say error and exit.
nomem:
	push	nomem_len
	pop	rdx
	mov	rsi, offset nomem_str
	jmp	write_exit
; 6d. Remember allocated memory address.
outmemok:
	mov	[outfile], rax
; 8. Determine and set lzma_dict_size.
	push	18h
	pop	rdi
	call	lzma_set_dict_size
; 9. Allocate lzma_workmem.
	mov	edi, (1 shl 18h) * 19 / 2 + 509000h
	call	malloc
	test	rax, rax
	jz	nomem
	mov	[workmem], rax
; 10. Say another 'hi'.
	push	compressing_len
	pop	rdx
	mov	rsi, offset compressing_str
	call	write_string
; 11. Do work.
; find jump to 32-bit code
	mov	rdi, [infile]
	dec	rdi
@@:
	inc	rdi
	cmp	dword [rdi], 0E88EE08Eh		; mov fs,ax/mov gs,ax
	jnz	@b
	cmp	dword [rdi+4], 00BCD08Eh	; mov ss,ax/mov esp,00xxxxxx
	jnz	@b
	add	rdi, 11
	mov	[inptr], rdi
	sub	rdi, [infile]
	mov	[indelta], edi
	mov	eax, [insize]
	mov	ebx, eax
	add	eax, 0x10000
	mov	[loader_base+..loader_patch3+2], eax
	sub	ebx, edi
	mov	[insize], ebx
	call	preprocess_calltrick2
	mov	al, [cti]
	mov	[loader_base+loader_patch5-1], al
	mov	eax, [ctn]
	mov	[loader_base+loader_patch4+1], eax
	mov	esi, [indelta]
	add	rsi, [outfile]
	add	rsi, loader_size - 5
	mov	rdi, [inptr]
	mov	edx, [insize]
	mov	rcx, [workmem]
	call	lzma_compress
	mov	edx, [indelta]
	add	eax, loader_size-5
	mov	[loader_base+loader_patch1+6], eax
	add	eax, edx
	mov	[outsize], eax
	mov	eax, edx
	add	rax, [outfile]
	mov	ecx, [rax + loader_size - 4]
	bswap	ecx
	mov	[loader_base+loader_patch2+4], ecx
	add	edx, 0x10000
	mov	[loader_base+loader_patch1+1], edx
	mov	rsi, [infile]
	mov	rdi, [outfile]
	mov	ecx, [indelta]
	rep	movsb
	mov	rsi, loader_base
	mov	ecx, loader_size
	rep	movsb
	mov     eax, [outsize]
	cmp     eax, [insize]
	jb      short packed_ok
	push	too_big_len
	pop	rdx
	mov	rsi, offset too_big_str
	jmp	write_exit
packed_ok:
; 12. Main work is done. Free lzma_workmem.
	mov	rdi, [workmem]
	call	free
; 13. Set header
	mov     eax, [outsize]
	mov	ecx, 100
	mul	ecx
	div	[insize]
	mov	cl, 10
	div	cl
	add	ax, '00'
	mov	[ratio], ax
	push	done_len
	pop	rdx
	mov	rsi, offset done_str
	call	write_string
; 14. Save the output file.
; 14a. Do system call for open.
	mov	rdi, [outfilename]
	mov	rsi, create_mode
	call	fopen
; 14b. Test for success; if yes, goto 14d.
	test	rax, rax
	jnz	short @f
; 14c. Say error and exit.
outerr:
	push	outfileerr_len
	pop	rdx
	mov	rsi, offset outfileerr_str
	jmp	write_exit
; 14d. Do system call for write.
@@:
	mov	r12, rax
	mov	rdi, [outfile]
	mov	esi, [outsize]
	push	1
	pop	rdx
	mov	rcx, r12
	call	fwrite
	test	eax, eax
	jz	short outerr
; 14e. Close output file.
	mov	rdi, r12
	call	fclose
; 15. Exit.
	xor	edi, edi
	call	exit

; Scan command line, skipping possible options, and return first non-option
; ecx is number of arguments left, rdi points to first new argument (updated by func)
; After the call: ZF set if no arguments left, otherwise rax points to the arg.
get_file_name:
; 1. Test whether there are still arguments. If no, goto 5; note ZF is set.
	dec	ecx
	jz	@@end
; 2. Get the new arg, advance rdi (ecx was decreased in step 1).
	mov	rax, [rdi]
	add	rdi, 8
; 5. No arguments (ZF set) or normal argument (ZF cleared); return.
@@end:
	ret

pack_calltrick_fail:
	xor	eax, eax
	xor	ebx, ebx
	mov	[ctn], eax
	ret

preprocess_calltrick2:
; restore input
	mov	rsi, [infile]
; input preprocessing
	push	rax
	mov	edi, [insize]
	add	edi, edi
	call	malloc
	pop	rcx
	test	rax, rax
	jz	pack_calltrick_fail
	mov	rdi, offset ct1
	xchg	rax, rbx
	xor	eax, eax
	push	rdi
	mov	ecx, 256/4
	rep	stosd
	pop	rdi
	mov	ecx, [insize]
	mov	rsi, [inptr]
	xchg	eax, edx
	push	rbx
input_pre2:
	lodsb
@@:
	cmp	al, 0Fh
	jnz	short ip1
	dec	ecx
	jz	short input_pre_done2
	lodsb
	cmp	al, 80h
	jb	short @b
	cmp	al, 90h
	jb	short @f
ip1:
	sub	al, 0E8h
	cmp	al, 1
	ja	short input_pre_cont2
@@:
	cmp	ecx, 5
	jb	short input_pre_done2
	lodsd
	add	eax, esi
	sub	eax, dword ptr [inptr]
	cmp	eax, [insize]
	jae	short xxx2
	cmp	eax, 1000000h
	jae	short xxx2
	sub	ecx, 4
	bswap	eax
	mov	[rsi-4], eax
	inc	edx
	mov	[rbx], rsi
	add	rbx, 8
	jmp	short input_pre_cont2
xxx2:	sub	rsi, 4
	movzx	eax, byte ptr [rsi]
	mov	byte ptr [rax+rdi], 1
input_pre_cont2:
	loop	input_pre2
input_pre_done2:
	mov	[ctn], edx
	pop	rdx
	xor	eax, eax
	mov	ecx, 256
	repnz	scasb
	jnz	pack_calltrick_fail
	not	cl
	mov	[cti], cl
@@:
	cmp	rbx, rdx
	jz	@f
	sub	rbx, 8
	mov	rax, [rbx]
	mov	[rax-4], cl
	jmp	@b
@@:
	push	rax
	mov	rdi, rbx
	call	free
	pop	rax
	ret

extrn exit
extrn fopen
extrn fread
extrn fwrite
extrn fclose
extrn fseek
extrn ftell
extrn malloc
extrn free
extrn write
extrn utimes
extrn stat

open_mode	db	"rb",0
create_mode	db	"wb",0

.data

loader_base:
use32
org 0
include 'loader_lzma.asm'
