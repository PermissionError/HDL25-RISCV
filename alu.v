`include "definitions.v"

module alu (
    input  wire [31:0] src_a,
    input  wire [31:0] src_b,
    input  wire [3:0]  alu_control,
    output reg  [31:0] alu_result,
    output wire        zero
);
    wire signed [31:0] src_a_signed = src_a;
    
    always @(*) begin
        case (alu_control)
            `ALU_ADD:  alu_result = src_a + src_b;
            `ALU_SUB:  alu_result = src_a - src_b;
            `ALU_AND:  alu_result = src_a & src_b;
            `ALU_OR:   alu_result = src_a | src_b;
            `ALU_XOR:  alu_result = src_a ^ src_b;
            `ALU_SLL:  alu_result = src_a << src_b[4:0];
            `ALU_SRL:  alu_result = src_a >> src_b[4:0];
            `ALU_SRA:  alu_result = src_a_signed >>> src_b[4:0]; // Arithmetic shift
            `ALU_SLT:  alu_result = (src_a_signed < $signed(src_b)) ? 32'd1 : 32'd0;
            `ALU_SLTU: alu_result = (src_a < src_b) ? 32'd1 : 32'd0;
            `ALU_LUI:  alu_result = src_b; // Pass immediate for LUI
            default:   alu_result = 32'b0;
        endcase
    end

    // Zero flag for BEQ
    assign zero = (alu_result == 32'b0);
endmodule