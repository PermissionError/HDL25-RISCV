module sign_extend (
    input  wire [31:0] instr,
    input  wire [2:0]  imm_src, // Control signal to select type
    output reg  [31:0] imm_ext
);
    always @(*) begin
        case (imm_src)
            // I-Type (lw, I-type ALU, jalr)
            3'b000: imm_ext = {{20{instr[31]}}, instr[31:20]};
            // S-Type (sw)
            3'b001: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            // B-Type (beq)
            3'b010: imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            // J-Type (jal)
            3'b011: imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            // U-Type (lui) - Upper Immediate
            3'b100: imm_ext = {instr[31:12], 12'b0}; 
            default: imm_ext = 32'b0;
        endcase
    end
endmodule