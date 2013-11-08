;
; BALL.ASM
;

	.include "startup.asm"

; ----
; sprite addresses

SATB_BASE	.equ $7F00
SPRITE_BASE	.equ $4000
SPR_GROUP	.equ SPRITE_BASE
BALL_A		.equ SPR_GROUP
BALL_B		.equ SPR_GROUP+$100

; ----
; demo variables

	.bss
sx	.ds 2	; the sprite coordinates
sy	.ds 2
y_idx   .ds 2   ; index in the y coordinate table (0-63)
flag	.ds 1	; used to remember in which direction the ball moves
cnt	.ds 1	; counter used for loops
satb	.ds 512	; the local SATB

; ----
; ball demo main routine

	.code
	.bank MAIN_BANK
	.org  $C000
main:
	; upload the sprite in VRAM, the ball is 32x32 in size

	load_sprites BALL_A,ball,#1

	; initialize the local SATB (hide all the 64 sprites)

	init_satb satb

	; initialize our lovely ball

	stw   #((256-32)/2),sx	; that will center it on the screen
	stw   #((224-32)/2),sy

	spr_set #0,satb
	spr_x sx,#32
	spr_y sy,#56
	spr_pattern #BALL_A
	spr_ctrl  #SIZE_MASK|FLIP_MASK,#SIZE_32x32|NO_FLIP
	spr_pri   #1
	spr_pal   #0

	; vsync before setting the palette, to avoid snow

	vsync

	; set the sprite palette

	map   ball_colors
	set_sprpal #0,ball_colors

	; we are now ready to move the ball!
.anim:
	vsync
.go:
	lda   flag		; check in which direction to move the ball
	bne   .up
.down:
	cmpw  #45,y_idx		; that will be down
	beq   .swap
	incw  y_idx
	bra   .update
.up:
	cmpw  #0,y_idx		; or up
	beq   .swap
	decw  y_idx
	bra   .update
.swap:
	lda   flag		; change the ball direction
	eor   #$1
	sta   flag
	bra   .go
.update:
	stw   #y_table,<_si	; get the y coordinate in the y index
	lda   y_idx		; table: sy = y_table[y_idx]
	asl   A
	tay
	lda   [_si],Y
	sta   sy
	iny
	lda   [_si],Y
	sta   sy+1

	spr_set #0,satb		; select sprite
	spr_x sx,#32		; set coordinates
	spr_y sy,#56
	spr_pattern #BALL_A	; set pattern

	cmpw  #43,y_idx		; different pattern (flattened ball)
	blo   .satb		; when y_idx >= 43
	spr_pattern #BALL_B
.satb:
	update_satb satb	; upload the BAT in VRAM

	jmp   .anim		; and loop again and again

; ----
; the sprite data

	.bank MAIN_BANK+1
	.org  $6000
ball:
	.incspr "ball.pcx",0,0,2,2	; ball A
	.incspr "ball.pcx",32,0,2,2	; ball B
ball_colors:
	.defpal $000,$000,$000,$000,$000,$000,$000,$000,\
		$000,$221,$332,$443,$554,$665,$776,$777
y_table:
	.dw 107,107,108,109,110,111,112,113
	.dw 114,115,116,117,118,119,120,122
	.dw 123,124,126,127,129,130,132,133
	.dw 135,137,139,141,143,145,147,149
	.dw 152,155,158,161,164,168,172,177
	.dw 183,189,195,195,196,196

