class ra_example_smoke_test extends ra_example_base_test;

  // factory registration macro
  `uvm_component_utils(ra_example_smoke_test)
   typedef apb3_basic_rw_sequence #( 1,3,8,8) test_sequence_t;

   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------    
   function new(string name = "ra_example_tb", 
		uvm_component parent = null);
      super.new(name, parent);      
   endfunction: new


      task run_phase(uvm_phase phase);
	 test_sequence_t m_sequence = test_sequence_t::type_id::create("m_sequence");

	 phase.raise_objection(this);
	 m_sequence.count = 10;
	 
	 m_sequence.start(m_apb3_sequencer);
	
	 phase.drop_objection(this);
      endtask // run_phase
endclass // ra_example_smoke_test
