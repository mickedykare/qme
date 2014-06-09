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

class apb3_reg_predictor #(int SLAVE_COUNT = 1, int ADDRESS_WIDTH = 32, int DATA_WIDTH = 32 ) extends uvm_reg_predictor #(mvc_sequence_item_base);

   typedef apb3_reg_predictor #(SLAVE_COUNT, ADDRESS_WIDTH, DATA_WIDTH) this_t;

      typedef apb3_host_apb3_transaction #( 1 ,
                                         ADDRESS_WIDTH ,
                                         DATA_WIDTH ,
                                         DATA_WIDTH ) apb3_transaction_t;


  `uvm_component_param_utils(this_t)

  uvm_analysis_imp #(mvc_sequence_item_base,this_t) bus_item_export;

  // Function: new
  //
  // Create a new instance of this type, giving it the optional ~name~
  // and ~parent~.
  //
  function new (string name, uvm_component parent);
    super.new(name, parent);
    bus_item_export = new("bus_item_export", this);
  endfunction

  // Function: pre_predict
  //
  // Override this method to change the value or re-direct the
  // target register
  //
  function void pre_predict(uvm_reg_item rw);
  endfunction

  uvm_predict_s m_pending_reg_tr[uvm_reg];

  // Function- write
  //
  // not a user-level method. Do not call directly. See documentation
  // for the ~bus_item_export~ member.
  //
  function void write(mvc_sequence_item_base tr);
    uvm_reg rg;

    apb3_transaction_t apb_trans;

    if (!$cast(apb_trans, tr)) begin
      `uvm_fatal("NOT_APB_TYPE","Provided bus_item is not of the correct type")
      return;
    end

      super.write(apb_trans);
  endfunction

endclass

