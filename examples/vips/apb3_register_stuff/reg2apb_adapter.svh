/*****************************************************************************
 *
 * Copyright 2007-2013 Mentor Graphics Corporation
 * All Rights Reserved.
 *
 * THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE
 * PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT
 * TO LICENSE TERMS.
 *
 *****************************************************************************/

//---------------------------------------------------------------
// CLASS: reg2apb_adapter
//
// This is the adapter used for APB interface.
// This converts the reg items to APB bus specific items and 
// vice-versa.
//
//---------------------------------------------------------------
class reg2apb_adapter #(type T = int, int SLAVE_COUNT = 1 , int ADDRESS_WIDTH = 32 ,
                        int WDATA_WIDTH = 32 , int RDATA_WIDTH = 32 ) extends uvm_reg_adapter;

   typedef reg2apb_adapter #(T, SLAVE_COUNT, ADDRESS_WIDTH, WDATA_WIDTH, RDATA_WIDTH) this_t; 

  `uvm_object_param_utils(this_t)

   function new(string name = "reg2apb_adapter");
      mvc_sequence base_seq;
//      mvc_sequence_item tmp;
      

      super.new(name);
      supports_byte_enable = 0;
      provides_responses = 0;

      base_seq = new;
      parent_sequence = base_seq;
   endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
     T apb = T::type_id::create("apb");

     uvm_reg_item       item = get_item();
     uvm_sequencer_base seqr = item.map.get_sequencer();

     
    apb.set_sequencer(seqr);

     
    if (rw.kind == UVM_WRITE) begin
      if (!apb.randomize() with {apb.slave_id         == (SLAVE_COUNT - 1);
                                 apb.addr             == rw.addr;
                                 apb.prot             == 3'b000;
                                 apb.read_or_write    == APB3_TRANS_WRITE;
                                 apb.wr_data          == rw.data;
                                 apb.strb             == 1'b1;} )
        `uvm_fatal("reg2bus","bad constraints in UVM_WRITE");
    end else begin
      if (!apb.randomize() with {apb.slave_id         == (SLAVE_COUNT - 1);
                                 apb.addr             == rw.addr;
                                 apb.prot             == 3'b000;
                                 apb.read_or_write    == APB3_TRANS_READ;
                                 apb.strb             == 4'b0000;} )
        `uvm_fatal("reg2bus","bad constraints in UVM_READ");
    end

    `uvm_info("reg2bus",$sformatf("do register access: %p",rw),UVM_HIGH);
     
    return apb;
  endfunction: reg2bus

  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    T apb;

    if (!$cast(apb, bus_item))
    begin
      `uvm_fatal("NOT_APB_TYPE","Provided bus_item is not of the correct type")
      return;
    end

    rw.kind = (apb.read_or_write == APB3_TRANS_WRITE) ? UVM_WRITE : UVM_READ;
    rw.addr = apb.addr;
    if(apb.read_or_write == APB3_TRANS_WRITE)
    begin
/* -----\/----- EXCLUDED -----\/-----
      if(apb.strb == '1)
  We are not using strobes for this case.
  -----/\----- EXCLUDED -----/\----- */
       rw.data = apb.wr_data;
/* -----\/----- EXCLUDED -----\/-----
      else 
       `uvm_error("bus2reg","Strobe not set for all bytes");
 -----/\----- EXCLUDED -----/\----- */
    end
    else
    begin
      rw.data = apb.rd_data;
    end
    rw.status = UVM_IS_OK;
    `uvm_info("bus2reg", $sformatf("saw register access: %p",rw), UVM_HIGH);
  endfunction: bus2reg

endclass: reg2apb_adapter

