class uart_tx_seq extends uart_wb_base_seq;
  `uvm_object_param_utils(uart_tx_seq)

   int count=10;
   
   function new(string name = "");
      super.new(name);
   endfunction

 task body();
     bit status;
    super.body();

    repeat(count) begin
       `uvm_info(get_type_name(),"Transmitting ...",UVM_MEDIUM);
       assert(m_registermodel.RXTXBUF.randomize());
       m_registermodel.RXTXBUF.update(status, .path(UVM_FRONTDOOR), .parent(this));       
       m_registermodel.RXTXBUF.print();
       
    end
    # 100us;
    


 endtask // body
   


endclass // uart_config_seq
