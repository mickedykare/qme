class fpu_env_config extends uvm_object; 

`uvm_object_utils(fpu_env_config)

	// Configuration object for the agents
	fpu_agent_config m_fpu_master_agent_config;
	fpu_agent_config m_fpu_slave_agent_config;
	
	function new(string name="fpu_env_config");
		super.new(name);

	endfunction: new

endclass
