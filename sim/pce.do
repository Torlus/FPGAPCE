vlib work
#vcom -explicit  -93 "../src/sram_sim.vhd"
vcom -explicit  -93 "../src/sdram_sim.vhd"
vcom -explicit  -93 "../src/flash_sim.vhd"
vcom -explicit  -93 "../src/ram.vhd"

vcom -explicit  -93 "../src/pll_sim.vhd"
#vcom -explicit  -93 "../src/pll.vhd"

vcom -explicit  -93 "../src/hex.vhd"
vcom -explicit  -93 "../src/cpu65xx_e.vhd"
vcom -explicit  -93 "../src/cpu65xx_fast.vhd"
vcom -explicit  -93 "../src/g00_audio_interface.vhd"
vcom -explicit  -93 "../src/voltab.vhd"
vcom -explicit  -93 "../src/psg.vhd"
vcom -explicit  -93 "../src/huc6280.vhd"
vcom -explicit  -93 "../src/colram.vhd"
vcom -explicit  -93 "../src/scanline.vhd"
vcom -explicit  -93 "../src/huc6260.vhd"
vcom -explicit  -93 "../src/linebuf.vhd"
vcom -explicit  -93 "../src/satram.vhd"
vcom -explicit  -93 "../src/huc6270.vhd"
vcom -explicit  -93 "../src/chameleon_old_sdram.vhd"
vcom -explicit  -93 "../src/sdram_controller.vhd"
vcom -explicit  -93 "../src/pce_top.vhd"
vcom -explicit  -93 "../src/pce_top_tb.vhd"
vsim -t 1ps -lib work tb
view wave
delete wave *
view structure
view signals
onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -format Logic /tb/sys/reset_n
add wave -noupdate -format Logic /tb/sys/clk

add wave -noupdate -divider "CPU"
add wave -noupdate -format Logic /tb/sys/cpu_clkrst
add wave -noupdate -format Logic /tb/sys/cpu_clkout
add wave -noupdate -format Logic /tb/sys/cpu/cpu_en
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu_a
add wave -noupdate -format Logic /tb/sys/cpu_rd_n
add wave -noupdate -format Logic /tb/sys/cpu_wr_n
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu_di
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu_do
#add wave -noupdate -format Logic /tb/sys/cpu_hsm
add wave -noupdate -format Logic /tb/sys/cpu_rdy

add wave -noupdate -format Literal /tb/sys/cpu/romHCycles
add wave -noupdate -format Literal /tb/sys/cpu/lateHCycles
add wave -noupdate -format Logic /tb/sys/cpu/clockDone

#add wave -noupdate -format Logic /tb/sys/vdc_irq_n
add wave -noupdate -divider "CPU - DEBUG"
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/theOpcode
#add wave -noupdate -format Literal /tb/sys/cpu/cpu/theCpuCycle
#add wave -noupdate -format Literal /tb/sys/cpu/cpu/nextCpuCycle
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/U
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/myAddr
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/indexOut
#add wave -noupdate -format Literal /tb/sys/cpu/cpu/nextAddr
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/U
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/W
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/aluZ
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/aluRmwOut
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/aluRegisterOut
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/PC
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/MPR
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/btSrc
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/btDst
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/btLen
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/btAlt
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/A
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/X
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/Y
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/cpu/S
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/Z
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/N
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/V
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/C
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/T
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/I
#add wave -noupdate -format Literal /tb/sys/cpu/cpu/nvtbdizc
#add wave -noupdate -divider "IRQ"
#add wave -noupdate -format Logic /tb/sys/irq2_n
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/irq2Reg
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/irqActive
#add wave -noupdate -format Logic /tb/sys/cpu/cpu/processIrq

#add wave -noupdate -format Logic /tb/sys/cpu/tmr_irq
#add wave -noupdate -format Logic /tb/sys/cpu/irq1_n
#add wave -noupdate -format Logic /tb/sys/cpu/irq2_n
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/data_buf
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/int_do

add wave -noupdate -divider "MEMORY MAP"
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu_a
#add wave -noupdate -format Logic /tb/sys/cpu_a(20)
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/rom_a
#add wave -noupdate -format Logic /tb/sys/rom_oe_n
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/rom_do
#add wave -noupdate -format Logic /tb/sys/cpu_ram_sel_n
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/ram_a
#add wave -noupdate -format Logic /tb/sys/ram_we
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/ram_di
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/ram_do
add wave -noupdate -format Logic /tb/sys/cpu_vce_sel_n
add wave -noupdate -format Logic /tb/sys/cpu_vdc_sel_n
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc_do
add wave -noupdate -format Logic /tb/sys/cpu/psg_sel_n
add wave -noupdate -format Logic /tb/sys/cpu/psg_we


add wave -noupdate -divider "SDRAM"
add wave -noupdate -format Logic /tb/DRAM_CLK
add wave -noupdate -format Logic /tb/sys/SDR_CLK
add wave -noupdate -format Literal /tb/sys/sdrc/sdr/ramState
add wave -noupdate -format Literal /tb/sys/sdrc/sdr/currentPort
add wave -noupdate -format Literal /tb/sys/sdrc/sdr/nextRamPort
add wave -noupdate -format Literal -radix hexadecimal /tb/DRAM_ADDR
add wave -noupdate -format Logic /tb/DRAM_RAS_N
add wave -noupdate -format Logic /tb/DRAM_CAS_N
add wave -noupdate -format Logic /tb/DRAM_WE_N
add wave -noupdate -format Literal -radix hexadecimal /tb/DRAM_DQ
add wave -noupdate -format Logic /tb/sys/romrd_req
add wave -noupdate -format Logic /tb/sys/romrd_ack
add wave -noupdate -format Logic /tb/sys/vdccpu_ram_req
add wave -noupdate -format Logic /tb/sys/vdccpu_ram_ack
add wave -noupdate -format Logic /tb/sys/vdcsp_ram_req
add wave -noupdate -format Logic /tb/sys/vdcsp_ram_ack
add wave -noupdate -format Logic /tb/sys/vdcbg_ram_req
add wave -noupdate -format Logic /tb/sys/vdcbg_ram_ack
add wave -noupdate -format Logic /tb/sys/vdcdma_ram_req
add wave -noupdate -format Logic /tb/sys/vdcdma_ram_ack
add wave -noupdate -format Logic /tb/sys/vdcdmas_ram_req
add wave -noupdate -format Logic /tb/sys/vdcdmas_ram_ack


add wave -noupdate -divider "RAM"
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/ram_a
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/ram_di
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/ram_do
add wave -noupdate -format Logic /tb/sys/ram_we

#add wave -noupdate -divider "VDC"
#add wave -noupdate -format Literal /tb/sys/vdc/mc
#add wave -noupdate -format Logic /tb/sys/vdc_ram_req
#add wave -noupdate -format Logic /tb/sys/vdc_ram_ack
#add wave -noupdate -format Logic /tb/sys/vdc_ram_we
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc_ram_a_full
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc_ram_d
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc_ram_q


#add wave -noupdate -divider "FLASH"
#add wave -noupdate -format Literal -radix hexadecimal /tb/FL_ADDR
#add wave -noupdate -format Literal -radix hexadecimal /tb/FL_DQ
#add wave -noupdate -format Logic /tb/FL_OE_N

#add wave -noupdate -divider "VRAM"
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc_ram_a
#add wave -noupdate -format Logic /tb/sys/vdc_ram_ce_n
#add wave -noupdate -format Logic /tb/sys/vdc_ram_oe_n
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc_ram_do
#add wave -noupdate -format Logic /tb/sys/vdc_ram_we_n
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc_ram_di

#add wave -noupdate -divider "VIDEO"
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc_colno
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/y
#add wave -noupdate -format Literal /tb/sys/vdc/sp2
#add wave -noupdate -format Logic /tb/sys/vdc/dmas_active
#add wave -noupdate -format Logic /tb/sys/vdc/sp_on
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/dmas_sat_a
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/dmas_sat_di
#add wave -noupdate -format Logic /tb/sys/vdc/dmas_sat_we
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/sp_nb

#add wave -noupdate -format Literal -radix unsigned /tb/sys/vce/h_cnt
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vce/vga_v_cnt
#add wave -noupdate -format Logic /tb/sys/vce/bl_n
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vce/vga_h_cnt
#add wave -noupdate -format Literal /tb/sys/vce/dotclock
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vce/clken_cnt
#add wave -noupdate -format Logic /tb/sys/vce/clken
#add wave -noupdate -format Logic /tb/sys/vce/vga_hs_n
#add wave -noupdate -format Logic /tb/sys/vce/vga_vs_n
#add wave -noupdate -format Logic /tb/sys/vce/hs_n
#add wave -noupdate -format Logic /tb/sys/vce/vs_n

#add wave -noupdate -divider "SCANDOUBLER"
#add wave -noupdate -format Logic /tb/sys/vce/sl0_we
#add wave -noupdate -format Logic /tb/sys/vce/sl1_we
#add wave -noupdate -format Literal /tb/sys/vce/r_ff
#add wave -noupdate -format Literal /tb/sys/vce/g_ff
#add wave -noupdate -format Literal /tb/sys/vce/b_ff
#add wave -noupdate -format Literal /tb/sys/vce/vga_r_ff
#add wave -noupdate -format Literal /tb/sys/vce/vga_g_ff
#add wave -noupdate -format Literal /tb/sys/vce/vga_b_ff

#add wave -noupdate -divider "PSG"
#add wave -noupdate -format Logic /tb/sys/cpu/psg/clk
#add wave -noupdate -format Logic /tb/sys/cpu/psg/clken
#add wave -noupdate -format Logic /tb/sys/cpu/psg/reset_n
#add wave -noupdate -format Literal -radix unsigned /tb/sys/cpu/psg/ch(0).freq
#add wave -noupdate -format Literal -radix unsigned /tb/sys/cpu/psg/ch(0).wf_cnt
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/psg/ch(0).gl_out
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/psg/ch(1).gl_out
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/psg/ch(2).gl_out
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/psg/ch(3).gl_out
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/psg/ch(4).gl_out
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/psg/ch(5).gl_out

#add wave -noupdate -format Literal /tb/sys/cpu/psg/mix
#add wave -noupdate -format Literal /tb/sys/cpu/psg/vt_addr
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/cpu/psg/vt_addr
#add wave -noupdate -format Literal -radix signed /tb/sys/cpu/psg/vt_data
#add wave -noupdate -format Literal -radix signed /tb/sys/cpu/psg/lacc

#add wave -noupdate -format Literal -radix signed /tb/sys/cpu/psg/ldata
#add wave -noupdate -format Literal -radix signed /tb/sys/cpu/psg/rdata

#add wave -noupdate -divider "AUDIO DAC"
#add wave -noupdate -format Logic /tb/sys/aud_xck
#add wave -noupdate -format Logic /tb/sys/aud_bclk
#add wave -noupdate -format Logic /tb/sys/aud_dacdat
#add wave -noupdate -format Logic /tb/sys/aud_daclrck
#add wave -noupdate -format Logic /tb/sys/cpu/dac_latch
#add wave -noupdate -format Logic /tb/sys/i2c_sdat
#add wave -noupdate -format Logic /tb/sys/i2c_sclk
#add wave -noupdate -format Logic /tb/sys/cpu/dac_clken
#add wave -noupdate -format Logic /tb/sys/cpu/dac_init
#add wave -noupdate -format Literal /tb/sys/cpu/dac/state
#add wave -noupdate -format Literal /tb/sys/cpu/dac/state2


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
