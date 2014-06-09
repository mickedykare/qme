class ra_example_tb_env #(type REGISTERMODEL_T=int,int ADDR_WIDTH,int DATA_WIDTH) extends uvm_env;

  // factory registration macro
  `uvm_component_param_utils(ra_example_tb_env #(REGISTERMODEL_T,ADDR_WIDTH, DATA_WIDTH))

  // internal components
   //  coverage     m_generic_reg_bus_agent_cov;   
   //  scoreboard   m_scoreboard;
   //

   typedef apb3_reg_predictor #(1,ADDR_WIDTH, DATA_WIDTH) apb3_reg_predictor_t;

   typedef reg2apb_adapter #(.NO_OF_SLAVES(1),
                             .ADDRESS_CHUNK(0),
                             .ADDRESS_WIDTH(ADDR_WIDTH), 
                             .DATA_WIDTH(DATA_WIDTH)) reg2apb_adapter_t; 
   
   // adapter for register bus
   reg2apb_adapter_t m_reg2apb;           
   // Predictor           
   apb3_reg_predictor_t m_reg_predictor;  
   // pointer to  analysis port from apb3 agent
   uvm_analysis_port #( mvc_sequence_item_base ) mon_ap; 
   // pointer to Register map
   REGISTERMODEL_T m_registermodel;
   
   
   
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
     m_reg2apb = reg2apb_adapter_t::type_id::create("m_reg2apb");
     m_reg_predictor = apb3_reg_predictor_t::type_id::create("m_reg_predictor",this);
     uvm_default_printer = uvm_default_table_printer;
  endfunction: build_phase

  //--------------------------------------------------------------------
  // connect_phase
  //-------------------------------------------------------------------- 
  virtual function void connect_phase(uvm_phase phase);
     if(!uvm_config_db #(REGISTERMODEL_T)::get( this , "", "REGISTERMAP" , m_registermodel )) begin
        `uvm_error(get_type_name(),"get cannot find resource REGISTERMAP" )
     end
     mon_ap = m_apb3_master_agent.ap["trans_ap"];
     mon_ap.connect(m_reg_predictor.bus_item_export);
     // Note CHECK for REUSE! How do I know that this is not a top level env?
     m_reg_predictor.map=m_registermodel.example_block_registers_map;
     m_reg_predictor.adapter = m_reg2apb;
     m_registermodel.example_block_registers_map.set_auto_predict(0);
     uvm_config_db #(mvc_sequencer)::set(null, "*", "apb3_sequencer", m_apb3_master_agent.m_sequencer);
  endfunction: connect_phase

   
endclass: ra_example_tb_env

