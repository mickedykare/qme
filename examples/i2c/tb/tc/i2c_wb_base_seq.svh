class i2c_wb_base_seq extends uvm_sequence #(wb_item);
 `uvm_object_utils(i2c_wb_base_seq)

   default_top_block m_registermodel;

   function new(string name="i2c_wb_base_seq");
      super.new(name);
      // Insert Constructor Code Here
   endfunction : new


   task body;
      // Start by picking up the register model and print the contents of the registers
      if(!uvm_config_db #(default_top_block)::get( null , "", "REGISTERMAP" , m_registermodel )) begin
         `uvm_error(get_type_name(),"get cannot find resource REGISTERMAP" )
      end
      m_registermodel.default_top_block_map.print();
   endtask // if
endclass // i2c_wb_base_seq
