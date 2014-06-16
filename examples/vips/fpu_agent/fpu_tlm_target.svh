`ifndef __fpu_TLM_TARGET
 `define __fpu_TLM_TARGET

class fpu_tlm_target extends fpu_base_driver ;

   typedef fpu_tlm_target  this_t;

   `uvm_component_utils(fpu_tlm_target )
   uvm_tlm_b_target_socket  #(.IMP(this_t),.T(uvm_tlm_gp)) tlm_in_lt;
   uvm_tlm_nb_target_socket #(.IMP(this_t),.T(uvm_tlm_gp)) tlm_in_at;

    fpu_agent_config m_adaptor_cfg;
  // local variables
   int tests = 0;
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // Insert Connect Code Here
      case (m_cfg.m_tlm_timing_mode)
        LT_MODE:uvmc_tlm #(uvm_tlm_gp,uvm_tlm_phase_e,gp_with_fpu_converter)::connect(this.tlm_in_lt, m_adaptor_cfg.sc_lookup_name);
        AT_MODE:uvmc_tlm #(uvm_tlm_gp,uvm_tlm_phase_e,gp_with_fpu_converter)::connect(this.tlm_in_at, m_adaptor_cfg.sc_lookup_name);
      endcase // case (m_cfg.m_tlm_timing_mode)

   endfunction : connect_phase

   //--------------------------------------------------------------------
   // build_phase
   //------------------------------------------------------------------
   function void build_phase(uvm_phase phase );
      super.build_phase(phase);
      case (m_cfg.m_tlm_timing_mode)
        LT_MODE: tlm_in_lt = new("tlm_in_lt",  this);
        AT_MODE: tlm_in_at = new("tlm_in_at",  this);
      endcase // case (m_cfg.m_tlm_timing_mode)

      if(!uvm_config_db #(fpu_agent_config )::get(this, "", "fpu_agent_config", m_adaptor_cfg)) begin
         `uvm_error({get_type_name(),":build phase"}, "fpu_agent_config not found")
      end

      m_rsp = fpu_item::type_id::create("m_rsp",this);
   endfunction : build_phase

   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------
   function new (string name = "fpu_tlm_target", uvm_component parent = null);
      super.new(name,parent);
   endfunction: new

   task run_phase(uvm_phase phase);
      //      m_req.enable_recording("tlm_item");
   endtask // run_phase

   //--------------------------------------------------------------------
   // b_transport
   //--------------------------------------------------------------------
   // task called via 'tlm_in' socket
   task b_transport (uvm_tlm_gp  gp, uvm_tlm_time delay);
      `uvm_info(get_type_name(),"Received transaction from SC TLM model",UVM_HIGH);
      m_req = fpu_item::type_id::create("m_req",this);
      #(delay.get_realtime(1ns,1e-9));
      delay.reset();
      void'(this.begin_tr(m_req,"receive_tlm_items"));
      m_req.convert2fpu_item(gp);
      ap.write(m_req);
      #0;
      this.end_tr(m_req);
      tests++;
   endtask

   function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_gp gp,
                                           uvm_tlm_phase_e p,
                                           uvm_tlm_time delay);
      `uvm_info(get_type_name(),"Received transaction from SC TLM model(AT MODE)",UVM_HIGH);
      m_req = fpu_item::type_id::create("m_req",this);
      //      gp.print();
      m_req.convert2fpu_item(gp);
      //      m_req.print();
      ap.write(m_req);
      tests++;
      if (p == END_RESP)
        return UVM_TLM_COMPLETED;
      else
        return UVM_TLM_ACCEPTED;
   endfunction // nb_transport_fw

endclass: fpu_tlm_target
`endif
