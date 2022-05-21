`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADD  4'b0010
`define AND  4'b0000
`define OR   4'b0001
`define SUB  4'b1010
`define SLT  4'b1011
`define SL   4'b0100
`define SRL  4'b0110
`define SRA  4'b0111
`define XOR  4'b0101
`define NOR  4'b0011
`define SLTU 4'b1111

module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [3:0] ALUop,
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
	wire op_sl;
	wire op_srl;
	wire op_sra;
	wire op_xor;
	wire op_nor;
	wire op_sltu;
	wire add_of;
	wire sub_of;
	wire cf;
	wire [`DATA_WIDTH - 1:0] res;
assign op_and = !ALUop[3] & !ALUop[2] & !ALUop[1] & !ALUop[0];//0000
assign op_or  = !ALUop[3] & !ALUop[2] & !ALUop[1] &  ALUop[0];//0001
assign op_add = !ALUop[3] & !ALUop[2] &  ALUop[1] & !ALUop[0];//0010
assign op_sub =  ALUop[3] & !ALUop[2] &  ALUop[1] & !ALUop[0];//1010
assign op_slt =  ALUop[3] & !ALUop[2] &  ALUop[1] &  ALUop[0];//1011
assign op_sl  = !ALUop[3] &  ALUop[2] & !ALUop[1] & !ALUop[0];//0100
assign op_srl = !ALUop[3] &  ALUop[2] &  ALUop[1] & !ALUop[0];//0100
assign op_sra = !ALUop[3] &  ALUop[2] &  ALUop[1] &  ALUop[0];//0111
assign op_xor = !ALUop[3] &  ALUop[2] & !ALUop[1] &  ALUop[0];//0101
assign op_nor = !ALUop[3] & !ALUop[2] &  ALUop[1] &  ALUop[0];//0011
assign op_sltu=  ALUop[3] &  ALUop[2] &  ALUop[1] &  ALUop[0];//1111

assign {cf,res} = A + (ALUop[3]?~B:B) + ALUop[3];
assign add_of = (A[`DATA_WIDTH - 1]^!B[`DATA_WIDTH - 1])&(A[`DATA_WIDTH - 1]^res[`DATA_WIDTH - 1]);
assign sub_of = (A[`DATA_WIDTH - 1]^ B[`DATA_WIDTH - 1])&(A[`DATA_WIDTH - 1]^res[`DATA_WIDTH - 1]);
assign Result = {32{op_and}}	&	{A&B}	|
				{32{op_or }}	&	{A|B} 	|
				{32{op_add|op_sub}}		&	res 	|
				{32{op_slt}}	&	{res[`DATA_WIDTH - 1]^sub_of} | 
				{32{op_srl}}	&	{A>>B} | 
				{32{op_sl}}		&	{A<<B} | 
				{32{op_sra}}	&	{({{32{A[31]}},A}>>B)} |
				{32{op_xor}}	&	(A^B)	|
				{32{op_nor}}	&	(~(A|B))	|
				{31'b0,op_sltu}	&	{(A[`DATA_WIDTH - 1]^B[`DATA_WIDTH - 1])?(1'b1^(res[`DATA_WIDTH - 1]^sub_of)):(res[`DATA_WIDTH - 1]^sub_of)};
assign Zero = Result==0?1:0;//Big NOR
assign {Overflow,CarryOut} = (op_add)?{add_of,cf}:{sub_of,!cf};


endmodule
