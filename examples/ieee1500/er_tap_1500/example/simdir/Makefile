TEST=er_tap_1500_smoke_test

all:clean compile_vips compile_rtl
clean:
	rm -rf work
	rm -f transcript *.wlf *.ucdb
	vlib work

compile_vips:
	vlog ../er_simple_clk_reset/sv/er_simple_clk_reset_pkg.sv +indir+../er_simple_clk_reset/sv/
	vlog ../er_simple_clk_reset/sv/er_simple_clk_reset_if.sv
	vlog ../../sv/er_tap_1500_if.sv
	vlog ../../sv/er_tap_1500_agent_pkg.sv +incdir+../../sv/

compile_rtl:
	vlog ../rtl/tap_1500_beh_model.sv

compile_tb:
	vlog ../tb/tap_1500_tb_pkg.sv +incdir+../tb +incdir+../tc
	vlog ../tb/top.sv

gui:
	vsim -voptargs=+acc top -debugdb -uvmcontrol=all -msgmode both -onfinish stop -classdebug +UVM_TESTNAME=${TEST} -do "run 0;do wave.do"
load:
	vsim -voptargs=+acc top -uvmcontrol=none -msgmode both -onfinish stop  +UVM_TESTNAME=${TEST} -do "run 0" -c
