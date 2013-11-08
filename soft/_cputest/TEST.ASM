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
	;sei			; disable interrupts 
	cli
	;csh			; select the 7.16 MHz clock
	cld			; clear the decimal flag 
	ldx   #$FF		; initialize the stack pointer
	txs 
	lda   #$FF		; map the I/O bank in the first page
	tam   #0
	lda   #$F8		; and the RAM bank in the second page
	tam   #1

	clc
	clv
	lda   #$81
	sta   <$44
	cla
	lda   <$44
	lda   #$20
	sta   <$45
	ldx   #$10
	ldy	  #$11

	csh			; select the 7.16 MHz clock

	asl   a
	asl   <$44
	asl   <$34,X
	asl   $2044
	asl   $2034,X
	bsr   _reset
	;jmp   [$FFFE]

	;lda   <$44
	;lda   <$35,X
	;lda   $2044
	;lda   $2035,X
	;lda   $2033,Y
	;lda   [$44]
	;lda   [$35,X]
	;lda   [$44],Y

	;sta   <$44
	;sta   <$35,X
	;sta   $2044
	;sta   $2035,X
	;sta   $2033,Y
	;sta   [$44]
	;sta   [$35,X]
	;sta   [$44],Y
	
	;bbr0  <$44, _toto
	;lda   [$44]
	;lda   [$44,X]
	;rmb0  <$44
	;jmp   $E010
	;stx   $2000
	tii   $2000,$2001,$0000
	;tii   $2000,$2001,$0002
	;asl   <$44

	sed
	;brk
	nop
	sax
	sxy
_toto:
	nop
	
	;set
	;brk
	;nop
	;stz   $2345,X
	
	;sta   <$34
	st2   #$67
	;tma   #1
	;tam   #4
	tst   #$12, $3456,X
	tst   #$12, <$34,X
	
	;tsb   $E010
	;set
	;ora   #$03
	;brk
	;nop
	;ora   $0012
	;ora   $0002,X
	;ora   $0001,Y
	;ora   <$12
	;ora   <$12,X
	;ora   [$12]
	;ora   [$12,X]
	;ora   [$12],Y
	;bsr   _test

_test:
	rts
	;bra   _reset
	;jmp   $FFFE
	;jmp   [$FF20,X]
	;asl   a
	;asl   <$12
	;asl   <$12,X
	;asl   $1234
	;asl   $1234,X
	;sta   <$12
	;sta   <$12,X
	;sta   $1234
	;sta   $1234,X
	;sta   $1234,Y
	;sta   [$12]
	;sta   [$12,X]
	;sta   [$12],Y
	;lda   <$12
	;lda   <$12,X
	;lda   $0012
	;lda   $0012,X
	;lda   $0012,Y
	;lda   [$12]
	;lda   [$12,X]
	;lda   [$12],Y
	;adc   #$34
	;adc   [$23]
	
	jmp   [$FFFE]

	lda   #$FF		; map the I/O bank in the first page
	tam   #0
	lda   #$F8		; and the RAM bank in the second page
	tam   #1
	stz   $2000		; clear all the RAM
	tii   $2000,$2001,$1FFF

	map   main
	jmp   main

_irq2:
	nop
	nop
	nop
	rti
_irq1:
	rti
_timer:
	rti
_nmi:
	nop
	nop
	nop
	rti


	.code
	.bank MAIN_BANK
	.org  $C000
main:
	jmp	main
