;
; STARTUP.ASM  -  MagicKit standard startup code
;
		.list
		
	       .if (CDROM)
		.include  "cdstart.asm"  ; CD-ROM
	       .else
		.include  "standard.inc" ; HUCARD
		.ifdef HUC
		 .include "huc.inc"      ; HUC
		 .include "huc_opt.inc"
		.endif

; ----
; setup flexible boundaries for startup code
; and user program's "main".
;
START_BANK	.equ	0
	       .ifdef HUC
CONST_BANK	.equ	START_BANK+1
FONT_BANK	.equ	START_BANK+2
DATA_BANK	.equ	START_BANK+3
	       .else
MAIN_BANK	.equ	START_BANK+1
	       .endif

; ----
; system variables
;
		.bss
		.org	$2200
user_jmptbl:		; user interrupt vectors
irq2_jmp:	.ds 2	; IRQ2 (BRK instruction and external IRQ)
irq1_jmp:	.ds 2	; IRQ1 (VDC interrupt)
timer_jmp:	.ds 2	; TIMER
nmi_jmp:	.ds 2	; NMI (unused)
vsync_hook:	.ds 2	; VDC vertical sync routine
hsync_hook:	.ds 2	; VDC horizontal sync rountine
bg_x1:		.ds 2
bg_x2:		.ds 2
bg_y1:		.ds 2
bg_y2:		.ds 2

		.org	$2227
joyena:		.ds 1	; soft reset enable (bit 0/pad 1, bit 1/pad2, etc.)
joy:		.ds 5	; 'current' pad values (pad #1-5)
joytrg:		.ds 5	; 'delta' pad values (new keys hit)
joyold:		.ds 5	; 'previous' pad values

		.org	$2241
irq_cnt:	.ds 1	; VDC interrupt counter; increased 60 times per second
vdc_mwr:	.ds 1
vdc_dcr:	.ds 1

		.org	$2284
soft_reset:	.ds 2	; soft reset jump loc (run+select)

		.org	$2680
vsync_cnt:	.ds 1	; counter for 'wait_vsync' routine
joydlta:	.ds 5	; latched 'delta' pad values (new keys hit)
joyprev:	.ds 5	; latched 'previous' pad values
joybuf:		.ds 5	; 'delta' pad values collector
joyhook:	.ds 2	; 'read_joypad' routine hook
joycallback:	.ds 6	; joypad enhanced callback support
disp_cr:	.ds 1   ; display control (1 = on, 0 = off)
time:		.ds 3   ; system time (~100 ticks per second)


;±±±[ STARTUP CODE ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

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

    ; ----
    ; develo startup code

       .if (DEVELO)
	.org $6000

	sei
	map  _reset
	jmp  _reset
_restart:
	cla		; map the CD-ROM system bank
	tam   #7
	jmp   $4000	; back to the Develo shell
       .endif

; ----
; reset
; ----
; things start here
; ----

	.org  $E010
_reset:
	sei			; disable interrupts 
	csh			; select the 7.16 MHz clock
	cld			; clear the decimal flag 
	ldx   #$FF		; initialize the stack pointer
	txs 
	lda   #$FF		; map the I/O bank in the first page
	tam   #0
	lda   #$F8		; and the RAM bank in the second page
	tam   #1
	stz   $2000		; clear all the RAM
	tii   $2000,$2001,$1FFF

    ; ----
    ; initialize the hardware

	stz   timer_ctrl	; init timer
	jsr   init_psg		; init sound
	jsr   init_vdc		; init video
	lda   #$1F		; init joypad
	sta   joyena

    ; ----
    ; initialize interrupt vectors

	ldx   #4		; user vector table
	cly
.l2:	lda   #LOW(_rti)
	sta   user_jmptbl,Y
	iny
	lda   #HIGH(_rti)
	sta   user_jmptbl,Y
	iny
	dex
	bne   .l2

	stw   #_reset,soft_reset ; soft reset
	stw   #_rts,vsync_hook   ; user vsync routine
	stw   #_rts,hsync_hook   ; user hsync routine

	lda   #$01		 ; enable interrupts
	sta   $1402
	stz   $1403
	cli

    ; ----
    ; enable display and VSYNC interrupt

	vreg  #5
	lda   #$C8
	sta  <vdc_crl
	sta   video_data_l
	st2   #$00
	lda   #$01
	sta   disp_cr

    ; ----
    ; init random number generator

	stw   #$4BE7,<_cx	; set random seed
	stw   #$91D8,<_dx
	jsr   srand

    ; ----
    ; load font

       .ifdef HUC
	stz   <_dl
	stw   #$0800,<_di
	jsr   _load_default_font.2
	jsr   _cls
       .endif

    ; ----
    ; jump to main routine

       .ifdef HUC
	lda   #CONST_BANK	; map string constants bank
	tam   #2
	lda   #_call_bank	; map call bank
	tam   #4
	stw   #$4000,<__sp	; init stack ptr
	map   _main
	jsr   _main 		; go!
	bra   *
       .else
	map   main
	jmp   main
       .endif

; ----
; system
; ----
; give back control to the Develo system
; ----

       .if (DEVELO)
_system:
	sei
	csh
	cld
	ldx   #$FF	; stack
	txs 
	lda   #$FF	; I/O bank
	tam   #0
	lda   #$F8	; RAM bank
	tam   #1
	lda   #$80	; Develo Bank
	tam   #2
	tma   #7	; startup code bank
	tam   #3

    ; ----
    ; re-initialize the machine
    ;
	stz   $2000		; clear RAM
	tii   $2000,$2001,$1FFF
	stz   timer_ctrl	; init timer
	jsr   init_psg		; init sound
	jsr   init_vdc		; init video
	lda   #$1F		; init joypad
	sta   joyena
	lda   #$07		; set interrupt mask
	sta   $1402
	stz   $1403		; reset timer interrupt
	lda   #$80		; disable sound driver
	sta   <$20E7
	st0   #5		; enable display and vsync interrupt
	lda   #$C8
	sta  <vdc_crl
	sta   video_data_l
	jmp   _restart		; restart
       .endif

;±±±[ INTERRUPT CODE ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

_rts:
	rts
_rti:
	rti

; ----
; irq2
; ----
; IRQ2 interrupt handler
; ----

_irq2:
	bbs0 <irq_m,.user
	rti
.user:
	jmp   [irq2_jmp]

; ----
; irq1
; ----
; VDC interrupt handler
; ----

_irq1:
	bbs1 <irq_m,.user_irq1	; jump to the user irq1 vector
	; --
	pha			; save registers
	phx
	phy
	; --
	lda   video_reg		; get VDC status register
	sta  <vdc_sr		; save a copy

    ; ----
    ; vsync interrupt
    ;
.vsync:
	bbr5 <vdc_sr,.hsync
	; --
	inc   irq_cnt		; increment IRQ counter
	; --
	st0   #5		; update display control (bg/sp)
	lda  <vdc_crl
	sta   video_data_l
	; --
	bbs5 <irq_m,.l3
	; --
	ldx   disp_cr		; check display state (on/off)
	bne  .l1
	and   #$3F		; disable display
	sta   video_data_l
	bra  .l2
	; --	
.l1:	jsr  .rcr_init		; init display list
.l2:	st0   #7		; scrolling
	stw   bg_x1,video_data
	st0   #8
	stw   bg_y1,video_data
	jsr   read_joypad	; read joypad
	; --
.l3:	bbr4 <irq_m,.l4
	jsr  .user_vsync	; call user vsync routine
.l4:
    ; ----
    ; hsync interrupt
    ;
.hsync:
	bbr2 <vdc_sr,.exit
	bbr6 <irq_m,.rcr_sys
	bbs7 <irq_m,.l5
	; --
	st0   #7		; scrolling
	stw   bg_x2,video_data
	st0   #8
	stw   bg_y2,video_data
	; --
.l5:	bsr  .user_hsync	; call user handler

    ; ----
    ; exit interrupt
    ;
.exit:
	lda  <vdc_reg		; restore VDC register index
	sta   video_reg
	; --
	ply
	plx
	pla
	rti

    ; ----
    ; user routine hooks
    ;
.user_irq1:
	jmp   [irq1_jmp]
.user_hsync:
	jmp   [hsync_hook]
.user_vsync:
	jmp   [vsync_hook]

    ; ----
    ; hsync scrolling handler
    ;
.rcr_sys:
	ldy   s_idx
	bpl  .r1
	; --
	lda  <vdc_crl
	and   #$3F
	sta  <vdc_crl
	stz   s_idx
	ldx   s_list
	lda   s_top,X
	jsr  .r5
	jmp  .exit
	; --
.r1:	ldx   s_list,Y
	lda  <vdc_crl
	and   #$3F
	ora   s_cr,X
	sta  <vdc_crl
	; --
	jsr  .rcr_set
	; --
	lda   s_top,X
	cmp   #$FF
	beq  .exit
	; --
	st0   #7
	lda   s_xl,X
	ldy   s_xh,X
	sta   video_data_l
	sty   video_data_h
	st0   #8
	lda   s_yl,X
	ldy   s_yh,X
	sub   #1
	bcs  .r2
	dey
.r2:	sta   video_data_l
	sty   video_data_h
	jmp  .exit

    ; ----
    ; init display list
    ;
.rcr_init:
	jsr   build_disp_list
	bcs   .r3
	rts
	; --
.r3:	smb   #7,<vdc_crl
	lda   #$FF
	sta   s_idx
	ldx   s_list
	ldy   s_top,X
	cpy   #$FF
	bne   .r5
	; --
	ldy   s_xl,X
	sty   bg_x1
	ldy   s_xh,X
	sty   bg_x1+1
	ldy   s_yl,X
	sty   bg_y1
	ldy   s_yh,X
	sty   bg_y1+1
	stz   s_idx
	bra   .r5

    ; ----
    ; program scanline interrupt
    ;
.rcr_set:
	iny
	sty   s_idx
	lda   s_list,Y
	tay
	lda   s_top,Y
	cmp   scr_height
	bhs  .r6
	cmp   s_bottom,X
	blo  .r5
	; --
	lda   s_bottom,X
.r4:	dec   A
	pha
	lda   #$F0
	sta   s_bottom,X
	stz   s_cr,X
	dec   s_idx
	pla
	; --
.r5:	st0   #6		; set scanline counter
	add   #64
	sta   video_data_l
	cla
	adc   #0
	sta   video_data_h
	bra   __rcr_on
	;--
.r6:	lda   s_bottom,X
	cmp   scr_height
	blo  .r4
	bra   __rcr_off

; ----
; rcr_on
; ----
; enable scanline interrupt
; ----

  rcr_on:
 _rcr_on:
 	lda   #5
	sta  <vdc_reg
__rcr_on:
	st0   #5
	lda  <vdc_crl
	ora   #$04
	sta  <vdc_crl
	sta   video_data_l
	rts

; ----
; rcr_off
; ----
; disable scanline interrupt
; ----

  rcr_off:
 _rcr_off:
	lda   #5
	sta  <vdc_reg
__rcr_off:
	st0   #5
	lda  <vdc_crl
	and   #$FB
	sta  <vdc_crl
	sta   video_data_l
	rts

; ----
; timer
; ----
; timer interrupt handler
; ----

_timer:
	bbs2 <irq_m,.user
	incw  time
	stz   $1403
	rti
.user:
	jmp   [timer_jmp]

; ----
; nmi
; ----
; NMI interrupt handler
; ----

_nmi:
	bbs3 <irq_m,.user
	rti
.user:
	jmp   [nmi_jmp]


;±±[ DATA ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; ----
; font
; ----

	.ifdef HUC
font_table:
	 .dw font_1
	 .dw font_1
	 .dw font_1
	 .dw font_1

	 .data
	 .bank FONT_BANK
	 .org  $6000
	 .include "font.inc"

	 .code
	.endif


;±±[ LIBRARY ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; ----
; standard library
; ----

       .ifdef HUC
	.include "library.asm"
	.include "scroll.asm"
	.include "math.asm"
	.include "huc.asm"
	.include "huc_gfx.asm"
	.include "huc_snd.asm"
	.include "huc_misc.asm"
       .else
	.include "library.asm"
	.include "scroll.asm"
	.include "math.asm"
       .endif

; ----
; disp_on
; ----
; enable display
; ----

       .ifdef HUC
_disp_on:
	ldx   disp_cr
	lda   #1
	sta   disp_cr
	cla
	rts
       .else
 disp_on:
	lda   #1
	sta   disp_cr
	rts
       .endif

; ----
; disp_off
; ----
; disable display
; ----

       .ifdef HUC
_disp_off:
	ldx   disp_cr
	stz   disp_cr
	cla
	rts
       .else
 disp_off:
	stz   disp_cr
	rts
       .endif

; ----
; set_intvec
; ----
; set interrupt vector
; ----
; IN : A = vector number
;           0 IRQ2
;           1 IRQ1 (VDC)
;           2 TIMER
;           3 NMI
;           4 VSYNC
;           5 HSYNC
;           6 SOFT RESET (RUN + SELECT)
;      X = vector address low byte
;      Y =   "      "    high byte
; ----

set_intvec:
	php
	sei
	cmp   #6
	blo  .vector
	bne  .exit
.reset:
	stx   soft_reset
	sty   soft_reset+1
	bra  .exit	
.vector:
	pha
	asl   A
	sax
	sta   user_jmptbl,X
	inx
	tya
	sta   user_jmptbl,X
	pla
.exit:
	plp
	rts

; ----
; wait_vsync
; ----
; wait the next vsync
; ----
; IN :  A = number of frames to be sync'ed on
; ----
; OUT:  A = number of elapsed frames since last call
; ----

wait_vsync:
	bbr1 <irq_m,.l1
	cla			; return immediately if IRQ1 is redirected
       .ifdef HUC
	clx
       .endif
	rts

.l1:	sei			; disable interrupts
	cmp   irq_cnt		; calculate how many frames to wait
	beq  .l2
	bhs  .l3
	lda   irq_cnt
.l2:	inc   A
.l3:	sub   irq_cnt
	sta   vsync_cnt
	cli			; re-enable interrupts

.l4:	lda   irq_cnt		; wait loop
.l5:	cmp   irq_cnt
	beq  .l5
	dec   vsync_cnt
	bne  .l4

	stz   irq_cnt		; reset system interrupt counter
	inc   A			; return number of elapsed frames

       .ifndef HUC
        rts
       .else

    ; ----
    ; callback support

	pha
	lda   joycallback	; callback valid?
	bpl  .t3
	bit   #$01
	bne  .t3

	lda   joycallback+1	; get events for all the 
	beq  .t3		; selected joypads
	sta  <_al
	cly
	cla
.t1:    lsr  <_al
	bcc  .t2
	ora   joybuf,Y
.t2:	iny
	cpy   #5
	blo  .t1

	and   joycallback+2	; compare with requested state
	beq  .t3

	inc   joycallback	; lock callback feature
	tax			; call user routine
	tma   #5
	pha
	lda   joycallback+3
	tam   #5
	cla
	jsr  .callback
	pla
	tam   #5
	dec   joycallback	; unlock
	; --
.t3:	plx
	cla
	rts

    ; ----
    ; user routine callback
    ;
.callback:
	jmp   [joycallback+4]
       .endif

; ----
; read_joypad
; ----
; poll joypads
;
; 'joyport' (location $1000) is a control read/write port which only reads
; 4 bits at a time; the program uses joyport to toggle the multiplex line
;
; real logic values are read into the port - the joypad's keys are default
; high, and 'pulled' low when pressed.  Therefore, these values must be
; inverted/complemented to yield values where '1' means 'pressed'
;
; bit values for joypad bytes: (MSB = #7; LSB = #0)
; -------------------------------------------------
; bit 0 (ie $01) = I
; bit 1 (ie $02) = II
; bit 2 (ie $04) = 'select'
; bit 3 (ie $08) = 'run'
; bit 4 (ie $10) = UP
; bit 5 (ie $20) = RIGHT
; bit 6 (ie $40) = DOWN
; bit 7 (ie $80) = LEFT
; ----

read_joypad:
	lda   #$01		; reset joypad port to joystick #1
	sta   joyport
	lda   #$03
	sta   joyport
	jsr   .delay

    ; ----
    ; poll all the joypads
    ;
	cly			; counter for 5 joypads
.l1:	lda   #$01		; first nybble
	sta   joyport
	bsr  .delay		; required delay (approx 9 cycles)
	lda   joy,Y		; move previous pad value to 'prev' area
	sta   joyold,Y
	lda   joyport		; fetch first nybble
	asl   A			; shift it to 'high' position within byte
	asl   A
	asl   A
	asl   A
	sta   joy,Y		; store in 'current' area
	stz   joyport		; toggle port (to read other 4 key values)
	bsr  .delay		; delay again
	lda   joyport		; fetch second nybble
	and   #$0F		; clear unused bits
	ora   joy,Y		; merge 2 nybbles into 1 byte
	eor   #$FF		; reset 'sense' of keys
	sta   joy,Y		; store it
	eor   joyold,Y		; check against previous value
	and   joy,Y
	sta   joytrg,Y		; 'new key pressed' key values

    ; ----
    ; buffered 'new key pressed'
    ; see joy_events();
    ;
	ora   joybuf,Y		; collect 'new key pressed'
	sta   joybuf,Y

; ** old code **
;	ora   joybuf,Y		; collect 'new key pressed'
;	sta   joybuf,Y
;	lda   vsync_cnt
;	cmp   #1
;	bne  .l2
;	lda   joybuf,Y		; update keys
;	eor   joyprev,Y
;	and   joybuf,Y
;	sta   joydlta,Y
;	lda   joybuf,Y
;	sta   joyprev,Y
;	cla
;	sta   joybuf,Y

    ; ----
    ; next joypad
    ;
.l2:	iny
	cpy   #$05		; cycle for next of 5 joypads
	bcc  .l1

    ; ----
    ; soft reset check
    ;
	cly			; start cycle of 5 joypads
.l3:	lda   joyena		; find mask of 'important' joysticks
	and  .bitmsk,Y
	beq  .l4		; not important enough to check
	lda   joytrg,Y
	cmp   #$04		; 'select' key newly-pressed ?
	bne  .l4
	lda   joy,Y
	cmp   #$0C		; 'run+select' currently pressed ?
	bne  .l4

       .if (DEVELO)
	jmp   _system
       .else
	jmp   [soft_reset]	; run+select 'soft reset' vector
       .endif

.l4:	iny			; try next joypad
	cpy   #$05
	bcc  .l3

    ; ----
    ; joyread hook
    ;
       .ifdef HUC
        tstw  joyhook
	beq  .l5
	jsr  .hook
.l5:
       .endif
    ; ----
    ; return
    ;
	rts

    ; ----
    ; small delay
    ;
.delay:
	ldx   #3
.l6:	dex
	bne  .l6
	rts

.bitmsk:
	.db $01,$02,$04,$08,$10	; bit-masks for check-reset

    ; ----
    ; user routine
    ;
       .ifdef HUC
.hook:
	jmp   [joyhook]
       .endif


;±±[ USER PROGRAM ]±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

	.nomlist
	.list

	;...

	.endif

