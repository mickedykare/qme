class ra_example_apb3_base_sequence #( int SLAVE_COUNT   = 1 ,
				int ADDRESS_WIDTH = 32,
				int WDATA_WIDTH = 32,
				int RDATA_WIDTH = 32 ) extends mvc_sequence;

  typedef apb3_host_write    #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH) write_item_t;
  typedef apb3_host_read     #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH) read_item_t;
  typedef ra_example_apb3_base_sequence #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH) this_t;
  typedef apb3_vip_config    #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH) config_t;
   
   example_block_registers m_registermodel;

  typedef bit[ADDRESS_WIDTH-1:0] addr_t;
  `uvm_object_param_utils( this_t )
  mvc_config_base  apb3_config;

  // Handle to apb3_vip_config.
  config_t c;

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


   
endclass // ra_example_apb3_base_sequence









class apb3_basic_rw_sequence #( int SLAVE_COUNT   = 1 ,
				int ADDRESS_WIDTH = 32,
				int WDATA_WIDTH = 32,
				int RDATA_WIDTH = 32 ) extends ra_example_apb3_base_sequence #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH);
   

  typedef apb3_basic_rw_sequence #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH) this_t;
  `uvm_object_param_utils( this_t )

   int 				    count = 5;
   

  function new(string name = "");
    super.new(name);
  endfunction

  task body();

     write_item_t write_item = write_item_t::type_id::create("write_seq");
     read_item_t  read_item = read_item_t::type_id::create("read_seq");
     super.body();
    // Execute write followed by read to the same address and slave ID
     for(int i = 0;i < count;i++)
     begin
	start_item( write_item );
	assert ( write_item.randomize() with {strb > 0;}) else
	  `uvm_error(get_type_name(),"Assert statement failure"); 	
	
	finish_item( write_item );
	start_item(read_item);
	assert ( read_item.randomize() with {addr == write_item.addr;}) else
	  `uvm_error(get_type_name(),"Assert statement failure"); 	
	finish_item(read_item);
	
     end
     
  endtask

endclass


// Let's create our own register sequence as example
//

class ra_example_setup_seq #( int SLAVE_COUNT   = 1 ,
				int ADDRESS_WIDTH = 32,
				int WDATA_WIDTH = 32,
				int RDATA_WIDTH = 32 ) extends ra_example_apb3_base_sequence #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH);
   

   typedef ra_example_setup_seq #(SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH) this_t;
  `uvm_object_param_utils( this_t )


  function new(string name = "");
    super.new(name);
  endfunction

  task body();
     bit status;
     
     super.body();
     `uvm_info(get_type_name(),"Setting up DUT in XYZ mode",UVM_MEDIUM);
      assert (m_registermodel.SYSPOR_DBB_RST_N_MASK3.randomize()) else 
	`uvm_error(get_type_name(), "Control register randomization failed")
     m_registermodel.SYSPOR_DBB_RST_N_MASK3.update(status, .path(UVM_FRONTDOOR), .parent(this));

     
/* -----\/----- EXCLUDED -----\/-----
  // Set up interrupt enable
  spi_rm.ctrl_reg.ie.set(int_enable);
  // Don't set the go_bsy bit
  spi_rm.ctrl_reg.go_bsy.set(0);
  // Write the new value to the control register
  spi_rm.ctrl_reg.update(status, .path(UVM_FRONTDOOR), .parent(this));
  // Get a copy of the register value for the SPI agent
  data = spi_rm.ctrl_reg.get();
 -----/\----- EXCLUDED -----/\----- */


     
  endtask

endclass
