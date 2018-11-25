all: tb_pll

tb:
	iverilog -s top -o output/tb.out -I support/wb_common ../hyperram/wb_hyper.v wb_hyper_tb.v ../hyperram/hyper_xface.v hyper_wrapper.v models/s27ks0641.v support/vlog_tb_utils/vlog_tb_utils.v support/vlog_tb_utils/vlog_tap_generator.v support/wb_bfm/wb_bfm_master.v
	vvp output/tb.out +vcd

tb_pll:
	iverilog -s top -o output/tb_pll.out -I support/wb_common ../hyperram_pll/ecp5_iddrx1f.v ../hyperram_pll/ecp5_oddrx1f.v ../hyperram_pll/wb_hyper_pll.v wb_hyper_tb.v ../hyperram_pll/hyper_xface_pll.v hyper_wrapper.v ecp5_ddr_sim.v models/s27ks0641.v support/vlog_tb_utils/vlog_tb_utils.v support/vlog_tb_utils/vlog_tap_generator.v support/wb_bfm/wb_bfm_master.v
	vvp output/tb_pll.out +vcd

tb_crc:
	iverilog -s top -o output/tb_crc.out -I support/wb_common crc_tb.v ../crc32/wb_crc32.v ../crc32/CRC32_Ethernet_x32.v support/vlog_tb_utils/vlog_tb_utils.v support/vlog_tb_utils/vlog_tap_generator.v support/wb_bfm/wb_bfm_master.v
	vvp output/tb_crc.out +vcd

full:
	iverilog -g2001 -s top -o output/tb_full.out -I support/wb_common -I .. -I ../sdc_dma/verilog -I ../cmos_capture -f full_filelist.txt
	vvp output/tb_full.out +vcd +firmware=firmware.hex
