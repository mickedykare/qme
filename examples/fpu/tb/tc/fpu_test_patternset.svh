import fpu_agent_pkg::*;

class fpu_test_patternset extends fpu_test_base;
	`uvm_component_utils(fpu_test_patternset)

	fpu_sequence_patternset s_seq;

	function new(string name = "fpu_test_patternset", uvm_component parent=null);
		super.new(name, parent);
	endfunction // 
	
	function void build_phase(uvm_phase phase);	
		string patternset_filename;
                int patternset_maxcount;
                if($test$plusargs ("PATTERNSET_FILENAME")) begin
                        void'($value$plusargs ("PATTERNSET_FILENAME=%s", patternset_filename));
                        uvm_config_db#(string)::set(null,"", "patternset_filename", patternset_filename);
                end
                if($test$plusargs ("PATTERNSET_MAXCOUNT")) begin
                        void'($value$plusargs ("PATTERNSET_MAXCOUNT=%d", patternset_maxcount));
                        uvm_config_db#(int)::set(null,"", "patternset_maxcount", patternset_maxcount);
                end

		//set_config_int("*sequencer", "count", 0);
		s_seq = fpu_sequence_patternset::type_id::create("s_seq");
		super.build_phase(phase);
	endfunction // new

	virtual task run_phase(uvm_phase phase);
		int timeout = `TIMEOUT;
		phase.raise_objection(this,"run_phase raise objection in fpu_test_patternset");
		
		fork : thread_fpu_simple_sanity
			s_seq.start(seqr_handle, null);
			#timeout;
		join_any
		uvm_report_info(get_type_name(), "Stopping test...", UVM_LOW );
		phase.drop_objection(this,"run_phase raise objection in fpu_test_patternset");
	endtask
endclass
