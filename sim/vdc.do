vlib work
vcom -explicit  -93 "../src/sram_sim.vhd"
vcom -explicit  -93 "../src/flash_sim.vhd"
vcom -explicit  -93 "../src/ram.vhd"
vcom -explicit  -93 "../src/pll_sim.vhd"
vcom -explicit  -93 "../src/hex.vhd"
vcom -explicit  -93 "../src/colram.vhd"
vcom -explicit  -93 "../src/scanline.vhd"
vcom -explicit  -93 "../src/huc6260.vhd"
vcom -explicit  -93 "../src/linebuf.vhd"
vcom -explicit  -93 "../src/satram.vhd"
vcom -explicit  -93 "../src/huc6270.vhd"
vcom -explicit  -93 "../src/vdc_top.vhd"
vcom -explicit  -93 "../src/vdc_top_tb.vhd"
vsim -t 1ps -lib work tb
view wave
delete wave *
view structure
view signals
onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -format Logic /tb/sys/reset_n
add wave -noupdate -format Logic /tb/sys/clk

add wave -noupdate -divider "Memory"
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/sram_addr
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/sram_dq
add wave -noupdate -format Logic /tb/sys/sram_ce_n
add wave -noupdate -format Logic /tb/sys/sram_oe_n
add wave -noupdate -format Logic /tb/sys/sram_we_n

#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/fl_addr
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/fl_dq
#add wave -noupdate -format Logic /tb/sys/fl_oe_n

add wave -noupdate -divider "VCE"
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vce/h_cnt
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vce/vga_h_cnt
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vce/vga_v_cnt
#add wave -noupdate -format Logic /tb/sys/vce/bl_n
#add wave -noupdate -format Literal /tb/sys/vce/dotclock
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vce/clken_cnt
add wave -noupdate -format Logic /tb/sys/vce/clken
#add wave -noupdate -format Logic /tb/sys/vce/vga_hs_n
#add wave -noupdate -format Logic /tb/sys/vce/vga_vs_n
#add wave -noupdate -format Logic /tb/sys/vce/hs_n
#add wave -noupdate -format Logic /tb/sys/vce/vs_n

add wave -noupdate -divider "VDC - Count/Sync"
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/x_ren_start
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/x_ren_end
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/y_bgren_start
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/y_bgren_end
#add wave -noupdate -format Logic /tb/sys/vdc/y_update
add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/x
add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/y
add wave -noupdate -format Logic /tb/sys/vdc/bg_active
add wave -noupdate -format Logic /tb/sys/vdc/ren_active
add wave -noupdate -format Logic /tb/sys/vdc/sp1_active
add wave -noupdate -format Logic /tb/sys/vdc/sp2_active
add wave -noupdate -format Logic /tb/sys/vdc/dma_active
add wave -noupdate -format Logic /tb/sys/vdc/dbg_vbl
add wave -noupdate -format Logic /tb/sys/vdc/dmas_active
add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/rcnt
add wave -noupdate -format Logic /tb/sys/vdc/sp_on
add wave -noupdate -format Logic /tb/sys/vdc/bg_on
add wave -noupdate -format Logic /tb/sys/vdc/burst

add wave -noupdate -divider "VDC - DMAS"
add wave -noupdate -format Literal /tb/sys/vdc/dmas
add wave -noupdate -format Logic /tb/sys/vdc/dmas_busy
add wave -noupdate -format Logic /tb/sys/vdc/dmas_ram_req
add wave -noupdate -format Logic /tb/sys/vdc/dmas_ram_ack
add wave -noupdate -format Logic /tb/sys/vdc/dmas_sat_we
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/dmas_sat_a
add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/dmas_sat_di

add wave -noupdate -divider "VDC - IRQ"
#add wave -noupdate -format Logic /tb/sys/vdc/irq_vbl
#add wave -noupdate -format Logic /tb/sys/vdc/irq_rcr
#add wave -noupdate -format Logic /tb/sys/vdc/irq_dma
#add wave -noupdate -format Logic /tb/sys/vdc/irq_dmas
#add wave -noupdate -format Logic /tb/sys/vdc/irq_ovf
#add wave -noupdate -format Logic /tb/sys/vdc/irq_col
add wave -noupdate -format Logic /tb/sys/vdc/irq_n

#add wave -noupdate -divider "VDC - BG Engine"
#add wave -noupdate -format Literal /tb/sys/vdc/bg1
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/bg_cyc
#add wave -noupdate -format Logic /tb/sys/vdc/bg_busy
#add wave -noupdate -format Logic /tb/sys/vdc/bg_ram_req
#add wave -noupdate -format Logic /tb/sys/vdc/bg_ram_ack
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/bg_y
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/bg_ram_a
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/bg_ram_do
#add wave -noupdate -format Logic /tb/sys/vdc/bg2_ini_req
#add wave -noupdate -format Logic /tb/sys/vdc/bg2_req
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/bg2_mem_a
#add wave -noupdate -format Logic /tb/sys/vdc/bg2_mem_we
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/bg2_mem_di

#add wave -noupdate -divider "VDC - Sprite Engine"
#add wave -noupdate -format Literal /tb/sys/vdc/sp1
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/sp_cur_y
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/sp_sat_a
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/sp_sat_do
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/sp_name
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/sp_cgx
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/sp_cgy
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/sp_hf
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/sp_vf
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/sp_nb
#add wave -noupdate -format Literal /tb/sys/vdc/sp2
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/sp_cur
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/sp_prebuf(0).addr
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/sp_prebuf(1).addr
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/sp_ram_a
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/sp_ram_do
#add wave -noupdate -format Logic /tb/sys/vdc/sp_ram_req
#add wave -noupdate -format Logic /tb/sys/vdc/sp_ram_ack

#add wave -noupdate -divider "VDC - Line rendering"
#add wave -noupdate -format Literal /tb/sys/vdc/ren
#add wave -noupdate -format Literal -radix unsigned /tb/sys/vdc/ren_mem_a
#add wave -noupdate -format Logic /tb/sys/vdc/ren_mem_we
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/ren_mem_do
#add wave -noupdate -format Literal -radix hexadecimal /tb/sys/vdc/colno_ff

#add wave -noupdate -divider "SCANDOUBLER"
#add wave -noupdate -format Logic /tb/sys/vce/sl0_we
#add wave -noupdate -format Logic /tb/sys/vce/sl1_we
#add wave -noupdate -format Literal /tb/sys/vce/r_ff
#add wave -noupdate -format Literal /tb/sys/vce/g_ff
#add wave -noupdate -format Literal /tb/sys/vce/b_ff
#add wave -noupdate -format Literal /tb/sys/vce/vga_r_ff
#add wave -noupdate -format Literal /tb/sys/vce/vga_g_ff
#add wave -noupdate -format Literal /tb/sys/vce/vga_b_ff


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
