//----------------------------------------------------------------------
//                   Mentor Graphics Corporation
//----------------------------------------------------------------------
// Project         : ieee1500
// Unit            : er_tap_1500_item
// File            : er_tap_1500_item.svh
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
// er_tap_1500_item
//----------------------------------------------------------------------
class er_tap_1500_item extends uvm_sequence_item;
  
  rand command_t m_command;
  rand sel_reg_t m_select_register;
  rand bit m_data_in[]; 
  rand bit m_data_out[];
  
  rand integer m_length; //Number of bits;
  status_t m_status;
 
  // declaration macros
   `uvm_object_utils_begin(er_tap_1500_item)
      `uvm_field_enum(command_t,m_command,UVM_ALL_ON|UVM_NORECORD)
      `uvm_field_enum(sel_reg_t,m_select_register,UVM_ALL_ON|UVM_NORECORD)
      `uvm_field_array_int(m_data_in,UVM_ALL_ON|UVM_NORECORD)
      `uvm_field_array_int(m_data_out,UVM_ALL_ON|UVM_NORECORD)
      `uvm_field_int(m_length,UVM_ALL_ON|UVM_NORECORD)
   `uvm_object_utils_end

   // To avoid some problems with ILLEGALNAME, I stole this from GP item
   
   function void do_record(uvm_recorder recorder);
      if (!is_recording_enabled())
	return;
      super.do_record(recorder);
      `uvm_record_field("command",m_command.name())
      `uvm_record_field("select_reg",m_select_register.name())      
      `uvm_record_field("data_length",m_length)
      `uvm_record_field("response_status",m_status.name())
      for (int i=0; i < m_length; i++)
	`uvm_record_field($sformatf("\\data_in[%0d] ", i), m_data_in[i])
      for (int i=0; i < m_length; i++)
	`uvm_record_field($sformatf("\\data_out[%0d] ", i), m_data_out[i])

  endfunction

   
   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------  
   function new(string name="er_tap_1500_item");
      super.new(name);
   endfunction: new
   
   constraint C_SIZE {m_data_in.size() == m_length;
                      m_data_out.size() == m_length;}
   
    virtual function void set_data_in(ref bit unsigned p []);
    m_data_in = p;
  endfunction 
   
endclass: er_tap_1500_item

