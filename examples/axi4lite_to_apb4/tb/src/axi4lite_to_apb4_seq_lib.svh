class axi4lite_base_seq #( int AXI4_ADDRESS_WIDTH   = 32, 
                           int AXI4_RDATA_WIDTH     = 32,
                           int AXI4_WDATA_WIDTH     = 32,
                           int AXI4_ID_WIDTH        = 4,
                           int AXI4_USER_WIDTH      = 4,
                           int AXI4_REGION_MAP_SIZE = 16
                           ) extends mvc_sequence;


   int 			       count=10;
   
   
   typedef axi4lite_base_seq #(AXI4_ADDRESS_WIDTH,AXI4_RDATA_WIDTH,AXI4_WDATA_WIDTH,AXI4_ID_WIDTH,AXI4_USER_WIDTH,AXI4_REGION_MAP_SIZE) this_t;
   `uvm_object_param_utils( this_t )
   typedef axi4_vip_config #(AXI4_ADDRESS_WIDTH,AXI4_RDATA_WIDTH,AXI4_WDATA_WIDTH,AXI4_ID_WIDTH,AXI4_USER_WIDTH,AXI4_REGION_MAP_SIZE) apb4_config_t;
   
   axi4lite_to_apb4_registers m_registermodel;
   mvc_config_base  axi4_config;
   // Handle to apb3_vip_config.
   axi4_config_t c;
   
  //
  function new(string name = "");
    super.new(name);
  endfunction // new

 task body();
     axi4_config = mvc_config_base::get_config(m_sequencer);
     if(!uvm_config_db #(axi4lite_to_apb4_registers)::get( uvm_top , "", "REGISTERMAP" , m_registermodel )) begin
        `uvm_error(get_type_name() , "uvm_config_db #( example_block_registers )::get cannot find resource REGISTERMAP" )
     end
     
     if ( ! $cast(c, axi4_config) ) `uvm_error("ASSERT_FAILURE","Assert statement failure");
     // Wait for reset and then the first clock edge
     axi4_config.wait_for_reset();
     axi4_config.wait_for_clock();
  endtask


endclass // axi4lite_to_apb4_apb2_base_sequence


class axi4lite_readwrite_seq #( int AXI4_ADDRESS_WIDTH   = 32, 
				int AXI4_RDATA_WIDTH     = 32,
				int AXI4_WDATA_WIDTH     = 32,
				int AXI4_ID_WIDTH        = 4,
				int AXI4_USER_WIDTH      = 4,
				int AXI4_REGION_MAP_SIZE = 16
				) extends axi4lite_base_seq #(AXI4_ADDRESS_WIDTH,AXI4_RDATA_WIDTH,AXI4_WDATA_WIDTH,AXI4_ID_WIDTH,AXI4_USER_WIDTH,AXI4_REGION_MAP_SIZE);
   
   typedef axi4lite_readwrite_seq #(AXI4_ADDRESS_WIDTH,AXI4_RDATA_WIDTH,AXI4_WDATA_WIDTH,AXI4_ID_WIDTH,AXI4_USER_WIDTH,AXI4_REGION_MAP_SIZE) this_t;

   `uvm_object_param_utils( this_t )

     typedef axi4_master_read  #(AXI4_ADDRESS_WIDTH,
				 AXI4_RDATA_WIDTH,
				 AXI4_WDATA_WIDTH,
				 AXI4_ID_WIDTH,
				 AXI4_USER_WIDTH,
				 AXI4_REGION_MAP_SIZE
				 ) read_item_t;

   typedef axi4_master_write #(AXI4_ADDRESS_WIDTH,
                               AXI4_RDATA_WIDTH,
                               AXI4_WDATA_WIDTH,
                               AXI4_ID_WIDTH,
                               AXI4_USER_WIDTH,
                               AXI4_REGION_MAP_SIZE
                               ) write_item_t;

   read_item_t  read_item;
   write_item_t write_item;
   
   
  function new(string name = "");
    super.new(name);
  endfunction // new

   task body;      
      super.body();
      read_item  = read_item_t::type_id::create("read_item");
      write_item = write_item_t::type_id::create("write_item");

      for(int i=0;i<count;++i) begin
	 start_item( write_item );
	 assert(write_item.randomize()) else
	   `uvm_error(this.get_full_name(),"Randomisation failure");
	 finish_item( write_item );

	 start_item( read_item );
	 assert (read_item.randomize() with {read_item.addr == write_item.addr;}) else
	   `uvm_error(this.get_full_name(),"Randomisation failure");
         finish_item( read_item );
       end
   endtask // body
   

   endclass // axi4lite_readwrite_seq
