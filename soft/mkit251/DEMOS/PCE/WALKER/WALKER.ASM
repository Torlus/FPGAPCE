; WALKER.ASM - a PCE Sprite demo, written by Bt Garner with assistance
; from David Michel (btgarner@mindspring.com, dmichel@easynet.fr)
; This code may be used freely as long as proper credit is given

	.include "startup.asm"
	.mlist
	.list

        ; sprite defines

SATB_BASE     .equ $7F00
SPRITE_BASE   .equ $4000
SPR_GROUP     .equ SPRITE_BASE
SPRITES       .equ SPR_GROUP

        ; the variables

	.bss
sx	.ds 2   ; the sprite coordinates
sy	.ds 2
flag	.ds 2   ; used to remember in which direction the ball moves
cnt	.ds 2   ; counter used for loop
sflag	.ds 2	; animation direciton (0 or 1)
csp	.ds 2   ; sprite currently to be displayed (0 .. 7)
spr_c	.ds 2	; counter for sprite animation (5->0)

satb	.ds 512 ; the local SATB

; ----
; walker demo

	.code
	.bank MAIN_BANK
	.org  $C000
main:
        ; upload the sprites in VRAM

        load_sprites SPRITES,sprite_bank_1,#8

        ; initialize the local SATB (hide all the 64 sprites)

	init_satb satb

 	; initialize variables

        stw #((256-32)/2+32),sx  ; that will center the sprite on the screen
        stw #((240-64)/2+64),sy
;	stw #32,sx

	stw	#1,spr_c
	stw	#3,csp
	stw	#0,sflag
	stw	#1,flag

	; vsync before setting the palette, to avoid snow

	vsync

        ; upload the sprite palette

	map    spr_palette
        set_sprpal #0,spr_palette,#16

	; This is the start of the main loop

walk:
	vsync			; synchronize the program on the vblank
	                  	; interrupt
.go:
        lda 	flag        	; check in which direction to move the sprite
        bne 	.left

.right:                  	; Move the sprite to the right
        addw	#1,sx		; increment the sx variable
        cmpw	#(256+32),sx	; check to see if we're at the display's right edge
        beq   	.swap		; Yes? Change the direction flag
        bra   	.update		; No?  fall through

.left:                   	; Move the sprite to the left
        subw	#1,sx		; decrement the sx variable
        cmpw 	#0,sx		; check to see if we're at the display's left edge
        beq   	.swap		; Yes? Change the direction flag
        bra   	.update		; No?  fall through

.swap:                  	; change the sprite's direction
        lda 	flag		; load variable "flag" into register A
        eor 	#$1		; exclusive OR on A with 1
        sta 	flag		; store register A in variable "flag"
        bra 	.update		; fall through

.update:
	addw	#1,spr_c	; decrement the sprite update counter
	cmpw	#5,spr_c	; check to see if it has reached 0
	bne	.aupdate	; No? Don't alter the sprite to display
				; Yes: Fall through
	stw	#0,spr_c	; re-prime the sprite update counter
        lda 	sflag        	; check in which direction to animate the sprite
        bne 	.dec		; branch appropriately

.inc:                  		; increase the sprite to display
        addw	#1,csp		; add 1 to variable "csp"
	lda	csp		; load variable "csp" into Register A
        cmp 	#5		; check if we're at the last sprite (5)
        beq   	.aswap		; if so, change the animation direction variable
        bra   	.aupdate	; else move to updating the display

.dec:                   	; decrease the sprite to display
        subw	#1,csp		; subtract 1 from current sprite
	lda	csp		; load variable "csp" into "A" register
        cmp  	#1		; check if we're at the first sprite (1)
        beq   	.aswap		; if so, change the animation direction variable
        bra   	.aupdate	; else move to updating the display

.aswap:                  	; change the animation direction
        lda 	sflag
        eor 	#$1
        sta 	sflag
        bra 	.aupdate

.aupdate:
        spr_set #0,satb		; set the sprite that we want to display 
        lda 	flag		; check the direction flag
        bne 	.flip		; right (flag != 0), fall through
.noflip:
	spr_ctrl  #SIZE_MASK|FLIP_MASK,#SIZE_32x64|NO_FLIP
	bra 	.finish		; skip over the (flag == 0) code

.flip:
	spr_ctrl  #SIZE_MASK|FLIP_MASK,#SIZE_32x64|FLIP_X
	bra	.finish		; fall throguh

.finish:
        spr_x 	sx		; set the sprite's x and y variables
        spr_y 	sy

	lda 	csp		; this is a case statement to determine
				; which sprite to display
        cmp 	#1
        beq 	.spr_1
        cmp	#2
        beq	.spr_2
        cmp	#3
        beq	.spr_3
        cmp	#4
        beq	.spr_4
        cmp	#5
        beq	.spr_5

.resume:
        spr_pri		#1	; these do not need to be here, but are so
        spr_pal 	#0	; that other programs can modify them 
				; the next line actually does all the work
        update_satb 	satb,SATB_BASE

        jmp walk  	     ; repeat (ad nauseum)


.spr_1:
        spr_pattern #(SPRITES+($200*1))
        bra .resume
.spr_2:
        spr_pattern #(SPRITES+($200*2))
        bra .resume
.spr_3:
        spr_pattern #(SPRITES+($200*3))
        bra .resume
.spr_4:
        spr_pattern #(SPRITES+($200*4))
        bra .resume
.spr_5:
        spr_pattern #(SPRITES+($200*5))
        bra .resume


; the sprite data

        .bank MAIN_BANK+1
	.org  $6000


sprite_bank_1:	.incspr "walker5.pcx",  0,0,2,4 
		.incspr "walker5.pcx", 32,0,2,4 
		.incspr "walker5.pcx", 64,0,2,4 
		.incspr "walker5.pcx", 96,0,2,4 
		.incspr "walker5.pcx",128,0,2,4 
		.incspr "walker5.pcx",160,0,2,4 
		.incspr "walker5.pcx",192,0,2,4 
		.incspr "walker5.pcx",224,0,2,4 

spr_palette:	.incpal "walker5.pcx",0,16
;spr_palette:	.dw 	$0,$8,$10,$18,$20,$28,$30,$38
;		.dw 	$0,$8,$10,$18,$20,$28,$30,$38

