#ifndef __FPU_CORE_H__
#define __FPU_CORE_H__
#include "systemc.h"
#include "tlm.h"
#include "tlm_utils/simple_initiator_socket.h"
#include "tlm_utils/simple_target_socket.h"

class fpu_core: public sc_core::sc_module {
 public:
  tlm_utils::simple_target_socket<fpu_core,32> portA;
  tlm_utils::simple_initiator_socket<fpu_core,32> result;
  sc_core::sc_in<bool> stop;
  sc_core::sc_out<short int> fpu_warning;

  SC_HAS_PROCESS(fpu_core);
  // constructor
  fpu_core(sc_module_name name);
  // destructor
  ~fpu_core();
  
  private:
   void fpu_core_thread(); //SC_THREAD
  	void b_transport_portA(tlm::tlm_generic_payload& trans,
	sc_core::sc_time& t);
};

#endif
