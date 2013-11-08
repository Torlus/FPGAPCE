; MML.ASM
; -------
;
; MML demo
;
; The music is called "BOOGI BUG" and has been composed by
; Jean-Claude PAULIN in 1987. I found it in an old french
; magazine called 'TILT' (anyone remember it? :)
; It was written for a MSX computer.
;
; Enjoy!
; David
;
; Note: The music is not complete, I was too lazy to type it
;       all, sorry. (^^;
;

	        .include "startup.asm"
		.include "sound.asm"
		.nomlist
		.list

		.code
		.bank	MAIN_BANK
		.org	$C000

main:		map	snd1

		lda	#0		; track 1
		sta	<_al
		stw	#snd1,<_si
		jsr	snd_trkreg
		lda	#1		; track 2
		sta	<_al
		stw	#snd2,<_si
		jsr	snd_trkreg
		lda	#2		; track 3
		sta	<_al
		stw	#snd3,<_si
		jsr	snd_trkreg

		lda	#3		; echo effect
		sta	<_al
		stw	#snd1_e,<_si
		jsr	snd_trkreg
		lda	#4
		sta	<_al
		stw	#snd2_e,<_si
		jsr	snd_trkreg
		lda	#5
		sta	<_al
		stw	#snd3_e,<_si
		jsr	snd_trkreg

		lda	#$99
		sta	psg_mainvol

.here:		vsync
		jsr	snd_interval
		bra	.here


;----
; MUSIC

	.data
	.bank	MAIN_BANK+1
	.org	$4000

snd1:	.mml	"W3T200L4V15O2AO3C#DD#ED#DC#",\
		"O2AO3C#DD#ED#DC#DF#GG#AG#GF#O2AO3C#",\
		"DD#ED#DC#O2BO3C#DD#EO2F#GG#AO3C#DG#",\
		"L12AR12O5C#R12DR12D#R12ER12FR12"

snd2:	.mml	"W3T200L12V14O5G#6A12R2G#6A12",\
		"R4O6C#R12DC#O5AGEDC","G#6A12R2G#6A12R1G#6",\
		"A12R2G#6A12","R4O6CR12DCO5AGEDC",\
		"G#6A12R2G#6A12",\
		"R6ED#6E12O6E6O5E12O6D#6D12",\
		"D6O5E12D#6E12",\
		"O6C#6O5E12O6C6O5B12B12",\
		"R12E4E4R4O6C12C#6O5A12E6D#12",\
		"D6B12G#6A12AR12AR12A#R12BR12O6CR12C#R12"

snd3:	.mml	"W3T200L12V13O5F6F#12R2C6C#12",\
		"R1","F6F#12R2C6C#12R1D#6",\
		"E12R2O4B6O5C12","R1",\
		"F6F#12R2C6C#12",\
		"R2G#6R12G6F#12F#6R12R4",\
		"E6R12D#6D12D12",\
		"R12O4G#4G#4R4O5D#12E6C#12O4G#6G12",\
		"F#6O5D12C6C#12C#R12F#R12GR12G#R12AR12A#R12"

snd1_e:	.mml	"W3T200L4V7R3O2AO3C#DD#ED#DC#",\
		"O2AO3C#DD#ED#DC#DF#GG#AG#GF#O2AO3C#",\
		"DD#ED#DC#O2BO3C#DD#EO2F#GG#AO3C#DG#",\
		"L12AR12O5C#R12DR12D#R12ER12FR12"

snd2_e:	.mml	"W3T200L12V6R3O5G#6A12R2G#6A12",\
		"R4O6C#R12DC#O5AGEDC","G#6A12R2G#6A12R1G#6",\
		"A12R2G#6A12","R4O6CR12DCO5AGEDC",\
		"G#6A12R2G#6A12",\
		"R6ED#6E12O6E6O5E12O6D#6D12",\
		"D6O5E12D#6E12",\
		"O6C#6O5E12O6C6O5B12B12",\
		"R12E4E4R4O6C12C#6O5A12E6D#12",\
		"D6B12G#6A12AR12AR12A#R12BR12O6CR12C#R12"

snd3_e:	.mml	"W3T200L12V5R3O5F6F#12R2C6C#12",\
		"R1","F6F#12R2C6C#12R1D#6",\
		"E12R2O4B6O5C12","R1",\
		"F6F#12R2C6C#12",\
		"R2G#6R12G6F#12F#6R12R4",\
		"E6R12D#6D12D12",\
		"R12O4G#4G#4R4O5D#12E6C#12O4G#6G12",\
		"F#6O5D12C6C#12C#R12F#R12GR12G#R12AR12A#R12"

