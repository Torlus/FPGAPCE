;
; MATH.ASM  -  MagicKit Standard Math Routines
;
;


; ----
; divu8
; ----
; 8-bit unsigned division
; ----
; OUT : _CL = _AL / _BL
;	_DL = _AL % _BL
; ----

divu8:
	lda   <_al
	asl   A
	sta   <_cl
	cla
	ldy   #8
.l1:
	rol   A
	cmp   <_bl
	bcc   .l2
	sbc   <_bl
.l2:
	rol   <_cl
	dey
	bne   .l1

	sta   <_dl
	rts


; ----
; divu10
; ----
; 16-bit unsigned division by 10
; ----
; OUT : _DX = _DX / 10
;	  A = _DX % 10
; ----

divu10:
	  ldy	#16
  	  cla
	  asl	<_dl
  	  rol	<_dh
.l1:  	  rol	a
  	  cmp	#10
  	  blo	.l2
  	  sbc	#10
.l2:	  rol	<_dl
  	  rol	<_dh
	  dey
  	  bne	.l1
	  rts

	.if (!CDROM)
; ----
; mulu8
; ----
; 8-bit unsigned multiplication
; ----
; OUT : _CX = _AL * _BL
; ----

mulu8:
	lda   <_bl
	sta   <_ch

	cla
	ldy   #8
.l1:
	asl   A
	rol   <_ch
	bcc   .next
	add   <_al
	bcc   .next
	inc   <_ch
.next:
	dey
	bne   .l1

	sta   <_cl
	rts


; ----
; mulu16
; ----
; 16-bit unsigned multiplication
; ----
; OUT : _DX/CX = _AX * _BX
; ----

mulu16:
	lda   <_ah
	ora   <_bh
	bne   .l1

	stwz  <_dx		;  8-bit multiplication
	jmp   mulu8

.l1:	stw   <_bx,<_dx		; 16-bit multiplication
	stwz  <_cx
	ldy   #16

.l2:	aslw  <_cx
	rolw  <_dx
	bcc   .l3

	addw  <_ax,<_cx
	bcc   .l3
	incw  <_dx

.l3:	dey
	bne   .l2
	rts
	.endif

; ----
; mulu32
; ----
; 32-bit unsigned multiplication
; ----
; OUT : _DX/CX = _BX/AX * _DX/CX
; ----

mulu32:
	stw   <_cx,<_si
	stw   <_dx,<_di
	stwz  <_cx
	stwz  <_dx
	ldy   #32
.loop:
	aslw  <_cx
	rolw  <_dx
	rolw  <_si
	rolw  <_di
	bcc   .next

	addw  <_ax,<_cx
	adcw  <_bx,<_dx
.next:
	dey
	bne   .loop
	rts


; ----
; srand
; ----
; set random seed
; ----
; IN : _DX/CX = 32-bit seed
; ----

	.bss
_rndix	.ds 1
_rndiy	.ds 1
_rndbuf	.ds 28

	.code
srand:
	stw	<_cx,_rndbuf
	stw	<_dx,_rndbuf+2

	cly
	lda	#6
.l1:	pha
	phy
	stw	#$41C6,<_bx
	stw	#$4E6D,<_ax
	jsr	mulu32
	addw	#$3039,<_cx
	adcw	#$0000,<_dx
	pla
	add	#4
	tay
	stw	<_cx,_rndbuf,Y
	stw	<_dx,_rndbuf+2,Y
	pla
	dec	A
	bne	.l1

	lda	#12
	sta	_rndiy
	stz	_rndix

	lda	#70
.l2:	pha
	jsr	rand
	pla
	dec	A
	bne	.l2

	rts


; ----
; rand
; ----
; return a 31-bit random number
; ----
; OUT : _DX/CX
; ----

rand:
	clc
	ldx	_rndix
	ldy	_rndiy
	lda	_rndbuf,Y
	adc	_rndbuf,X
	sta	_rndbuf,Y
	sta	<_cl
	inx
	iny
	lda	_rndbuf,Y
	adc	_rndbuf,X
	sta	_rndbuf,Y
	sta	<_ch
	inx
	iny
	lda	_rndbuf,Y
	adc	_rndbuf,X
	sta	_rndbuf,Y
	sta	<_dl
	inx
	iny
	lda	_rndbuf,Y
	adc	_rndbuf,X
	sta	_rndbuf,Y
	sta	<_dh
	inx
	iny

	lsr	<_dh
	ror	<_dl
	ror	<_ch
	ror	<_cl

	cpy	#28
	blo	.l1
	cly
	bra	.l2

.l1:	cpx	#28
	blo	.l2
	clx

.l2:	stx	_rndix
	sty	_rndiy
	rts


; ----
; random
; ----
; return a random number in the interval 0 <= x < A
; ----
; IN  : A = range (1 - 128)
; ----
; OUT : A = random number
; ----

random:
	pha
	jsr	rand
	pla
	; ----
	cmp	#128
	blo	.l1

	lda	<_dh
	rts

.l1:	asl	A
	sta	<_al
	lda	<_dh
	sta	<_bl
	jsr	mulu8

	lda	<_ch
	rts

