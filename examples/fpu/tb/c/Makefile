ROOT_DIR=/home/hakanp/designs
# This makefile is intended to be called from the main one. I.e. if it exists
MTECH=$(shell echo `which vsim` | sed 's/\(.*\)linux/\1/' | sed 's/\(.*\)_x86_64/\1/' | sed 's/\/bin\/vsim//')
WORK=work

CPPVER=
ifdef CPPVER
CPPINSTALL=-cppinstall ${CPPVER}
else
CPPINSTALL=
endif

UVMC_HOME=${ROOT_DIR}/fpu_uvm_systemc/uvmc/xl-uvmc-2.2

INCLUDE_LIBS=-I${MTECH}/include/systemc -I${MTECH}/include/systemc/tlm -I${ROOT_DIR}/fpu_uvm_systemc/tb/c/ -I${UVMC_HOME}/src/connect/sc -I$(UVMC_HOME)/../converters/ 
SC_ARGS= ${INCLUDE_LIBS} -g -Wall -fmessage-length=0 -fPIC -pipe -work ${WORK} -scv -DQUESTA -DSC_INCLUDE_DYNAMIC_PROCESSES -O0
SCCOM = sccom ${SC_ARGS}


SCCOM_LINK=sccom -g -link ${SC_ARGS}
SCCOM_LINK2=sccom -g -link -scv -lib uvmc_lib -lib work 

UVM_HOME=${MTECH}/verilog_src/${UVM_VERSION}/src
UVMC_SC_X_ARGS=

C_ARGS=
UVM_X_ARGS=
UVM_VERSION=uvm-1.1d
QUESTA_DIR=/opt/eda/questa/10.3/questasim
UVM_HOME=${QUESTA_DIR}/verilog_src/${UVM_VERSION}/src
UVM_INC_DIR=+incdir+${UVM_HOME}
LIBDIR=.
QUESTA_UVM_PKG_HOME=${QUESTA_DIR}/verilog_src/questa_uvm_pkg-1.2/src
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
	export UVM_HOME=${UVM_HOME};vlog -32  -work uvmc_lib -incr +incdir+$(UVM_HOME)/src +incdir+$(UVMC_HOME)/src/connect/sv $(UVMC_HOME)/src/connect/sv/uvmc_pkg.sv ${UVMC_X_ARGS};
	export UVM_HOME=${UVM_HOME};sccom -32 -work uvmc_lib -incr -g -I$(UVMC_HOME)/src/connect/sc $(UVMC_HOME)/src/connect/sc/uvmc.cpp
	export UVM_HOME=${UVM_HOME}; sccom -32 -work uvmc_lib -g -I$(UVMC_HOME)/src/connect/sc -DSC_INCLUDE_DYNAMIC_PROCESSES -linkshared
# 64 bit version
#             export UVM_HOME=${UVM_HOME};vlog -64  -work uvmc_lib -incr +incdir+$(UVM_HOME)/src +incdir+$(UVMC_HOME)/src/connect/sv $(UVMC_HOME)/src/connect/sv/uvmc_pkg.sv;
#             export UVM_HOME=${UVM_HOME};sccom -64 -work uvmc_lib -incr -g -I$(UVMC_HOME)/src/connect/sc $(UVMC_HOME)/src/connect/sc/uvmc.cpp;
#             export UVM_HOME=${UVM_HOME};sccom -64 -work uvmc_lib -g -I$(UVMC_HOME)/src/connect/sc -DSC_INCLUDE_DYNAMIC_PROCESSES -linkshared

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
	${SCCOM} -32  \
	-I${ROOT_DIR}/fpu_uvm_systemc/tlm_models/fpu/ \
	${ROOT_DIR}/fpu_uvm_systemc/tlm_models/fpu/fpu_top.cpp \
	${ROOT_DIR}/fpu_uvm_systemc/tlm_models/fpu/fpu_core.cpp 
	

compile_wrapper:
	@echo "Compiling wrapper";
	@echo ${MTECH};
	${SCCOM} -32 -verbose \
	${UVMC_SC_X_ARGS} \
	${CPPINSTALL} \
	-I${ROOT_DIR}/fpu_uvm_systemc/tlm_models/fpu/ \
	-I${ROOT_DIR}/fpu_uvm_systemc/tlm_models/common/ \
	-I${ROOT_DIR}/fpu_uvm_systemc/uvmc/converters \
	${ROOT_DIR}/fpu_uvm_systemc/fpu/tb/c/fpu_wrapper.cpp \
	${ROOT_DIR}/fpu_uvm_systemc/tlm_models/fpu/fpu_top.cpp \
	${ROOT_DIR}/fpu_uvm_systemc/tlm_models/fpu/fpu_core.cpp 

link_wrapper:
	@echo "Linking wrapper"
	${SCCOM_LINK} ${CPPINSTALL} -lib uvmc_lib


comp_link:  compile_wrapper link_wrapper

load:
	vsim -c -L uvmc_lib -L work work.sc_main 
xx:
	sccom -g \
	-I${UVMC_HOME}/src/connect/sc -I$(UVMC_HOME)/../converters/ \
	-I${MTECH}/include/systemc -I${MTECH}/include/systemc/tlm \
	-I${ROOT_DIR}/fpu_uvm_systemc/tlm_models/fpu/ \
	-I${ROOT_DIR}/fpu_uvm_systemc/tlm_models/common/ \
	-I${ROOT_DIR}/fpu_uvm_systemc/uvmc/converters \
	${ROOT_DIR}/fpu_uvm_systemc/fpu/tb/c/fpu_wrapper.cpp \
	${ROOT_DIR}/fpu_uvm_systemc/tlm_models/fpu/fpu_top.cpp \
	${ROOT_DIR}/fpu_uvm_systemc/tlm_models/fpu/fpu_core.cpp 
	sccom -link -lib uvmc_lib 

yy:
	vsim  -L uvmc_lib -L work work.sc_main

allxx:  clean compile_uvm compile_uvmc xx yy
