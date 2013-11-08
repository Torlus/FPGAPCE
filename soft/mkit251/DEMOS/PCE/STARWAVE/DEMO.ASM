;
; DEMO.ASM  -  First PCE Engine demo 
;

	.include "startup.asm"
	.nomlist
	.list

; ----
; demo variables

		.zp
scanline:	.ds 2	; the line number for the scanline interrupt

	; wavy scroll

wave_base:	.ds 1	; base index for the wave table
wave_idx:	.ds 1	; index in the wave table

	; scroll text

txt_flag:	.ds 1	; event flag
txt_offset:	.ds 2	; scroll offset
txt_ptr:	.ds 2	; pointer in the text string
txt_pos:	.ds 1	; screen position for the next character
txt_width:	.ds 1	; width of a character
txt_char:	.ds 1	; current character

	; sprites

spr_idx:	.ds 1   ; sprite index in the SATB
star_pattern:	.ds 1	; star sprite index 
angle_base:	.ds 1	; star starting position
angle:			; star position in the circle
angle_l:	.ds 1
angle_h:	.ds 1
radius:		.ds 1	; circle radius
zoom:		.ds 1	; direction of the zoom

		.bss
satb:		.ds 512	; the local SATB in RAM

; ----
; ball demo main routine

	.code
	.bank MAIN_BANK
	.org  $C000
main:
	jsr   init_screen	; initialize the screen
	jsr   init_scroll	; initialize the scroll-text
	jsr   init_sprites	; initialize the sprites

	; set interrupt vector

	setvec #HSYNC,hsync_proc
	vec_on #HSYNC
	smb    #7,<irq_m

	; enable HSYNC interrupt

	vreg  #5
	lda   #$CC
	sta   video_data_l
	sta   vdc_crl

	; the main loop, here we rotate the stars
	; and scroll the text window

.loop:	vsync		       	; synchro
	jsr   vsync_proc
	jsr   star_circle	; update the sprite positions
	jsr   scroll_text	; update the scroll text
	update_satb satb	; update the SATB
	bra   .loop	       	; continue again and again!!

;±±±[ SUB CODE ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; ----
; star_circle
; ----
; draw a circle of stars
; ----

star_circle:

	; set circle starting angle

	lda   <angle_base
	sta   <angle_h
	stz   <angle_l
	inc   <angle_base
	inc   <star_pattern

	; update the radius - zoom effect

	lda   <radius
	ldx   <zoom
	bne   .in
.out:
	inc   A			; add
	cmp   #106
	blo   .set
	dec   <zoom
.in:
	dec   A			; sub
	cmp   #65
	bhs   .set
	inc   <zoom
	inc   A
.set:
	sta   <radius

	; calculate the position of the 12 stars

	lda   #11		; sprite index and loop counter
	sta   <spr_idx
.l1:
	lda   <radius		; get star position
	sta   <_al
	lda   <angle_h
	sta   <_bl
	jsr   rotate

	spr_set <spr_idx,satb	; select the sprite

	addw  #140,<_cx		; set position
	addw  #152,<_dx
	spr_y <_cx
	spr_x <_dx

	lda   <star_pattern	; set pattern
	lsr   A
	and   #$06
	sta   <_al
	stz   <_ah
	addw  #SPR_VRAM(stars),<_ax
	spr_pattern <_ax

	addw  #$1556,<angle	; update star position

	dec   <spr_idx
	bmi   .l2
	jmp   .l1
.l2:
	rts

; ----
; rotate
; ------
; rotate a point
; ----
; IN:   _AL = radius  (0 - 127)
;       _BL = angle in degree (0-255)
;
; OUT:  _CX/_DX = signed 16bit coordinates
; ----

rotate:
	; calculate Y coordinate

.y:
	ldx   <_bl
	lda   .sine,X
	bsr   .muls
	sta   <_cl
	stz   <_ch
	bit   #$80
	beq   .x
	lda   #$FF
	sta   <_ch

	; calculate X coordinate

.x:
	lda   <_bl
	add   #64
	tax
	lda   .sine,X
	bsr   .muls
	sta   <_dl
	stz   <_dh
	bit   #$80
	beq   .exit
	lda   #$FF
	sta   <_dh
	
	; ok

.exit:
	rts

	; multiplication sub-routine

.muls:
	clx
	bit   #$80
	beq   .s1
	inx
	neg
.s1:	asl   A
	sta   <_ah

	cla
	ldy   #7
.l1:
	asl   a
	rol   <_ah
	bcc   .s2
	add   <_al
	bcc   .s2
	inc   <_ah
.s2:
	dey
	bne   .l1
	lda   <_ah
	cpx   #0
	beq   .s3
	neg
.s3:	rts

	; the sine table
.sine:
	.include "sin.inc"

; ----
; scroll_text
; ----
; update the scroll text
; ----

scroll_text:

	lda   <txt_offset
	and   #$7
	lbne  .s3

	; check if a new character is needed

	inc   <txt_char
	dec   <txt_width
	bpl   .s2

	; extract a character from the text string

	lda   [txt_ptr]		; get the character
	bne   .s1
	stw   #text,<txt_ptr	; loop if end reached
	lda   text
.s1:
	incw  <txt_ptr		; update the text pointer
	sub   #32		; adjust character index
	tax			; get the width of the character
	ldy   char_width,X
	sty   <txt_width
	asl   A			; store the character index
	sta   <txt_char

	; calculate the character VRAM address

.s2:	lda   <txt_char
	sta   <_al
	and   #$60
	asl   A
	sta   <_ah
	lda   <_al
	and   #$1F
	ora   <_ah
	sta   <_dl
	stz   <_dh
	addw  #CHAR(font),<_dx

	; copy the character

	vreg  #5		; change the VRAM increment to 64
	st2   #$10

	vreg  #0		; set the VRAM write address
	lda   <txt_pos
	sta   video_data
	st2   #$05

	vreg  #2		; copy the data
	stw   <_dx,video_data
	addw  #$20,<_dx
	stw   <_dx,video_data

	vreg  #5		; VRAM increment back to 1
	st2   #$00

	; incremente the position of the character

	lda   <txt_pos
	inc   A
	and   #$3F
	sta   <txt_pos

	; incremente scroll offset

.s3:	addw  #2,<txt_offset
	rts

;±±±[ INTERRUPT CODE ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; ----
; vsync_proc
; ----
; called every VSYNC
; ----

vsync_proc:
	vreg  #6		; restart the scanline counter on the first
	stw   #$40,video_data	; line
	stw   #$40,<scanline
	lda   <wave_base	; change the index base for the wavy
	add   #4		; scrolling
	sta   <wave_base
	sta   <wave_idx
	rts

; ----
; hsync_proc
; ----
; called every HSYNC
; ----

hsync_proc:

	; update the scrolling

	lda   <scanline		; check in what area we are
	cmp   #224
	blo   .water
	cmp   #239
	bhs   .water
.text:
	st0   #7		; text area
	stw   <txt_offset,video_data
	bra   .update
.water:
	st0   #7		; water area
	lda   <wave_idx
	lsr   A
	lsr   A
	tax
	lda   .wave,X
	sta   video_data
	stz   video_data+1
.update:
	lda   <scanline		; update index in the
	bit   #$03		; wave table
	bne   .scanline
	inc   <wave_idx

	; reprogram the scanline counter for the next line

.scanline:
	st0   #6
	incw  <scanline
	stw   <scanline,video_data
	rts

	; the wave table

.wave:	.db   5,6,7,8,8,9,9,10,10,10,9,9,8,8,7,6
	.db   5,4,3,2,2,1,1,0,0,0,1,1,2,2,3,4
	.db   5,6,7,7,8,8,9,9,9,9,9,8,8,7,7,6
	.db   5,4,3,3,2,2,1,1,1,1,1,2,2,3,3,4

;±±±[ INIT CODE ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; ----
; init_screen
; ----
; setup the screen for the demo, upload all the data, set the palettes
; and fill the background with the water pattern
; ----

init_screen:
	map   stars		; map the sprite bank and the font
	map   font		; bank in the memory

	; copy all the data to the VRAM

	vload stars,#64*4
	vload water,#16*4
	vload font, #16*256

	; vsync before setting the palette, to avoid snow

	vsync

	; initialize the palette

	set_sprpal #0,stars_pal,#3
	set_bgpal  #0,water_pal,#2
	set_bgpal  #2,font_pal,#1

	; fill the background

	stw   #.scrtab,<_si	; address of the character table
	setvwaddr #$0		; set the VRAM write address

	lda   #32		; 32 lines of 32 blocks, each block
.l1:	ldx   #32		; is two 8x8 characters
	pha 
.l2:	cly			; we fill each line with two words
	lda   [_si],Y		; from the table
	iny			
	sta   video_data_l
	lda   [_si],Y
	iny
	sta   video_data_h
	lda   [_si],Y
	iny
	sta   video_data_l
	lda   [_si],Y
	iny
	sta   video_data_h
	dex			; next block
	bne   .l2
	addw  #4,<_si		; update the table pointer
	pla
	dec   A			; next line
	bne   .l1
	rts

	; water background table, two words per line

.scrtab:.dw   $0100,$0101,$0102,$0103,$0100,$0101,$0102,$0103
	.dw   $0100,$0101,$0102,$0103,$0100,$0101,$0102,$0103
	.dw   $0100,$0101,$0102,$0103,$0100,$0101,$0102,$0103
	.dw   $0100,$0101,$0102,$0103,$0100,$0101,$0102,$0103
	.dw   $0100,$0101,$0102,$0103,$0100,$0101,$0102,$0103
	.dw   $2200,$2200,$2220,$2220,$1100,$1101,$0102,$0103
	.dw   $0100,$0101,$0102,$0103,$0100,$0101,$0102,$0103
	.dw   $0100,$0101,$0102,$0103,$0100,$0101,$0102,$0103

; ----
; init_scroll
; ----
; reset the position of the scroll text
; ----

init_scroll:
	lda   #32
	sta   <txt_pos
	stw   #text,<txt_ptr
	rts

; ----
; init_sprites
; ----
; setup the sprites
; ----

init_sprites:
	init_satb satb		; reset the local RAM SATB

	tii   .tbl,satb,8*12	; initialize the 12 star sprites

	lda   #65		; set star circle radius to 65
	sta   <radius
	rts

	; table for initializing the sprites

.tbl:	.dw   120,152,SPR_VRAM(stars),$80
	.dw   120,152,SPR_VRAM(stars),$81
	.dw   120,152,SPR_VRAM(stars),$82
	.dw   120,152,SPR_VRAM(stars),$80
	.dw   120,152,SPR_VRAM(stars),$81
	.dw   120,152,SPR_VRAM(stars),$82
	.dw   120,152,SPR_VRAM(stars),$80
	.dw   120,152,SPR_VRAM(stars),$81
	.dw   120,152,SPR_VRAM(stars),$82
	.dw   120,152,SPR_VRAM(stars),$80
	.dw   120,152,SPR_VRAM(stars),$81
	.dw   120,152,SPR_VRAM(stars),$82

;±±±[ DATA ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

	.bank MAIN_BANK+1
	.org $8000

	; palettes

stars_pal:
	.incpal "block.pcx",1
	.incpal "block.pcx",4,2
water_pal:
	.incpal "block.pcx",0
	.incpal "block.pcx",3
font_pal:
	.incpal "block.pcx",2

	; sprites and water

stars:	.vram $4000
	.incspr "block.pcx",0,80,4,1
water:	.vram $1000
	.incchr "block.pcx",0,96,2,2

	; scroll text

text:
	.db "                                "
	.db "YO!!  THE MAGIC TEAM IS PROUD TO PRESENT... THE FIRST "
	.db "PC ENGINE DEMO!    "
	.db "IT'S NOT MUCH AND SOUND IS MISSING "
	.db "BUT IT'S JUST THE BEGINNING :)    "
	.db "AT LEAST WE HOPE IT WILL "
	.db "GIVE YOU THE ENVY TO MAKE NEW DEMOS!    "
	.db "AND PERHAPS WE WILL HAVE SOON "
	.db "A GREAT DEMO SCENE ON THE PC ENGINE...  WHO KNOWS!"
	.db "                                "
	.db "CREDITS :  CODE BY RONY AND GFX BY PHOENIX."
	.db "                                "
	.db "GREETINGS TO ALL OUR FRIENDS "
	.db "AND TO ALL THE TGHACK-LIST MEMBERS!!"
	.db "                                "
	.db "                                "
	.db " RESTARTING..."
	.db "                                "
	.db 0

	; character width (8 or 16)

char_width:
	.db 0,0,1,1,1,1,1,0,0,0,1,1,0,1,0,1
	.db 1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1
	.db 1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1
	.db 1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,1

	.bank MAIN_BANK+2
	.org $A000

	; 16x16 font

font:	.vram $2000
	.pal  2
	.incchr "block.pcx",0,0,32,8

