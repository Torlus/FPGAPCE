;
; SLIDSHOW.ASM
;

_xres	.equ 320	; set this before including 'startup.asm'
			; that will set up a 320x240 screen in place
			; of the default 256x240 screen

	.include "startup.asm"
	.nomlist
	.list

; ----
; defines

NB_PICS	  .equ 4	; the number of pictures in the slideshow

; ----
; variables

	  .zp
pic:	  .ds  1	; the current picture number
pic_bank: .ds  1	; picture bank index


;±±±[ MAIN CODE ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

	.code
	.bank MAIN_BANK
	.org  $C000
main:
    ; ----
    ; disable display

	jsr   disp_off
	vsync

    ; ----
    ; load the picture in VRAM

	jsr   load_pic

    ; ----
    ; enable display

	jsr   disp_on
	vsync

    ; ----
    ; wait that the user presses a button
.l1:
	vsync			; synchro
	tst   #$03,joytrg	; button pressed?
	beq  .l1

    ; ----
    ; next picture - loop if was the last one

	inc   <pic
	lda   <pic
	cmp   #NB_PICS
	blo   main
	stz   <pic
	jmp   main


;±±±[ SUB CODE ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; ----
; load_pic
; ----
; upload a whole pic in VRAM
; ----

load_pic:

	lda   <pic		; get the current pic number

	asl   A			; mul it by 6 (each picture takes six banks;
	sta   <pic_bank		; five for the graphics and one for the BAT
	asl   A			; and the palette)
	add   <pic_bank

	add   #BANK(pic_0)	; add the bank index of the first picture

	sta   <pic_bank		; store the bank index

    ; ----
    ; load the graphic in VRAM, one bank at a time
	
	lda   <pic_bank		; first bank
	tam   #2
	vload $1000,$4000,#$1000
	inc   <pic_bank		; second bank
	lda   <pic_bank
	tam   #2
	vload $2000,$4000,#$1000
	inc   <pic_bank		; third bank
	lda   <pic_bank
	tam   #2
	vload $3000,$4000,#$1000
	inc   <pic_bank		; fourth bank
	lda   <pic_bank
	tam   #2
	vload $4000,$4000,#$1000
	inc   <pic_bank		; fifth bank
	lda   <pic_bank
	tam   #2
	vload $5000,$4000,#$1000

    ; ----
    ; vsync before setting the palette - to avoid snow

	vsync

    ; ----
    ; now set the palette

	inc   <pic_bank
	lda   <pic_bank
	tam   #4
	set_bgpal #0,$8000,#16

    ; ----
    ; and finaly copy the BAT

	batcpy $0,\
	       $8200,\
	       #40,\
	       #30

    ; ----
    ; ok, done

	rts


;±±±[ PICTURE DATA ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

	.data

    ; ----
    ; pictures can contain up to 256 colors, but as you know the
    ; PC-Engine can display only 16 colors per 8x8 tile, so be careful
    ; when making pictures. And also take care of the color alignment,
    ; a tile can use, for example, color 0 to 15, but not color 4 and
    ; color 26 and color 125, all the colors used in a tile must
    ; belong to the same sub-palette (colors 0 - 15, 16 - 31, etc...)
    ;
    ; if you have problems making 256 color pictures that the assembler
    ; accepts, switch to 16 colors PCX files, they are also supported
    ; and with them no problem :)

PIC_BANK .func (((\1)*6)+MAIN_BANK+1)	; a little function to help
					; referencing banks

PIC	.macro				; hmm a macro could be handy too...
	 .bank PIC_BANK(\1)
	 .org  $8000
pic_\1:	 .incchr \2,40,30
	 .bank PIC_BANK(\1)+5
	 .org  $8000
	 .incpal \2
	 .org  $8200
	 .incbat \2,$1000,40,30
	.endm

	PIC 0,"tetris3.pcx"		; what would we do without macros? :)
	PIC 1,"tetris1.pcx"
	PIC 2,"tetris4.pcx"
	PIC 3,"tetris2.pcx"

    ; ----
    ; etc... up to 21 pictures.
    ;
    ; at your turn now, make us some cool slideshow!

