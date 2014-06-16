`ifndef __fpu_ITEM_SEQ
 `define __fpu_ITEM_SEQ
class fpu_item_seq extends uvm_sequence #(fpu_item);

   fpu_item m_item;

   `uvm_object_utils(fpu_item_seq)

   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------
   function new (string name = "fpu_item_seq" );
      super.new(name);
      m_item = new("m_item");

   endfunction: new

   task body;
      start_item(m_item);
      finish_item(m_item);
      get_response(m_item);
   endtask //

endclass: fpu_item_seq
`endif
