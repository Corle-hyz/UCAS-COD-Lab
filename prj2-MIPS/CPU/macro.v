//normal
`define CALCU_I 3'b001 //2*GPR + IMM/OFF
`define BRANCH  4'b0001 //2*GPR + OFF
`define LOAD 	3'b100 //2*GPR + OFF
`define STORE 	3'b101 //2*GPR + OFF
`define LUI 	6'b001111 //1*GPR + IMM
`define BLEZ    6'b000110 //1*GPR + OFF
`define JUMP 	5'b00001 //instr_index

//special
`define SPECIAL 6'b000000
`define CALCU   3'b100 //3*GPR_H
`define JUMP_R  5'b00100 //2*GPR + hint
`define SLT_X   5'b10101 //3*GPR_H
`define SHIFT   4'b0000 //3*GPR_L
`define SHIFT_V 4'b0001 //3*GPR_H
`define SHIFT_ALL 3'b000
`define MOVE    5'b00101
//regimm
`define REGIMM   6'b000001 //1*GPR + OFF
`define BRANCH_Z 4'b0000  //only 5 bits

`define SHIFT_SIGN  5'b00000
`define JAL 6'b000011
`define JALR 6'b001001//special

//other
`define ADDU  6'b100001//SPECIAL
`define ADDIU 6'b001001
`define SUBU  6'b100011//conflict with the definition in ALU, so I make a little change with the name. the other definitions are the same
`define ANDU  6'b100100
`define ANDI  6'b001100
`define NORU  6'b100111
`define ORU   6'b100101
`define ORI   6'b001101
`define XORU  6'b100110
`define XORI  6'b001110
`define SLT_U 6'b101010
`define SLTI  6'b001010//same as 44
`define SLTUU 6'b101011
`define SLTIU 6'b001011
`define SLL   6'b000000
`define SLLV  6'b000100
`define SRAU  6'b000011
`define SRAV  6'b000111
`define SRLU  6'b000010
`define SRLV  6'b000110
`define J     6'b000010
`define JAL   6'b000011
`define JR    6'b001000
`define JALR  6'b001001
`define BNE   6'b000101
`define BEQ   6'b000100
`define BGEZ  5'b00001
`define BLTZ  5'b00000
`define MOVN  6'b001011
`define MOVZ  6'b001010
`define SB_s  3'b000//the short version, which implies the value of the last three bits
`define SH_s  3'b001
`define SW_s  3'b011
`define SWL_s 3'b010
`define SWR_s 3'b110
`define SB    6'b101000
`define SH    6'b101001
`define SW    6'b101011
`define SWL   6'b101010
`define SWR   6'b101110
`define LB    6'b100000
`define LH    6'b100001
`define LW    6'b100011
`define LBU   6'b100100
`define LHU   6'b100101
`define LWL   6'b100010
`define LWR   6'b100110
