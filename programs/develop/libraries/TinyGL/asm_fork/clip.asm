; fill triangle profile
; #define PROFILE

CLIP_XMIN equ (1<<0)
CLIP_XMAX equ (1<<1)
CLIP_YMIN equ (1<<2)
CLIP_YMAX equ (1<<3)
CLIP_ZMIN equ (1<<4)
CLIP_ZMAX equ (1<<5)

offs_X equ 0
offs_Y equ 4
offs_Z equ 8
offs_W equ 12

align 4
proc gl_transform_to_viewport uses eax ebx ecx, context:dword,v:dword
locals
	point dd ?
endl
	mov eax,[context]
	mov ebx,[v]

	; coordinates
	fld1
	fdiv dword[ebx+offs_vert_pc+offs_W] ;st0 = 1/v.pc.W

	fld dword[ebx+offs_vert_pc+offs_X] ;st0 = v.pc.X
	fmul st0,st1
	fmul dword[eax+offs_cont_viewport+offs_vpor_scale+offs_X]
	fadd dword[eax+offs_cont_viewport+offs_vpor_trans+offs_X]
	fistp dword[ebx+offs_vert_zp] ;v.zp.x = st0, st0 = st1

	fld dword[ebx+offs_vert_pc+offs_Y] ;st0 = v.pc.Y
	fmul st0,st1
	fmul dword[eax+offs_cont_viewport+offs_vpor_scale+offs_Y]
	fadd dword[eax+offs_cont_viewport+offs_vpor_trans+offs_Y]
	fistp dword[ebx+offs_vert_zp+offs_zbup_y] ;v.zp.y = st0, st0 = st1

	fld dword[ebx+offs_vert_pc+offs_Z] ;st0 = v.pc.Z
	fmul st0,st1
	fmul dword[eax+offs_cont_viewport+offs_vpor_scale+offs_Z]
	fadd dword[eax+offs_cont_viewport+offs_vpor_trans+offs_Z]
	fistp dword[ebx+offs_vert_zp+offs_zbup_z] ;v.zp.z = st0, st0 = st1

	; color
	bt dword[eax+offs_cont_lighting_enabled],0
	jnc @f
		mov ecx,ebx
		add ecx,offs_vert_zp+offs_zbup_b
		push ecx
		add ecx,offs_zbup_g-offs_zbup_b
		push ecx
		add ecx,offs_zbup_r-offs_zbup_g
		push ecx
		stdcall RGBFtoRGBI, dword[ebx+offs_vert_color],dword[ebx+offs_vert_color+4],dword[ebx+offs_vert_color+8]
		jmp .end_if
	@@:
		; no need to convert to integer if no lighting : take current color
		push ecx
		mov ecx,[eax+offs_cont_longcurrent_color]
		mov dword[ebx+offs_vert_zp+offs_zbup_r],ecx
		mov ecx,[eax+offs_cont_longcurrent_color+4]
		mov dword[ebx+offs_vert_zp+offs_zbup_g],ecx
		mov ecx,[eax+offs_cont_longcurrent_color+8]
		mov dword[ebx+offs_vert_zp+offs_zbup_b],ecx
		pop ecx
	.end_if:
  
	; texture
	bt dword[eax+offs_cont_texture_2d_enabled],0
	jnc @f
		mov dword[point],dword(ZB_POINT_S_MAX - ZB_POINT_S_MIN)
		fild dword[point]
		fmul dword[ebx+offs_vert_tex_coord] ;st0 *= v.tex_coord.X
		fistp dword[ebx+offs_vert_zp+offs_zbup_s]
		add dword[ebx+offs_vert_zp+offs_zbup_s],ZB_POINT_S_MIN

		mov dword[point],dword(ZB_POINT_T_MAX - ZB_POINT_T_MIN)
		fild dword[point]
		fmul dword[ebx+offs_vert_tex_coord+4] ;st0 *= v.tex_coord.Y
		fistp dword[ebx+offs_vert_zp+offs_zbup_t]
		add dword[ebx+offs_vert_zp+offs_zbup_s],ZB_POINT_T_MIN
	@@:
if DEBUG ;gl_transform_to_viewport
push edi
	mov ecx,80
	mov eax,[ebx+offs_vert_zp]
	lea edi,[buf_param]
	stdcall convert_int_to_str,ecx
	stdcall str_n_cat,edi,txt_zp_sp,2
	stdcall str_len,edi
	add edi,eax
	sub ecx,eax

	mov eax,[ebx+offs_vert_zp+offs_zbup_y]
	stdcall convert_int_to_str,ecx
	stdcall str_n_cat,edi,txt_zp_sp,2
	stdcall str_len,edi
	add edi,eax
	sub ecx,eax

	mov eax,[ebx+offs_vert_zp+offs_zbup_z]
	stdcall convert_int_to_str,ecx

	stdcall str_n_cat,edi,txt_nl,2
	stdcall dbg_print,f_ttv,buf_param
pop edi
end if
	ret
endp

align 4
proc gl_add_select1 uses eax ebx ecx, context:dword, z1:dword,z2:dword,z3:dword
	mov eax,[z1]
	mov ebx,eax
	cmp [z2],eax
	jge @f
		mov eax,[z2]
	@@:
	cmp [z3],eax
	jge @f
		mov eax,[z3]
	@@:
	cmp [z2],ebx
	jle @f
		mov ebx,[z2]
	@@:
	cmp [z3],ebx
	jle @f
		mov ebx,[z3]
	@@:
	mov ecx,0xffffffff
	sub ecx,ebx
	push ecx
	mov ecx,0xffffffff
	sub ecx,eax
	push ecx
	stdcall gl_add_select, [context] ;,0xffffffff-eax,0xffffffff-ebx
	ret
endp

; point

align 4
proc gl_draw_point uses eax ebx, context:dword, p0:dword
	mov ebx,[p0]
	cmp dword[ebx+offs_vert_clip_code],0 ;if (p0.clip_code == 0)
	jne @f
	mov eax,[context]
	cmp dword[eax+offs_cont_render_mode],GL_SELECT
	jne .els
		stdcall gl_add_select, eax,dword[ebx+offs_vert_zp+offs_zbup_z],dword[ebx+offs_vert_zp+offs_zbup_z] ;p0.zp.z,p0.zp.z
		jmp @f
	.els:
		add ebx,offs_vert_zp
		stdcall ZB_plot, dword[eax+offs_cont_zb],ebx
	@@:
	ret
endp

; line

align 4
proc interpolate uses eax ebx ecx, q:dword,p0:dword,p1:dword,t:dword
	mov eax,[q]
	mov ebx,[p0]
	mov ecx,[p1]
	fld dword[t]

	; интерполяция по координатам
	fld dword[ecx+offs_vert_pc]
	fsub dword[ebx+offs_vert_pc]
	fmul st0,st1
	fadd dword[ebx+offs_vert_pc]
	fstp dword[eax+offs_vert_pc]

	fld dword[ecx+offs_vert_pc+4]
	fsub dword[ebx+offs_vert_pc+4]
	fmul st0,st1
	fadd dword[ebx+offs_vert_pc+4]
	fstp dword[eax+offs_vert_pc+4]

	fld dword[ecx+offs_vert_pc+8]
	fsub dword[ebx+offs_vert_pc+8]
	fmul st0,st1
	fadd dword[ebx+offs_vert_pc+8]
	fstp dword[eax+offs_vert_pc+8]

	fld dword[ecx+offs_vert_pc+12]
	fsub dword[ebx+offs_vert_pc+12]
	fmul st0,st1
	fadd dword[ebx+offs_vert_pc+12]
	fstp dword[eax+offs_vert_pc+12]

	; интерполяция по цвету
	fld dword[ecx+offs_vert_color]
	fsub dword[ebx+offs_vert_color]
	fmul st0,st1
	fadd dword[ebx+offs_vert_color]
	fstp dword[eax+offs_vert_color]

	fld dword[ecx+offs_vert_color+4]
	fsub dword[ebx+offs_vert_color+4]
	fmul st0,st1
	fadd dword[ebx+offs_vert_color+4]
	fstp dword[eax+offs_vert_color+4]

	fld dword[ecx+offs_vert_color+8]
	fsub dword[ebx+offs_vert_color+8]
	fmul st0,st1
	fadd dword[ebx+offs_vert_color+8]
	fstp dword[eax+offs_vert_color+8]
	ret
endp

;
; Line Clipping 
;

; Line Clipping algorithm from 'Computer Graphics', Principles and
; Practice
; tmin,tmax -> &float
align 4
proc ClipLine1 uses ebx, denom:dword,num:dword,tmin:dword,tmax:dword
	fldz
	fcom dword[denom]
	fstsw ax
	sahf
	je .u2
	jmp @f
	.u2:
		fcom dword[num]
		fstsw ax
		sahf
		jb .r0 ;if (denom==0 && num>0) return 0
		jmp .r1
	@@:

	fcom dword[denom]
	fstsw ax
	sahf
	ja .els_0 ;if (0<denom)
		fld dword[num]
		fdiv dword[denom]

		mov ebx,[tmax]
		fcom dword[ebx]
		fstsw ax
		sahf
		ja .r0 ;if (t>*tmax) return 0

		mov ebx,[tmin]
		fcom dword[ebx]
		fstsw ax
		sahf
		jbe .r1
			fstp dword[ebx] ;if (t>*tmin) *tmin=t
		jmp .r1

	.els_0: ;else if (0>denom)
		fld dword[num]
		fdiv dword[denom]

		mov ebx,[tmin]
		fcom dword[ebx]
		fstsw ax
		sahf
		jb .r0 ;if (t<*tmin) return 0

		mov ebx,[tmax]
		fcom dword[ebx]
		fstsw ax
		sahf
		jae .r1
			fstp dword[ebx] ;if (t<*tmin) *tmax=t
	jmp .r1

	.r0: ;return 0
		xor eax,eax
		jmp .end_f
	.r1: ;return 1
		xor eax,eax
		inc eax
	.end_f:
if DEBUG ;ClipLine1
push edi
	mov ecx,80
	lea edi,[buf_param]
	stdcall convert_int_to_str,ecx

	stdcall str_n_cat,edi,txt_nl,2
	stdcall dbg_print,f_cl1,buf_param
pop edi
end if
	ffree st0 ;профилактика для очистки стека
	fincstp   ;как минимум одно значение в стеке уже есть
	ret
endp

align 4
proc gl_draw_line uses eax ebx edx edi esi, context:dword, p1:dword, p2:dword
locals
	d_x dd ?
	d_y dd ?
	d_z dd ?
	d_w dd ?
	x1 dd ?
	y1 dd ?
	z1 dd ?
	w1 dd ?
	q1 GLVertex ?
	q2 GLVertex ?
	tmin dd ? ;ebp-8
	tmax dd ? ;ebp-4
endl

	mov edx,[context]
	mov edi,[p1]
	mov esi,[p2]

if DEBUG
	jmp @f
		f_1 db ' gl_draw_line',0
	@@:
	stdcall dbg_print,f_1,m_1
end if
	cmp dword[edi+offs_vert_clip_code],0
	jne .els_i
	cmp dword[esi+offs_vert_clip_code],0
	jne .els_i
		;if ( (p1.clip_code | p2.clip_code) == 0)
		cmp dword[edx+offs_cont_render_mode],GL_SELECT ;if (context.render_mode == GL_SELECT)
		jne .els_1
			stdcall gl_add_select1, edx,dword[edi+offs_vert_zp+offs_zbup_z],\
				dword[esi+offs_vert_zp+offs_zbup_z],dword[esi+offs_vert_zp+offs_zbup_z]
			jmp .end_f
		.els_1:
			add edi,offs_vert_zp
			add esi,offs_vert_zp
			push esi
			push edi
			push dword[edx+offs_cont_zb]
			cmp dword[edx+offs_cont_depth_test],0
			je .els_2
				;if (context.depth_test)
				call ZB_line_z ;, dword[edx+offs_cont_zb],edi,esi
				jmp .end_f
			.els_2:
				call ZB_line ;, dword[edx+offs_cont_zb],edi,esi
				jmp .end_f
	.els_i:
		;else if ( (p1.clip_code & p2.clip_code) != 0 )
		mov eax,[edi+offs_vert_clip_code]
		and eax,[esi+offs_vert_clip_code]
		cmp eax,0
		jne .end_f
	.els_0:
if DEBUG
	stdcall dbg_print,f_1,m_2
end if

	finit
	fld dword[esi+offs_vert_pc+offs_X]
	fsub dword[edi+offs_vert_pc+offs_X]
	fstp dword[d_x] ;d_x = p2.pc.X - p1.pc.X
	fld dword[esi+offs_vert_pc+offs_Y]
	fsub dword[edi+offs_vert_pc+offs_Y]
	fstp dword[d_y] ;d_y = p2.pc.Y - p1.pc.Y
	fld dword[esi+offs_vert_pc+offs_Z]
	fsub dword[edi+offs_vert_pc+offs_Z]
	fstp dword[d_z] ;d_z = p2.pc.Z - p1.pc.Z
	fld dword[esi+offs_vert_pc+offs_W]
	fsub dword[edi+offs_vert_pc+offs_W]
	fstp dword[d_w] ;d_w = p2.pc.W - p1.pc.W

	mov eax,[edi+offs_vert_pc+offs_X]
	mov [x1],eax ;x1 = p1.pc.X
	mov eax,[edi+offs_vert_pc+offs_Y]
	mov [y1],eax ;y1 = p1.pc.Y
	mov eax,[edi+offs_vert_pc+offs_Z]
	mov [z1],eax ;z1 = p1.pc.Z
	mov eax,[edi+offs_vert_pc+offs_W]
	mov [w1],eax ;w1 = p1.pc.W

	mov dword[tmin],0.0
	mov dword[tmax],1.0

	mov eax,ebp
	sub eax,4
	push eax ;толкаем в стек адрес &tmax
	sub eax,4
	push eax ;толкаем в стек адрес &tmin
	fld dword[x1]
	fadd dword[w1]
	fchs
	fstp dword[esp-4]
	fld dword[d_x]
	fadd dword[d_w]
	fstp dword[esp-8]
	sub esp,8
	call ClipLine1 ;d_x+d_w,-x1-w1,&tmin,&tmax
	bt eax,0
	jnc .end_f

	sub esp,8 ;толкаем в стек адреса переменных &tmin и &tmax
	fld dword[x1]
	fsub dword[w1]
	fstp dword[esp-4]
	fld dword[d_w]
	fsub dword[d_x]
	fstp dword[esp-8]
	sub esp,8
	call ClipLine1 ;-d_x+d_w,x1-w1,&tmin,&tmax
	bt eax,0
	jnc .end_f

	sub esp,8 ;толкаем в стек адреса переменных &tmin и &tmax
	fld dword[y1]
	fadd dword[w1]
	fchs
	fstp dword[esp-4]
	fld dword[d_y]
	fadd dword[d_w]
	fstp dword[esp-8]
	sub esp,8
	call ClipLine1 ;d_y+d_w,-y1-w1,&tmin,&tmax
	bt eax,0
	jnc .end_f

	sub esp,8 ;толкаем в стек адреса переменных &tmin и &tmax
	fld dword[y1]
	fsub dword[w1]
	fstp dword[esp-4]
	fld dword[d_w]
	fsub dword[d_y]
	fstp dword[esp-8]
	sub esp,8
	call ClipLine1 ;-d_y+d_w,y1-w1,&tmin,&tmax
	bt eax,0
	jnc .end_f

	sub esp,8 ;толкаем в стек адреса переменных &tmin и &tmax
	fld dword[z1]
	fadd dword[w1]
	fchs
	fstp dword[esp-4]
	fld dword[d_z]
	fadd dword[d_w]
	fstp dword[esp-8]
	sub esp,8
	call ClipLine1 ;d_z+d_w,-z1-w1,&tmin,&tmax
	bt eax,0
	jnc .end_f

	sub esp,8 ;толкаем в стек адреса переменных &tmin и &tmax
	fld dword[z1]
	fsub dword[w1]
	fstp dword[esp-4]
	fld dword[d_w]
	fsub dword[d_z]
	fstp dword[esp-8]
	sub esp,8
	call ClipLine1 ;-d_z+d_w,z1-w1,&tmin,&tmax
	bt eax,0
	jnc .end_f

	mov eax,ebp
	sub eax,8+2*sizeof.GLVertex ;eax = &q1
	stdcall interpolate, eax,edi,esi,[tmin]
	stdcall gl_transform_to_viewport, edx,eax
	add eax,sizeof.GLVertex ;eax = &q2
	stdcall interpolate, eax,edi,esi,[tmax]
	stdcall gl_transform_to_viewport, edx,eax

	sub eax,sizeof.GLVertex ;eax = &q1
	mov ebx,eax
	add ebx,offs_vert_zp+offs_zbup_b
	push ebx
	add ebx,offs_zbup_g-offs_zbup_b
	push ebx
	add ebx,offs_zbup_r-offs_zbup_g
	push ebx
	stdcall RGBFtoRGBI, dword[eax+offs_vert_color],dword[eax+offs_vert_color+4],dword[eax+offs_vert_color+8]

	add eax,sizeof.GLVertex ;eax = &q2
	mov ebx,eax
	add ebx,offs_vert_zp+offs_zbup_b
	push ebx
	add ebx,offs_zbup_g-offs_zbup_b
	push ebx
	add ebx,offs_zbup_r-offs_zbup_g
	push ebx
	stdcall RGBFtoRGBI, dword[eax+offs_vert_color],dword[eax+offs_vert_color+4],dword[eax+offs_vert_color+8]

	add eax,offs_vert_zp ;eax = &q2.zp
	push eax
	sub eax,sizeof.GLVertex ;eax = &q1.zp
	push eax
	push dword[edx+offs_cont_zb]
	cmp dword[edx+offs_cont_depth_test],0
	je .els_3
		call ZB_line_z ;(context.zb,&q1.zp,&q2.zp)
		jmp .end_f
	.els_3:
		call ZB_line ;(context.zb,&q1.zp,&q2.zp)
	.end_f:
	ret
endp

; triangle

;
; Clipping
;

; We clip the segment [a,b] against the 6 planes of the normal volume.
; We compute the point 'c' of intersection and the value of the parameter 't'
; of the intersection if x=a+t(b-a). 
;
; sign: 0 -> '-', 1 -> '+'
macro clip_func sign,dir,dir1,dir2
{
locals
	t dd ?
	d_X dd ?
	d_Y dd ?
	d_Z dd ?
	d_W dd ?
endl
	mov edx,[a]
	mov ebx,[b]
	mov ecx,[c]
	fld dword[ebx]
	fsub dword[edx]
	fstp dword[d_X] ;d_X = (b.X - a.X)
	fld dword[ebx+4]
	fsub dword[edx+4]
	fstp dword[d_Y] ;d_Y = (b.Y - a.Y)
	fld dword[ebx+8]
	fsub dword[edx+8]
	fstp dword[d_Z] ;d_Z = (b.Z - a.Z)
	fld dword[ebx+12]
	fsub dword[edx+12]
	fst dword[d_W] ;d_W = (b.W - a.W)
if sign eq 0
	fadd dword[d#dir]
else
	fsub dword[d#dir]
end if

	fldz
	fcomp st1
	fstsw ax
	sahf
	ja @f
		fincstp
		fst dword[t] ;t=0
		jmp .e_zero
	@@: ;else
		fincstp
		fld dword[edx+offs#dir]
if sign eq 0		
		fchs
end if
		fsub dword[edx+offs_W]
		fdiv st0,st1
		fst dword[t] ;t = ( sign a.dir - a.W) / den
	.e_zero:

	fmul dword[d#dir1] ;st0 = t * d.dir1
	fadd dword[edx+offs#dir1]
	fstp dword[ecx+offs#dir1] ;c.dir1 = a.dir1 + t * d.dir1

	fld dword[t]
	fmul dword[d#dir2] ;st0 = t * d.dir2
	fadd dword[edx+offs#dir2]
	fstp dword[ecx+offs#dir2] ;c.dir2 = a.dir2 + t * d.dir2

	fld dword[t]
	fmul dword[d_W]
	fadd dword[edx+offs_W]
	fst dword[ecx+offs_W] ;c.W = a.W + t * d_W

if sign eq 0		
		fchs
end if
	fstp dword[ecx+offs#dir] ;c.dir = sign c.W
	mov eax,[t]
}

align 4
proc clip_xmin uses ebx ecx edx, c:dword, a:dword, b:dword
	clip_func 0,_X,_Y,_Z
	ret
endp

align 4
proc clip_xmax uses ebx ecx edx, c:dword, a:dword, b:dword
	clip_func 1,_X,_Y,_Z
	ret
endp

align 4
proc clip_ymin uses ebx ecx edx, c:dword, a:dword, b:dword
	clip_func 0,_Y,_X,_Z
	ret
endp

align 4
proc clip_ymax uses ebx ecx edx, c:dword, a:dword, b:dword
	clip_func 1,_Y,_X,_Z
	ret
endp

align 4
proc clip_zmin uses ebx ecx edx, c:dword, a:dword, b:dword
	clip_func 0,_Z,_X,_Y
	ret
endp

align 4
proc clip_zmax uses ebx ecx edx, c:dword, a:dword, b:dword
	clip_func 1,_Z,_X,_Y
	ret
endp

align 4
clip_proc dd clip_xmin,clip_xmax, clip_ymin,clip_ymax, clip_zmin,clip_zmax

;static inline void updateTmp(GLContext *c, GLVertex *q,GLVertex *p0,GLVertex *p1,float t)
;{
;  if (c->current_shade_model == GL_SMOOTH) {
;    q->color.v[0]=p0->color.v[0] + (p1->color.v[0]-p0->color.v[0])*t;
;    q->color.v[1]=p0->color.v[1] + (p1->color.v[1]-p0->color.v[1])*t;
;    q->color.v[2]=p0->color.v[2] + (p1->color.v[2]-p0->color.v[2])*t;
;  } else {
;    q->color.v[0]=p0->color.v[0];
;    q->color.v[1]=p0->color.v[1];
;    q->color.v[2]=p0->color.v[2];
;  }

;  if (c->texture_2d_enabled) {
;    q->tex_coord.X=p0->tex_coord.X + (p1->tex_coord.X-p0->tex_coord.X)*t;
;    q->tex_coord.Y=p0->tex_coord.Y + (p1->tex_coord.Y-p0->tex_coord.Y)*t;
;  }

;  q->clip_code=gl_clipcode(q->pc.X,q->pc.Y,q->pc.Z,q->pc.W);
;  if (q->clip_code==0){
;    gl_transform_to_viewport(c,q);
;    RGBFtoRGBI(q->color.v[0],q->color.v[1],q->color.v[2],q->zp.r,q->zp.g,q->zp.b);
;  }
;}

;static void gl_draw_triangle_clip(GLContext *c, GLVertex *p0,GLVertex *p1,GLVertex *p2,int clip_bit);

;void gl_draw_triangle(GLContext *c, GLVertex *p0,GLVertex *p1,GLVertex *p2)
;{
;  int co,c_and,cc[3],front;
;  float norm;
;  
;  cc[0]=p0->clip_code;
;  cc[1]=p1->clip_code;
;  cc[2]=p2->clip_code;
;  
;  co=cc[0] | cc[1] | cc[2];
;
;  /* we handle the non clipped case here to go faster */
;  if (co==0) {
;    
;      norm=(float)(p1->zp.x-p0->zp.x)*(float)(p2->zp.y-p0->zp.y)-
;        (float)(p2->zp.x-p0->zp.x)*(float)(p1->zp.y-p0->zp.y);
;      
;      if (norm == 0) return;
;
;      front = norm < 0.0;
;      front = front ^ c->current_front_face;
;  
;      /* back face culling */
;      if (c->cull_face_enabled) {
;        /* most used case first */
;        if (c->current_cull_face == GL_BACK) {
;          if (front == 0) return;
;          c->draw_triangle_front(c,p0,p1,p2);
;        } else if (c->current_cull_face == GL_FRONT) {
;          if (front != 0) return;
;          c->draw_triangle_back(c,p0,p1,p2);
;        } else {
;          return;
;        }
;      } else {
;        /* no culling */
;        if (front) {
;          c->draw_triangle_front(c,p0,p1,p2);
;        } else {
;          c->draw_triangle_back(c,p0,p1,p2);
;        }
;      }
;  } else {
;    c_and=cc[0] & cc[1] & cc[2];
;    if (c_and==0) {
;      gl_draw_triangle_clip(c,p0,p1,p2,0);
;    }
;  }
;}

;static void gl_draw_triangle_clip(GLContext *c, GLVertex *p0,GLVertex *p1,GLVertex *p2,int clip_bit)
;{
;  int co,c_and,co1,cc[3],edge_flag_tmp,clip_mask;
;  GLVertex tmp1,tmp2,*q[3];
;  float tt;

;  cc[0]=p0->clip_code;
;  cc[1]=p1->clip_code;
;  cc[2]=p2->clip_code;

;  co=cc[0] | cc[1] | cc[2];
;  if (co == 0) {
;    gl_draw_triangle(c,p0,p1,p2);
;  } else {
;    c_and=cc[0] & cc[1] & cc[2];
;    /* the triangle is completely outside */
;    if (c_and!=0) return;

;    /* find the next direction to clip */
;    while (clip_bit < 6 && (co & (1 << clip_bit)) == 0)  {
;      clip_bit++;
;    }

;    /* this test can be true only in case of rounding errors */
;    if (clip_bit == 6) {
;#if 0
;      printf("Error:\n");
;      printf("%f %f %f %f\n",p0->pc.X,p0->pc.Y,p0->pc.Z,p0->pc.W);
;      printf("%f %f %f %f\n",p1->pc.X,p1->pc.Y,p1->pc.Z,p1->pc.W);
;      printf("%f %f %f %f\n",p2->pc.X,p2->pc.Y,p2->pc.Z,p2->pc.W);
;#endif
;      return;
;    }

;    clip_mask = 1 << clip_bit;
;    co1=(cc[0] ^ cc[1] ^ cc[2]) & clip_mask;

;    if (co1)  { 
;      /* one point outside */

;      if (cc[0] & clip_mask) { q[0]=p0; q[1]=p1; q[2]=p2; }
;      else if (cc[1] & clip_mask) { q[0]=p1; q[1]=p2; q[2]=p0; }
;      else { q[0]=p2; q[1]=p0; q[2]=p1; }
;      
;      tt=clip_proc[clip_bit](&tmp1.pc,&q[0]->pc,&q[1]->pc);
;      updateTmp(c,&tmp1,q[0],q[1],tt);
;
;      tt=clip_proc[clip_bit](&tmp2.pc,&q[0]->pc,&q[2]->pc);
;      updateTmp(c,&tmp2,q[0],q[2],tt);
;
;      tmp1.edge_flag=q[0]->edge_flag;
;      edge_flag_tmp=q[2]->edge_flag;
;      q[2]->edge_flag=0;
;      gl_draw_triangle_clip(c,&tmp1,q[1],q[2],clip_bit+1);
;
;      tmp2.edge_flag=0;
;      tmp1.edge_flag=0;
;      q[2]->edge_flag=edge_flag_tmp;
;      gl_draw_triangle_clip(c,&tmp2,&tmp1,q[2],clip_bit+1);
;    } else {
;      /* two points outside */

;      if ((cc[0] & clip_mask)==0) { q[0]=p0; q[1]=p1; q[2]=p2; }
;      else if ((cc[1] & clip_mask)==0) { q[0]=p1; q[1]=p2; q[2]=p0; } 
;      else { q[0]=p2; q[1]=p0; q[2]=p1; }

;      tt=clip_proc[clip_bit](&tmp1.pc,&q[0]->pc,&q[1]->pc);
;      updateTmp(c,&tmp1,q[0],q[1],tt);

;      tt=clip_proc[clip_bit](&tmp2.pc,&q[0]->pc,&q[2]->pc);
;      updateTmp(c,&tmp2,q[0],q[2],tt);

;      tmp1.edge_flag=1;
;      tmp2.edge_flag=q[2]->edge_flag;
;      gl_draw_triangle_clip(c,q[0],&tmp1,&tmp2,clip_bit+1);
;    }
;  }
;}

align 4
proc gl_draw_triangle_select uses eax, context:dword, p0:dword,p1:dword,p2:dword
	mov eax,[p2]
	push dword[eax+offs_vert_zp+offs_Z]
	mov eax,[p1]
	push dword[eax+offs_vert_zp+offs_Z]
	mov eax,[p0]
	push dword[eax+offs_vert_zp+offs_Z]
	stdcall gl_add_select1, [context] ;,p0.zp.z, p1.zp.z, p2.zp.z
	ret
endp

;#ifdef PROFILE
;int count_triangles,count_triangles_textured,count_pixels;
;#endif

align 4
proc gl_draw_triangle_fill uses eax edx, context:dword, p0:dword,p1:dword,p2:dword
;#ifdef PROFILE
;  {
;    int norm;
;    assert(p0->zp.x >= 0 && p0->zp.x < c->zb->xsize);
;    assert(p0->zp.y >= 0 && p0->zp.y < c->zb->ysize);
;    assert(p1->zp.x >= 0 && p1->zp.x < c->zb->xsize);
;    assert(p1->zp.y >= 0 && p1->zp.y < c->zb->ysize);
;    assert(p2->zp.x >= 0 && p2->zp.x < c->zb->xsize);
;    assert(p2->zp.y >= 0 && p2->zp.y < c->zb->ysize);
    
;    norm=(p1->zp.x-p0->zp.x)*(p2->zp.y-p0->zp.y)-
;      (p2->zp.x-p0->zp.x)*(p1->zp.y-p0->zp.y);
;    count_pixels+=abs(norm)/2;
;    count_triangles++;
;  }
;#endif

	mov edx,[context]
	cmp dword[edx+offs_cont_texture_2d_enabled],0
	je .els_i
		;if (context.texture_2d_enabled)
;#ifdef PROFILE
;    count_triangles_textured++;
;#endif
		mov eax,dword[edx+offs_cont_current_texture]
		mov eax,[eax] ;переход по указателю
		;так как offs_text_images+offs_imag_pixmap = 0 то context.current_texture.images[0].pixmap = [eax]
		stdcall ZB_setTexture, dword[edx+offs_cont_zb],dword[eax]
;    ZB_fillTriangleMappingPerspective, dword[edx+offs_cont_zb],&p0->zp,&p1->zp,&p2->zp);
		jmp .end_f
	.els_i:
	cmp dword[edx+offs_cont_current_shade_model],GL_SMOOTH
	jne .els
		;else if (context.current_shade_model == GL_SMOOTH)
;    ZB_fillTriangleSmooth, dword[edx+offs_cont_zb],&p0->zp,&p1->zp,&p2->zp);
		jmp .end_f
	.els:
;    ZB_fillTriangleFlat, dword[edx+offs_cont_zb],&p0->zp,&p1->zp,&p2->zp);
	.end_f:
	ret
endp

; Render a clipped triangle in line mode

align 4
proc gl_draw_triangle_line uses eax ebx ecx edx, context:dword, p0:dword,p1:dword,p2:dword
	mov edx,[context]
	cmp dword[edx+offs_cont_depth_test],0
	je .els
		lea ecx,[ZB_line_z]
		jmp @f
	.els:
		lea ecx,[ZB_line]
	@@:

	;if (p0.edge_flag) ZB_line_z(context.zb,&p0.zp,&p1.zp)
	mov eax,[p0]
	cmp dword[eax+offs_vert_edge_flag],0
	je @f
		mov ebx,eax
		add ebx,offs_vert_zp
		mov eax,[p1]
		add eax,offs_vert_zp
		stdcall ecx,dword[edx+offs_cont_zb],ebx,eax
	@@:
	;if (p1.edge_flag) ZB_line_z(context.zb,&p1.zp,&p2.zp)
	mov eax,[p1]
	cmp dword[eax+offs_vert_edge_flag],0
	je @f
		mov ebx,eax
		add ebx,offs_vert_zp
		mov eax,[p2]
		add eax,offs_vert_zp
		stdcall ecx,dword[edx+offs_cont_zb],ebx,eax
	@@:
	;if (p2.edge_flag) ZB_line_z(context.zb,&p2.zp,&p0.zp);
	mov eax,[p2]
	cmp dword[eax+offs_vert_edge_flag],0
	je @f
		mov ebx,eax
		add ebx,offs_vert_zp
		mov eax,[p0]
		add eax,offs_vert_zp
		stdcall ecx,dword[edx+offs_cont_zb],ebx,eax
	@@:

	ret
endp

; Render a clipped triangle in point mode
align 4
proc gl_draw_triangle_point uses eax ebx edx, context:dword, p0:dword,p1:dword,p2:dword
	mov edx,[context]
	mov eax,[p0]
	cmp dword[eax+offs_vert_edge_flag],0
	je @f
		mov ebx,eax
		add ebx,offs_vert_zp
		stdcall ZB_plot,dword[edx+offs_cont_zb],ebx
	@@:
	add eax,[p1]
	cmp dword[eax+offs_vert_edge_flag],0
	je @f
		mov ebx,eax
		add ebx,offs_vert_zp
		stdcall ZB_plot,dword[edx+offs_cont_zb],ebx
	@@:
	add eax,[p2]
	cmp dword[eax+offs_vert_edge_flag],0
	je @f
		mov ebx,eax
		add ebx,offs_vert_zp
		stdcall ZB_plot,dword[edx+offs_cont_zb],ebx
	@@:
	ret
endp



