class fpu_agent extends uvm_env;
`uvm_component_utils( fpu_agent)

	fpu_agent_config m_cfg;

	uvm_sequencer #(fpu_item, fpu_item) sequencer;
	fpu_sequence_driver           driver;

	fpu_monitor                   monitor; 
	fpu_coverage                  coverage;

	virtual fpu_pin_if m_fpu_pins;

	uvm_analysis_port #(fpu_item)  request_analysis_port;
	uvm_analysis_port #(fpu_item) response_analysis_port;

	uvm_active_passive_enum is_active = UVM_ACTIVE;

	function new(string name = "RTL_Env", uvm_component parent=null);
		super.new(name, parent);
	endfunction // new

	function void build_phase(uvm_phase phase);     

		string seqr_name;

		int verbosity_level = UVM_FULL;
		int active;

		super.build_phase(phase);

		void'(uvm_config_db#(int)::get(this,"","verbosity_level", verbosity_level));
		set_report_verbosity_level(verbosity_level);

		if (!uvm_config_db#(fpu_agent_config)::get(this,"","fpu_agent_config",m_cfg)) begin
			`uvm_error({get_type_name(),":build_phase"},"fpu_agent_config not found")
		end

		if (uvm_config_db#(int)::get(this,"","is_active",active)) begin
			is_active = uvm_active_passive_enum'(active);
		end

		uvm_report_info(get_type_name(), $psprintf("active set to %s", is_active), UVM_FULL );

		uvm_report_info(get_type_name(), "build", UVM_FULL );

		response_analysis_port = new("response_analysis_port",  this);

		monitor = fpu_monitor::type_id::create("fpu_monitor", this);
		coverage = fpu_coverage::type_id::create("fpu_coverage", this);

		if (is_active == UVM_ACTIVE) begin
			no_seqr_name:assert(uvm_config_db#(string)::get(this,"","SEQR_NAME",seqr_name));
			sequencer = new (seqr_name, this);
			request_analysis_port  = new("request_analysis_port",  this);
			driver = fpu_sequence_driver::type_id::create("fpu_sequence_driver", this);
		end
	endfunction // new


	function void connect_phase(uvm_phase phase);     
		super.connect_phase(phase);

		monitor.response_ap.connect( coverage.analysis_export );
		monitor.response_ap.connect( response_analysis_port );

		if (is_active == UVM_ACTIVE) begin
			driver.seq_item_port.connect( sequencer.seq_item_export );

			driver.analysis_port.connect( request_analysis_port );
		end
	endfunction // void


endclass
