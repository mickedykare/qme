//----------------------------------------------------------------------
//                   Mentor Graphics Inc
//----------------------------------------------------------------------
// Project         : i2c_master2
// Unit            : uart_base_test
// File            : uart_base_test.svh
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

`ifndef __UART_BASE_TEST
`define __UART_BASE_TEST

`include "uvm_macros.svh"

class uart_base_test extends uvm_test;

   `uvm_component_utils(uart_base_test)  
   uart_16550_tb_env	#(WB_AWIDTH, WB_DWIDTH) m_env; 

   // Config classes
   uart_vip_config	m_uart_vip_config; 
   wb_agent_config	#(WB_AWIDTH, WB_DWIDTH) m_wb_agent_config; 
   simple_irq_agent_config m_irq_agent_config;
   sli_clk_reset_config m_clk_config;
   
  typedef mvc_item_listener #( uart_device_end_data_char ) listener_t;

   //Pointers to sequencers are always useful
   uvm_sequencer #(wb_item) m_wb_sequencer;
   mvc_sequencer m_uart_sequencer;

   // And we need the register model of course
   uart16550_registers m_registermodel;                        // register model
   reg2wb_adapter m_reg2wb;
   uvm_reg_predictor #(wb_item) m_reg_predictor;

   
   
   
   
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
      
      // Lets configure the uart
      
      
      // Configure i2c agent and publish the config to the agent 
      m_uart_vip_config= uart_vip_config::type_id::create("m_uart_vip_config");
      // Let's pick up interfaces and populate the bfm
      if ( !uvm_config_db#(virtual mgc_uart)::get (this,"","UART_IF",m_uart_vip_config.m_bfm ) ) begin            
         `uvm_error( get_type_name(), "UART_IF not found" )      
      end

      m_uart_vip_config.set_structural_index( 1 );
      // end 0 is RTL
      m_uart_vip_config.m_bfm.uart_set_device_end_abstraction_level(0, 1, 0);
      // end 1 is TLM
      m_uart_vip_config.m_bfm.uart_set_device_end_abstraction_level(1, 0, 1);
      // Clock source is TLM
      m_uart_vip_config.m_bfm.uart_set_clock_source_abstraction_level(1, 0);
      
      // Set the configuration here.
      m_uart_vip_config.m_bfm.set_cfg_parity_selection ( uart_no_parity );
      m_uart_vip_config.m_bfm.set_cfg_word_len ( uart_8_bit_word );
      m_uart_vip_config.m_bfm.set_cfg_stop_bit_len ( uart_stop_bit_one );
      m_uart_vip_config.m_bfm.set_cfg_sw_flow_ctrl ( 1) ;
      m_uart_vip_config.m_bfm.set_cfg_hw_flow_ctrl ( 0 );
      
      m_uart_vip_config.m_coverage_per_instance = 1;
      m_uart_vip_config.set_analysis_component( "" , "uart_coverage" , uart_coverage::get_type() );
      m_uart_vip_config.set_analysis_component( "" , "uart_listener" , listener_t::get_type() );

      m_uart_vip_config.set_default_sequence(null);



      

      
      uvm_config_db #(uvm_object)::set(this,"*",mvc_config_base_id,m_uart_vip_config);
      
      m_clk_config = sli_clk_reset_config::type_id::create("m_clk_config");


      assert(m_clk_config.randomize() with {m_reset_delay>3;
                                            m_reset_delay<10;} );
      m_clk_config.m_clk_period=20ns;

      if(!uvm_config_db #(virtual sli_clk_reset_if)::get( this , "", "SLI_CLK_RESET_IF1" , m_clk_config.vif )) begin
         `uvm_error("Config Error" , "uvm_config_db #( bfm_type )::get cannot find resource SLI_CLK_RESET_IF1" )
      end

      uvm_config_db #(sli_clk_reset_config)::set( this , "m_env.m_clk_agent*" , "sli_clk_reset_config", m_clk_config );

      //Create and publish register model  

      m_reg2wb = reg2wb_adapter::type_id::create("m_reg2wb");   // adapter for register bus
      m_reg_predictor = uvm_reg_predictor #(wb_item)::type_id::create("m_reg_predictor", this);  //
      
      m_registermodel = uart16550_registers::type_id::create("m_registermodel");          // create the register model
      m_registermodel.build();                                            // regs need a manual build()
      uvm_resource_db#(bit)::set({"REG::",m_registermodel.LSR.get_full_name()},"NO_REG_TESTS",1,this);
      uvm_resource_db#(bit)::set({"REG::",m_registermodel.MSR.get_full_name()},"NO_REG_TESTS",1,this);
      uvm_config_db #(uart16550_registers)::set( null , "*" , "REGISTERMAP", m_registermodel );

      m_env = uart_16550_tb_env#(WB_AWIDTH,WB_DWIDTH)::type_id::create("m_env",this);
   endfunction : build_phase


   // connect_phase
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // Insert Connect Code Here
      $cast(m_wb_sequencer,uvm_top.find("*m_env.m_wb_agent.m_sequencer"));
      // Publish sequencer for everybody
      uvm_config_db #(uvm_sequencer #(wb_item))::set(this,"*","WB_SEQR",m_wb_sequencer);
      m_env.m_wb_agent.ap.connect(m_reg_predictor.bus_in);
      m_reg_predictor.map=m_registermodel.uart16550_registers_map;
      m_reg_predictor.adapter = m_reg2wb;
      m_registermodel.uart16550_registers_map.set_auto_predict(0);
      m_registermodel.uart16550_registers_map.set_sequencer(this.m_env.m_wb_agent.m_sequencer,m_reg2wb);
      $cast(m_uart_sequencer,uvm_top.find("*m_env.m_uart_agent.sequencer"));



   endfunction : connect_phase


   task run_phase(uvm_phase phase);
      bit  [31:0] respons;
      uvm_status_e      status;
      uvm_reg_hw_reset_seq seq = uvm_reg_hw_reset_seq::type_id::create("seq");      
      seq.model =m_registermodel;
 
      phase.raise_objection(this);
      m_registermodel.uart16550_registers_map.print();
      #1us;
      seq.start(null);
      #5us;

      phase.drop_objection(this);
      

   endtask // run_phase
   

   

endclass : uart_base_test

`endif