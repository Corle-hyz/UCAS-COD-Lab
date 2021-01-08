`timescale 1ns / 1ps

`define STATE_RESET 8'd0
`define STATE_RUN 8'd1
`define STATE_HALT 8'd2

module counter(
    input clk,
    input [31:0] interval,
    input [7:0] state,
    output [31:0] counter
	);
reg[31:0] counter;
reg[31:0] step;
initial begin
	counter <= 32'b0;
	step <= 32'b0;
end

always @(posedge clk)
begin
	case(state)
		`STATE_RESET:counter <= 32'b0;
		`STATE_HALT:counter <= counter;
		`STATE_RUN:begin
						step <= step+32'b1;
						if(step==interval) begin
							counter <= counter+32'b1;
							step <= 32'b0;
						end else begin
							counter <= counter;
						end
					end
		default:counter <= counter;
	endcase
end
	/*TODO: Add your logic code here*/
    
endmodule
