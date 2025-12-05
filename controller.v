`include "definitions.v"

module controller (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    
    output wire       reg_write,
    output wire       alu_src,    // Selects RegB (0) or Imm (1)
    output wire       mem_write,
    output wire [1:0] result_src, // 00: ALU, 01: Mem, 10: PC+4
    output wire [2:0] imm_src,
    output wire [3:0] alu_control,
    output wire       pc_src,     // Branch decision
    output wire       jump        // Unconditional jump (JAL)
);

    wire [1:0] alu_op;
    wire       branch;

    // Main Decoder
    main_decoder md (
        .opcode(opcode),
        .reg_write(reg_write),
        .imm_src(imm_src),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .result_src(result_src),
        .branch(branch),
        .alu_op(alu_op),
        .jump(jump)
    );

    // ALU Decoder
    alu_decoder ad (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode),
        .alu_control(alu_control)
    );

    // PC Source Logic for Branching (BEQ)
    // Note: The Zero flag check happens in the top level. 
    // Here we just expose the control signals.
    // However, usually pc_src depends on Zero. 
    // For this module structure, I will export 'branch' and let Top Level combine it with 'Zero'.
    assign pc_src = branch;
    
endmodule

module main_decoder (
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg  [2:0] imm_src,
    output reg        alu_src,
    output reg        mem_write,
    output reg  [1:0] result_src,
    output reg        branch,
    output reg  [1:0] alu_op,
    output reg        jump
);
    // Opcodes
    localparam OP_R_TYPE = 7'b0110011;
    localparam OP_I_TYPE = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011; // beq
    localparam OP_JAL    = 7'b1101111; // jal
    localparam OP_LUI    = 7'b0110111; // lui

    always @(*) begin
        // Defaults
        reg_write = 0; imm_src = 0; alu_src = 0; mem_write = 0;
        result_src = 0; branch = 0; alu_op = 0; jump = 0;

        case (opcode)
            OP_R_TYPE: begin // R-Type
                reg_write = 1;
                alu_op    = 2'b10;
            end
            OP_I_TYPE: begin // I-Type ALU
                reg_write = 1;
                alu_src   = 1; // Use Immediate
                alu_op    = 2'b10; // Use funct3/7 to determine op
            end
            OP_LOAD: begin // lw
                reg_write  = 1;
                alu_src    = 1;
                imm_src    = 3'b000;
                result_src = 2'b01; // From Memory
                alu_op     = 2'b00; // ADD
            end
            OP_STORE: begin // sw
                mem_write = 1;
                alu_src   = 1;
                imm_src   = 3'b001; // S-Type
                alu_op    = 2'b00; // ADD
            end
            OP_BRANCH: begin // beq
                branch  = 1;
                alu_op  = 2'b01; // Sub (compare)
                imm_src = 3'b010; // B-Type
            end
            OP_JAL: begin // jal
                jump       = 1;
                reg_write  = 1;
                imm_src    = 3'b011; // J-Type
                result_src = 2'b10;  // PC+4
            end
            OP_LUI: begin // lui
                reg_write = 1;
                alu_src   = 1;
                imm_src   = 3'b100; // U-Type
                alu_op    = 2'b11;  // Pass through
            end
        endcase
    end
endmodule

module alu_decoder (
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    input  wire [6:0] opcode,
    output reg  [3:0] alu_control
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_control = `ALU_ADD; // LW, SW (Add)
            2'b01: alu_control = `ALU_SUB; // BEQ (Sub)
            2'b11: alu_control = `ALU_LUI; // LUI (Pass Imm)
            2'b10: begin // R-Type or I-Type
                case (funct3)
                    3'b000: begin // ADD or SUB
                         if (opcode == 7'b0110011 && funct7[5]) // R-type SUB
                             alu_control = `ALU_SUB;
                         else 
                             alu_control = `ALU_ADD; // ADD or ADDI
                    end
                    3'b001: alu_control = `ALU_SLL; // SLL, SLLI
                    3'b010: alu_control = `ALU_SLT; // SLT, SLTI
                    3'b011: alu_control = `ALU_SLTU; // SLTU, SLTIU
                    3'b100: alu_control = `ALU_XOR; // XOR, XORI
                    3'b101: begin // SRL, SRA
                        if (funct7[5]) alu_control = `ALU_SRA; // SRA, SRAI
                        else           alu_control = `ALU_SRL; // SRL, SRLI
                    end
                    3'b110: alu_control = `ALU_OR;  // OR, ORI
                    3'b111: alu_control = `ALU_AND; // AND, ANDI
                    default: alu_control = `ALU_ADD;
                endcase
            end
        endcase
    end
endmodule