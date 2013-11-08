;
; LIBRARY.ASM  -  MagicKit Standard Library
;
;

; IMPORTANT NOTE:
; ----
; almost all the library functions have been changed to automaticaly
; handle bank mapping (you don't have to map data yourself anymore),
; the change will be transparent to you if you were using only library
; macros to call functions, but you will have to update your code
; in case you were directly calling those functions!


; ----
; map_data
; ----
; map data in page 3-4 ($6000-$9FFF)
; ----
; IN :  _BL = data bank
;       _SI = data address
; ----
; OUT:  _BX = old banks
;       _SI = remapped data address
; ----

map_data:
	ldx   <_bl

    ; ----
    ; save current bank mapping
    ;
	tma   #3
	sta   <_bl
	tma   #4
	sta   <_bh
	; --
	cpx   #$FE
	bne   .l1
	; --
	stx   <_bp
	rts

    ; ----
    ; map new bank
    ;
.l1:	stz   <_bp
	; --
	txa
	tam   #3
	inc   A
	tam   #4

    ; ----
    ; remap data address to page 3
    ;
	lda   <_si+1
	and   #$1F
	ora   #$60
	sta   <_si+1
	rts


; ----
; unmap_data
; ----
; IN :  _BX = old banks
; ----

unmap_data:

	lda	<_bl
	tam	#3
	lda	<_bh
	tam	#4
	rts

; ----
; remap_data
; ----

remap_data:
	lda   <_bp
	bne   .l1
	lda   <_si+1
	bpl   .l1
	sub   #$20
	sta   <_si+1
	tma   #4
	tam   #3
	inc   A
	tam   #4
.l1:
	rts


; ----
; load_palette
; ----
; initialize one or more sub-palette
; ----
; IN :  _AL = index of the first sub-palette (0-31)
;       _BL = data bank
;       _SI = address of data
;       _CL = number of sub-palette to copy
; ----

	.ifdef HUC
_load_palette.3:
	.endif
 load_palette:

    ; ----
    ; map data
    ;
	jsr   map_data

    ; ----
    ; multiply the sub-palette index by 16
    ; and set the VCE color index register
    ;
	lda   <_al
	stz   <_ah
	asl   A
	asl   A
	asl   A
	asl   A
	rol   <_ah
	sta   color_reg_l
	lda   <_ah
	sta   color_reg_h

    ; ----
    ; load new colors
    ;
	cly
.loop_a:
	ldx   #16
.loop_b:
	lda   [_si],Y		; set color
	iny
	sta   color_data_l
	lda   [_si],Y
	sta   color_data_h
	iny
	bne   .next
	inc   <_si+1
.next:  dex			; next color
	bne   .loop_b

	dec   <_cl		; next sub-palette
	bne   .loop_a

    ; ----
    ; unmap data
    ;
	jmp   unmap_data


; ----
; load_bat
; ----
; transfer a BAT in VRAM
; ----
; IN :  _DI = VRAM base address
;       _BL = BAT bank
;       _SI = BAT memory location
;       _CL = nb of column to copy
;       _CH = nb of row
; ----

	.ifdef HUC
_load_bat.4:
	.endif
 load_bat:

    ; ----
    ; map data
    ;
	jsr   map_data

    ; ----
    ; copy BAT
    ;
	cly
	; --
.l1:	jsr   set_write
	ldx   <_cl
	; --
.l2:	lda   [_si],Y
	sta   video_data_l
	iny
	lda   [_si],Y
	sta   video_data_h
	iny
	bne   .l3
	inc   <_si+1
.l3:	dex
	bne   .l2
	; --
	jsr   remap_data
	; --
	addw  bat_width,<_di
	dec   <_ch
	bne   .l1

    ; ----
    ; unmap data
    ;
	jmp   unmap_data


; ----
; load_map
; ----
; transfer a tiled map in VRAM
; ----
; IN :  _DI = VRAM base address
;       _CL = x start coordinate in the map
;       _CH = y start coordinate
;       _DL = nb of column to copy
;       _DH = nb of row
; ----

              .bss
mapbank       .ds 1
mapaddr       .ds 2
mapwidth      .ds 2
mapheight     .ds 2
maptilebank   .ds 1
maptileaddr   .ds 2
maptilebase   .ds 2
mapnbtile     .ds 2
mapctablebank .ds 1
mapctable     .ds 2
mapwrap       .ds 1
              .code
load_map:

    ; ----
    ; save bank mapping
    ;
	tma   #2
	pha
	tma   #3
	pha
	tma   #4
	pha
	tma   #5
	pha

    ; ----
    ; calculate map address
    ;
	stw   mapctable,<_bp
	stb   mapaddr,<_si
	lda   mapaddr+1
	and   #$1F
	sta   <_si+1
	; --
	ldx   <_cl
	stx   <_ah
	ldy   <_ch
	sty   <_bh
	; --
	lda   mapwidth+1
	beq   .l1
	tya
	add   <_si+1
	sta   <_si+1
	bra   .l2
    	; --
.l1:	sty   <_al
	lda   mapwidth
	sta   <_bl
	jsr   mulu8
	addw  <_cx,<_si

    ; ----
    ; calculate map bank
    ;
.l2:	rol   A
	rol   A
	rol   A
	rol   A
	and   #$0F
	add   mapbank
	sta   <_bl

    ; ----
    ; map data
    ;
    	tam   #2
	inc   A
	tam   #3
	lda   mapctablebank
	tam   #4
	inc   A
	tam   #5

    ; ----
    ; adjust data addresses
    ;
	lda   <_si+1		; tile ptr
	and   #$1F
	ora   #$40
	sta   <_si+1
	; --
	lda   <_bp+1		; color table ptr
	and   #$1F
	ora   #$80
	sta   <_bp+1

    ; ----
    ; vertical loop
    ;
.l3:	ldy   <_ah
	lda   <_dl
	sta   <_al
	bra   .l5

    ; ----
    ; horizontal loop
    ;
.l4:	iny
	; --
	cpy   mapwidth		; horizontal wrapping
	bne   .l5
	cly
	ldx   mapwrap
	bne   .l5
	ldy   mapwidth
	lda   maptilebase
	sta   <_cl
	lda   maptilebase+1
	ora   [_bp]
	sta   <_ch
	dey
	bra   .x1
.l5:
	lda   [_si],Y		; get tile index
	tax			; calculate BAT value (tile + palette)
	sxy
        stz   <_ch
	asl   A
	rol   <_ch
	asl   A
	rol   <_ch
	add   maptilebase
	sta   <_cl
	lda   <_ch
	adc   maptilebase+1
	adc   [_bp],Y
	sta   <_ch
	sxy
.x1:
	vreg  #0		; copy tile
	stw   <_di,video_data
	vreg  #2
	stw   <_cx,video_data
	incw  <_cx
	stw   <_cx,video_data
	incw  <_cx
	vreg  #0
	addw  bat_width,<_di,video_data
	vreg  #2
	stw   <_cx,video_data
	incw  <_cx
	stw   <_cx,video_data

	incw  <_di		; next tile
	incw  <_di
	dec   <_al
	lbne  .l4

    ; ----
    ; next line
    ;
	lda   bat_width		; incremente vram address
	sub   <_dl
	asl   A
	add   <_di
	sta   <_di
	cla
	adc   <_di+1
	sta   <_di+1

	inc   <_bh		; vertical wrapping
	lda   <_bh
	cmp   mapheight
	bne   .l6
	; --
	lda   mapbank
	tam   #2
	inc   A
	tam   #3
	stb   mapaddr,<_si
	lda   mapaddr+1
	and   #$1F
	ora   #$40
	sta   <_si+1
	stz   <_bh
	bra   .l7

.l6:	addw  mapwidth,<_si	; incremente map address
	; --
	cmp   #$60		; adjust bank mapping if necessary
	blo   .l7
	sub   #$20
	sta   <_si+1
	tma   #3
	tam   #2
	inc   A
	tam   #3

.l7:	dec   <_dh
	lbne  .l3

    ; ----
    ; restore bank mapping
    ;
    	pla
	tam   #5
	pla
	tam   #4
	pla
	tam   #3
	pla
	tam   #2
	rts


; ----
; load_font
; ----
; transfer a 8x8 monochrome font into VRAM, slow but can be useful
; ----
; IN :  _DI = VRAM base address
;       _BL = font bank
;       _SI = font memory location
;       _AL = font color (0-15)
;       _AH = bg color (0-15)
;       _CL = number of characters to copy
; ----

load_font:

    ; ----
    ; map data
    ;
	jsr   map_data
	jsr   set_write

    ; ----
    ; init bg color
    ;
    	lda   <_cl
	pha
	; --
    	ldx   #3
.l1:	cla
	lsr   <_ah
	bcc   .l2
	lda   #$FF
.l2:	sta   <_cl,X
	dex
	bpl   .l1

    ; ----
    ; character loop
    ;
	plx
.copy:

    ; ----
    ; plane 1
    ;
	cly
.p1:	bbs0  <_al,.p2
	lda   [_si],Y
	eor   #$FF
	and   <_dh
	bra   .p3
	; --
.p2:	lda   <_dh
	ora   [_si],Y
.p3:	sta   video_data_l

    ; ----
    ; plane 2
    ;
	bbs1  <_al,.p4
	lda   [_si],Y
	eor   #$FF
	and   <_dl
	bra   .p5
	; --
.p4:	lda   <_dl
	ora   [_si],Y
.p5:	sta   video_data_h
	; --
	iny
	cpy   #8
	bne   .p1

    ; ----
    ; plane 3
    ;
	cly
.t1:	bbs2  <_al,.t2
	lda   [_si],Y
	eor   #$FF
	and   <_ch
	bra   .t3
	; --
.t2:	lda   <_ch
	ora   [_si],Y
.t3:	sta   video_data_l

    ; ----
    ; plane 4
    ;
	bbs3  <_al,.t4
	lda   [_si],Y
	eor   #$FF
	and   <_cl
	bra   .t5
	; --
.t4:	lda   <_cl
	ora   [_si],Y
.t5:	sta   video_data_h
	; --
	iny
	cpy   #8
	bne   .t1

    ; ----
    ; next character
    ;
	addw  #8,<_si
	; --
	dex
	bne   .copy

    ; ----
    ; unmap data
    ;
	jmp   unmap_data


; ----
; load_vram
; ----
; copy a block of memory to VRAM
; ----
; IN :  _DI = VRAM location
;       _BL = data bank
;       _SI = data memory location
;       _CX = number of words to copy
; ----

	.ifdef HUC
_load_vram.3:
	.endif
 load_vram:

    ; ----
    ; map data
    ;
	jsr   map_data

    ; ----
    ; set vram address
    ;
	jsr   set_write

    ; ----
    ; copy data
    ;
	cly
	ldx   <_cl
	beq   .l3
	; --
.l1:	lda   [_si],Y
	sta   video_data_l
	iny
	lda   [_si],Y
	sta   video_data_h
	iny
	bne   .l2
	inc   <_si+1
	; --
.l2:	dex
	bne   .l1
	; --
	jsr   remap_data
	; --
.l3:	dec   <_ch
	bpl   .l1

    ; ----
    ; unmap data
    ;
	jmp   unmap_data


; ----
; set_read
; ----
; set the VDC VRAM read pointer
; ----
; IN :  _DI = VRAM location
; ----

set_read:
	vreg  #$01
	lda   <_di 
	sta   video_data_l
	.ifdef HUC
	 sta   _vdc+2
	.endif
	lda   <_di+1
	sta   video_data_h
	.ifdef HUC
	 sta   _vdc+3
	.endif
	vreg  #$02
	rts 


; ----
; set_write
; ----
; set the VDC VRAM write pointer
; ----
; IN :  _DI = VRAM location
; ----

set_write:
	vreg  #$00
	lda   <_di 
	sta   video_data_l
	.ifdef HUC
	 sta   _vdc
	.endif
	lda   <_di+1
	sta   video_data_h
	.ifdef HUC
	 sta   _vdc+1
	.endif
	vreg  #$02
	rts 


; ----
; calc_vram_addr
; ----
; calculate VRAM address
; ----
; IN :    X = x coordinates
;         A = y     "
; ----
; OUT:  _DI = VRAM location
; ----

calc_vram_addr:
	phx
	and   bat_vmask
	stz   <_di
	ldx   bat_width
	cpx   #64
	beq   .s64
	cpx   #128
	beq   .s128
	; --
.s32:	lsr   A
	ror   <_di
	; --
.s64:	lsr   A
	ror   <_di
	; --
.s128:	lsr   A
	ror   <_di
	sta   <_di+1
	; --
	pla
	and   bat_hmask
	ora   <_di
	sta   <_di
	rts

	.if (!CDROM)
; ----
; HSR(xres)
; ----
; macros to calculate the value of the HSR VDC register
; ----
; IN :  xres, horizontal screen resolution
; ----

HSR	.macro
	 .if (\1 <= 272)
	  ; low res
	  .db $02
	  .db (18 - (((\1 / 8) - 1) / 2))
	 .else
	  ; high res
	  .db $03
	  .db (24 - (((\1 / 8) - 1) / 2))
	 .endif
	.endm


; ----
; HDR(xres)
; ----
; macros to calculate the value of the HDR VDC register
; ----
; IN :  xres, horizontal screen resolution
; ----

HDR	.macro
	 .db ((\1 / 8) - 1)
	 .if (\1 <= 272)
	  ; low res
	  .db (38 - ((18 - (((\1 / 8) - 1) / 2)) + (\1 / 8)))
	 .else
	  ; high res
	  .db (54 - ((24 - (((\1 / 8) - 1) / 2)) + (\1 / 8)))
	 .endif
	.endm


; ----
; init_vdc
; ----
; initialize the video controller
;  - 256x224 screen mode
;  - 64x32 virtual bgmap size
;  - display and sprites off
;  - interrupts disabled
;  - SATB at $7F00
;  - VRAM cleared
; ----

	   .bss
bat_width  .ds 2
bat_height .ds 1
bat_hmask  .ds 1
bat_vmask  .ds 1
scr_width  .ds 1
scr_height .ds 1
	   .code
init_vdc:

    ; ----
    ; default screen resolution
    ;
	.ifndef _xres
_xres    .equ 256
	.endif

    ; ----
    ; initialize the VDC registers
    ;
	stw   #.table,<_si 	; register table address in '_si'
	cly 
.l1:	lda   [_si],Y		; select the VDC register
	iny
	sta   <vdc_reg
	sta   video_reg
	.ifdef HUC
	 asl   A
	 tax
	.endif
	lda   [_si],Y		; send the 16-bit data
	iny 
	sta   video_data_l
	.ifdef HUC
	 sta   _vdc,X
	.endif
	lda   [_si],Y
	iny 
	sta   video_data_h
	.ifdef HUC
	 sta   _vdc+1,X
	.endif
	cpy   #36		; loop if not at the end of the
	bne   .l1		; table

    ; ----
    ; set the pixel clock frequency
    ;
	.if (_xres <= 272)
	 stz  color_ctrl
	.else
	 lda  #1
	 sta  color_ctrl
	.endif

    ; ----
    ; set the background & border colors to black
    ;
	stw   #256,color_reg
	stwz  color_data
	stwz  color_reg
	stwz  color_data

    ; ----
    ; clear the video RAM
    ;
	st0   #0
	st1   #0
	st2   #0
	st0   #2

	ldx   #128
.l2:	cly
.l3:	st1   #0
	st2   #0
	dey
	bne   .l3
	dex
	bne   .l2

    ; ----
    ; save screen infos
    ;
	stw   #_xres,scr_width	; resolution
	stw   #224,scr_height
	; --
    	lda   #BGMAP_SIZE_64x32	; virtual size
	jmp   set_bat_size

    ; ----
    ; VDC register table
    ;
.table:	.db $05,$00,$00		; CR    control register
	.db $06,$00,$00		; RCR   scanline interrupt counter
	.db $07,$00,$00		; BXR   background horizontal scroll offset
	.db $08,$00,$00		; BYR        "     vertical     "      "
	.db $09,$10,$00		; MWR   size of the virtual screen
	.db $0A			; HSR +
	 HSR _xres		;     |                 [$02,$02]
	.db $0B			; HDR | display size
	 HDR _xres		;     | and synchro     [$1F,$04]
	.db $0C,$02,$17		; VPR |
	.db $0D,$DF,$00		; VDW |
	.db $0E,$0C,$00		; VCR +
	.db $0F,$10,$00		; DCR   DMA control register
	.db $13,$00,$7F		; SATB  address of the SATB
	.endif

; ----
; set_bat_size
; ----
; set bg map virtual size
; ----
; IN : A = new size (0-7)
; ----

set_bat_size:
	and   #$07
	pha
	; --
	.if (CDROM)
	 jsr   ex_scrsiz
	 plx
	.else
	 vreg  #9
	 pla
	 tax
	 asl   A
	 asl   A
	 asl   A
	 asl   A
	 .ifdef HUC
	  sta   _vdc+18
	 .endif
	 sta   video_data_l
	.endif
	; --
	lda  .width,X
	sta   bat_width
	stz   bat_width+1
	dec   A
	sta   bat_hmask
	; --
	lda  .height,X
	sta   bat_height
	dec   A
	sta   bat_vmask
	rts

.width:	 .db $20,$40,$80,$80,$20,$40,$80,$80
.height: .db $20,$20,$20,$20,$40,$40,$40,$40


; ----
; init_psg
; ----
; initialize the sound generator.
; ----

init_psg:
	stz   psg_mainvol	; main volume to zero
	stz   psg_lfoctrl	; disable the LFO
	
	lda   #5		; set volume to zero for each channel
.clear:	sta   psg_ch            ; and disable them
	stz   psg_ctrl
	stz   psg_pan
	dec   A
	bpl   .clear

	lda   #4		; disable noise for channel 5 & 6
	sta   psg_ch
	stz   psg_noise
	lda   #5
	sta   psg_ch
	stz   psg_noise
	rts

