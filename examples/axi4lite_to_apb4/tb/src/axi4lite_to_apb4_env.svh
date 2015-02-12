class axi4lite_to_apb4_env extends uvm_env;

  `uvm_component_utils(axi4lite_to_apb4_env)  
   // my agents
   mvc_agent m_axi4lite_master_agent;
   mvc_agent m_apb4_master_agent;
   mvc_agent m_apb4_slave_agent;
   sli_clk_reset_agent  m_clk_axi4_agent; 
   sli_clk_reset_agent  m_clk_apb4_master_agent; 
   sli_clk_reset_agent  m_clk_apb4_slave_agent; 


  // pointer to  analysis port from apb3 agent
   uvm_analysis_port #( mvc_sequence_item_base ) mon_apb4_master_ap; 
   uvm_analysis_port #( mvc_sequence_item_base ) mon_apb4_slave_ap; 
   uvm_analysis_port #( mvc_sequence_item_base ) mon_axi4_master_ap; 

   function new(string name="m_axi4lite_to_apb4_env",uvm_component parent=null);
      super.new(name,parent);
   endfunction // new
   
   function void build_phase(uvm_phase phase);
      m_axi4lite_master_agent=mvc_agent::type_id::create("m_axi4lite_master_agent",this);
      m_apb4_master_agent=mvc_agent::type_id::create("m_apb4_master_agent",this);
      m_apb4_slave_agent=mvc_agent::type_id::create("m_apb4_slave_agent",this);
      m_clk_apb4_master_agent=sli_clk_reset_agent::type_id::create("m_clk_apb4_master_agent",this);
      m_clk_apb4_slave_agent=sli_clk_reset_agent::type_id::create("m_clk_apb4_slave_agent",this);
      m_clk_axi4_agent=sli_clk_reset_agent::type_id::create("m_clk_axi4_agent",this);
      
   endfunction // build_phase
   
   
   function void connect_phase(uvm_phase phase);
      mon_apb4_master_ap = m_apb4_master_agent.ap["trans_ap"];     
      mon_apb4_slave_ap = m_apb4_slave_agent.ap["trans_ap"];     
      mon_axi4_master_ap = m_axi4lite_master_agent.ap["trans_ap"];     
   endfunction // connect_phase
   

endclass
