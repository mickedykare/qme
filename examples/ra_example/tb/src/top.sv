module top;
   import uvm_pkg::*;
   import ra_example_tb_pkg::*;
   
   sli_clk_reset_if i_clk_reset_if();
   mgc_apb3#(1,3,8,8)i_apb3_if(i_clk_reset_if.clk,i_clk_reset_if.nreset);

   ra_example#(3,8) dut(
		       // FIELD OUTPUT PORTS
		       .LDOA_mask_SYSPOR_DBB_RST_N_MASK1    (),
		       .LDOB_mask_SYSPOR_DBB_RST_N_MASK1    (),
		       .LDOC_mask_SYSPOR_DBB_RST_N_MASK1    (),
		       .LDOF_mask_SYSPOR_DBB_RST_N_MASK1    (),
		       .LDOG_mask_SYSPOR_DBB_RST_N_MASK1    (),
		       .LDOH_mask_SYSPOR_DBB_RST_N_MASK1    (),
		       .spare_SYSPOR_DBB_RST_N_MASK1        (),
		       .LDOT_mask_SYSPOR_DBB_RST_N_MASK1    (),
		       .LDOM_mask_SYSPOR_DBB_RST_N_MASK2    (),
		       .LDOS_mask_SYSPOR_DBB_RST_N_MASK2    (),
		       .EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2 (),
		       .spare_SYSPOR_DBB_RST_N_MASK2        (),
		       .BUCK2_mask_SYSPOR_DBB_RST_N_MASK2   (),
		       .BUCK4_mask_SYSPOR_DBB_RST_N_MASK2   (),
		       .BUCK1_mask_SYSPOR_DBB_RST_N_MASK2   (),
		       .LDOP_mask_SYSPOR_DBB_RST_N_MASK2    (),
		       .BUCK5_mask_SYSPOR_DBB_RST_N_MASK3   (),
		       .spare_SYSPOR_DBB_RST_N_MASK3        (),
		       .spare_SYSPOR_DBB_RST_N_MASK4        (),
		       .rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4(),

		       // INPUT PORTS
		       .LDOA_mask_SYSPOR_DBB_RST_N_MASK1_ip    ('1),
		       .LDOB_mask_SYSPOR_DBB_RST_N_MASK1_ip    ('1),
		       .LDOC_mask_SYSPOR_DBB_RST_N_MASK1_ip    ('1),
		       .LDOF_mask_SYSPOR_DBB_RST_N_MASK1_ip    ('1),
		       .LDOG_mask_SYSPOR_DBB_RST_N_MASK1_ip    ('1),
		       .LDOH_mask_SYSPOR_DBB_RST_N_MASK1_ip    ('1),
		       .spare_SYSPOR_DBB_RST_N_MASK1_ip        ('1),
		       .LDOT_mask_SYSPOR_DBB_RST_N_MASK1_ip    ('1),
		       .LDOM_mask_SYSPOR_DBB_RST_N_MASK2_ip    ('1),
		       .LDOS_mask_SYSPOR_DBB_RST_N_MASK2_ip    ('1),
		       .EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2_ip ('1),
		       .spare_SYSPOR_DBB_RST_N_MASK2_ip        ('1),
		       .BUCK2_mask_SYSPOR_DBB_RST_N_MASK2_ip   ('1),
		       .BUCK4_mask_SYSPOR_DBB_RST_N_MASK2_ip   ('1),
		       .BUCK1_mask_SYSPOR_DBB_RST_N_MASK2_ip   ('1),
		       .LDOP_mask_SYSPOR_DBB_RST_N_MASK2_ip    ('1),
		       .BUCK5_mask_SYSPOR_DBB_RST_N_MASK3_ip   ('1),
		       .spare_SYSPOR_DBB_RST_N_MASK3_ip        ('1),
		       .spare_SYSPOR_DBB_RST_N_MASK4_ip        ('1),
		       .rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4_ip('1),

		       // apb3 example
			.pclk(i_apb3_if.PCLK),
			.presetn(i_apb3_if.PRESETn),
			.paddr(i_apb3_if.PADDR),
			.psel(i_apb3_if.PSEL),
			.penable(i_apb3_if.PENABLE),
			.pwrite(i_apb3_if.PWRITE),
			.pwdata(i_apb3_if.PWDATA),
			.pstrb(i_apb3_if.PSTRB),
			.pprot(i_apb3_if.PPROT),
			.prdata(i_apb3_if.PRDATA),
			.pready(i_apb3_if.PREADY),
			.pslverr(i_apb3_if.PSLVERR)
		       );

   initial begin
      uvm_config_db #(virtual mgc_apb3#(1,3,8,8))::set( null , "*" , "APB3_IF" , i_apb3_if );
      uvm_config_db #(virtual sli_clk_reset_if)::set( null , "*" , "SLI_CLK_RESET_IF" , i_clk_reset_if );
      run_test();
   end
   


endmodule
