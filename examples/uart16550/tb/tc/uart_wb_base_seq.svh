class uart_wb_base_seq extends uvm_sequence #(wb_item);
 `uvm_object_utils(uart_wb_base_seq)

   uart16550_registers m_registermodel;
   uart_vip_config m_uart_vip_config;

   function new(string name="uart_wb_base_seq");
      super.new(name);
      // Insert Constructor Code Here
   endfunction : new


   task body;
      // Start by picking up the register model and print the contents of the registers
      if(!uvm_config_db #(uart16550_registers)::get( null , "", "REGISTERMAP" , m_registermodel )) begin
         `uvm_error(get_type_name(),"get cannot find resource REGISTERMAP" )
      end


      
//      m_registermodel.uart16550_registers_map.print();
   endtask // if
endclass // uart_wb_base_seq
