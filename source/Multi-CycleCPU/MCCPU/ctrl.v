`include "ctrl_encode_def.v"

module ctrl(
input				clk,
input				rst,

input				Zero,
input		[5:0]	Op,
input		[5:0]	Funct,

output reg			RegWrite,		// control signal for register write
output reg			MemWrite,		// control signal for memory write
output reg			PCWrite,		// control signal for PC write
output reg			IRWrite,		// control signal for IR write
output reg			EXTOp,			// control signal to signed extension
output reg  [2:0]  	ALUSrcA,		// ALU source for A, 0 - PC, 1 - ReadData1
output reg 	[1:0] 	ALUSrcB,		// ALU source for B, 0 - ReadData2, 1 - 4, 2 - extended immediate, 3 - branch offset
output reg 	[3:0]	ALUOp,			// ALU opertion
output reg 	[1:0] 	PCSource,		// PC source, 0- ALU, 1-ALUOut, 2-JUMP address
output reg 	[1:0] 	GPRSel,			// general purpose register selection
output reg	[1:0]	WDSel,			// (register) write data selection
output reg       	IorD 			// 0-memory access for instruction, 1 - memory access for data
);

	// GPRSel_RD   2'b00
	// GPRSel_RT   2'b01
	// GPRSel_31   2'b10

	// WDSel_FromALU 2'b00
	// WDSel_FromMEM 2'b01
	// WDSel_FromPC  2'b10

	parameter	[2:0]	sif		= 3'b000,				// IF  state
						sid		= 3'b001,				// ID  state
						sexe	= 3'b010,				// EXE state
						smem	= 3'b011,				// MEM state
						swb		= 3'b100;				// WB  state
	// r format
	wire rtype  = ~|Op;
	wire i_add  = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] & ~Funct[1] & ~Funct[0];	// add
	wire i_sub  = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] &  Funct[1] & ~Funct[0];	// sub
	wire i_and  = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] &  Funct[2] & ~Funct[1] & ~Funct[0];	// and
	wire i_or   = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] &  Funct[2] & ~Funct[1] &  Funct[0];	// or
	wire i_slt  = rtype &  Funct[5] & ~Funct[4] &  Funct[3] & ~Funct[2] &  Funct[1] & ~Funct[0];	// slt
	wire i_sltu = rtype &  Funct[5] & ~Funct[4] &  Funct[3] & ~Funct[2] &  Funct[1] &  Funct[0];	// sltu
	wire i_addu = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] & ~Funct[1] &  Funct[0];	// addu
	wire i_subu = rtype &  Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] &  Funct[1] &  Funct[0];	// subu
	wire i_sll	= rtype & ~Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] & ~Funct[1] & ~Funct[0];	// sll
	wire i_nor	= rtype &  Funct[5] & ~Funct[4] & ~Funct[3] &  Funct[2] &  Funct[1] &  Funct[0];	// nor
	wire i_srl	= rtype & ~Funct[5] & ~Funct[4] & ~Funct[3] & ~Funct[2] &  Funct[1] & ~Funct[0];	// srl
	wire i_sllv = rtype & ~Funct[5] & ~Funct[4] & ~Funct[3] &  Funct[2] & ~Funct[1] & ~Funct[0];	// sllv
	wire i_srlv = rtype & ~Funct[5] & ~Funct[4] & ~Funct[3] &  Funct[2] &  Funct[1] & ~Funct[0];	// srlv
	wire i_jr	= rtype & ~Funct[5] & ~Funct[4] &  Funct[3] & ~Funct[2] & ~Funct[1] & ~Funct[0]; 	// jr
	wire i_jalr	= rtype & ~Funct[5] & ~Funct[4] &  Funct[3] & ~Funct[2] & ~Funct[1] &  Funct[0]; 	// jalr

	// i format
	wire i_addi = ~Op[5] & ~Op[4] &  Op[3] & ~Op[2] & ~Op[1] & ~Op[0];	// addi
	wire i_ori  = ~Op[5] & ~Op[4] &  Op[3] &  Op[2] & ~Op[1] &  Op[0];	// ori
	wire i_lw   =  Op[5] & ~Op[4] & ~Op[3] & ~Op[2] &  Op[1] &  Op[0];	// lw
	wire i_sw   =  Op[5] & ~Op[4] &  Op[3] & ~Op[2] &  Op[1] &  Op[0];	// sw
	wire i_beq  = ~Op[5] & ~Op[4] & ~Op[3] &  Op[2] & ~Op[1] & ~Op[0];	// beq
	wire i_lui	= ~Op[5] & ~Op[4] &  Op[3] &  Op[2] &  Op[1] &  Op[0];	// lui
	wire i_slti = ~Op[5] & ~Op[4] &  Op[3] & ~Op[2] &  Op[1] & ~Op[0];	// slti
	wire i_bne  = ~Op[5] & ~Op[4] & ~Op[3] &  Op[2] & ~Op[1] &  Op[0];	// bne
	wire i_andi = ~Op[5] & ~Op[4] &  Op[3] &  Op[2] & ~Op[1] & ~Op[0];	// andi

	// j format
	wire i_j    = ~Op[5] & ~Op[4] & ~Op[3] & ~Op[2] &  Op[1] & ~Op[0];	// j
	wire i_jal  = ~Op[5] & ~Op[4] & ~Op[3] & ~Op[2] &  Op[1] &  Op[0];	// jal

	/*************************************************/
	/******               FSM                   ******/
	reg	[2:0]	nextstate;
	reg	[2:0]	state;

	always@(posedge clk or posedge rst) begin
		if(rst)
			state <= sif;
		else
			state <= nextstate;
	end

	/*************************************************/
	/******         Control Signal              ******/
	always@(*) begin
		RegWrite = 0;
		MemWrite = 0;
		PCWrite  = 0;
		IRWrite  = 0;
		EXTOp    = 1;			// signed extension
		ALUSrcA  = 3'b001;		// 1 - ReadData1
		ALUSrcB  = 2'b00;       // 0 - ReadData2
		ALUOp    = 3'b001;      // ALU_ADD       3'b001
		GPRSel   = 2'b00;       // GPRSel_RD     2'b00
		WDSel    = 2'b00;       // WDSel_FromALU 2'b00
		PCSource = 2'b00;       // PC + 4 (ALU)
		IorD     = 0;           // 0-memory access for instruction

		case(state)
			sif: begin
				PCWrite = 1;
				IRWrite = 1;
				ALUSrcA = 3'b000;		// PC
				ALUSrcB = 2'b01;		// 4
				nextstate = sid;
			end
			
			sid: begin
				if(i_j) begin
					PCSource = 2'b10;	// JUMP address
					PCWrite = 1;
					nextstate = sif;
				end else if(i_jr) begin
					PCSource = 2'b11;
					PCWrite = 1;
					nextstate = sif;
				end else if(i_jal) begin
					PCSource = 2'b10;	// JUMP address
					PCWrite = 1;
					RegWrite = 1;
					WDSel = 2'b10;		// WDSel_FromPC  2'b10
					GPRSel = 2'b10;		// GPRSel_31     2'b10
					nextstate = sif;
				end else if(i_jalr) begin
					PCSource = 2'b11;
					PCWrite = 1;
					RegWrite = 1;
					WDSel = 2'b10;
					GPRSel = 2'b00;
					nextstate = sif;
				end else begin
					ALUSrcA = 3'b000;	// PC
					ALUSrcB = 2'b11;	// branch offset
					nextstate = sexe;
				end
			end
			
			sexe: begin
				/******************************
				`define ALU_NOP		4'b0000
				`define ALU_ADD   	4'b0001
				`define ALU_SUB 	4'b0010
				`define ALU_AND		4'b0011
				`define ALU_OR    	4'b0100
				`define ALU_SLT   	4'b0101
				`define ALU_SLTU  	4'b0110
				`define	ALU_SLL		4'b0111
				`define	ALU_NOR		4'b1000
				`define ALU_SRL		4'b1001
				******************************/
				ALUOp[0] = i_add | i_lw  | i_sw  | i_addi | i_and  | i_slt  | i_addu | i_sll  | i_slti | i_andi | i_srl | i_sllv | i_srlv;
				ALUOp[1] = i_sub | i_beq | i_and | i_sltu | i_subu | i_sll  | i_bne  | i_andi | i_sllv;
				ALUOp[2] = i_or  | i_ori | i_slt | i_sltu | i_sll  | i_slti | i_sllv;
				ALUOp[3] = i_nor | i_srl | i_srlv;
				if(i_beq | i_bne) begin
					PCSource = 2'b01;		// ALUout, branch address
					PCWrite = (i_beq & Zero) | (i_bne & ~Zero);
					nextstate = sif;
				end else if(i_lw || i_sw) begin
					ALUSrcB = 2'b10;		// select offset
					nextstate = smem;
				end else begin
					if(i_sllv || i_srlv)
						ALUSrcA = 3'b100;
					if(i_sll || i_srl)
						ALUSrcA = 3'b010;
					if(i_lui)
						ALUSrcA = 3'b011;
					if(i_addi || i_ori || i_slti || i_andi)
						ALUSrcB = 2'b10;	// select immediate
					if(i_ori || i_andi)
						EXTOp = 0;			// zero extension
					nextstate = swb;
				end
			end
			
			smem: begin
				IorD = 1;					// memory address  = ALUout
				if(i_lw) begin
					nextstate = swb;
				end else begin				// i_sw
					MemWrite = 1;
					nextstate = sif;
				end
			end
			
			swb: begin
				if(i_lw)
					WDSel = 2'b01;			// WDSel_FromMEM 2'b01
				if(i_lw | i_addi | i_ori | i_lui | i_slti | i_andi) begin
					GPRSel = 2'b01;			// GPRSel_RT     2'b01
				end
				RegWrite = 1;
				nextstate = sif;
			end

			default: begin
				nextstate = sif;
			end
			
		endcase
	end

endmodule