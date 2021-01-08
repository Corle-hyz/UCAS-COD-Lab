`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5
`define REG_NUM 31
module reg_file(
	input clk,
	input rst,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output [`DATA_WIDTH - 1:0] rdata1,
	output [`DATA_WIDTH - 1:0] rdata2
);

reg [`DATA_WIDTH-1:0] REG_FILE [`REG_NUM-1:0];
//integer i=0;
/*initial begin
//	for(i=0;i<`DATA_WIDTH;i=i+1)
	REG_FILE[00] = 32'b0;	REG_FILE[01] = 32'b0;	REG_FILE[02] = 32'b0;	REG_FILE[03] = 32'b0;	REG_FILE[04] = 32'b0;	REG_FILE[05] = 32'b0;	REG_FILE[06] = 32'b0;	REG_FILE[07] = 32'b0;
	REG_FILE[08] = 32'b0;	REG_FILE[09] = 32'b0;	REG_FILE[10] = 32'b0;	REG_FILE[11] = 32'b0;	REG_FILE[12] = 32'b0;	REG_FILE[13] = 32'b0;	REG_FILE[14] = 32'b0;	REG_FILE[15] = 32'b0;
	REG_FILE[16] = 32'b0;	REG_FILE[17] = 32'b0;	REG_FILE[18] = 32'b0;	REG_FILE[19] = 32'b0;	REG_FILE[20] = 32'b0;	REG_FILE[21] = 32'b0;	REG_FILE[22] = 32'b0;	REG_FILE[23] = 32'b0;
	REG_FILE[24] = 32'b0;	REG_FILE[25] = 32'b0;	REG_FILE[26] = 32'b0;	REG_FILE[27] = 32'b0;	REG_FILE[28] = 32'b0;	REG_FILE[29] = 32'b0;	REG_FILE[30] = 32'b0;	REG_FILE[31] = 32'b0;
end
*/
always @(posedge clk) begin
	if(rst) begin
		REG_FILE[0] <= 32'b0;
	end
	if(wen && !rst && (waddr!=5'b0)) begin
		REG_FILE[~waddr] <= wdata;
	end
end

assign rdata1 = (raddr1==5'b0)?32'b0:REG_FILE[~raddr1];
assign rdata2 = (raddr2==5'b0)?32'b0:REG_FILE[~raddr2];

	// TODO: Please add your logic code here

endmodule
