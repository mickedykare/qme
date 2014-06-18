//----------------------------------------------------------------------
//                   Mentor Graphics Inc
//----------------------------------------------------------------------
// Project         : i2c_master2
// Unit            : i2c_base_test
// File            : i2c_base_test.svh
//----------------------------------------------------------------------
// Created by      : mikaela.mikaela
// Creation Date   : 2014/04/01
//----------------------------------------------------------------------
// Title: 
//
// Summary:
//
// Description:
//
//----------------------------------------------------------------------

`ifndef __I2C_BASE_TEST
`define __I2C_BASE_TEST

`include "uvm_macros.svh"

class i2c_base_test extends uvm_test;

   `uvm_component_utils(i2c_base_test)  
   i2c_tb_env	#(WB_AWIDTH, WB_DWIDTH) m_env; 

   // Config classes
   i2c_vip_config	m_i2c_vip_config; 
   wb_agent_config	#(WB_AWIDTH, WB_DWIDTH) m_wb_agent_config; 
   simple_irq_agent_config m_irq_agent_config;
   sli_clk_reset_config m_clk_config;
   
   typedef i2c_slave_sequence i2c_slave_sequence_t;


   
   //Pointers to sequencers are always useful
   uvm_sequencer #(wb_item) m_wb_sequencer;
   mvc_sequencer m_i2c_sequencer;

   // And we need the register model of course
   default_top_block m_registermodel;                        // register model
   
   
   function void do_i2c_slave_config();
      m_i2c_vip_config.m_bfm.i2c_set_master_abstraction_level(1, 0);
      m_i2c_vip_config.m_bfm.i2c_set_slave_abstraction_level(0, 1);
      //m_i2c_vip_config.m_bfm.i2c_set_clock_source_abstraction_level(0, 1); //Internal
      m_i2c_vip_config.m_bfm.i2c_set_clock_source_abstraction_level(1, 0); //External

      m_i2c_vip_config.m_slave_addr        = SLAVE_ADDRESS1;

      m_i2c_vip_config.m_bfm.set_config_7b_addr(1'b1);
      m_i2c_vip_config.m_bfm.set_config_hs_master_code(3);

      m_i2c_vip_config.m_bfm.set_config_num_slave(NUMBER_OF_I2C_SLAVES);
      m_i2c_vip_config.m_bfm.set_config_slave_addr_index1(0, SLAVE_ADDRESS1);
      m_i2c_vip_config.m_bfm.set_config_slave_addr_index1(1, SLAVE_ADDRESS2);
      

      // set analysis component
      m_i2c_vip_config.set_monitor_item("trans_ap", i2c_master_i2c_data_transfer::type_id::get() );
      m_i2c_vip_config.set_analysis_component("" , "i2c_slave_coverage" ,   i2c_slave_coverage #(SLAVE_7_BIT)::type_id::get() );
      m_i2c_vip_config.set_analysis_component("trans_ap" , "i2c_scoreboard" , i2c_scoreboard::type_id::get() );
      m_i2c_vip_config.set_default_sequence(null);
   endfunction
   
   
   
   // constructor
   function new(string name, uvm_component parent );
      super.new(name, parent);
      // Insert Constructor Code Here
   endfunction : new

   // build_phase
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // Configure irq agent and publish the config to the agent
      m_irq_agent_config=simple_irq_agent_config::type_id::create("m_irq_agent_config");


      m_irq_agent_config.is_active=UVM_ACTIVE;
      if(!uvm_config_db #(virtual simple_irq_if )::get(this, "", "SIMPLE_IRQ_IF",m_irq_agent_config.vif )) begin
	 `uvm_error(get_type_name(), "SIMPLE_IRQ_IF not found)")
      end
      uvm_config_db #(simple_irq_agent_config)::set(this,"*m_env.m_irq_agent*","simple_irq_agent_config",m_irq_agent_config);

	
      // Configure wb agent and publish the config to the agent
      m_wb_agent_config= wb_agent_config  #(WB_AWIDTH, WB_DWIDTH)::type_id::create("m_wb_agent_config"); 
      m_wb_agent_config.is_active=UVM_ACTIVE;
      if(!uvm_config_db #(virtual wb_if #(WB_AWIDTH,WB_DWIDTH) )::get(this, "", "WB_IF",m_wb_agent_config.vif )) begin
	 `uvm_error(get_type_name(), "WB_IF not found)")
      end
      uvm_config_db #(wb_agent_config #(WB_AWIDTH,WB_DWIDTH))::set(this,"*m_env.m_wb_agent*","wb_agent_config",m_wb_agent_config);
      
      
      
      
      // Configure i2c agent and publish the config to the agent 
      m_i2c_vip_config= i2c_vip_config::type_id::create("m_i2c_vip_config");
      // Let's pick up interfaces and populate the bfm
      if ( !uvm_config_db#(virtual mgc_i2c)::get (this,"","I2C_INTERFACE",m_i2c_vip_config.m_bfm ) ) begin            
         `uvm_error( get_type_name(), "I2C_INTERFACE not found" )      
      end
      do_i2c_slave_config();   
      uvm_config_db #(uvm_object)::set(this,"*",mvc_config_base_id,m_i2c_vip_config);
      
      m_clk_config = sli_clk_reset_config::type_id::create("m_clk_config");


      assert(m_clk_config.randomize() with {m_reset_delay>3;
                                            m_reset_delay<10;} );
      m_clk_config.m_clk_period=1us;

      if(!uvm_config_db #(virtual sli_clk_reset_if)::get( this , "", "SLI_CLK_RESET_IF" , m_clk_config.vif )) begin
         `uvm_error("Config Error" , "uvm_config_db #( bfm_type )::get cannot find resource APB3_IF" )
      end

      uvm_config_db #(sli_clk_reset_config)::set( this , "m_env.m_clk_agent*" , "sli_clk_reset_config", m_clk_config );

      //Create and publish register model  
      
      m_registermodel = default_top_block::type_id::create("m_registermodel");          // create the register model
      m_registermodel.build();                                            // regs need a manual build()

      uvm_resource_db #(default_top_block)::set("*","REGISTERMAP",m_registermodel); // make available to sequences
      
      m_env= new("m_env", this); 
   endfunction : build_phase


   // connect_phase
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // Insert Connect Code Here
      $cast(m_wb_sequencer,uvm_top.find("*m_env.m_wb_agent.m_sequencer"));
      // Publish sequencer for everybody
      uvm_config_db #(uvm_sequencer #(wb_item))::set(this,"*","WB_SEQR",m_wb_sequencer);
      $cast(m_i2c_sequencer,uvm_top.find("*m_env.m_i2c_slave_agent.sequencer"));
      m_registermodel.default_top_block_map.set_sequencer(m_wb_sequencer, m_env.m_reg2wb);




   endfunction : connect_phase


   task run_phase(uvm_phase phase);
      bit  [31:0] respons;
      uvm_status_e      status;
      uvm_reg_hw_reset_seq seq = uvm_reg_hw_reset_seq::type_id::create("reg_hw_reset_seq");      
      seq.model =m_registermodel;
 
      phase.raise_objection(this);
      m_registermodel.default_top_block_map.print();
      #10us;
      seq.start(m_wb_sequencer);
      #5us;

      phase.drop_objection(this);
      

   endtask // run_phase
   

   

endclass : i2c_base_test

`endif