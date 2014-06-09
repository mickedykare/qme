class ra_example_base_test extends uvm_test;

  // factory registration macro
  `uvm_component_utils(ra_example_base_test)

   typedef apb3_vip_config #( 1,3,8,8 ) apb3_config_t;
   typedef virtual mgc_apb3 #( 1,3,8,8 ) apb3_if_t;

   // env 
   ra_example_tb_env #(example_block_registers,3,8) m_env;

   // configurations
   apb3_config_t m_apb3_master_config;
   sli_clk_reset_config m_clk_config;
   
   // register model
   example_block_registers m_registermodel;
   
  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------    
  function new(string name = "ra_example_tb", 
               uvm_component parent = null);
    super.new(name, parent);      
  endfunction: new

  //--------------------------------------------------------------------
  // build_phase
  //-------------------------------------------------------------------- 
   virtual function void build_phase(uvm_phase phase);    
      // Configure apb3 master vip
      m_apb3_master_config = apb3_config_t::type_id::create("m_apb3_master_config");
      m_clk_config = sli_clk_reset_config::type_id::create("m_clk_config");
      
      // APB3
      if(!uvm_config_db #(apb3_if_t )::get( this , "", "APB3_IF" , m_apb3_master_config.m_bfm )) begin
         `uvm_error("Config Error" , "uvm_config_db #( bfm_type )::get cannot find resource APB3_IF" )
      end

      m_apb3_master_config.max_slave_wait_count      = 20;
      m_apb3_master_config.default_mem_data          = 5;
      m_apb3_master_config.slave_err_not_supported   = 0;
      m_apb3_master_config.m_coverage_per_instance   = 1;
      m_apb3_master_config.m_bfm.set_config_response_max_timeout(600);
      m_apb3_master_config.m_bfm.apb3_set_host_abstraction_level(0, 1);  //Master TLM
      m_apb3_master_config.m_bfm.apb3_set_slave_abstraction_level(1, 0); // SLave RTL
      m_apb3_master_config.m_bfm.apb3_set_clk_contr_abstraction_level(1, 0); 
      m_apb3_master_config.m_bfm.apb3_set_rst_contr_abstraction_level(1, 0);
      uvm_config_db #( uvm_object )::set( this , "m_env.m_apb3_master_agent*" , mvc_config_base_id , m_apb3_master_config );

      // Clock agent
       if(!uvm_config_db #(virtual sli_clk_reset_if)::get( this , "", "SLI_CLK_RESET_IF" , m_clk_config.vif )) begin
         `uvm_error("Config Error" , "uvm_config_db #( bfm_type )::get cannot find resource APB3_IF" )
      end
      uvm_config_db #(sli_clk_reset_config)::set( this , "m_env.m_clk_reset_agent*" , "sli_clk_reset_config", m_clk_config );

      
      m_registermodel = example_block_registers::type_id::create("m_registermodel");          // create the register model
      m_registermodel.build();
      uvm_config_db #( example_block_registers)::set( null , "*" , "REGISTERMAP", m_registermodel );
      
      m_env=ra_example_tb_env#(example_block_registers,3,8)::type_id::create("m_env",this);
  endfunction: build_phase

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      m_registermodel.print();
      
      phase.drop_objection(this);
      
      
   endtask // run_phase
   
   

   
endclass: ra_example_base_test

