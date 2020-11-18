`include "ctrl_encode_def.v"

module ctrl(
input	[5:0]	Op,
input	[5:0]	Funct,
input			Zero,

output			RegWrite,
output			MemWrite,
output			EXTOp,
output	[3:0]	ALUOp,
output	[1:0]	NPCOp,
output	[1:0]	ALUSrcA,		// ALU source for A
output			ALUSrcB,		// ALU source for B
output			GPRSel,			// general purpose register selection
output			WDSel			// (register) write data selection
);
   
	// r format
	wire rtype  = ~|Op;
	wire i_add  = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] & ~Funct[1] & ~Funct[0];	// add
	wire i_sub  = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] &  Funct[1] & ~Funct[0]; 	// sub
	wire i_and  = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] &  Funct[2] & ~Funct[1] & ~Funct[0]; 	// and
	wire i_or   = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] &  Funct[2] & ~Funct[1] &  Funct[0]; 	// or
	wire i_slt  = rtype &  Funct[5] & ~Funct[4] &  Funct[3] & ~Funct[2] &  Funct[1] & ~Funct[0]; 	// slt
	wire i_sltu = rtype &  Funct[5] & ~Funct[4] &  Funct[3] & ~Funct[2] &  Funct[1] &  Funct[0]; 	// sltu
	wire i_addu = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] & ~Funct[1] &  Funct[0]; 	// addu
	wire i_subu = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] &  Funct[1] &  Funct[0]; 	// subu
	wire i_sll  = rtype & ~Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] & ~Funct[1] & ~Funct[0]; 	// sll
	wire i_nor	= rtype &  Funct[5] & ~Funct[4] & ~Funct[3] &  Funct[2] &  Funct[1] &  Funct[0]; 	// nor

	// i format
	wire i_addi = ~Op[5] & ~Op[4] &  Op[3] & ~Op[2] & ~Op[1] & ~Op[0];	// addi
	wire i_ori  = ~Op[5] & ~Op[4] &  Op[3] &  Op[2] & ~Op[1] &  Op[0];	// ori
	wire i_lw   =  Op[5] & ~Op[4] & ~Op[3] & ~Op[2] &  Op[1] &  Op[0];	// lw
	wire i_sw   =  Op[5] & ~Op[4] &  Op[3] & ~Op[2] &  Op[1] &  Op[0];	// sw
	wire i_beq  = ~Op[5] & ~Op[4] & ~Op[3] &  Op[2] & ~Op[1] & ~Op[0];	// beq
	wire i_lui	= ~Op[5] & ~Op[4] &  Op[3] &  Op[2] &  Op[1] &  Op[0];	// lui
	wire i_slti	= ~Op[5] & ~Op[4] &  Op[3] & ~Op[2] &  Op[1] & ~Op[0];	// slti

	// j format
	wire i_j    = ~Op[5] & ~Op[4] & ~Op[3] & ~Op[2] &  Op[1] & ~Op[0];	// j

	// generate control signals
	assign RegWrite		= rtype | i_lw | i_addi | i_ori | i_lui | i_slti;		// register write
	assign MemWrite   	= i_sw;                           						// memory write
	
	// 32-bit RD1 from rs	2b'00
	// 32-bit shamt			2b'01
	// 32-bit luiImm32		2b'10
	assign ALUSrcA[0]	= i_sll;
	assign ALUSrcA[1]	= i_lui;
	
	// ALU B is from instruction immediate
	assign ALUSrcB    	= i_lw | i_sw | i_addi | i_ori | i_slti;
	
	// signed extension
	assign EXTOp      	= i_addi | i_lw | i_sw | i_slti;

	// GPRSel_RD   1'b0
	// GPRSel_RT   1'b1
	assign GPRSel = i_lw | i_addi | i_ori | i_lui | i_slti;

	// WDSel_FromALU aluout 	 2'b00
	// WDSel_FromMEM readdata	 2'b01
	// WDSel_FromPC 			 2'b10 
	assign WDSel = i_lw;

	// NPC_PLUS4   2'b00
	// NPC_BRANCH  2'b01
	// NPC_JUMP    2'b10
	assign NPCOp[0] = i_beq & Zero;
	assign NPCOp[1] = i_j;
  
	/************************************
	`define ALU_NOP  	4'b0000
	`define ALU_ADD  	4'b0001
	`define ALU_SUB  	4'b0010
	`define ALU_AND  	4'b0011
	`define ALU_OR    	4'b0100
	`define ALU_SLT   	4'b0101
	`define ALU_SLTU  	4'b0110
	`define	ALU_SLL		4'b0111
	`define	ALU_NOR		4'b1000
	************************************/
	assign ALUOp[0] = i_add | i_lw  | i_sw  | i_addi | i_and  | i_slt | i_addu | i_sll | i_slti;
	assign ALUOp[1] = i_sub | i_beq | i_and | i_sltu | i_subu | i_sll;
	assign ALUOp[2] = i_or  | i_ori | i_slt | i_sltu | i_sll  |	i_slti;
	assign ALUOp[3]	= i_nor;

endmodule
