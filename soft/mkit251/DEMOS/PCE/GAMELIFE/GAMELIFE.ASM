;
; GAMELIFE.ASM
; ------------
;
; This program is Conway's 'game of life' for the PC-Engine,
; created using the MagicKit assembler.
;
; You've all seen this simulation before, but maybe didn't know its name
;
; Actually, this may not be the exact live/die algorithm from Conway;
; I wrote it from memory; I think it may create too many 'births'
;
;
; There are lots of little variables to play around with and recompile,
; for those who are interested...
;
; You can easily change the display character, colour, and speed
; of the simulation... and of course, the starting map.
;
; Have fun !
;

		.include "startup.asm"

;
;---[ RESERVED VARIABLES ]------------------------------------------------------
;

; Zero Page area:

		.zp

dspfldptr:	.ds	2	; pointer to display field
cntfldptr:	.ds	2	; pointer to counter field
tmpptr:		.ds	2	; temporary field pointer

xcnt:		.ds	1	; temporary x counter
ycnt:		.ds	1	; temporary y counter

; Safe area in RAM:

		.bss

dispfld:	.ds	32*32 	; field for display of items
cntfld:		.ds	32*32 	; field for counting of items


;---[ USER PROGRAM ]------------------------------------------------------------

		.code
		.bank MAIN_BANK
		.org  $C000

main:
		map	offchr		; map in the memory bank

		vload	offchr,#2*16	; load blank&full characters into VRAM

		vsync			; vsync to avoid snow
		set_bgpal #0,palette	; fill palette #0

; initialize variables

		jsr	clrcntfld	; clear the count field area
		jsr	clrdspfld	; clear the display field area

		; initialize dispfld from bgfld:
		;
		tii	bgfld,dispfld,32*32

		jsr	dispdspfld	; display the display field area

		vsync
.loop:		vsync   #25		; sync on 25 periods

		jsr	clrcntfld	; clear the count field
		jsr	countnbr	; count neighbours
		jsr	cnt2disp	; format display screen
		jsr	dispdspfld	; display it

		bra	.loop		; repeat


;---[ USER SUBROUTINES ]--------------------------------------------------------

;
; clear the fields (display field or count field):
;

clrcntfld:	stw	#cntfld,<dspfldptr
		bra	clrfld		; use loop in next subroutine

clrdspfld:	stw	#dispfld,<dspfldptr

clrfld:		lda	#32		; size 32 lines tall
.l1:		ldx	#32		; size 32 chars wide
		pha
		cla
.l2:		sta	[dspfldptr]
		incw	dspfldptr
		dex
		bne	.l2
		pla
		dec	a
		bne	.l1
		rts


;
; display the background, from the display field:
;

dispdspfld:	stw	#dispfld,<dspfldptr

		setvwaddr $0		; set the VRAM address to top-right

		lda	#32		; size 32 lines tall
.l1:		ldx	#32		; size 32 chars wide (1st half)
		pha
.l2:		lda	[dspfldptr]
		bne	.on

.off:		stw	#CHAR(offchr),video_data	; display offchr
		bra	.next

.on:		stw	#CHAR(onchr),video_data		; display onchr

.next:		incw	<dspfldptr

		dex			; next block
		bne	.l2
					 
		ldx	#32		; size 32 chars wide (second half)
					; (this is virtual 64 wide mode)

.l3:		stw	#CHAR(offchr),video_data	; fill with blanks
		dex
		bne	.l3

		pla
		dec	a 		; next line
		bne	.l1

		rts


;
; fill the display field from count field's data:
;

cnt2disp:	stw	#dispfld,<dspfldptr
		stw	#cntfld,<cntfldptr

		lda	#32		; size 32 lines tall
.l1:		ldx	#32		; size 32 chars wide (first half)
		pha

.l2:		lda	[cntfldptr]	; how many neighbours ?

		cmp	#3
		beq	.l2a		; 2 neighbours (plus self) -> live

		cmp	#4
		beq	.l2a		; 3 neighbours (plus self) -> live

.l2b:		cla			; all else -> die
		sta	[dspfldptr]
		bra	.next

.l2a:		lda	#1
		sta	[dspfldptr]

.next:		incw	<dspfldptr
		incw	<cntfldptr

		dex
		bne	.l2

		pla
		dec	a 		; next line
		bne	.l1

		rts


;
; count neighbours from dispfld into clrfld
;

countnbr	stw	#dispfld,<dspfldptr
		stw	#cntfld,<cntfldptr

		lda	#32		; size 32 lines tall
		sta	<ycnt
.l1:		lda	#32		; size 32 chars wide (first half)
		sta	<xcnt

.l2:		lda	[dspfldptr]	; is this one alive ?
		beq	.next

		bsr	incnbr		; if so, increment his neighbours

.next:		incw	<cntfldptr
		incw	<dspfldptr

		dec	<xcnt
		bne	.l2

		dec	<ycnt
		bne	.l1

		rts

;
; increment the count of the neighbour units:
;

incnbr:		lda	<ycnt
		cmp	#32
		beq	.top
		cmp	#1
		beq	.bottom

.middle:	jsr	incup
		jsr	incmid
		jsr	incdown
		rts

.top:		jsr	incmid
		jsr	incdown
		rts

.bottom:	jsr	incup
		jsr	incmid
		rts


incup:		stw	<cntfldptr,<tmpptr
		subw	#33,<tmpptr
		bra	incline

incmid:		stw	<cntfldptr,<tmpptr
		decw	<tmpptr
		bra	incline

incdown:	stw	<cntfldptr,<tmpptr
		addw	#31,<tmpptr

incline:	ldx	<xcnt
		cpx	#32
		beq	.noleft

		lda	[tmpptr]	; inc neighbour on left
		inc	a
		sta	[tmpptr]

.noleft:	incw	<tmpptr
		lda	[tmpptr]	; inc mid (always)
		inc	a
		sta	[tmpptr]

		cpx	#1
		beq	.noright

		incw	<tmpptr
		lda	[tmpptr]	; inc neighbour on right
		inc	a
		sta	[tmpptr]

.noright:	rts


;---[ USER DATA ]---------------------------------------------------------------

	.bank	MAIN_BANK+1
	.org	$6000

;
; Blank character
;
offchr:	defchr	$1000,0,\
	$00000000,\
	$00000000,\
	$00000000,\
	$00000000,\
	$00000000,\
	$00000000,\
	$00000000,\
	$00000000

;
; Visible character (a squarish 'O')
;
onchr:	defchr	$1010,0,\
	$01111110,\
	$11111111,\
	$11000011,\
	$11000011,\
	$11000011,\
	$11000011,\
	$11111111,\
	$01111110

;
; Single palette entry
;
; entry #0 = black, #1-#15 are all a sort of turquoise
;
palette:	defpal	$000,$157,$157,$157,\
			$157,$157,$157,$157,\
			$157,$157,$157,$157,\
			$157,$157,$157,$157

;
; Couldn't think of a pseudo-random number generator quickly,
; so I created a 'start map'
;
bgfld:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

