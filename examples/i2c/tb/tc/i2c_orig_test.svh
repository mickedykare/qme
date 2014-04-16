// This test mimics the original test provided with opencores.org
class i2c_orig_test extends i2c_base_test;
`uvm_component_utils(i2c_orig_test)  
   
   i2c_slave_sequence_t   i2c_slave_seq;
   i2c_wb_orig_seq m_wb_orig_seq;
   
   // constructor
   function new(string name, uvm_component parent );
      super.new(name, parent);
      // Insert Constructor Code Here
   endfunction : new
   
   task run_phase(uvm_phase phase);
      bit  [31:0] respons;
      uvm_status_e      status;
      m_wb_orig_seq=i2c_wb_orig_seq::type_id::create("m_wb_orig_seq");      
      i2c_slave_seq  = i2c_slave_sequence_t::type_id::create("i2c_slave_seq");

      phase.raise_objection(this);
      // We need to start the slave sequence in the background
      fork
	 i2c_slave_seq.start(m_i2c_sequencer);
      join_none
      #1us;
      m_wb_orig_seq.start(m_wb_sequencer);
      #5us;

      phase.drop_objection(this);
      endtask


endclass // i2c_orig_test
