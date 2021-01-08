`timescale 10ns / 1ns
`include "macro.v"

module custom_cpu(
	input  rst,
	input  clk,

	//Instruction request channel
	output reg [31:0] PC,
	output Inst_Req_Valid,
	input Inst_Req_Ack,

	//Instruction response channel
	input  [31:0] Instruction,
	input Inst_Valid,
	output Inst_Ack,

	//Memory request channel
	output [31:0] Address,
	output reg MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,
	output reg MemRead,
	input Mem_Req_Ack,

	//Memory data response channel
	input  [31:0] Read_data,
	input Read_data_Valid,
	output Read_data_Ack, 

    output [31:0]	cpu_perf_cnt_0,
    output [31:0]	cpu_perf_cnt_1,
    output [31:0]	cpu_perf_cnt_2,
    output [31:0]	cpu_perf_cnt_3,
    output [31:0]	cpu_perf_cnt_4,
    output [31:0]	cpu_perf_cnt_5,
    output [31:0]	cpu_perf_cnt_6,
    output [31:0]	cpu_perf_cnt_7,
    output [31:0]	cpu_perf_cnt_8,
    output [31:0]	cpu_perf_cnt_9,
    output [31:0]	cpu_perf_cnt_10,
    output [31:0]	cpu_perf_cnt_11,
    output [31:0]	cpu_perf_cnt_12,
    output [31:0]	cpu_perf_cnt_13,
    output [31:0]	cpu_perf_cnt_14,
    output [31:0]	cpu_perf_cnt_15

);

	wire RF_wen;
	wire [31:0] RF_wdata;
	wire [31:0] RF_rdata1;
	wire [31:0] RF_rdata2;

  //TODO: Please add your RISC-V CPU code here
	wire [6:0] opcode;
	wire [4:0] rd;
	wire [2:0] funct3;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [6:0] funct7;
	wire [5:0] type;
	
	wire [31:0] sign_extend;
	wire sign;
	wire [31:0] PC_4;
	wire [31:0] Branch_PC;
	wire Branch_eff;
	wire [3:0] ALUop;
	wire [31:0] ALU_result;
	wire [31:0] Read_extend;
	wire [31:0] Store_extend;
	wire [31:0] PC_extend;
	wire [31:0] ALU_num1;
	wire [31:0] ALU_num2;
	wire Zero;
	wire [3:0] sb_strb;
	wire [3:0] sh_strb;
	wire [3:0] sw_strb;
	wire [31:0] JALR_extend;
	wire [3:0] store_byte;
	wire [31:0] sb_result;
	wire [31:0] sh_result;
	wire [1:0] byte;
	wire [7:0] lb_data;
	wire [15:0] lh_data;
	wire shift_imm;
	// to describe the type of instruction
	// use one-hot code
	parameter R_type = 6'b000001;
	parameter I_type = 6'b000010;
	parameter S_type = 6'b000100;
	parameter B_type = 6'b001000;
	parameter U_type = 6'b010000;
	parameter J_type = 6'b100000;
	// to describe the state
	// use one-hot code
	parameter IF  = 9'b000000001;
	parameter IW  = 9'b000000010;
	parameter ID  = 9'b000000100;
	parameter EX  = 9'b000001000;
	parameter LD  = 9'b000010000;
	parameter ST  = 9'b000100000;
	parameter WB  = 9'b001000000;
	parameter RDW = 9'b010000000;
	parameter RSTSTATE = 9'b100000000; //extra state, in order to avoid the dead-lock, and make FSM more easy
	reg [8:0] state;
	reg [8:0] next_state;
	reg [31:0] originPC;
	reg [31:0] valid_Instruction;
	reg [31:0] valid_Read_data;
	
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
		PC <= Branch_eff ? Branch_PC : PC_4;
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
		IF: if(Inst_Req_Ack & Inst_Req_Valid) begin
				next_state = IW;
			end else begin
				next_state = IF;
			end
		IW: if(Inst_Ack & Inst_Valid) begin
				next_state = ID;
			end else begin
				next_state = IW;
			end
		ID: next_state = EX;
		EX: case(type)
				B_type: next_state = IF;
				S_type: next_state = ST;
				I_type: if(opcode==`LOAD) begin
							next_state = LD;
						end else begin
							next_state = WB;
						end
				default: if(opcode==7'b0) begin //avoid the influence of empty instruction
							next_state = IF; // although it might be uncessary
						end else begin
							next_state = WB;
						end
			endcase
		// all the hand-shaking signals should be in the condition of "if"
		// or the signals may not become valid in time
		LD: if(Mem_Req_Ack & MemRead) begin
				next_state = RDW;
			end else begin
				next_state = LD;
			end
		ST: if(Mem_Req_Ack & MemWrite) begin
				next_state = IF;
			end else begin
				next_state = ST;
			end
		WB: next_state = IF;
		RDW: if(Read_data_Ack & Read_data_Valid) begin
				next_state = WB;
			end else begin
				next_state = RDW;
			end
		default: next_state = IF;
	endcase
end

always @(posedge clk) begin
	valid_Instruction <= (Inst_Ack & Inst_Valid)? Instruction : valid_Instruction;
end

always @(posedge clk) begin
	valid_Read_data <= (Read_data_Valid & Read_data_Ack)? Read_data : valid_Read_data;
end

// MemRead and MemWrite used to be wire type
// However, the program always recieve bad trap at the begenning
// This problem was solved after changing these two variables to reg type
always @(posedge clk) begin
	MemRead <= (state == LD)?1:0;
end

always @(posedge clk) begin
	MemWrite <= (state == ST)?1:0;
end

assign opcode = valid_Instruction[6:0];
assign rd = valid_Instruction[11:7];
assign funct3 = valid_Instruction[14:12];
assign rs1 = valid_Instruction[19:15];
assign rs2 = valid_Instruction[24:20];
assign funct7 = valid_Instruction[31:25];
// the immediate/offset number in RISC-V has a common character
// that the highest bit of immediate/offset number is also at
// the highest position of RISC-V instruction
assign sign = valid_Instruction[31]?1'b1:1'b0;
assign PC_4 = PC + 4;
assign type = (opcode==`CALCU || (opcode==`IMMED && (funct3==`f3SLLI || funct3==`f3SRI)))? R_type:
			  (opcode==`LOAD  || (opcode==`IMMED &&  funct3!=`f3SLLI && funct3!=`f3SRI)) ? I_type:
			  (opcode==`STORE) ? S_type:
			  (opcode==`BRANCH)? B_type:
			  (opcode==`LUI || opcode==`AUIPC)? U_type : J_type; // JALR is put into J_type

// use to judge the shift instructions in R_type
//including SLLI, SRLI, SRAI
assign shift_imm = (opcode==`IMMED && (funct3==`f3SLLI || funct3==`f3SRI))?1'b1:1'b0;
// B_type and J_type start from NO.1 bit, so the NO.0 bit should be assigned as 0
assign sign_extend = (type==I_type)? {{20{sign}},valid_Instruction[31:20]}:
					 (type==S_type)? {{20{sign}},valid_Instruction[31:25],valid_Instruction[11:7]}:
					 (type==B_type)? {{20{sign}},valid_Instruction[7],valid_Instruction[30:25],valid_Instruction[11:8],1'b0}:
					 (type==J_type)? {{12{sign}},valid_Instruction[19:12],valid_Instruction[20],valid_Instruction[30:21],1'b0}:
					 {valid_Instruction[31:12],12'b0};

//special judgement of JALR
assign JALR_extend = {{20{sign}},valid_Instruction[31:20]};

assign RF_wen = state==WB ? 1'b1 : 1'b0;

assign RF_wdata = opcode==`LUI ? sign_extend :
				  type==J_type ? originPC + 4 :
				  opcode==`AUIPC ? PC_extend : 
				  opcode==`LOAD ? Read_extend : ALU_result; 

// To judge if allowed to jump or branch
assign Branch_eff = (type==J_type ||
					(type==B_type && ((funct3==`f3BEQ && Zero) || (funct3==`f3BNE && !Zero) || 
					((funct3==`f3BLT || funct3==`f3BLTU) && ALU_result) || 
					((funct3==`f3BGE || funct3==`f3BGEU) && !ALU_result))))? 1'b1:1'b0;
					
// Branch_PC is the correct PC value after branch or jump instruction
// assign the lowest 1 bit as 0
assign Branch_PC = opcode==`JALR? (ALU_result & 32'hfffffffe) : PC_extend;
assign PC_extend = originPC + sign_extend;
// assign the lowest 2 bits as 0
assign Address = ALU_result & 32'hfffffffc;
assign Inst_Ack = (state==RSTSTATE || state==IW)?1:0;
assign Inst_Req_Valid = (state == IF)?1:0;
assign Read_data_Ack = (state == RDW)?1:0;
// SLLI, SRLI, SRAI are placed into R_type, ATTENTION!!
assign ALUop = (opcode==`LOAD || opcode==`STORE || type==J_type || (type==I_type && funct3==`f3ADDI) || 
			   ( type==R_type && funct3==`f3A_S && funct7==`f7ADD)) ? `ADD : 
			   ((type==B_type && (funct3==`f3BEQ  || funct3==`f3BNE)) || (type==R_type && funct3==`f3A_S && funct7==`f7SUB)) ? `SUB :
			   ((type==I_type && funct3==`f3ORI)  || (type==R_type && funct3==`f3OR))  ? `OR  :
			   ((type==I_type && funct3==`f3ANDI) || (type==R_type && funct3==`f3AND)) ? `AND :
			   ((type==B_type && (funct3==`f3BLT  || funct3==`f3BGE)) || (type==R_type && funct3==`f3SLT) || (type==I_type && funct3==`f3SLTI)) ? `SLT :
			   ( type==R_type && (funct3==`f3SLLI || funct3==`f3SLL)) ? `SL  :
			   ((type==R_type && funct3==`f3SRI && funct7==`f7SRLI) || (type==R_type && funct3==`f3SR && funct7==`f7SRL)) ? `SRL :
			   ((type==R_type && funct3==`f3SRI && funct7==`f7SRAI) || (type==R_type && funct3==`f3SR && funct7==`f7SRA)) ? `SRA :
			   ((type==I_type && funct3==`f3XORI) || (type==R_type && funct3==`f3XOR)) ? `XOR : `SLTU ;

assign ALU_num1 = opcode==`JAL ? originPC : RF_rdata1;
assign ALU_num2 = (type==B_type || (type==R_type && !shift_imm)) ? RF_rdata2 :
				  shift_imm ? {27'b0,rs2} :
				  opcode==`JALR ? JALR_extend : sign_extend;
assign store_byte = sb_strb;
assign sb_result =  {32{store_byte[0]}} & {{24{1'b0}},RF_rdata2[7:0]} |
					{32{store_byte[1]}} & {{16{1'b0}},RF_rdata2[7:0],{8{1'b0}}} |
					{32{store_byte[2]}} & {{8{1'b0}},RF_rdata2[7:0],{16{1'b0}}} |
					{32{store_byte[3]}} & {RF_rdata2[7:0],{24{1'b0}}};
assign sh_result =  {32{~ALU_result[1]}} & {{16{1'b0}},RF_rdata2[15:0]} |
					{32{ ALU_result[1]}} & {RF_rdata2[15:0],{16{1'b0}}};
assign Store_extend = {32{funct3==`f3SB}}  &  sb_result |
					  {32{funct3==`f3SH}}  &  sh_result |
					  {32{funct3==`f3SW}}  &  RF_rdata2 ;
assign byte = ALU_result[1:0];
assign lb_data = ( byte[1] &  byte[0]) ? valid_Read_data[31:24] : 
				 ((byte[1] & !byte[0]) ? valid_Read_data[23:16] :
				 ((!byte[1]&  byte[0]) ? valid_Read_data[15:8]  : valid_Read_data[7:0])); 
assign lh_data = (!byte[1] & !byte[0]) ? valid_Read_data[15:0] : valid_Read_data[31:16];
assign Read_extend = {32{funct3==`f3LB}}  & {{24{lb_data[7]}},lb_data[7:0]}   |
					 {32{funct3==`f3LH}}  & {{16{lh_data[15]}},lh_data[15:0]} |
					 {32{funct3==`f3LW}}  & {valid_Read_data[31:0]}				|
					 {32{funct3==`f3LBU}} & {{24{1'b0}},lb_data[7:0]} 			|
					 {32{funct3==`f3LHU}} & {{16{1'b0}},lh_data[15:0]};
assign Write_data = Store_extend;
assign sb_strb = 4'b1000 >> (~ALU_result[1:0]);
assign sh_strb = {ALU_result[1],ALU_result[1],!ALU_result[1],!ALU_result[1]};
assign sw_strb = 4'b1111;
assign Write_strb = funct3==`f3SB ? sb_strb :
					funct3==`f3SH ? sh_strb :
					sw_strb;

reg_file reg_data(
	.clk(clk),
	.rst(rst),
	.waddr(rd),
	.raddr1(rs1),
	.raddr2(rs2),
	.wen(RF_wen),
	.wdata(RF_wdata),
	.rdata1(RF_rdata1),
	.rdata2(RF_rdata2)
);

alu res_cal(
	.A(ALU_num1),
	.B(ALU_num2),
	.ALUop(ALUop),
	.Result(ALU_result),
	.Overflow(),
	.CarryOut(),
	.Zero(Zero)
);






endmodule

