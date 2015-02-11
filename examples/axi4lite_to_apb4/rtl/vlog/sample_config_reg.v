
// Name: sample_conf
// Description: Sample Config Register 
// Address space is: C0F16000 with offset xB60
// inital value if 0
// Read/Write
// bits [31:16]   ctrl 
// 31  sample waddr normal data
// 30  sample waddr normal instr
// 29  sample waddr privileged data
// 28  sample waddr privileged instr
// 27  sample wdata normal data
// 26  sample wdata normal instr
// 25  sample wdata privileged data
// 24  sample wdata privileged instr
// 23  sample raddr normal data
// 22  sample raddr normal instr
// 21  sample raddr privileged data
// 20  sample raddr privileged instr
// 19  sample rdata normal data
// 18  sample rdata normal instr
// 17  sample rdata privileged data
// 16  sample rdata privileged instr

module sample_config_reg(input clk,
			 input rstn,
			 input write,
			 input [31:0] wdata,
			 output [31:0] rdata,
			 output reg [15:0] sample_conf_ctrl			 
			 );
   // create internal signals that make register easily debuggable

   // waddr
   wire 			      waddr_nd;
   wire 			      waddr_ni;
   wire 			      waddr_pd;
   wire 			      waddr_pi;

   // wdata
   wire 			      wdata_nd;
   wire 			      wdata_ni;
   wire 			      wdata_pd;
   wire 			      wdata_pi;

   // raddr
   wire 			      raddr_nd;
   wire 			      raddr_ni;
   wire 			      raddr_pd;
   wire 			      raddr_pi;

   // rdata
   wire 			      rdata_nd;
   wire 			      rdata_ni;
   wire 			      rdata_pd;
   wire 			      rdata_pi;

// Assigns

   assign 			      waddr_nd = sample_conf_ctrl[15];
   assign 			      waddr_ni = sample_conf_ctrl[14];
   assign 			      waddr_pd = sample_conf_ctrl[13];
   assign 			      waddr_pi = sample_conf_ctrl[12];
   assign 			      wdata_nd = sample_conf_ctrl[11];
   assign 			      wdata_ni = sample_conf_ctrl[10];
   assign 			      wdata_pd = sample_conf_ctrl[9];
   assign 			      wdata_pi = sample_conf_ctrl[8];
   assign 			      raddr_nd = sample_conf_ctrl[7];
   assign 			      raddr_ni = sample_conf_ctrl[6];
   assign 			      raddr_pd = sample_conf_ctrl[5];
   assign 			      raddr_pi = sample_conf_ctrl[4];
   assign 			      rdata_nd = sample_conf_ctrl[3];
   assign 			      rdata_ni = sample_conf_ctrl[2];
   assign 			      rdata_pd = sample_conf_ctrl[1];
   assign 			      rdata_pi = sample_conf_ctrl[0];

   
 assign rdata= {sample_conf_ctrl,16'h0000};
   
   

   always @(posedge clk  or negedge rstn)
     if (!rstn)
       sample_conf_ctrl <= 16'h0000;
     else
       if (write)
         sample_conf_ctrl <= wdata[31:16];
       else
         sample_conf_ctrl <= sample_conf_ctrl;
   



   
   
endmodule // sample_config_reg




