sccom -reportprogress -work work ./fpu_core.cpp
sccom -reportprogress -work work ./fpu_top.cpp
sccom -reportprogress -work work ./fpu_tlm_wrapper.cpp
sccom -link -work work -lib uvmc_lib -lib work
vsim -c work.sc_main
