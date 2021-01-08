`timescale 1ns / 1ps

module adder(
    input [7:0] operand0,
    input [7:0] operand1,
    output [7:0] result
    );
/*initial begin
	result = 8'b0;
	operand0 = 8'b0;
	operand1 = 8'b0;
end*/
reg [7:0]result;
always @(operand0 or operand1 or result)
begin
	result <= operand0 + operand1;
end

	/*TODO: Add your logic code here*/

endmodule
