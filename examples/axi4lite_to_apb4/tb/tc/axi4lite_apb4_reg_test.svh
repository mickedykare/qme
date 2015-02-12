class axi4lite_apb4_reg_test extends axi4lite_to_apb4_basetest;
   `uvm_component_utils(axi4lite_apb4_reg_test)
     rand integer data;
   
   function new(string name="axi4lite_to_apb4_env",uvm_component parent=null);
      super.new(name,parent);
   endfunction // new
   
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_resource_db #(bit)::set({"REG::", m_registermodel.axi4lite_to_apb4_sample.get_full_name()}, "NO_REG_HW_RESET_TEST", 1);
   endfunction // build_phase
   
   uvm_reg my_regs[$];   
 
 
  // Read back reset values in random order

  task run_phase(uvm_phase phase);
     bit status;
     int ref_data;
     
     uvm_reg_hw_reset_seq m_sequence = uvm_reg_hw_reset_seq::type_id::create("m_sequence");
     m_sequence.model = m_registermodel;
     phase.raise_objection(this);
     // Start slave sequence on slave
     super.start_slave_sequence();     
     
     `uvm_info(get_type_name(),"Checking reset values",UVM_MEDIUM);
     m_sequence.start(null);

     m_registermodel.get_registers(my_regs);
     repeat(10) begin
     my_regs.shuffle();
     foreach(my_regs[i]) begin
	assert(this.randomize());
	my_regs[i].write(status, data, .parent(null));
    end
     my_regs.shuffle();
     foreach(my_regs[i]) begin
	ref_data = my_regs[i].get();
	my_regs[i].read(status, data, .parent(null));
	if(ref_data != data) begin
           `uvm_error(get_type_name(), $sformatf("get/read: Read error for %s: Expected: %0h Actual: %0h", my_regs[i].get_name(), ref_data, data));
	end
     end
     end // repeat (10)
     

     
     
     phase.drop_objection(this);
  endtask // run_phase




endclass // axi4lite_apb4_reg_test
