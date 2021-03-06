module top;
   import uvm_pkg::*;
   import uart_tb_pkg::*;
   
   sli_clk_reset_if i_clk_if();
   mgc_uart i_uart_if (1'bz, 1'bz, 1'bz, 1'bz, 1'bz, 1'bz);
   wb_if#(WB_AWIDTH,WB_DWIDTH) i_wb_if(.clk(i_clk_if.clk),.rstn(i_clk_if.nreset));
   assign i_wb_if.err = '0;
   assign i_wb_if.rty = '0;
   
   
 // Instantiate an interrupt handler (used to start ISR)
   simple_irq_if i_simple_irq_if(i_clk_if.clk,i_clk_if.nreset);



uart_top dut(
             .wb_clk_i(i_wb_if.clk), 
             // Wishbone signals
             .wb_rst_i(~i_wb_if.rstn), 
	     .wb_adr_i(i_wb_if.adr), 
	     .wb_dat_i(i_wb_if.dout), 
	     .wb_dat_o(i_wb_if.din), 
	     .wb_we_i (i_wb_if.we), 
	     .wb_stb_i(i_wb_if.stb), 
	     .wb_cyc_i(i_wb_if.cyc), 
	     .wb_ack_o(i_wb_if.ack), 
	     .wb_sel_i(i_wb_if.sel),
             .int_o(i_simple_irq_if.irq), // interrupt request
             // UART signals
             // serial input/output
             .stx_pad_o(i_uart_if.DAT[0]), 
	     .srx_pad_i(i_uart_if.DAT[1]),

             // modem signals
             .rts_pad_o(i_uart_if.RCTSn[0]), 
	     .cts_pad_i(i_uart_if.RCTSn[1]), 
	     .dtr_pad_o(i_uart_if.DTRn), 
	     .dsr_pad_i(i_uart_if.DSRn), 
	     .ri_pad_i(i_uart_if.RIn), 
	     .dcd_pad_i(i_uart_if.DCDn),
	     .baud_o(i_uart_if.iRCLK)
        );

   assign i_uart_if.iBAUDOUTn = ~i_uart_if.iRCLK;

   
   


   initial begin
      uvm_config_db #(virtual mgc_uart)::set( null , "*" , "UART_IF" , i_uart_if );
      uvm_config_db #(virtual sli_clk_reset_if)::set( null , "*" , "SLI_CLK_RESET_IF1" , i_clk_if );
      uvm_config_db #(virtual wb_if #(WB_AWIDTH,WB_DWIDTH))::set( null , "uvm_test_top" , "WB_IF" , i_wb_if);
      uvm_config_db #(virtual simple_irq_if)::set( null , "uvm_test_top" , "SIMPLE_IRQ_IF" , i_simple_irq_if);
      run_test();
   end
   


endmodule
