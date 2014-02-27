//----------------------------------------------------------------------------
//                                                                          --
//     COPYRIGHT (C)                                ERICSSON  AB,  2012     --
//                                                                          --
//     Ericsson AB, Sweden.                                                 --
//                                                                          --
//     The document(s) may be used  and/or copied only with the written     --
//     permission from Ericsson AB  or in accordance with the terms and     --
//     conditions  stipulated in the agreement/contract under which the     --
//     document(s) have been supplied.                                      --
//                                                                          --
//----------------------------------------------------------------------------
// Unit            : er_simple_clk_reset_driver
//----------------------------------------------------------------------------
// Created by      : qmikand
// Creation Date   : 2012/06/19
//----------------------------------------------------------------------------
// Title: 
//
// Summary:
//
// Description:
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------
// er_simple_clk_reset_driver
//----------------------------------------------------------------------
class er_simple_clk_reset_driver extends uvm_driver #(er_clk_rst_item, er_clk_rst_item);

  // factory registration macro
  `uvm_component_utils(er_simple_clk_reset_driver)  

  // internal components 
  er_clk_rst_item    req_txn;
  er_clk_rst_item    rsp_txn;

  // interface  

  er_simple_clk_reset_config m_cfg;

  virtual er_simple_clk_reset_if  vif;

  // local variables
  int tests = 0;

  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------    
  function new (string name = "er_simple_clk_reset_driver",
                uvm_component parent = null);
    super.new(name,parent);
  endfunction: new


   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(!uvm_config_db #(er_simple_clk_reset_config)::get(this, "", "er_simple_clk_reset_config", m_cfg)) begin
	 `uvm_error("build_phase", "er_simple_clk_reset_config not found")
      end    

      vif = m_cfg.vif;
   endfunction // connect_phase
   

   
  //--------------------------------------------------------------------
  // run_phase
  //--------------------------------------------------------------------  
  
  virtual task drive_clk;
     vif.clk = m_cfg.m_clk_initial_value;
     forever begin
        #(m_cfg.m_clk_period/2);
        vif.clk = ~vif.clk;
     end
  endtask
        
  
  virtual task run_phase(uvm_phase phase);
  
    // We always start the same way
      fork
        drive_clk();
      join_none
    
      vif.nreset <= 0;
      repeat (m_cfg.m_reset_delay) @(posedge vif.clk);
      vif.nreset<=1;
      `uvm_info(get_type_name(),"Reset released",UVM_LOW);
      forever begin  
        seq_item_port.get_next_item(req_txn);
          case (req_txn.m_cmd)
            ACTIVATE_RESET:begin
                              repeat (req_txn.m_delay) @(posedge vif.clk);
                               `uvm_info(get_type_name(),"Activating reset....",UVM_LOW);
	                       #1ps;
	       
                               vif.nreset <= 0;
                            end
                             
            DEACTIVATE_RESET:begin
                              repeat (req_txn.m_delay) @(posedge vif.clk);
                               `uvm_info(get_type_name(),"Deactivating reset....",UVM_LOW);
	                       #1ps;

                               vif.nreset <= 1;
                            end
               
            default: begin
              `uvm_error(get_type_name(),"UNKNOWN COMMAND");
            
            end
	  endcase // case (req_txn.m_cmd)
	 seq_item_port.item_done();
	 
      
      end // forever begin
     
       
 
  endtask: run_phase

  
endclass: er_simple_clk_reset_driver



//----------------------------------------------------------------------
// er_simple_clk_reset_enable_driver
// use this driver to be able to turn the clock off
//----------------------------------------------------------------------
class er_simple_clk_reset_enable_driver extends er_simple_clk_reset_driver;

  // factory registration macro
  `uvm_component_utils(er_simple_clk_reset_enable_driver)  

  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------    
  function new (string name = "er_simple_clk_reset_enable_driver",
                uvm_component parent = null);
    super.new(name,parent);
  endfunction: new

  //--------------------------------------------------------------------
  // run_phase
  //--------------------------------------------------------------------  
  virtual task drive_clk;
     vif.clk = m_cfg.m_clk_initial_value;
     forever begin
       #(m_cfg.m_clk_period/2);
       if (m_cfg.m_clk_enable) vif.clk = ~vif.clk;
     end
  endtask
        
endclass // er_simple_clk_reset_enable_driver
