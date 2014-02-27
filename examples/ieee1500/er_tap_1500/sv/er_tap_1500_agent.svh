//----------------------------------------------------------------------
//                   Mentor Graphics Corporation
//----------------------------------------------------------------------
// Project         : ieee1500
// Unit            : er_tap_1500_agent_agent
// File            : er_tap_1500_agent_agent.svh
//----------------------------------------------------------------------
// Created by      : mikaela
// Creation Date   : 2014/01/29
//----------------------------------------------------------------------
// Title: 
//
// Summary:
//
// Description:
//
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// er_tap_1500_agent
//----------------------------------------------------------------------
class er_tap_1500_agent extends uvm_agent;

   // configuration object
   er_tap_1500_agent_config m_cfg;

   // factory registration macro
   `uvm_component_utils(er_tap_1500_agent)   

   // external interfaces
   uvm_analysis_port #(er_tap_1500_item) ap;

   // internal components
   er_tap_1500_monitor  m_monitor;
   er_tap_1500_base_driver  m_driver;
   uvm_sequencer #(er_tap_1500_item)  m_sequencer;
   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------
   function new(string name = "er_tap_1500_agent", 
		uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   //--------------------------------------------------------------------
   // build_phase
   //--------------------------------------------------------------------
   virtual function void build_phase(uvm_phase phase);
      
      if(!uvm_config_db #(er_tap_1500_agent_config)::get(this, "", "er_tap_1500_agent_config", m_cfg)) begin
	 `uvm_error("build_phase", "er_tap_1500_agent_config not found")
      end    

      case (m_cfg.m_agent_mode)
        UNCONFIGURED: begin
           `uvm_error(get_type_name(),"You do have to select what version of the agent you want to use");
        end

        MASTER: begin
           `uvm_info(get_type_name(),"This agent is configured as a RTL MASTER",UVM_NONE);
           er_tap_1500_base_driver::type_id::set_inst_override(er_tap_1500_master_driver::get_type(), {get_full_name(),".","m_driver"});
        end
        
        SLAVE: begin
           `uvm_info(get_type_name(),"This agent is configured as a RTL SLAVE - Remember to start slave sequence!",UVM_NONE);
           er_tap_1500_base_driver::type_id::set_inst_override(er_tap_1500_slave_driver::get_type(), {get_full_name(),".","m_driver"});
        end
	
        default: begin
           `uvm_error(get_type_name(),"Unspecified configuration");
        end
      endcase // case (m_cfg.m_agent_mode)




      ap = new("ap", this);
      
      // Monitor is always built
      m_monitor = er_tap_1500_monitor::type_id::create("m_monitor", this);
      
      // Driver and Sequencer only built if agent is active
      if (m_cfg.is_active == UVM_ACTIVE) begin
	 m_driver     = er_tap_1500_base_driver::type_id::create("m_driver",this);
	 m_sequencer  = uvm_sequencer #(er_tap_1500_item)::type_id::create("m_sequencer",this);
      end 
   endfunction: build_phase

   //--------------------------------------------------------------------
   // connect_phase
   //--------------------------------------------------------------------
   virtual function void connect_phase(uvm_phase phase);
      // Monitor is always connected
      m_monitor.ap.connect(ap);
      m_monitor.vif = m_cfg.vif;
      // Driver and Sequencer only connected if agent is active    
      if (m_cfg.is_active == UVM_ACTIVE) begin
	 m_driver.vif = m_cfg.vif;
	 m_driver.seq_item_port.connect(m_sequencer.seq_item_export);   
	 m_cfg.m_sequencer = this.m_sequencer; 
      end           
   endfunction: connect_phase

endclass: er_tap_1500_agent

