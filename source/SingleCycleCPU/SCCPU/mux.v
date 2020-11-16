// mux2
module mux2 #(parameter WIDTH = 8) (
input	[WIDTH-1:0]	d0,
input	[WIDTH-1:0]	d1,
input				s,

output	[WIDTH-1:0]	y
);
            
	assign y = (s == 1'b1) ? d1:d0;
    
endmodule

// mux4
module mux4 #(parameter WIDTH = 8) (
input	[WIDTH-1:0]	d0,
input	[WIDTH-1:0]	d1,
input	[WIDTH-1:0]	d2,
input	[WIDTH-1:0]	d3,
input	[1:0]		s,

output	[WIDTH-1:0]	y
);
    
	reg [WIDTH-1:0] y_r;
    
    always@(*) begin
        case(s)
            2'b00:		y_r = d0;
            2'b01:		y_r = d1;
            2'b10: 		y_r = d2;
            2'b11: 		y_r = d3;
            default:			;
        endcase
    end
    
    assign y = y_r;
        
endmodule

// mux8
module mux8 #(parameter WIDTH = 8) (
input	[WIDTH-1:0]	d0,
input	[WIDTH-1:0]	d1,
input	[WIDTH-1:0]	d2,
input	[WIDTH-1:0]	d3,
input	[WIDTH-1:0]	d4,
input	[WIDTH-1:0]	d5,
input	[WIDTH-1:0]	d6,
input	[WIDTH-1:0]	d7,
input	[2:0]		s,

output	[WIDTH-1:0]	y,
);

    reg	[WIDTH-1:0] y_r;
	
    always@(*) begin
        case(s)
			3'd0:		y_r = d0;
            3'd1: 		y_r = d1;
            3'd2: 		y_r = d2;
            3'd3: 		y_r = d3;
            3'd4: 		y_r = d4;
            3'd5: 		y_r = d5;
            3'd6: 		y_r = d6;
            3'd7: 		y_r = d7;
            default: 			;
        endcase
    end
    
    assign y = y_r;
    
endmodule

// mux16
module mux16 #(parameter WIDTH = 8) (
input	[WIDTH-1:0]	d0,
input	[WIDTH-1:0]	d1,
input	[WIDTH-1:0]	d2,
input	[WIDTH-1:0]	d3,
input	[WIDTH-1:0]	d4,
input	[WIDTH-1:0]	d5,
input	[WIDTH-1:0]	d6,
input	[WIDTH-1:0]	d7,
input	[WIDTH-1:0]	d8,
input	[WIDTH-1:0]	d9,
input	[WIDTH-1:0]	d10,
input	[WIDTH-1:0]	d11,
input	[WIDTH-1:0]	d12,
input	[WIDTH-1:0]	d13,
input	[WIDTH-1:0]	d14,
input	[WIDTH-1:0]	d15,
input	[3:0]		s,

output	[WIDTH-1:0]	y
);
    
    reg	[WIDTH-1:0] y_r;
    
    always@(*) begin
        case(s)
            4'd0:		y_r = d0;
            4'd1:  		y_r = d1;
            4'd2:  		y_r = d2;
            4'd3:  		y_r = d3;
            4'd4:  		y_r = d4;
            4'd5:  		y_r = d5;
            4'd6:  		y_r = d6;
            4'd7:  		y_r = d7;
            4'd8:  		y_r = d8;
            4'd9: 		y_r = d9;
            4'd10: 		y_r = d10;
            4'd11: 		y_r = d11;
            4'd12: 		y_r = d12;
            4'd13: 		y_r = d13;
            4'd14: 		y_r = d14;
            4'd15: 		y_r = d15;
            default: 			 ;
        endcase
    end
    
    assign y = y_r;
    
endmodule