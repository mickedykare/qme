class tap_1500_env extends uvm_env;


   `uvm_component_utils(tap_1500_env)

   // These are the agents we need
   er_tap_1500_agent m_tap_1500_agent;
   er_simple_clk_reset_agent m_clk_agent;

  // constructor
  function new(string name = "env", uvm_component parent = null );
    super.new(name, parent);
    // Insert Constructor Code Here
  endfunction : new

  // build_phase
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    // Insert Build Code Here
      m_tap_1500_agent = er_tap_1500_agent::type_id::create("m_tap_1500_agent",this);
      m_clk_agent = er_simple_clk_reset_agent::type_id::create("m_clk_agent",this);
  endfunction : build_phase


  // connect_phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
     // this is where we hook up all the analysis components
  endfunction : connect_phase

endclass // rmm_reader_env

   