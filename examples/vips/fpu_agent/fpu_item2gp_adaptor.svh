`ifndef __FPU_ITEM2GP_ADAPTOR
 `define __FPU_ITEM2GP_ADAPTOR
 `include "uvm_macros.svh"


class fpu_item2gp_adaptor extends uvm_component;
   `uvm_component_utils(fpu_item2gp_adaptor)
   typedef fpu_item2gp_adaptor  this_t;

   fpu_agent_config m_cfg;

   // Two different versions:
   // ****************************************
   // AP->SEQ_ITEM_EXPORT->TLM_MASTER_DRIVER
   // ****************************************
   uvm_analysis_export #(fpu_item) analysis_export; // Incoming transactions, pass to TLM Model
	uvm_tlm_analysis_fifo #(fpu_item) m_fifo;
	uvm_tlm_b_initiator_socket #(.T(uvm_tlm_gp)) tlm_out;

   // ****************************************
   // TLM_SLAVE_DRIVER->AP
   // ****************************************
   uvm_tlm_b_target_socket  #(.IMP(this_t),.T(uvm_tlm_gp)) tlm_in_lt; // Incoming transactions from LT-TLM model 
   uvm_tlm_nb_target_socket #(.IMP(this_t),.T(uvm_tlm_gp)) tlm_in_at; // Incoming transactions from AT-TLM model 

   // the slave contains an ap
   uvm_analysis_port #(fpu_item) ap; // pointer to ap in tlm slave
	
	fpu_item m_rsp;
	fpu_item m_req;

   function new(string name, uvm_component p = null);
      super.new(name,p);
   endfunction

   //--------------------------------------------------------------------
   // build_phase
   //------------------------------------------------------------------
   function void build_phase(uvm_phase phase );
      super.build_phase(phase);
      ap = new("ap",this);
      if(!uvm_config_db #(fpu_agent_config )::get(this, "", "fpu_agent_config", m_cfg)) begin
         `uvm_error({get_name(),":build phase"}, "fpu_agent_config not found")
      end

      case (m_cfg.m_socket_type)
        UNCONFIGURED_SOCKET : begin
           `uvm_error(get_name(),"You do have to select what type of the socket you want to use");
        end

        INITIATOR_SOCKET : begin
           `uvm_info(get_name(),"This socket is configured as a INITIATOR_SOCKET",UVM_MEDIUM);
           analysis_export     = new("analysis_export",this);
           m_fifo    = new("m_fifo",this);
			  tlm_out   = new("tlm_out",this);
        end

        TARGET_SOCKET : begin
           `uvm_info(get_name(),"This socket is configured as a TARGET_SOCKET",UVM_MEDIUM);
				case (m_cfg.m_tlm_timing_mode)
					LT_MODE: tlm_in_lt = new("tlm_in_lt",  this);
					AT_MODE: tlm_in_at = new("tlm_in_at",  this);
				endcase // case (m_cfg.m_tlm_timing_mode)
				m_rsp = fpu_item::type_id::create("m_rsp",this);
			end

        default: begin
           `uvm_error(get_name(),"Unspecified socket configuration");
        end

      endcase //case (m_cfg.socket_type)

   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      case (m_cfg.m_socket_type)

        UNCONFIGURED_SOCKET : begin
           `uvm_error(get_name(),"You do have to select what type of the socket you want to use");
        end

        INITIATOR_SOCKET: begin
           analysis_export.connect(m_fifo.analysis_export);
			  uvmc_tlm #(uvm_tlm_gp,uvm_tlm_phase_e)::connect(this.tlm_out, m_cfg.sc_lookup_name);
        end

        TARGET_SOCKET: begin
				case (m_cfg.m_tlm_timing_mode)
					// If using extensions
					// LT_MODE:uvmc_tlm #(uvm_tlm_gp,uvm_tlm_phase_e,gp_with_fpu_converter)::connect(this.tlm_in_lt, m_adaptor_cfg.sc_lookup_name);
					// AT_MODE:uvmc_tlm #(uvm_tlm_gp,uvm_tlm_phase_e,gp_with_fpu_converter)::connect(this.tlm_in_at, m_adaptor_cfg.sc_lookup_name);
			  		LT_MODE:uvmc_tlm #(uvm_tlm_gp,uvm_tlm_phase_e)::connect(this.tlm_in_lt, m_cfg.sc_lookup_name);
					AT_MODE:uvmc_tlm #(uvm_tlm_gp,uvm_tlm_phase_e)::connect(this.tlm_in_at, m_cfg.sc_lookup_name);
				endcase // case (m_cfg.m_tlm_timing_mode)
        end

        default: begin
           `uvm_error(get_name(),"Unspecified socket configuration");
        end

      endcase //case (m_cfg.socket_type)

   endfunction

	// The run_phase is actually only used by the 
	// initiator_socket.
   virtual task run_phase(uvm_phase phase);
      //int tr_handle;
      fpu_item    m_item;
      
      uvm_tlm_gp gp; 
      uvm_tlm_time delay=new("del",1e-12);
//      uvm_tlm_time delay=new("del",m_cfg.sc_delay);
      case (m_cfg.m_socket_type)
        INITIATOR_SOCKET : begin
	      forever begin
   	      m_fifo.get(m_item);
                `uvm_info("DEBUG",$sformatf("received item :" ),UVM_NONE);
					 m_item.print();
                gp = m_item.convert2fpu_gp_item();
                gp.print();
                tlm_out.b_transport(gp,delay);
      	end
        end
        TARGET_SOCKET: begin
        end
		  endcase

   endtask
	
   //--------------------------------------------------------------------
   // b_transport
   //--------------------------------------------------------------------
   // task called via 'tlm_in' socket
   task b_transport (uvm_tlm_gp  gp, uvm_tlm_time delay);
      `uvm_info(get_name(),"Received transaction from SC TLM model (LT MODE)",UVM_HIGH);
		gp.print();
      m_req = fpu_item::type_id::create("m_req",this);
      #(delay.get_realtime(1ns,1e-9));
      delay.reset();
      void'(this.begin_tr(m_req,"receive_tlm_items"));
      m_req.convert2fpu_item(gp);
      ap.write(m_req);
      #0;
      this.end_tr(m_req);
   endtask

   function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_gp gp,
                                           uvm_tlm_phase_e p,
                                           uvm_tlm_time delay);
      `uvm_info(get_name(),"Received transaction from SC TLM model (AT MODE)",UVM_HIGH);
      m_req = fpu_item::type_id::create("m_req",this); 
      //      gp.print();
      m_req.convert2fpu_item(gp);
      //      m_req.print();
      ap.write(m_req);
      if (p == END_RESP)
        return UVM_TLM_COMPLETED;
      else
        return UVM_TLM_ACCEPTED;
   endfunction // nb_transport_fw

endclass:fpu_item2gp_adaptor

`endif
