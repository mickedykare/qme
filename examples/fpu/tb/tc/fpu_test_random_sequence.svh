import fpu_agent_pkg::*;

class fpu_test_random_sequence extends fpu_test_base;
`uvm_component_utils(fpu_test_random_sequence)
 
	fpu_sequence_random  s_seq; // Sequence to execute

	function new(string name = "fpu_test_random_sequence", uvm_component parent=null);
      super.new(name, parent);
	endfunction // new


	function void build_phase(uvm_phase phase);
      s_seq = fpu_sequence_random::type_id::create("s_seq");
      super.build_phase(phase);
	endfunction // new

	virtual task run_phase(uvm_phase phase);
      int timeout = `TIMEOUT;
      phase.raise_objection(this,"run_phase raise objection in fpu_test_random_sequence");
      fork : thread_fpu_sequence_rand
      	s_seq.start(seqr_handle, null);
      	#timeout;
      join_any
     
      uvm_report_info(get_type_name(), "Stopping test...", UVM_LOW );      
      phase.drop_objection(this,"run_phase drop objection in fpu_test_random_sequence");
	endtask

endclass
