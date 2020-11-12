`include "ctrl_encode_def.v"

module alu(
input		signed	[31:0]	A,
input		signed	[31:0]	B,
input				[2:0]	ALUOp,
output	reg	signed	[31:0]	C,
output						Zero
);

    always@(*) begin
        case(ALUOp)
            `ALU_NOP:	C = A;                          				// NOP
            `ALU_ADD:  	C = A + B;                      				// ADD
            `ALU_SUB:  	C = A - B;                     					// SUB
            `ALU_AND:  	C = A & B;                      				// AND/ANDI
            `ALU_OR:   	C = A | B;                      				// OR/ORI
            `ALU_SLT:  	C = (A < B) ? 32'd1 : 32'd0;    				// SLT/SLTI
            `ALU_SLTU: 	C = ({1'b0, A} < {1'b0, B}) ? 32'd1 : 32'd0;
            default:   	C = A;                          				// Undefined
        endcase
    end
    
    assign Zero = (C == 32'b0);
    
endmodule