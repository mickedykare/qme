XLSFILE=i2c_master_core_register_test.xlsm
all:convert2csv generate
convert2csv:
	ruvm_xls2csv.pl i2c_master_core_register_test.xls

generate:
	${MODEL_TECH}/RUVM_4.4/vreguvm -csvin regs.csv -autoinstance -block default_top_block -uvmout i2c_master_uvm_reg.sv
