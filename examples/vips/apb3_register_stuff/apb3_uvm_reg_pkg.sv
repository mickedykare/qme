// This package describes the parts used for uvm reg package with apb3


package apb3_uvm_reg_pkg;
   import uvm_pkg::*;
   import mvc_pkg::*;
   import mgc_apb3_v1_0_pkg::*;        
`include "uvm_macros.svh"


// For APB we have different use cases
// A. one slave. No decoding of address chunks to PSEL
// B. Multiple slaves, we need to decode PSEL for different addresses
   
class reg2apb_adapter #(int NO_OF_SLAVES=1,
			int ADDRESS_CHUNK=17'h1_0000,
			int ADDRESS_WIDTH = 32 ,
			int DATA_WIDTH = 32) extends uvm_reg_adapter;
   
   typedef apb3_host_apb3_transaction #( 1 ,
                                         ADDRESS_WIDTH ,
                                         DATA_WIDTH ,
                                         DATA_WIDTH ) apb3_transaction_t;


   
   typedef reg2apb_adapter #(NO_OF_SLAVES,ADDRESS_CHUNK,ADDRESS_WIDTH, DATA_WIDTH) this_t; 

  `uvm_object_param_utils(this_t)

   function string get_type_name();
      return "reg2apb_adapter";
   endfunction // get_type_name
   
   
   function new(string name = "reg2apb_adapter");
      mvc_sequence base_seq;
      super.new(name);
      supports_byte_enable = 0;
      provides_responses = 0;
      base_seq = new;
      parent_sequence = base_seq;
   endfunction // new

   

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb3_transaction_t apb = apb3_transaction_t::type_id::create("apb");

    uvm_reg_item       item = get_item();
    uvm_sequencer_base seqr = item.map.get_sequencer();

    apb.set_sequencer(seqr);
   //  `uvm_info(get_type_name(),"Received register transaction...",UVM_NONE);
     

     
    if (NO_OF_SLAVES != 1) begin
       `uvm_fatal(get_type_name(),"Multiple slaves not implemented yet");
    end
    else
      begin
	 `uvm_info(get_type_name(),"Converting UVM REG transaction to APB3 transaction",UVM_NONE);
	 if (rw.kind == UVM_WRITE) begin
	    if (!apb.randomize() with {apb.slave_id         == 0;
                                       apb.addr             == rw.addr;
                                       apb.prot             == 3'b000;
                                       apb.read_or_write    == APB3_TRANS_WRITE;
                                       apb.wr_data          == rw.data;
                                       apb.strb             == 4'b1111;} )
              `uvm_fatal(get_type_name(),"bad constraints in UVM_WRITE");
	 end else begin
	    if (!apb.randomize() with {apb.slave_id         == 0;
                                       apb.addr             == rw.addr;
                                       apb.prot             == 3'b000;
                                       apb.read_or_write    == APB3_TRANS_READ;
                                       apb.strb             == 4'b0000;} )
              `uvm_fatal(get_type_name(),"bad constraints in UVM_READ");
	 end
	 
	 `uvm_info(get_type_name(),$sformatf("do register access: %p",rw),UVM_MEDIUM);
	 return apb;
      end // UNMATCHED !!
       
      endfunction: reg2bus



   
  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    apb3_transaction_t apb;

   //  `uvm_info(get_type_name(),"Received bus transaction...",UVM_NONE);

     
    if (!$cast(apb, bus_item))
    begin
      `uvm_fatal("NOT_APB_TYPE","Provided bus_item is not of the correct type")
      return;
    end
     if (NO_OF_SLAVES != 1) begin
	`uvm_fatal(get_type_name(),"Multiple slaves not implemented yet");
     end
     else begin
	rw.kind = (apb.read_or_write == APB3_TRANS_WRITE) ? UVM_WRITE : UVM_READ;
	// We need to converte addrss
	rw.addr = apb.addr;
	if(apb.read_or_write == APB3_TRANS_WRITE)
	  begin
	     if(apb.strb == 4'b1111)
	       rw.data = apb.wr_data;
	     else 
	       `uvm_error("bus2reg","Strobe not set for all bytes");
	  end
	else
	  begin
	     rw.data = apb.rd_data;
	  end
	rw.status = UVM_IS_OK;
     end // else: !if(NO_OF_SLAVES != 1)
     

`uvm_info(get_type_name(), $sformatf("saw register access: %p",rw), UVM_MEDIUM);
  endfunction: bus2reg

endclass: reg2apb_adapter

   `include "apb3_reg_predictor.svh"

   

endpackage // apb3_uvm_reg_pkg
   