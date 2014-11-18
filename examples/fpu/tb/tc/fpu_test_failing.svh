class fpu_test_failing extends fpu_test_base;
   `uvm_component_utils(fpu_test_failing)
     rand int no_of_cycles;
   
   function new(string name = "fpu_test_simple_failing", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new
   


   function void build_phase(uvm_phase phase);     
      super.build_phase(phase);
   endfunction // new

   virtual task run_phase(uvm_phase phase);
      int timeout = `TIMEOUT;
      phase.raise_objection(this,);
      `uvm_info(get_type_name(),"This is a fake test to illustrate failing tests",UVM_LOW);
      assert(this.randomize() with {no_of_cycles > 0;
				    no_of_cycles <1000;});
      repeat(no_of_cycles) begin
	 #100ns;
      end
      if (no_of_cycles > 700)
	`uvm_error(get_type_name(),"Got my fake error");
      phase.drop_objection(this,);
   endtask // run_phase
   
   

endclass:fpu_test_failing
