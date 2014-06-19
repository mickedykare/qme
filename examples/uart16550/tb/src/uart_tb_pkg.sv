package uart_tb_pkg;
   import uvm_pkg::*;
   import mgc_uart_v1_0_pkg::*;
   import mvc_pkg::*;
   import wb_pkg::*;
   import sli_clk_reset_pkg::*;
   import simple_irq_pkg::*;
   import uart1650_registers_pkg::*;
   
   
   parameter WB_AWIDTH=4;
   parameter WB_DWIDTH=8;
   
   
`include "uart_16550_tb_env.svh"
`include "uart_base_test.svh"
`include "uart_wb_base_seq.svh"
`include "uart_config_seq.svh"
`include "qvip_uart_base_seq.svh"
`include "qvip_uart_slave_seq.svh"

`include "uart_tx_seq.svh"
`include "uart_orig_test.svh"
   

endpackage // uart_tb_pkg
   