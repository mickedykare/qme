`ifndef __fpu_BASE_DRIVER
 `define __fpu_BASE_DRIVER
class fpu_base_driver extends uvm_driver #(fpu_item, fpu_item);

   // factory registration macro
   `uvm_component_utils(fpu_base_driver )

   // internal components
   fpu_item    m_req;
   fpu_item    m_rsp;

   // interface
   virtual fpu_if  vif;

   // local variables
   int     tests = 0;

   // Configuration class
   fpu_agent_config  m_cfg;
   uvm_analysis_port #(fpu_item) ap;

   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------
   function new (string name = "fpu_base_driver",
                 uvm_component parent = null);
      super.new(name,parent);
   endfunction: new

   // build phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db #(fpu_agent_config)::get(this, "", "fpu_agent_config", m_cfg)) begin
         `uvm_error({get_type_name(),":build phase"}, "fpu_agent_config not found")
      end
      ap =new("ap",this);
   endfunction

   //--------------------------------------------------------------------
   // run_phase
   // Add handling of reset - what happens if a reset occurs in the middle
   // the access?
   //--------------------------------------------------------------------
   virtual task run_phase(uvm_phase phase);
      `uvm_error(get_type_name(),"You must configure this agent to be an RTL agent or TLM agent");
   endtask: run_phase

   //--------------------------------------------------------------------
   // report_phase
   //--------------------------------------------------------------------
   virtual function void report_phase(uvm_phase phase);
      string s;
      $sformat(s, "%0d sequence items", tests);
      `uvm_info({get_type_name(),":report"}, s, UVM_MEDIUM )
   endfunction: report_phase

endclass: fpu_base_driver

`endif //  `ifndef __fpu_BASE_DRIVER
