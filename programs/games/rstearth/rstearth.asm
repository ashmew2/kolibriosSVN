;*****************************************************************************
; Rusty Earth - for Kolibri OS
; Copyright (c) 2014, Marat Zakiyanov aka Mario79, aka Mario
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;        * Redistributions of source code must retain the above copyright
;          notice, this list of conditions and the following disclaimer.
;        * Redistributions in binary form must reproduce the above copyright
;          notice, this list of conditions and the following disclaimer in the
;          documentation and/or other materials provided with the distribution.
;        * Neither the name of the <organization> nor the
;          names of its contributors may be used to endorse or promote products
;          derived from this software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY Marat Zakiyanov ''AS IS'' AND ANY
; EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;*****************************************************************************
  use32
  org 0x0

  db 'MENUET01'
  dd 0x01
  dd START
  dd IM_END
  dd I_END
  dd stacktop
  dd 0x0
  dd path
;-----------------------------------------------------------------------------
include 'lang.inc'
include '../../macros.inc'
include '../../proc32.inc'
;define __DEBUG__ 1
;define __DEBUG_LEVEL__ 1
;include '../../debug-fdo.inc'
include '../../develop/libraries/box_lib/load_lib.mac'
;include '../../develop/libraries/box_lib/trunk/box_lib.mac'
@use_library
;---------------------------------------------------------------------
FONT_SIZE_X = 32
FONT_REAL_SIZE_X = 32
FONT_SIZE_Y = 32
;---------------------------------------------------------------------
LEVEL_MAP_SIZE_X = 10
LEVEL_MAP_SIZE_Y = 10
SPRITE_SIZE_X = 64
SPRITE_SIZE_Y = 64
;-----------------------------------------------------------------------------
ROUTE_UP    = 1
ROUTE_DOWN  = 2
ROUTE_LEFT  = 3
ROUTE_RIGHT = 4
;-----------------------------------------------------------------------------
OBJECT_DEATH = 1
OBJECT_SKELETON = 2
OBJECT_IFRIT = 3
OBJECT_BARRET = 4
OBJECT_FINAL_MONSTER = 14
OBJECT_PROTAGONIST = 15
OBJECT_RED_BRICK = 16
OBJECT_WHITE_BRICK = 17
RED_BRICK_CRASH_1 = 0x80
RED_BRICK_CRASH_2 = 0x81
;-----------------------------------------------------------------------------
BASE_SMALL_ROCK = 0
BASE_GRASS = 1
BASE_LAVA = 2
BASE_WATER = 3
;-----------------------------------------------------------------------------
TARGET_RANGE = 3
;-----------------------------------------------------------------------------
START:
	mcall	68,11
	mcall	66,1,1
	mcall	40,0x7	;27
;--------------------------------------
load_libraries	l_libs_start,end_l_libs
	test	eax,eax
	jnz	button.exit
;--------------------------------------
; unpack deflate
	mov	eax,[unpack_DeflateUnpack2]
	mov	[deflate_unpack],eax
;--------------------------------------
	call	load_and_convert_all_icons
	call	load_all_sound_files
	
	mov	eax,[background_music]
	mov	[wav_for_test],eax
	mov	ebx,eax
	add	ebx,1024
	mov	[wav_for_test_end],ebx
	call	initialize_sound_system
	
	mov	[sounds_flag],1
	mov	[music_flag],1
	mcall	51,1,snd_background_music_thread_start,snd_background_music_thread_stack
;---------------------------------------------------------------------
menu_still:
	jmp	main_menu_start
;---------------------------------------------------------------------
start_level_0:
	mov	[death_of_protagonist],0
	mov	[protagonist_route],2
	mov	[protagonist_position.x],4
	mov	[protagonist_position.y],4
	
	mov	esi,map_level_0
	call	map_level_to_plan_level
	call	generate_objects_id
	call	copy_plan_level_to_plan_level_old
;---------------------------------------------------------------------
red:
	call	draw_window
;---------------------------------------------------------------------
still:
;	mcall	10
	mcall	23,1

	cmp	eax,1
	je	red

	cmp	eax,2
	je	key

	cmp	eax,3
	je	button
	
	call	actions_for_all_cell
	call	show_tiles
	call	harvest_of_death
	call	show_tiles_one_iteration
	cmp	[death_of_protagonist],1
	je	death_of_protagonist_start
	
	mov	eax,[protagonist_position.y]
	imul	eax,LEVEL_MAP_SIZE_X*4
	mov	ebx,[protagonist_position.x]
	shl	ebx,2
	add	eax,ebx
	add	eax,plan_level
	mov	eax,[eax]
	cmp	ah,OBJECT_PROTAGONIST
	jne	death_of_protagonist_start

	jmp	still
;---------------------------------------------------------------------
button:
	mcall	17

	cmp	ah,1
	jne	still
;--------------------------------------
.exit:
	mov	eax,[N_error]
;        DEBUGF  1, "N_error: %d\n",eax
	test	eax,eax
	jz	@f

	mcall	51,1,thread_start,thread_stack
;--------------------------------------
@@:
	mcall	-1
;---------------------------------------------------------------------
draw_window:
	mcall	12,1
	mcall	48,4
	mov	ecx,100 shl 16 + 644
	add	cx,ax
	mcall	0,<100,649>,,0x74AABBCC,,title
;	mcall	13,<0,640>,<0,640>,0xff0000
	mov	[draw_all_level],1
;	call	show_tiles
	call	show_tiles_one_iteration
	mov	[draw_all_level],0
;	mcall	4,<3,8>,0,message,message.size
	mcall	12,2
	ret
;---------------------------------------------------------------------
memory_free_error:
	mov	[N_error],3
	jmp	button.exit
;---------------------------------------------------------------------
memory_get_error:
	mov	[N_error],4
	jmp	button.exit
;-----------------------------------------------------------------------------
include 'key.inc'
include 'show_tiles.inc'
include 'show_base.inc'
include 'show_object.inc'
include 'death_protagonist.inc'
include 'load.inc'
include 'icon_convert.inc'
include 'error_window.inc'
include 'actions.inc'
include 'actions_npc.inc'
include 'actions_protagonist.inc'
include 'actions_white_bricks.inc'
include 'random.inc'
include 'snd_api.inc'
include 'sound.inc'
include 'menu.inc'
include 'font.inc'
;---------------------------------------------------------------------
if lang eq ru
	include 'localization_rus.inc'
else
	include 'localization_eng.inc'
end if
;---------------------------------------------------------------------
include 'i_data.inc'
include 'levels.inc'
;---------------------------------------------------------------------
IM_END:
;---------------------------------------------------------------------
;include_debug_strings
;---------------------------------------------------------------------
include 'u_data.inc'
;---------------------------------------------------------------------
I_END:
