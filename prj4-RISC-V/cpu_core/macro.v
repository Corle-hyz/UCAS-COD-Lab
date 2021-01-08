// opcode-begin
`define LUI    7'b0110111
`define AUIPC  7'b0010111
`define JAL    7'b1101111
`define JALR   7'b1100111
`define BRANCH 7'b1100011
`define LOAD   7'b0000011
`define STORE  7'b0100011
`define IMMED  7'b0010011
`define CALCU  7'b0110011
// opcode-end



// funct3-begin
`define opJALR 3'b000 // this might be useless

// BRANCH
`define f3BEQ  3'b000
`define f3BNE  3'b001
`define f3BLT  3'b100
`define f3BGE  3'b101
`define f3BLTU 3'b110
`define f3BGEU 3'b111

// LOAD
`define f3LB  3'b000
`define f3LH  3'b001
`define f3LW  3'b010
`define f3LBU 3'b100
`define f3LHU 3'b101

// STORE
`define f3SB 3'b000
`define f3SH 3'b001
`define f3SW 3'b010

// IMMED
`define f3ADDI  3'b000
`define f3SLTI  3'b010
`define f3SLTIU 3'b011
`define f3XORI  3'b100
`define f3ORI   3'b110
`define f3ANDI  3'b111
`define f3SLLI  3'b001
`define f3SRI   3'b101 //which contains SRLI and SRAI

// CALCU
`define f3A_S  3'b000 //which contains ADD and SUB
`define f3SLL  3'b001
`define f3SLT  3'b010
`define f3SLTU 3'b011
`define f3XOR  3'b100
`define f3SR   3'b101 //which contains SRL and SRA
`define f3OR   3'b110
`define f3AND  3'b111
// funct3-end

//funct7-begin
`define f7SRLI 7'b0000000
`define f7SRAI 7'b0100000
`define f7ADD  7'b0000000
`define f7SUB  7'b0100000
`define f7SRL  7'b0000000
`define f7SRA  7'b0100000
//funct7-end
