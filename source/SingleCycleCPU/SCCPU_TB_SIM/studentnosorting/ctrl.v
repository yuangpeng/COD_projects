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
output	[1:0]	GPRSel,			// general purpose register selection
output	[1:0]	WDSel			// (register) write data selection
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
	wire i_srl	= rtype & ~Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] &  Funct[1] & ~Funct[0]; 	// srl
	wire i_sllv = rtype & ~Funct[5] & ~Funct[4] & ~Funct[3] &  Funct[2] & ~Funct[1] & ~Funct[0]; 	// sllv
	wire i_srlv = rtype & ~Funct[5] & ~Funct[4] & ~Funct[3] &  Funct[2] &  Funct[1] & ~Funct[0]; 	// srlv
	wire i_jr	= rtype & ~Funct[5] & ~Funct[4] &  Funct[3] &  Funct[2] &  Funct[1] &  Funct[0]; 	// jr
	wire i_jalr	= rtype & ~Funct[5] & ~Funct[4] &  Funct[3] & ~Funct[2] & ~Funct[1] &  Funct[0]; 	// jalr

	// i format
	wire i_addi = ~Op[5] & ~Op[4] &  Op[3] & ~Op[2] & ~Op[1] & ~Op[0];	// addi
	wire i_ori  = ~Op[5] & ~Op[4] &  Op[3] &  Op[2] & ~Op[1] &  Op[0];	// ori
	wire i_lw   =  Op[5] & ~Op[4] & ~Op[3] & ~Op[2] &  Op[1] &  Op[0];	// lw
	wire i_sw   =  Op[5] & ~Op[4] &  Op[3] & ~Op[2] &  Op[1] &  Op[0];	// sw
	wire i_beq  = ~Op[5] & ~Op[4] & ~Op[3] &  Op[2] & ~Op[1] & ~Op[0];	// beq
	wire i_lui	= ~Op[5] & ~Op[4] &  Op[3] &  Op[2] &  Op[1] &  Op[0];	// lui
	wire i_slti	= ~Op[5] & ~Op[4] &  Op[3] & ~Op[2] &  Op[1] & ~Op[0];	// slti
	wire i_bne	= ~Op[5] & ~Op[4] & ~Op[3] &  Op[2] & ~Op[1] &  Op[0];	// bne
	wire i_andi = ~Op[5] & ~Op[4] &  Op[3] &  Op[2] & ~Op[1] & ~Op[0];	// andi

	// j format
	wire i_j    = ~Op[5] & ~Op[4] & ~Op[3] & ~Op[2] &  Op[1] & ~Op[0];	// j
	wire i_jal	= ~Op[5] & ~Op[4] & ~Op[3] & ~Op[2] &  Op[1] &  Op[0];	// jal

	// generate control signals
	assign RegWrite		= rtype | i_lw | i_addi | i_ori | i_lui | i_slti | i_andi | i_jal;		// register write
	assign MemWrite   	= i_sw;                           										// memory write
	
	// 32-bit RD1 from rs				2b'00
	// 32-bit shamt						2b'01
	// 32-bit luiImm32					2b'10
	// 32-bit RD1 from rs lower bit		2b'11
	assign ALUSrcA[0]	= i_sll  | i_srl  | i_sllv | i_srlv;
	assign ALUSrcA[1]	= i_lui  | i_sllv | i_srlv;
	
	// ALU B is from instruction immediate
	assign ALUSrcB    	= i_lw   | i_sw   | i_addi | i_ori | i_slti | i_andi;
	
	// signed extension
	assign EXTOp      	= i_addi | i_lw   | i_sw   | i_slti;

	// GPRSel_RD   	2'b00
	// GPRSel_RT   	2'b01
	// GPRSel_31	2'b10
	assign GPRSel[0]	= i_lw   | i_addi | i_ori  | i_lui | i_slti | i_andi;
	assign GPRSel[1]	= i_jal;

	// WDSel_FromALU aluout 	 2'b00
	// WDSel_FromMEM readdata	 2'b01
	// WDSel_FromPC 			 2'b10
	assign WDSel[0] = i_lw;
	assign WDSel[1] = i_jal | i_jalr;

	// NPC_PLUS4    2'b00
	// NPC_BRANCH   2'b01
	// NPC_JUMP     2'b10
	// NPC_JUMPR	2'b11
	assign NPCOp[0] = (i_beq & Zero) | (i_bne & ~Zero) | i_jr | i_jalr;
	assign NPCOp[1] = i_j | i_jal | i_jr | i_jalr;

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
	`define ALU_SRL		4'b1001
	`define ALU_JR		4'b1010
	************************************/
	assign ALUOp[0] = i_add | i_lw   | i_sw  | i_addi | i_and  | i_slt  | i_addu | i_sll  | i_slti | i_andi | i_srl | i_sllv | i_srlv;
	assign ALUOp[1] = i_sub | i_beq  | i_and | i_sltu | i_subu | i_sll  | i_bne  | i_andi | i_sllv | i_jr;
	assign ALUOp[2] = i_or  | i_ori  | i_slt | i_sltu | i_sll  | i_slti | i_srl  | i_sllv;
	assign ALUOp[3]	= i_nor | i_srlv | i_jr;

endmodule
