# This makefile is intended to be called from the main one. I.e. if it exists
MTECH=$(shell echo `which vsim` | sed 's/\(.*\)linux/\1/' | sed 's/\(.*\)_x86_64/\1/' | sed 's/\/bin\/vsim//')
WORK=work
CPPVER=
UVMC_HOME=${QME_HOME}/examples/uvmc/xl-uvmc-2.2
#INCLUDE_LIBS=-I${MTECH}/include/systemc  -I${QME_PROJECT_HOME}/fpu/tb/c/ -I${UVMC_HOME}/src/connect/sc -I$(UVMC_HOME)/../converters
INCLUDE_LIBS=-I${QME_PROJECT_HOME}/fpu/tb/c/ -I${UVMC_HOME}/src/connect/sc 
SYSTEMC_ARGS= ${INCLUDE_LIBS} -g -Wall -fmessage-length=0 -fPIC -pipe -work ${WORK} -scv -DQUESTA -DSC_INCLUDE_DYNAMIC_PROCESSES -O0
SCCOM = sccom 
SCCOM_LINK=${SCCOM} -g -link ${SYSTEMC_ARGS}
UVM_VERSION=uvm-1.1d
UVM_HOME=${MTECH}/verilog_src/${UVM_VERSION}/src
UVM_INC_DIR=+incdir+${UVM_HOME}
QUESTA_UVM_PKG_HOME=${QUESTA_DIR}/verilog_src/questa_uvm_pkg-1.2/src
UVMC_SC_X_ARGS=
C_ARGS=
UVM_X_ARGS=
LIBDIR=.


ifdef CPPVER
CPPINSTALL=-cppinstall ${CPPVER}
else
CPPINSTALL=
endif
ARCH=32

help:
	@echo "Read the Makefile"

#// This will compile and do a sanity check on the wrapper.
sanity:clean uvmc compile_wrapper link_wrapper load

clean:
	rm -f *.o
	rm -rf work
	rm -rf uvmc_lib
	rm -rf ${UVM_VERSION}
	vlib work
	vlib ${UVM_VERSION}
	vlib uvmc_lib
	vmap uvmc_lib uvmc_lib

uvmc:
	# 32 bit version
	export UVM_HOME=${UVM_HOME};vlog -${ARCH}  -work uvmc_lib -incr +incdir+$(UVM_HOME)/src +incdir+$(UVMC_HOME)/src/connect/sv $(UVMC_HOME)/src/connect/sv/uvmc_pkg.sv ${UVMC_X_ARGS};
	export UVM_HOME=${UVM_HOME};${SCCOM} -${ARCH} -work uvmc_lib -incr -g -I$(UVMC_HOME)/src/connect/sc $(UVMC_HOME)/src/connect/sc/uvmc.cpp
	export UVM_HOME=${UVM_HOME}; ${SCCOM} -${ARCH} -work uvmc_lib -g -I$(UVMC_HOME)/src/connect/sc -DSC_INCLUDE_DYNAMIC_PROCESSES -linkshared
# 64 bit version
#             export UVM_HOME=${UVM_HOME};vlog -64  -work uvmc_lib -incr +incdir+$(UVM_HOME)/src +incdir+$(UVMC_HOME)/src/connect/sv $(UVMC_HOME)/src/connect/sv/uvmc_pkg.sv;
#             export UVM_HOME=${UVM_HOME};${SCCOM} -64 -work uvmc_lib -incr -g -I$(UVMC_HOME)/src/connect/sc $(UVMC_HOME)/src/connect/sc/uvmc.cpp;
#             export UVM_HOME=${UVM_HOME};${SCCOM} -64 -work uvmc_lib -g -I$(UVMC_HOME)/src/connect/sc -DSC_INCLUDE_DYNAMIC_PROCESSES -linkshared

compile_uvm:
	test -d ${LIBDIR}/${UVM_VERSION}||vlib ${LIBDIR}/${UVM_VERSION}
	vmap mtiUvm ${LIBDIR}/${UVM_VERSION}
	vlog ${UVM_X_ARGS} -mfcu -suppress 2181 -sv -work mtiUvm \
	${UVM_INC_DIR} ${VLOG_TIMESCALE} \
	${UVM_HOME}/uvm.sv 
	vlog +incdir+${QUESTA_UVM_PKG_HOME} \
	-mfcu -suppress 2181 -sv -work mtiUvm ${UVM_INC_DIR} \
	${QUESTA_UVM_PKG_HOME}/questa_uvm_pkg.sv \
	${UVM_HDL_MAX_WIDTH} \
	$(UVM_HOME)/dpi/uvm_dpi.cc  ${UVM_X_ARGS}


compile_uvmc:
	test -d ${LIBDIR}/uvmc_lib||vlib ${LIBDIR}/uvmc_lib
	make -f ${UVMC_HOME}/lib/Makefile.questa UVM_HOME=${UVM_HOME}/.. UVMC_HOME=${UVMC_HOME} \
	UVMC_LIB=${LIBDIR}/uvmc_lib BITS=32 UVM_LIB=${LIBDIR}/${UVM_VERSION} \
	UVM_VERSION=${UVM_VERSION} UVMC_X_ARGS=${UVM_X_ARGS} UVMC_SC_X_ARGS=${UVMC_SC_X_ARGS} uvmc_pkg

compile_fpu:
	${SCCOM} ${SYSTEMC_ARGS} -${ARCH}  \
	-I${QME_PROJECT_HOME}/fpu/tlm_models/fpu/ \
	${QME_PROJECT_HOME}/fpu/tlm_models/fpu/fpu_top.cpp \
	${QME_PROJECT_HOME}/fpu/tlm_models/fpu/fpu_core.cpp 


compile_wrapper:
	@echo "Compiling wrapper";
	@echo ${MTECH};
	${SCCOM} ${SYSTEMC_ARGS} -${ARCH} -verbose \
	${UVMC_SC_X_ARGS} \
	${CPPINSTALL} \
	-I${QME_PROJECT_HOME}/tlm_models/fpu/ \
	-I${QME_PROJECT_HOME}/tlm_models/common/ \
	-I${QME_PROJECT_HOME}/fpu/uvmc/converters \
	${QME_PROJECT_HOME}/fpu/tb/c/fpu_wrapper.cpp \
	${QME_PROJECT_HOME}/tlm_models/fpu/fpu_top.cpp \
	${QME_PROJECT_HOME}/tlm_models/fpu/fpu_core.cpp 

link_wrapper:
	@echo "Linking wrapper"
	${SCCOM_LINK} ${CPPINSTALL} -lib uvmc_lib


comp_link:  compile_wrapper link_wrapper

load:
	vsim -c -L uvmc_lib -L work work.sc_main 

