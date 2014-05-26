#ifndef __FPU_CORE_CPP__
#define __FPU_CORE_CPP__

#ifndef SC_INCLUDE_DYNAMIC_PROCESSES
#define SC_INCLUDE_DYNAMIC_PROCESSES
#endif

#include "fpu_core.h"
#include <iostream>

using namespace std;
using namespace tlm;
using namespace sc_core;

//Constructor
fpu_core::fpu_core(sc_module_name name) : 
  sc_module(name),
  portA("portA"),
  result("result"),
  stop("stop"),
  fpu_warning("fpu_warning")
  {
    	portA.register_b_transport(this,&fpu_core::b_transport_portA);
      SC_THREAD(fpu_core_thread);
  }
	
// Destructor
fpu_core::~fpu_core() {
	cout << "fpu_core self destructing in 10...9...8...7...6..." << endl;
}

void fpu_core::b_transport_portA(tlm::tlm_generic_payload& trans,sc_core::sc_time &t) {
	cout << "fpu_core: Received something on portA " << endl;
	cout << "fpu_core: sending it out on result port " << endl;
	wait (t);
	// send something to the result port
	sc_time delay = sc_time(0, SC_NS);
	result->b_transport(trans,delay);
// 	if (trans.has_mm()) {
// 		trans.acquire();
// 		//decode trans...
// 		trans.release();
// 	} else {
// //	tlm::tlm_generic_payload* cp_trans= m_bwi_mm.allocate(trans.get_data_length());
// 	tlm::tlm_generic_payload* cp_trans= new tlm::tlm_generic_payload;
// 	cp_trans->acquire();
// 	cp_trans->set_data_length(trans.get_data_length());
// 	cp_trans->deep_copy_from(trans);
// 	//decode trans...and do something
// 	trans.update_original_from(*cp_trans);
// 	cp_trans->release();
// 	}

}


void fpu_core::fpu_core_thread() {
	while (true) {
		cout << "Inside fpu_core_thread: Writing to fpu_warning in fpu_core" << endl;
		fpu_warning.write(10);
		wait(10);
	}
}

#endif
