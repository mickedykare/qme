// This test mimics the original test provided with opencores.org
class uart_orig_test extends uart_base_test;
`uvm_component_utils(uart_orig_test)  
   uart_config_seq m_setup_seq;
   uart_tx_seq m_tx_seq;
   qvip_uart_slave_seq m_qvip_uart_slave_seq;
   
   
   // constructor
   function new(string name, uvm_component parent );
      super.new(name, parent);
      // Insert Constructor Code Here
   endfunction : new
   
   task run_phase(uvm_phase phase);
      bit  [31:0] respons;
      uvm_status_e      status;
      m_qvip_uart_slave_seq = qvip_uart_slave_seq::type_id::create("m_qvip_uart_slave_seq");
      m_setup_seq=uart_config_seq::type_id::create("m_setup_seq");      
      m_tx_seq=uart_tx_seq::type_id::create("m_tx_seq");      
      phase.raise_objection(this);
      m_setup_seq.start(m_wb_sequencer);
      m_uart_vip_config.m_bfm.set_cfg_word_len (m_setup_seq.m_word_length );

      fork
	 m_qvip_uart_slave_seq.start(m_uart_sequencer);
      join_none
      
      m_tx_seq.start(m_wb_sequencer);
      
      phase.drop_objection(this);
      endtask


endclass // uart_orig_test
