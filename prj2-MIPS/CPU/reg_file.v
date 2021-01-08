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
endmodule
