`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5
`define REG_NUM 32
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
	end else begin
		REG_FILE[0] <= REG_FILE[0];
	end
end

always @(posedge clk) begin
	if(!rst && wen && (waddr!=5'b0)) begin
		REG_FILE[waddr] <= wdata;
	end else begin
		REG_FILE[waddr] <= REG_FILE[waddr];
	end
end



/*
always @(posedge clk) begin
	if(rst) begin
		REG_FILE[0] <= 32'b0;
	
		REG_FILE[1] <= 32'b0;
		REG_FILE[2] <= 32'b0;
		REG_FILE[3] <= 32'b0;
		REG_FILE[4] <= 32'b0;
		REG_FILE[5] <= 32'b0;
		REG_FILE[6] <= 32'b0;
		REG_FILE[7] <= 32'b0;
		REG_FILE[8] <= 32'b0;
		REG_FILE[9] <= 32'b0;
		REG_FILE[10] <= 32'b0;
		REG_FILE[11] <= 32'b0;
		REG_FILE[12] <= 32'b0;
		REG_FILE[13] <= 32'b0;
		REG_FILE[14] <= 32'b0;
		REG_FILE[15] <= 32'b0;
		REG_FILE[16] <= 32'b0;
		REG_FILE[17] <= 32'b0;
		REG_FILE[18] <= 32'b0;
		REG_FILE[19] <= 32'b0;
		REG_FILE[20] <= 32'b0;
		REG_FILE[21] <= 32'b0;
		REG_FILE[22] <= 32'b0;
		REG_FILE[23] <= 32'b0;
		REG_FILE[24] <= 32'b0;
		REG_FILE[25] <= 32'b0;
		REG_FILE[26] <= 32'b0;
		REG_FILE[27] <= 32'b0;
		REG_FILE[28] <= 32'b0;
		REG_FILE[29] <= 32'b0;
		REG_FILE[30] <= 32'b0;
		REG_FILE[31] <= 32'b0;
		
	end else begin
		REG_FILE[0] <= REG_FILE[0];
		
		REG_FILE[1] <= REG_FILE[1];
		REG_FILE[2] <= REG_FILE[2];
		REG_FILE[3] <= REG_FILE[3];
		REG_FILE[4] <= REG_FILE[4];
		REG_FILE[5] <= REG_FILE[5];
		REG_FILE[6] <= REG_FILE[6];
		REG_FILE[7] <= REG_FILE[7];
		REG_FILE[8] <= REG_FILE[8];
		REG_FILE[9] <= REG_FILE[9];
		REG_FILE[10] <= REG_FILE[10];
		REG_FILE[11] <= REG_FILE[11];
		REG_FILE[12] <= REG_FILE[12];
		REG_FILE[13] <= REG_FILE[13];
		REG_FILE[14] <= REG_FILE[14];
		REG_FILE[15] <= REG_FILE[15];
		REG_FILE[16] <= REG_FILE[16];
		REG_FILE[17] <= REG_FILE[17];
		REG_FILE[18] <= REG_FILE[18];
		REG_FILE[19] <= REG_FILE[19];
		REG_FILE[20] <= REG_FILE[20];
		REG_FILE[21] <= REG_FILE[21];
		REG_FILE[22] <= REG_FILE[22];
		REG_FILE[23] <= REG_FILE[23];
		REG_FILE[24] <= REG_FILE[24];
		REG_FILE[25] <= REG_FILE[25];
		REG_FILE[26] <= REG_FILE[26];
		REG_FILE[27] <= REG_FILE[27];
		REG_FILE[28] <= REG_FILE[28];
		REG_FILE[29] <= REG_FILE[29];
		REG_FILE[30] <= REG_FILE[30];
		REG_FILE[31] <= REG_FILE[31];
		
	end
	if(wen && !rst && (waddr!=5'b0)) begin
		REG_FILE[waddr] <= wdata;
	end else begin
		REG_FILE[waddr] <= REG_FILE[waddr];
	end
end
*/
assign rdata1 = (raddr1==5'b0)?32'b0:REG_FILE[raddr1];
assign rdata2 = (raddr2==5'b0)?32'b0:REG_FILE[raddr2];
endmodule
