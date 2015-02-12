class axi4lite_to_apb4_apb2_base_sequence #( int SLAVE_COUNT   = 1 ,
                                int ADDRESS_WIDTH = 32,
                                int WDATA_WIDTH = 32,
                                int RDATA_WIDTH = 32 ) extends mvc_sequence;

   typedef apb3_host_write    #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH) write_item_t;
   typedef apb3_host_read     #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH) read_item_t;
   typedef axi4lite_to_apb4_apb2_base_sequence #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH) this_t;
   typedef apb3_vip_config    #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH) config_t;
   
   axi4lite_to_apb4_registers m_registermodel;

   typedef bit [ADDRESS_WIDTH-1:0]  addr_t;
   `uvm_object_param_utils( this_t )

    mvc_config_base  apb3_config;

   // Handle to apb3_vip_config.
   apb4_config_t c;
   
  //
  function new(string name = "");
    super.new(name);
  endfunction // new

 task body();
     apb3_config = mvc_config_base::get_config(m_sequencer);
     if(!uvm_config_db #(example_block_registers)::get( uvm_top , "", "REGISTERMAP" , m_registermodel )) begin
        `uvm_error(get_type_name() , "uvm_config_db #( example_block_registers )::get cannot find resource REGISTERMAP" )
     end
     
     if ( ! $cast(c, apb3_config) ) `uvm_error("ASSERT_FAILURE","Assert statement failure");
     // Wait for reset and then the first clock edge
     apb3_config.wait_for_reset();
     apb3_config.wait_for_clock();
  endtask


endclass // axi4lite_to_apb4_apb2_base_sequence




