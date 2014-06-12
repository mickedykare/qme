class fpu_environment extends uvm_env; // rename to base

`uvm_component_utils(fpu_environment)

//	fpu_agent                     agent;
	fpu_agent                     master_agent;
	fpu_agent                     slave_agent;
	fpu_scoreboard                scoreboard;
	listener								master_listener;

	//converters between SV and SC
	fpu_item2gp_adaptor m_fpu_master_adaptor;
	fpu_item2gp_adaptor m_fpu_slave_adaptor;
	fpu_env_config m_cfg;
	
	function new(string name = "", uvm_component parent=null);
      super.new(name, parent);
	endfunction // new

	// Using uvm 2.0 factory
	function void build_phase(uvm_phase phase);     
      int verbosity_level = UVM_HIGH;
      super.build_phase(phase);

		if (!uvm_config_db #(fpu_env_config)::get(this,"","fpu_env_config",m_cfg)) begin
			`uvm_error("build_phase","fpu_env_config configuration object not found")
		end

      uvm_config_db#(int)::set(this,"master_agent","is_active",int'(UVM_ACTIVE));
      uvm_config_db#(int)::set(this,"slave_agent","is_active",int'(UVM_PASSIVE));

		// Create the agents
      master_agent = fpu_agent::type_id::create("master_agent", this);
      slave_agent  = fpu_agent::type_id::create("slave_agent", this);

		// Create the TLM adaptors (should be in the agents?)
		m_fpu_master_adaptor = fpu_item2gp_adaptor::type_id::create("master_adaptor",this);
		m_fpu_slave_adaptor  = fpu_item2gp_adaptor::type_id::create("slave_adaptor",this);
		
		// Create the listener so that we can see that item are coming from the analysis port
		master_listener  = listener::type_id::create("master_listener",this);
		
		// Create a scoreboard
      scoreboard = fpu_scoreboard::type_id::create("scoreboard", this);
		
		// Set verbosity level
		void'(uvm_config_db#(int)::get(this,"","verbosity_level", verbosity_level));
      set_report_verbosity_level(verbosity_level);
	endfunction // new


	function void connect_phase(uvm_phase phase);     
      super.connect_phase(phase);
		master_agent.request_analysis_port.connect(m_fpu_master_adaptor.analysis_export);
		master_agent.request_analysis_port.connect(master_listener.analysis_export);
      slave_agent.response_analysis_port.connect(scoreboard.response_analysis_export);
		m_fpu_slave_adaptor.ap.connect(scoreboard.response_analysis_export_tlm);
	endfunction 

endclass
