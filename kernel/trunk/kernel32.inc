;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                              ;;
;; Copyright (C) KolibriOS team 2004-2015. All rights reserved. ;;
;; Distributed under terms of the GNU General Public License    ;;
;;                                                              ;;
;; KERNEL32.INC                                                 ;;
;;                                                              ;;
;; Included 32 bit kernel files for MenuetOS                    ;;
;;                                                              ;;
;; This file is kept separate as it will be easier to           ;;
;; maintain and compile with an automated SETUP program         ;;
;; in the future.                                               ;;
;;                                                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

$Revision$

struct  POINT
        x       dd ?
        y       dd ?
ends

struct  RECT
        left    dd ?
        top     dd ?
        right   dd ?
        bottom  dd ?
ends

struct  BOX
        left    dd ?
        top     dd ?
        width   dd ?
        height  dd ?
ends

struct  DISPMODE
        width   dw ?
        height  dw ?
        bpp     dw ?
        freq    dw ?
ends

; constants definition
WSTATE_NORMAL    = 00000000b
WSTATE_MAXIMIZED = 00000001b
WSTATE_MINIMIZED = 00000010b
WSTATE_ROLLEDUP  = 00000100b

WSTATE_REDRAW    = 00000001b
WSTATE_WNDDRAWN  = 00000010b

WSTYLE_HASCAPTION     = 00010000b
WSTYLE_CLIENTRELATIVE = 00100000b

struct  TASKDATA
        event_mask      dd ?
        pid             dd ?
                        dw ?
        state           db ?
                        db ?
                        dw ?
        wnd_number      db ?
                        db ?
        mem_start       dd ?
        counter_sum     dd ?
        counter_add     dd ?
        cpu_usage       dd ?
ends

TSTATE_RUNNING        = 0
TSTATE_RUN_SUSPENDED  = 1
TSTATE_WAIT_SUSPENDED = 2
TSTATE_ZOMBIE         = 3
TSTATE_TERMINATING    = 4
TSTATE_WAITING        = 5
TSTATE_FREE           = 9

ZPOS_DESKTOP            = -2
ZPOS_ALWAYS_BACK        = -1
ZPOS_NORMAL             = 0
ZPOS_ALWAYS_TOP         = 1     ;ZPOS_ALWAYS_TOP is always last and has max number!
; structures definition
struct  WDATA
        box             BOX
        cl_workarea     dd ?
        cl_titlebar     dd ?
        cl_frames       dd ?
        z_modif         db ?
        fl_wstate       db ?
        fl_wdrawn       db ?
        fl_redraw       db ?
ends

label WDATA.fl_wstyle byte at WDATA.cl_workarea + 3

struct  DBG_REGS
        dr0             dd ?
        dr1             dd ?
        dr2             dd ?
        dr3             dd ?
        dr7             dd ?
ends

struct  PROC
        list            LHEAD
        thr_list        LHEAD
        heap_lock       MUTEX
        heap_base       rd 1
        heap_top        rd 1
        mem_used        rd 1
        dlls_list_ptr   rd 1
        pdt_0_phys      rd 1
        pdt_1_phys      rd 1
        io_map_0        rd 1
        io_map_1        rd 1

        ht_lock         rd 1
        ht_free         rd 1            ;htab[0] stdin
        ht_next         rd 1            ;htab[1] stdout
        htab            rd (4096-$)/4   ;htab[2] stderr
        pdt_0           rd 1024
ends

struct  APPDATA
        app_name        rb 11
                        rb 5

        list            LHEAD           ;+16
        process         dd ?            ;+24
        fpu_state       dd ?            ;+28
        exc_handler     dd ?            ;+32
        except_mask     dd ?            ;+36
        pl0_stack       dd ?            ;+40
        cursor          dd ?            ;+44
        fd_ev           dd ?            ;+48
        bk_ev           dd ?            ;+52
        fd_obj          dd ?            ;+56
        bk_obj          dd ?            ;+60
        saved_esp       dd ?            ;+64
        io_map          rd 2            ;+68
        dbg_state       dd ?            ;+76
        cur_dir         dd ?            ;+80
        wait_timeout    dd ?            ;+84
        saved_esp0      dd ?            ;+88
        wait_begin      dd ?            ;+92   +++
        wait_test       dd ?            ;+96   +++
        wait_param      dd ?            ;+100  +++
        tls_base        dd ?            ;+104
                        dd ?            ;+108
        event_filter    dd ?            ;+112
        draw_bgr_x      dd ?            ;+116
        draw_bgr_y      dd ?            ;+120
                        dd ?            ;+124

        wnd_shape       dd ?            ;+128
        wnd_shape_scale dd ?            ;+132
                        dd ?            ;+136
                        dd ?            ;+140
        saved_box       BOX             ;+144
        ipc_start       dd ?            ;+160
        ipc_size        dd ?            ;+164
        event_mask      dd ?            ;+168
        debugger_slot   dd ?            ;+172
        terminate_protection dd ?       ;+176
        keyboard_mode   db ?            ;+180
                        rb 3
                        dd ?            ;+184
        dbg_event_mem   dd ?            ;+188
        dbg_regs        DBG_REGS        ;+192
        wnd_caption     dd ?            ;+212
        wnd_clientbox   BOX             ;+216
        priority        dd ?            ;+232
        in_schedule     LHEAD           ;+236

ends

struct  IDE_DATA
        ProgrammingInterface dd ?
        Interrupt            dw ?
        RegsBaseAddres       dw ?
        BAR0_val             dw ?
        BAR1_val             dw ?
        BAR2_val             dw ?
        BAR3_val             dw ?
        dma_hdd_channel_1    db ?
        dma_hdd_channel_2    db ?
ends

struct  IDE_CACHE
        pointer              dd ?
        size                 dd ?   ; not use
        data_pointer         dd ?
        system_data_size     dd ?   ; not use
        appl_data_size       dd ?   ; not use
        system_data          dd ?
        appl_data            dd ?
        system_sad_size      dd ?
        appl_sad_size        dd ?
        search_start         dd ?
        appl_search_start    dd ?
ends

struct  IDE_DEVICE
        UDMA_possible_modes  db ?
        UDMA_set_mode        db ?
ends

; Core functions
include "core/sync.inc"     ; macros for synhronization objects
include "core/sys32.inc"    ; process management
include "core/sched.inc"    ; process scheduling
include "core/syscall.inc"  ; system call
include "core/fpu.inc"      ; all fpu/sse support
include "core/memory.inc"
include "core/mtrr.inc"
include "core/heap.inc"     ; kernel and app heap
include "core/malloc.inc"   ; small kernel heap
include "core/taskman.inc"
include "core/dll.inc"
include "core/peload.inc"   ;
include "core/exports.inc"
include "core/string.inc"
include "core/v86.inc"      ; virtual-8086 manager
include "core/irq.inc"      ; irq handling functions
include "core/apic.inc"     ; Interrupt Controller functions
include "core/timers.inc"
include "core/clipboard.inc" ; custom clipboard

; GUI stuff
include "gui/window.inc"
include "gui/event.inc"
include "gui/font.inc"
include "gui/button.inc"

; shutdown

; file system

include "blkdev/disk.inc" ; support for plug-n-play disks
include "blkdev/disk_cache.inc" ; caching for plug-n-play disks
include "blkdev/rd.inc"   ; ramdisk read /write
include "fs/fat.inc"      ; read / write for fat filesystem
include "fs/ntfs.inc"     ; read / write for ntfs filesystem
include "fs/fs_lfn.inc"    ; syscall, version 2
include "fs/iso9660.inc"  ; read for iso9660 filesystem CD
include "fs/ext2/ext2.asm"     ; read / write for ext2 filesystem
include "fs/xfs.asm"      ; read / write for xfs filesystem

; sound

include "sound/playnote.inc" ; player Note for Speaker PC

; display

;include "video/vesa12.inc"   ; Vesa 1.2 functions
include "video/vesa20.inc"   ; Vesa 2.0 functions
include "video/blitter.inc"  ;
include "video/vga.inc"      ; VGA 16 color functions
include "video/cursors.inc"  ; cursors functions

; Network Interface & TCPIP Stack

include "network/stack.inc"

;include "drivers/uart.inc"


; Mouse pointer

include "gui/mouse.inc"

; Window skinning

include "gui/skincode.inc"

; Pci functions

include "bus/pci/pci32.inc"

; USB functions
include "bus/usb/init.inc"

; Floppy drive controller

include "blkdev/fdc.inc"
include "blkdev/flp_drv.inc"

; IDE cache
include "blkdev/ide_cache.inc"

; HD drive controller
include "blkdev/hd_drv.inc"
; Access through BIOS
include "blkdev/bd_drv.inc"

; CD drive controller

include "blkdev/cd_drv.inc"

; Character devices

include "hid/keyboard.inc"
include "hid/mousedrv.inc"

; setting date,time,clock and alarm-clock

include "hid/set_dtc.inc"

;% -include

;parser file names
include "fs/parse_fn.inc"

; work with conf lib
include "core/conf_lib.inc"

; load external lib
include "core/ext_lib.inc"

; list of external functions
include "imports.inc"
