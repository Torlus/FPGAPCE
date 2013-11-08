@SET PCE_INCLUDE=..\MKIT251\INCLUDE\PCE
@..\MKIT251\BIN\PCEAS -raw -l 3 -m TEST.ASM
@perl ..\..\bin2txt.pl TEST.PCE > ..\..\sim\main.txt

