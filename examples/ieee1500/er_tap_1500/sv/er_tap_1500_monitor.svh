//----------------------------------------------------------------------
//                   Mentor Graphics Corporation
//----------------------------------------------------------------------
// Project         : ieee1500
// Unit            : er_tap_1500_monitor
// File            : er_tap_1500_monitor.svh
//----------------------------------------------------------------------
// Created by      : mikaela
// Creation Date   : 2014/01/29
//----------------------------------------------------------------------
// Title: 
//
// Summary:
//
// Description:
//
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// er_tap_1500_monitor
//----------------------------------------------------------------------
class er_tap_1500_monitor extends uvm_monitor;
   
   // factory registration macro
   `uvm_component_utils(er_tap_1500_monitor)   
   
   er_tap_1500_agent_config m_cfg;
   
   // external interfaces
   uvm_analysis_port     #(er_tap_1500_item) ap;
   
   // variables
   er_tap_1500_item    mon_txn, t;
   
   // interface  
   virtual er_tap_1500_if  vif;
   event   dbg;
   
   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------     
   function new (string name = "er_tap_1500_monitor",
                 uvm_component parent = null);
      super.new(name,parent);
   endfunction: new

   //--------------------------------------------------------------------
   // build_phase
   //--------------------------------------------------------------------     
   virtual function void build_phase(uvm_phase phase);

      ap = new("ap",this);          
      
   endfunction: build_phase
   
   

   //--------------------------------------------------------------------
   // run_phase
   //--------------------------------------------------------------------  
   virtual task run_phase(uvm_phase phase);
      mon_txn = er_tap_1500_item::type_id::create("mon_txn");
      mon_txn.enable_recording("mon_items");
      void'(this.begin_tr(mon_txn,"mon_items"));      
      this.end_tr(mon_txn);
      @(posedge vif.WRSTN);
      @(posedge vif.WRCK);
      fork
	 detect_shift_operation();
	 detect_update_operation();
	 detect_capture_operation();
      join
   endtask: run_phase

   //--------------------------------------------------------------------
   // monitor_dut
   //--------------------------------------------------------------------  
   
   task detect_capture_operation();
      // Monitor transactions from the interface
      int count;
      forever begin
	 if (vif.WRSTN) begin
            @(posedge vif.CaptureWR);
	    void'(this.begin_tr(mon_txn,"mon_items"));      

            @(posedge vif.WRCK);
            mon_txn.m_length = 0;
            mon_txn.m_status = OK;
            if (vif.SelectWIR) begin
               `uvm_info(get_type_name(),"Detected capture of IR",UVM_HIGH);               
               mon_txn.m_command=CAPTURE;
               mon_txn.m_select_register = IR;
               
            end else begin
               `uvm_info(get_type_name(),"Detected capture of DR",UVM_HIGH);
               mon_txn.m_command=CAPTURE;
               mon_txn.m_select_register = DR;
            end
            while (vif.UpdateWR) @(posedge vif.WRCK);
            $cast(t, mon_txn.clone());
            ap.write(t);	    	      
	    this.end_tr(mon_txn);

         end
      end
   endtask
   
   
   task detect_update_operation();
      // Monitor transactions from the interface
      int count;
      forever begin
	 if (vif.WRSTN) begin
            @(posedge vif.UpdateWR);
	    void'(this.begin_tr(mon_txn,"mon_items"));      
            @(posedge vif.WRCK);
            mon_txn.m_length = 0;
            mon_txn.m_status = OK;
            if (vif.SelectWIR) begin
               `uvm_info(get_type_name(),"Detected update of IR",UVM_HIGH);               
               mon_txn.m_command=UPDATE;
               mon_txn.m_select_register = IR;
               
            end else begin
               `uvm_info(get_type_name(),"Detected update of DR",UVM_HIGH);
               mon_txn.m_command=UPDATE;
               mon_txn.m_select_register = DR;
            end
            while (vif.UpdateWR) @(posedge vif.WRCK);
	    	       this.end_tr(mon_txn);

            $cast(t, mon_txn.clone());
            ap.write(t);
         end
      end
   endtask
   
   task detect_shift_operation();
      // Monitor transactions from the interface
      int count;
      forever begin
	 if (vif.WRSTN) begin
            @(posedge vif.ShiftWR);
	    void'(this.begin_tr(mon_txn,"mon_items"));      
            @(posedge vif.WRCK);              	    
     
            count = 0;
	    if (vif.SelectWIR) begin
	       `uvm_info(get_type_name(),"Detected start of Shift operation to IR",UVM_HIGH);     
               while(vif.ShiftWR & vif.SelectWIR) begin
		  mon_txn.m_data_in=new[count+1](mon_txn.m_data_in);
		  mon_txn.m_data_in[count] = vif.WSI;
		  @(posedge vif.WRCK);              
		  mon_txn.m_data_out=new[count+1](mon_txn.m_data_out);
		  mon_txn.m_data_out[count] = vif.WSO;
		  count++;
               end
               mon_txn.m_select_register = IR;
               mon_txn.m_length =count;
	       mon_txn.m_command=LOAD_REGISTER;
	       `uvm_info(get_type_name(),"Detected end of Shift operation to IR",UVM_HIGH);         

  	       
            end else 
	      begin
		 `uvm_info(get_type_name(),"Detected start of Shift operation to DR",UVM_HIGH);
		 count = 0;
		 while(vif.ShiftWR & ~vif.SelectWIR) begin
                    mon_txn.m_data_in[count] = vif.WSI;           
                    @(posedge vif.WRCK);              
                    mon_txn.m_data_out[count] = vif.WSO;  
                    count++;
		 end
		 mon_txn.m_select_register = DR;
		 mon_txn.m_length =count;
		 mon_txn.m_command=LOAD_REGISTER;
 	       `uvm_info(get_type_name(),"Detected end of Shift operation to DR",UVM_HIGH);         

              end // else: !if(vif.SelectWIR)
         end // if (vif.WRSTN)
            $cast(t, mon_txn.clone());
            ap.write(t);
	       this.end_tr(mon_txn);
      end
   endtask
endclass: er_tap_1500_monitor

