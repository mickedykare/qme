// *************************************************************************************
// Copyright 2014 Mentor Graphics Corporation
// All Rights Reserved
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS
//
// bugs, enhancement requests to: avidan_efody@mentor.com
// *************************************************************************************

class sli_clk_reset_driver extends uvm_driver #(sli_clk_rst_item, sli_clk_rst_item);

  // factory registration macro
  `uvm_component_utils(sli_clk_reset_driver)  

  // internal components 
  sli_clk_rst_item    req_txn;
  sli_clk_rst_item    rsp_txn;

  // interface  

  sli_clk_reset_config m_cfg;

  virtual sli_clk_reset_if  vif;

  // local variables
  int tests = 0;

  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------    
  function new (string name = "sli_clk_reset_driver",
                uvm_component parent = null);
    super.new(name,parent);
  endfunction: new


   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(!uvm_config_db #(sli_clk_reset_config)::get(this, "", "sli_clk_reset_config", m_cfg)) begin
	 `uvm_error("build_phase", "sli_clk_reset_config not found")
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
       if (m_cfg.m_clk_enable) vif.clk = ~vif.clk;
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

  
endclass: sli_clk_reset_driver



