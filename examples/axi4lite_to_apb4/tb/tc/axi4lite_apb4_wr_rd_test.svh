class axi4lite_apb4_wr_rd_test extends axi4lite_to_apb4_basetest;
   `uvm_component_utils(axi4lite_apb4_wr_rd_test)
  
   function new(string name="axi4lite_to_apb4_env",uvm_component parent=null);
      super.new(name,parent);
   endfunction // new


   
   

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      // Start slave sequence on slave
      super.start_slave_sequence();     
      // Step 1 do the same tests 



      phase.drop_objection(this);



      
   endtask // run_phase
   
   


endclass // axi4lite_apb4_wr_rd_test
