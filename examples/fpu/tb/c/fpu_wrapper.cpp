#include <systemc.h>
#include "fpu_top.h"
#include "uvmc.h"
#ifndef SC_INCLUDE_DYNAMIC_PROCESSES
#define SC_INCLUDE_DYNAMIC_PROCESSES
#endif

using namespace tlm;
using namespace uvmc;
using namespace std;
using namespace sc_core;

//#include "gp_with_<MYTYPE>_converter.h"


SC_MODULE(force_block)
{
    sc_signal<sc_uint<32> > force_value;
    sc_signal<bool> update_timer_counter;

    fpu_top *ref_ptr; /* Pointer to the reference model in sc_main */

    void force_timer_counter();
    void set_ref_ptr(fpu_top *ref);

    // Constructor
    SC_CTOR(force_block)
    {
        SC_METHOD(force_timer_counter);
        sensitive << update_timer_counter.posedge_event();
        dont_initialize();

        force_value.observe_foreign_signal("/top/force_value");        
        update_timer_counter.observe_foreign_signal("/top/update_timer_counter");        
    }

    ~force_block()
    {
    }
};

void force_block::set_ref_ptr(fpu_top *ref)
{
                ref_ptr = ref;
}

void force_block::force_timer_counter()
{
                ref_ptr->set_timer_counter(force_value.read());
}


int sc_main(int argc, char*argv[]) {
	sc_core::sc_time cycle_time(2, SC_NS);
	sc_core::sc_time delay(0, SC_NS);
	sc_core::sc_signal<bool> stop;
	sc_core::sc_signal<short int> fpu_warning;

	stop.observe_foreign_signal("/top/stop_fpu");
	fpu_warning.control_foreign_signal("/top/tlm_fpu_warn");

	/////////////////////////////////////////////////
	/// Force block for forcing large counter values
	/////////////////////////////////////////////////
	force_block my_force("my_force");

	fpu_top fpu_systemc("fpu_systemc");

	my_force.set_ref_ptr( &fpu_systemc);

	fpu_systemc.stop.bind(stop);
	fpu_systemc.fpu_warning.bind(fpu_warning);

	/////////////////////////////////////////////////
	// Connect the signals with UVMConnect
	//	uvmc_connect<gp_with_MYTYPE_converter>(ref.portA,"fpu_portA");
	//	uvmc_connect<gp_with_MYTYPE_converter>(ref.portB,"fpu_portB");
	//	uvmc_connect<gp_with_MYTYPE_converter>(ref.result,"fpu_result"); 
	uvmc_connect(fpu_systemc.portA,"request_socket");
	uvmc_connect(fpu_systemc.result,"response_socket"); 


	sc_start(-1);
	return 0;

}
