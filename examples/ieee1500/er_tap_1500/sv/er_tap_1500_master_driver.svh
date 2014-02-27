//----------------------------------------------------------------------
//                   Mentor Graphics Inc
//----------------------------------------------------------------------
// Project         : ieee1500
// Unit            : er_tap_1500_master_driver
// File            : er_tap_1500_master_driver.svh
//----------------------------------------------------------------------
// Created by      : mikaela.mikaela
// Creation Date   : 2014/01/29
//----------------------------------------------------------------------
// Title: 
//
// Summary:
//
// Description:
//
//----------------------------------------------------------------------

`ifndef __TAP_1500_MASTER_DRIVER
`define __TAP_1500_MASTER_DRIVER

`include "uvm_macros.svh"

class er_tap_1500_master_driver extends er_tap_1500_base_driver;

  `uvm_component_utils(er_tap_1500_master_driver)    
  event dbg;
  
  process main_p,reset_p; // used for controlling reset
  
  // constructor
  function new(string name = "er_tap_1500_base_driver", uvm_component parent = null);

    super.new(name, parent);
    // Insert Constructor Code Here

  endfunction : new

  // build_phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Insert Build Code Here
  endfunction : build_phase




// This is used to handle reset during an access

 task reset_handler();
     reset_p=process::self();
     @(negedge vif.WRSTN);
      `uvm_info(get_type_name(),"Detected reset - aborting any ongoing transfer",UVM_HIGH);
     main_p.kill();
 // Reset all signals to initial state
    vif.WSI  <= '0;
    vif.SelectWIR <='0;
    vif.CaptureWR <= '0;
    vif.ShiftWR <= '0;
    vif.UpdateWR <= '0;
     if (~response_sent) begin
        `uvm_info(get_type_name(),"Returning TRANSFER_ABORTED_DUE_TO_RESET",UVM_HIGH);
        m_req.m_status = TRANSFER_ABORTED_DUE_TO_RESET;
//        ap.write(m_req);
        seq_item_port.item_done(m_req);
        response_sent= 1;
	tests++;
	
     end
     else begin
        `uvm_info(get_type_name(),"Response was already sent",UVM_HIGH);
     end // else: !if(~response_sent)
     @(negedge vif.WRSTN);
     `uvm_info(get_type_name(),"Detected release of reset",UVM_HIGH);
     //wait one cycle after reset before moving on
     @(posedge vif.WRCK );
  endtask // reset_handler

  task do_bus_access();
      main_p=process::self();
      seq_item_port.get_next_item(m_req);  // get transaction
      // NOTE Copy transaction!!!
//      m_req.print();
      response_sent = 0;

      @(posedge vif.WRCK);
     void'(this.begin_tr(m_req,"driver_items"));      
      case(m_req.m_command)  //what type of transaction?
          LOAD_REGISTER:load_register(m_req);
          UPDATE:update_register(m_req);
          CAPTURE:capture_register(m_req);
        default: `uvm_error(get_type_name(),$sformatf("er_tap_1500_item(tr_id=%0d) the m_command was illegal",
                                                      m_req.get_transaction_id()) )
      endcase // case (m_req.txn_type)
     this.end_tr(m_req);
      seq_item_port.item_done(m_req);
      seq_item_port.put(m_req);
      response_sent=1;
      reset_p.kill();
      
   endtask // self

  task load_register(ref er_tap_1500_item tr);
    case (tr.m_select_register)
      IR:begin
         `uvm_info(get_type_name(),"Starting to load IR",UVM_HIGH);
         vif.SelectWIR <= '1;
         vif.ShiftWR <='1;
         vif.WSI <= tr.m_data_in[0];
         @(posedge vif.WRCK);
         for (int i=1;i<tr.m_length;i++) begin
            vif.WSI <= tr.m_data_in[i];
            @ (posedge vif.WRCK);
            tr.m_data_out[i-1] =vif.WSO;
         end
         vif.ShiftWR <='0; 
         @ (posedge vif.WRCK);
         tr.m_data_out[tr.m_length-1] =vif.WSO;
         `uvm_info(get_type_name(),"IR should now be loaded",UVM_HIGH);  
         tr.m_status <= OK;

      end
      DR: begin
         `uvm_info(get_type_name(),"Starting to load DR",UVM_HIGH);
         vif.SelectWIR <= '0;
         vif.ShiftWR <='1;
         vif.WSI <= tr.m_data_in[0];
         @(posedge vif.WRCK);
         for (int i=1;i<tr.m_length;i++) begin
            vif.WSI <= tr.m_data_in[i];
            @ (posedge vif.WRCK);
            tr.m_data_out[i-1] =vif.WSO;
         end
         vif.ShiftWR <='0; 
         @ (posedge vif.WRCK);
         tr.m_data_out[tr.m_length-1] =vif.WSO;
         `uvm_info(get_type_name(),"DR should now be loaded",UVM_HIGH);  
         tr.m_status <= OK;
      end


      default: `uvm_error(get_type_name(),$sformatf("er_tap_1500_item(tr_id=%0d) the m_select_reg was illegal",
                                                      m_req.get_transaction_id()) )
  endcase
  endtask
  
  task update_register(ref er_tap_1500_item tr);
     case (tr.m_select_register)
       IR:begin
          `uvm_info(get_type_name(),"Starting to update IR",UVM_HIGH);
          vif.SelectWIR <= '1;
          vif.UpdateWR <= '1;
          @ (posedge vif.WRCK);
          vif.UpdateWR <= '0;
          `uvm_info(get_type_name(),"IR should now be updated",UVM_HIGH);  
          tr.m_status <= OK;
       end
       DR: begin
          `uvm_info(get_type_name(),"Starting to update DR",UVM_HIGH);
          vif.SelectWIR <= '0;
          vif.UpdateWR <= '1;
          @ (posedge vif.WRCK);
          vif.UpdateWR <= '0;
          `uvm_info(get_type_name(),"DR should now be updated",UVM_HIGH);  
          tr.m_status <= OK;
       end
       default: `uvm_error(get_type_name(),$sformatf("er_tap_1500_item(tr_id=%0d) the m_select_reg was illegal",
                                                      m_req.get_transaction_id()) )
     endcase
  endtask
    
   task capture_register(ref er_tap_1500_item tr);
      case (tr.m_select_register)
	IR:begin
           `uvm_info(get_type_name(),"Starting to capture IR",UVM_MEDIUM);
           vif.SelectWIR <= '1;
           vif.CaptureWR <= '1;
           @ (posedge vif.WRCK);
           vif.CaptureWR <= '0;
           `uvm_info(get_type_name(),"IR should now be updated",UVM_MEDIUM);  
           tr.m_status <= OK;
           this.end_tr(m_req);
        end
	DR: begin
           void'(this.begin_tr(m_req,"driver_items"));           
           `uvm_info(get_type_name(),"Starting to capture DR",UVM_MEDIUM);
           vif.SelectWIR <= '0;
           vif.CaptureWR <= '1;
           @ (posedge vif.WRCK);
           vif.CaptureWR <= '0;
           `uvm_info(get_type_name(),"DR should now be captured",UVM_MEDIUM);  
           tr.m_status <= OK;
        end
	default: `uvm_error(get_type_name(),$sformatf("er_tap_1500_item(tr_id=%0d) the m_select_reg was illegal",
                                                      m_req.get_transaction_id()) )
      endcase
   endtask
  
  
   task run_phase(uvm_phase phase);
      // Fixing to get streams from time 0
      m_req=er_tap_1500_item::type_id::create("m_req"); 
      m_req.enable_recording("driver_item_stream");
      void'(this.begin_tr(m_req,"driver_items"));      
      this.end_tr(m_req);
      
      @(posedge vif.WRSTN);
      `uvm_info(get_type_name(),"Detected release of reset",UVM_MEDIUM);
      vif.WSI  <= '0;
      vif.SelectWIR <='0;
      vif.CaptureWR <= '0;
      vif.ShiftWR <= '0;
      vif.UpdateWR <= '0;
      @(posedge vif.WRCK);
      forever begin
         fork
            reset_handler();
            do_bus_access();
         join
      end
   endtask // run_phase
  
  







endclass : er_tap_1500_master_driver

`endif