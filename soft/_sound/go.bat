@SET PCE_INCLUDE=..\MKIT251\INCLUDE\PCE
@..\MKIT251\BIN\PCEAS -l 3 -m sound.asm
perl ..\..\bin2txt.pl sound.pce > ..\..\sim\flash.txt

