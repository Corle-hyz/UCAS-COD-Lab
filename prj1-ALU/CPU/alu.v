`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADD 3'b010
`define AND 3'b000
`define OR  3'b001
`define SUB 3'b110
`define SLT 3'b111
//in order to test if the report could be opened normally
module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUop,
	output Overflow,
	output CarryOut,
	output Zero,
	output [`DATA_WIDTH - 1:0] Result
);

wire op_add;
wire op_sub;
wire op_or;
wire op_and;
wire op_slt;
wire add_of;
wire sub_of;
wire cf;
//wire plus;
//wire sub_sign;

assign op_and = (!ALUop[2]) & (!ALUop[1]) & (!ALUop[0]);//000
assign op_or = (!ALUop[2]) & (!ALUop[1]) & (ALUop[0]);//001
assign op_add = (!ALUop[2]) & (ALUop[1]) & (!ALUop[0]);//010
assign op_sub = (ALUop[2]) & (ALUop[1]) & (!ALUop[0]);//110
assign op_slt = (ALUop[2]) & (ALUop[1]) & (ALUop[0]);//111

//wire [`DATA_WIDTH - 1:0] B_reverse;
//wire [`DATA_WIDTH - 1:0] and_res;
//wire [`DATA_WIDTH - 1:0] or_res;
//wire [`DATA_WIDTH - 1:0] slt_res;

wire [`DATA_WIDTH - 1:0] res;
//wire [`DATA_WIDTH - 1:0] cal_B;

//assign sub_sign = (op_slt | op_sub)?1:0;
//assign and_res = A & B;//and
//assign or_res = A | B;//or
assign {cf,res} = {0,A} + {0,ALUop[2]?~B:B} + ALUop[2];


//assign cal_B = (sub_sign)?~B:B;
//assign plus = (sub_sign)?32'b1:32'b0;
//assign {cf,res} = A + cal_B + plus;
assign add_of = (A[`DATA_WIDTH - 1]^!B[`DATA_WIDTH - 1])&(A[`DATA_WIDTH - 1]^res[`DATA_WIDTH - 1]);
assign sub_of = (A[`DATA_WIDTH - 1]^B[`DATA_WIDTH - 1])&(A[`DATA_WIDTH - 1]^res[`DATA_WIDTH - 1]);
//assign slt_res = res[`DATA_WIDTH - 1]^sub_of;

//assign {Overflow,CarryOut,Result} = op_add?{add_of,cf,res}:(op_and?{1'b0,1'b0,and_res}:(op_or?{1'b0,1'b0,or_res}:(op_slt?{1'b0,1'b0,slt_res}:{sub_of,!cf,res})));

assign Result = {32{op_and}}&{A&B} |
		{32{op_or }}&{A|B} |
		{32{op_add|op_sub}}&res |
		{32{op_slt}}&{res[`DATA_WIDTH - 1]^sub_of};
assign Zero = Result==0?1:0;//Big NOR
assign {Overflow,CarryOut} = (op_add)?{add_of,cf}:{sub_of,!cf};


endmodule
