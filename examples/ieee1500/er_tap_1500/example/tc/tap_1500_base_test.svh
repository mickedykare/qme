class tap_1500_base_test extends uvm_test;

   `uvm_component_utils(tap_1500_base_test)    

   // The actual environmen
   tap_1500_env  m_env;
   // The configurations:
   er_simple_clk_reset_config m_clk_reset_config;
   er_tap_1500_agent_config  m_tap_1500_agent_config;
   
   // constructor
   function new(string name, uvm_component parent );
      super.new(name, parent);
      // Insert Constructor Code Here
   endfunction : new

   
   // build_phase
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_top.set_report_severity_id_action_hier(UVM_WARNING, "ILLEGALNAME",UVM_NO_ACTION);
      uvm_top.set_report_id_verbosity_hier("ILLEGALNAME",UVM_DEBUG);
      m_clk_reset_config  = er_simple_clk_reset_config::type_id::create("m_clk_reset_config");
      m_tap_1500_agent_config  = er_tap_1500_agent_config::type_id::create("m_tap_1500_agent_config");
      // Define reset parameters
      assert(m_clk_reset_config.randomize() with { m_reset_delay >= 5;
                                                   m_reset_delay <= 10;
                                                   m_clk_initial_value == 1;});
      m_clk_reset_config.m_clk_period=10ns;

      // Get the interfaces and put them in the config classes.
      
      if(!uvm_config_db #(virtual er_simple_clk_reset_if )::get(this, "", "CLOCK_INTERFACE", m_clk_reset_config.vif)) begin
         `uvm_error(get_type_name(), "CLOCK_INTERFACE not found)")
      end      
      

      if ( !uvm_config_db#(virtual er_tap_1500_if)::get (this,"","ER_TAP_1500_INTERFACE",m_tap_1500_agent_config.vif ) ) begin            
         `uvm_error( get_type_name(), "ER_TAP_1500_INTERFACE not found" )      
      end

      // Configure tap_1500 agent:
      m_tap_1500_agent_config.m_agent_mode=MASTER;
      
      // Publish the configurations    
      uvm_config_db #(er_simple_clk_reset_config)::set(this,"*m_env.m_clk_agent*","er_simple_clk_reset_config",m_clk_reset_config);
      uvm_config_db #(er_tap_1500_agent_config)::set(this,"*m_env.m_tap_1500_agent*","er_tap_1500_agent_config",m_tap_1500_agent_config);
      
      // Insert Build Code Here
      m_env = tap_1500_env ::type_id::create("m_env",this);
   endfunction // build_phase


   
   // connect_phase
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      
      // Insert Connect Code Here
   endfunction : connect_phase


   

   
   task run_phase(uvm_phase phase);

      
      bit  [31:0] respons;
      uvm_status_e 	status;
 
      phase.raise_objection(this);
      factory.print();
      #10us;
      


      phase.drop_objection(this);
      
   endtask // run_phase

   endclass
     