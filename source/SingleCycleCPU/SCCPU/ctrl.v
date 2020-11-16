`include "ctrl_encode_def.v"

module ctrl(
input	[5:0]	Op,
input	[5:0]	Funct,
input			Zero,

output			RegWrite,
output			MemWrite,
output			EXTOp,
output	[2:0]	ALUOp,
output	[1:0]	NPCOp,
output			ALUSrcA,		// ALU source for A
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

	// i format
	wire i_addi = ~Op[5]&~Op[4]& Op[3]&~Op[2]&~Op[1]&~Op[0];	// addi
	wire i_ori  = ~Op[5]&~Op[4]& Op[3]& Op[2]&~Op[1]& Op[0]; 	// ori
	wire i_lw   =  Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]& Op[0];	// lw
	wire i_sw   =  Op[5]&~Op[4]& Op[3]&~Op[2]& Op[1]& Op[0]; 	// sw
	wire i_beq  = ~Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]&~Op[0]; 	// beq

	// j format
	wire i_j    = ~Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]&~Op[0];	// j

	// generate control signals
	assign RegWrite		= rtype | i_lw | i_addi | i_ori;	// register write
	assign MemWrite   	= i_sw;                           	// memory write
	assign ALUSrcA		= i_sll;							// ALU A is from shift instruction
	assign ALUSrcB    	= i_lw | i_sw | i_addi | i_ori;   	// ALU B is from instruction immediate
	assign EXTOp      	= i_addi | i_lw | i_sw;           	// signed extension

	// GPRSel_RD   1'b0
	// GPRSel_RT   1'b1
	assign GPRSel = i_lw | i_addi | i_ori;

	// WDSel_FromALU 2'b00
	// WDSel_FromMEM 2'b01
	// WDSel_FromPC  2'b10 
	assign WDSel = i_lw;  

	// NPC_PLUS4   2'b00
	// NPC_BRANCH  2'b01
	// NPC_JUMP    2'b10
	assign NPCOp[0] = i_beq & Zero;
	assign NPCOp[1] = i_j;
  
	// ALU_NOP   3'b000
	// ALU_ADD   3'b001
	// ALU_SUB   3'b010
	// ALU_AND   3'b011
	// ALU_OR    3'b100
	// ALU_SLT   3'b101
	// ALU_SLTU  3'b110
	// ALU_SLL	 3'b111
	assign ALUOp[0] = i_add | i_lw | i_sw | i_addi | i_and | i_slt | i_addu | i_sll;
	assign ALUOp[1] = i_sub | i_beq | i_and | i_sltu | i_subu | i_sll;
	assign ALUOp[2] = i_or | i_ori | i_slt | i_sltu | i_sll;

endmodule
