;������࠭���� �� ��業��� GPL  SEE YOU File FAQ.txt and HISTORY. Good Like! 
;��⨬���஢���� ��������� EditBox (��室�� ��ਠ�� �� Maxxxx32)
;��⨬����� ������.
;<Lrz>  - ������ ����ᥩ  www.lrz.land.ru
;��������� �ਫ������
use32           ; �࠭����, �ᯮ����騩 32 ࠧ�來�� �������
    org 0x0             ; ������ ���� ����, �ᥣ�� 0x0
    db 'MENUET01'       ; �����䨪��� �ᯮ��塞��� 䠩�� (8 ����)
    dd 0x1              ; ����� �ଠ� ��������� �ᯮ��塞��� 䠩��
    dd start            ; ����, �� ����� ��⥬� ��।��� �ࠢ�����
                        ; ��᫥ ����㧪� �ਫ������ � ������
    dd i_end            ; ࠧ��� �ਫ������
    dd i_end            ; ��ꥬ �ᯮ��㥬�� �����, ��� �⥪� �⢥��� 0�100 ���� � ��஢��� �� �୨�� 4 ����
    dd i_end            ; �ᯮ����� ������ �⥪� � ������ �����, �ࠧ� �� ⥫�� �ணࠬ��. ���設� �⥪� � ��������� �����, 㪠������ ���
    dd 0x0,0x0          ; 㪠��⥫� �� ��ப� � ��ࠬ��ࠬ�.
        include 'macros.inc'
        include 'editbox.inc'
align 4
        use_edit_box procinfo,22,5
;������� ����
start:                          ;��窠 �室� � �ணࠬ��
        mcall   40,0x27         ;��⠭����� ���� ��� ��������� ᮡ�⨩
 ;��⥬� �㤥� ॠ��஢��� ⮫쪮 �� ᮮ�饭�� � ����ᮢ��,����� ������, ��।��񭭠� ࠭��, ᮡ�⨥ �� ��� (��-� ��稫��� - ����⨥ �� ������ ��� ��� ��६�饭��; ���뢠���� �� ���⥭��) � ����⨥ ������
red_win:
    call draw_window            ;��ࢮ��砫쭮 ����室��� ���ᮢ��� ����
align 4
still:                          ;�᭮���� ��ࠡ��稪 
        mcall   10              ;������� ᮡ���
        cmp al,0x1    ;�᫨ ���������� ��������� ����
        jz red_win
        cmp al,0x2    ;�᫨ ����� ������ � ��३�
        jz key
        cmp al,0x3    ;�᫨ ����� ������ � ��३�
        jz button
        mouse_edit_boxes editboxes,editboxes_end
        jmp still    ;�᫨ ��祣� �� ����᫥����� � ᭮�� � 横�
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
button:
        mcall   17      ;������� �����䨪��� ����⮩ ������
        test ah,ah              ;�᫨ � ah 0, � ��३� �� ��ࠡ��稪 ᮡ�⨩ still
        jz  still
        mcall   -1
key:
        mcall   2       ;����㧨� ���祭�� 2 � ॣ���� eax � ����稬 ��� ����⮩ ������
        key_edit_boxes editboxes,editboxes_end    
    jmp still

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
align 4
draw_window:            ;�ᮢ���� ���� �ਫ������
        mcall   12,1
        mcall   0,(50*65536+390),(30*65536+200),0xb3AABBCC,0x805080DD,hed
        draw_edit_boxes editboxes,editboxes_end,use_f9,procinfo  ;�ᮢ���� edit box'��
        mcall   12,2
    ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;DATA ����� 
editboxes:
edit1 edit_box 168,5,10,0xffffff,0x6a9480,0,0,0,99,ed_buffer.2,ed_figure_only
edit2 edit_box 250,5,30,0xffffff,0x6a9480,0,0xAABBCC,0,308,hed,ed_focus,53,53
edit3 edit_box 35,5,50,0xffffff,0x6a9480,0,0,0,9,ed_buffer.3,ed_figure_only
edit4 edit_box 16,5,70,0xffffff,0x6a9480,0,0,0,1,ed_buffer.4,ed_figure_only
editboxes_end:
data_of_code dd 0
mouse_flag dd 0x0
hed db   'EDITBOX optimization and retype <Lrz> date 09.05.2007',0
rb  256
ed_buffer:
;.1: rb 514;256
.2: rb 101
.3: rb 11
.4: rb 3
;��� ������� ���� ����室��� ��� ⮣� �� �� �� ����९���� ᫥���騥� �����, � ���� ���� 0
buffer_end:
align 16
procinfo:
rb 1024 ;1 �� ��� ����祭�� ��饩 �������� 
rb 1024 ;Stack
i_end:  
