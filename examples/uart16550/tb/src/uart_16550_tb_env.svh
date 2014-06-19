//----------------------------------------------------------------------
//                   Mentor Graphics Inc
//----------------------------------------------------------------------
// Project         : i2c_master2
// Unit            : uart_16550_tb_env
// File            : uart_16550_tb_env.svh
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

`ifndef __UART_16550_TB_ENV
`define __UART_16550_TB_ENV

`include "uvm_macros.svh"

class uart_16550_tb_env #(int AWIDTH, DWIDTH) extends uvm_env;
   `uvm_component_param_utils(uart_16550_tb_env#(AWIDTH, DWIDTH))    
   
   wb_agent#(AWIDTH, DWIDTH) m_wb_agent; 
   mvc_agent	m_uart_agent; 
   sli_clk_reset_agent m_clk_agent;
   simple_irq_agent m_irq_agent;
   

   // constructor
   function new(string name = "env", uvm_component parent = null );
      super.new(name, parent);
   endfunction : new

   // build_phase
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_uart_agent= mvc_agent::type_id::create("m_uart_agent", this);
      m_wb_agent= wb_agent#(AWIDTH, DWIDTH)::type_id::create("m_wb_agent", this);
      m_clk_agent=sli_clk_reset_agent::type_id::create("m_clk_agent",this);
      m_irq_agent=simple_irq_agent::type_id::create("m_irq_agent",this);
   endfunction : build_phase


   // connect_phase
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction : connect_phase


endclass : uart_16550_tb_env

`endif