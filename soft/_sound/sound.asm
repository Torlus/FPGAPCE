;	.include "startup.asm"
	
	.include "macro.inc"
	.list
	
START_BANK	.equ	0
MAIN_BANK	.equ	START_BANK+1

	.code
	.bank START_BANK

    ; ----
    ; interrupt vectors

	.org  $FFF6

	.dw _irq2
	.dw _irq1
	.dw _timer
	.dw _nmi
	.dw _reset

	.org  $E010
_reset:
	sei			; disable interrupts 
	cld			; clear the decimal flag 
	ldx   #$FF		; initialize the stack pointer
	txs 
	lda   #$FF		; map the I/O bank in the first page
	tam   #0
	lda   #$F8		; and the RAM bank in the second page
	tam   #1

	map	main
	jmp main

_irq2:
	rti
_irq1:
	rti
_timer:
	rti
_nmi:
	rti

	.code
	.bank MAIN_BANK
	.org  $C000
main:
	lda	#$FF
	sta	$0801		; Global sound balance
	
	lda	#$00
	sta	$0800		; Channel select
	
	lda	#$40
	sta	$0804		; ON=0 DDA=1
	lda #$00
	sta	$0804		; ON=0 DDA=0 (resets waveform index)
	
	lda	#$0E
	sta	$0806
	lda	#$11
	sta	$0806
	lda	#$14
	sta	$0806
	lda	#$16
	sta	$0806
	lda	#$18
	sta	$0806
	lda	#$1A
	sta	$0806
	lda	#$1C
	sta	$0806
	lda	#$1D
	sta	$0806
	lda	#$1D
	sta	$0806
	lda	#$1D
	sta	$0806
	lda	#$1C
	sta	$0806
	lda	#$1A
	sta	$0806
	lda	#$18
	sta	$0806
	lda	#$16
	sta	$0806
	lda	#$14
	sta	$0806
	lda	#$11
	sta	$0806
	lda	#$0E
	sta	$0806
	lda	#$0B
	sta	$0806
	lda	#$08
	sta	$0806
	lda	#$06
	sta	$0806
	lda	#$04
	sta	$0806
	lda	#$02
	sta	$0806
	lda	#$01
	sta	$0806
	lda	#$00
	sta	$0806
	lda	#$00
	sta	$0806
	lda	#$00
	sta	$0806
	lda	#$01
	sta	$0806
	lda	#$02
	sta	$0806
	lda	#$04
	sta	$0806
	lda	#$06
	sta	$0806
	lda	#$08
	sta	$0806
	lda	#$0B
	sta	$0806
	
	
	lda #$FF
	sta $0805		; Channel balance
	
	lda #$00
	sta	$0803
	lda #$FE
	sta $0802		; Frequency (440 Hz)
	
	lda #$9F
	sta	$0804		; ON=1 DDA=0 AL=$1F (starts output)
	
	
endloop:
	;vsync
	jmp	endloop

