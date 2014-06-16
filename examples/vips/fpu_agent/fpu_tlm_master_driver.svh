`ifndef __FPU_TLM_MASTER_DRIVER
 `define __FPU_TLM_MASTER_DRIVER

class fpu_tlm_master_driver  extends fpu_base_driver ;

   typedef fpu_tlm_master_driver  this_t;

   // factory registration macro
   `uvm_component_utils(fpu_tlm_master_driver )

   uvm_tlm_b_initiator_socket  #(.T(uvm_tlm_gp)) tlm_out_lt;
   uvm_tlm_nb_initiator_socket #(.T(uvm_tlm_gp),.IMP(this_t)) tlm_out_at;

   fpu_agent_config m_adaptor_cfg;
   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------
   function new (string name = "fpu_tlm_master_driver",
                 uvm_component parent = null);
      super.new(name,parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      case (m_cfg.m_tlm_timing_mode)
        LT_MODE:tlm_out_lt = new("tlm_out_lt",this);
        AT_MODE:tlm_out_at = new("tlm_out_at",this,this);
      endcase // case (m_cfg.m_tlm_timing_mode)

   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      if(!uvm_config_db #(fpu_agent_config )::get(this, "", "fpu_agent_config", m_adaptor_cfg)) begin
         `uvm_error({get_type_name(),":build phase"}, "fpu_agent_config not found")
      end

      case (m_cfg.m_tlm_timing_mode)
        LT_MODE:uvmc_tlm #(uvm_tlm_gp,uvm_tlm_phase_e,gp_with_fpu_converter)::connect(this.tlm_out_lt, m_adaptor_cfg.sc_lookup_name);
        AT_MODE:uvmc_tlm #(uvm_tlm_gp,uvm_tlm_phase_e,gp_with_fpu_converter)::connect(this.tlm_out_at, m_adaptor_cfg.sc_lookup_name);
      endcase // case (m_cfg.m_tlm_timing_mode)


   endfunction

   function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      `uvm_info(get_type_name(),$psprintf("Running in %0s",m_cfg.m_tlm_timing_mode),UVM_HIGH);
   endfunction // end_of_elaboration_phase


   //--------------------------------------------------------------------
   // run_phase
   // Add handling of reset - what happens if a reset occurs in the middle
   // the access?
   //--------------------------------------------------------------------
   virtual task run_phase(uvm_phase phase);
      int tr_handle;
      
      uvm_tlm_gp gp;
      uvm_tlm_phase_e p;
      uvm_tlm_time delay=new("del",0);
      m_req = new();
      m_req.enable_recording("tlm_item");
      void'(this.begin_tr(m_req,"sent_tlm_items"));
      this.end_tr(m_req);


      forever begin
         seq_item_port.get_next_item(m_req);
         `uvm_info(get_type_name(),"Got transaction from sequencer",UVM_HIGH);
         $cast(m_rsp,m_req.clone());
         m_rsp.set_id_info(m_req);
         gp = m_req.convert2fpu_gp_item();
         //      gp.print();

         tr_handle=this.begin_tr(m_req,"sent_tlm_items");
         if (m_req.is_recording_enabled()) m_req.set_transaction_color(tr_handle);

         
         //      void'(this.begin_tr(gp,"sent_gp_items"));
         case (m_cfg.m_tlm_timing_mode)
           LT_MODE:tlm_out_lt.b_transport(gp,delay);
           AT_MODE: begin
              p = BEGIN_REQ;
              void'(tlm_out_at.nb_transport_fw(gp,p,delay));
           end
         endcase

         tests++;
         `uvm_info(get_type_name(),"Sending transaction to AP",UVM_HIGH);

         ap.write(m_rsp);
	 		#(delay.get_realtime(1ns,1e-9));
         delay.reset();
         this.end_tr(m_req);
         // Put response data into the req_txn fields
         seq_item_port.item_done(m_req);
      end
   endtask: run_phase

   function uvm_tlm_sync_e nb_transport_bw(ref uvm_tlm_gp t,
                                           ref uvm_tlm_phase_e p,
                                           input uvm_tlm_time delay);
      return UVM_TLM_ACCEPTED;
   endfunction

endclass: fpu_tlm_master_driver

`endif //  `ifndef __FPU_TLM_MASTER_DRIVER
