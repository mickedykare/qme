//----------------------------------------------------------------------------
//                                                                          --
//     COPYRIGHT (C)                                ERICSSON  AB,  2012     --
//                                                                          --
//     Ericsson AB, Sweden.                                                 --
//                                                                          --
//     The document(s) may be used  and/or copied only with the written     --
//     permission from Ericsson AB  or in accordance with the terms and     --
//     conditions  stipulated in the agreement/contract under which the     --
//     document(s) have been supplied.                                      --
//                                                                          --
//----------------------------------------------------------------------------
// Unit            : er_clk_rst_item
//----------------------------------------------------------------------------
// Created by      : qmikand
// Creation Date   : 2012/06/19
//----------------------------------------------------------------------------
// Title: 
//
// Summary:
//
// Description:
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------
// er_clk_rst_item
//----------------------------------------------------------------------
class er_clk_rst_item extends uvm_sequence_item;

  rand cmd_t m_cmd;
  rand int m_delay;
    
  constraint C1 {
    m_delay >= 0;
    }  



  // user stimulus variables (rand)

  // user response variables (non rand)
  
  // factory registration macro
  `uvm_object_utils(er_clk_rst_item)

  
  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new (string name = "er_clk_rst_item" );
    super.new(name);
  endfunction: new

  //--------------------------------------------------------------------
  // do_copy
  //--------------------------------------------------------------------
  // Performs a deep copy of an object.
  virtual function void do_copy(uvm_object rhs);
    er_clk_rst_item rhs_;

    if(!$cast(rhs_, rhs)) begin 
      `uvm_error({get_type_name(),":do_copy"}, "Copy Failed, type mismatch")
      return;
    end 
    
    super.do_copy(rhs);    
    
  endfunction: do_copy

  //--------------------------------------------------------------------
  // do_compare
  //--------------------------------------------------------------------
  // Compares one object to another of the same type.
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    er_clk_rst_item rhs_;
    
    if(!$cast(rhs_, rhs)) begin 
      `uvm_error({get_type_name(),":do_compare"}, "Compare Failed, type mismatch")
      return 0; 
    end    

    return((super.do_compare(rhs, comparer))
      );
    
  endfunction: do_compare

  //--------------------------------------------------------------------
  // do_print
  //--------------------------------------------------------------------
  // Prints a the result of convert2string to the screen.
  function void do_print(uvm_printer printer);
    if(printer.knobs.sprint == 0) begin
      $display(convert2string());
    end
    else begin
      printer.m_string = convert2string();
    end
  endfunction: do_print

  //--------------------------------------------------------------------
  // convert2string
  //--------------------------------------------------------------------
  // Returns a string representation of the object.
  function string convert2string();
    string str;
    str = super.convert2string();
    $sformat(str, "%s\n",str);

    return str;
  endfunction: convert2string


endclass: er_clk_rst_item

