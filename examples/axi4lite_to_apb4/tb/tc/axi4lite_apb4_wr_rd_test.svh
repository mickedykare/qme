class axi4lite_apb4_wr_rd_test extends axi4lite_to_apb4_basetest;
   `uvm_component_utils(axi4lite_apb4_wr_rd_test)
     
     function new(string name="axi4lite_to_apb4_env",uvm_component parent=null);
	super.new(name,parent);
     endfunction // new
   
   typedef axi4lite_readwrite_seq #(.AXI4_ADDRESS_WIDTH(AW), 
				    .AXI4_RDATA_WIDTH(DW), 
				    .AXI4_WDATA_WIDTH(DW), 
				    // Not used in lite
				    .AXI4_ID_WIDTH(AXI4_ID_WIDTH), 
				    .AXI4_USER_WIDTH(AXI4_USER_WIDTH), 
				    .AXI4_REGION_MAP_SIZE(AXI4_REGION_MAP_SIZE)) my_seq_t;
   my_seq_t m_sequence;
   
   
   task run_phase(uvm_phase phase);
   
      m_sequence = my_seq_t::type_id::create("m_seq");
      
      phase.raise_objection(this);
      // Start slave sequence on slave
      super.start_slave_sequence();     
      // Step 1 do the same tests 
      m_sequence.start(m_axi4_master_sequencer);
      phase.drop_objection(this);
      //


      
   endtask // run_phase
   
   


endclass // axi4lite_apb4_wr_rd_test
