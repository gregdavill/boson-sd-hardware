tb:
	iverilog -s top -o output/tb.out -I support/wb_common ../hyperram/wb_hyper.v wb_hyper_tb.v ../hyperram/hyper_xface.v hyper_wrapper.v models/s27ks0641.v support/vlog_tb_utils/vlog_tb_utils.v support/vlog_tb_utils/vlog_tap_generator.v support/wb_bfm/wb_bfm_master.v
	vvp output/tb.out +vcd