// This package describes the parts used for uvm reg package with apb3


package apb3_uvm_reg_pkg;
   import uvm_pkg::*;
   import mvc_pkg::*;
   import mgc_apb3_v1_0_pkg::*;        
`include "uvm_macros.svh"

   // Pick these up from Questa VIP apb3 ex 9
   `include "reg2apb_adapter.svh"
   `include "apb_reg_predictor.svh"

   

endpackage // apb3_uvm_reg_pkg
   