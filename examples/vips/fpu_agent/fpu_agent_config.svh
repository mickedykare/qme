`ifndef __FPU_AGENT_CONFIG
 `define __FPU_AGENT_CONFIG

class fpu_agent_config  extends uvm_object;  
  // factory registration macro
   `uvm_object_utils (fpu_agent_config)

   agent_mode_t m_agent_mode = UNCONFIGURED;

   // Used for adaptor to set direction, could be TARGET_SOCKET or INITIATOR_SOCKET.
   socket_type_t m_socket_type = UNCONFIGURED_SOCKET;

   tlm_timing_mode_t m_tlm_timing_mode = LT_MODE; // Can also be AT_MODE

   // ----------------------------------------------------------------
   // This string is used to connect to the TLM port in Systemc world.
   // Refer to UVMC documentation
   // ---------------------------------------------------------------
   string sc_lookup_name = "foo";
  
   // virtual interface handle:
   virtual fpu_if  vif;

   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------
   function new(string name = "fpu_agent_config");
      super.new(name);
   endfunction: new

endclass: fpu_agent_config

`endif //  `ifndef __FPU_AGENT_CONFIG
