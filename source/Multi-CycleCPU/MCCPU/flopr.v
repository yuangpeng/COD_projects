module flopr #(parameter WIDTH = 8) (
input				clk,
input				rst,
input	[WIDTH-1:0]	d,

output	[WIDTH-1:0]	q
);
	reg [WIDTH-1:0] q_r;
	
	always@(posedge clk or posedge rst) begin
		if(rst) 
			q_r <= 0;
		else 
			q_r <= d;
	end
	
	assign q = q_r;
	
endmodule