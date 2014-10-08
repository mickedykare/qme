
class fpu_test_base extends uvm_test;

   int verbosity_level = UVM_MEDIUM;
   int m_logfile_handle;
   `uvm_component_utils(fpu_test_base)

  
     fpu_agent_config m_fpu_master_agent_config;
   fpu_agent_config m_fpu_slave_agent_config;
   
   fpu_env_config m_cfg;  
   fpu_environment m_env;

   // Handle to sequencer down in the test environment
   uvm_sequencer #(fpu_item, fpu_item) seqr_handle;
   

   function new(string name = "fpu_test_base", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new
   


   function void build_phase(uvm_phase phase); 
      string  result;
      string  verbosity_level_s;
      
         verbosity_level = UVM_MEDIUM;
      uvm_report_info( get_type_name(), $psprintf("Setting verbosity_level: %0d", verbosity_level), UVM_FULL );
      uvm_config_db#(int)::set(this,"","verbosity_level", verbosity_level);

      super.build_phase(phase);
      
      //Using the uvm 2.0 factory 
      m_env = fpu_environment::type_id::create("m_env", this);

      m_fpu_master_agent_config = fpu_agent_config::type_id::create("m_fpu_master_agent_config");
      m_fpu_master_agent_config.m_agent_mode      = RTL_MASTER;
      m_fpu_master_agent_config.m_tlm_timing_mode = LT_MODE;
      m_fpu_master_agent_config.m_socket_type  = INITIATOR_SOCKET; 
      m_fpu_master_agent_config.sc_lookup_name = "request_socket";   
      
      m_fpu_slave_agent_config = fpu_agent_config::type_id::create("m_fpu_slave_agent_config");
      m_fpu_slave_agent_config.m_agent_mode      = RTL_SLAVE;
      m_fpu_slave_agent_config.m_tlm_timing_mode = LT_MODE;
      m_fpu_slave_agent_config.m_socket_type  = TARGET_SOCKET; 
      m_fpu_slave_agent_config.sc_lookup_name = "response_socket";   
      
      m_cfg = fpu_env_config::type_id::create("m_cfg",this);
      m_cfg.m_fpu_master_agent_config = m_fpu_master_agent_config;
      m_cfg.m_fpu_slave_agent_config  = m_fpu_slave_agent_config;
      
      uvm_config_db #(fpu_env_config)::set(this,"*","fpu_env_config",m_cfg);
      uvm_config_db #(fpu_agent_config)::set(this,"*master*","fpu_agent_config",m_fpu_master_agent_config);
      uvm_config_db #(fpu_agent_config)::set(this,"*slave*","fpu_agent_config",m_fpu_slave_agent_config);
      
      // Set the name of the sequencer
      uvm_config_db#(string)::set(this,"m_env.*","SEQR_NAME", "main_sequencer");

   endfunction


   virtual    function void end_of_elaboration_phase(uvm_phase phase); 
      //find the sequencer in the testbench
      assert($cast(seqr_handle, uvm_top.find("*main_sequencer")));  
   endfunction // end_of_elaboration
   

   virtual    task run_phase(uvm_phase phase); 

      int runtime = `TIMEOUT;
      phase.raise_objection(this,"run_phase raise objection in fpu_test_base");
      
      uvm_report_info(get_type_name(), "No Sequences started ...", UVM_LOW); 
      #runtime;
      uvm_report_info(get_type_name(), "Stopping test...", UVM_LOW );      
      phase.drop_objection(this,"run_phase drop objection in fpu_test_base");
   endtask
   




endclass
