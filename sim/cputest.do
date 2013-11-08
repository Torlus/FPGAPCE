vlib work
vcom -explicit  -93 "../src/sram_sim.vhd"
vcom -explicit  -93 "../src/flash_sim.vhd"
vcom -explicit  -93 "../src/cpu65xx_e.vhd"
vcom -explicit  -93 "../src/cpu65xx_fast.vhd"
vcom -explicit  -93 "../src/huc6280.vhd"
vcom -explicit  -93 "../src/cputest_top.vhd"
vcom -explicit  -93 "../src/cputest_top_tb.vhd"
vsim -t 1ps -lib work tb
view wave
delete wave *
view structure
view signals
onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -format Logic /tb/sys/reset
add wave -noupdate -format Logic /tb/sys/clock

add wave -noupdate -divider "CPU"
add wave -noupdate -format Logic /tb/sys/cpu/cpu_en
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu_a
add wave -noupdate -format Logic /tb/sys/cpu_rd_n
add wave -noupdate -format Logic /tb/sys/cpu_wr_n
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu_di
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu_do
add wave -noupdate -format Logic /tb/sys/cpu_hsm
add wave -noupdate -divider "CPU DEBUG"
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/theOpcode
add wave -noupdate -format Literal /tb/sys/cpu/cpu/theCpuCycle
add wave -noupdate -format Literal /tb/sys/cpu/cpu/nextCpuCycle
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/myAddr
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/indexOut
add wave -noupdate -format Literal /tb/sys/cpu/cpu/nextAddr
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/U
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/W
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/aluZ
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/aluRmwOut
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/aluRegisterOut
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/PC
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/MPR
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/btSrc
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/btDst
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/btLen
add wave -noupdate -format Logic /tb/sys/cpu/cpu/btAlt
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/A
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/X
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/Y
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/S
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/Z
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/N
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/V
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/C
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/T
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/I
add wave -noupdate -format Literal /tb/sys/cpu/cpu/nvtbdizc
#add wave -noupdate -divider "IRQ"
#add wave -noupdate -format Logic /tb/sys/irq2_n
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/irq2Reg
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/irqActive
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/processIrq
add wave -noupdate -divider "MEMORY"
add wave -noupdate -format Logic /tb/sys/cpu_a(20)
add wave -noupdate -format Logic /tb/sys/cpu_ram_sel_n
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/fl_dq

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 200
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update

set IgnoreWarning 1
#report simulator control
