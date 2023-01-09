include Irvine32.inc
include macros/utils.mac
include macros/int.mac
include macros/float.mac
include macros/vector.mac


.data
xax DWORD ?
fcw WORD ?
INF EQU 1000000000
n_vertices DWORD 0
n_triangles DWORD 0
vertices DWORD 60000 DUP(?)
triangles DWORD 60000 DUP(?)
WIDTH__ EQU 480
HEIGHT EQU 360
color_buffer DWORD 172800 DUP(?)
deep_buffer DWORD 172800 DUP(?)
charLevel DWORD 64 DUP(?)
buffer DWORD 200000 DUP(?)
mm DWORD 15 DUP(?)
engine DWORD 4 DUP(?)
camera DWORD 115 DUP(?)
keyboard DWORD 11 DUP(?)
player DWORD 49 DUP(?)
terrain DWORD 12008 DUP(?)


.code
fsqrt__ PROC USES esi edi
	local x:DWORD, ret_0:DWORD
	ffsqrt x, x
	vpmov ret_0, x, 1
	jmp end_fsqrt__
	end_fsqrt__:
	ret
fsqrt__ ENDP


fabs__ PROC USES esi edi
	local x:DWORD, ret_0:DWORD
	ffabs x, x
	vpmov ret_0, x, 1
	jmp end_fabs__
	end_fabs__:
	ret
fabs__ ENDP


sin PROC USES esi edi
	local x:DWORD, ret_0:DWORD
	ffld x
	fsin
	fstp x
	vpmov ret_0, x, 1
	jmp end_sin
	end_sin:
	ret
sin ENDP


cos PROC USES esi edi
	local x:DWORD, ret_0:DWORD
	ffld x
	fcos
	fstp x
	vpmov ret_0, x, 1
	jmp end_cos
	end_cos:
	ret
cos ENDP


rand PROC USES esi edi
	local x:DWORD, y:DWORD, ret_0:DWORD, ri:DWORD, mean:DWORD, reg_float_1:DWORD, reg_float_2:DWORD, reg_float_3:DWORD
	call Random32
	mov ri, eax
	ffadd x, y, reg_float_1
	ffdiv reg_float_1, 1073741824, reg_float_1
	vvmov mean, reg_float_1, 1
	ifmov reg_float_1, ri
	ffadd reg_float_1, 1056964608, reg_float_2
	ffdiv reg_float_2, 1325400064, reg_float_2
	ffdiv reg_float_2, 1073741824, reg_float_2
	ffsub y, x, reg_float_3
	ffmul reg_float_2, reg_float_3, reg_float_2
	ffadd x, y, reg_float_3
	ffdiv reg_float_3, 1073741824, reg_float_3
	ffadd reg_float_2, reg_float_3, reg_float_2
	vpmov ret_0, reg_float_2, 1
	jmp end_rand
	end_rand:
	ret
rand ENDP


min2i PROC USES esi edi
	local x:DWORD, y:DWORD, ret_0:DWORD
	iicmp x, y
	jnl L2
	vpmov ret_0, x, 1
	jmp end_min2i
	L2:
	L1:
	vpmov ret_0, y, 1
	jmp end_min2i
	end_min2i:
	ret
min2i ENDP


max2i PROC USES esi edi
	local x:DWORD, y:DWORD, ret_0:DWORD
	iicmp x, y
	jng L4
	vpmov ret_0, x, 1
	jmp end_max2i
	L4:
	L3:
	vpmov ret_0, y, 1
	jmp end_max2i
	end_max2i:
	ret
max2i ENDP


min2f PROC USES esi edi
	local x:DWORD, y:DWORD, ret_0:DWORD, reg_int_1:DWORD
	ffcmp x, y
	jnb L6
	fimov reg_int_1, x
	vpmov ret_0, x, 1
	jmp end_min2f
	L6:
	L5:
	vpmov ret_0, y, 1
	jmp end_min2f
	end_min2f:
	ret
min2f ENDP


max2f PROC USES esi edi
	local x:DWORD, y:DWORD, ret_0:DWORD, reg_int_1:DWORD
	ffcmp x, y
	jna L8
	fimov reg_int_1, x
	vpmov ret_0, x, 1
	jmp end_max2f
	L8:
	L7:
	vpmov ret_0, y, 1
	jmp end_max2f
	end_max2f:
	ret
max2f ENDP


min3i PROC USES esi edi
	local x:DWORD, y:DWORD, z:DWORD, ret_0:DWORD
	iicmp x, y
	jnl L10
	iicmp x, z
	jnl L10
	vpmov ret_0, x, 1
	jmp end_min3i
	jmp L9
	L10:
	iicmp y, z
	jnl L11
	vpmov ret_0, y, 1
	jmp end_min3i
	jmp L9
	L11:
	vpmov ret_0, z, 1
	jmp end_min3i
	L9:
	end_min3i:
	ret
min3i ENDP


max3i PROC USES esi edi
	local x:DWORD, y:DWORD, z:DWORD, ret_0:DWORD
	iicmp x, y
	jng L13
	iicmp x, z
	jng L13
	vpmov ret_0, x, 1
	jmp end_max3i
	jmp L12
	L13:
	iicmp y, z
	jng L14
	vpmov ret_0, y, 1
	jmp end_max3i
	jmp L12
	L14:
	vpmov ret_0, z, 1
	jmp end_max3i
	L12:
	end_max3i:
	ret
max3i ENDP


Vec2__init PROC USES esi edi
	local x:DWORD, y:DWORD, self:DWORD
	mov esi, self
	vvmov [esi+0], x, 1
	mov esi, self
	vvmov [esi+4], y, 1
	end_Vec2__init:
	ret
Vec2__init ENDP


Vec2__add PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_Vec2_1[2]:DWORD
	mov esi, self
	mov edi, other
	ffadd [esi+0], [edi+0], reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, self
	mov edi, other
	ffadd [esi+4], [edi+4], reg_float_1
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_Vec2_1
	call Vec2__init
	vpmov ret_0, reg_Vec2_1, 2
	jmp end_Vec2__add
	end_Vec2__add:
	ret
Vec2__add ENDP


Vec2__sub PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_Vec2_1[2]:DWORD
	mov esi, self
	mov edi, other
	ffsub [esi+0], [edi+0], reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, self
	mov edi, other
	ffsub [esi+4], [edi+4], reg_float_1
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_Vec2_1
	call Vec2__init
	vpmov ret_0, reg_Vec2_1, 2
	jmp end_Vec2__sub
	end_Vec2__sub:
	ret
Vec2__sub ENDP


Vec2__mulc PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_Vec2_1[2]:DWORD
	mov esi, self
	ffmul [esi+0], other, reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, self
	ffmul [esi+4], other, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_Vec2_1
	call Vec2__init
	vpmov ret_0, reg_Vec2_1, 2
	jmp end_Vec2__mulc
	end_Vec2__mulc:
	ret
Vec2__mulc ENDP


Vec2__length PROC USES esi edi
	local self:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_float_2:DWORD
	mov esi, self
	ffmul [esi+0], [esi+0], reg_float_1
	mov esi, self
	ffmul [esi+4], [esi+4], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-12], reg_float_1, 1
	plea [esp-16], reg_float_1
	call fsqrt__
	vpmov ret_0, reg_float_1, 1
	jmp end_Vec2__length
	end_Vec2__length:
	ret
Vec2__length ENDP


Vec2__dot PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_float_2:DWORD
	mov esi, self
	mov edi, other
	ffmul [esi+0], [edi+0], reg_float_1
	mov esi, self
	mov edi, other
	ffmul [esi+4], [edi+4], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vpmov ret_0, reg_float_1, 1
	jmp end_Vec2__dot
	end_Vec2__dot:
	ret
Vec2__dot ENDP


Vec2__norm PROC USES esi edi
	local self:DWORD, ret_0:DWORD, l:DWORD, reg_float_1:DWORD, reg_Vec2_1[2]:DWORD
	iimov [esp-12], self
	plea [esp-16], reg_float_1
	call Vec2__length
	vvmov l, reg_float_1, 1
	mov esi, self
	ffdiv [esi+0], l, reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, self
	ffdiv [esi+4], l, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_Vec2_1
	call Vec2__init
	vpmov ret_0, reg_Vec2_1, 2
	jmp end_Vec2__norm
	end_Vec2__norm:
	ret
Vec2__norm ENDP


Vec2__print PROC USES esi edi
	local self:DWORD
	mov esi, self
	printFloat [esi+0]
	mov esi, self
	printFloat [esi+4]
	printEndl
	end_Vec2__print:
	ret
Vec2__print ENDP


Vec3__init PROC USES esi edi
	local x:DWORD, y:DWORD, z:DWORD, self:DWORD
	mov esi, self
	vvmov [esi+0], x, 1
	mov esi, self
	vvmov [esi+4], y, 1
	mov esi, self
	vvmov [esi+8], z, 1
	end_Vec3__init:
	ret
Vec3__init ENDP


Vec3__add PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_Vec3_1[3]:DWORD
	mov esi, self
	mov edi, other
	ffadd [esi+0], [edi+0], reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, self
	mov edi, other
	ffadd [esi+4], [edi+4], reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, self
	mov edi, other
	ffadd [esi+8], [edi+8], reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Vec3__add
	end_Vec3__add:
	ret
Vec3__add ENDP


Vec3__sub PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_Vec3_1[3]:DWORD
	mov esi, self
	mov edi, other
	ffsub [esi+0], [edi+0], reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, self
	mov edi, other
	ffsub [esi+4], [edi+4], reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, self
	mov edi, other
	ffsub [esi+8], [edi+8], reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Vec3__sub
	end_Vec3__sub:
	ret
Vec3__sub ENDP


Vec3__mul PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_Vec3_1[3]:DWORD
	mov esi, self
	mov edi, other
	ffmul [esi+0], [edi+0], reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, self
	mov edi, other
	ffmul [esi+4], [edi+4], reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, self
	mov edi, other
	ffmul [esi+8], [edi+8], reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Vec3__mul
	end_Vec3__mul:
	ret
Vec3__mul ENDP


Vec3__mulc PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_Vec3_1[3]:DWORD
	mov esi, self
	ffmul [esi+0], other, reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, self
	ffmul [esi+4], other, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, self
	ffmul [esi+8], other, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Vec3__mulc
	end_Vec3__mulc:
	ret
Vec3__mulc ENDP


Vec3__length PROC USES esi edi
	local self:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_float_2:DWORD
	mov esi, self
	ffmul [esi+0], [esi+0], reg_float_1
	mov esi, self
	ffmul [esi+4], [esi+4], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	mov esi, self
	ffmul [esi+8], [esi+8], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-12], reg_float_1, 1
	plea [esp-16], reg_float_1
	call fsqrt__
	vpmov ret_0, reg_float_1, 1
	jmp end_Vec3__length
	end_Vec3__length:
	ret
Vec3__length ENDP


Vec3__dot PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_float_2:DWORD
	mov esi, self
	mov edi, other
	ffmul [esi+0], [edi+0], reg_float_1
	mov esi, self
	mov edi, other
	ffmul [esi+4], [edi+4], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	mov esi, self
	mov edi, other
	ffmul [esi+8], [edi+8], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vpmov ret_0, reg_float_1, 1
	jmp end_Vec3__dot
	end_Vec3__dot:
	ret
Vec3__dot ENDP


Vec3__cross PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_float_2:DWORD, reg_Vec3_1[3]:DWORD
	mov esi, self
	mov edi, other
	ffmul [esi+4], [edi+8], reg_float_1
	mov esi, other
	mov edi, self
	ffmul [esi+4], [edi+8], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, other
	mov edi, self
	ffmul [esi+0], [edi+8], reg_float_1
	mov esi, self
	mov edi, other
	ffmul [esi+0], [edi+8], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, self
	mov edi, other
	ffmul [esi+0], [edi+4], reg_float_1
	mov esi, other
	mov edi, self
	ffmul [esi+0], [edi+4], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Vec3__cross
	end_Vec3__cross:
	ret
Vec3__cross ENDP


Vec3__toVec2 PROC USES esi edi
	local self:DWORD, ret_0:DWORD, reg_Vec2_1[2]:DWORD
	mov esi, self
	vvmov [esp-12], [esi+0], 1
	mov esi, self
	vvmov [esp-16], [esi+4], 1
	plea [esp-20], reg_Vec2_1
	call Vec2__init
	vpmov ret_0, reg_Vec2_1, 2
	jmp end_Vec3__toVec2
	end_Vec3__toVec2:
	ret
Vec3__toVec2 ENDP


Vec3__norm PROC USES esi edi
	local self:DWORD, ret_0:DWORD, l:DWORD, reg_float_1:DWORD, reg_Vec3_1[3]:DWORD
	iimov [esp-12], self
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov l, reg_float_1, 1
	mov esi, self
	ffdiv [esi+0], l, reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, self
	ffdiv [esi+4], l, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, self
	ffdiv [esi+8], l, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Vec3__norm
	end_Vec3__norm:
	ret
Vec3__norm ENDP


Vec3__print PROC USES esi edi
	local self:DWORD
	mov esi, self
	printFloat [esi+0]
	mov esi, self
	printFloat [esi+4]
	mov esi, self
	printFloat [esi+8]
	printEndl
	end_Vec3__print:
	ret
Vec3__print ENDP


Vec3_zero PROC USES esi edi
	local ret_0:DWORD, reg_Vec3_1[3]:DWORD
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Vec3_zero
	end_Vec3_zero:
	ret
Vec3_zero ENDP


Vec3_one PROC USES esi edi
	local ret_0:DWORD, reg_Vec3_1[3]:DWORD
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], 1065353216, 1
	vvmov [esp-20], 1065353216, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Vec3_one
	end_Vec3_one:
	ret
Vec3_one ENDP


Matrix3__init PROC USES esi edi
	local u:DWORD, v:DWORD, w:DWORD, self:DWORD
	mov esi, self
	pvmov [esi+0], u, 3
	mov esi, self
	pvmov [esi+12], v, 3
	mov esi, self
	pvmov [esi+24], w, 3
	end_Matrix3__init:
	ret
Matrix3__init ENDP


Matrix3__transform PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_Vec3_1[3]:DWORD
	mov esi, self
	plea [esp-12], [esi+0]
	iimov [esp-16], other
	plea [esp-20], reg_float_1
	call Vec3__dot
	vvmov [esp-12], reg_float_1, 1
	add esp, -12
	mov esi, self
	plea [esp-12], [esi+12]
	iimov [esp-16], other
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -12
	vvmov [esp-16], reg_float_1, 1
	add esp, -16
	mov esi, self
	plea [esp-12], [esi+24]
	iimov [esp-16], other
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -16
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Matrix3__transform
	end_Matrix3__transform:
	ret
Matrix3__transform ENDP


Matrix3__transpose PROC USES esi edi
	local self:DWORD, ret_0:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD, reg_Vec3_3[3]:DWORD, reg_Matrix3_1[9]:DWORD
	mov esi, self
	vvmov [esp-12], [esi+0], 1
	mov esi, self
	vvmov [esp-16], [esi+12], 1
	mov esi, self
	vvmov [esp-20], [esi+24], 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	add esp, -12
	mov esi, self
	vvmov [esp-12], [esi+4], 1
	mov esi, self
	vvmov [esp-16], [esi+16], 1
	mov esi, self
	vvmov [esp-20], [esi+28], 1
	plea [esp-24], reg_Vec3_2
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_2
	add esp, -16
	mov esi, self
	vvmov [esp-12], [esi+8], 1
	mov esi, self
	vvmov [esp-16], [esi+20], 1
	mov esi, self
	vvmov [esp-20], [esi+32], 1
	plea [esp-24], reg_Vec3_3
	call Vec3__init
	sub esp, -16
	plea [esp-20], reg_Vec3_3
	plea [esp-24], reg_Matrix3_1
	call Matrix3__init
	vpmov ret_0, reg_Matrix3_1, 9
	jmp end_Matrix3__transpose
	end_Matrix3__transpose:
	ret
Matrix3__transpose ENDP


Matrix3__mul PROC USES esi edi
	local self:DWORD, other:DWORD, ret_0:DWORD, ot[9]:DWORD, reg_Matrix3_1[9]:DWORD, reg_float_1:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD, reg_Vec3_3[3]:DWORD
	iimov [esp-12], other
	plea [esp-16], reg_Matrix3_1
	call Matrix3__transpose
	vvmov ot, reg_Matrix3_1, 9
	mov esi, self
	plea [esp-12], [esi+0]
	lea esi, ot
	plea [esp-16], [esi+0]
	plea [esp-20], reg_float_1
	call Vec3__dot
	vvmov [esp-12], reg_float_1, 1
	add esp, -12
	mov esi, self
	plea [esp-12], [esi+0]
	lea esi, ot
	plea [esp-16], [esi+12]
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -12
	vvmov [esp-16], reg_float_1, 1
	add esp, -16
	mov esi, self
	plea [esp-12], [esi+0]
	lea esi, ot
	plea [esp-16], [esi+24]
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -16
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	add esp, -12
	mov esi, self
	plea [esp-12], [esi+12]
	lea esi, ot
	plea [esp-16], [esi+0]
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -12
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	add esp, -24
	mov esi, self
	plea [esp-12], [esi+12]
	lea esi, ot
	plea [esp-16], [esi+12]
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -24
	vvmov [esp-16], reg_float_1, 1
	add esp, -28
	mov esi, self
	plea [esp-12], [esi+12]
	lea esi, ot
	plea [esp-16], [esi+24]
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -28
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_2
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_2
	add esp, -16
	mov esi, self
	plea [esp-12], [esi+24]
	lea esi, ot
	plea [esp-16], [esi+0]
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -16
	add esp, -16
	vvmov [esp-12], reg_float_1, 1
	add esp, -28
	mov esi, self
	plea [esp-12], [esi+24]
	lea esi, ot
	plea [esp-16], [esi+12]
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -28
	vvmov [esp-16], reg_float_1, 1
	add esp, -32
	mov esi, self
	plea [esp-12], [esi+24]
	lea esi, ot
	plea [esp-16], [esi+24]
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -32
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_3
	call Vec3__init
	sub esp, -16
	plea [esp-20], reg_Vec3_3
	plea [esp-24], reg_Matrix3_1
	call Matrix3__init
	vpmov ret_0, reg_Matrix3_1, 9
	jmp end_Matrix3__mul
	end_Matrix3__mul:
	ret
Matrix3__mul ENDP


Matrix3__inv PROC USES esi edi
	local self:DWORD, ret_0:DWORD, det:DWORD, reg_float_1:DWORD, reg_float_2:DWORD, reg_float_3:DWORD, invdet:DWORD, inv[9]:DWORD
	mov esi, self
	ffmul [esi+16], [esi+32], reg_float_1
	mov esi, self
	ffmul [esi+28], [esi+20], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	mov esi, self
	ffmul [esi+0], reg_float_1, reg_float_1
	mov esi, self
	ffmul [esi+12], [esi+32], reg_float_2
	mov esi, self
	ffmul [esi+20], [esi+24], reg_float_3
	ffsub reg_float_2, reg_float_3, reg_float_2
	mov esi, self
	ffmul [esi+4], reg_float_2, reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	mov esi, self
	ffmul [esi+12], [esi+28], reg_float_2
	mov esi, self
	ffmul [esi+16], [esi+24], reg_float_3
	ffsub reg_float_2, reg_float_3, reg_float_2
	mov esi, self
	ffmul [esi+8], reg_float_2, reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vvmov det, reg_float_1, 1
	ffdiv 1065353216, det, reg_float_1
	vvmov invdet, reg_float_1, 1
	mov esi, self
	ffmul [esi+16], [esi+32], reg_float_1
	mov esi, self
	ffmul [esi+28], [esi+20], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	ffmul reg_float_1, invdet, reg_float_1
	lea esi, inv
	vvmov [esi+0], reg_float_1, 1
	mov esi, self
	ffmul [esi+8], [esi+28], reg_float_1
	mov esi, self
	ffmul [esi+4], [esi+32], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	ffmul reg_float_1, invdet, reg_float_1
	lea esi, inv
	vvmov [esi+4], reg_float_1, 1
	mov esi, self
	ffmul [esi+4], [esi+20], reg_float_1
	mov esi, self
	ffmul [esi+8], [esi+16], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	ffmul reg_float_1, invdet, reg_float_1
	lea esi, inv
	vvmov [esi+8], reg_float_1, 1
	mov esi, self
	ffmul [esi+20], [esi+24], reg_float_1
	mov esi, self
	ffmul [esi+12], [esi+32], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	ffmul reg_float_1, invdet, reg_float_1
	lea esi, inv
	vvmov [esi+12], reg_float_1, 1
	mov esi, self
	ffmul [esi+0], [esi+32], reg_float_1
	mov esi, self
	ffmul [esi+8], [esi+24], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	ffmul reg_float_1, invdet, reg_float_1
	lea esi, inv
	vvmov [esi+16], reg_float_1, 1
	mov esi, self
	ffmul [esi+12], [esi+8], reg_float_1
	mov esi, self
	ffmul [esi+0], [esi+20], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	ffmul reg_float_1, invdet, reg_float_1
	lea esi, inv
	vvmov [esi+20], reg_float_1, 1
	mov esi, self
	ffmul [esi+12], [esi+28], reg_float_1
	mov esi, self
	ffmul [esi+24], [esi+16], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	ffmul reg_float_1, invdet, reg_float_1
	lea esi, inv
	vvmov [esi+24], reg_float_1, 1
	mov esi, self
	ffmul [esi+24], [esi+4], reg_float_1
	mov esi, self
	ffmul [esi+0], [esi+28], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	ffmul reg_float_1, invdet, reg_float_1
	lea esi, inv
	vvmov [esi+28], reg_float_1, 1
	mov esi, self
	ffmul [esi+0], [esi+16], reg_float_1
	mov esi, self
	ffmul [esi+12], [esi+4], reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	ffmul reg_float_1, invdet, reg_float_1
	lea esi, inv
	vvmov [esi+32], reg_float_1, 1
	vpmov ret_0, inv, 9
	jmp end_Matrix3__inv
	end_Matrix3__inv:
	ret
Matrix3__inv ENDP


Matrix3__print PROC USES esi edi
	local self:DWORD
	mov esi, self
	plea [esp-12], [esi+0]
	call Vec3__print
	mov esi, self
	plea [esp-12], [esi+12]
	call Vec3__print
	mov esi, self
	plea [esp-12], [esi+24]
	call Vec3__print
	printEndl
	end_Matrix3__print:
	ret
Matrix3__print ENDP


Matrix3_identity PROC USES esi edi
	local ret_0:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD, reg_Vec3_3[3]:DWORD, reg_Matrix3_1[9]:DWORD
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 1065353216, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_2
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_2
	add esp, -16
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 1065353216, 1
	plea [esp-24], reg_Vec3_3
	call Vec3__init
	sub esp, -16
	plea [esp-20], reg_Vec3_3
	plea [esp-24], reg_Matrix3_1
	call Matrix3__init
	vpmov ret_0, reg_Matrix3_1, 9
	jmp end_Matrix3_identity
	end_Matrix3_identity:
	ret
Matrix3_identity ENDP


AngleAxis__init PROC USES esi edi
	local axis:DWORD, angle:DWORD, self:DWORD
	mov esi, self
	pvmov [esi+0], axis, 3
	mov esi, self
	vvmov [esi+12], angle, 1
	end_AngleAxis__init:
	ret
AngleAxis__init ENDP


AngleAxis__rotate PROC USES esi edi
	local self:DWORD, v:DWORD, ret_0:DWORD, reg_float_1:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD, reg_Vec3_3[3]:DWORD, reg_float_2:DWORD
	iimov [esp-12], v
	add esp, -12
	mov esi, self
	vvmov [esp-12], [esi+12], 1
	plea [esp-16], reg_float_1
	call cos
	sub esp, -12
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_Vec3_1
	call Vec3__mulc
	mov esi, self
	plea [esp-12], [esi+0]
	iimov [esp-16], v
	plea [esp-20], reg_Vec3_2
	call Vec3__cross
	plea [esp-12], reg_Vec3_2
	add esp, -12
	mov esi, self
	vvmov [esp-12], [esi+12], 1
	plea [esp-16], reg_float_1
	call sin
	sub esp, -12
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_Vec3_3
	call Vec3__mulc
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_3
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	mov esi, self
	plea [esp-12], [esi+0]
	add esp, -12
	mov esi, self
	vvmov [esp-12], [esi+12], 1
	plea [esp-16], reg_float_1
	call cos
	sub esp, -12
	add esp, -12
	mov esi, self
	plea [esp-12], [esi+0]
	iimov [esp-16], v
	plea [esp-20], reg_float_2
	call Vec3__dot
	sub esp, -12
	ffmul reg_float_1, reg_float_2, reg_float_1
	ffsub 1065353216, reg_float_1, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_Vec3_3
	call Vec3__mulc
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_3
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_AngleAxis__rotate
	end_AngleAxis__rotate:
	ret
AngleAxis__rotate ENDP


Triangle__init PROC USES esi edi
	local p0:DWORD, p1:DWORD, p2:DWORD, self:DWORD, reg_int_1:DWORD
	iiadd p0, n_vertices, reg_int_1
	mov esi, self
	vvmov [esi+0], reg_int_1, 1
	iiadd p1, n_vertices, reg_int_1
	mov esi, self
	vvmov [esi+4], reg_int_1, 1
	iiadd p2, n_vertices, reg_int_1
	mov esi, self
	vvmov [esi+8], reg_int_1, 1
	end_Triangle__init:
	ret
Triangle__init ENDP


rayPlaneIntersect PROC USES esi edi
	local p0:DWORD, p1:DWORD, P:DWORD, N:DWORD, ret_0:DWORD, ret_1:DWORD, dir[3]:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD, NdotRayDirection:DWORD, reg_float_1:DWORD, reg_int_1:DWORD, t:DWORD
	iimov [esp-12], p1
	iimov [esp-16], p0
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_2
	call Vec3__norm
	vvmov dir, reg_Vec3_2, 3
	iimov [esp-12], N
	plea [esp-16], dir
	plea [esp-20], reg_float_1
	call Vec3__dot
	vvmov NdotRayDirection, reg_float_1, 1
	vvmov [esp-12], NdotRayDirection, 1
	plea [esp-16], reg_float_1
	call fabs__
	ffcmp reg_float_1, 897988541
	jnb L16
	fimov reg_int_1, reg_float_1
	vpmov ret_0, 1315859240, 1
	jmp end_rayPlaneIntersect
	L16:
	L15:
	iimov [esp-12], N
	add esp, -12
	iimov [esp-12], P
	iimov [esp-16], p0
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_float_1
	call Vec3__dot
	ffdiv reg_float_1, NdotRayDirection, reg_float_1
	vvmov t, reg_float_1, 1
	vpmov ret_0, t, 1
	plea [esp-12], dir
	vvmov [esp-16], t, 1
	plea [esp-20], reg_Vec3_1
	call Vec3__mulc
	iimov [esp-12], p0
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vpmov ret_1, reg_Vec3_1, 3
	jmp end_rayPlaneIntersect
	end_rayPlaneIntersect:
	ret
rayPlaneIntersect ENDP


rayPlaneDist PROC USES esi edi
	local p0:DWORD, p1:DWORD, P:DWORD, N:DWORD, ret_0:DWORD, dir[3]:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD, NdotRayDirection:DWORD, reg_float_1:DWORD, reg_int_1:DWORD
	iimov [esp-12], p1
	iimov [esp-16], p0
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_2
	call Vec3__norm
	vvmov dir, reg_Vec3_2, 3
	iimov [esp-12], N
	plea [esp-16], dir
	plea [esp-20], reg_float_1
	call Vec3__dot
	vvmov NdotRayDirection, reg_float_1, 1
	vvmov [esp-12], NdotRayDirection, 1
	plea [esp-16], reg_float_1
	call fabs__
	ffcmp reg_float_1, 897988541
	jnb L18
	fimov reg_int_1, reg_float_1
	vpmov ret_0, 1315859240, 1
	jmp end_rayPlaneDist
	L18:
	L17:
	iimov [esp-12], N
	add esp, -12
	iimov [esp-12], P
	iimov [esp-16], p0
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_float_1
	call Vec3__dot
	ffdiv reg_float_1, NdotRayDirection, reg_float_1
	vpmov ret_0, reg_float_1, 1
	jmp end_rayPlaneDist
	end_rayPlaneDist:
	ret
rayPlaneDist ENDP


deg2rad PROC USES esi edi
	local deg:DWORD, ret_0:DWORD, reg_float_1:DWORD
	ffmul deg, 1078530010, reg_float_1
	ffdiv reg_float_1, 1127481344, reg_float_1
	vpmov ret_0, reg_float_1, 1
	jmp end_deg2rad
	end_deg2rad:
	ret
deg2rad ENDP


axisAngle2Matrix PROC USES esi edi
	local v:DWORD, angle:DWORD, ret_0:DWORD, reg_float_1:DWORD, x:DWORD, y:DWORD, z:DWORD, c__:DWORD, s:DWORD, t:DWORD, reg_float_2:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD
	local reg_Vec3_3[3]:DWORD, reg_Matrix3_1[9]:DWORD
	vvmov [esp-12], angle, 1
	plea [esp-16], reg_float_1
	call deg2rad
	vvmov angle, reg_float_1, 1
	mov esi, v
	vvmov x, [esi+0], 1
	mov esi, v
	vvmov y, [esi+4], 1
	mov esi, v
	vvmov z, [esi+8], 1
	vvmov [esp-12], angle, 1
	plea [esp-16], reg_float_1
	call cos
	vvmov c__, reg_float_1, 1
	vvmov [esp-12], angle, 1
	plea [esp-16], reg_float_1
	call sin
	vvmov s, reg_float_1, 1
	ffsub 1065353216, c__, reg_float_1
	vvmov t, reg_float_1, 1
	ffmul t, x, reg_float_1
	ffmul reg_float_1, x, reg_float_1
	ffadd reg_float_1, c__, reg_float_1
	vvmov [esp-12], reg_float_1, 1
	ffmul t, x, reg_float_1
	ffmul reg_float_1, y, reg_float_1
	ffmul z, s, reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	ffmul t, x, reg_float_1
	ffmul reg_float_1, z, reg_float_1
	ffmul y, s, reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	ffmul t, x, reg_float_1
	ffmul reg_float_1, y, reg_float_1
	ffmul z, s, reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	ffmul t, y, reg_float_1
	ffmul reg_float_1, y, reg_float_1
	ffadd reg_float_1, c__, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	ffmul t, y, reg_float_1
	ffmul reg_float_1, z, reg_float_1
	ffmul x, s, reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_2
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_2
	ffmul t, x, reg_float_1
	ffmul reg_float_1, z, reg_float_1
	ffmul y, s, reg_float_2
	ffsub reg_float_1, reg_float_2, reg_float_1
	add esp, -16
	vvmov [esp-12], reg_float_1, 1
	ffmul t, y, reg_float_1
	ffmul reg_float_1, z, reg_float_1
	ffmul x, s, reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	ffmul t, z, reg_float_1
	ffmul reg_float_1, z, reg_float_1
	ffadd reg_float_1, c__, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_3
	call Vec3__init
	sub esp, -16
	plea [esp-20], reg_Vec3_3
	plea [esp-24], reg_Matrix3_1
	call Matrix3__init
	vpmov ret_0, reg_Matrix3_1, 9
	jmp end_axisAngle2Matrix
	end_axisAngle2Matrix:
	ret
axisAngle2Matrix ENDP


ModelManager__init PROC USES esi edi
	local self:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD, reg_Vec3_3[3]:DWORD, reg_Matrix3_1[9]:DWORD
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+0], reg_Vec3_1, 3
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 1065353216, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_2
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_2
	add esp, -16
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 1065353216, 1
	plea [esp-24], reg_Vec3_3
	call Vec3__init
	sub esp, -16
	plea [esp-20], reg_Vec3_3
	plea [esp-24], reg_Matrix3_1
	call Matrix3__init
	mov esi, self
	vvmov [esi+12], reg_Matrix3_1, 9
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], 1065353216, 1
	vvmov [esp-20], 1065353216, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+48], reg_Vec3_1, 3
	end_ModelManager__init:
	ret
ModelManager__init ENDP


ModelManager__reset PROC USES esi edi
	local self:DWORD
	vvmov n_vertices, 0, 1
	vvmov n_triangles, 0, 1
	end_ModelManager__reset:
	ret
ModelManager__reset ENDP


ModelManager__set_transform PROC USES esi edi
	local self:DWORD, pos:DWORD, rot:DWORD, scale:DWORD
	mov esi, self
	pvmov [esi+0], pos, 3
	mov esi, self
	pvmov [esi+12], rot, 9
	mov esi, self
	pvmov [esi+48], scale, 3
	end_ModelManager__set_transform:
	ret
ModelManager__set_transform ENDP


ModelManager__add_vertex PROC USES esi edi
	local self:DWORD, v:DWORD, reg_int_1:DWORD, reg_Vec3_1[3]:DWORD
	iimul n_vertices, 12, reg_int_1
	mov esi, self
	plea [esp-12], [esi+12]
	add esp, -12
	iimov [esp-12], v
	mov esi, self
	plea [esp-16], [esi+48]
	plea [esp-20], reg_Vec3_1
	call Vec3__mul
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Matrix3__transform
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+0]
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	lea esi, vertices
	add esi, reg_int_1
	vvmov [esi+0], reg_Vec3_1, 3
	iiadd n_vertices, 1, reg_int_1
	vvmov n_vertices, reg_int_1, 1
	end_ModelManager__add_vertex:
	ret
ModelManager__add_vertex ENDP


ModelManager__add_triangle PROC USES esi edi
	local self:DWORD, t:DWORD, reg_int_1:DWORD
	iimul n_triangles, 12, reg_int_1
	lea esi, triangles
	add esi, reg_int_1
	pvmov [esi+0], t, 3
	iiadd n_triangles, 1, reg_int_1
	vvmov n_triangles, reg_int_1, 1
	end_ModelManager__add_triangle:
	ret
ModelManager__add_triangle ENDP


ModelManager__add_pyramid PROC USES esi edi
	local self:DWORD, pos:DWORD, w:DWORD, h:DWORD, r:DWORD, reg_float_1:DWORD, reg_Triangle_1[3]:DWORD, reg_Vec3_1[3]:DWORD
	ffdiv w, 1073741824, reg_float_1
	vvmov r, reg_float_1, 1
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 1, 1
	vvmov [esp-20], 2, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 2, 1
	vvmov [esp-20], 3, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 3, 1
	vvmov [esp-20], 4, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 4, 1
	vvmov [esp-20], 1, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	mov esi, pos
	vvmov [esp-12], [esi+0], 1
	mov esi, pos
	vvmov [esp-16], [esi+4], 1
	mov esi, pos
	ffadd [esi+8], h, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffadd [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffadd [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	vvmov [esp-20], [esi+8], 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffadd [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffsub [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	vvmov [esp-20], [esi+8], 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffsub [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffsub [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	vvmov [esp-20], [esi+8], 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffsub [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffadd [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	vvmov [esp-20], [esi+8], 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	end_ModelManager__add_pyramid:
	ret
ModelManager__add_pyramid ENDP


ModelManager__add_box PROC USES esi edi
	local self:DWORD, pos:DWORD, w:DWORD, h:DWORD, r:DWORD, reg_float_1:DWORD, reg_Triangle_1[3]:DWORD, reg_Vec3_1[3]:DWORD
	ffdiv w, 1073741824, reg_float_1
	vvmov r, reg_float_1, 1
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 1, 1
	vvmov [esp-20], 2, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 2, 1
	vvmov [esp-20], 3, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 4, 1
	vvmov [esp-16], 7, 1
	vvmov [esp-20], 6, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 5, 1
	vvmov [esp-16], 4, 1
	vvmov [esp-20], 6, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 2, 1
	vvmov [esp-16], 6, 1
	vvmov [esp-20], 7, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 7, 1
	vvmov [esp-16], 3, 1
	vvmov [esp-20], 2, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1, 1
	vvmov [esp-16], 5, 1
	vvmov [esp-20], 6, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1, 1
	vvmov [esp-16], 6, 1
	vvmov [esp-20], 2, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 4, 1
	vvmov [esp-20], 5, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 5, 1
	vvmov [esp-20], 1, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 7, 1
	vvmov [esp-20], 4, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 3, 1
	vvmov [esp-20], 7, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	mov esi, pos
	ffadd [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffadd [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	vvmov [esp-20], [esi+8], 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffsub [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffadd [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	vvmov [esp-20], [esi+8], 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffsub [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffsub [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	vvmov [esp-20], [esi+8], 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffadd [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffsub [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	vvmov [esp-20], [esi+8], 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffadd [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffadd [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	ffadd [esi+8], h, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffsub [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffadd [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	ffadd [esi+8], h, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffsub [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffsub [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	ffadd [esi+8], h, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffadd [esi+0], r, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffsub [esi+4], r, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, pos
	ffadd [esi+8], h, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	end_ModelManager__add_box:
	ret
ModelManager__add_box ENDP


ModelManager__add_plane PROC USES esi edi
	local self:DWORD, pos:DWORD, siz:DWORD, reg_Triangle_1[3]:DWORD, reg_float_1:DWORD, reg_Vec3_1[3]:DWORD
	vvmov siz, 1161527296, 1
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 1, 1
	vvmov [esp-20], 2, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 2, 1
	vvmov [esp-20], 3, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	mov esi, pos
	ffadd [esi+0], siz, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffadd [esi+4], siz, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffadd [esi+0], siz, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffsub [esi+4], siz, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffsub [esi+0], siz, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffsub [esi+4], siz, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	mov esi, pos
	ffsub [esi+0], siz, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	mov esi, pos
	ffadd [esi+4], siz, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	end_ModelManager__add_plane:
	ret
ModelManager__add_plane ENDP


ModelManager__add_spaceship PROC USES esi edi
	local self:DWORD, reg_Triangle_1[3]:DWORD, reg_Vec3_1[3]:DWORD
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 1, 1
	vvmov [esp-20], 2, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 3, 1
	vvmov [esp-20], 1, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 4, 1
	vvmov [esp-16], 5, 1
	vvmov [esp-20], 6, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 4, 1
	vvmov [esp-16], 7, 1
	vvmov [esp-20], 5, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 8, 1
	vvmov [esp-16], 9, 1
	vvmov [esp-20], 10, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 8, 1
	vvmov [esp-16], 11, 1
	vvmov [esp-20], 9, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 10, 1
	vvmov [esp-16], 7, 1
	vvmov [esp-20], 12, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 10, 1
	vvmov [esp-16], 9, 1
	vvmov [esp-20], 7, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 6, 1
	vvmov [esp-16], 13, 1
	vvmov [esp-20], 14, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 6, 1
	vvmov [esp-16], 5, 1
	vvmov [esp-20], 13, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 14, 1
	vvmov [esp-16], 15, 1
	vvmov [esp-20], 1, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1, 1
	vvmov [esp-16], 16, 1
	vvmov [esp-20], 14, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1, 1
	vvmov [esp-16], 17, 1
	vvmov [esp-20], 16, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 18, 1
	vvmov [esp-16], 19, 1
	vvmov [esp-20], 12, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 18, 1
	vvmov [esp-16], 20, 1
	vvmov [esp-20], 19, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 10, 1
	vvmov [esp-20], 3, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 8, 1
	vvmov [esp-20], 10, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 18, 1
	vvmov [esp-16], 6, 1
	vvmov [esp-20], 21, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 18, 1
	vvmov [esp-16], 4, 1
	vvmov [esp-20], 6, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 15, 1
	vvmov [esp-16], 22, 1
	vvmov [esp-20], 23, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 15, 1
	vvmov [esp-16], 24, 1
	vvmov [esp-20], 22, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1, 1
	vvmov [esp-16], 23, 1
	vvmov [esp-20], 2, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1, 1
	vvmov [esp-16], 15, 1
	vvmov [esp-20], 23, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 13, 1
	vvmov [esp-16], 15, 1
	vvmov [esp-20], 14, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 13, 1
	vvmov [esp-16], 24, 1
	vvmov [esp-20], 15, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 11, 1
	vvmov [esp-16], 25, 1
	vvmov [esp-20], 9, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 11, 1
	vvmov [esp-16], 26, 1
	vvmov [esp-20], 25, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 24, 1
	vvmov [esp-16], 27, 1
	vvmov [esp-20], 22, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 24, 1
	vvmov [esp-16], 28, 1
	vvmov [esp-20], 27, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 9, 1
	vvmov [esp-16], 29, 1
	vvmov [esp-20], 13, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 9, 1
	vvmov [esp-16], 25, 1
	vvmov [esp-20], 29, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 13, 1
	vvmov [esp-16], 28, 1
	vvmov [esp-20], 24, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 13, 1
	vvmov [esp-16], 29, 1
	vvmov [esp-20], 28, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 25, 1
	vvmov [esp-16], 30, 1
	vvmov [esp-20], 29, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 25, 1
	vvmov [esp-16], 31, 1
	vvmov [esp-20], 30, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 26, 1
	vvmov [esp-16], 31, 1
	vvmov [esp-20], 25, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 26, 1
	vvmov [esp-16], 32, 1
	vvmov [esp-20], 31, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 29, 1
	vvmov [esp-16], 30, 1
	vvmov [esp-20], 28, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 28, 1
	vvmov [esp-16], 33, 1
	vvmov [esp-20], 27, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 28, 1
	vvmov [esp-16], 30, 1
	vvmov [esp-20], 33, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 30, 1
	vvmov [esp-16], 32, 1
	vvmov [esp-20], 33, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 30, 1
	vvmov [esp-16], 31, 1
	vvmov [esp-20], 32, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 13, 1
	vvmov [esp-16], 34, 1
	vvmov [esp-20], 9, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 13, 1
	vvmov [esp-16], 35, 1
	vvmov [esp-20], 34, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 7, 1
	vvmov [esp-16], 36, 1
	vvmov [esp-20], 5, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 7, 1
	vvmov [esp-16], 37, 1
	vvmov [esp-20], 36, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 9, 1
	vvmov [esp-16], 37, 1
	vvmov [esp-20], 7, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 9, 1
	vvmov [esp-16], 34, 1
	vvmov [esp-20], 37, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 5, 1
	vvmov [esp-16], 35, 1
	vvmov [esp-20], 13, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 5, 1
	vvmov [esp-16], 36, 1
	vvmov [esp-20], 35, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 35, 1
	vvmov [esp-16], 38, 1
	vvmov [esp-20], 34, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 35, 1
	vvmov [esp-16], 39, 1
	vvmov [esp-20], 38, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 37, 1
	vvmov [esp-16], 40, 1
	vvmov [esp-20], 36, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 37, 1
	vvmov [esp-16], 41, 1
	vvmov [esp-20], 40, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 34, 1
	vvmov [esp-16], 41, 1
	vvmov [esp-20], 37, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 34, 1
	vvmov [esp-16], 38, 1
	vvmov [esp-20], 41, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 36, 1
	vvmov [esp-16], 39, 1
	vvmov [esp-20], 35, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 36, 1
	vvmov [esp-16], 40, 1
	vvmov [esp-20], 39, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 42, 1
	vvmov [esp-16], 16, 1
	vvmov [esp-20], 17, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 42, 1
	vvmov [esp-16], 43, 1
	vvmov [esp-20], 16, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 14, 1
	vvmov [esp-16], 43, 1
	vvmov [esp-20], 6, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 14, 1
	vvmov [esp-16], 16, 1
	vvmov [esp-20], 43, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 21, 1
	vvmov [esp-16], 44, 1
	vvmov [esp-20], 42, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 21, 1
	vvmov [esp-16], 45, 1
	vvmov [esp-20], 44, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 46, 1
	vvmov [esp-16], 19, 1
	vvmov [esp-20], 20, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 46, 1
	vvmov [esp-16], 47, 1
	vvmov [esp-20], 19, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 10, 1
	vvmov [esp-16], 46, 1
	vvmov [esp-20], 3, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 10, 1
	vvmov [esp-16], 47, 1
	vvmov [esp-20], 46, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 12, 1
	vvmov [esp-16], 47, 1
	vvmov [esp-20], 10, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 12, 1
	vvmov [esp-16], 19, 1
	vvmov [esp-20], 47, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 17, 1
	vvmov [esp-16], 48, 1
	vvmov [esp-20], 42, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 17, 1
	vvmov [esp-16], 49, 1
	vvmov [esp-20], 48, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 3, 1
	vvmov [esp-16], 50, 1
	vvmov [esp-20], 1, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 3, 1
	vvmov [esp-16], 51, 1
	vvmov [esp-20], 50, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 46, 1
	vvmov [esp-16], 51, 1
	vvmov [esp-20], 3, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 46, 1
	vvmov [esp-16], 52, 1
	vvmov [esp-20], 51, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 20, 1
	vvmov [esp-16], 52, 1
	vvmov [esp-20], 46, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 20, 1
	vvmov [esp-16], 53, 1
	vvmov [esp-20], 52, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1, 1
	vvmov [esp-16], 49, 1
	vvmov [esp-20], 17, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1, 1
	vvmov [esp-16], 50, 1
	vvmov [esp-20], 49, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 21, 1
	vvmov [esp-16], 54, 1
	vvmov [esp-20], 18, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 21, 1
	vvmov [esp-16], 55, 1
	vvmov [esp-20], 54, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 18, 1
	vvmov [esp-16], 53, 1
	vvmov [esp-20], 20, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 18, 1
	vvmov [esp-16], 54, 1
	vvmov [esp-20], 53, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 42, 1
	vvmov [esp-16], 55, 1
	vvmov [esp-20], 21, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 42, 1
	vvmov [esp-16], 48, 1
	vvmov [esp-20], 55, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 54, 1
	vvmov [esp-16], 56, 1
	vvmov [esp-20], 53, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 54, 1
	vvmov [esp-16], 57, 1
	vvmov [esp-20], 56, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 48, 1
	vvmov [esp-16], 58, 1
	vvmov [esp-20], 55, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 48, 1
	vvmov [esp-16], 59, 1
	vvmov [esp-20], 58, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 49, 1
	vvmov [esp-16], 59, 1
	vvmov [esp-20], 48, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 49, 1
	vvmov [esp-16], 60, 1
	vvmov [esp-20], 59, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 55, 1
	vvmov [esp-16], 57, 1
	vvmov [esp-20], 54, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 55, 1
	vvmov [esp-16], 58, 1
	vvmov [esp-20], 57, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 52, 1
	vvmov [esp-16], 61, 1
	vvmov [esp-20], 51, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 52, 1
	vvmov [esp-16], 62, 1
	vvmov [esp-20], 61, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 53, 1
	vvmov [esp-16], 62, 1
	vvmov [esp-20], 52, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 53, 1
	vvmov [esp-16], 56, 1
	vvmov [esp-20], 62, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 50, 1
	vvmov [esp-16], 60, 1
	vvmov [esp-20], 49, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 50, 1
	vvmov [esp-16], 63, 1
	vvmov [esp-20], 60, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 51, 1
	vvmov [esp-16], 63, 1
	vvmov [esp-20], 50, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 51, 1
	vvmov [esp-16], 61, 1
	vvmov [esp-20], 63, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 62, 1
	vvmov [esp-16], 64, 1
	vvmov [esp-20], 61, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 62, 1
	vvmov [esp-16], 65, 1
	vvmov [esp-20], 64, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 56, 1
	vvmov [esp-16], 65, 1
	vvmov [esp-20], 62, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 56, 1
	vvmov [esp-16], 66, 1
	vvmov [esp-20], 65, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 63, 1
	vvmov [esp-16], 67, 1
	vvmov [esp-20], 60, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 63, 1
	vvmov [esp-16], 68, 1
	vvmov [esp-20], 67, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 61, 1
	vvmov [esp-16], 68, 1
	vvmov [esp-20], 63, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 61, 1
	vvmov [esp-16], 64, 1
	vvmov [esp-20], 68, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 57, 1
	vvmov [esp-16], 66, 1
	vvmov [esp-20], 56, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 57, 1
	vvmov [esp-16], 69, 1
	vvmov [esp-20], 66, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 59, 1
	vvmov [esp-16], 70, 1
	vvmov [esp-20], 58, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 59, 1
	vvmov [esp-16], 71, 1
	vvmov [esp-20], 70, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 60, 1
	vvmov [esp-16], 71, 1
	vvmov [esp-20], 59, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 60, 1
	vvmov [esp-16], 67, 1
	vvmov [esp-20], 71, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 58, 1
	vvmov [esp-16], 69, 1
	vvmov [esp-20], 57, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 58, 1
	vvmov [esp-16], 70, 1
	vvmov [esp-20], 69, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 12, 1
	vvmov [esp-16], 72, 1
	vvmov [esp-20], 18, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 12, 1
	vvmov [esp-16], 73, 1
	vvmov [esp-20], 72, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 18, 1
	vvmov [esp-16], 72, 1
	vvmov [esp-20], 4, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 7, 1
	vvmov [esp-16], 73, 1
	vvmov [esp-20], 12, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 7, 1
	vvmov [esp-16], 74, 1
	vvmov [esp-20], 73, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 4, 1
	vvmov [esp-16], 74, 1
	vvmov [esp-20], 7, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 75, 1
	vvmov [esp-16], 76, 1
	vvmov [esp-20], 77, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 75, 1
	vvmov [esp-16], 78, 1
	vvmov [esp-20], 76, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 79, 1
	vvmov [esp-16], 78, 1
	vvmov [esp-20], 75, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 79, 1
	vvmov [esp-16], 80, 1
	vvmov [esp-20], 78, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 77, 1
	vvmov [esp-16], 81, 1
	vvmov [esp-20], 82, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 77, 1
	vvmov [esp-16], 76, 1
	vvmov [esp-20], 81, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 82, 1
	vvmov [esp-16], 80, 1
	vvmov [esp-20], 79, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 82, 1
	vvmov [esp-16], 81, 1
	vvmov [esp-20], 80, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 78, 1
	vvmov [esp-16], 81, 1
	vvmov [esp-20], 76, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 78, 1
	vvmov [esp-16], 80, 1
	vvmov [esp-20], 81, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 74, 1
	vvmov [esp-16], 79, 1
	vvmov [esp-20], 73, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 74, 1
	vvmov [esp-16], 82, 1
	vvmov [esp-20], 79, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 4, 1
	vvmov [esp-16], 82, 1
	vvmov [esp-20], 74, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 4, 1
	vvmov [esp-16], 77, 1
	vvmov [esp-20], 82, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 73, 1
	vvmov [esp-16], 75, 1
	vvmov [esp-20], 72, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 73, 1
	vvmov [esp-16], 79, 1
	vvmov [esp-20], 75, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 72, 1
	vvmov [esp-16], 77, 1
	vvmov [esp-20], 4, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 72, 1
	vvmov [esp-16], 75, 1
	vvmov [esp-20], 77, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 6, 1
	vvmov [esp-16], 45, 1
	vvmov [esp-20], 21, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 6, 1
	vvmov [esp-16], 83, 1
	vvmov [esp-20], 45, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 43, 1
	vvmov [esp-16], 83, 1
	vvmov [esp-20], 6, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 43, 1
	vvmov [esp-16], 84, 1
	vvmov [esp-20], 83, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 42, 1
	vvmov [esp-16], 84, 1
	vvmov [esp-20], 43, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 42, 1
	vvmov [esp-16], 44, 1
	vvmov [esp-20], 84, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 45, 1
	vvmov [esp-16], 85, 1
	vvmov [esp-20], 44, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 45, 1
	vvmov [esp-16], 86, 1
	vvmov [esp-20], 85, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 84, 1
	vvmov [esp-16], 87, 1
	vvmov [esp-20], 83, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 84, 1
	vvmov [esp-16], 88, 1
	vvmov [esp-20], 87, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 44, 1
	vvmov [esp-16], 88, 1
	vvmov [esp-20], 84, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 44, 1
	vvmov [esp-16], 85, 1
	vvmov [esp-20], 88, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 83, 1
	vvmov [esp-16], 86, 1
	vvmov [esp-20], 45, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 83, 1
	vvmov [esp-16], 87, 1
	vvmov [esp-20], 86, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 86, 1
	vvmov [esp-16], 89, 1
	vvmov [esp-20], 85, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 86, 1
	vvmov [esp-16], 90, 1
	vvmov [esp-20], 89, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 88, 1
	vvmov [esp-16], 91, 1
	vvmov [esp-20], 87, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 88, 1
	vvmov [esp-16], 92, 1
	vvmov [esp-20], 91, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 85, 1
	vvmov [esp-16], 92, 1
	vvmov [esp-20], 88, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 85, 1
	vvmov [esp-16], 89, 1
	vvmov [esp-20], 92, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 87, 1
	vvmov [esp-16], 90, 1
	vvmov [esp-20], 86, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 87, 1
	vvmov [esp-16], 91, 1
	vvmov [esp-20], 90, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 91, 1
	vvmov [esp-16], 89, 1
	vvmov [esp-20], 90, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 91, 1
	vvmov [esp-16], 92, 1
	vvmov [esp-20], 89, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 69, 1
	vvmov [esp-16], 65, 1
	vvmov [esp-20], 66, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 69, 1
	vvmov [esp-16], 64, 1
	vvmov [esp-20], 65, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 69, 1
	vvmov [esp-16], 68, 1
	vvmov [esp-20], 64, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 69, 1
	vvmov [esp-16], 67, 1
	vvmov [esp-20], 68, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 69, 1
	vvmov [esp-16], 71, 1
	vvmov [esp-20], 67, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 69, 1
	vvmov [esp-16], 70, 1
	vvmov [esp-20], 71, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 41, 1
	vvmov [esp-16], 39, 1
	vvmov [esp-20], 40, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 41, 1
	vvmov [esp-16], 38, 1
	vvmov [esp-20], 39, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 93, 1
	vvmov [esp-20], 94, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 2, 1
	vvmov [esp-20], 93, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 95, 1
	vvmov [esp-16], 96, 1
	vvmov [esp-20], 97, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 95, 1
	vvmov [esp-16], 98, 1
	vvmov [esp-20], 96, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 8, 1
	vvmov [esp-16], 99, 1
	vvmov [esp-20], 11, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 8, 1
	vvmov [esp-16], 100, 1
	vvmov [esp-20], 99, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 100, 1
	vvmov [esp-16], 97, 1
	vvmov [esp-20], 99, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 100, 1
	vvmov [esp-16], 101, 1
	vvmov [esp-20], 97, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 98, 1
	vvmov [esp-16], 102, 1
	vvmov [esp-20], 96, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 98, 1
	vvmov [esp-16], 103, 1
	vvmov [esp-20], 102, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 103, 1
	vvmov [esp-16], 93, 1
	vvmov [esp-20], 104, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 93, 1
	vvmov [esp-16], 105, 1
	vvmov [esp-20], 106, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 93, 1
	vvmov [esp-16], 103, 1
	vvmov [esp-20], 105, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 107, 1
	vvmov [esp-16], 108, 1
	vvmov [esp-20], 109, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 107, 1
	vvmov [esp-16], 101, 1
	vvmov [esp-20], 108, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 100, 1
	vvmov [esp-20], 8, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 94, 1
	vvmov [esp-20], 100, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 107, 1
	vvmov [esp-16], 98, 1
	vvmov [esp-20], 95, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 107, 1
	vvmov [esp-16], 110, 1
	vvmov [esp-20], 98, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 104, 1
	vvmov [esp-16], 22, 1
	vvmov [esp-20], 111, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 104, 1
	vvmov [esp-16], 23, 1
	vvmov [esp-20], 22, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 93, 1
	vvmov [esp-16], 23, 1
	vvmov [esp-20], 104, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 93, 1
	vvmov [esp-16], 2, 1
	vvmov [esp-20], 23, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 102, 1
	vvmov [esp-16], 104, 1
	vvmov [esp-20], 111, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 102, 1
	vvmov [esp-16], 103, 1
	vvmov [esp-20], 104, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 11, 1
	vvmov [esp-16], 112, 1
	vvmov [esp-20], 26, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 11, 1
	vvmov [esp-16], 99, 1
	vvmov [esp-20], 112, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 111, 1
	vvmov [esp-16], 27, 1
	vvmov [esp-20], 113, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 111, 1
	vvmov [esp-16], 22, 1
	vvmov [esp-20], 27, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 99, 1
	vvmov [esp-16], 114, 1
	vvmov [esp-20], 112, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 99, 1
	vvmov [esp-16], 102, 1
	vvmov [esp-20], 114, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 102, 1
	vvmov [esp-16], 113, 1
	vvmov [esp-20], 114, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 102, 1
	vvmov [esp-16], 111, 1
	vvmov [esp-20], 113, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 112, 1
	vvmov [esp-16], 115, 1
	vvmov [esp-20], 116, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 112, 1
	vvmov [esp-16], 114, 1
	vvmov [esp-20], 115, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 26, 1
	vvmov [esp-16], 116, 1
	vvmov [esp-20], 32, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 26, 1
	vvmov [esp-16], 112, 1
	vvmov [esp-20], 116, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 114, 1
	vvmov [esp-16], 113, 1
	vvmov [esp-20], 115, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 113, 1
	vvmov [esp-16], 33, 1
	vvmov [esp-20], 115, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 113, 1
	vvmov [esp-16], 27, 1
	vvmov [esp-20], 33, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 115, 1
	vvmov [esp-16], 32, 1
	vvmov [esp-20], 116, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 115, 1
	vvmov [esp-16], 33, 1
	vvmov [esp-20], 32, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 102, 1
	vvmov [esp-16], 117, 1
	vvmov [esp-20], 118, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 102, 1
	vvmov [esp-16], 99, 1
	vvmov [esp-20], 117, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 97, 1
	vvmov [esp-16], 119, 1
	vvmov [esp-20], 120, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 97, 1
	vvmov [esp-16], 96, 1
	vvmov [esp-20], 119, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 99, 1
	vvmov [esp-16], 120, 1
	vvmov [esp-20], 117, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 99, 1
	vvmov [esp-16], 97, 1
	vvmov [esp-20], 120, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 96, 1
	vvmov [esp-16], 118, 1
	vvmov [esp-20], 119, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 96, 1
	vvmov [esp-16], 102, 1
	vvmov [esp-20], 118, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 118, 1
	vvmov [esp-16], 121, 1
	vvmov [esp-20], 122, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 118, 1
	vvmov [esp-16], 117, 1
	vvmov [esp-20], 121, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 120, 1
	vvmov [esp-16], 123, 1
	vvmov [esp-20], 124, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 120, 1
	vvmov [esp-16], 119, 1
	vvmov [esp-20], 123, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 117, 1
	vvmov [esp-16], 124, 1
	vvmov [esp-20], 121, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 117, 1
	vvmov [esp-16], 120, 1
	vvmov [esp-20], 124, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 119, 1
	vvmov [esp-16], 122, 1
	vvmov [esp-20], 123, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 119, 1
	vvmov [esp-16], 118, 1
	vvmov [esp-20], 122, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 125, 1
	vvmov [esp-16], 105, 1
	vvmov [esp-20], 126, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 125, 1
	vvmov [esp-16], 106, 1
	vvmov [esp-20], 105, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 103, 1
	vvmov [esp-16], 126, 1
	vvmov [esp-20], 105, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 103, 1
	vvmov [esp-16], 98, 1
	vvmov [esp-20], 126, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 110, 1
	vvmov [esp-16], 127, 1
	vvmov [esp-20], 128, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 110, 1
	vvmov [esp-16], 125, 1
	vvmov [esp-20], 127, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 129, 1
	vvmov [esp-16], 108, 1
	vvmov [esp-20], 130, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 129, 1
	vvmov [esp-16], 109, 1
	vvmov [esp-20], 108, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 100, 1
	vvmov [esp-16], 129, 1
	vvmov [esp-20], 130, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 100, 1
	vvmov [esp-16], 94, 1
	vvmov [esp-20], 129, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 101, 1
	vvmov [esp-16], 130, 1
	vvmov [esp-20], 108, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 101, 1
	vvmov [esp-16], 100, 1
	vvmov [esp-20], 130, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 106, 1
	vvmov [esp-16], 131, 1
	vvmov [esp-20], 132, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 106, 1
	vvmov [esp-16], 125, 1
	vvmov [esp-20], 131, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 94, 1
	vvmov [esp-16], 133, 1
	vvmov [esp-20], 134, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 94, 1
	vvmov [esp-16], 93, 1
	vvmov [esp-20], 133, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 129, 1
	vvmov [esp-16], 134, 1
	vvmov [esp-20], 135, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 129, 1
	vvmov [esp-16], 94, 1
	vvmov [esp-20], 134, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 109, 1
	vvmov [esp-16], 135, 1
	vvmov [esp-20], 136, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 109, 1
	vvmov [esp-16], 129, 1
	vvmov [esp-20], 135, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 93, 1
	vvmov [esp-16], 132, 1
	vvmov [esp-20], 133, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 93, 1
	vvmov [esp-16], 106, 1
	vvmov [esp-20], 132, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 110, 1
	vvmov [esp-16], 137, 1
	vvmov [esp-20], 138, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 110, 1
	vvmov [esp-16], 107, 1
	vvmov [esp-20], 137, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 107, 1
	vvmov [esp-16], 136, 1
	vvmov [esp-20], 137, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 107, 1
	vvmov [esp-16], 109, 1
	vvmov [esp-20], 136, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 125, 1
	vvmov [esp-16], 138, 1
	vvmov [esp-20], 131, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 125, 1
	vvmov [esp-16], 110, 1
	vvmov [esp-20], 138, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 137, 1
	vvmov [esp-16], 139, 1
	vvmov [esp-20], 140, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 137, 1
	vvmov [esp-16], 136, 1
	vvmov [esp-20], 139, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 131, 1
	vvmov [esp-16], 141, 1
	vvmov [esp-20], 142, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 131, 1
	vvmov [esp-16], 138, 1
	vvmov [esp-20], 141, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 132, 1
	vvmov [esp-16], 142, 1
	vvmov [esp-20], 143, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 132, 1
	vvmov [esp-16], 131, 1
	vvmov [esp-20], 142, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 138, 1
	vvmov [esp-16], 140, 1
	vvmov [esp-20], 141, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 138, 1
	vvmov [esp-16], 137, 1
	vvmov [esp-20], 140, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 135, 1
	vvmov [esp-16], 144, 1
	vvmov [esp-20], 145, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 135, 1
	vvmov [esp-16], 134, 1
	vvmov [esp-20], 144, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 136, 1
	vvmov [esp-16], 145, 1
	vvmov [esp-20], 139, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 136, 1
	vvmov [esp-16], 135, 1
	vvmov [esp-20], 145, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 133, 1
	vvmov [esp-16], 143, 1
	vvmov [esp-20], 146, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 133, 1
	vvmov [esp-16], 132, 1
	vvmov [esp-20], 143, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 134, 1
	vvmov [esp-16], 146, 1
	vvmov [esp-20], 144, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 134, 1
	vvmov [esp-16], 133, 1
	vvmov [esp-20], 146, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 145, 1
	vvmov [esp-16], 147, 1
	vvmov [esp-20], 148, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 145, 1
	vvmov [esp-16], 144, 1
	vvmov [esp-20], 147, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 139, 1
	vvmov [esp-16], 148, 1
	vvmov [esp-20], 149, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 139, 1
	vvmov [esp-16], 145, 1
	vvmov [esp-20], 148, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 146, 1
	vvmov [esp-16], 150, 1
	vvmov [esp-20], 151, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 146, 1
	vvmov [esp-16], 143, 1
	vvmov [esp-20], 150, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 144, 1
	vvmov [esp-16], 151, 1
	vvmov [esp-20], 147, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 144, 1
	vvmov [esp-16], 146, 1
	vvmov [esp-20], 151, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 140, 1
	vvmov [esp-16], 149, 1
	vvmov [esp-20], 152, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 140, 1
	vvmov [esp-16], 139, 1
	vvmov [esp-20], 149, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 142, 1
	vvmov [esp-16], 153, 1
	vvmov [esp-20], 154, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 142, 1
	vvmov [esp-16], 141, 1
	vvmov [esp-20], 153, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 143, 1
	vvmov [esp-16], 154, 1
	vvmov [esp-20], 150, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 143, 1
	vvmov [esp-16], 142, 1
	vvmov [esp-20], 154, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 141, 1
	vvmov [esp-16], 152, 1
	vvmov [esp-20], 153, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 141, 1
	vvmov [esp-16], 140, 1
	vvmov [esp-20], 152, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 101, 1
	vvmov [esp-16], 155, 1
	vvmov [esp-20], 156, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 101, 1
	vvmov [esp-16], 107, 1
	vvmov [esp-20], 155, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 107, 1
	vvmov [esp-16], 95, 1
	vvmov [esp-20], 155, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 97, 1
	vvmov [esp-16], 156, 1
	vvmov [esp-20], 157, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 97, 1
	vvmov [esp-16], 101, 1
	vvmov [esp-20], 156, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 95, 1
	vvmov [esp-16], 97, 1
	vvmov [esp-20], 157, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 158, 1
	vvmov [esp-16], 159, 1
	vvmov [esp-20], 160, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 158, 1
	vvmov [esp-16], 161, 1
	vvmov [esp-20], 159, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 162, 1
	vvmov [esp-16], 160, 1
	vvmov [esp-20], 163, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 162, 1
	vvmov [esp-16], 158, 1
	vvmov [esp-20], 160, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 161, 1
	vvmov [esp-16], 164, 1
	vvmov [esp-20], 159, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 161, 1
	vvmov [esp-16], 165, 1
	vvmov [esp-20], 164, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 165, 1
	vvmov [esp-16], 163, 1
	vvmov [esp-20], 164, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 165, 1
	vvmov [esp-16], 162, 1
	vvmov [esp-20], 163, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 160, 1
	vvmov [esp-16], 164, 1
	vvmov [esp-20], 163, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 160, 1
	vvmov [esp-16], 159, 1
	vvmov [esp-20], 164, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 157, 1
	vvmov [esp-16], 162, 1
	vvmov [esp-20], 165, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 157, 1
	vvmov [esp-16], 156, 1
	vvmov [esp-20], 162, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 95, 1
	vvmov [esp-16], 165, 1
	vvmov [esp-20], 161, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 95, 1
	vvmov [esp-16], 157, 1
	vvmov [esp-20], 165, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 156, 1
	vvmov [esp-16], 158, 1
	vvmov [esp-20], 162, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 156, 1
	vvmov [esp-16], 155, 1
	vvmov [esp-20], 158, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 155, 1
	vvmov [esp-16], 161, 1
	vvmov [esp-20], 158, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 155, 1
	vvmov [esp-16], 95, 1
	vvmov [esp-20], 161, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 98, 1
	vvmov [esp-16], 128, 1
	vvmov [esp-20], 166, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 98, 1
	vvmov [esp-16], 110, 1
	vvmov [esp-20], 128, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 126, 1
	vvmov [esp-16], 166, 1
	vvmov [esp-20], 167, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 126, 1
	vvmov [esp-16], 98, 1
	vvmov [esp-20], 166, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 125, 1
	vvmov [esp-16], 167, 1
	vvmov [esp-20], 127, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 125, 1
	vvmov [esp-16], 126, 1
	vvmov [esp-20], 167, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 128, 1
	vvmov [esp-16], 168, 1
	vvmov [esp-20], 169, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 128, 1
	vvmov [esp-16], 127, 1
	vvmov [esp-20], 168, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 167, 1
	vvmov [esp-16], 170, 1
	vvmov [esp-20], 171, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 167, 1
	vvmov [esp-16], 166, 1
	vvmov [esp-20], 170, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 127, 1
	vvmov [esp-16], 171, 1
	vvmov [esp-20], 168, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 127, 1
	vvmov [esp-16], 167, 1
	vvmov [esp-20], 171, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 166, 1
	vvmov [esp-16], 169, 1
	vvmov [esp-20], 170, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 166, 1
	vvmov [esp-16], 128, 1
	vvmov [esp-20], 169, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 169, 1
	vvmov [esp-16], 172, 1
	vvmov [esp-20], 173, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 169, 1
	vvmov [esp-16], 168, 1
	vvmov [esp-20], 172, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 171, 1
	vvmov [esp-16], 174, 1
	vvmov [esp-20], 175, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 171, 1
	vvmov [esp-16], 170, 1
	vvmov [esp-20], 174, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 168, 1
	vvmov [esp-16], 175, 1
	vvmov [esp-20], 172, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 168, 1
	vvmov [esp-16], 171, 1
	vvmov [esp-20], 175, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 170, 1
	vvmov [esp-16], 173, 1
	vvmov [esp-20], 174, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 170, 1
	vvmov [esp-16], 169, 1
	vvmov [esp-20], 173, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 174, 1
	vvmov [esp-16], 172, 1
	vvmov [esp-20], 175, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 174, 1
	vvmov [esp-16], 173, 1
	vvmov [esp-20], 172, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 152, 1
	vvmov [esp-16], 154, 1
	vvmov [esp-20], 153, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 152, 1
	vvmov [esp-16], 150, 1
	vvmov [esp-20], 154, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 152, 1
	vvmov [esp-16], 151, 1
	vvmov [esp-20], 150, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 152, 1
	vvmov [esp-16], 147, 1
	vvmov [esp-20], 151, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 152, 1
	vvmov [esp-16], 148, 1
	vvmov [esp-20], 147, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 152, 1
	vvmov [esp-16], 149, 1
	vvmov [esp-20], 148, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 124, 1
	vvmov [esp-16], 122, 1
	vvmov [esp-20], 121, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 124, 1
	vvmov [esp-16], 123, 1
	vvmov [esp-20], 122, 1
	plea [esp-24], reg_Triangle_1
	call Triangle__init
	sub esp, -12
	plea [esp-16], reg_Triangle_1
	call ModelManager__add_triangle
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -2147483648, 1
	vvmov [esp-16], -1085066445, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1094545572, 1
	vvmov [esp-16], -1111577802, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -2147483648, 1
	vvmov [esp-16], -1111577802, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1094545572, 1
	vvmov [esp-16], -1085066445, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082130432, 1
	vvmov [esp-16], -1087062934, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1081601950, 1
	vvmov [esp-16], -1111577802, 1
	vvmov [esp-20], -1093052400, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082130432, 1
	vvmov [esp-16], -1111577802, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1081601950, 1
	vvmov [esp-16], -1085066445, 1
	vvmov [esp-20], -1093052400, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -2147483648, 1
	vvmov [esp-16], -1083922239, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1088477253, 1
	vvmov [esp-16], -1085066445, 1
	vvmov [esp-20], -1085965704, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1094545572, 1
	vvmov [esp-16], -1083922239, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -2147483648, 1
	vvmov [esp-16], -1085066445, 1
	vvmov [esp-20], -1086551228, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082130432, 1
	vvmov [esp-16], -1083922239, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1088759110, 1
	vvmov [esp-16], -1111926768, 1
	vvmov [esp-20], -1085965704, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1094545572, 1
	vvmov [esp-16], -1111577802, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1094545572, 1
	vvmov [esp-16], 1043093206, 1
	vvmov [esp-20], -1174203793, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1090361334, 1
	vvmov [esp-16], 1033785206, 1
	vvmov [esp-20], 1045542679, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1090361334, 1
	vvmov [esp-16], 1033785206, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082130432, 1
	vvmov [esp-16], -1085066445, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1084301404, 1
	vvmov [esp-16], -1082482754, 1
	vvmov [esp-20], 1045542679, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1084301404, 1
	vvmov [esp-16], -1082482754, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082130432, 1
	vvmov [esp-16], -1111577802, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -2147483648, 1
	vvmov [esp-16], 1046918411, 1
	vvmov [esp-20], -1086693835, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -2147483648, 1
	vvmov [esp-16], 1043093206, 1
	vvmov [esp-20], -1174203793, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1094340890, 1
	vvmov [esp-16], 1046676819, 1
	vvmov [esp-20], -1086237494, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1096589037, 1
	vvmov [esp-16], -1085143620, 1
	vvmov [esp-20], -1074854153, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -2147483648, 1
	vvmov [esp-16], -1085143620, 1
	vvmov [esp-20], -1074814727, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -2147483648, 1
	vvmov [esp-16], -1106430552, 1
	vvmov [esp-20], -1073598798, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1101001445, 1
	vvmov [esp-16], -1106430552, 1
	vvmov [esp-20], -1073626481, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1097370855, 1
	vvmov [esp-16], -1090171752, 1
	vvmov [esp-20], -1073982577, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1110759073, 1
	vvmov [esp-16], -1087952126, 1
	vvmov [esp-20], -1070182538, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1107631800, 1
	vvmov [esp-16], -1084972492, 1
	vvmov [esp-20], -1070617906, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -2147483648, 1
	vvmov [esp-16], -1084972492, 1
	vvmov [esp-20], -1070507177, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -2147483648, 1
	vvmov [esp-16], -1087952126, 1
	vvmov [esp-20], -1070060483, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1086962270, 1
	vvmov [esp-16], -1087628326, 1
	vvmov [esp-20], -1087180374, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1087125009, 1
	vvmov [esp-16], -1099189505, 1
	vvmov [esp-20], -1087180374, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082647170, 1
	vvmov [esp-16], -1099189505, 1
	vvmov [esp-20], -1090623059, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082647170, 1
	vvmov [esp-16], -1087628326, 1
	vvmov [esp-20], -1090623059, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1086962270, 1
	vvmov [esp-16], -1087628326, 1
	vvmov [esp-20], -1098877449, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1087125009, 1
	vvmov [esp-16], -1099189505, 1
	vvmov [esp-20], -1098877449, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082647170, 1
	vvmov [esp-16], -1099182794, 1
	vvmov [esp-20], -1119389273, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082647170, 1
	vvmov [esp-16], -1087628326, 1
	vvmov [esp-20], -1119389273, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1084301404, 1
	vvmov [esp-16], 1033785206, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1084301404, 1
	vvmov [esp-16], 1033785206, 1
	vvmov [esp-20], 1045542679, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1083469254, 1
	vvmov [esp-16], 1007263783, 1
	vvmov [esp-20], 1062090047, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082962582, 1
	vvmov [esp-16], -1127804725, 1
	vvmov [esp-20], 1062090047, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1090361334, 1
	vvmov [esp-16], -1082482754, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1090361334, 1
	vvmov [esp-16], -1082482754, 1
	vvmov [esp-20], 1045542679, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1084301404, 1
	vvmov [esp-16], 1046193635, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1090361334, 1
	vvmov [esp-16], 1046193635, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1094545572, 1
	vvmov [esp-16], 961656599, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1094545572, 1
	vvmov [esp-16], -1083464221, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1090361334, 1
	vvmov [esp-16], -1081172453, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1084301404, 1
	vvmov [esp-16], -1081172453, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082130432, 1
	vvmov [esp-16], -1083464221, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082130432, 1
	vvmov [esp-16], 961656599, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1085574794, 1
	vvmov [esp-16], -1084860085, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1084314826, 1
	vvmov [esp-16], -1086745844, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1084314826, 1
	vvmov [esp-16], -1102867071, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1085574794, 1
	vvmov [esp-16], -1115121150, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1089087943, 1
	vvmov [esp-16], -1115121150, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1090347912, 1
	vvmov [esp-16], -1086745844, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1089087943, 1
	vvmov [esp-16], -1084860085, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1090347912, 1
	vvmov [esp-16], -1102867071, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1090347912, 1
	vvmov [esp-16], -1088604760, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1089087943, 1
	vvmov [esp-16], -1087492430, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1085574794, 1
	vvmov [esp-16], -1087492430, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1089087943, 1
	vvmov [esp-16], -1100511550, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1090347912, 1
	vvmov [esp-16], -1097250059, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1084314826, 1
	vvmov [esp-16], -1088604760, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1084314826, 1
	vvmov [esp-16], -1097250059, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1085574794, 1
	vvmov [esp-16], -1100511550, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082115333, 1
	vvmov [esp-16], -1085266094, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082355247, 1
	vvmov [esp-16], -1084152087, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1081600272, 1
	vvmov [esp-16], -1085031213, 1
	vvmov [esp-20], -1093052400, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1080163303, 1
	vvmov [esp-16], -1084418844, 1
	vvmov [esp-20], 1073937279, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1068115165, 1
	vvmov [esp-16], -1079631466, 1
	vvmov [esp-20], 1075107489, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1075660299, 1
	vvmov [esp-16], -1083975926, 1
	vvmov [esp-20], 1061199177, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1068153333, 1
	vvmov [esp-16], -1079297599, 1
	vvmov [esp-20], 1077423165, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1075936284, 1
	vvmov [esp-16], -1081845219, 1
	vvmov [esp-20], 1061199177, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1068175144, 1
	vvmov [esp-16], -1079107178, 1
	vvmov [esp-20], 1075107489, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1067895803, 1
	vvmov [esp-16], -1079180159, 1
	vvmov [esp-20], 1074309733, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1075320560, 1
	vvmov [esp-16], -1082204252, 1
	vvmov [esp-20], 1053535345, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082962582, 1
	vvmov [esp-16], -1127804725, 1
	vvmov [esp-20], 1057701128, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1083469254, 1
	vvmov [esp-16], 1007263783, 1
	vvmov [esp-20], 1058388994, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1083469254, 1
	vvmov [esp-16], 1007263783, 1
	vvmov [esp-20], 1065667789, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082962582, 1
	vvmov [esp-16], -1127804725, 1
	vvmov [esp-20], 1065667789, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1082962582, 1
	vvmov [esp-16], -1127804725, 1
	vvmov [esp-20], 1046207057, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1083469254, 1
	vvmov [esp-16], 1007263783, 1
	vvmov [esp-20], 1051720050, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1072014610, 1
	vvmov [esp-16], 1068376470, 1
	vvmov [esp-20], 1069549198, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1071982313, 1
	vvmov [esp-16], 1068306006, 1
	vvmov [esp-20], 1069549198, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1071982313, 1
	vvmov [esp-16], 1068306006, 1
	vvmov [esp-20], 1067776685, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], -1072014610, 1
	vvmov [esp-16], 1068376470, 1
	vvmov [esp-20], 1068054348, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1052938076, 1
	vvmov [esp-16], -1111577802, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1052938076, 1
	vvmov [esp-16], -1085066445, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], -1087062934, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065881698, 1
	vvmov [esp-16], -1111577802, 1
	vvmov [esp-20], -1093052400, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065881698, 1
	vvmov [esp-16], -1085066445, 1
	vvmov [esp-20], -1093052400, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], -1111577802, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1059006395, 1
	vvmov [esp-16], -1085066445, 1
	vvmov [esp-20], -1085965704, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1052938076, 1
	vvmov [esp-16], -1083922239, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], -1083922239, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1058724538, 1
	vvmov [esp-16], -1111926768, 1
	vvmov [esp-20], -1085965704, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1052938076, 1
	vvmov [esp-16], -1111577802, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1052938076, 1
	vvmov [esp-16], 1043093206, 1
	vvmov [esp-20], -1174203793, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1057122314, 1
	vvmov [esp-16], 1033785206, 1
	vvmov [esp-20], 1045542679, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1057122314, 1
	vvmov [esp-16], 1033785206, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], -1085066445, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1063182244, 1
	vvmov [esp-16], -1082482754, 1
	vvmov [esp-20], 1045542679, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1063182244, 1
	vvmov [esp-16], -1082482754, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], -1111577802, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1053142758, 1
	vvmov [esp-16], 1046676819, 1
	vvmov [esp-20], -1086237494, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1050894611, 1
	vvmov [esp-16], -1085143620, 1
	vvmov [esp-20], -1074854153, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1046482203, 1
	vvmov [esp-16], -1106430552, 1
	vvmov [esp-20], -1073626481, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1050112793, 1
	vvmov [esp-16], -1090171752, 1
	vvmov [esp-20], -1073982577, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1036724575, 1
	vvmov [esp-16], -1087952126, 1
	vvmov [esp-20], -1070182538, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1039851848, 1
	vvmov [esp-16], -1084972492, 1
	vvmov [esp-20], -1070617906, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1060521378, 1
	vvmov [esp-16], -1087628326, 1
	vvmov [esp-20], -1087180374, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1060356961, 1
	vvmov [esp-16], -1099189505, 1
	vvmov [esp-20], -1087180374, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064836478, 1
	vvmov [esp-16], -1099189505, 1
	vvmov [esp-20], -1090623059, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064836478, 1
	vvmov [esp-16], -1087628326, 1
	vvmov [esp-20], -1090623059, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1060521378, 1
	vvmov [esp-16], -1087628326, 1
	vvmov [esp-20], -1098877449, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1060356961, 1
	vvmov [esp-16], -1099189505, 1
	vvmov [esp-20], -1098877449, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064836478, 1
	vvmov [esp-16], -1099189505, 1
	vvmov [esp-20], -1119389273, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064836478, 1
	vvmov [esp-16], -1087628326, 1
	vvmov [esp-20], -1119389273, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1063182244, 1
	vvmov [esp-16], 1033785206, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1063182244, 1
	vvmov [esp-16], 1033785206, 1
	vvmov [esp-20], 1045542679, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064014394, 1
	vvmov [esp-16], 1007263783, 1
	vvmov [esp-20], 1062090047, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064521066, 1
	vvmov [esp-16], -1127804725, 1
	vvmov [esp-20], 1062090047, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1057122314, 1
	vvmov [esp-16], -1082482754, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1057122314, 1
	vvmov [esp-16], -1082482754, 1
	vvmov [esp-20], 1045542679, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1063182244, 1
	vvmov [esp-16], 1046193635, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1057122314, 1
	vvmov [esp-16], 1046193635, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1052938076, 1
	vvmov [esp-16], 961656599, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1052938076, 1
	vvmov [esp-16], -1083464221, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1057122314, 1
	vvmov [esp-16], -1081172453, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1063182244, 1
	vvmov [esp-16], -1081172453, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], -1083464221, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], 961656599, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1061908854, 1
	vvmov [esp-16], -1084860085, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1063168822, 1
	vvmov [esp-16], -1086745844, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1063168822, 1
	vvmov [esp-16], -1102867071, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1061908854, 1
	vvmov [esp-16], -1115121150, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1058395705, 1
	vvmov [esp-16], -1115121150, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1057135736, 1
	vvmov [esp-16], -1086745844, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1058395705, 1
	vvmov [esp-16], -1084860085, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1057135736, 1
	vvmov [esp-16], -1102867071, 1
	vvmov [esp-20], 1070408191, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1057135736, 1
	vvmov [esp-16], -1088604760, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1058395705, 1
	vvmov [esp-16], -1087492430, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1061908854, 1
	vvmov [esp-16], -1087492430, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1058395705, 1
	vvmov [esp-16], -1100511550, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1057135736, 1
	vvmov [esp-16], -1097250059, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1063168822, 1
	vvmov [esp-16], -1088604760, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1063168822, 1
	vvmov [esp-16], -1097250059, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1061908854, 1
	vvmov [esp-16], -1100511550, 1
	vvmov [esp-20], 1068573603, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065368315, 1
	vvmov [esp-16], -1085266094, 1
	vvmov [esp-20], 1067563614, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065128401, 1
	vvmov [esp-16], -1084152087, 1
	vvmov [esp-20], 1006726912, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1065883376, 1
	vvmov [esp-16], -1085031213, 1
	vvmov [esp-20], -1093052400, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1067320345, 1
	vvmov [esp-16], -1084418844, 1
	vvmov [esp-20], 1073937279, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1079368483, 1
	vvmov [esp-16], -1079631466, 1
	vvmov [esp-20], 1075107489, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1079330315, 1
	vvmov [esp-16], -1079297599, 1
	vvmov [esp-20], 1077423165, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1071823349, 1
	vvmov [esp-16], -1083975926, 1
	vvmov [esp-20], 1061199177, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1071547364, 1
	vvmov [esp-16], -1081845219, 1
	vvmov [esp-20], 1061199177, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1079308504, 1
	vvmov [esp-16], -1079107178, 1
	vvmov [esp-20], 1075107489, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1079587845, 1
	vvmov [esp-16], -1079180159, 1
	vvmov [esp-20], 1074309733, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1072163088, 1
	vvmov [esp-16], -1082204252, 1
	vvmov [esp-20], 1053535345, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064521066, 1
	vvmov [esp-16], -1127804725, 1
	vvmov [esp-20], 1057701128, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064014394, 1
	vvmov [esp-16], 1007263783, 1
	vvmov [esp-20], 1058388994, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064014394, 1
	vvmov [esp-16], 1007263783, 1
	vvmov [esp-20], 1065667789, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064521066, 1
	vvmov [esp-16], -1127804725, 1
	vvmov [esp-20], 1065667789, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064521066, 1
	vvmov [esp-16], -1127804725, 1
	vvmov [esp-20], 1046207057, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1064014394, 1
	vvmov [esp-16], 1007263783, 1
	vvmov [esp-20], 1051720050, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1075468619, 1
	vvmov [esp-16], 1068376470, 1
	vvmov [esp-20], 1069549198, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1075501335, 1
	vvmov [esp-16], 1068306006, 1
	vvmov [esp-20], 1069549198, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1075501335, 1
	vvmov [esp-16], 1068306006, 1
	vvmov [esp-20], 1067776685, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 1075468619, 1
	vvmov [esp-16], 1068376470, 1
	vvmov [esp-20], 1068054348, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	call ModelManager__add_vertex
	end_ModelManager__add_spaceship:
	ret
ModelManager__add_spaceship ENDP


build_char_level PROC USES esi edi
	local reg_int_1:DWORD
	iimul 00, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 32, 1
	iimul 01, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 46, 1
	iimul 02, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 39, 1
	iimul 03, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 45, 1
	iimul 04, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 44, 1
	iimul 05, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 58, 1
	iimul 06, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 95, 1
	iimul 07, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 34, 1
	iimul 08, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 59, 1
	iimul 09, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 60, 1
	iimul 10, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 62, 1
	iimul 11, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 47, 1
	iimul 12, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 92, 1
	iimul 13, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 33, 1
	iimul 14, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 43, 1
	iimul 15, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 42, 1
	iimul 16, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 61, 1
	iimul 17, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 94, 1
	iimul 18, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 76, 1
	iimul 19, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 74, 1
	iimul 20, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 63, 1
	iimul 21, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 84, 1
	iimul 22, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 89, 1
	iimul 23, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 40, 1
	iimul 24, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 41, 1
	iimul 25, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 55, 1
	iimul 26, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 67, 1
	iimul 27, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 70, 1
	iimul 28, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 50, 1
	iimul 29, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 49, 1
	iimul 30, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 73, 1
	iimul 31, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 51, 1
	iimul 32, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 53, 1
	iimul 33, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 90, 1
	iimul 34, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 91, 1
	iimul 35, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 93, 1
	iimul 36, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 83, 1
	iimul 37, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 86, 1
	iimul 38, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 69, 1
	iimul 39, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 65, 1
	iimul 40, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 88, 1
	iimul 41, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 80, 1
	iimul 42, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 71, 1
	iimul 43, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 79, 1
	iimul 44, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 85, 1
	iimul 45, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 52, 1
	iimul 46, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 75, 1
	iimul 47, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 37, 1
	iimul 48, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 78, 1
	iimul 49, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 72, 1
	iimul 50, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 87, 1
	iimul 51, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 35, 1
	iimul 52, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 48, 1
	iimul 53, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 77, 1
	iimul 54, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 36, 1
	iimul 55, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 68, 1
	iimul 56, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 82, 1
	iimul 57, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 57, 1
	iimul 58, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 81, 1
	iimul 59, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 54, 1
	iimul 60, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 66, 1
	iimul 61, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 64, 1
	iimul 62, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 56, 1
	iimul 63, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov [esi+0], 38, 1
	end_build_char_level:
	ret
build_char_level ENDP


push_render_buffer Macro c, p
mov eax, p
mov ebx, c
mov BYTE PTR buffer[eax], bl
inc p
ENDM
display PROC USES esi edi
	local p:DWORD, i:DWORD, j:DWORD, color:DWORD, reg_int_1:DWORD, reg_int_2:DWORD, char:DWORD
	vvmov p, 0, 1
	iimov i, 0
	L19:
	iicmp i, 360
	jnl L20
	iimov j, 0
	L22:
	iicmp j, 480
	jnl L23
	iimul i, 1920, reg_int_1
	iimul j, 4, reg_int_2
	iiadd reg_int_1, reg_int_2, reg_int_1
	lea esi, color_buffer
	add esi, reg_int_1
	vvmov color, [esi+0], 1
	iimul color, 4, reg_int_1
	lea esi, charLevel
	add esi, reg_int_1
	vvmov char, [esi+0], 1
	push_render_buffer char, p
	L24:
	iiadd j, 1, j
	jmp L22
	L23:
	push_render_buffer 10, p
	L21:
	iiadd i, 1, i
	jmp L19
	L20:
	push_render_buffer 0, p
	mov edx, OFFSET buffer
	call WriteString
	end_display:
	ret
display ENDP


clear_buffer PROC USES esi edi
	local i:DWORD, j:DWORD, reg_int_1:DWORD, reg_int_2:DWORD
	iimov i, 0
	L25:
	iicmp i, 360
	jnl L26
	iimov j, 0
	L28:
	iicmp j, 480
	jnl L29
	iimul i, 1920, reg_int_1
	iimul j, 4, reg_int_2
	iiadd reg_int_1, reg_int_2, reg_int_1
	lea esi, color_buffer
	add esi, reg_int_1
	vvmov [esi+0], 0, 1
	iimul i, 1920, reg_int_1
	iimul j, 4, reg_int_2
	iiadd reg_int_1, reg_int_2, reg_int_1
	lea esi, deep_buffer
	add esi, reg_int_1
	vvmov [esi+0], 1315859240, 1
	L30:
	iiadd j, 1, j
	jmp L28
	L29:
	L27:
	iiadd i, 1, i
	jmp L25
	L26:
	end_clear_buffer:
	ret
clear_buffer ENDP


Distortion__init PROC USES esi edi
	local pos:DWORD, siz:DWORD, type__:DWORD, self:DWORD, reg_float_1:DWORD
	mov esi, self
	pvmov [esi+0], pos, 3
	mov esi, self
	vvmov [esi+12], siz, 1
	mov esi, self
	vvmov [esi+16], 1112014848, 1
	mov esi, self
	vvmov [esi+20], 1069547520, 1
	mov esi, self
	vvmov [esi+24], type__, 1
	mov esi, self
	iicmp [esi+24], 1
	jne L32
	mov esi, self
	ffpow [esi+12], [esi+20], reg_float_1
	mov esi, self
	ffadd [esi+12], reg_float_1, reg_float_1
	mov esi, self
	vvmov [esi+16], reg_float_1, 1
	L32:
	L31:
	end_Distortion__init:
	ret
Distortion__init ENDP


Distortion__need PROC USES esi edi
	local self:DWORD, p:DWORD, ret_0:DWORD, v[3]:DWORD, reg_Vec3_1[3]:DWORD, reg_float_1:DWORD, reg_int_1:DWORD
	mov esi, self
	iicmp [esi+24], 0
	jne L34
	vpmov ret_0, 0, 1
	jmp end_Distortion__need
	jmp L33
	L34:
	mov esi, self
	iicmp [esi+24], 1
	jne L35
	mov esi, self
	plea [esp-12], [esi+0]
	iimov [esp-16], p
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	vvmov v, reg_Vec3_1, 3
	plea [esp-12], v
	plea [esp-16], reg_float_1
	call Vec3__length
	mov esi, self
	ffcmp reg_float_1, [esi+16]
	jnb L36
	mov reg_int_1, 1
	jmp L37
	L36:
	mov reg_int_1, 0
	L37:
	vpmov ret_0, reg_int_1, 1
	jmp end_Distortion__need
	jmp L33
	L35:
	mov esi, self
	iicmp [esi+24], 2
	jne L38
	iimov [esp-12], p
	mov esi, self
	plea [esp-16], [esi+0]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_float_1
	call Vec3__length
	mov esi, self
	ffsub reg_float_1, [esi+16], reg_float_1
	vvmov [esp-12], reg_float_1, 1
	plea [esp-16], reg_float_1
	call fabs__
	mov esi, self
	ffcmp reg_float_1, [esi+12]
	jnb L39
	mov reg_int_1, 1
	jmp L40
	L39:
	mov reg_int_1, 0
	L40:
	vpmov ret_0, reg_int_1, 1
	jmp end_Distortion__need
	jmp L33
	L38:
	mov esi, self
	iicmp [esi+24], 3
	jne L41
	mov esi, self
	mov edi, p
	ffsub [esi+0], [edi+0], reg_float_1
	vvmov [esp-12], reg_float_1, 1
	plea [esp-16], reg_float_1
	call fabs__
	mov esi, self
	ffcmp reg_float_1, [esi+12]
	jnb L42
	mov reg_int_1, 1
	jmp L43
	L42:
	mov reg_int_1, 0
	L43:
	vpmov ret_0, reg_int_1, 1
	jmp end_Distortion__need
	L41:
	L33:
	end_Distortion__need:
	ret
Distortion__need ENDP


Distortion__update PROC USES esi edi
	local self:DWORD, nx:DWORD, reg_float_1:DWORD, reg_Vec3_1[3]:DWORD, reg_int_1:DWORD, reg_int_2:DWORD
	mov esi, self
	iicmp [esi+24], 1
	jne L45
	lea esi, player
	ffsub [esi+20], 1120403456, reg_float_1
	mov esi, self
	ffsub reg_float_1, [esi+16], reg_float_1
	vvmov [esp-12], reg_float_1, 1
	lea esi, player
	ffmul 1063675494, [esi+0], reg_float_1
	lea esi, engine
	ffmul reg_float_1, [esi+4], reg_float_1
	mov esi, self
	ffadd [esi+0], reg_float_1, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_float_1
	call max2f
	vvmov nx, reg_float_1, 1
	vvmov [esp-12], nx, 1
	lea esi, player
	vvmov [esp-16], [esi+24], 1
	vvmov [esp-20], 1109393408, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+0], reg_Vec3_1, 3
	jmp L44
	L45:
	mov esi, self
	iicmp [esi+24], 2
	jne L46
	lea esi, engine
	ffmul 1092616192, [esi+4], reg_float_1
	mov esi, self
	ffadd [esi+16], reg_float_1, reg_float_1
	mov esi, self
	vvmov [esi+16], reg_float_1, 1
	mov esi, self
	ffcmp [esi+16], 1140457472
	jna L48
	mov esi, self
	fimov reg_int_1, [esi+16]
	mov esi, self
	vvmov [esi+24], 0, 1
	L48:
	L47:
	jmp L44
	L46:
	mov esi, self
	iicmp [esi+24], 3
	jne L49
	lea esi, engine
	ffmul 1128792064, [esi+4], reg_float_1
	mov esi, self
	ffadd [esi+0], reg_float_1, reg_float_1
	mov esi, self
	vvmov [esi+0], reg_float_1, 1
	mov esi, self
	lea edi, player
	ffsub [esi+0], [edi+20], reg_float_1
	ffcmp reg_float_1, 1148846080
	jna L51
	fimov reg_int_2, reg_float_1
	mov esi, self
	vvmov [esi+24], 0, 1
	L51:
	L50:
	L49:
	L44:
	end_Distortion__update:
	ret
Distortion__update ENDP


Distortion__distort PROC USES esi edi
	local self:DWORD, p:DWORD, ret_0:DWORD, v[3]:DWORD, reg_Vec3_1[3]:DWORD, d:DWORD, reg_float_1:DWORD, x:DWORD, reg_int_1:DWORD, reg_int_2:DWORD, k:DWORD, t:DWORD, reg_float_2:DWORD
	local reg_int_3:DWORD, h:DWORD
	mov esi, self
	iicmp [esi+24], 1
	jne L53
	mov esi, self
	plea [esp-12], [esi+0]
	iimov [esp-16], p
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	vvmov v, reg_Vec3_1, 3
	plea [esp-12], v
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov d, reg_float_1, 1
	mov esi, self
	ffpow [esi+12], [esi+20], reg_float_1
	ffsub d, reg_float_1, reg_float_1
	vvmov x, reg_float_1, 1
	iicmp 0 , x
	jnl L55
	mov esi, self
	ffcmp x, [esi+12]
	jnb L55
	fimov reg_int_1, x
	plea [esp-12], v
	mov esi, self
	ffsub [esi+12], x, reg_float_1
	mov esi, self
	ffpow reg_float_1, [esi+20], reg_float_1
	ffdiv reg_float_1, d, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_Vec3_1
	call Vec3__mulc
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Distortion__distort
	jmp L54
	L55:
	mov esi, self
	plea [esp-12], [esi+0]
	iimov [esp-16], p
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Distortion__distort
	L54:
	jmp L52
	L53:
	mov esi, self
	iicmp [esi+24], 2
	jne L56
	iimov [esp-12], p
	mov esi, self
	plea [esp-16], [esi+0]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	vvmov v, reg_Vec3_1, 3
	plea [esp-12], v
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov d, reg_float_1, 1
	mov esi, self
	ffsub d, [esi+16], reg_float_1
	vvmov x, reg_float_1, 1
	vvmov [esp-12], x, 1
	plea [esp-16], reg_float_1
	call fabs__
	mov esi, self
	ffcmp reg_float_1, [esi+12]
	jnb L58
	fimov reg_int_2, reg_float_1
	vvmov k, 1060320051, 1
	ffdiv x, 1073741824, reg_float_1
	mov esi, self
	ffdiv reg_float_1, [esi+12], reg_float_1
	ffmul reg_float_1, 1078530010, reg_float_1
	vvmov [esp-12], reg_float_1, 1
	plea [esp-16], reg_float_1
	call cos
	mov esi, self
	ffmul [esi+12], reg_float_1, reg_float_1
	ffpow reg_float_1, k, reg_float_1
	ffsub k, 1065353216, reg_float_2
	mov esi, self
	ffpow [esi+12], reg_float_2, reg_float_2
	ffdiv reg_float_1, reg_float_2, reg_float_1
	mov esi, self
	ffsub [esi+12], reg_float_1, reg_float_1
	ffmul reg_float_1, x, reg_float_1
	vvmov [esp-12], x, 1
	plea [esp-16], reg_float_2
	call fabs__
	ffdiv reg_float_1, reg_float_2, reg_float_1
	vvmov t, reg_float_1, 1
	plea [esp-12], v
	ffsub t, x, reg_float_1
	ffdiv reg_float_1, d, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_Vec3_1
	call Vec3__mulc
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Distortion__distort
	jmp L57
	L58:
	plea [esp-12], reg_Vec3_1
	call Vec3_zero
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Distortion__distort
	L57:
	jmp L52
	L56:
	mov esi, self
	iicmp [esi+24], 3
	jne L59
	mov esi, self
	mov edi, p
	ffsub [esi+0], [edi+0], reg_float_1
	vvmov x, reg_float_1, 1
	vvmov [esp-12], x, 1
	plea [esp-16], reg_float_1
	call fabs__
	mov esi, self
	ffcmp reg_float_1, [esi+12]
	jnb L61
	fimov reg_int_3, reg_float_1
	vvmov h, 1106247680, 1
	ffmul x, 1078530010, reg_float_1
	mov esi, self
	ffdiv reg_float_1, [esi+12], reg_float_1
	vvmov [esp-12], reg_float_1, 1
	plea [esp-16], reg_float_1
	call cos
	ffadd 1065353216, reg_float_1, reg_float_1
	ffmul reg_float_1, h, reg_float_1
	ffdiv reg_float_1, 1073741824, reg_float_1
	vvmov t, reg_float_1, 1
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], t, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Distortion__distort
	jmp L60
	L61:
	plea [esp-12], reg_Vec3_1
	call Vec3_zero
	vpmov ret_0, reg_Vec3_1, 3
	jmp end_Distortion__distort
	L60:
	L59:
	L52:
	end_Distortion__distort:
	ret
Distortion__distort ENDP


Camera__init PROC USES esi edi
	local self:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD, reg_Vec3_3[3]:DWORD, reg_Matrix3_1[9]:DWORD, reg_int_1:DWORD, reg_float_1:DWORD, i:DWORD
	vvmov [esp-12], -1027080192, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+0], reg_Vec3_1, 3
	vvmov [esp-12], 1109393408, 1
	vvmov [esp-16], 1106247680, 1
	vvmov [esp-20], 1109393408, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+12], reg_Vec3_1, 3
	iimov [esp-12], self
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], -1082130432, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	add esp, -12
	plea [esp-12], reg_Vec3_1
	add esp, -24
	vvmov [esp-12], -1082130432, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_2
	call Vec3__init
	sub esp, -24
	plea [esp-16], reg_Vec3_2
	add esp, -28
	vvmov [esp-12], 0, 1
	vvmov [esp-16], -1082130432, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_3
	call Vec3__init
	sub esp, -28
	plea [esp-20], reg_Vec3_3
	plea [esp-24], reg_Matrix3_1
	call Matrix3__init
	sub esp, -12
	plea [esp-16], reg_Matrix3_1
	call Camera__set_axis
	iidiv 480, 2, reg_int_1
	ifmov reg_float_1, reg_int_1
	vvmov [esp-12], reg_float_1, 1
	iidiv 360, 2, reg_int_1
	ifmov reg_float_1, reg_int_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+108], reg_Vec3_1, 3
	mov esi, self
	ffdiv 1139802112, [esi+12], reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, self
	ffdiv 1135869952, [esi+16], reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 1065353216, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+120], reg_Vec3_1, 3
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 1065353216, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_2
	call Vec3__norm
	mov esi, self
	vvmov [esi+132], reg_Vec3_2, 3
	mov esi, self
	vvmov [esi+144], 1045220557, 1
	mov esi, self
	vvmov [esi+148], 1053609165, 1
	mov esi, self
	vvmov [esi+152], 1053609165, 1
	mov esi, self
	vvmov [esi+156], 1008981770, 1
	mov esi, self
	vvmov [esi+160], 0, 1
	mov esi, self
	vvmov [esi+164], 0, 1
	mov esi, self
	vvmov [esi+168], 0, 1
	mov esi, self
	vvmov [esi+172], 0, 1
	mov esi, self
	vvmov [esi+176], 10, 1
	iimov i, 0
	L62:
	mov esi, self
	iicmp i, [esi+176]
	jnl L63
	iimul i, 28, reg_int_1
	mov esi, self
	add esi, reg_int_1
	vvmov [esi+204], 0, 1
	L64:
	iiadd i, 1, i
	jmp L62
	L63:
	end_Camera__init:
	ret
Camera__init ENDP


Camera__add_distortion PROC USES esi edi
	local self:DWORD, d:DWORD, i:DWORD, reg_int_1:DWORD, reg_int_2:DWORD
	iimov i, 0
	L65:
	mov esi, self
	iicmp i, [esi+176]
	jnl L66
	iimul i, 28, reg_int_1
	mov esi, self
	add esi, reg_int_1
	iicmp [esi+204], 0
	jne L69
	iimul i, 28, reg_int_2
	mov esi, self
	add esi, reg_int_2
	pvmov [esi+180], d, 7
	jmp end_Camera__add_distortion
	L69:
	L68:
	L67:
	iiadd i, 1, i
	jmp L65
	L66:
	end_Camera__add_distortion:
	ret
Camera__add_distortion ENDP


Camera__need_distort PROC USES esi edi
	local self:DWORD, p:DWORD, ret_0:DWORD, i:DWORD, reg_int_1:DWORD, reg_int_2:DWORD
	iimov i, 0
	L70:
	mov esi, self
	iicmp i, [esi+176]
	jnl L71
	iimul i, 28, reg_int_1
	mov esi, self
	add esi, reg_int_1
	plea [esp-12], [esi+180]
	iimov [esp-16], p
	plea [esp-20], reg_int_2
	call Distortion__need
	iicmp reg_int_2, 1
	jne L74
	vpmov ret_0, 1, 1
	jmp end_Camera__need_distort
	L74:
	L73:
	L72:
	iiadd i, 1, i
	jmp L70
	L71:
	vpmov ret_0, 0, 1
	jmp end_Camera__need_distort
	end_Camera__need_distort:
	ret
Camera__need_distort ENDP


Camera__distort PROC USES esi edi
	local self:DWORD, p:DWORD, ret_0:DWORD, r[3]:DWORD, i:DWORD, reg_int_1:DWORD, reg_int_2:DWORD, reg_Vec3_1[3]:DWORD
	pvmov r, p, 3
	iimov i, 0
	L75:
	mov esi, self
	iicmp i, [esi+176]
	jnl L76
	iimul i, 28, reg_int_1
	mov esi, self
	add esi, reg_int_1
	iicmp [esi+204], 0
	jng L79
	iimul i, 28, reg_int_2
	mov esi, self
	add esi, reg_int_2
	plea [esp-12], [esi+180]
	iimov [esp-16], p
	plea [esp-20], reg_Vec3_1
	call Distortion__distort
	plea [esp-12], r
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vvmov r, reg_Vec3_1, 3
	L79:
	L78:
	L77:
	iiadd i, 1, i
	jmp L75
	L76:
	vpmov ret_0, r, 3
	jmp end_Camera__distort
	end_Camera__distort:
	ret
Camera__distort ENDP


Camera__set_axis PROC USES esi edi
	local self:DWORD, axis:DWORD, reg_Matrix3_1[9]:DWORD, reg_Vec3_1[3]:DWORD
	mov esi, self
	pvmov [esi+36], axis, 9
	iimov [esp-12], axis
	plea [esp-16], reg_Matrix3_1
	call Matrix3__inv
	mov esi, self
	vvmov [esi+72], reg_Matrix3_1, 9
	mov esi, self
	plea [esp-12], [esi+96]
	mov esi, self
	vvmov [esp-16], [esi+20], 1
	plea [esp-20], reg_Vec3_1
	call Vec3__mulc
	mov esi, self
	plea [esp-12], [esi+0]
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	mov esi, self
	vvmov [esi+24], reg_Vec3_1, 3
	end_Camera__set_axis:
	ret
Camera__set_axis ENDP


Camera__set_inv_axis PROC USES esi edi
	local self:DWORD, inv_axis:DWORD, reg_Matrix3_1[9]:DWORD, reg_Vec3_1[3]:DWORD
	mov esi, self
	pvmov [esi+72], inv_axis, 9
	iimov [esp-12], inv_axis
	plea [esp-16], reg_Matrix3_1
	call Matrix3__inv
	mov esi, self
	vvmov [esi+36], reg_Matrix3_1, 9
	mov esi, self
	plea [esp-12], [esi+96]
	mov esi, self
	vvmov [esp-16], [esi+20], 1
	plea [esp-20], reg_Vec3_1
	call Vec3__mulc
	mov esi, self
	plea [esp-12], [esi+0]
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	mov esi, self
	vvmov [esi+24], reg_Vec3_1, 3
	end_Camera__set_inv_axis:
	ret
Camera__set_inv_axis ENDP


Camera__render PROC USES esi edi
	local self:DWORD, i:DWORD, reg_int_1:DWORD, tri[3]:DWORD, p0[3]:DWORD, p1[3]:DWORD, p2[3]:DWORD, bound__[3]:DWORD, bound_r:DWORD, reg_int_2:DWORD, reg_float_1:DWORD, bound_x:DWORD, reg_Vec3_1[3]:DWORD
	local reg_int_3:DWORD, reg_Vec3_2[3]:DWORD, reg_int_4:DWORD, reg_int_5:DWORD, reg_Vec3_3[3]:DWORD, reg_int_6:DWORD, reg_int_7:DWORD, reg_int_8:DWORD, reg_int_9:DWORD, l0:DWORD, reg_Vec3_4[3]:DWORD, l1:DWORD, l2:DWORD
	local reg_int_10:DWORD, reg_int_11:DWORD, reg_int_12:DWORD, reg_int_13:DWORD, reg_int_14:DWORD, reg_int_15:DWORD
	iimov [esp-12], self
	call Camera___shake
	iimov i, 0
	L80:
	mov esi, self
	iicmp i, [esi+176]
	jnl L81
	iimul i, 28, reg_int_1
	mov esi, self
	add esi, reg_int_1
	plea [esp-12], [esi+180]
	call Distortion__update
	L82:
	iiadd i, 1, i
	jmp L80
	L81:
	call clear_buffer
	iimov i, 0
	L83:
	iicmp i, n_triangles
	jnl L84
	iimul i, 12, reg_int_1
	lea esi, triangles
	add esi, reg_int_1
	vvmov tri, [esi+0], 3
	lea esi, tri
	iimul [esi+0], 12, reg_int_1
	lea esi, vertices
	add esi, reg_int_1
	vvmov p0, [esi+0], 3
	lea esi, tri
	iimul [esi+4], 12, reg_int_1
	lea esi, vertices
	add esi, reg_int_1
	vvmov p1, [esi+0], 3
	lea esi, tri
	iimul [esi+8], 12, reg_int_1
	lea esi, vertices
	add esi, reg_int_1
	vvmov p2, [esi+0], 3
	iimul 0, 28, reg_int_1
	mov esi, self
	add esi, reg_int_1
	vvmov bound__, [esi+180], 3
	iimul 0, 28, reg_int_1
	iimul 0, 28, reg_int_2
	mov esi, self
	add esi, reg_int_1
	ffsub [esi+196], [esi+192], reg_float_1
	vvmov bound_r, reg_float_1, 1
	lea esi, bound__
	vvmov bound_x, [esi+0], 1
	lea esi, p0
	ffcmp [esi+0], bound_x
	jb L88
	lea esi, p0
	fimov reg_int_1, [esi+0]
	plea [esp-12], p0
	plea [esp-16], bound__
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_float_1
	call Vec3__length
	ffcmp reg_float_1, bound_r
	jb L88
	fimov reg_int_2, reg_float_1
	jmp L87
	L88:
	lea esi, p1
	ffcmp [esi+0], bound_x
	jb L89
	lea esi, p1
	fimov reg_int_3, [esi+0]
	plea [esp-12], p1
	plea [esp-16], bound__
	plea [esp-20], reg_Vec3_2
	call Vec3__sub
	plea [esp-12], reg_Vec3_2
	plea [esp-16], reg_float_1
	call Vec3__length
	ffcmp reg_float_1, bound_r
	jb L89
	fimov reg_int_4, reg_float_1
	jmp L87
	L89:
	lea esi, p2
	ffcmp [esi+0], bound_x
	jb L90
	lea esi, p2
	fimov reg_int_5, [esi+0]
	plea [esp-12], p2
	plea [esp-16], bound__
	plea [esp-20], reg_Vec3_3
	call Vec3__sub
	plea [esp-12], reg_Vec3_3
	plea [esp-16], reg_float_1
	call Vec3__length
	ffcmp reg_float_1, bound_r
	jb L90
	fimov reg_int_6, reg_float_1
	jmp L87
	L90:
	jmp L85
	L87:
	L86:
	iimov [esp-12], self
	plea [esp-16], p0
	plea [esp-20], reg_int_7
	call Camera__visible
	iicmp reg_int_7, 0 
	jne L92
	iimov [esp-12], self
	plea [esp-16], p1
	plea [esp-20], reg_int_8
	call Camera__visible
	iicmp reg_int_8, 0 
	jne L92
	iimov [esp-12], self
	plea [esp-16], p2
	plea [esp-20], reg_int_9
	call Camera__visible
	iicmp reg_int_9, 0
	jne L92
	jmp L85
	L92:
	L91:
	plea [esp-12], p1
	plea [esp-16], p2
	plea [esp-20], reg_Vec3_4
	call Vec3__sub
	plea [esp-12], reg_Vec3_4
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov l0, reg_float_1, 1
	plea [esp-12], p0
	plea [esp-16], p2
	plea [esp-20], reg_Vec3_4
	call Vec3__sub
	plea [esp-12], reg_Vec3_4
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov l1, reg_float_1, 1
	plea [esp-12], p0
	plea [esp-16], p1
	plea [esp-20], reg_Vec3_4
	call Vec3__sub
	plea [esp-12], reg_Vec3_4
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov l2, reg_float_1, 1
	iimov [esp-12], self
	plea [esp-16], p0
	plea [esp-20], reg_int_10
	call Camera__need_distort
	iicmp reg_int_10, 1 
	je L94
	iimov [esp-12], self
	plea [esp-16], p1
	plea [esp-20], reg_int_11
	call Camera__need_distort
	iicmp reg_int_11, 1 
	je L94
	iimov [esp-12], self
	plea [esp-16], p2
	plea [esp-20], reg_int_12
	call Camera__need_distort
	jmp L95
	L94:
	ffcmp l0, l1
	jna L97
	fimov reg_int_13, l0
	ffcmp l0, l2
	jna L97
	fimov reg_int_14, l0
	iimov [esp-12], self
	plea [esp-16], p0
	plea [esp-20], p1
	plea [esp-24], p2
	call Camera__seperate_triangle
	jmp L96
	L97:
	ffcmp l1, l2
	jna L98
	fimov reg_int_15, l1
	iimov [esp-12], self
	plea [esp-16], p1
	plea [esp-20], p2
	plea [esp-24], p0
	call Camera__seperate_triangle
	jmp L96
	L98:
	iimov [esp-12], self
	plea [esp-16], p2
	plea [esp-20], p0
	plea [esp-24], p1
	call Camera__seperate_triangle
	L96:
	jmp L93
	L95:
	iimov [esp-12], self
	plea [esp-16], p2
	plea [esp-20], p1
	plea [esp-24], p0
	call Camera__render_triangle
	L93:
	L85:
	iiadd i, 1, i
	jmp L83
	L84:
	end_Camera__render:
	ret
Camera__render ENDP


Camera__seperate_triangle PROC USES esi edi
	local self:DWORD, p0:DWORD, p1:DWORD, p2:DWORD, p[3]:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD, reg_float_1:DWORD, reg_float_2:DWORD, reg_int_1:DWORD, reg_Vec3_3[3]:DWORD, reg_Vec3_4[3]:DWORD, reg_Vec3_5[3]:DWORD
	iimov [esp-12], p1
	iimov [esp-16], p2
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	plea [esp-12], reg_Vec3_1
	vvmov [esp-16], 1056964608, 1
	plea [esp-20], reg_Vec3_2
	call Vec3__mulc
	vvmov p, reg_Vec3_2, 3
	iimov [esp-12], p1
	iimov [esp-16], p2
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_float_1
	call Vec3__length
	plea [esp-12], p
	mov esi, self
	plea [esp-16], [esi+0]
	plea [esp-20], reg_Vec3_2
	call Vec3__sub
	plea [esp-12], reg_Vec3_2
	plea [esp-16], reg_float_2
	call Vec3__length
	mov esi, self
	ffmul reg_float_2, [esi+156], reg_float_2
	ffcmp reg_float_1, reg_float_2
	jnb L100
	fimov reg_int_1, reg_float_1
	iimov [esp-12], self
	add esp, -12
	iimov [esp-12], self
	iimov [esp-16], p2
	plea [esp-20], reg_Vec3_3
	call Camera__distort
	sub esp, -12
	plea [esp-16], reg_Vec3_3
	add esp, -16
	iimov [esp-12], self
	iimov [esp-16], p1
	plea [esp-20], reg_Vec3_4
	call Camera__distort
	sub esp, -16
	plea [esp-20], reg_Vec3_4
	add esp, -20
	iimov [esp-12], self
	iimov [esp-16], p0
	plea [esp-20], reg_Vec3_5
	call Camera__distort
	sub esp, -20
	plea [esp-24], reg_Vec3_5
	call Camera__render_triangle
	jmp L99
	L100:
	iimov [esp-12], self
	plea [esp-16], p
	iimov [esp-20], p0
	iimov [esp-24], p1
	call Camera__seperate_triangle
	iimov [esp-12], self
	plea [esp-16], p
	iimov [esp-20], p2
	iimov [esp-24], p0
	call Camera__seperate_triangle
	L99:
	end_Camera__seperate_triangle:
	ret
Camera__seperate_triangle ENDP


Camera__visible PROC USES esi edi
	local self:DWORD, p:DWORD, ret_0:DWORD, t:DWORD, gp[3]:DWORD, cp[3]:DWORD, reg_Vec3_1[3]:DWORD, x:DWORD, reg_int_1:DWORD, y:DWORD, reg_int_2:DWORD
	mov esi, self
	plea [esp-12], [esi+0]
	iimov [esp-16], p
	mov esi, self
	plea [esp-20], [esi+24]
	mov esi, self
	plea [esp-24], [esi+96]
	plea [esp-28], t
	plea [esp-32], gp
	call rayPlaneIntersect
	mov esi, self
	plea [esp-12], [esi+72]
	add esp, -12
	plea [esp-12], gp
	mov esi, self
	plea [esp-16], [esi+24]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Matrix3__transform
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+120]
	plea [esp-20], reg_Vec3_1
	call Vec3__mul
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+108]
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vvmov cp, reg_Vec3_1, 3
	lea esi, cp
	fimov reg_int_1, [esi+0]
	vvmov x, reg_int_1, 1
	lea esi, cp
	fimov reg_int_1, [esi+4]
	vvmov y, reg_int_1, 1
	iicmp x, 0 
	jl L101
	iicmp x, 480
	jnl L101
	iicmp y, 0 
	jl L101
	iicmp y, 360
	jnl L101
	ffcmp t, 0
	jna L101
	fimov reg_int_1, t
	mov reg_int_2, 1
	jmp L102
	L101:
	mov reg_int_2, 0
	L102:
	vpmov ret_0, reg_int_2, 1
	jmp end_Camera__visible
	end_Camera__visible:
	ret
Camera__visible ENDP


Camera__shake PROC USES esi edi
	local self:DWORD, magnitude:DWORD, duration:DWORD
	mov esi, self
	lea edi, engine
	vvmov [esi+160], [edi+8], 1
	mov esi, self
	vvmov [esi+164], magnitude, 1
	mov esi, self
	vvmov [esi+168], duration, 1
	end_Camera__shake:
	ret
Camera__shake ENDP


Camera___shake PROC USES esi edi
	local self:DWORD, t:DWORD, reg_float_1:DWORD, reg_int_1:DWORD, k:DWORD, reg_Vec3_1[3]:DWORD
	lea esi, engine
	mov edi, self
	ffsub [esi+8], [edi+160], reg_float_1
	vvmov t, reg_float_1, 1
	mov esi, self
	ffcmp t, [esi+168]
	ja L104
	fimov reg_int_1, t
	mov esi, self
	ffmul [esi+164], t, reg_float_1
	mov esi, self
	ffdiv reg_float_1, [esi+168], reg_float_1
	vvmov k, reg_float_1, 1
	ffsub 0, k, reg_float_1
	vvmov [esp-12], reg_float_1, 1
	vvmov [esp-16], k, 1
	plea [esp-20], reg_float_1
	call rand
	vvmov [esp-12], reg_float_1, 1
	ffsub 0, k, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	vvmov [esp-16], k, 1
	plea [esp-20], reg_float_1
	call rand
	sub esp, -12
	vvmov [esp-16], reg_float_1, 1
	ffsub 0, k, reg_float_1
	add esp, -16
	vvmov [esp-12], reg_float_1, 1
	vvmov [esp-16], k, 1
	plea [esp-20], reg_float_1
	call rand
	sub esp, -16
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	plea [esp-12], [esi+0]
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	mov esi, self
	vvmov [esi+0], reg_Vec3_1, 3
	L104:
	L103:
	end_Camera___shake:
	ret
Camera___shake ENDP


Camera__render_triangle PROC USES esi edi
	local self:DWORD, v1:DWORD, v2:DWORD, v3:DWORD, reg_int_1:DWORD, t1:DWORD, t2:DWORD, t3:DWORD, gp1[3]:DWORD, gp2[3]:DWORD, gp3[3]:DWORD, reg_int_2:DWORD, reg_int_3:DWORD
	local N[3]:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD, d1:DWORD, reg_float_1:DWORD, d2:DWORD, d3:DWORD, p1[3]:DWORD, p2[3]:DWORD, p3[3]:DWORD, wf:DWORD, reg_float_2:DWORD, reg_float_3:DWORD
	local _light:DWORD, X1:DWORD, reg_int_4:DWORD, X2:DWORD, X3:DWORD, Y1:DWORD, Y2:DWORD, Y3:DWORD, DX12:DWORD, DX23:DWORD, DX31:DWORD, DY12:DWORD, DY23:DWORD
	local DY31:DWORD, FDX12:DWORD, FDX23:DWORD, FDX31:DWORD, FDY12:DWORD, FDY23:DWORD, FDY31:DWORD, minx:DWORD, maxx:DWORD, miny:DWORD, maxy:DWORD, C1:DWORD, reg_int_5:DWORD
	local C2:DWORD, C3:DWORD, CY2:DWORD, CY1:DWORD, CY3:DWORD, y:DWORD, CX1:DWORD, CX2:DWORD, CX3:DWORD, x:DWORD, w1:DWORD, w2:DWORD, w3:DWORD
	local d:DWORD, reg_float_4:DWORD, reg_float_5:DWORD, v[3]:DWORD, h[3]:DWORD, light:DWORD, color:DWORD, reg_int_6:DWORD, reg_int_7:DWORD
	mov esi, self
	iiadd [esi+172], 3, reg_int_1
	mov esi, self
	vvmov [esi+172], reg_int_1, 1
	mov esi, self
	plea [esp-12], [esi+0]
	iimov [esp-16], v1
	mov esi, self
	plea [esp-20], [esi+24]
	mov esi, self
	plea [esp-24], [esi+96]
	plea [esp-28], t1
	plea [esp-32], gp1
	call rayPlaneIntersect
	mov esi, self
	plea [esp-12], [esi+0]
	iimov [esp-16], v2
	mov esi, self
	plea [esp-20], [esi+24]
	mov esi, self
	plea [esp-24], [esi+96]
	plea [esp-28], t2
	plea [esp-32], gp2
	call rayPlaneIntersect
	mov esi, self
	plea [esp-12], [esi+0]
	iimov [esp-16], v3
	mov esi, self
	plea [esp-20], [esi+24]
	mov esi, self
	plea [esp-24], [esi+96]
	plea [esp-28], t3
	plea [esp-32], gp3
	call rayPlaneIntersect
	ffcmp t1, 0
	jb L106
	fimov reg_int_1, t1
	ffcmp t2, 0
	jb L106
	fimov reg_int_2, t2
	ffcmp t3, 0
	jb L106
	fimov reg_int_3, t3
	jmp L107
	L106:
	jmp end_Camera__render_triangle
	L107:
	L105:
	iimov [esp-12], v2
	iimov [esp-16], v1
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	plea [esp-12], reg_Vec3_1
	add esp, -12
	iimov [esp-12], v3
	iimov [esp-16], v1
	plea [esp-20], reg_Vec3_2
	call Vec3__sub
	sub esp, -12
	plea [esp-16], reg_Vec3_2
	plea [esp-20], reg_Vec3_1
	call Vec3__cross
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_2
	call Vec3__norm
	vvmov N, reg_Vec3_2, 3
	iimov [esp-12], v1
	mov esi, self
	plea [esp-16], [esi+0]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov d1, reg_float_1, 1
	iimov [esp-12], v2
	mov esi, self
	plea [esp-16], [esi+0]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov d2, reg_float_1, 1
	iimov [esp-12], v3
	mov esi, self
	plea [esp-16], [esi+0]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov d3, reg_float_1, 1
	mov esi, self
	plea [esp-12], [esi+72]
	add esp, -12
	plea [esp-12], gp1
	mov esi, self
	plea [esp-16], [esi+24]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Matrix3__transform
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+120]
	plea [esp-20], reg_Vec3_1
	call Vec3__mul
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+108]
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vvmov p1, reg_Vec3_1, 3
	mov esi, self
	plea [esp-12], [esi+72]
	add esp, -12
	plea [esp-12], gp2
	mov esi, self
	plea [esp-16], [esi+24]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Matrix3__transform
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+120]
	plea [esp-20], reg_Vec3_1
	call Vec3__mul
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+108]
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vvmov p2, reg_Vec3_1, 3
	mov esi, self
	plea [esp-12], [esi+72]
	add esp, -12
	plea [esp-12], gp3
	mov esi, self
	plea [esp-16], [esi+24]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Matrix3__transform
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+120]
	plea [esp-20], reg_Vec3_1
	call Vec3__mul
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+108]
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vvmov p3, reg_Vec3_1, 3
	lea esi, p2
	lea edi, p3
	ffsub [esi+4], [edi+4], reg_float_1
	lea esi, p1
	lea edi, p3
	ffsub [esi+0], [edi+0], reg_float_2
	ffmul reg_float_1, reg_float_2, reg_float_1
	lea esi, p3
	lea edi, p2
	ffsub [esi+0], [edi+0], reg_float_2
	lea esi, p1
	lea edi, p3
	ffsub [esi+4], [edi+4], reg_float_3
	ffmul reg_float_2, reg_float_3, reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vvmov wf, reg_float_1, 1
	vvmov [esp-12], 0, 1
	add esp, -12
	plea [esp-12], N
	mov esi, self
	plea [esp-16], [esi+132]
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -12
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_float_1
	call max2f
	mov esi, self
	ffmul [esi+148], reg_float_1, reg_float_1
	mov esi, self
	ffadd [esi+144], reg_float_1, reg_float_1
	vvmov _light, reg_float_1, 1
	lea esi, p1
	ffmul 1098907648, [esi+0], reg_float_1
	fimov reg_int_4, reg_float_1
	vvmov X1, reg_int_4, 1
	lea esi, p2
	ffmul 1098907648, [esi+0], reg_float_1
	fimov reg_int_4, reg_float_1
	vvmov X2, reg_int_4, 1
	lea esi, p3
	ffmul 1098907648, [esi+0], reg_float_1
	fimov reg_int_4, reg_float_1
	vvmov X3, reg_int_4, 1
	lea esi, p1
	ffmul 1098907648, [esi+4], reg_float_1
	fimov reg_int_4, reg_float_1
	vvmov Y1, reg_int_4, 1
	lea esi, p2
	ffmul 1098907648, [esi+4], reg_float_1
	fimov reg_int_4, reg_float_1
	vvmov Y2, reg_int_4, 1
	lea esi, p3
	ffmul 1098907648, [esi+4], reg_float_1
	fimov reg_int_4, reg_float_1
	vvmov Y3, reg_int_4, 1
	iisub X1, X2, reg_int_4
	vvmov DX12, reg_int_4, 1
	iisub X2, X3, reg_int_4
	vvmov DX23, reg_int_4, 1
	iisub X3, X1, reg_int_4
	vvmov DX31, reg_int_4, 1
	iisub Y1, Y2, reg_int_4
	vvmov DY12, reg_int_4, 1
	iisub Y2, Y3, reg_int_4
	vvmov DY23, reg_int_4, 1
	iisub Y3, Y1, reg_int_4
	vvmov DY31, reg_int_4, 1
	iishl DX12, 4, reg_int_4
	vvmov FDX12, reg_int_4, 1
	iishl DX23, 4, reg_int_4
	vvmov FDX23, reg_int_4, 1
	iishl DX31, 4, reg_int_4
	vvmov FDX31, reg_int_4, 1
	iishl DY12, 4, reg_int_4
	vvmov FDY12, reg_int_4, 1
	iishl DY23, 4, reg_int_4
	vvmov FDY23, reg_int_4, 1
	iishl DY31, 4, reg_int_4
	vvmov FDY31, reg_int_4, 1
	vvmov [esp-12], X1, 1
	vvmov [esp-16], X2, 1
	vvmov [esp-20], X3, 1
	plea [esp-24], reg_int_4
	call min3i
	iiadd reg_int_4, 15, reg_int_4
	iishr reg_int_4, 4, reg_int_4
	vvmov minx, reg_int_4, 1
	vvmov [esp-12], X1, 1
	vvmov [esp-16], X2, 1
	vvmov [esp-20], X3, 1
	plea [esp-24], reg_int_4
	call max3i
	iiadd reg_int_4, 15, reg_int_4
	iishr reg_int_4, 4, reg_int_4
	vvmov maxx, reg_int_4, 1
	vvmov [esp-12], Y1, 1
	vvmov [esp-16], Y2, 1
	vvmov [esp-20], Y3, 1
	plea [esp-24], reg_int_4
	call min3i
	iiadd reg_int_4, 15, reg_int_4
	iishr reg_int_4, 4, reg_int_4
	vvmov miny, reg_int_4, 1
	vvmov [esp-12], Y1, 1
	vvmov [esp-16], Y2, 1
	vvmov [esp-20], Y3, 1
	plea [esp-24], reg_int_4
	call max3i
	iiadd reg_int_4, 15, reg_int_4
	iishr reg_int_4, 4, reg_int_4
	vvmov maxy, reg_int_4, 1
	vvmov [esp-12], minx, 1
	vvmov [esp-16], 0, 1
	plea [esp-20], reg_int_4
	call max2i
	vvmov minx, reg_int_4, 1
	iiadd maxx, 1, reg_int_4
	vvmov [esp-12], reg_int_4, 1
	vvmov [esp-16], 480, 1
	plea [esp-20], reg_int_4
	call min2i
	vvmov maxx, reg_int_4, 1
	vvmov [esp-12], miny, 1
	vvmov [esp-16], 0, 1
	plea [esp-20], reg_int_4
	call max2i
	vvmov miny, reg_int_4, 1
	iiadd maxy, 1, reg_int_4
	vvmov [esp-12], reg_int_4, 1
	vvmov [esp-16], 360, 1
	plea [esp-20], reg_int_4
	call min2i
	vvmov maxy, reg_int_4, 1
	iimul DY12, X1, reg_int_4
	iimul DX12, Y1, reg_int_5
	iisub reg_int_4, reg_int_5, reg_int_4
	vvmov C1, reg_int_4, 1
	iimul DY23, X2, reg_int_4
	iimul DX23, Y2, reg_int_5
	iisub reg_int_4, reg_int_5, reg_int_4
	vvmov C2, reg_int_4, 1
	iimul DY31, X3, reg_int_4
	iimul DX31, Y3, reg_int_5
	iisub reg_int_4, reg_int_5, reg_int_4
	vvmov C3, reg_int_4, 1
	iicmp DY12, 0 
	jl L109
	iicmp DY12, 0 
	jne L111
	iicmp DX12, 0
	jng L111
	jmp L111
	L109:
	iiadd C1, 1, reg_int_4
	vvmov C1, reg_int_4, 1
	L111:
	L108:
	iicmp DY23, 0 
	jl L113
	iicmp DY23, 0 
	jne L115
	iicmp DX23, 0
	jng L115
	jmp L115
	L113:
	iiadd C2, 1, reg_int_4
	vvmov C2, reg_int_4, 1
	L115:
	L112:
	iicmp DY31, 0 
	jl L117
	iicmp DY31, 0 
	jne L119
	iicmp DX31, 0
	jng L119
	jmp L119
	L117:
	iiadd C3, 1, reg_int_4
	vvmov C3, reg_int_4, 1
	L119:
	L116:
	iishl miny, 4, reg_int_4
	iimul DX23, reg_int_4, reg_int_4
	iiadd C2, reg_int_4, reg_int_4
	iishl minx, 4, reg_int_5
	iimul DY23, reg_int_5, reg_int_5
	iisub reg_int_4, reg_int_5, reg_int_4
	vvmov CY2, reg_int_4, 1
	iishl miny, 4, reg_int_4
	iimul DX12, reg_int_4, reg_int_4
	iiadd C1, reg_int_4, reg_int_4
	iishl minx, 4, reg_int_5
	iimul DY12, reg_int_5, reg_int_5
	iisub reg_int_4, reg_int_5, reg_int_4
	vvmov CY1, reg_int_4, 1
	iishl miny, 4, reg_int_4
	iimul DX31, reg_int_4, reg_int_4
	iiadd C3, reg_int_4, reg_int_4
	iishl minx, 4, reg_int_5
	iimul DY31, reg_int_5, reg_int_5
	iisub reg_int_4, reg_int_5, reg_int_4
	vvmov CY3, reg_int_4, 1
	iimov y, miny
	L120:
	iicmp y, maxy
	jnl L121
	vvmov CX1, CY1, 1
	vvmov CX2, CY2, 1
	vvmov CX3, CY3, 1
	iimov x, minx
	L123:
	iicmp x, maxx
	jnl L124
	iicmp CX1, 0 
	jng L127
	iicmp CX2, 0 
	jng L127
	iicmp CX3, 0
	jng L127
	lea esi, p2
	lea edi, p3
	ffsub [esi+4], [edi+4], reg_float_1
	ifmov reg_float_2, x
	lea esi, p3
	ffsub reg_float_2, [esi+0], reg_float_3
	ffmul reg_float_1, reg_float_3, reg_float_1
	lea esi, p3
	lea edi, p2
	ffsub [esi+0], [edi+0], reg_float_3
	ifmov reg_float_4, y
	lea esi, p3
	ffsub reg_float_4, [esi+4], reg_float_5
	ffmul reg_float_3, reg_float_5, reg_float_3
	ffadd reg_float_1, reg_float_3, reg_float_1
	ffdiv reg_float_1, wf, reg_float_1
	vvmov w1, reg_float_1, 1
	lea esi, p3
	lea edi, p1
	ffsub [esi+4], [edi+4], reg_float_1
	ifmov reg_float_2, x
	lea esi, p3
	ffsub reg_float_2, [esi+0], reg_float_3
	ffmul reg_float_1, reg_float_3, reg_float_1
	lea esi, p1
	lea edi, p3
	ffsub [esi+0], [edi+0], reg_float_3
	ifmov reg_float_4, y
	lea esi, p3
	ffsub reg_float_4, [esi+4], reg_float_5
	ffmul reg_float_3, reg_float_5, reg_float_3
	ffadd reg_float_1, reg_float_3, reg_float_1
	ffdiv reg_float_1, wf, reg_float_1
	vvmov w2, reg_float_1, 1
	ffsub 1065353216, w1, reg_float_1
	ffsub reg_float_1, w2, reg_float_1
	vvmov w3, reg_float_1, 1
	ffmul w1, d1, reg_float_1
	ffmul w2, d2, reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	ffmul w3, d3, reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vvmov d, reg_float_1, 1
	iimul y, 1920, reg_int_4
	iimul x, 4, reg_int_5
	iiadd reg_int_4, reg_int_5, reg_int_4
	lea esi, deep_buffer
	add esi, reg_int_4
	ffcmp d, [esi+0]
	jnb L129
	fimov reg_int_5, d
	mov esi, v1
	ffmul w1, [esi+0], reg_float_1
	mov esi, v2
	ffmul w2, [esi+0], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	mov esi, v3
	ffmul w3, [esi+0], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-12], reg_float_1, 1
	mov esi, v1
	ffmul w1, [esi+4], reg_float_1
	mov esi, v2
	ffmul w2, [esi+4], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	mov esi, v3
	ffmul w3, [esi+4], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	mov esi, v1
	ffmul w1, [esi+8], reg_float_1
	mov esi, v2
	ffmul w2, [esi+8], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	mov esi, v3
	ffmul w3, [esi+8], reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vvmov [esp-20], reg_float_1, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_2
	call Vec3__norm
	vvmov v, reg_Vec3_2, 3
	mov esi, self
	plea [esp-12], [esi+132]
	plea [esp-16], v
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_2
	call Vec3__norm
	vvmov h, reg_Vec3_2, 3
	vvmov [esp-12], 0, 1
	add esp, -12
	plea [esp-12], N
	plea [esp-16], h
	plea [esp-20], reg_float_1
	call Vec3__dot
	sub esp, -12
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_float_1
	call max2f
	mov esi, self
	ffmul reg_float_1, [esi+152], reg_float_1
	ffadd _light, reg_float_1, reg_float_1
	vvmov light, reg_float_1, 1
	ffmul light, 1115684864, reg_float_1
	fimov reg_int_6, reg_float_1
	vvmov color, reg_int_6, 1
	iimul y, 1920, reg_int_6
	iimul x, 4, reg_int_7
	iiadd reg_int_6, reg_int_7, reg_int_6
	lea esi, color_buffer
	add esi, reg_int_6
	vvmov [esi+0], color, 1
	iimul y, 1920, reg_int_6
	iimul x, 4, reg_int_7
	iiadd reg_int_6, reg_int_7, reg_int_6
	lea esi, deep_buffer
	add esi, reg_int_6
	vvmov [esi+0], d, 1
	L129:
	L128:
	L127:
	L126:
	iisub CX1, FDY12, reg_int_6
	vvmov CX1, reg_int_6, 1
	iisub CX2, FDY23, reg_int_6
	vvmov CX2, reg_int_6, 1
	iisub CX3, FDY31, reg_int_6
	vvmov CX3, reg_int_6, 1
	L125:
	iiadd x, 1, x
	jmp L123
	L124:
	iiadd CY1, FDX12, reg_int_6
	vvmov CY1, reg_int_6, 1
	iiadd CY2, FDX23, reg_int_6
	vvmov CY2, reg_int_6, 1
	iiadd CY3, FDX31, reg_int_6
	vvmov CY3, reg_int_6, 1
	L122:
	iiadd y, 1, y
	jmp L120
	L121:
	end_Camera__render_triangle:
	ret
Camera__render_triangle ENDP


get_time PROC USES esi edi
	local ret_0:DWORD, t:DWORD
	call GetMseconds
	mov t, eax
	vpmov ret_0, t, 1
	jmp end_get_time
	end_get_time:
	ret
get_time ENDP


Keyboard__init PROC USES esi edi
	local self:DWORD
	mov esi, self
	vvmov [esi+24], 0, 1
	mov esi, self
	vvmov [esi+28], 0, 1
	mov esi, self
	vvmov [esi+32], 0, 1
	mov esi, self
	vvmov [esi+36], 0, 1
	mov esi, self
	vvmov [esi+40], 0, 1
	end_Keyboard__init:
	ret
Keyboard__init ENDP


Keyboard__update PROC USES esi edi
	local self:DWORD, key:DWORD, reg_int_1:DWORD
	call ReadKey
	movzx ebx, ax
	mov key, ebx
	iicmp key, 04209
	jne L130
	mov reg_int_1, 1
	jmp L131
	L130:
	mov reg_int_1, 0
	L131:
	mov esi, self
	vvmov [esi+0], reg_int_1, 1
	iicmp key, 04709
	jne L132
	mov reg_int_1, 1
	jmp L133
	L132:
	mov reg_int_1, 0
	L133:
	mov esi, self
	vvmov [esi+4], reg_int_1, 1
	iicmp key, 04471
	jne L134
	mov reg_int_1, 1
	jmp L135
	L134:
	mov reg_int_1, 0
	L135:
	mov esi, self
	vvmov [esi+8], reg_int_1, 1
	iicmp key, 07777
	jne L136
	mov reg_int_1, 1
	jmp L137
	L136:
	mov reg_int_1, 0
	L137:
	mov esi, self
	vvmov [esi+12], reg_int_1, 1
	iicmp key, 08051
	jne L138
	mov reg_int_1, 1
	jmp L139
	L138:
	mov reg_int_1, 0
	L139:
	mov esi, self
	vvmov [esi+16], reg_int_1, 1
	iicmp key, 08292
	jne L140
	mov reg_int_1, 1
	jmp L141
	L140:
	mov reg_int_1, 0
	L141:
	mov esi, self
	vvmov [esi+20], reg_int_1, 1
	iicmp key, 18432
	jne L142
	mov reg_int_1, 1
	jmp L143
	L142:
	mov reg_int_1, 0
	L143:
	mov esi, self
	vvmov [esi+24], reg_int_1, 1
	iicmp key, 20480
	jne L144
	mov reg_int_1, 1
	jmp L145
	L144:
	mov reg_int_1, 0
	L145:
	mov esi, self
	vvmov [esi+28], reg_int_1, 1
	iicmp key, 19200
	jne L146
	mov reg_int_1, 1
	jmp L147
	L146:
	mov reg_int_1, 0
	L147:
	mov esi, self
	vvmov [esi+32], reg_int_1, 1
	iicmp key, 19712
	jne L148
	mov reg_int_1, 1
	jmp L149
	L148:
	mov reg_int_1, 0
	L149:
	mov esi, self
	vvmov [esi+36], reg_int_1, 1
	iicmp key, 00283
	jne L150
	mov reg_int_1, 1
	jmp L151
	L150:
	mov reg_int_1, 0
	L151:
	mov esi, self
	vvmov [esi+40], reg_int_1, 1
	end_Keyboard__update:
	ret
Keyboard__update ENDP


Keyboard__print PROC USES esi edi
	local self:DWORD
	mov esi, self
	printInt [esi+24]
	mov esi, self
	printInt [esi+28]
	mov esi, self
	printInt [esi+32]
	mov esi, self
	printInt [esi+36]
	mov esi, self
	printInt [esi+40]
	printEndl
	end_Keyboard__print:
	ret
Keyboard__print ENDP


Engine__init PROC USES esi edi
	local self:DWORD, reg_int_1:DWORD
	mov esi, self
	vvmov [esi+0], 1065353216, 1
	plea [esp-12], reg_int_1
	call get_time
	mov esi, self
	vvmov [esi+12], reg_int_1, 1
	end_Engine__init:
	ret
Engine__init ENDP


Engine__update_time PROC USES esi edi
	local self:DWORD, t:DWORD, reg_int_1:DWORD, reg_float_1:DWORD, reg_int_2:DWORD
	plea [esp-12], reg_int_1
	call get_time
	ifmov reg_float_1, reg_int_1
	vvmov t, reg_float_1, 1
	L152:
	mov esi, self
	ifmov reg_float_1, [esi+12]
	ffsub t, reg_float_1, reg_float_1
	mov esi, self
	ffcmp reg_float_1, [esi+0]
	jnb L153
	fimov reg_int_1, reg_float_1
	plea [esp-12], reg_int_2
	call get_time
	ifmov reg_float_1, reg_int_2
	vvmov t, reg_float_1, 1
	jmp L152
	L153:
	mov esi, self
	ifmov reg_float_1, [esi+12]
	ffsub t, reg_float_1, reg_float_1
	ffdiv reg_float_1, 1148846080, reg_float_1
	mov esi, self
	vvmov [esi+4], reg_float_1, 1
	fimov reg_int_2, t
	mov esi, self
	vvmov [esi+12], reg_int_2, 1
	ffdiv t, 1148846080, reg_float_1
	mov esi, self
	vvmov [esi+8], reg_float_1, 1
	end_Engine__update_time:
	ret
Engine__update_time ENDP


Engine__step PROC USES esi edi
	local self:DWORD
	iimov [esp-12], self
	call Engine__update_time
	plea [esp-12], mm
	call ModelManager__reset
	call update
	plea [esp-12], keyboard
	call Keyboard__update
	plea [esp-12], camera
	call Camera__render
	call display
	end_Engine__step:
	ret
Engine__step ENDP


main PROC
	call build_char_level
	plea [esp-12], camera
	call Camera__init
	plea [esp-12], engine
	call Engine__init
	plea [esp-12], keyboard
	call Keyboard__init
	plea [esp-12], mm
	call ModelManager__init
	call init
	L154:
	plea [esp-12], engine
	call Engine__step
	jmp L154
	L155:
	call WaitMsg
	exit
main ENDP


PD__init PROC USES esi edi
	local kp:DWORD, kd:DWORD, self:DWORD
	mov esi, self
	vvmov [esi+0], 0, 1
	mov esi, self
	vvmov [esi+4], kp, 1
	mov esi, self
	vvmov [esi+8], kd, 1
	end_PD__init:
	ret
PD__init ENDP


PD__step PROC USES esi edi
	local self:DWORD, p:DWORD, target:DWORD, ret_0:DWORD, err:DWORD, reg_float_1:DWORD, deri:DWORD, y:DWORD, reg_float_2:DWORD
	ffsub target, p, reg_float_1
	vvmov err, reg_float_1, 1
	mov esi, self
	ffsub err, [esi+0], reg_float_1
	lea esi, engine
	ffdiv reg_float_1, [esi+4], reg_float_1
	vvmov deri, reg_float_1, 1
	mov esi, self
	ffmul [esi+4], err, reg_float_1
	mov esi, self
	ffmul [esi+8], deri, reg_float_2
	ffadd reg_float_1, reg_float_2, reg_float_1
	vvmov y, reg_float_1, 1
	mov esi, self
	vvmov [esi+0], err, 1
	vpmov ret_0, y, 1
	jmp end_PD__step
	end_PD__step:
	ret
PD__step ENDP


Vec3PD__init PROC USES esi edi
	local kp:DWORD, kd:DWORD, self:DWORD, reg_Vec3_1[3]:DWORD
	plea [esp-12], reg_Vec3_1
	call Vec3_zero
	mov esi, self
	vvmov [esi+0], reg_Vec3_1, 3
	mov esi, self
	pvmov [esi+12], kp, 3
	mov esi, self
	pvmov [esi+24], kd, 3
	end_Vec3PD__init:
	ret
Vec3PD__init ENDP


Vec3PD__step PROC USES esi edi
	local self:DWORD, p:DWORD, target:DWORD, ret_0:DWORD, err[3]:DWORD, reg_Vec3_1[3]:DWORD, deri[3]:DWORD, reg_float_1:DWORD, reg_Vec3_2[3]:DWORD, y[3]:DWORD
	iimov [esp-12], target
	iimov [esp-16], p
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	vvmov err, reg_Vec3_1, 3
	plea [esp-12], err
	mov esi, self
	plea [esp-16], [esi+0]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	plea [esp-12], reg_Vec3_1
	lea esi, engine
	ffdiv 1065353216, [esi+4], reg_float_1
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_Vec3_2
	call Vec3__mulc
	vvmov deri, reg_Vec3_2, 3
	mov esi, self
	plea [esp-12], [esi+12]
	plea [esp-16], err
	plea [esp-20], reg_Vec3_1
	call Vec3__mul
	mov esi, self
	plea [esp-12], [esi+24]
	plea [esp-16], deri
	plea [esp-20], reg_Vec3_2
	call Vec3__mul
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_2
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vvmov y, reg_Vec3_1, 3
	mov esi, self
	vvmov [esi+0], err, 3
	vpmov ret_0, y, 3
	jmp end_Vec3PD__step
	end_Vec3PD__step:
	ret
Vec3PD__step ENDP


Player__init PROC USES esi edi
	local self:DWORD, reg_Vec3_1[3]:DWORD, reg_Vec3_2[3]:DWORD, reg_Vec3_3[3]:DWORD, reg_Matrix3_1[9]:DWORD, reg_Vec3PD_1[9]:DWORD, reg_PD_1[3]:DWORD
	mov esi, self
	vvmov [esi+0], 1133903872, 1
	mov esi, self
	vvmov [esi+4], 1133903872, 1
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 1092616192, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+8], reg_Vec3_1, 3
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 1092616192, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+20], reg_Vec3_1, 3
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], -1082130432, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	add esp, -12
	vvmov [esp-12], -1082130432, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_2
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_2
	add esp, -16
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 1065353216, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_3
	call Vec3__init
	sub esp, -16
	plea [esp-20], reg_Vec3_3
	plea [esp-24], reg_Matrix3_1
	call Matrix3__init
	mov esi, self
	vvmov [esi+32], reg_Matrix3_1, 9
	vvmov [esp-12], 1077936128, 1
	vvmov [esp-16], 1077936128, 1
	vvmov [esp-20], 1077936128, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+68], reg_Vec3_1, 3
	vvmov [esp-12], 0, 1
	vvmov [esp-16], -1028521984, 1
	vvmov [esp-20], -1005191168, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+80], reg_Vec3_1, 3
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+92], reg_Vec3_1, 3
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], -1029701632, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+104], reg_Vec3_1, 3
	vvmov [esp-12], 1036831949, 1
	vvmov [esp-16], 1036831949, 1
	vvmov [esp-20], 1036831949, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	add esp, -12
	vvmov [esp-12], 1084227584, 1
	vvmov [esp-16], 1084227584, 1
	vvmov [esp-20], 1084227584, 1
	plea [esp-24], reg_Vec3_2
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_2
	plea [esp-20], reg_Vec3PD_1
	call Vec3PD__init
	mov esi, self
	vvmov [esi+116], reg_Vec3PD_1, 9
	plea [esp-12], reg_Vec3_1
	call Vec3_zero
	mov esi, self
	vvmov [esi+152], reg_Vec3_1, 3
	plea [esp-12], reg_Vec3_1
	call Vec3_zero
	mov esi, self
	vvmov [esi+164], reg_Vec3_1, 3
	mov esi, self
	vvmov [esi+176], 0, 1
	vvmov [esp-12], 1084227584, 1
	vvmov [esp-16], 1082130432, 1
	plea [esp-20], reg_PD_1
	call PD__init
	mov esi, self
	vvmov [esi+180], reg_PD_1, 3
	mov esi, self
	vvmov [esi+192], -1082130432, 1
	end_Player__init:
	ret
Player__init ENDP


Player__collide PROC USES esi edi
	local self:DWORD, ret_0:DWORD, w[3]:DWORD, reg_Vec3_1[3]:DWORD, d:DWORD, reg_float_1:DWORD, i:DWORD, reg_int_1:DWORD, t[3]:DWORD, reg_float_2:DWORD, a[3]:DWORD, b[3]:DWORD, c__[3]:DWORD
	local u[3]:DWORD, dd__:DWORD, j:DWORD, reg_int_2:DWORD, reg_int_3:DWORD
	mov esi, self
	plea [esp-12], [esi+8]
	mov esi, self
	plea [esp-16], [esi+20]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	vvmov w, reg_Vec3_1, 3
	plea [esp-12], w
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov d, reg_float_1, 1
	fimov reg_int_1, d
	iimov i, 0
	L156:
	iicmp i, reg_int_1
	jnl L157
	plea [esp-12], w
	ifmov reg_float_1, i
	ffdiv reg_float_1, d, reg_float_2
	vvmov [esp-16], reg_float_2, 1
	plea [esp-20], reg_Vec3_1
	call Vec3__mulc
	mov esi, self
	plea [esp-12], [esi+20]
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vvmov t, reg_Vec3_1, 3
	vvmov [esp-12], 1077420229, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+68]
	plea [esp-20], reg_Vec3_1
	call Vec3__mul
	plea [esp-12], t
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vvmov a, reg_Vec3_1, 3
	vvmov [esp-12], -1073175593, 1
	vvmov [esp-16], 1079584489, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+68]
	plea [esp-20], reg_Vec3_1
	call Vec3__mul
	plea [esp-12], t
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vvmov b, reg_Vec3_1, 3
	vvmov [esp-12], -1073175593, 1
	vvmov [esp-16], -1067899159, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	mov esi, self
	plea [esp-16], [esi+68]
	plea [esp-20], reg_Vec3_1
	call Vec3__mul
	plea [esp-12], t
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	vvmov c__, reg_Vec3_1, 3
	plea [esp-12], a
	plea [esp-16], b
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	vvmov u, reg_Vec3_1, 3
	plea [esp-12], u
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov dd__, reg_float_1, 1
	fimov reg_int_2, dd__
	iimov j, 0
	L159:
	iicmp j, reg_int_2
	jnl L160
	plea [esp-12], terrain
	add esp, -12
	plea [esp-12], u
	ifmov reg_float_1, j
	ffdiv reg_float_1, dd__, reg_float_2
	vvmov [esp-16], reg_float_2, 1
	plea [esp-20], reg_Vec3_1
	call Vec3__mulc
	sub esp, -12
	add esp, -12
	plea [esp-12], b
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_int_3
	call Terrain__collide
	iicmp reg_int_3, 1
	jne L163
	vpmov ret_0, 1, 1
	jmp end_Player__collide
	L163:
	L162:
	L161:
	iiadd j, 1, j
	jmp L159
	L160:
	plea [esp-12], a
	plea [esp-16], c__
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	vvmov u, reg_Vec3_1, 3
	plea [esp-12], u
	plea [esp-16], reg_float_1
	call Vec3__length
	vvmov dd__, reg_float_1, 1
	fimov reg_int_2, dd__
	iimov j, 0
	L164:
	iicmp j, reg_int_2
	jnl L165
	plea [esp-12], terrain
	add esp, -12
	plea [esp-12], u
	ifmov reg_float_1, j
	ffdiv reg_float_1, dd__, reg_float_2
	vvmov [esp-16], reg_float_2, 1
	plea [esp-20], reg_Vec3_1
	call Vec3__mulc
	sub esp, -12
	add esp, -12
	plea [esp-12], c__
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_int_3
	call Terrain__collide
	iicmp reg_int_3, 1
	jne L168
	vpmov ret_0, 1, 1
	jmp end_Player__collide
	L168:
	L167:
	L166:
	iiadd j, 1, j
	jmp L164
	L165:
	L158:
	iiadd i, 1, i
	jmp L156
	L157:
	vpmov ret_0, 0, 1
	jmp end_Player__collide
	end_Player__collide:
	ret
Player__collide ENDP


Player__update PROC USES esi edi
	local self:DWORD, reg_Vec3_1[3]:DWORD, reg_float_1:DWORD, reg_Distortion_1[7]:DWORD, reg_int_1:DWORD, reg_int_2:DWORD, reg_int_3:DWORD, rot[9]:DWORD, reg_Matrix3_1[9]:DWORD, reg_Matrix3_2[9]:DWORD, reg_Vec3_2[3]:DWORD, theta:DWORD, phi:DWORD
	local local_camera_x:DWORD, reg_float_2:DWORD, local_camera_y:DWORD, local_camera_z:DWORD, camera_w[3]:DWORD, reg_Vec3_3[3]:DWORD, camera_u[3]:DWORD, camera_v[3]:DWORD, reg_int_4:DWORD
	lea esi, keyboard
	iicmp [esi+20], 1
	jne L170
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], -1029701632, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+104], reg_Vec3_1, 3
	jmp L169
	L170:
	lea esi, keyboard
	iicmp [esi+4], 1
	jne L171
	vvmov [esp-12], -1036779520, 1
	vvmov [esp-16], -1036779520, 1
	vvmov [esp-20], -1013579776, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+104], reg_Vec3_1, 3
	jmp L169
	L171:
	lea esi, keyboard
	iicmp [esi+8], 1
	jne L172
	vvmov [esp-12], 0, 1
	vvmov [esp-16], -1028521984, 1
	vvmov [esp-20], -1005191168, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+104], reg_Vec3_1, 3
	jmp L169
	L172:
	lea esi, keyboard
	iicmp [esi+0], 1
	jne L173
	vvmov [esp-12], 1106247680, 1
	vvmov [esp-16], -1020002304, 1
	vvmov [esp-20], -1013579776, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	mov esi, self
	vvmov [esi+104], reg_Vec3_1, 3
	jmp L169
	L173:
	lea esi, keyboard
	iicmp [esi+12], 1
	jne L174
	plea [esp-12], camera
	mov esi, self
	ffsub [esi+20], 1128792064, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	add esp, -12
	plea [esp-12], reg_Vec3_1
	vvmov [esp-16], 1112014848, 1
	vvmov [esp-20], 3, 1
	plea [esp-24], reg_Distortion_1
	call Distortion__init
	sub esp, -12
	plea [esp-16], reg_Distortion_1
	call Camera__add_distortion
	L174:
	L169:
	lea esi, keyboard
	iicmp [esi+32], 1
	jne L176
	mov esi, self
	vvmov [esi+176], -1049624576, 1
	jmp L175
	L176:
	lea esi, keyboard
	iicmp [esi+36], 1
	jne L177
	mov esi, self
	vvmov [esi+176], 1097859072, 1
	jmp L175
	L177:
	lea esi, keyboard
	iicmp [esi+28], 1
	jne L178
	mov esi, self
	vvmov [esi+176], 0, 1
	L178:
	L175:
	iimul 0, 28, reg_int_1
	lea esi, camera
	add esi, reg_int_1
	plea [esp-12], [esi+180]
	mov esi, self
	plea [esp-16], [esi+20]
	plea [esp-20], reg_int_2
	call Distortion__need
	iicmp reg_int_2, 1
	jne L180
	mov esi, self
	lea edi, engine
	vvmov [esi+192], [edi+8], 1
	L180:
	L179:
	mov esi, self
	ffcmp [esi+192], 0
	jna L182
	mov esi, self
	fimov reg_int_2, [esi+192]
	jmp end_Player__update
	L182:
	L181:
	mov esi, self
	ffcmp [esi+4], [esi+0]
	jnb L184
	mov esi, self
	fimov reg_int_3, [esi+4]
	lea esi, engine
	ffmul 1125515264, [esi+4], reg_float_1
	mov esi, self
	ffadd [esi+4], reg_float_1, reg_float_1
	mov esi, self
	vvmov [esi+4], reg_float_1, 1
	L184:
	L183:
	mov esi, self
	plea [esp-12], [esi+180]
	mov esi, self
	vvmov [esp-16], [esi+152], 1
	mov esi, self
	vvmov [esp-20], [esi+176], 1
	plea [esp-24], reg_float_1
	call PD__step
	lea esi, engine
	ffmul reg_float_1, [esi+4], reg_float_1
	mov esi, self
	ffadd [esi+164], reg_float_1, reg_float_1
	mov esi, self
	vvmov [esi+164], reg_float_1, 1
	mov esi, self
	lea edi, engine
	ffmul [esi+164], [edi+4], reg_float_1
	mov esi, self
	ffadd [esi+152], reg_float_1, reg_float_1
	mov esi, self
	vvmov [esi+152], reg_float_1, 1
	mov esi, self
	ffsub 0, [esi+152], reg_float_1
	mov esi, self
	vvmov [esi+160], reg_float_1, 1
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	mov esi, self
	vvmov [esp-16], [esi+152], 1
	plea [esp-20], reg_Matrix3_1
	call axisAngle2Matrix
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 1065353216, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	mov esi, self
	vvmov [esp-16], [esi+156], 1
	plea [esp-20], reg_Matrix3_2
	call axisAngle2Matrix
	plea [esp-12], reg_Matrix3_1
	plea [esp-16], reg_Matrix3_2
	plea [esp-20], reg_Matrix3_1
	call Matrix3__mul
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 1065353216, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	mov esi, self
	vvmov [esp-16], [esi+160], 1
	plea [esp-20], reg_Matrix3_2
	call axisAngle2Matrix
	plea [esp-12], reg_Matrix3_1
	plea [esp-16], reg_Matrix3_2
	plea [esp-20], reg_Matrix3_1
	call Matrix3__mul
	vvmov rot, reg_Matrix3_1, 9
	mov esi, self
	vvmov [esi+8], [esi+20], 3
	lea esi, rot
	plea [esp-12], [esi+0]
	mov esi, self
	lea edi, engine
	ffmul [esi+4], [edi+4], reg_float_1
	vvmov [esp-16], reg_float_1, 1
	plea [esp-20], reg_Vec3_1
	call Vec3__mulc
	vvmov [esp-12], 1065353216, 1
	vvmov [esp-16], -1082130432, 1
	vvmov [esp-20], 1065353216, 1
	plea [esp-24], reg_Vec3_2
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_2
	plea [esp-20], reg_Vec3_1
	call Vec3__mul
	mov esi, self
	plea [esp-12], [esi+20]
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	mov esi, self
	vvmov [esi+20], reg_Vec3_1, 3
	mov esi, self
	plea [esp-12], [esi+116]
	mov esi, self
	plea [esp-16], [esi+80]
	mov esi, self
	plea [esp-20], [esi+104]
	plea [esp-24], reg_Vec3_1
	call Vec3PD__step
	plea [esp-12], reg_Vec3_1
	lea esi, engine
	vvmov [esp-16], [esi+4], 1
	plea [esp-20], reg_Vec3_2
	call Vec3__mulc
	mov esi, self
	plea [esp-12], [esi+92]
	plea [esp-16], reg_Vec3_2
	plea [esp-20], reg_Vec3_2
	call Vec3__add
	mov esi, self
	vvmov [esi+92], reg_Vec3_2, 3
	mov esi, self
	plea [esp-12], [esi+92]
	lea esi, engine
	vvmov [esp-16], [esi+4], 1
	plea [esp-20], reg_Vec3_1
	call Vec3__mulc
	mov esi, self
	plea [esp-12], [esi+80]
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	mov esi, self
	vvmov [esi+80], reg_Vec3_1, 3
	mov esi, self
	vvmov [esp-12], [esi+80], 1
	plea [esp-16], reg_float_1
	call deg2rad
	vvmov theta, reg_float_1, 1
	mov esi, self
	vvmov [esp-12], [esi+84], 1
	plea [esp-16], reg_float_1
	call deg2rad
	vvmov phi, reg_float_1, 1
	vvmov [esp-12], theta, 1
	plea [esp-16], reg_float_1
	call cos
	vvmov [esp-12], phi, 1
	plea [esp-16], reg_float_2
	call cos
	ffmul reg_float_1, reg_float_2, reg_float_1
	vvmov local_camera_x, reg_float_1, 1
	vvmov [esp-12], theta, 1
	plea [esp-16], reg_float_1
	call sin
	vvmov [esp-12], phi, 1
	plea [esp-16], reg_float_2
	call cos
	ffmul reg_float_1, reg_float_2, reg_float_1
	vvmov local_camera_y, reg_float_1, 1
	vvmov [esp-12], phi, 1
	plea [esp-16], reg_float_1
	call sin
	vvmov local_camera_z, reg_float_1, 1
	vvmov [esp-12], local_camera_x, 1
	vvmov [esp-16], local_camera_y, 1
	vvmov [esp-20], local_camera_z, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	mov esi, self
	vvmov [esp-16], [esi+88], 1
	plea [esp-20], reg_Vec3_2
	call Vec3__mulc
	mov esi, self
	plea [esp-12], [esi+20]
	plea [esp-16], reg_Vec3_2
	plea [esp-20], reg_Vec3_2
	call Vec3__add
	lea esi, camera
	vvmov [esi+0], reg_Vec3_2, 3
	plea [esp-12], reg_Vec3_1
	call Vec3_zero
	lea esi, camera
	plea [esp-12], [esi+0]
	mov esi, self
	plea [esp-16], [esi+20]
	plea [esp-20], reg_Vec3_2
	call Vec3__sub
	plea [esp-12], reg_Vec3_2
	plea [esp-16], reg_Vec3_3
	call Vec3__norm
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_3
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	vvmov camera_w, reg_Vec3_1, 3
	plea [esp-12], camera_w
	add esp, -12
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 1065353216, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__cross
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_2
	call Vec3__norm
	vvmov camera_u, reg_Vec3_2, 3
	plea [esp-12], camera_w
	plea [esp-16], camera_u
	plea [esp-20], reg_Vec3_1
	call Vec3__cross
	plea [esp-12], reg_Vec3_1
	plea [esp-16], reg_Vec3_2
	call Vec3__norm
	vvmov camera_v, reg_Vec3_2, 3
	plea [esp-12], camera
	add esp, -12
	plea [esp-12], camera_u
	plea [esp-16], camera_v
	plea [esp-20], camera_w
	plea [esp-24], reg_Matrix3_1
	call Matrix3__init
	sub esp, -12
	plea [esp-16], reg_Matrix3_1
	call Camera__set_inv_axis
	iimov [esp-12], self
	plea [esp-16], reg_int_4
	call Player__collide
	iicmp reg_int_4, 1
	jne L186
	plea [esp-12], camera
	vvmov [esp-16], 1084227584, 1
	vvmov [esp-20], 1056964608, 1
	call Camera__shake
	mov esi, self
	vvmov [esi+4], 1125515264, 1
	L186:
	L185:
	plea [esp-12], mm
	mov esi, self
	plea [esp-16], [esi+20]
	add esp, -16
	plea [esp-12], rot
	mov esi, self
	plea [esp-16], [esi+32]
	plea [esp-20], reg_Matrix3_1
	call Matrix3__mul
	sub esp, -16
	plea [esp-20], reg_Matrix3_1
	mov esi, self
	plea [esp-24], [esi+68]
	call ModelManager__set_transform
	plea [esp-12], mm
	call ModelManager__add_spaceship
	end_Player__update:
	ret
Player__update ENDP


Player__rot_x_ctl_test PROC USES esi edi
	local self:DWORD, reg_float_1:DWORD
	lea esi, keyboard
	iicmp [esi+0], 1
	jne L188
	mov esi, self
	ffadd [esi+184], 1036831949, reg_float_1
	mov esi, self
	vvmov [esi+184], reg_float_1, 1
	jmp L187
	L188:
	lea esi, keyboard
	iicmp [esi+12], 1
	jne L189
	mov esi, self
	ffsub [esi+184], 1036831949, reg_float_1
	mov esi, self
	vvmov [esi+184], reg_float_1, 1
	jmp L187
	L189:
	lea esi, keyboard
	iicmp [esi+4], 1
	jne L190
	mov esi, self
	ffadd [esi+188], 1036831949, reg_float_1
	mov esi, self
	vvmov [esi+188], reg_float_1, 1
	jmp L187
	L190:
	lea esi, keyboard
	iicmp [esi+20], 1
	jne L191
	mov esi, self
	ffsub [esi+188], 1036831949, reg_float_1
	mov esi, self
	vvmov [esi+188], reg_float_1, 1
	L191:
	L187:
	mov esi, self
	printFloat [esi+184]
	mov esi, self
	printFloat [esi+188]
	printEndl
	end_Player__rot_x_ctl_test:
	ret
Player__rot_x_ctl_test ENDP


Obstacle__init PROC USES esi edi
	local pos:DWORD, w:DWORD, h:DWORD, type__:DWORD, self:DWORD, reg_float_1:DWORD
	mov esi, self
	pvmov [esi+0], pos, 3
	mov esi, self
	vvmov [esi+12], type__, 1
	ifmov reg_float_1, w
	mov esi, self
	vvmov [esi+16], reg_float_1, 1
	ifmov reg_float_1, h
	mov esi, self
	vvmov [esi+20], reg_float_1, 1
	end_Obstacle__init:
	ret
Obstacle__init ENDP


Obstacle__collide PROC USES esi edi
	local self:DWORD, p:DWORD, ret_0:DWORD, d[3]:DWORD, reg_Vec3_1[3]:DWORD, b:DWORD, reg_float_1:DWORD, reg_int_1:DWORD, reg_int_2:DWORD, reg_int_3:DWORD, reg_int_4:DWORD
	iimov [esp-12], p
	mov esi, self
	plea [esp-16], [esi+0]
	plea [esp-20], reg_Vec3_1
	call Vec3__sub
	vvmov d, reg_Vec3_1, 3
	mov esi, self
	iicmp [esi+12], 1
	jne L193
	lea esi, d
	mov edi, self
	ffmul [esi+8], [edi+16], reg_float_1
	mov esi, self
	ffdiv reg_float_1, [esi+20], reg_float_1
	vvmov b, reg_float_1, 1
	lea esi, d
	iicmp 0 , [esi+8]
	jg L194
	lea esi, d
	mov edi, self
	ffcmp [esi+8], [edi+20]
	jnb L194
	lea esi, d
	fimov reg_int_1, [esi+8]
	lea esi, d
	vvmov [esp-12], [esi+0], 1
	plea [esp-16], reg_float_1
	call fabs__
	ffcmp reg_float_1, b
	jnb L194
	fimov reg_int_2, reg_float_1
	lea esi, d
	vvmov [esp-12], [esi+4], 1
	plea [esp-16], reg_float_1
	call fabs__
	ffcmp reg_float_1, b
	jnb L194
	fimov reg_int_3, reg_float_1
	mov reg_int_4, 1
	jmp L195
	L194:
	mov reg_int_4, 0
	L195:
	vpmov ret_0, reg_int_4, 1
	jmp end_Obstacle__collide
	jmp L192
	L193:
	mov esi, self
	iicmp [esi+12], 2
	jne L196
	lea esi, d
	iicmp 0 , [esi+8]
	jg L197
	lea esi, d
	mov edi, self
	ffcmp [esi+8], [edi+20]
	jnb L197
	lea esi, d
	fimov reg_int_1, [esi+8]
	lea esi, d
	vvmov [esp-12], [esi+0], 1
	plea [esp-16], reg_float_1
	call fabs__
	mov esi, self
	ffcmp reg_float_1, [esi+16]
	jnb L197
	fimov reg_int_2, reg_float_1
	lea esi, d
	vvmov [esp-12], [esi+4], 1
	plea [esp-16], reg_float_1
	call fabs__
	mov esi, self
	ffcmp reg_float_1, [esi+16]
	jnb L197
	fimov reg_int_3, reg_float_1
	mov reg_int_4, 1
	jmp L198
	L197:
	mov reg_int_4, 0
	L198:
	vpmov ret_0, reg_int_4, 1
	jmp end_Obstacle__collide
	L196:
	L192:
	end_Obstacle__collide:
	ret
Obstacle__collide ENDP


Obstacle__update PROC USES esi edi
	local self:DWORD
	mov esi, self
	iicmp [esi+12], 1
	jne L200
	plea [esp-12], mm
	mov esi, self
	plea [esp-16], [esi+0]
	mov esi, self
	vvmov [esp-20], [esi+16], 1
	mov esi, self
	vvmov [esp-24], [esi+20], 1
	call ModelManager__add_pyramid
	jmp L199
	L200:
	mov esi, self
	iicmp [esi+12], 2
	jne L201
	plea [esp-12], mm
	mov esi, self
	plea [esp-16], [esi+0]
	mov esi, self
	vvmov [esp-20], [esi+16], 1
	mov esi, self
	vvmov [esp-24], [esi+20], 1
	call ModelManager__add_box
	L201:
	L199:
	end_Obstacle__update:
	ret
Obstacle__update ENDP


Terrain__init PROC USES esi edi
	local self:DWORD
	mov esi, self
	vvmov [esi+0], 1148846080, 1
	mov esi, self
	vvmov [esi+4], 1148846080, 1
	mov esi, self
	vvmov [esi+8], 1140457472, 1
	mov esi, self
	vvmov [esi+12], 0, 1
	mov esi, self
	vvmov [esi+16], 0, 1
	mov esi, self
	vvmov [esi+20], 2000, 1
	mov esi, self
	vvmov [esi+48024], 1120403456, 1
	mov esi, self
	vvmov [esi+48028], 1, 1
	end_Terrain__init:
	ret
Terrain__init ENDP


Terrain__collide PROC USES esi edi
	local self:DWORD, p:DWORD, ret_0:DWORD, i:DWORD, reg_int_1:DWORD, reg_int_2:DWORD
	iimov i, 0
	L202:
	mov esi, self
	iicmp i, [esi+12]
	jnl L203
	iimul i, 24, reg_int_1
	mov esi, self
	add esi, reg_int_1
	plea [esp-12], [esi+24]
	iimov [esp-16], p
	plea [esp-20], reg_int_2
	call Obstacle__collide
	iicmp reg_int_2, 1
	jne L206
	vpmov ret_0, 1, 1
	jmp end_Terrain__collide
	L206:
	L205:
	L204:
	iiadd i, 1, i
	jmp L202
	L203:
	vpmov ret_0, 0, 1
	jmp end_Terrain__collide
	end_Terrain__collide:
	ret
Terrain__collide ENDP


Terrain__add_obstacle PROC USES esi edi
	local self:DWORD, pos:DWORD, w:DWORD, h:DWORD, type__:DWORD, reg_int_1:DWORD, reg_Obstacle_1[6]:DWORD
	mov esi, self
	iimul [esi+16], 24, reg_int_1
	iimov [esp-12], pos
	vvmov [esp-16], w, 1
	vvmov [esp-20], h, 1
	vvmov [esp-24], type__, 1
	plea [esp-28], reg_Obstacle_1
	call Obstacle__init
	mov esi, self
	add esi, reg_int_1
	vvmov [esi+24], reg_Obstacle_1, 6
	mov esi, self
	iiadd [esi+12], 1, reg_int_1
	vvmov [esp-12], reg_int_1, 1
	mov esi, self
	vvmov [esp-16], [esi+20], 1
	plea [esp-20], reg_int_1
	call min2i
	mov esi, self
	vvmov [esi+12], reg_int_1, 1
	mov esi, self
	iiadd [esi+16], 1, reg_int_1
	mov esi, self
	iimod reg_int_1, [esi+20], reg_int_1
	mov esi, self
	vvmov [esi+16], reg_int_1, 1
	end_Terrain__add_obstacle:
	ret
Terrain__add_obstacle ENDP


Terrain__update PROC USES esi edi
	local self:DWORD, player_pos:DWORD, reg_Vec3_1[3]:DWORD, reg_Matrix3_1[9]:DWORD, reg_Vec3_2[3]:DWORD, i:DWORD, reg_int_1:DWORD
	iimov [esp-12], self
	iimov [esp-16], player_pos
	call Terrain__generate_terrain
	plea [esp-12], mm
	add esp, -12
	plea [esp-12], reg_Vec3_1
	call Vec3_zero
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	add esp, -16
	plea [esp-12], reg_Matrix3_1
	call Matrix3_identity
	sub esp, -16
	plea [esp-20], reg_Matrix3_1
	add esp, -20
	plea [esp-12], reg_Vec3_2
	call Vec3_one
	sub esp, -20
	plea [esp-24], reg_Vec3_2
	call ModelManager__set_transform
	iimov i, 0
	L207:
	mov esi, self
	iicmp i, [esi+12]
	jnl L208
	iimul i, 24, reg_int_1
	mov esi, self
	add esi, reg_int_1
	plea [esp-12], [esi+24]
	call Obstacle__update
	L209:
	iiadd i, 1, i
	jmp L207
	L208:
	end_Terrain__update:
	ret
Terrain__update ENDP


Terrain__generate_sub_terrain PROC USES esi edi
	local self:DWORD, pos:DWORD, siz:DWORD, w:DWORD, h:DWORD, nw:DWORD, nh:DWORD, nsiz:DWORD, reg_float_1:DWORD, rid:DWORD, reg_int_1:DWORD, reg_int_2:DWORD, reg_int_3:DWORD
	local reg_int_4:DWORD, reg_Vec3_1[3]:DWORD
	ffdiv siz, 1077936128, reg_float_1
	vvmov nsiz, reg_float_1, 1
	vvmov [esp-12], 0, 1
	vvmov [esp-16], 1065353216, 1
	plea [esp-20], reg_float_1
	call rand
	vvmov rid, reg_float_1, 1
	ffcmp rid, 1005961871
	jnb L211
	fimov reg_int_1, rid
	ffmul siz, 1082130432, reg_float_1
	ffdiv reg_float_1, 1084227584, reg_float_1
	vvmov w, reg_float_1, 1
	iimov [esp-12], self
	iimov [esp-16], pos
	fimov reg_int_2, w
	vvmov [esp-20], reg_int_2, 1
	fimov reg_int_2, w
	vvmov [esp-24], reg_int_2, 1
	vvmov [esp-28], 1, 1
	call Terrain__add_obstacle
	jmp L210
	L211:
	ffcmp rid, 1017370378
	jnb L212
	fimov reg_int_2, rid
	ffcmp siz, 1097859072
	jnb L212
	fimov reg_int_3, siz
	vvmov w, siz, 1
	vvmov [esp-12], 1109393408, 1
	vvmov [esp-16], 1116471296, 1
	plea [esp-20], reg_float_1
	call rand
	vvmov h, reg_float_1, 1
	iimov [esp-12], self
	iimov [esp-16], pos
	fimov reg_int_4, w
	vvmov [esp-20], reg_int_4, 1
	fimov reg_int_4, h
	vvmov [esp-24], reg_int_4, 1
	vvmov [esp-28], 1, 1
	call Terrain__add_obstacle
	jmp L210
	L212:
	ffcmp siz, 1106247680
	jb L213
	fimov reg_int_4, siz
	iimov [esp-12], self
	ffmul nsiz, 0, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	ffmul nsiz, 0, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	add esp, -12
	iimov [esp-12], pos
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	vvmov [esp-20], nsiz, 1
	call Terrain__generate_sub_terrain
	iimov [esp-12], self
	ffmul nsiz, 0, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	ffmul nsiz, 1065353216, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	add esp, -12
	iimov [esp-12], pos
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	vvmov [esp-20], nsiz, 1
	call Terrain__generate_sub_terrain
	iimov [esp-12], self
	ffmul nsiz, 0, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	ffmul nsiz, 1073741824, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	add esp, -12
	iimov [esp-12], pos
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	vvmov [esp-20], nsiz, 1
	call Terrain__generate_sub_terrain
	iimov [esp-12], self
	ffmul nsiz, 1065353216, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	ffmul nsiz, 0, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	add esp, -12
	iimov [esp-12], pos
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	vvmov [esp-20], nsiz, 1
	call Terrain__generate_sub_terrain
	iimov [esp-12], self
	ffmul nsiz, 1065353216, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	ffmul nsiz, 1065353216, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	add esp, -12
	iimov [esp-12], pos
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	vvmov [esp-20], nsiz, 1
	call Terrain__generate_sub_terrain
	iimov [esp-12], self
	ffmul nsiz, 1065353216, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	ffmul nsiz, 1073741824, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	add esp, -12
	iimov [esp-12], pos
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	vvmov [esp-20], nsiz, 1
	call Terrain__generate_sub_terrain
	iimov [esp-12], self
	ffmul nsiz, 1073741824, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	ffmul nsiz, 0, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	add esp, -12
	iimov [esp-12], pos
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	vvmov [esp-20], nsiz, 1
	call Terrain__generate_sub_terrain
	iimov [esp-12], self
	ffmul nsiz, 1073741824, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	ffmul nsiz, 1065353216, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	add esp, -12
	iimov [esp-12], pos
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	vvmov [esp-20], nsiz, 1
	call Terrain__generate_sub_terrain
	iimov [esp-12], self
	ffmul nsiz, 1073741824, reg_float_1
	add esp, -12
	vvmov [esp-12], reg_float_1, 1
	ffmul nsiz, 1073741824, reg_float_1
	vvmov [esp-16], reg_float_1, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	add esp, -12
	iimov [esp-12], pos
	plea [esp-16], reg_Vec3_1
	plea [esp-20], reg_Vec3_1
	call Vec3__add
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	vvmov [esp-20], nsiz, 1
	call Terrain__generate_sub_terrain
	L213:
	L210:
	end_Terrain__generate_sub_terrain:
	ret
Terrain__generate_sub_terrain ENDP


Terrain__generate_terrain PROC USES esi edi
	local self:DWORD, pos:DWORD, tar_x:DWORD, reg_float_1:DWORD, tar_y:DWORD, y:DWORD, reg_int_1:DWORD, reg_int_2:DWORD, reg_Vec3_1[3]:DWORD
	mov esi, pos
	mov edi, self
	ffadd [esi+0], [edi+4], reg_float_1
	vvmov tar_x, reg_float_1, 1
	mov esi, self
	ffdiv [esi+8], 1073741824, reg_float_1
	mov esi, pos
	ffadd [esi+4], reg_float_1, reg_float_1
	vvmov tar_y, reg_float_1, 1
	mov esi, self
	ffdiv [esi+8], 1073741824, reg_float_1
	mov esi, pos
	ffsub [esi+4], reg_float_1, reg_float_1
	vvmov y, reg_float_1, 1
	mov esi, self
	ffmod y, [esi+48024], reg_float_1
	ffsub y, reg_float_1, reg_float_1
	vvmov y, reg_float_1, 1
	L214:
	mov esi, self
	ffcmp [esi+0], tar_x
	jnb L215
	mov esi, self
	fimov reg_int_1, [esi+0]
	L216:
	ffcmp y, tar_y
	jnb L217
	fimov reg_int_2, y
	iimov [esp-12], self
	add esp, -12
	mov esi, self
	vvmov [esp-12], [esi+0], 1
	vvmov [esp-16], y, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	sub esp, -12
	plea [esp-16], reg_Vec3_1
	mov esi, self
	vvmov [esp-20], [esi+48024], 1
	call Terrain__generate_sub_terrain
	mov esi, self
	ffadd y, [esi+48024], reg_float_1
	vvmov y, reg_float_1, 1
	jmp L216
	L217:
	mov esi, self
	ffadd [esi+0], [esi+48024], reg_float_1
	mov esi, self
	vvmov [esi+0], reg_float_1, 1
	jmp L214
	L215:
	end_Terrain__generate_terrain:
	ret
Terrain__generate_terrain ENDP


init PROC USES esi edi
	local reg_int_1:DWORD, reg_Vec3_1[3]:DWORD, reg_Distortion_1[7]:DWORD
	plea [esp-12], player
	call Player__init
	plea [esp-12], terrain
	call Terrain__init
	plea [esp-12], engine
	call Engine__update_time
	plea [esp-12], engine
	call Engine__step
	L218:
	lea esi, keyboard
	iicmp [esi+24], 0
	jne L219
	plea [esp-12], keyboard
	call Keyboard__update
	plea [esp-12], camera
	call Camera__render
	call display
	jmp L218
	L219:
	plea [esp-12], engine
	call Engine__update_time
	iimul 0, 28, reg_int_1
	vvmov [esp-12], -971227136, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	vvmov [esp-16], 1112014848, 1
	vvmov [esp-20], 1, 1
	plea [esp-24], reg_Distortion_1
	call Distortion__init
	lea esi, camera
	add esi, reg_int_1
	vvmov [esi+180], reg_Distortion_1, 7
	end_init:
	ret
init ENDP


update PROC USES esi edi
	local reg_int_1:DWORD, reg_float_1:DWORD, reg_int_2:DWORD, reg_int_3:DWORD, reg_Vec3_1[3]:DWORD, reg_Distortion_1[7]:DWORD
	plea [esp-12], player
	call Player__update
	plea [esp-12], terrain
	lea esi, player
	plea [esp-16], [esi+20]
	call Terrain__update
	lea esi, player
	ffcmp [esi+192], 0
	jna L221
	lea esi, player
	fimov reg_int_1, [esi+192]
	lea esi, engine
	lea edi, player
	ffsub [esi+8], [edi+192], reg_float_1
	ffcmp reg_float_1, 1077936128
	jna L221
	fimov reg_int_2, reg_float_1
	iimul 0, 28, reg_int_3
	vvmov [esp-12], -971227136, 1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Vec3_1
	call Vec3__init
	plea [esp-12], reg_Vec3_1
	vvmov [esp-16], 0, 1
	vvmov [esp-20], 0, 1
	plea [esp-24], reg_Distortion_1
	call Distortion__init
	lea esi, camera
	add esi, reg_int_3
	vvmov [esi+180], reg_Distortion_1, 7
	call init
	L221:
	L220:
	end_update:
	ret
update ENDP


END main