#ifndef __FPU_TOP_H__
#define __FPU_TOP_H__
#include "systemc.h"
#include "tlm.h"
#include "fpu_core.h"
#include "fpu_extension.h"

class fpu_top :public sc_core::sc_module {
 public:
  tlm::tlm_target_socket< > portA;
  tlm::tlm_initiator_socket< > result;
  sc_in<bool> stop;
  sc_out<short int> fpu_warning;

  SC_HAS_PROCESS(fpu_top);
  // Constructor
  fpu_top(sc_module_name name);
  // Destructor
  ~fpu_top();

  fpu_core *fpu_core_inst;

  void set_timer_counter(int);


private:
	sc_core::sc_signal<bool> sig_stop;
   void fpu_top_thread(); //SC_THREAD
	void stop_process();

	sc_int<32> timer_value;

};

#endif
