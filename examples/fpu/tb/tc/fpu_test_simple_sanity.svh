import fpu_agent_pkg::*;

class fpu_test_simple_sanity extends fpu_test_base;
`uvm_component_utils(fpu_test_simple_sanity)
 fpu_sequence_simple_sanity s_seq; // The sequence to execute

function new(string name = "fpu_test_simple_sanity", uvm_component parent=null);
      super.new(name, parent);
endfunction // new


function void build_phase(uvm_phase phase);     
      //set_config_int("*sequencer", "count", 0);
      s_seq = fpu_sequence_simple_sanity::type_id::create("s_seq");
      super.build_phase(phase);
endfunction // new

virtual task run_phase(uvm_phase phase);
      int timeout = `TIMEOUT;
		phase.raise_objection(this,"run_phase raise objection in test_simple_sanity");
      
      fork : thread_fpu_simple_sanity
      	s_seq.start(seqr_handle, null);
      	#timeout;
      join_any

      uvm_report_info(get_type_name(), "Stopping test...", UVM_LOW );      
		phase.drop_objection(this,"run_phase drop objection in test_simple_sanity");
endtask

endclass
