class axi4lite_to_apb4_basetest extends uvm_test;
   `uvm_component_utils(axi4lite_to_apb4_basetest);

   // Pointers to the sequencers
   mvc_sequencer m_apb4_master_sequencer;
   mvc_sequencer m_apb4_slave_sequencer;
   mvc_sequencer m_axi4_master_sequencer;

   //env 
   axi4lite_to_apb4_env m_env;

   // Configuration objects, one per interface   
   apb4_config_t m_apb4_master_cfg;
   apb4_config_t m_apb4_slave_cfg;
   axi4_config_t m_axi4lite_cfg;
   sli_clk_reset_config m_axi4_clk_config;
   sli_clk_reset_config m_apb4_master_clk_config;
   sli_clk_reset_config m_apb4_slave_clk_config;

   // register model
   axi4lite_to_apb4_registers m_registermodel;
   
   // Adding a reporter for UVM reporting (for QVIP)
   
   qvip_err_assertion_reporter m_qvip_reporter;
   



   // Components used by the register model
   // adapter for register bus
   reg2apb_adapter_t m_reg2apb;           
   // Predictor           
   apb3_reg_predictor_t m_reg_predictor;  
   
   // Slave sequence
   apb4_slave_seq_t m_apb4_slave_seq;
   
   function new(string name="axi4lite_to_apb4_env",uvm_component parent=null);
      super.new(name,parent);
   endfunction // new
   
   function void build_phase(uvm_phase phase);
      // Create and configure each agent
      m_apb4_slave_cfg=apb4_config_t::type_id::create("m_apb4_slave_cfg");
      m_apb4_master_cfg=apb4_config_t::type_id::create("m_apb4_master_cfg");
      m_axi4lite_cfg=axi4_config_t::type_id::create("m_axi4lite_cfg");
      m_axi4_clk_config=sli_clk_reset_config::type_id::create("m_axi4_clk_config");
      m_apb4_master_clk_config=sli_clk_reset_config::type_id::create("m_apb4_master_clk_config");
      m_apb4_slave_clk_config=sli_clk_reset_config::type_id::create("m_apb4_slave_clk_config");
      m_qvip_reporter=new("m_qvip_reporter");
 
      // Get the pin interfaces
      if(!uvm_config_db #( axi4_if_t)::get( this , "", "AXI4_M_IF" ,m_axi4lite_cfg.m_bfm ))
	`uvm_error("Config Error" , "uvm_config_db #( axi_if_t )::get can not find resource AXI4_M_IF" );
      
      if(!uvm_config_db #( apb3_if_t)::get( this , "", "APB4_M_IF" ,m_apb4_master_cfg.m_bfm ))
	`uvm_error("Config Error" , "uvm_config_db #( apb3_if_t )::get can not find resource APB4_M_IF" );
      
      if(!uvm_config_db #( apb3_if_t)::get( this , "", "APB4_S_IF" ,m_apb4_slave_cfg.m_bfm ))
	`uvm_error("Config Error" , "uvm_config_db #( apb3_if_t )::get can not find resource APB4_S_IF" );

      if(!uvm_config_db #(virtual sli_clk_reset_if)::get( this , "", "SLI_CLK_RESET_AXI4_IF" , m_axi4_clk_config.vif )) begin
         `uvm_error("Config Error" , "uvm_config_db #( bfm_type )::get cannot find resource SLI_CLK_RESET_AXI4_IF" )
      end

      if(!uvm_config_db #(virtual sli_clk_reset_if)::get( this , "", "SLI_CLK_RESET_APB4_M_IF" , m_apb4_master_clk_config.vif )) begin
         `uvm_error("Config Error" , "uvm_config_db #( bfm_type )::get cannot find resource SLI_CLK_RESET_APB4_M_IF" )
      end

      if(!uvm_config_db #(virtual sli_clk_reset_if)::get( this , "", "SLI_CLK_RESET_APB4_S_IF" , m_apb4_slave_clk_config.vif )) begin
         `uvm_error("Config Error" , "uvm_config_db #( bfm_type )::get cannot find resource SLI_CLK_RESET_APB4_S_IF" )
      end
      


      
      // Configure AXI4
      m_axi4lite_cfg.m_bfm.register_interface_reporter(m_qvip_reporter);
      
      m_axi4lite_cfg.m_bfm.set_config_axi4lite_interface(1);
      m_axi4lite_cfg.m_bfm.axi4_set_master_abstraction_level(0,1);
      m_axi4lite_cfg.m_bfm.axi4_set_slave_abstraction_level(1,0);

     // Configure APB4 master
      m_apb4_master_cfg.m_bfm.register_interface_reporter(m_qvip_reporter);
      m_apb4_master_cfg.m_bfm.apb3_set_host_abstraction_level(0, 1);//Master TLM

      m_apb4_master_cfg.m_bfm.apb3_set_slave_abstraction_level(1, 0);// Slave is rtl


      m_apb4_master_cfg.m_bfm.apb3_set_clk_contr_abstraction_level(1, 0);
      m_apb4_master_cfg.m_bfm.apb3_set_rst_contr_abstraction_level(1, 0);
      m_apb4_master_cfg.m_bfm.set_config_apb2_enable(1'b1);
      m_apb4_master_cfg.delete_analysis_component("trans_ap","checker");

     // Configure APB4 slave
      m_apb4_slave_cfg.m_bfm.register_interface_reporter(m_qvip_reporter);
      m_apb4_slave_cfg.m_bfm.apb3_set_host_abstraction_level(1, 0); // master is rtl
      m_apb4_slave_cfg.m_bfm.apb3_set_slave_abstraction_level(0, 1); // slave is tlm
      m_apb4_slave_cfg.m_bfm.apb3_set_clk_contr_abstraction_level(1, 0);
      m_apb4_slave_cfg.m_bfm.apb3_set_rst_contr_abstraction_level(1, 0);
      m_apb4_slave_cfg.m_bfm.set_config_apb4_enable(1'b1);

      // Configure clock generators
      m_axi4_clk_config.m_clk_period=2.5ns;
      m_apb4_master_clk_config.m_clk_period=5ns;
      m_apb4_slave_clk_config.m_clk_period=5ns;

      m_axi4_clk_config.m_reset_delay=10;
      m_apb4_master_clk_config.m_reset_delay=3;
      m_apb4_slave_clk_config.m_reset_delay=3;
      

      
      // Publish the configs
      uvm_config_db #(uvm_object)::set(this, "*m_env.m_axi4lite_master_agent*",mvc_config_base_id,m_axi4lite_cfg );
      uvm_config_db #(uvm_object)::set(this, "*m_env.m_apb4_master_agent*",mvc_config_base_id,m_apb4_master_cfg );
      uvm_config_db #(uvm_object)::set(this, "*m_env.m_apb4_slave_agent*",mvc_config_base_id,m_apb4_slave_cfg );
      uvm_config_db #(sli_clk_reset_config)::set( this , "m_env.m_clk_axi4_agent*" , "sli_clk_reset_config", m_axi4_clk_config);
      uvm_config_db #(sli_clk_reset_config)::set( this , "m_env.m_clk_apb4_master_agent*" , "sli_clk_reset_config", m_apb4_master_clk_config);
      uvm_config_db #(sli_clk_reset_config)::set( this , "m_env.m_clk_apb4_slave_agent*" , "sli_clk_reset_config", m_apb4_slave_clk_config);





      m_env = axi4lite_to_apb4_env::type_id::create("m_env",this);

      // Build register stuff
      m_registermodel = axi4lite_to_apb4_registers::type_id::create("m_registermodel");          // create the register model
      m_registermodel.build();
      uvm_config_db #(axi4lite_to_apb4_registers)::set( null , "*" , "REGISTERMAP", m_registermodel );

      m_reg2apb = reg2apb_adapter_t::type_id::create("m_reg2apb");
      m_reg_predictor = apb3_reg_predictor_t::type_id::create("m_reg_predictor",this);
//      uvm_reg::include_coverage(UVM_CVR_ALL);       
      uvm_reg::include_coverage("*", UVM_CVR_ADDR_MAP);

   endfunction // build_phase
   
   function void connect_phase(uvm_phase phase);
      $cast(m_apb4_master_sequencer,uvm_top.find("*m_env.m_apb4_master_agent.sequencer"));
      $cast(m_apb4_slave_sequencer,uvm_top.find("*m_env.m_apb4_slave_agent.sequencer"));
      $cast(m_axi4_master_sequencer,uvm_top.find("*m_env.m_axi4lite_master_agent.sequencer"));
      
      // Register stuff
      m_reg_predictor.map=m_registermodel.axi4lite_to_apb4_register_map;
      
      
      m_reg_predictor.adapter = m_reg2apb;
      m_registermodel.axi4lite_to_apb4_register_map.set_auto_predict(0);
      m_registermodel.axi4lite_to_apb4_register_map.set_sequencer(m_apb4_master_sequencer,m_reg2apb);
   endfunction
	

   function void start_slave_sequence();
      m_apb4_slave_seq=apb4_slave_seq_t::type_id::create("m_apb4_slave_seq");
      m_apb4_slave_seq.m_my_id = 0;
      fork
	 m_apb4_slave_seq.start(m_apb4_slave_sequencer);
      join_none
   endfunction // start_slave_sequnce


   
   task run_phase(uvm_phase phase);
      uvm_reg_hw_reset_seq m_sequence = uvm_reg_hw_reset_seq::type_id::create("m_sequence");
      m_sequence.model=m_registermodel;

      phase.raise_objection(this);
      m_registermodel.print();
      phase.drop_objection(this);
   endtask // run_phase





endclass
