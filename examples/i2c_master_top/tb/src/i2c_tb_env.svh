//----------------------------------------------------------------------
//                   Mentor Graphics Inc
//----------------------------------------------------------------------
// Project         : i2c_master2
// Unit            : i2c_tb_env
// File            : i2c_tb_env.svh
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

`ifndef __I2C_TB_ENV
`define __I2C_TB_ENV

`include "uvm_macros.svh"

class i2c_tb_env #(int AWIDTH, DWIDTH) extends uvm_env;
   `uvm_component_param_utils(i2c_tb_env#(AWIDTH, DWIDTH))    
   
   wb_agent#(AWIDTH, DWIDTH) m_wb_agent; 
   mvc_agent	m_i2c_slave_agent; 
   simple_irq_agent m_irq_agent;
   sli_clk_reset_agent m_clk_agent;
   

   reg2wb_adapter m_reg2wb;
   uvm_reg_predictor #(wb_item) m_reg_predictor;
   default_top_block m_registermodel;                        // register model

   // constructor
   function new(string name = "env", uvm_component parent = null );
      super.new(name, parent);
   endfunction : new

   // build_phase
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_i2c_slave_agent= mvc_agent::type_id::create("m_i2c_slave_agent", this);
      m_wb_agent= wb_agent#(AWIDTH, DWIDTH)::type_id::create("m_wb_agent", this);
      m_irq_agent=simple_irq_agent::type_id::create("m_irq_agent",this);
      m_clk_agent=sli_clk_reset_agent::type_id::create("m_clk_agent",this);
      // Adding UVM register package
      m_reg2wb = reg2wb_adapter::type_id::create("m_reg2wb");   // adapter for register bus
      m_reg_predictor = uvm_reg_predictor #(wb_item)::type_id::create("m_reg_predictor", this);  // 
   endfunction : build_phase


   // connect_phase
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // Insert Connect Code Here
      //    m_wb_agent.ap.connect(); 
      //    m_i2c_slave_agent.ap.connect(); 
      if(!uvm_config_db #(default_top_block)::get( this , "", "REGISTERMAP" , m_registermodel )) begin
         `uvm_error(get_type_name(),"get cannot find resource REGISTERMAP" )
      end

      // Note CHECK for REUSE! How do I know that this is not a top level env?
      m_wb_agent.ap.connect(m_reg_predictor.bus_in);
      m_reg_predictor.map=m_registermodel.default_top_block_map;
      m_reg_predictor.adapter = m_reg2wb;
      m_registermodel.default_top_block_map.set_auto_predict(0);
   endfunction : connect_phase


endclass : i2c_tb_env

`endif