class uart_config_seq extends uart_wb_base_seq;
  `uvm_object_param_utils(uart_config_seq)

   rand uart_data_word_length_e m_word_length;
   
   function new(string name = "");
      super.new(name);
   endfunction


 task body();
     bit status;
    super.body();
    this.randomize();

    `uvm_info(get_type_name(),"Enabling access to LCR DIVIDER",UVM_MEDIUM);
    m_registermodel.LCR.SET_DIV_LATCH_ACCESS.set(1);
    m_registermodel.LCR.update(status, .path(UVM_FRONTDOOR), .parent(this));
    `uvm_info(get_type_name(),"Set DL to divide by 3 - FIX THIS. Not nice",UVM_MEDIUM); 
    m_registermodel.RXTXBUF.write(status,2,.parent(this));
    `uvm_info(get_type_name(),"Disabling access to LCR DIVIDER",UVM_MEDIUM);
    `uvm_info(get_type_name(),$psprintf("Setting word size to %0s",m_word_length),UVM_MEDIUM);
    m_registermodel.LCR.SET_DIV_LATCH_ACCESS.set(0);
    case(m_word_length)
      uart_5_bit_word:m_registermodel.LCR.SET_NO_OF_BITS.set(0); // 00 = 5 bits
      uart_6_bit_word:m_registermodel.LCR.SET_NO_OF_BITS.set(1); // 01 = 6 bits
      uart_7_bit_word:m_registermodel.LCR.SET_NO_OF_BITS.set(2); // 10 = 7 bits
      uart_8_bit_word:m_registermodel.LCR.SET_NO_OF_BITS.set(3); // 11 = 8 bits
    endcase
    m_registermodel.LCR.update(status, .path(UVM_FRONTDOOR), .parent(this));
    // Let's enable some interrupts
    m_registermodel.IER.TXEMTPTY_ENA.set(1);
    m_registermodel.IER.RXDAT_ENA.set(1);
    m_registermodel.IER.update(status, .path(UVM_FRONTDOOR), .parent(this));



    `uvm_info(get_type_name(),"Configuration of registers done!",UVM_MEDIUM);


 endtask // body
   


endclass // uart_config_seq
