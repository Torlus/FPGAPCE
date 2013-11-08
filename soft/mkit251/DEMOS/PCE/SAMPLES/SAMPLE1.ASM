; SAMPLE1.ASM - Sample program which demonstrates printing a
;               short string into the BGMAP
;

        .include "startup.asm"
        .nomlist
        .list

	.code
	.bank MAIN_BANK
        .org  $C000

main:   map    offchar		; map in the memory bank

        ; load blank character into VRAM:

        vload  offchar,#16

	vsync			; vsync to avoid snow
        set_bgpal  #0,cgpal,#1	; fill palette #0


; blank the background

	setvwaddr  $0		; set the VRAM address to $0000

        lda   #32               ; size 32 lines tall
.l1:    ldx   #64               ; size 64 chars wide
        pha
.l2:    cly

	; Fill each BAT map position with blank character

	stw   #CHAR(offchar),video_data

        dex                     ; next block
        bne   .l2
        pla
        dec   A                 ; next line
        bne   .l1


	; load the characters for 0-9,A-F
	; into $1000 - $1100 in VRAM
	; (each character uses 16 words)

        vload  zero,#16*16


; print trivial message on the background, starting
; at BAT address $0100 (a few line down)

        vload  $0100,chars,#16


.here:  bra    .here

        ;...

;±±±[ USER DATA ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

        .bank  MAIN_BANK+1
        .org   $6000

;
; Blank char
;
offchar:  .defchr $0FF0,0,\
	  $00000000,\
	  $00000000,\
	  $00000000,\
	  $00000000,\
	  $00000000,\
	  $00000000,\
	  $00000000,\
	  $00000000

;
; numbers from 0-9,A-F:
;
zero:     .defchr $1000,0,\
	  $00111110,\
	  $01000011,\
	  $01000101,\
	  $01001001,\
	  $01010001,\
	  $01100001,\
	  $00111110,\
	  $00000000

one:      .defchr $1010,0,\
	  $00001000,\
	  $00011000,\
	  $00001000,\
	  $00001000,\
	  $00001000,\
	  $00001000,\
	  $00011100,\
	  $00000000

two:      .defchr $1020,0,\
	  $00111110,\
	  $01000001,\
	  $00000001,\
	  $00111110,\
	  $01000000,\
	  $01000000,\
	  $01111111,\
	  $00000000

three:    .defchr $1030,0,\
	  $00111110,\
	  $01000001,\
	  $00000001,\
	  $00011110,\
	  $00000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

four:     .defchr $1040,0,\
	  $00000010,\
	  $00100010,\
	  $00100010,\
	  $00111111,\
	  $00000010,\
	  $00000010,\
	  $00000010,\
	  $00000000

five:     .defchr $1050,0,\
	  $01111111,\
	  $01000000,\
	  $01000000,\
	  $00111110,\
	  $00000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

six:      .defchr $1060,0,\
	  $00111110,\
	  $01000000,\
	  $01000000,\
	  $01111110,\
	  $01000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

seven:    .defchr $1070,0,\
	  $00111111,\
	  $00000001,\
	  $00000001,\
	  $00000010,\
	  $00000100,\
	  $00001000,\
	  $00001000,\
	  $00000000

eight:    .defchr $1080,0,\
	  $00111110,\
	  $01000001,\
	  $01000001,\
	  $00111110,\
	  $01000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

nine:     .defchr $1090,0,\
	  $00111110,\
	  $01000001,\
	  $01000001,\
	  $00111111,\
	  $00000001,\
	  $00000001,\
	  $00111110,\
	  $00000000

ten:      .defchr $10A0,0,\
	  $00111110,\
	  $01000001,\
	  $01000001,\
	  $01111111,\
	  $01000001,\
	  $01000001,\
	  $01000001,\
	  $00000000

eleven:   .defchr $10B0,0,\
	  $01111110,\
	  $01000001,\
	  $01000001,\
	  $01111110,\
	  $01000001,\
	  $01000001,\
	  $01111110,\
	  $00000000

twelve:   .defchr $10C0,0,\
	  $00111110,\
	  $01000001,\
	  $01000000,\
	  $01000000,\
	  $01000000,\
	  $01000001,\
	  $00111110,\
	  $00000000

thirteen: .defchr $10D0,0,\
	  $01111110,\
	  $01000001,\
	  $01000001,\
	  $01000001,\
	  $01000001,\
	  $01000001,\
	  $01111110,\
	  $00000000

fourteen: .defchr $10E0,0,\
	  $01111111,\
	  $01000000,\
	  $01000000,\
	  $01111110,\
	  $01000000,\
	  $01000000,\
	  $01111111,\
	  $00000000

fifteen:  .defchr $10F0,0,\
	  $01111111,\
	  $01000000,\
	  $01000000,\
	  $01111110,\
	  $01000000,\
	  $01000000,\
	  $01000000,\
	  $00000000

;
; Simple palette entry
;
; entry #0 = black, #1-#15 are all white
;
cgpal:  .defpal $000,$777,$777,$777,\
		$777,$777,$777,$777,\
		$777,$777,$777,$777,\
		$777,$777,$777,$777

;
; characters to place in BAT
;
; This simply prints all characters from 0-9, and A-F in a line
; $0100 = palette #0, pointing at $1000 for character (ie. '0')
;
chars:  dw   $0100,$0101,$0102,$0103
        dw   $0104,$0105,$0106,$0107
        dw   $0108,$0109,$010A,$010B
        dw   $010C,$010D,$010E,$010F

