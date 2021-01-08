`timescale 10ns / 1ns
`include "macro.v"

module mips_cpu(
	input  rst,
	input  clk,

	//Instruction request channel
	output reg[31:0] PC,
	output Inst_Req_Valid,
	input Inst_Req_Ack,

	//Instruction response channel
	input  [31:0] Instruction,
	input Inst_Valid,
	output Inst_Ack,

	//Memory request channel
	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,
	output MemRead,
	input Mem_Req_Ack,

	//Memory data response channel
	input  [31:0] Read_data,
	input Read_data_Valid,
	output Read_data_Ack,

    output [31:0]	mips_perf_cnt_0,
    output [31:0]	mips_perf_cnt_1,
    output [31:0]	mips_perf_cnt_2,
    output [31:0]	mips_perf_cnt_3,
    output [31:0]	mips_perf_cnt_4,
    output [31:0]	mips_perf_cnt_5,
    output [31:0]	mips_perf_cnt_6,
    output [31:0]	mips_perf_cnt_7,
    output [31:0]	mips_perf_cnt_8,
    output [31:0]	mips_perf_cnt_9,
    output [31:0]	mips_perf_cnt_10,
    output [31:0]	mips_perf_cnt_11,
    output [31:0]	mips_perf_cnt_12,
    output [31:0]	mips_perf_cnt_13,
    output [31:0]	mips_perf_cnt_14,
    output [31:0]	mips_perf_cnt_15
);


	wire			RF_wen;
	wire [4:0]		RF_waddr;
	wire [31:0]		RF_wdata;
	// Control Signals, in order to control the data and path
	wire RegDst;
	wire Jump;
	wire Branch;// to determine whether the instruction is the class of BRANCH
	wire MemtoReg;
	wire ALUsrc;
	wire Zero;
	wire [3:0] ALU_control;
	wire Branch_eff;// to determine whether we really need to branch

	// Mid Signals, in order to store the mid value of the main variables
	wire [31:0]PC_4;// to store the value of PC+4
	wire [31:0] branch_PC;// to store the value of the value of PC after branch operation
	wire [31:0] RF_rdata1;
	wire [31:0] RF_rdata2;
	wire [4:0] RF_raddr1;
	wire [4:0] RF_raddr2;
	wire [31:0] ALU_N2;// the number that we really need to send to ALU and do the calculation
	wire [31:0] ALU_result;
	wire [5:0] opcode;// high 6 bits
	wire [5:0] func;// low 6 bits
	wire [31:0] extend;// the result of extension after select all kinds of extension of different operations
	wire [31:0] shift_num;// the result after shift
	wire [3:0] sw_strb;// strb signals in different operations
	wire [3:0] sb_strb;
	wire [3:0] sh_strb;
	wire [3:0] swl_strb;
	wire [3:0] swr_strb;
	wire [31:0] sb_result;// the result of data selection according to different opertions
	wire [31:0] sh_result;
	wire [31:0] sw_result;
	wire [31:0] swl_result;
	wire [31:0] swr_result;
	wire [1:0] byte;// to decide to data selection of LOAD operation
	wire [7:0] load_byte_data;
	wire [15:0] load_half_data;
	wire [31:0] lwl_data;
	wire [31:0] lwr_data;
	wire [31:0] sign_extend;
	wire [31:0] zero_extend;
	wire [31:0] lui_extend;// special extend of LUI
	wire [31:0] sltiu_extend;// special extend of SLTIU
	wire [31:0] shift_sign_extend;// shift left 2 bits and then make a signed extension
	wire [31:0] JumpAddress;
	wire [31:0] temp;
	wire [3:0] store_byte;
	wire [4:0] rs;// register, the position is defined by Instruction[25:21]
	wire [4:0] rt;// register, the position is defined by Instruction[20:16]
	wire [4:0] rd;// register, the position is defined by Instruction[15:11]

	//hand_shaking
	reg [31:0] valid_Instruction;
	reg [31:0] valid_Read_data;
	// To describe the state of FSM
	// use one-hot code
	parameter IF  = 9'b0_0000_0001;
	parameter IW  = 9'b0_0000_0010;
	parameter ID  = 9'b0_0000_0100;
	parameter EX  = 9'b0_0000_1000;
	parameter LD  = 9'b0_0001_0000;
	parameter ST  = 9'b0_0010_0000;
	parameter WB  = 9'b0_0100_0000;
	parameter RDW = 9'b0_1000_0000;
	parameter RSTSTATE = 9'b1_0000_0000;
	reg [8:0] state;
	reg [8:0] next_state;
	reg [31:0] originPC;

always @(posedge clk) begin
	if(rst) begin
		state <= RSTSTATE;
	end else begin
		state <= next_state;
	end
end

always @(posedge clk) begin
	if(rst) begin
		PC <= 32'b0;
	end else if(state==EX) begin
		PC <= Jump ? JumpAddress:((Branch&Branch_eff)?branch_PC:PC_4);
	end else begin
		PC <= PC;
	end
end

always @(posedge clk) begin
	if(state==IF) begin
		originPC <= PC;
	end else begin
		originPC <= originPC;
	end
end


always @(*) begin
	case(state)
		RSTSTATE: next_state = IF;
		IF: if(Inst_Req_Ack) begin
				next_state = IW;
			end else begin
				next_state = IF;
			end
		IW: if(Inst_Valid) begin
				next_state = ID;
			end else begin
				next_state = IW;
			end
		ID: next_state = EX;
		EX: case(opcode)
				`REGIMM: if(func[4:1]==`BRANCH_Z) begin
								next_state = IF;
						 end else begin
								next_state = WB;
						 end
				default: if(opcode[5:2]==`BRANCH || opcode[5:1]==`JUMP) begin
								next_state = IF;
						 end else if(opcode[5:3]==`LOAD) begin
						 		next_state = LD;
						 end else if(opcode[5:3]==`STORE) begin
						 		next_state = ST;
						 end else begin
						 		next_state = WB;
						 end		
			endcase
		LD: if(Mem_Req_Ack) begin
				next_state = RDW;
			end else begin
				next_state = LD;
			end
		ST: if(Mem_Req_Ack) begin
				next_state = IF;
			end else begin
				next_state = ST;
			end
		WB: next_state = IF;
		RDW: if(Read_data_Valid) begin
				next_state = WB;
			end else begin
				next_state = RDW;
			end
		default: next_state = state;
	endcase
end

// The number of clock cycle
reg [31:0] Cycle_cnt;
always @(posedge clk) begin
	if(rst) begin
		Cycle_cnt <= 32'b0;
	end else begin
		Cycle_cnt <= Cycle_cnt + 31'b1;
	end
end
assign mips_perf_cnt_0 = Cycle_cnt;

// The number of obtained instruction
reg [31:0] Inst_cnt;
always @(posedge clk) begin
	if(rst) begin
		Inst_cnt <= 32'b0;
	end else if(state == IF) begin
		Inst_cnt <= Inst_cnt + 31'b1;
	end else begin
		Inst_cnt <= Inst_cnt;
	end
end
assign mips_perf_cnt_1 = Inst_cnt;

// The number of Visiting Memory
reg [31:0] Memory_cnt;
always @(posedge clk) begin
	if(rst) begin
		Memory_cnt <= 32'b0;
	end else if((state == LD || state == ST) && Mem_Req_Ack) begin
		Memory_cnt <= Memory_cnt + 31'b1;
	end else begin
		Memory_cnt <= Memory_cnt;
	end
end
assign mips_perf_cnt_2 = Memory_cnt;

// The delay time of Visiting Memory Stage
reg [31:0] Delay_cnt;
always @(posedge clk) begin
	if(rst) begin
		Delay_cnt <= 32'b0;
	end else if(((state==LD || state==ST) && !Mem_Req_Ack) || (state==RDW && !Read_data_Valid)) begin
		Delay_cnt <= Delay_cnt + 31'b1;
	end else begin
		Delay_cnt <= Delay_cnt;
	end
end
assign mips_perf_cnt_3 = Delay_cnt;

// The number of really branch while the branch instruction
reg [31:0] Branch_cnt;
always @(posedge clk) begin
	if(rst) begin
		Branch_cnt <= 32'b0;
	end else if(state==EX && Branch && Branch_eff) begin
		Branch_cnt <= Branch_cnt + 31'b1;
	end else begin
		Branch_cnt <= Branch_cnt;
	end
end
assign mips_perf_cnt_4 = Branch_cnt;

// The number of NOT really branch while the branch instruction
reg [31:0] nBranch_cnt;
always @(posedge clk) begin
	if(rst) begin
		nBranch_cnt <= 32'b0;
	end else if(state==EX && Branch && !Branch_eff) begin
		nBranch_cnt <= nBranch_cnt + 31'b1;
	end else begin
		nBranch_cnt <= nBranch_cnt;
	end
end
assign mips_perf_cnt_5 = nBranch_cnt;

always @(posedge clk) begin
	valid_Instruction <= (Inst_Ack && Inst_Valid)? Instruction : valid_Instruction;
end

always @(posedge clk) begin
	valid_Read_data <= (Read_data_Valid && Read_data_Ack)? Read_data : valid_Read_data;
end

assign Inst_Ack = (state==RSTSTATE || state==IW)?1:0;
assign Inst_Req_Valid = (state == IF)?1:0;
assign MemRead = (state == LD)?1:0;
assign MemWrite = (state == ST)?1:0;
assign Read_data_Ack = (state == RDW)?1:0;
assign rs = valid_Instruction[25:21];
assign rt = valid_Instruction[20:16];
assign rd = valid_Instruction[15:11];
assign opcode = valid_Instruction[31:26];
assign func = valid_Instruction[5:0];
assign RegDst = (opcode[5:3]==`CALCU_I||opcode[5:3]==`LOAD)?0:1;
assign Jump = (opcode[5:1]==`JUMP || (opcode==`SPECIAL&&func[5:1]==`JUMP_R)) ?1:0;
assign Branch = (opcode[5:2]==`BRANCH || (opcode==`REGIMM && rt[4:1]==`BRANCH_Z))?1:0;
assign MemtoReg = (opcode[5:3]==`LOAD)?1:0;
assign RF_wen = (opcode[5:3]==`STORE || opcode==`J || opcode[5:2]==`BRANCH || (opcode==`REGIMM && rt[4:1]==`BRANCH_Z) || 
				(opcode==`SPECIAL && (func==`JR||func==`MOVZ&&(!Zero)||func==`MOVN&&Zero)))?0:(((state==WB && opcode!=`JR) || (opcode==`JAL && state==EX))?1:0);
assign RF_waddr = (opcode==`JAL)?31 : ((RegDst)?rd:rt);
assign RF_wdata = (opcode==`SPECIAL && (func==`MOVZ && Zero || func==`MOVN && (!Zero)))?RF_rdata1:
					((opcode==`JAL || (opcode==`SPECIAL&&func==`JALR))?originPC+8:
					((opcode==`LUI)?lui_extend:((MemtoReg)?
					((opcode==`LB)?(load_byte_data[7]?{{24{1'b1}},load_byte_data}:{{24{1'b0}},load_byte_data}):
					((opcode==`LH)?(load_half_data[15]?{{16{1'b1}},load_half_data}:{{16{1'b0}},load_half_data}) :
					((opcode==`LBU)?{{24{1'b0}},load_byte_data}:
					((opcode==`LHU)?{{16{1'b0}},load_half_data}:
					((opcode==`LWL)?lwl_data:
					((opcode==`LWR)?lwr_data:valid_Read_data)))))):ALU_result)));
assign byte = ALU_result[1:0];
assign load_byte_data = (byte[1]&byte[0])?valid_Read_data[31:24]:
						((byte[1]&!byte[0])?valid_Read_data[23:16]:
						((!byte[1]&byte[0])?valid_Read_data[15:8]:valid_Read_data[7:0]));
assign load_half_data = (!byte[1]&!byte[0])?valid_Read_data[15:0]:valid_Read_data[31:16];
assign lwl_data = (byte[1]&byte[0])?valid_Read_data[31:0]:
					((byte[1]&!byte[0])?{valid_Read_data[23:0],RF_rdata2[7:0]}:
					((!byte[1]&byte[0])?{valid_Read_data[15:0],RF_rdata2[15:0]}:
					{valid_Read_data[7:0],RF_rdata2[23:0]}));
assign lwr_data = (!byte[1]&!byte[0])?valid_Read_data[31:0]:
					((!byte[1]&byte[0])?{RF_rdata2[31:24],valid_Read_data[31:8]}:
					((byte[1]&!byte[0])?{RF_rdata2[31:16],valid_Read_data[31:16]}:
					{RF_rdata2[31:8],valid_Read_data[31:24]}));
assign RF_raddr1 = rs;
assign RF_raddr2 = rt;
assign ALU_control = (opcode[5:3]==`LOAD||opcode==`ADDIU||opcode[5:3]==`STORE||(opcode==`SPECIAL&&func==`ADDU))?`ADD:
			( ((opcode==`SPECIAL && (func==`SUBU || func==`MOVZ || func==`MOVN))  || (opcode[5:2]==`BRANCH && opcode!=`BLEZ))?`SUB:
			( (opcode==`ANDI || (opcode==`SPECIAL && func==`ANDU))?`AND:
			( (opcode==`ORI  || (opcode==`SPECIAL && func==`ORU))?`OR:
			( (opcode==`XORI || (opcode==`SPECIAL && func==`XORU))?`XOR:
			( (opcode==`SPECIAL && (func==`SLL  || func==`SLLV))?`SL:
			( (opcode==`SPECIAL && (func==`SRAU || func==`SRAV))?`SRA:
			( (opcode==`SPECIAL && (func==`SRLU || func==`SRLV))?`SRL:
			( (opcode==`SLTI || opcode==`BLEZ   || (opcode==`REGIMM && rt[4:1]==`BRANCH_Z) || (opcode==`SPECIAL && (func[5:1]==`MOVE || func==`SLT_U)))?`SLT:
			( (opcode==`SPECIAL && func==`NORU)?`NOR:`SLTU)))))))));
assign Branch_eff = ((opcode==`BNE && Zero==0) || (opcode==`BEQ && Zero==1) || (opcode==`BLEZ && (shift_num==32'b0||ALU_result==32'b1))
					|| (opcode==`REGIMM && ((rt==`BLTZ && ALU_result==32'b1) || (rt==`BGEZ  &&  (ALU_result==32'b0 || shift_num==32'b0))))
					|| (opcode==`BGTZ && Zero!=1 && !shift_num[31]))?1:0;
assign PC_4 = PC + 4;
assign lui_extend = {valid_Instruction[15:0],16'b0};
assign zero_extend = {16'b0,valid_Instruction[15:0]};
assign sign_extend = valid_Instruction[15] ? {{16{1'b1}},valid_Instruction[15:0]} : {{16{1'b0}},valid_Instruction[15:0]};
assign shift_sign_extend = valid_Instruction[15] ? {{14{1'b1}},valid_Instruction[15:0],2'b00} : {{14{1'b0}},valid_Instruction[15:0],2'b00};
assign sltiu_extend = valid_Instruction[15] ? {{1'b0},{15{1'b1}},valid_Instruction[15:0]} : {{16{1'b0}},valid_Instruction[15:0]};
assign extend = (opcode==`ANDI||opcode==`ORI||opcode==`XORI)?zero_extend:
				( (opcode==`ADDIU||opcode==`SLTI||opcode[5:3]==`LOAD||opcode[5:3]==`STORE)?sign_extend:
				( (opcode==`SLTIU)?sltiu_extend:
				( (opcode==`LUI)?lui_extend : shift_sign_extend)));
alu branch_PC_result(
	.A(PC_4),
	.B(shift_sign_extend),
	.ALUop(`ADD),
	.Result(branch_PC),
	.Overflow(),
	.CarryOut(),
	.Zero()
);
reg_file ren_data_get(
	.clk(clk),
	.rst(rst),
	.waddr(RF_waddr),
	.raddr1(RF_raddr1),
	.raddr2(RF_raddr2),
	.wen(RF_wen),
	.wdata(RF_wdata),
	.rdata1(RF_rdata1),
	.rdata2(RF_rdata2)
);
assign ALU_N2 = (ALUsrc)?extend:
				((opcode==`SPECIAL && (func==`MOVZ || func==`MOVN) || opcode==`BGTZ || opcode==`BLEZ || (opcode==`REGIMM && (rt==`BLTZ || rt==`BGEZ)))?32'b0:
				((opcode==`SPECIAL && (func[5:2]==`SHIFT))? {{27{1'b0}},valid_Instruction[10:6]}:
				((opcode==`SPECIAL && func[5:2]==`SHIFT_V)? {27'b0,RF_rdata1[4:0]}:RF_rdata2)));
assign shift_num = (opcode==`SPECIAL && (func[5:3]==`SHIFT_ALL||func==`MOVZ||func==`MOVN))?RF_rdata2:RF_rdata1;
alu res_cal(
	.A(shift_num),
	.B(ALU_N2),
	.ALUop(ALU_control),
	.Result(ALU_result),
	.Overflow(),
	.CarryOut(),
	.Zero(Zero)
);
assign Address = {ALU_result[31:2],2'b00};
assign ALUsrc = (opcode[5:3]==`CALCU_I || opcode[5:3]==`LOAD || opcode[5:3]==`STORE)?1:0;
assign sb_strb = 4'b1000 >> (~ALU_result[1:0]);
assign sh_strb = {ALU_result[1],ALU_result[1],!ALU_result[1],!ALU_result[1]};
assign sw_strb = 4'b1111;
assign swl_strb = {ALU_result[1]&ALU_result[0],ALU_result[1],ALU_result[1]|ALU_result[0],1'b1};
assign swr_strb = {1'b1,!(ALU_result[1]&ALU_result[0]),!ALU_result[1],(!ALU_result[1])&(!ALU_result[0])};
assign Write_strb = opcode[2:0]==`SB_s?sb_strb:
					( opcode[2:0]==`SH_s?sh_strb:
					( opcode[2:0]==`SW_s?sw_strb:
					( opcode[2:0]==`SWL_s?swl_strb:swr_strb)));
assign store_byte = sb_strb;
assign Write_data = (opcode==`SB)? sb_result : 
					((opcode==`SH)? sh_result : 
					((opcode==`SWL)? swl_result : 
					((opcode==`SWR)? swr_result: RF_rdata2)));
assign sb_result = {32{store_byte[0]}} & {{24{1'b0}},RF_rdata2[7:0]} |
					{32{store_byte[1]}} & {{16{1'b0}},RF_rdata2[7:0],{8{1'b0}}} |
					{32{store_byte[2]}} & {{8{1'b0}},RF_rdata2[7:0],{16{1'b0}}} |
					{32{store_byte[3]}} & {RF_rdata2[7:0],{24{1'b0}}};			
assign sh_result = {32{store_byte[0]}} & {{16{1'b0}},RF_rdata2[15:0]} |
					{32{store_byte[2]}} & {RF_rdata2[15:0],{16{1'b0}}};
assign swl_result = {32{store_byte[0]}} & {{24{1'b0}},RF_rdata2[31:24]} |
					{32{store_byte[1]}} & {{16{1'b0}},RF_rdata2[31:16]} |
					{32{store_byte[2]}} & {{8{1'b0}},RF_rdata2[31:8]};				
assign swr_result = {32{store_byte[1]}} & {RF_rdata2[23:0],{8{1'b0}}} |
					{32{store_byte[2]}} & {RF_rdata2[15:0],{16{1'b0}}} |
					{32{store_byte[3]}} & {RF_rdata2[7:0],{24{1'b0}}};
assign JumpAddress =(opcode==`SPECIAL && (func==`JALR || func==`JR))?{RF_rdata1} : {PC_4[31:28],valid_Instruction[25:0],2'b00}; //should be check!!!


endmodule

