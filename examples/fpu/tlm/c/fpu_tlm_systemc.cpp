// $Id: //dvt/tme/dev/main/TechTalks/VM/VM_TechTalk_lab/fpu/tlm/c/fpu_tlm_dpi_c.cpp#1 $
//----------------------------------------------------------------------
//   Copyright 2005-2006 Mentor Graphics Corporation
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

#include <systemc.h>
#include <cmath>

#include "dpiheader.h"

#define OP_ADD 0
#define OP_SUB 1
#define OP_MUL 2
#define OP_DIV 3
#define OP_SQR 4
//----------------------------------------------------------------------
void
com_pute(
	 const REQSTRUCT* req,
	       RSPSTRUCT* res)
{
  float result;

  switch( req->op )
  {
  case OP_ADD:
	result = req->a + req->b;
	break;
  case OP_SUB:
	result = req->a - req->b;
	break;
  case OP_MUL:
	result = req->a * req->b;
	break;
  case OP_DIV:
	result = (req->b <= 1.0e-32 && req->b >=1.0e-32)
	  ? INFINITY
	  : req->a / req->b;
	break;
  case OP_SQR:
	result = (req->a < 0.0)
	  ? NAN
	  : sqrt(req->a);
	break;
  }



  res->a      = req->a;
  res->b      = req->b;
  res->op     = req->op;
  res->round  = req->round;
  res->result = result;
}


#include "systemc.h"

SC_MODULE (first_counter) {
  sc_in_clk	clock ;      // Clock input of the design
  sc_in<bool>	reset ;      // active high, synchronous Reset input
  sc_in<bool>	enable;      // Active high enable signal for counter
  sc_out<sc_uint<4> > counter_out; // 4 bit vector output of the counter

  //------------Local Variables Here---------------------
  sc_uint<4>	    count;

  //------------Code Starts Here-------------------------
  // Below function implements actual counter logic
  void incr_count () {
    // At every rising edge of clock we check if reset is active
    // If active, we load the counter output with 4'b0000
    if (reset.read() == 1) {
      count =  0;
      counter_out.write(count);
    // If enable is active, then we increment the counter
    } else if (enable.read() == 1) {
      count = count + 1;
      counter_out.write(count);
      cout<<"@" << sc_time_stamp() <<" :: Incremented Counter "
	<<counter_out.read()<<endl;
    }
  } // End of function incr_count

  // Constructor for the counter
  // Since this counter is a positive edge trigged one,
  // We trigger the below block with respect to positive
  // edge of the clock and also when ever reset changes state
  SC_CTOR(first_counter) {
    cout<<"Executing new"<<endl;
    SC_METHOD(incr_count);
    sensitive << reset;
    sensitive << clock.pos();
  } // End of Constructor

}; // End of Module counter
