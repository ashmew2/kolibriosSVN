;#___________________________________________________________________________________________________
;****************************************************************************************************|
; Program Palitra (c) Sergei Steshin (Akyltist)                                                      |
;----------------------------------------------------------------------------------------------------|
;; compiler:     FASM 1.69.31                                                                        |
;; version:      0.2.0                                                                               |
;; last update:  15/09/2012                                                                          |
;; e-mail:       dr.steshin@gmail.com                                                                |
;.....................................................................................................
;; History:                                                                                          |
;; 0.1.0 - ��ࢠ� ����� �ணࠬ��                                                                   |
;; 0.2.0 - ��ࠢ���� ��������� � ���, ������ ������訩 �� ��������� ���ᥫ�.                     |
;;       - ��������� ����㭪�, ��� ॣ㫨஢���� rgb ��⠢����� 梥� � �뢮� ��� ��⠢�����.   |
;;       - ��࠭ �뢮� 梥� � ����୮� ���� (���� �� �� ����������� � �� ���㠫쭮����).            |
;;       - ������ ��ᬥ⨪�.                                                                         |
;.....................................................................................................
;; All rights reserved.                                                                              |
;;                                                                                                   |
;; Redistribution and use in source and binary forms, with or without modification, are permitted    |
;; provided that the following conditions are met:                                                   |
;;       * Redistributions of source code must retain the above copyright notice, this list of       |
;;         conditions and the following disclaimer.                                                  |
;;       * Redistributions in binary form must reproduce the above copyright notice, this list of    |
;;         conditions and the following disclaimer in the documentation and/or other materials       |
;;         provided with the distribution.                                                           |
;;       * Neither the name of the <organization> nor the names of its contributors may be used to   |
;;         endorse or promote products derived from this software without specific prior written     |
;;         permission.                                                                               |
;;                                                                                                   |
;; THIS SOFTWARE IS PROVIDED BY Sergei Steshin ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,      |
;; INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A        |
;; PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY DIRECT, |
;; INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED    |
;; TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS       |
;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT          |
;; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS  |
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                                      |
;....................................................................................................|


;#___________________________________________________________________________________________________
;****************************************************************************************************|
; ��������� ������������ ����� ���������� ��� ������� ��                                             |
;----------------------------------------------------------------------------------------------------/
  use32
  org	 0x0

  db	 'MENUET01'
  dd	 0x01
  dd	 START
  dd	 I_END
  dd	 0x1000
  dd	 0x1000
  dd	 0x0
  dd	 0x0

include 'macros.inc'

START:
;#___________________________________________________________________________________________________
;****************************************************************************************************|
; �������� ���� ��������� - ��������� �������                                                        |
;----------------------------------------------------------------------------------------------------/
red:
    call draw_window			  ; ��뢠�� ����ᮢ�� ���� �ਫ������
still:
    mcall   10				  ; �㭪�� 10 - ����� ᮡ���
    cmp     eax,1			  ; ����ᮢ��� ���� ?
    je	    red 			  ; �᫨ �� - �� ���� red
    cmp     eax,2			  ; ����� ������ ?
    je	    key 			  ; �᫨ �� - �� key
    cmp     eax,3			  ; ����� ������ ?
    je	    button			  ; �᫨ �� - �� button
    jmp     still			  ; �᫨ ��㣮� ᮡ�⨥ - � ��砫� 横��
;end_still


key:					  ; ����� ������ �� ���������
    mcall   2				  ; �㭪�� 2 - ����� ��� ᨬ���� (� ah) (��� � �ਭ樯� �� �㦭�)
    jmp     still			  ; �������� � ��砫� 横��
;end_key

button:
    mcall   17				  ; 17 - ������� �����䨪��� ����⮩ ������
    cmp     ah, 1			  ; �᫨ ����� ������ � ����஬ 1,
    jz	    bexit			  ; ��室��
    cmp     ah, 7
    jne     color_button
    call    mouse_get
    jmp     still
  color_button:
    push    eax
    call    mouse_local 		  ; ����稫 ������� ���न����
    mov     ebx,129
    mov     ecx,[mouse_y]
    sub     ebx,ecx
    mov     ecx,3
    imul    ecx,ebx

    ;push    ecx


    pop     eax
  red_button:
    cmp     ah, 8
    jne     green_button
    mov     [cred],cl
    call    set_spectr
    jmp     still
  green_button:
    cmp     ah, 9
    jne     blue_button
    mov     [cgreen],cl
    call    set_spectr
    jmp     still
  blue_button:
    cmp     ah, 10
    jne     still
    mov     [cblue],cl
    call    set_spectr
    jmp     still
  bexit:
    mcall -1				  ; ���� ����� �ணࠬ��
;end_button

;#___________________________________________________________________________________________________
;****************************************************************************************************|
; ������� ������ ��������� ���� � ��������� ����������                                               |
;----------------------------------------------------------------------------------------------------/
draw_window:
    mov     eax,12			  ; �㭪�� 12: ����砥�, �� �㤥� �ᮢ����� ����
    mov     ebx,1			  ; 1,��砫� �ᮢ����
    int     0x40			  ; ���뢠���

    mov     eax,48			  ; �㭪�� 48 - �⨫� �⮡ࠦ���� ����
    mov     ebx,3			  ; ����㭪�� 3 - ������� �⠭����� 梥� ����.
    mov     ecx,sc			  ; �����⥫� �� ���� ࠧ��஬ edx ����, ��� ��������
    mov     edx,sizeof.system_colors	  ; ������ ⠡���� 梥⮢ (������ ���� 40 ����)
    int     0x40			  ; ���뢠���

    mov     eax,48			  ; �㭪�� 48 - �⨫� �⮡ࠦ���� ����.
    mov     ebx,4			  ; ����㭪�� 4 - �����頥� eax = ���� ᪨��.
    int     0x40			  ; ���뢠���
    mov     ecx,eax			  ; ���������� ����� ᪨��

    xor     eax,eax			  ; ��頥� eax (mov eax,0) (�㭪�� 0)
    mov     ebx,200 shl 16+325		  ; [���न��� �� �� x]*65536 + [ࠧ��� �� �� x]
    add     ecx,200 shl 16+168		  ; ���� ᪨�� + [���न��� �� y]*65536 + [ࠧ��� �� y]
    mov     edx,[sc.work]		  ; ������ �⨫� ���� �� ��䮫��
    or	    edx,0x34000000		  ; ��� ���� � ᪨��� 䨪�஢����� ࠧ��஢
    mov     edi,title			  ; ��������� ����
    int     0x40			  ; ���뢠���

    call    draw_palitra		  ; ������ �������
    call    draw_result 		  ; ������ ���������

    mov     eax,8			  ; �㭪�� 8 - ��।�����/㤠���� ������
    mov     ebx,89 shl 16+222		  ; ��砫�� ���न���� �� � [�-� x]*65536 + [ࠧ���]
    mov     ecx,9 shl 16+147		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    mov     edx,0x60000007		  ; ��砫쭮� ID ������ - 0xXYnnnnnn
    int     0x40

    mov     ebx,10 shl 16+8		  ; ��砫�� ���न���� �� � [�-� x]*65536 + [ࠧ���]
    mov     edx,0x60000008		  ; ID = 8
    mov     ecx,45 shl 16+85		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    int     0x40			  ; ���㥬 ��������� ������ ��� ᫠���஬ red
    add     ebx,29 shl 16		  ; ������塞
    inc     edx 			  ; ID = 9
    int     0x40			  ; ���㥬 ��������� ������ ��� ᫠���஬ green
    add     ebx,29 shl 16		  ; ������塞
    inc     edx 			  ; ID = 10
    int     0x40			  ; ���㥬 ��������� ������ ��� ᫠���஬ blue

    mov     eax,12			  ; �㭪�� 12: ����砥�, �� �㤥� �ᮢ����� ����
    mov     ebx,2			  ; 1,��砫� �ᮢ����
    int     0x40			  ; ���뢠���

    ret 				  ; �����頥� �ࠢ�����


;#___________________________________________________________________________________________________
;****************************************************************************************************|
; ���� ��������������� �������� � ������� ����������                                                 |
;----------------------------------------------------------------------------------------------------/

mouse_global:
    ;.................................................................................................
    ; ����砥� ���न���� ���
    ;.................................................................................................
    mov     eax,37			  ; �㭪�� 37 - ࠡ�� � �����
    mov     ebx,0			  ; ��� �㦭� �������� ���न����
    int     0x40			  ; eax = x*65536 + y, (x,y)=���न���� ����� ���
    mov     ecx,eax			  ;
    shr     ecx,16			  ; ecx = x+1
    movzx   edx,ax			  ; edx = y+1
    dec     ecx 			  ; ecx = x
    dec     edx 			  ; edx = y
    mov     [mouse_x],ecx		  ; mouse_x = x
    mov     [mouse_y],edx		  ; mouse_y = y
    ret 				  ; �����頥� �ࠢ�����
;end_mouse_global

mouse_local:
    ;.................................................................................................
    ; ����砥� ���न���� ��� �⭮�⥫쭮 ����
    ;.................................................................................................
    mov     eax,37			  ; �㭪�� 37 - ࠡ�� � �����
    mov     ebx,1			  ; ��� �㦭� �������� ���न����
    int     0x40			  ; eax = x*65536 + y, (x,y)=���न���� ����� ���
    mov     ecx,eax			  ;
    shr     ecx,16			  ; ecx = x+1
    movzx   edx,ax			  ; edx = y+1
    dec     ecx 			  ; ecx = x
    dec     edx 			  ; edx = y
    mov     [mouse_x],ecx		  ; mouse_x = x
    mov     [mouse_y],edx		  ; mouse_y = y
    ret 				  ; �����頥� �ࠢ�����
;end_mouse_local

desktop_get:
    ;.................................................................................................
    ; ��।��塞 �ਭ� ��࠭�
    ;.................................................................................................
    mov     eax,14			  ; ��।��塞 �ਭ� ��࠭� (eax = [xsize]*65536 + [ysize])
    int     0x40			  ; xsize = ࠧ��� �� ��ਧ��⠫� - 1
    mov     ebx,eax			  ;
    shr     ebx,16			  ; ebx = xsize-1
    ;movzx   edx,ax                       ;; edx = ysize-1 (��譨� ���)
    inc     ebx 			  ; ebx = xsize
    ;inc     edx                          ;; edx = ysize (��譨� ���)
    mov     [desctop_w],ebx
    ret
;end_desktop_get

mouse_get:
    mov     esi,2			  ; �������: 䫠� ��� ��������� ��横�������
    call    mouse_global
    call    desktop_get
    re_mouse_loop:			  ; �������: ��⪠ ��� ������ �᫨ ������ � ���
      mov     ebx,[desctop_w]
      imul    ebx,[mouse_y]		  ; ebx = y*xsize
      add     ebx,[mouse_x]		  ; ebx = y*xsize+x

      ;.................................................................................................
      ; ��६ 梥� � ������� � ��६�����
      ;.................................................................................................
      mov     eax,35			  ; �㭪�� ����� 梥�
      ;mov     ebx,ecx                    ;; ebx = y*xsize+x (��譨� ���)
      int     0x40			  ; ����砥� 梥� � eax
      cmp     eax,[sc.work]		  ; �ࠢ������ � 䮭�� �ਫ������
      je      mouse_err 		  ; �᫨ �� �� - � ��祣� �� ������
      cmp     eax,0x222222		  ; �ࠢ������ � 梥⮬ �⪨
      je      mouse_err 		  ; �᫨ �� �� - � ��祣� �� ������
      jmp     mouse_set 		  ; �������: ��룠�� �⮡� �� ���� 梥� �⪨
    mouse_err:				  ; �������: �᫨ ������ � ��� ��� 䮭
      inc     [mouse_y] 		  ; �������: ᬥ頥� �� ��������� ᭠砫� �� �
      inc     [mouse_x] 		  ; �������: ᬥ頥� �� ��������� ��⮬ �� �
      dec     esi			  ; �������: �����蠥� 䫠�
      cmp     esi,0			  ; �������: �ࠢ������ � �㫥�
    jz	      mouse_exit		  ; �������: �᫨ ���� � ᤥ���� ��� �� �����
    jmp    re_mouse_loop		  ; �������: �᫨ �� ���� � ���஡㥬 ����� �ᥫ��� ���ᥫ�
    mouse_set:
    mov     [color],eax 		  ; ���� ���������� ���� 梥�
    call    draw_result 		  ; �뢮��� १����
    mouse_exit:
    ret 				  ; �����頥� �ࠢ�����
;end_mouse_get----------------------------------------------------------------------------------------

draw_palitra:
    ;.................................................................................................
    ; ���ᮢ�� 䮭� ��� ������
    ;.................................................................................................
    mov     eax,13			  ; �㭪�� 13 - ���ᮢ��� ��אַ㣮�쭨�
    mov     edx,0x222222		  ; 梥�
    mov     ecx,9 shl 16+73		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    mov     esi,2			  ; ���稪 ����� ��������
    re_draw:
    mov     ebx,89 shl 16+73		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    mov     edi,3			  ; ���稪 ������⢠ ��������
    for_fon_loop:
      int     0x40			  ; ���뢠���
      add     ebx,75 shl 16		  ; ���頥� ��������� ����� �� �
      dec     edi			  ; �����蠥� ���稪 ������
      cmp     edi,0			  ; �ࠢ������ � �㫥�
    jnz     for_fon_loop		  ; �᫨ �� ���� � � ��砫� 横��
    dec     esi 			  ; �����蠥� ���
    cmp     esi,0			  ; �ࠢ������ � �㫥�
    mov     ecx,84 shl 16+73		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    jnz     re_draw			  ; �᫨ �� ���� � � ��砫� 横��

    ;.................................................................................................
    ; ���ᮢ�� ������ �� 横��
    ;.................................................................................................
    mov     eax,13			  ; �㭪�� 13 - ���ᮢ��� ��אַ㣮�쭨�
    mov     edx,0x0FFFFFFF		  ; 梥�
    mov     esi,6			  ; ���稪 ������⢠ ����楢 (#4,8)
    mov     ebx,78 shl 16+8		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    for_abz:
      ;;push    esi                       ; ���࠭塞 ���祭�� ���稪� ����� � �⥪
      cmp     esi,3
      jne     x2_line
      mov     ebx,78 shl 16+8
      x2_line:
      add     ebx,3 shl 16		  ; ���頥� ��������� ����� �� x
      mov     edi,8			  ; ���稪 ������⢠ ������ � ��ப�
      for_stolbik:
	push	edi			  ; ���࠭塞 ���祭�� ���稪� ����� � �⥪
	mov	edi,8			  ; ���稪 ������⢠ ������ � ��ப�
	mov	ecx,  1 shl 16+8	  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
	cmp	esi,3
	jg	y2_line 		  ; �᫨ ����� 4 � ����ਬ
	mov	ecx,76 shl 16+8
	y2_line:
	add	ebx,9 shl 16		  ; ���頥� ��������� ����� �� x
	for_loop:
	  add	  ecx,9 shl 16		  ; ���頥� ��������� ����� �� y
	  int	  0x40			  ; ���뢠���
	  sub	  edx,32 shl 16
	  dec	  edi			  ; �����蠥� ���稪 ������
	  cmp	  edi,0 		  ; �ࠢ������ � �㫥�
	  jnz	  for_loop		  ; �᫨ �� ���� � � ��砫� 横��
      sub     edx,32 shl 8
      pop     edi			  ; ���� ����⠭�������� ���稪 �����
      dec     edi			  ; �����蠥� ���
      cmp     edi,0			  ; �ࠢ������ � �㫥�
      jnz     for_stolbik		  ; �᫨ �� ���� � � ��砫� 横��
    sub     edx,48			  ; (#64,32)
    ;;pop     esi                         ; ���� ����⠭�������� ���稪 �����
    dec     esi 			  ; �����蠥� ���
    cmp     esi,0			  ; �ࠢ������ � �㫥�
    jnz     for_abz			  ; �᫨ �� ���� � � ��砫� 横��
    ret 				  ; �����頥� �ࠢ�����
;end_draw_palitra-------------------------------------------------------------------------------------

draw_result:
    ;.................................................................................................
    ; ���ᮢ�� १���� 梥� � hex
    ;.................................................................................................
    mov     eax,13			  ; �㭪�� 13 - ���ᮢ��� ��אַ㣮�쭨�
    mov     edx,0x222222		  ; 梥�-�������
    mov     ebx,4 shl 16+15		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    mov     ecx,9 shl 16+15		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    int     0x40			  ; ���뢠��� (�� ���� ��אַ㣮�쭨�)
    mov     ebx,23 shl 16+62		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    int     0x40			  ; ���뢠��� (�� ���� ��אַ㣮�쭨�)

    mov     edx,[color] 		  ; 梥�
    mov     ebx,5 shl 16+13		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    mov     ecx,10 shl 16+13		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    int     0x40			  ; ���뢠��� (�� ���� ��אַ㣮�쭨�)
    mov     edx,0xFFFFFF		  ; 梥�-䮭�
    mov     ebx,24 shl 16+60		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    int     0x40			  ; ���뢠��� (�� ���� ��אַ㣮�쭨�)

    mov     eax,47			  ; �㭪�� 47 - �뢮� �᫠ � ����
    mov     ecx,[color] 		  ; �᫮ (�� bl=0) ��� 㪠��⥫� (�� bl=1)
    mov     esi,0x0			  ; 0xX0RRGGBB
    mov     ebx,256+8 shl 16		  ; ��ࠬ���� �८�ࠧ������ �᫠ � ⥪�� (HEX)
    mov     edx,34 shl 16+13		  ; [���न��� �� �� x]*65536 + [���न��� �� �� y]
    int     0x40			  ; ���뢠��� - �뢮��� १���� � ���� (HEX)

    mov     eax,4			  ; �㭪�� 4: ������� ⥪�� � ����
    mov     ebx,27*65536+13		  ; [x ��砫��] *65536 + [y ��砫��]
    mov     ecx,0x0			  ; 梥� ⥪�� RRGGBB
    mov     edx,hex			  ; ��㥬 '#'
    mov     esi,1			  ; ����� ⥪�� � �����
    int     0x40

    ;.................................................................................................
    ; ���ᮢ�� ����� ��� r g b ���祭��
    ;.................................................................................................
    call    get_spectr
    mov     eax,13			  ; �㭪�� 13 - ���ᮢ��� ��אַ㣮�쭨�
    mov     edx,0x222222		  ; 梥�-�������
    mov     ebx,4 shl 16+23		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    mov     ecx,142 shl 16+15		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    int     0x40
    mov     ebx,33 shl 16+23		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    int     0x40
    mov     ebx,62 shl 16+23		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    int     0x40
    mov     edx,0xFFFFFF		  ; 梥�-�������
    mov     ebx,5 shl 16+21		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    mov     ecx,143 shl 16+13		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    int     0x40
    mov     ebx,34 shl 16+21		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    int     0x40
    mov     ebx,63 shl 16+21		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    int     0x40

    ;.................................................................................................
    ; ���ᮢ�� r g b ���祭��
    ;.................................................................................................
    movzx   eax,[cred]			  ; ����
    mov     ebx,7*65536+146		  ; [x ��砫��] *65536 + [y ��砫��]
    call    draw_value			  ; �뢮��� १����

    movzx   eax,[cgreen]		  ; ������
    mov     ebx,36*65536+146		  ; [x ��砫��] *65536 + [y ��砫��]
    call    draw_value			  ; �뢮��� १����

    movzx   eax,[cblue] 		  ; ᨭ��
    mov     ebx,65*65536+146		  ; [x ��砫��] *65536 + [y ��砫��]
    call    draw_value			  ; �뢮��� १����

    ;.................................................................................................
    ; ����塞 䮭
    ;.................................................................................................
    mov     eax,13			  ; �㭪�� 13 - ���ᮢ��� ��אַ㣮�쭨�
    mov     edx,[sc.work]		  ; 梥�-�������
    mov     ebx,8 shl 16+66		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    mov     ecx,40 shl 16+87		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    int     0x40

    ;mov     eax,13                        ; �㭪�� 13 - ���ᮢ��� ��אַ㣮�쭨�
    ;mov     edx,0x222222                  ; 梥�-�������
    ;mov     ebx,4 shl 16+23               ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    ;mov     ecx,30 shl 16+105             ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    ;int     0x40
    ;add     ebx,29 shl 16                 ; ��砫�� ���न���� �� x [�-� y]*65536 + [ࠧ���]
    ;int     0x40
    ;add     ebx,29 shl 16                 ; ��砫�� ���न���� �� x [�-� y]*65536 + [ࠧ���]
    ;int     0x40

    mov     eax,13			  ; �㭪�� 13 - ���ᮢ��� ��אַ㣮�쭨�
    mov     edx,[sc.work]		  ; 梥�-�������
    mov     ebx,5 shl 16+21		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    mov     ecx,31 shl 16+103		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    int     0x40
    add     ebx,29 shl 16		  ; ��砫�� ���न���� �� x [�-� y]*65536 + [ࠧ���]
    int     0x40
    add     ebx,29 shl 16		  ; ��砫�� ���न���� �� x [�-� y]*65536 + [ࠧ���]
    int     0x40

    ;.................................................................................................
    ; �뢮��� �㪢� r g b
    ;.................................................................................................
    mov     eax,4			  ; 4 - �뢥�� ��ப� ⥪�� � ����
    mov     ebx,12 shl 16+34		  ; [���न��� �� �� x]*65536 + [���न��� �� �� y]
    mov     ecx,0x0			  ; 0xX0RRGGBB (RR, GG, BB ������ 梥� ⥪��)
    mov     edx,cname			  ; 㪠��⥫� �� ��砫� ��ப�
    mov     esi,2			  ; �뢮���� esi ᨬ�����
    newline:				  ; 横�
      int     0x40			    ; ���뢠���
      add     ebx,29 shl 16		    ; ������塞
      add     edx,2			    ; ������塞
      cmp     [edx],byte 'x'		    ; �ࠢ����� � ���⮬ �
    jne    newline			  ; �᫨ �� ��� ��� �� ࠢ��

    ;.................................................................................................
    ; ���ᮢ�� ᫠���஢
    ;.................................................................................................
    mov     eax,13			  ; �㭪�� 13 - ���ᮢ��� ��אַ㣮�쭨�
    mov     edx,0x222222		  ; 梥�-�������
    mov     ebx,12 shl 16+4		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    mov     ecx,45 shl 16+85		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    int     0x40
    add     ebx,29 shl 16		  ; ��砫�� ���न���� �� x [�-� y]*65536 + [ࠧ���]
    int     0x40
    add     ebx,29 shl 16		  ; ��砫�� ���न���� �� x [�-� y]*65536 + [ࠧ���]
    int     0x40

    mov     edx,0xFA0919		  ; 梥�-�������
    mov     ebx,13 shl 16+2		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    mov     ecx,46 shl 16+83		  ; ��砫�� ���न���� �� y [�-� y]*65536 + [ࠧ���]
    int     0x40
    mov     edx,0x08CE19		  ; 梥�-�������
    add     ebx,29 shl 16		  ; ��砫�� ���न���� �� x [�-� y]*65536 + [ࠧ���]
    int     0x40
    mov     edx,0x0909FF		  ; 梥�-�������
    add     ebx,29 shl 16		  ; ��砫�� ���न���� �� x [�-� y]*65536 + [ࠧ���]
    int     0x40

    ;.................................................................................................
    ; ���ᮢ�� ����㭪��
    ;.................................................................................................
    mov     edx,0x0			  ; 梥�-����㭪��
    mov     ebx,10 shl 16+8		  ; ��砫�� ���न���� �� x [�-� x]*65536 + [ࠧ���]
    movzx   eax,[cred]			  ; ��६ ���祭�� 梥�
    call    draw_slider
    add     ebx,29 shl 16
    movzx   eax,[cgreen]		  ; ��६ ���祭�� 梥�
    call    draw_slider
    add     ebx,29 shl 16
    movzx   eax,[cblue] 		  ; ��६ ���祭�� 梥�
    call    draw_slider

    ret 				  ; �����頥� �ࠢ�����
;end_draw_result

draw_slider:
    xor     ecx,ecx
    mov     cl,0x3			  ; �㤥� ������ ��� �� 3 ⠪ ��� ����㭪� ������� 85 ���ᥫ��
    div     cl				  ; ����� - 楫�� � al ���⮪ � ah
    mov     cl,128			  ; ������ �窠 ����㭪�
    sub     cl,al			  ; cl=cl-al
    shl     ecx,16
    add     ecx,4			  ; ������ ��砫쭮� ���������
    mov     eax,13			  ; �㭪�� 13 - ���ᮢ��� ��אַ㣮�쭨�
    int     0x40
    ret 				  ; �����頥� �ࠢ�����

;end_slider

draw_value:
    ;.................................................................................................
    ; �뢮� �᫠ �� ��ப� � 㪠������ ������
    ;.................................................................................................
    push    ebx 			  ; ��࠭塞 ��᫠��� ���न����
    mov     ebx,10			  ; ��⠭�������� �᭮����� ��⥬� ��᫥���
    mov     edi,buff			  ; 㪠��⥫� �� ��ப� ����
    call    int2ascii			  ; ��������㥬 �᫮ � ����� ��� ��ப� � ���� + esi �����
    mov     eax,4			  ; �㭪�� 4: ������� ⥪�� � ����
    pop     ebx 			  ; ���⠥� �� �⥪� ��᫠��� ���न����
    mov     ecx,0x0			  ; 梥� ⥪�� RRGGBB
    mov     edx,buff			  ; 㪠��⥫� �� ��砫� ⥪��
    int     0x40
    ret 				  ; �����頥� �ࠢ�����
;end_draw_value

hex_digit:
    ;.................................................................................................
    ; �८�ࠧ������ � ASCII (��� ����ᨬ��� �� ��⥬� ��᫥���)
    ;.................................................................................................
    cmp    dl,10			  ; � dl ��������� �᫮ �� 0 �� 15
    jb	   .less			  ; �᫨ dl<10 � ���室��
    add    dl,'A'-10			  ; 10->A 11->B 12->C ...
    ret 				  ; �����頥� �ࠢ�����
    .less:
    or	   dl,'0'			  ; �᫨ ��⥬� ��᫥��� 10-� � �����
    ret 				  ; �����頥� �ࠢ�����
;end_hex_digit

int2ascii:
    ;.................................................................................................
    ; �८�ࠧ������ �᫠ � ��ப�
    ;.................................................................................................
    ; eax - 32-� ���筮� �᫮
    ; ebx - �᭮����� ��⥬� ��᫥���
    ; edi - 㪠��⥫� �� ��ப� ����
    ; �����頥� ���������� ���� � esi - ����� ��ப�
    ;pushad
    xor     esi,esi			  ; ����塞 ���稪 ᨬ�����
    convert_loop:
    xor     edx,edx			  ; ����塞 ॣ���� ��� ���⮪
    div     ebx 			  ; eax/ebx - ���⮪ � edx
    call    hex_digit			  ; �८�ࠧ㥬 ᨬ���
    push    edx 			  ; ����� � �⥪
    inc     esi 			  ; 㢥��稢��� ���稪
    test    eax,eax			  ; �᫨ �� ����� ������
    jnz     convert_loop		  ; � ������ ��
    cld 				  ; ����������� ���뢠�� 䫠� ���ࠢ����� DF (������ �����)
    write_loop: 			  ; ����
    pop     eax 			  ; ���⠥� �� �⥪� � ���
    stosb				  ; �����뢠�� � ���� �� ����� ES:(E)DI
    dec     esi 			  ; 㬥��蠥� ���稪
    test    esi,esi			  ; �᫨ ���� �� ���⠢��� �� �⥪�
    jnz     write_loop			  ; � �����
    mov     byte [edi],0		  ; ���� ������뢠�� �㫥��� ����
    ;popad                                 ; ����⠭�������� ���祭�� ॣ���஢
    ; ��� ���� �� ����� ��祣� ��饣� � �㭪樨, ���� �����頥� �� ������ ����祭��� ��ப�
    mov     edi,buff			  ; 㪠��⥫� �� ��砫� ⥪��
    call    str_len
    mov     esi,eax
    ret 				  ; � �����頥� �ࠢ�����
;end_int2ascii

get_spectr:
    ;.................................................................................................
    ; �����頥� r,g,b ��⮢���騥 梥�
    ;.................................................................................................
    ; get blue
    mov     ecx,[color]
    movzx   eax,cl
    mov     [cblue],al
    ; get red
    mov     eax,ecx
    xor     ax,ax
    shr     eax,16
    mov     [cred],al
    ; get green
    shl      ecx,16
    shr      ecx,24
    mov      [cgreen],cl
    ret 				  ; � �����頥� �ࠢ�����
;end_get_spectr

set_spectr:
    ;.................................................................................................
    ; ��⠭�������� �� r,g,b 梥�
    ;.................................................................................................
    ; get blue
    movzx   eax,[cred]
    shl     eax,8
    mov     al,[cgreen]
    shl     eax,8
    mov     al,[cblue]
    mov     [color],eax
    call    draw_result 		  ; �뢮��� १����
    ret 				  ; � �����頥� �ࠢ�����
;end_get_spectr

str_len:
    ;.................................................................................................
    ; ��।���� ����� ��ப� (�室->EDI ZS offset ; ��室->EAX ZS length)
    ;.................................................................................................
	push ecx
	push esi
	push edi

	cld
	xor   al, al
	mov ecx, 0FFFFFFFFh
	mov esi, edi
	repne scasb
	sub edi, esi
	mov eax, edi
	dec eax

	pop edi
	pop esi
	pop ecx

	ret
;end_str_len
;#___________________________________________________________________________________________________
;****************************************************************************************************|
; ���� ���������� � ��������                                                                         |
;----------------------------------------------------------------------------------------------------/

    color	dd 00000000h		  ; �࠭�� ���祭�� ��࠭���� 梥�
    mouse_x	dd 0			  ; �࠭�� ��������� � ���न���� ���
    mouse_y	dd 0			  ; �࠭�� ��������� � ���न���� ���
    desctop_w	dd 0			  ; �࠭�� �ਭ� ��࠭�
    sc		system_colors		  ; �࠭�� �������� ��⥬��� 梥⮢ ᪨��
    title	db 'Palitra v0.2',0	  ; �࠭�� ��� �ணࠬ��
    hex 	db '#',0		  ; ��� �뢮�� ���⪨ ��� ⥪��
    cname	db 'R G B x'		  ; �࠭�� ࠧ��� 梥⮢ (red,green,blue) x-��⪠ ����
    cred	db 0			  ; �࠭�� ���� ᯥ���
    cgreen	db 0			  ; �࠭�� ������ ᯥ���
    cblue	db 0			  ; �࠭�� ᨭ�� ᯥ���
    buff	db '000',0
I_END:


