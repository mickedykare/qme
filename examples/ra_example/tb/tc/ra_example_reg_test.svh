class ra_example_reg_test extends ra_example_base_test;

  // factory registration macro
  `uvm_component_utils(ra_example_reg_test)

   typedef ra_example_setup_seq #(1,3,8,8) reg_test_seq_t;


   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------    
   function new(string name = "ra_example_tb", 
		uvm_component parent = null);
      super.new(name, parent);      
   endfunction: new


      task run_phase(uvm_phase phase);
	 
 	 uvm_reg_hw_reset_seq m_sequence = uvm_reg_hw_reset_seq::type_id::create("m_sequence");
	 reg_test_seq_t m_reg_test_seq=reg_test_seq_t::type_id::create("m_reg_test_seq");
	 
	 m_sequence.model = m_registermodel;
	 
	 phase.raise_objection(this);
	 m_sequence.start(null);
	 m_reg_test_seq.start(m_apb3_sequencer);
//	 m_seq_reg_access.start(null);
	 #100ns;
	 
	 
	 phase.drop_objection(this);
      endtask // run_phase
endclass // ra_example_smoke_test
