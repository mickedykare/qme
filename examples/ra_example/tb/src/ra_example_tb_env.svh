class ra_example_tb_env #(int ADDR_WIDTH,int DATA_WIDTH) extends uvm_env;

  // factory registration macro
  `uvm_component_param_utils(ra_example_tb_env #(ADDR_WIDTH, DATA_WIDTH))

  // internal components
   //  coverage     m_generic_reg_bus_agent_cov;   
   //  scoreboard   m_scoreboard;
   //
   
   // pointer to  analysis port from apb3 agent
   uvm_analysis_port #( mvc_sequence_item_base ) mon_ap; 
   
   mvc_agent m_apb3_master_agent;
   sli_clk_reset_agent	m_clk_reset_agent; 
  
  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------    
  function new(string name = "ra_example_tb", 
               uvm_component parent = null);
    super.new(name, parent);      
  endfunction: new

  //--------------------------------------------------------------------
  // build_phase
  //-------------------------------------------------------------------- 
  virtual function void build_phase(uvm_phase phase);
     m_apb3_master_agent = mvc_agent::type_id::create("m_apb3_master_agent",this);
     m_clk_reset_agent = sli_clk_reset_agent::type_id::create("m_clk_reset_agent", this);
  endfunction: build_phase

  //--------------------------------------------------------------------
  // connect_phase
  //-------------------------------------------------------------------- 
  virtual function void connect_phase(uvm_phase phase);
     mon_ap = m_apb3_master_agent.ap["trans_ap"];     
     uvm_config_db #(mvc_sequencer)::set(null, "*", "apb3_sequencer", m_apb3_master_agent.m_sequencer);
  endfunction: connect_phase

   
endclass: ra_example_tb_env

