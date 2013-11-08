; SAMPLE2.ASM - Sample program to print calculated digits
;		into the BGMAP
;
;

        .include "startup.asm"
	.nomlist
	.list


; Zero-page variables

	.zp

ptr:	.ds   2 	; pointer to buffer address
a_cnt:	.ds   1
x_cnt:	.ds   1

	;...


;--- CODE area ----------

	.code
	.bank MAIN_BANK
	.org  $C000

main:	map    offchar		; map in the memory bank

	; load blank character into VRAM:

	vload  offchar,#16

	vsync			; vsync to avoid snow
	set_bgpal #0,cgpal,#1	; fill palette #0


; blank the background

	setvwaddr  $0		; set the VRAM address to $0000

	lda   #32		; size 32 lines tall
.l1:	ldx   #64		; size 64 chars wide
	pha
.l2:	cly

	; Fill each BAT map position with blank character

	stw   #CHAR(offchar),video_data

	dex			; next block
	bne   .l2
	pla
	dec   A 		; next line
	bne   .l1


	; load the characters for 0-9,A-F
	; into $1000 - $1100 in VRAM
	; (each character uses 16 words)

	vload  zero,#16*16


; print on the background

	stw   #buffer,<ptr	; set pointer to look at buffer

	lda   #1		; line #1 of 29 (line #0 is not viewable)
	sta   <a_cnt

.pr1:	ldx   #8		; read 8 bytes out
	stx   <x_cnt

	cla			; line number in _di
	sta   <_di+1
	lda   <a_cnt
	sta   <_di

	aslw  <_di		; multiply by $40 chars/line, to find address
	aslw  <_di		; of start-of-line (use a 6-bit left-shift)
	aslw  <_di
	aslw  <_di
	aslw  <_di
	aslw  <_di

	jsr   set_write 	; set VRAM write address

.pr2:	lda   [ptr]		; get byte
	tax			; preserve

	lsr   a 		; use top nybble
	lsr   a
	lsr   a
	lsr   a
	sta   video_data	; store char # (0-F) (LSB of VRAM word)
	st2   #$01		; MSB of VRAM word: palette #0, base addr $1000

	txa			; restore byte
	and   #$0F		; use bottom nybble
	sta   video_data	; store char # (0-F) (LSB of VRAM word)
	st2   #$01		; MSB of VRAM word: palette #0, base addr $1000

	stw   #CHAR(offchar),video_data 	; put space

	incw  <ptr		; point to next char

	dec   <x_cnt		; next block
	bne   .pr2

	inc   <a_cnt
	lda   <a_cnt
	cmp   #$30		; size 30 lines tall yet ?
	bne   .pr1


.here:	bra    .here

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
zero:	  .defchr $1000,0,\
	  $00111110,\
	  $01000011,\
	  $01000101,\
	  $01001001,\
	  $01010001,\
	  $01100001,\
	  $00111110,\
	  $00000000

one:	  .defchr $1010,0,\
	  $00001000,\
	  $00011000,\
	  $00001000,\
	  $00001000,\
	  $00001000,\
	  $00001000,\
	  $00011100,\
	  $00000000

two:	  .defchr $1020,0,\
	  $00111110,\
	  $01000001,\
	  $00000001,\
	  $00111110,\
	  $01000000,\
	  $01000000,\
	  $01111111,\
	  $00000000

three:	  .defchr $1030,0,\
	  $00111110,\
	  $01000001,\
	  $00000001,\
	  $00011110,\
	  $00000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

four:	  .defchr $1040,0,\
	  $00000010,\
	  $00100010,\
	  $00100010,\
	  $00111111,\
	  $00000010,\
	  $00000010,\
	  $00000010,\
	  $00000000

five:	  .defchr $1050,0,\
	  $01111111,\
	  $01000000,\
	  $01000000,\
	  $00111110,\
	  $00000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

six:	  .defchr $1060,0,\
	  $00111110,\
	  $01000000,\
	  $01000000,\
	  $01111110,\
	  $01000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

seven:	  .defchr $1070,0,\
	  $00111111,\
	  $00000001,\
	  $00000001,\
	  $00000010,\
	  $00000100,\
	  $00001000,\
	  $00001000,\
	  $00000000

eight:	  .defchr $1080,0,\
	  $00111110,\
	  $01000001,\
	  $01000001,\
	  $00111110,\
	  $01000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

nine:	  .defchr $1090,0,\
	  $00111110,\
	  $01000001,\
	  $01000001,\
	  $00111111,\
	  $00000001,\
	  $00000001,\
	  $00111110,\
	  $00000000

ten:	  .defchr $10A0,0,\
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
cgpal:	.defpal $000,$777,$777,$777,\
		$777,$777,$777,$777,\
		$777,$777,$777,$777,\
		$777,$777,$777,$777

;
; Just a bunch of hex digits to print out
;
buffer:
	db   $00,$01,$02,$03,$04,$05,$06,$07
	db   $08,$09,$0A,$0B,$0C,$0D,$0E,$0F
	db   $10,$11,$12,$13,$14,$15,$16,$17
	db   $18,$19,$1A,$1B,$1C,$1D,$1E,$1F
	db   $20,$21,$22,$23,$24,$25,$26,$27
	db   $28,$29,$2A,$2B,$2C,$2D,$2E,$2F
	db   $30,$31,$32,$33,$34,$35,$36,$37
	db   $38,$39,$3A,$3B,$3C,$3D,$3E,$3F
	db   $40,$41,$42,$43,$44,$45,$46,$47
	db   $48,$49,$4A,$4B,$4C,$4D,$4E,$4F
	db   $50,$51,$52,$53,$54,$55,$56,$57
	db   $58,$59,$5A,$5B,$5C,$5D,$5E,$5F
	db   $60,$61,$62,$63,$64,$65,$66,$67
	db   $68,$69,$6A,$6B,$6C,$6D,$6E,$6F
	db   $70,$71,$72,$73,$74,$75,$76,$77
	db   $78,$79,$7A,$7B,$7C,$7D,$7E,$7F
	db   $80,$81,$82,$83,$84,$85,$86,$87
	db   $88,$89,$8A,$8B,$8C,$8D,$8E,$8F
	db   $90,$91,$92,$93,$94,$95,$96,$97
	db   $98,$99,$9A,$9B,$9C,$9D,$9E,$9F
	db   $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7
	db   $A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
	db   $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7
	db   $B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
	db   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
	db   $C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
	db   $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7
	db   $D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
	db   $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
	db   $E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
	db   $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7
	db   $F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF

