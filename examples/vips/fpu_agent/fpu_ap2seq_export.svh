
`ifndef __FPU_AP2SEQ_EXPORT
 `define __FPU_AP2SEQ_EXPORT
 `include "uvm_macros.svh"


class fpu_ap2seq_export extends uvm_component;
   `uvm_component_utils(fpu_ap2seq_export)

   //   uvm_seq_item_pull_export #(fpu_item) seq_item_export;

   uvm_sequencer         #(fpu_item) m_sequencer; // We need a seq to run the slave sequence
   uvm_analysis_export   #(fpu_item) analysis_export;
   uvm_tlm_analysis_fifo #(fpu_item) m_fifo;

   fpu_item_seq m_seq;

   function new(string name, uvm_component p = null);
      super.new(name,p);
   endfunction

   //--------------------------------------------------------------------
   // build_phase
   //------------------------------------------------------------------
   function void build_phase(uvm_phase phase );
      super.build_phase(phase);
      analysis_export = new("analysis_export", this);
      m_fifo = new("m_fifo",this);
      m_sequencer = new("m_sequencer",this);
      m_seq = fpu_item_seq::type_id::create("m_seq");
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      analysis_export.connect(m_fifo.analysis_export);
   endfunction // connect_phase


   task run_phase(uvm_phase phase);
      forever begin
         m_seq = fpu_item_seq::type_id::create("m_seq");
         m_fifo.get(m_seq.m_item);
         $display("%m DBG received transaction:",$time());
         m_seq.m_item.print();

         m_seq.start(this.m_sequencer);
         `uvm_info(get_type_name(),"Sent transaction on to seq_item_export",UVM_HIGH);
      end
   endtask // run_phase

endclass:fpu_ap2seq_export

`endif
