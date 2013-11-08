; SOUND.ASM
; ---------
;

PSG_ENABLE	= $80
PSG_DDA		= $40
PSG_NOISE	= $80
PSG_LFO_ON	= $80


SND_STOP	= 0	; stop processing (track finish)
			; 0-byte operand

SND_OFF		= 1	; mute sound
			; 0-byte operand

SND_ON		= 2	; turn on sound
			; 0-byte operand

SND_VOLUME	= 3	; set voice volume (left & right)
			; 1-byte operand

SND_FREQ	= 4	; set voice frequency
			; 2-byte operand

SND_DURATION	= 5	; set voice duration
			; 1-byte operand

SND_NOISE_FREQ	= 6	; set noise frequency
			; 1-byte operand

SND_NOISE_OFF	= 7	; set noise off
			; 0-byte operand

SND_LFO_FREQ	= 8	; set LFO frequency
			; 1-byte operand

SND_LFO_CTRL	= 9	; set LFO control
			; 1-byte operand

SND_WAVE_SINE	= 20	; init to sine wave (predefined)
			; 0-byte operand

SND_WAVE_SAW	= 21	; init to sawtooth wave (predefined)
			; 0-byte operand

SND_WAVE_SQR	= 22	; init to square wave (predefined)
			; 0-byte operand

SND_WAVE_DATA	= 30	; init to inline wave data
			; 32-byte operand


		.zp

wavptr:		.ds	2
sndtrkptr:	.ds	2


		.bss

sndcount0:	.ds	1
sndcount1:	.ds	1
sndcount2:	.ds	1
sndcount3:	.ds	1
sndcount4:	.ds	1
sndcount5:	.ds	1

sndptr0:	.ds	2
sndptr1:	.ds	2
sndptr2:	.ds	2
sndptr3:	.ds	2
sndptr4:	.ds	2
sndptr5:	.ds	2


		.code

;
; initialize sound
;
snd_init:	stz	sndptr0
		stz	sndptr1
		stz	sndptr2
		stz	sndptr3
		stz	sndptr4
		stz	sndptr5

		stz	sndcount0
		stz	sndcount1
		stz	sndcount2
		stz	sndcount3
		stz	sndcount4
		stz	sndcount5

		stz	psg_mainvol
		stz	psg_lfoctrl

		lda	#5	; set volume to zero for each channel
.l1:		sta	psg_ch	; and disable them
		stz	psg_ctrl
		stz	psg_pan
		dec	A
		bpl	.l1

		lda	#4	; disable noise for channel 5/6
		sta	psg_ch
		stz	psg_noise
		lda	#5
		sta	psg_ch
		stz	psg_noise
		rts

;
; snd_trkreg
; ----
; register a track into a voice
; ----
; IN:  _AL = voice number
;      _SI = address of track data (must be mapped)
; ----
snd_trkreg:	lda	<_al
		tax
		stz	sndcount0,x
		asl	A
		tax
		stw	<_si, sndptr0,x
		rts


;
; snd_interval
; ----
; continue playing the track at a vsync/timer interval,
; updating counters as necessary
; ----
snd_interval:	ldx	#0
.loop:		lda	sndcount0,x	; 6 downcounters
		beq	.downcnt
		dec	A		; not zero, count down
		sta	sndcount0,x
		bra	.next

.downcnt:	stx	<_al		; if zero, check if voice has
		asl	<_al		; registered playable track
		stz	<_ah
		stw	#sndptr0,<_cx	; _cx is pointer to track pointer
		addw	<_ax,<_cx

		cly
		lda	[_cx],y		; now sndtrkptr is track pointer
		sta	<sndtrkptr
		iny
		lda	[_cx],y
		sta	<sndtrkptr+1

		cmpw	#0,<sndtrkptr		; if track pointer is zero
		beq	.next		; (no track), go to next voice

.exe:		phx			; else execute sound
		stx	<_al
		txa
		sta	psg_ch		; set channel
		jsr	snd_execute	; interpret byte-stream
		plx

		stz	<_ah		; at end, update track pointer
		asl	<_al		; in voice context
		addw	#sndptr0,<_ax
		lda	<sndtrkptr
		cly
		sta	[_ax],y
		iny
		lda	<sndtrkptr+1
		sta	[_ax],y

.next:		inx
		cpx	#6
		bne	.loop
		rts
		

;
; snd_execute
; ----
; execute the sound track currently registered
; ----
; IN: _AL = voice
;     sndtrkptr = ptr to sound code
; ----
snd_execute:
.loop:		cly
		lda	[sndtrkptr]

		cmp	#SND_STOP
		bne	.byte1
		cla
		sta	psg_ctrl
		sta	<sndtrkptr
		sta	<sndtrkptr+1
		jmp	.out

.byte1:		cmp	#SND_OFF
		bne	.byte2
		stz	psg_ctrl	; off with no volume
		incw	<sndtrkptr
		jmp	.loop

.byte2:		cmp	#SND_ON
		bne	.byte3
		lda	#(PSG_ENABLE | $1F)	; on + full volume
		sta	psg_ctrl
		incw	<sndtrkptr
		jmp	.loop

.byte3:		cmp	#SND_VOLUME
		bne	.byte4
		iny
		lda	[sndtrkptr],y
		sta	psg_pan
		addw	#2,<sndtrkptr
		jmp	.loop

.byte4:		cmp	#SND_FREQ
		bne	.byte5
		iny
		lda	[sndtrkptr],y
		sta	psg_freqlo
		iny
		lda	[sndtrkptr],y
		sta	psg_freqhi
		addw	#3,<sndtrkptr
		jmp	.loop

.byte5:		cmp	#SND_DURATION
		bne	.byte6
		lda	<_al
		tax
		iny
		lda	[sndtrkptr],y
		sta	sndcount0,x
		addw	#2,<sndtrkptr
		jmp	.out

.byte6:		cmp	#SND_NOISE_FREQ
		bne	.byte7
		iny
		lda	[sndtrkptr],y
		sta	psg_noise
		addw	#2,<sndtrkptr
		jmp	.loop

.byte7:		cmp	#SND_NOISE_OFF
		bne	.byte8
		iny
		stz	psg_noise
		incw	<sndtrkptr
		jmp	.loop

.byte8:		cmp	#SND_LFO_FREQ
		bne	.byte9
		iny
		lda	[sndtrkptr],y
		sta	psg_lfofreq
		addw	#2,<sndtrkptr
		jmp	.loop

.byte9:		cmp	#SND_LFO_CTRL
		bne	.byte20
		iny
		lda	[sndtrkptr],y
		sta	psg_lfoctrl
		addw	#2,<sndtrkptr
		jmp	.loop

.byte20:	cmp	#SND_WAVE_SINE
		bne	.byte21
		stw	#sine,<wavptr
		jsr	snd_loadwave
		incw	<sndtrkptr
		jmp	.loop

.byte21:	cmp	#SND_WAVE_SAW
		bne	.byte22
		stw	#sawtooth,<wavptr
		jsr	snd_loadwave
		incw	<sndtrkptr
		jmp	.loop

.byte22:	cmp	#SND_WAVE_SQR
		bne	.byte30
		stw	#square,<wavptr
		jsr	snd_loadwave
		incw	<sndtrkptr
		jmp	.loop

.byte30:	cmp	#SND_WAVE_DATA
		bne	.out
		incw	<sndtrkptr
		stw	<sndtrkptr,<wavptr
		jsr	snd_loadwave
		stw	<wavptr,<sndtrkptr
		jmp	.loop

.out:		rts


;
; load a waveform into a PSG channel
; PSG channel must already be set
;
snd_loadwave:	lda	#0
		sta	psg_ctrl

		ldx	#$20
.l1:		lda	[wavptr]
		sta	psg_wave
		incw	<wavptr
		dex
		bne	.l1

		lda	#PSG_ENABLE
		ora	#$1F		; full volume
		sta	psg_ctrl
		rts
		
;
; standard wave tables
;
sine:		db	18,22,24,26,28,28,30,30
		db	30,30,28,28,26,24,22,18
		db	12, 8, 6, 4, 2, 2, 0, 0
		db	 0, 0, 2, 2, 4, 6, 8,12
sawtooth:	db	17,19,21,23,25,27,29,31
		db	31,29,27,25,23,21,19,17
		db	15,13,11, 9, 7, 5, 3, 1
		db	 1, 3, 5, 7, 9,11,13,15
square:		db	 0, 0, 0, 0, 0, 0, 0, 0
		db	 0, 0, 0, 0, 0, 0, 0, 0
		db	31,31,31,31,31,31,31,31
		db	31,31,31,31,31,31,31,31
