class qvip_uart_base_seq extends mvc_sequence;
   
   typedef uart_device_end_data_char                         tx_data_char_t;
   typedef mvc_facing_end_item # (uart_device_end_data_char) rx_data_char_t;
   
   `uvm_object_utils(qvip_uart_base_seq )
   uart_vip_config m_vip_config;

   function new( string name = "" );
      super.new( name );
   endfunction

   task body();
      m_vip_config = uart_vip_config::get_config( m_sequencer );
   endtask // body
endclass // qvip_uart_base_seq

   
