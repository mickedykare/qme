package i2c_tb_pkg;
   import uvm_pkg::*;
   import wb_pkg::*; 
   import i2c_master_uvm_reg::*;
   import simple_irq_pkg::*;
   import sli_clk_reset_pkg::*;
   
   import mvc_pkg::*;
   import mgc_i2c_v2_1_pkg::*;

 
 `include "uvm_macros.svh"
 
 parameter WB_AWIDTH=32;
 parameter WB_DWIDTH=8;
 
 //Some useful settings for I2C 
 parameter NUMBER_OF_I2C_SLAVES=2;
 parameter SLAVE_ADDRESS1       = 7'b001_0000;   
 parameter SLAVE_ADDRESS2       = 7'b010_0000;   
 parameter SLAVE_ADDR_TYPE      = 1;  // 0: 10 bit slave address ; 1: 7 bit slave address

// Some stuff to be able to compare with original test bench
   
   parameter RD      = 1'b1;
   parameter WR      = 1'b0;
   parameter SADR    = 7'b001_0000;

   
 `include "i2c_tb_env.svh"
// Sequences
 `include "i2c_wb_base_seq.svh"
 `include "i2c_wb_orig_seq.svh"
 `include "i2c_wb_setup_seq.svh"

// Tests   
`include "i2c_base_test.svh" 
`include "i2c_orig_test.svh" 


endpackage