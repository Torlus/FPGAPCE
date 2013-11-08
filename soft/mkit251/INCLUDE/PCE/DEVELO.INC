;
; DEVELO.INC  -  Standard Develo definitions
;
;
	.include	"system.inc"


; --------
; This block defines DEVELO BIOS routine
; entry points.
;

dv_System	= $4000
dv_Standby	= $4003
dv_GetVdp	= $4006
dv_SetVdp	= $4009
dv_Vpoke	= $400C
dv_Vpeek	= $400F
dv_Ram2VRam	= $4012
dv_VRam2Ram	= $4015
dv_FillVram	= $4018
dv_Ram2Plt	= $401B
dv_Plt2Ram	= $401E
dv_Screen1	= $4021
dv_Send1Byte	= $402D
dv_SendBlock	= $4030
dv_Recv1Byte	= $4033
dv_Recv1ByteW	= $4036
dv_RecvBlock	= $4039
dv_FileOpen	= $403C
dv_FileOpen2	= $403F
dv_FileRead	= $4042
dv_FileWrite	= $4045
dv_FileDelete	= $4048
dv_GetDirFirst	= $404B
dv_GetDirNext	= $404E
dv_RegReport	= $4051
dv_XferSync	= $4054
dv_XferQuit	= $4057
dv_FileDskf	= $405A
dv_AutoRun	= $407D


; --------
; This block defines DEVELO BIOS Screen1
; commands.
;

SCRN1_INIT	= 0
SCRN1_CLS	= 1
SCRN1_LOCATE	= 2
SCRN1_PUTC	= 3
SCRN1_PUTS	= 4


; --------
; This block defines DEVELO standard
; variables.
;

XferPtr		equ	$20C8 ; 2
XferLen		equ	$20CA ; 2

Buffer		equ	$2800
FileName	equ	$27E0 ;12
FileTag		equ	$27EC ; 3
FileLoc		equ	$27EF ; 4
FileLen		equ	$27F3 ; 2
FileAdd		equ	$27F5 ; 2

