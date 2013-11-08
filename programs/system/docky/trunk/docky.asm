    use32
    org     0x0
;-------------------------------------------------------------------------------
    db	    "MENUET01"
    dd	    1, main, __dataend, __memend, __stackend, 0, sys_path
;-------------------------------------------------------------------------------
    include "../../../macros.inc"
    include "../../../proc32.inc"
    include "../../../dll.inc"
    include "../../../develop/libraries/box_lib/load_lib.mac"
    ;include "../../../debug.inc"

    include "DATA.INC"
    include "NAME.INC"

    @use_library_mem	 \
	    mem.Alloc,	 \
	    mem.Free,	 \
	    mem.ReAlloc, \
	    dll.Load
;================================================================================
main:
; ==== Init ====
    mcall   18, 7
    mov     [win.psid], eax

    mcall   40, 100101b

; ==== Load libs ====
    load_libraries load_lib_start, load_lib_end

; ==== Config LibINI ====
    invoke  ini.get_int, ini_data.file_name, ini_data.settings_name, ini_data.location_name, 1
    mov     [dock_items.location], eax

    invoke  ini.sections, ini_data.file_name, sections_callback

; ==== Load colors ====
    mcall   48, 3, color
    or	    dword[color.bg],	0x10000000
    or	    dword[color.frame], 0x10000000
    or	    dword[color.text],	0x80000000

; ==== Config LibIMG ====
    mov     dword[fi.p00], 5
    mov     dword[fi.p16], buf_128
    mov     dword[fi.p21], img_data.file_name

    mcall   70, fi

    mov     edx, [buf_128 + 32]
    imul    edx, 10

    stdcall mem.Alloc, edx
    mov     [img_data.rgb_object], eax

    mov     dword[fi.p00], 0
    mov     dword[fi.p12], edx
    m2m     dword[fi.p16], dword[img_data.rgb_object]
    mov     dword[fi.p21], img_data.file_name

    mcall   70, fi

    cmp     ebx, 0xFFFFFFFF
    je	    @f

    stdcall dword[img.decode], dword[img_data.rgb_object], ebx, 0
    mov     dword[img_data.object], eax

  ; === ALPHA ===
    mov     edi, eax
    add     edi, 8
    mov     edi, [edi]
    imul    edi, 128
    sub     edi, 4

    add     eax, 24
    mov     eax, [eax]
 .setalpha:
    mov     ebx, [eax + edi]
    shr     ebx, 24
    cmp     ebx, 0
    jne     .nonalpha

    mov     ecx, [color.bg]
    mov     [eax + edi], ecx
 .nonalpha:
    sub     edi, 4
    cmp     edi, 0
    jne     .setalpha

  ; === CONVERTING TO BGR
    stdcall dword[img.toRGB], dword[img_data.object], dword[img_data.rgb_object]
    stdcall dword[img.destroy], dword[img_data.object]

; ==== Config window ====
    mov     eax, dword[dock_items.location]
    and     eax, 1b
    cmp     eax, 0
    je	    .vert
    jmp     .setshape

 .vert:
    mov     byte[win.isvert], 1

 .setshape:
    cmp     byte[win.isvert], 1
    je	    .vert_sp

 .horz_sp:
    call    .HORZ_WIDTH
    call    .HORZ_X
    call    .HORZ_HEIGHT
    cmp     dword[dock_items.location], 1
    je	    .settop

 .setbottom:
    call    .HORZ_Y_BOTTOM
    jmp     .SETDEF

 .settop:
    call    .HORZ_Y_TOP
    jmp     .SETDEF


 .vert_sp:
    call    .VERT_WIDTH
    call    .VERT_HEIGHT
    call    .VERT_Y
    cmp     dword[dock_items.location], 2
    je	    .setleft

 .setright:
    call    .VERT_X_RIGHT
    jmp     .SETDEF

 .setleft:
    call    .VERT_X_LEFT
    jmp     .SETDEF

;-------------------------------------------------------------------------------
 .HORZ_WIDTH:
    mov     eax, BUTTON_SIZE
    mov     ebx, [dock_items.count]
    imul    eax, ebx
    add     eax, 24
    dec     eax
    mov     [win.width_opn], eax
    mov     [win.width_hdn], eax

    ret

;-------------------------------------------------------------------------------
 .HORZ_X:
    mcall   14
    shr     eax, 17
    mov     ecx, [win.width_opn]
    shr     ecx, 1
    sub     eax, ecx
    mov     [win.x_opn], eax
    mov     [win.x_hdn], eax

    ret

;-------------------------------------------------------------------------------
 .HORZ_HEIGHT:
    mov     dword[win.height_hdn], 3
    mov     dword[win.height_opn], BUTTON_SIZE

    ret

;-------------------------------------------------------------------------------
 .HORZ_Y_BOTTOM:
    mcall   14
    and     eax, 0xFFFF
    dec     eax
    mov     [win.y_hdn], eax
    sub     eax, 43
    mov     [win.y_opn], eax

    ret

 .HORZ_Y_TOP:
    mov     dword[win.y_opn], 0
    mov     dword[win.y_hdn], 0

    ret

;-------------------------------------------------------------------------------
 .VERT_WIDTH:
    mov     dword[win.width_opn], BUTTON_SIZE
    mov     dword[win.width_hdn], 3

    ret

;-------------------------------------------------------------------------------
 .VERT_X_LEFT:
    mov     dword[win.x_opn], 0
    mov     dword[win.x_hdn], 0

    ret

 .VERT_X_RIGHT:
    mcall   14
    and     eax, 0xFFFF0000
    shr     eax, 16
    mov     [win.x_hdn], eax
    sub     eax, BUTTON_SIZE
    mov     [win.x_opn], eax

    ret

;-------------------------------------------------------------------------------
 .VERT_HEIGHT:
    mov     eax, BUTTON_SIZE
    mov     ebx, [dock_items.count]
    imul    eax, ebx
    dec     eax
    add     eax, 12
    mov     [win.height_opn], eax
    mov     [win.height_hdn], eax

    ret

;-------------------------------------------------------------------------------
 .VERT_Y:
    mcall   14
    and     eax, 0xFFFF
    shr     eax, 1

    mov     esi, [win.height_opn]
    shr     esi, 1
    sub     eax, esi

    mov     [win.y_hdn], eax
    mov     [win.y_opn], eax

    ret

;-------------------------------------------------------------------------------
 .SETDEF:
    mov     eax, [win.width_hdn]
    mov     [win.width], eax

    mov     eax, [win.x_hdn]
    mov     [win.x], eax

    mov     eax, [win.height_hdn]
    mov     [win.height], eax

    mov     eax, [win.y_hdn]
    mov     [win.y], eax

;-------------------------------------------------------------------------------
; ==== START ====
    mcall   9, win.procinfo, -1
    mov     ecx, [win.procinfo + 30]
    mcall   18, 21
    and     eax, 0xFFFF
    mov     [win.sid], eax

    call    main_loop
;-------------------------------------------------------------------------------
exit:
    stdcall mem.Free, [img_data.rgb_object]
    mcall   18, 2, [nwin.sid]
    mcall   -1
;-------------------------------------------------------------------------------
main_loop:
    mcall   10

    cmp     eax, EV_REDRAW
    je	    event_redraw

    cmp     eax, EV_BUTTON
    je	    event_button

    cmp     eax, EV_MOUSE
    je	    event_mouse

    jmp     main_loop
;-------------------------------------------------------------------------------
event_redraw:
    mcall   12, 1

    mov     esi, [color.bg]
    or	    esi, 0x01000000
    mcall   0, <[win.x], [win.width]>, <[win.y], [win.height]>, [color.bg], , [color.frame]

    mov     edi, 0
  @@:
    cmp     edi, [dock_items.count]
    je	    @f

    push    edi
    mov     eax, 8
    mov     edx, 0x60000002
    mov     esi, [color.bg]
    imul    edi, BUTTON_SIZE
    add     edi, 12
    shl     edi, 16
    add     edi, BUTTON_SIZE
    cmp     byte[win.isvert], 1
    je	    .vert_btn
    mcall   , edi, <0, BUTTON_SIZE>
    jmp     .endbtn
 .vert_btn:
    sub     edi, 12 shl 16
    mcall   , <0, BUTTON_SIZE>, edi
 .endbtn:
    pop     edi

    cmp     byte[dock_items.separator + edi], 1
    jne     .end_separator

 .draw_separator:
    push    ebx
    push    ecx

    mov     eax, 13
    mov     ebx, edi
    imul    ebx, BUTTON_SIZE
    add     ebx, BUTTON_SIZE
    add     ebx, 12
    dec     ebx
    shl     ebx, 16
    add     ebx, 1

    cmp     byte[win.isvert], 1
    je	    .vert_draw_sep
    mcall   , , <4, 36>, [color.frame]
    jmp     .end_inner_sep
 .vert_draw_sep:
    sub     ebx, 12 shl 16
    mov     ecx, ebx
    mcall   , <4, 36>, , [color.frame]
 .end_inner_sep:
    pop     ecx
    pop     ebx
 .end_separator:

    cmp     byte[win.isvert], 1
    je	    .vert_dig
    mov     edx, ebx
    and     edx, 0xFFFF0000
    add     edx, 0x00060006
    jmp     .digend
 .vert_dig:
    mov     edx, ecx
    and     edx, 0xFFFF0000
    shr     edx, 16
    add     edx, 0x00060006
 .digend:

    imul    ebx, edi, 4
    add     ebx, dock_items.icon
    mov     ebx, [ebx]
    imul    ebx, ICON_SIZE_BGR
    add     ebx, [img_data.rgb_object]

    mcall   7, , <32, 32>

    inc     edi
    jmp     @b
  @@:

 ; ==== DRAW SETTINGS ====
    cmp     byte[win.isvert], 1
    je	    .cfg_vert

    mov     ebx, [win.width]
    sub     ebx, 10
    shl     ebx, 16
    add     ebx, 8
    mcall   8, , <2, BUTTON_SIZE - 4>, 0x60000003
    jmp     @f

 .cfg_vert:
    mov     ecx, [win.height]
    sub     ecx, 10
    shl     ecx, 16
    add     ecx, 8
    mcall   8, <2, BUTTON_SIZE - 4>, , 0x60000003
  @@:

 ; ==== cfg image ====
    mov     edi, 0
  @@:
    cmp     byte[set_img + edi], 0
    je	    .notdraw

    mov     eax, edi
    mov     edx, 0
    mov     ebx, 6
    div     ebx
    mov     ebx, edx
    mov     ecx, eax

    add     ebx, [win.width]
    cmp     byte[win.isvert], 0
    je	    .cfg_hoz
    sub     ebx, [win.width]
    add     ebx, [win.height]
 .cfg_hoz:
    sub     ebx, 10
    add     ecx, 18

    cmp     byte[win.isvert], 0
    je	    .cfg_draw

    xchg    ebx, ecx

  .cfg_draw:
    mcall   1, , , [color.frame]

 .notdraw:
    inc     edi
    cmp     edi, 36
    jne     @b

    mcall   12, 2

    jmp     main_loop
;-------------------------------------------------------------------------------
event_button:
    mcall   17

    cmp     ah, 1
    je	    .button_close

    cmp     ah, 2
    je	    .button_dock

    cmp     ah, 3
    je	    .button_cfg

    jmp     @f

 .button_close:
    jmp     exit

 .button_dock:
    mov     edi, [win.button_index]
    imul    edi, 256

    mov     dword[fi.p00], 7

    mov     esi, edi
    add     esi, dock_items.path
    mov     dword[fi.p21], esi

    mov     esi, edi
    add     esi, dock_items.param
    mov     dword[fi.p08], esi

    mcall   70, fi

    mov     ecx, eax
    mcall   18, 21
    and     eax, 0xFFFF
    mov     [win.psid], eax

    jmp     wnd_hide

 .button_cfg:
    mov     dword[fi.p00], 7
    mov     dword[fi.p21], cfg_app
    mcall   70, fi

    mov     ecx, eax
    mcall   18, 21
    and     eax, 0xFFFF
    mov     [win.psid], eax

    jmp     wnd_hide

  @@:
    jmp     main_loop
;-------------------------------------------------------------------------------
event_mouse:
    mcall   37, 1
    mov     edi, eax
    mov     esi, eax
    shr     edi, 16
    and     esi, 0xFFFF

    cmp     edi, 0
    jl	    wnd_hide
    dec     edi
    cmp     edi, [win.width]
    jg	    wnd_hide
    cmp     esi, 0
    jl	    wnd_hide
    dec     esi
    cmp     esi, [win.height]
    jg	    wnd_hide

    mov     eax, [dock_items.location]
    and     eax, 1b
    cmp     eax, 1
    jne     .vert
    mov     eax, edi
    jmp     .nxt

 .vert:
    mov     eax, esi
    add     eax, 12

 .nxt:
    sub     eax, 12
    mov     edx, 0
    mov     ebx, BUTTON_SIZE
    div     ebx

    cmp     eax, [dock_items.count]
    jge     .set0
    jmp     .nxtcmp

 .set0:
    mov     eax, 100

 .nxtcmp:
    cmp     [win.button_index], eax
    je	    .nxt2

    mov     [win.button_index], eax

 .nxt2:
    mov     eax, [win.button_index]
    imul    eax, BUTTON_SIZE
    cmp     byte[win.isvert], 1
    je	    .vert_name
    add     eax, [win.x]
    mov     [nwin.x], eax
    mov     byte[nwin.change_shape], 1
    mcall   13, <0, [win.width]>, <[win.height], 1>, [color.frame]
    jmp     .vert_end
 .vert_name:
    add     eax, [win.y]
    add     eax, 14
    mov     [nwin.y], eax
    mov     byte[nwin.change_shape], 1
    mcall   13, <[win.width], 1>, <0, [win.height]>, [color.frame]
 .vert_end:

    cmp     byte[win.state], 1
    je	    main_loop

    mov     edx, esp
    add     edx, 512
    mcall   51, 1, n_main

    mov     eax, 18

    mcall   , 7
    mov     [win.psid], eax

    mcall   18, 3, [win.sid]

    mov     byte[win.state], 1

    mov     eax, [win.width_opn]
    mov     [win.width], eax

    mov     eax, [win.x_opn]
    mov     [win.x], eax

    mov     eax, [win.height_opn]
    mov     [win.height], eax

    mov     eax, [win.y_opn]
    mov     [win.y], eax

    mcall   67, [win.x], [win.y], [win.width], [win.height]

    jmp     event_redraw

;-------------------------------------------------------------------------------
wnd_hide:
    cmp     byte[win.state], 0
    je	    main_loop

    mov     byte[nwin.close], 1

    mcall   18, 3, [win.psid]

    mov     byte[win.state], 0
    mov     byte[win.button_index], -1

    mov     eax, [win.width_hdn]
    mov     [win.width], eax

    mov     eax, [win.x_hdn]
    mov     [win.x], eax

    mov     eax, [win.height_hdn]
    mov     [win.height], eax

    mov     eax, [win.y_hdn]
    mov     [win.y], eax

    mcall   67, [win.x], [win.y], [win.width], [win.height]

    jmp     event_redraw
;-------------------------------------------------------------------------------
proc sections_callback, _file_name, _section_name
    mov     eax, [_section_name]
    cmp     byte[eax], '@'
    jne     @f

    dec     dword[dock_items.count]
    jmp     .endproc

  @@:
    ; ==== GET NAME ====
    mov     ebx, [dock_items.count]
    imul    ebx, 16
    add     ebx, dock_items.name

    mov     eax, [_section_name]

    mov     edi, 0
  @@:
    mov     cl, byte[eax]
    mov     byte[ebx + edi], cl

    inc     eax
    inc     edi
    cmp     edi, 10
    jne     @b

  ; ==== GET PATH ====
    mov     ebx, [dock_items.count]
    imul    ebx, 256
    add     ebx, dock_items.path

    invoke  ini.get_str, [_file_name], [_section_name], ini_data.path_name, ebx, 256, 0

  ; === GET  PARAM ===
    mov     ebx, [dock_items.count]
    imul    ebx, 256
    add     ebx, dock_items.param

    invoke  ini.get_str, [_file_name], [_section_name], ini_data.param_name, ebx, 256, 0

  ; ==== GET ICON ====
    invoke  ini.get_int, [_file_name], [_section_name], ini_data.icon_name, 0

    mov     ebx, [dock_items.count]
    imul    ebx, 4
    mov     [dock_items.icon + ebx], eax

  ; ==== GET SEPARATOR ====
    invoke  ini.get_int, [_file_name], [_section_name], ini_data.separator_name, 0

    mov     ebx, [dock_items.count]
    mov     byte[dock_items.separator + ebx], al

  ; ====== END =======
 .endproc:
    mov     eax, 1
    inc     dword[dock_items.count]
    ret
endp
;-------------------------------------------------------------------------------
    include "MEMORY.INC"