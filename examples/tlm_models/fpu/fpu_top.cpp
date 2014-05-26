#ifndef __FPU_TOP_CPP__
#define __FPU_TOP_CPP__

#ifndef SC_INCLUDE_DYNAMIC_PROCESSES
#define SC_INCLUDE_DYNAMIC_PROCESSES
#endif

#include <stdio.h>
#include <iostream>

#include "systemc.h"
#include "tlm.h"

#include "fpu_top.h"

using namespace std;
using namespace tlm;
using namespace sc_core;

// constructor
fpu_top::fpu_top(sc_core::sc_module_name name):
  sc_module(name),
  portA("portA"),
  result("result"),
  stop("stop"),
  fpu_warning("fpu_warning")
{

  fpu_core_inst = new fpu_core("fpu_core");

//  fpu_core_inst->stop(stop);
  stop(fpu_core_inst->stop);
  portA(fpu_core_inst->portA);
  
  fpu_core_inst->result(result);
  fpu_core_inst->fpu_warning(fpu_warning);
//  fpu_warning.bind(fpu_core_inst->fpu_warning);
 
  SC_METHOD(stop_process); sensitive << stop;
  SC_THREAD(fpu_top_thread);

}

// destructor
fpu_top::~fpu_top() {
  delete fpu_core_inst;
}

void fpu_top::stop_process() {
	cout << "In fpu_top: Reading stop signal" << endl;
   sig_stop.write(stop.read());
}

void fpu_top::set_timer_counter(int x) {
	cout << "set_timer_counter" << endl;
	timer_value = x;
}

void fpu_top::fpu_top_thread() {
	while (true) {
		cout << "Inside fpu_top_thread: Incrementing timer" << endl;
		timer_value++;
		wait(100);
	}
}



#endif
