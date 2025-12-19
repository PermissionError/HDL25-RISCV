// ==============================================================================
// Top Level Module: rv_mc
// ==============================================================================
module rv_mc(
    input clk,
    input rst
);

    // Internal connections
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [31:0] mem_rdata;
    wire        mem_we;
    
    // Control signals
    wire        pc_update;
    wire        ir_we;
    wire        we_mem;
    wire        we_rf;
    wire [1:0]  sel_mem_addr;
    wire [1:0]  sel_alu_src_a;
    wire [1:0]  sel_alu_src_b;
    wire [1:0]  sel_result;
    wire [3:0]  alu_control;
    wire [2:0]  imm_type;

    // Opcode and Funct from Datapath to Controller
    wire [6:0]  op;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire        zero;

    // --------------------------------------------------------------------------
    // Datapath Instance
    // --------------------------------------------------------------------------
    datapath DP (
        .clk(clk),
        .rst(rst),
        // Control inputs
        .pc_update(pc_update),
        .ir_we(ir_we),
        .we_rf(we_rf),
        .sel_mem_addr(sel_mem_addr),
        .sel_alu_src_a(sel_alu_src_a),
        .sel_alu_src_b(sel_alu_src_b),
        .sel_result(sel_result),
        .alu_control(alu_control),
        .imm_type(imm_type),
        // Memory Interface
        .mem_rdata(mem_rdata),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        // Status outputs
        .op(op),
        .funct3(funct3),
        .funct7(funct7),
        .zero(zero)
    );

    // --------------------------------------------------------------------------
    // Controller Instance
    // --------------------------------------------------------------------------
    controller CTR (
        .clk(clk),
        .rst(rst),
        .op(op),
        .funct3(funct3),
        .funct7(funct7),
        .zero(zero),
        // Outputs
        .pc_update(pc_update),
        .ir_we(ir_we),
        .we_mem(mem_we), // Mapped to we_mem
        .we_rf(we_rf),
        .sel_mem_addr(sel_mem_addr),
        .sel_alu_src_a(sel_alu_src_a),
        .sel_alu_src_b(sel_alu_src_b),
        .sel_result(sel_result),
        .alu_control(alu_control),
        .imm_type(imm_type)
    );

    // --------------------------------------------------------------------------
    // Memory Instance (Strict Naming Requirement)
    // --------------------------------------------------------------------------
    mem MEM (
        .clk(clk),
        .we(mem_we),
        .addr(mem_addr),
        .wd(mem_wdata),
        .rd(mem_rdata)
    );

endmodule


// ==============================================================================
// Controller Module
// Includes FSM, ALU Decoder, and Instr Decoder
// ==============================================================================
module controller(
    input        clk,
    input        rst,
    input [6:0]  op,
    input [2:0]  funct3,
    input [6:0]  funct7,
    input        zero,
    output       pc_update,
    output       ir_we,
    output       we_mem,
    output       we_rf,
    output [1:0] sel_mem_addr,
    output [1:0] sel_alu_src_a,
    output [1:0] sel_alu_src_b,
    output [1:0] sel_result,
    output [3:0] alu_control,
    output [2:0] imm_type
);

    wire [1:0] alu_op;

    fsm FSM_INST (
        .clk(clk),
        .rst(rst),
        .op(op),
        .zero(zero),
        .pc_update(pc_update),
        .ir_we(ir_we),
        .we_mem(we_mem),
        .we_rf(we_rf),
        .sel_mem_addr(sel_mem_addr),
        .sel_alu_src_a(sel_alu_src_a),
        .sel_alu_src_b(sel_alu_src_b),
        .sel_result(sel_result),
        .alu_op(alu_op)
    );

    alu_decoder ALU_DEC_INST (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .op(op),
        .alu_control(alu_control)
    );

    instr_decoder INSTR_DEC_INST (
        .op(op),
        .imm_type(imm_type)
    );

endmodule

// ==============================================================================
// FSM Module
// ==============================================================================
module fsm(
    input        clk,
    input        rst,
    input [6:0]  op,
    input        zero,
    output reg   pc_update,
    output reg   ir_we,
    output reg   we_mem,
    output reg   we_rf,
    output reg [1:0] sel_mem_addr,
    output reg [1:0] sel_alu_src_a,
    output reg [1:0] sel_alu_src_b,
    output reg [1:0] sel_result,
    output reg [1:0] alu_op
);

    // FSM State Encoding
    localparam S_FETCH      = 4'd0;
    localparam S_DECODE     = 4'd1;
    localparam S_MEM_ADDR   = 4'd2;
    localparam S_MEM_RD     = 4'd3;
    localparam S_WB_MEM     = 4'd4;
    localparam S_MEM_WR     = 4'd5;
    localparam S_EXE_R      = 4'd6;
    localparam S_WB_ALU     = 4'd7;
    localparam S_BEQ        = 4'd8;
    localparam S_EXE_I      = 4'd9;
    localparam S_JAL        = 4'd10;
    localparam S_LUI        = 4'd11;
    localparam S_JAL_WB     = 4'd12;

    reg [3:0] current_state, next_state;

    // --------------------------------------------------------------------------
    // FSM: State Transition
    // --------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= S_FETCH;
        else
            current_state <= next_state;
    end

    // --------------------------------------------------------------------------
    // FSM: Next State Logic & Output Logic
    // --------------------------------------------------------------------------
    always @(*) begin
        // Defaults
        next_state = current_state;
        pc_update = 0;
        ir_we = 0;
        we_mem = 0;
        we_rf = 0;
        sel_mem_addr = 0;
        sel_alu_src_a = 0;
        sel_alu_src_b = 0;
        sel_result = 0;
        alu_op = 2'b00;

        case (current_state)
            S_FETCH: begin
                // Fetch Instruction, PC = PC + 4
                sel_mem_addr = 2'b00;   // Addr = PC
                ir_we = 1;              // Write IR
                we_mem = 0;             // Read
                sel_alu_src_a = 2'b00;  // PC
                sel_alu_src_b = 2'b10;  // 4
                alu_op = 2'b00;         // Add
                sel_result = 2'b10;     // ALU Result Direct to PC
                pc_update = 1;
                next_state = S_DECODE;
            end

            S_DECODE: begin
                // Decode & Calculate Branch Target (PC + Imm)
                // Note: Standard MC often calculates target here. 
                sel_alu_src_a = 2'b00;  // PC
                sel_alu_src_b = 2'b01;  // Imm
                alu_op = 2'b00;         // Add
                // We don't write PC here, result stored in alu_reg automatically
                
                case (op)
                    7'b0000011: next_state = S_MEM_ADDR; // LW
                    7'b0100011: next_state = S_MEM_ADDR; // SW
                    7'b0110011: next_state = S_EXE_R;    // R-Type
                    7'b0010011: next_state = S_EXE_I;    // I-Type
                    7'b1100011: next_state = S_BEQ;      // Branch
                    7'b1101111: next_state = S_JAL;      // JAL
                    7'b0110111: next_state = S_LUI;      // LUI
                    default:    next_state = S_FETCH;
                endcase
            end

            S_MEM_ADDR: begin
                // Calculate Address: RS1 + Imm
                sel_alu_src_a = 2'b10; // RS1
                sel_alu_src_b = 2'b01; // Imm
                alu_op = 2'b00;        // Add
                if (op == 7'b0000011) next_state = S_MEM_RD; // LW
                else                  next_state = S_MEM_WR; // SW
            end

            S_MEM_RD: begin
                // Read Memory
                sel_mem_addr = 2'b01; // ALUOut
                we_mem = 0;
                next_state = S_WB_MEM;
            end

            S_WB_MEM: begin
                // Write back from Memory
                sel_result = 2'b01; // MDR
                we_rf = 1;
                next_state = S_FETCH;
            end

            S_MEM_WR: begin
                // Write Memory
                sel_mem_addr = 2'b01; // ALUOut
                we_mem = 1;
                next_state = S_FETCH;
            end

            S_EXE_R: begin
                // Execute R-Type
                sel_alu_src_a = 2'b10; // RS1
                sel_alu_src_b = 2'b00; // RS2
                alu_op = 2'b10;        // Op dependent
                next_state = S_WB_ALU;
            end

            S_EXE_I: begin
                // Execute I-Type
                sel_alu_src_a = 2'b10; // RS1
                sel_alu_src_b = 2'b01; // Imm
                alu_op = 2'b10;        // Op dependent
                next_state = S_WB_ALU;
            end

            S_WB_ALU: begin
                // Write back ALU Result
                sel_result = 2'b00; // ALUOut
                we_rf = 1;
                next_state = S_FETCH;
            end

            S_BEQ: begin
                // Branch comparison (RS1 - RS2)
                // Note: Branch target (PC+Imm) is already in alu_reg from S_DECODE
                // We need to save it before doing comparison
                sel_alu_src_a = 2'b10; // RS1
                sel_alu_src_b = 2'b00; // RS2
                alu_op = 2'b01;        // Sub for comparison
                // Result (RS1-RS2) will be in alu_result, zero flag set accordingly
                // On next cycle, alu_result moves to alu_reg, overwriting target
                // So we check zero NOW using alu_result, and update PC with current alu_reg
                
                if (zero) begin
                    sel_result = 2'b00; // Use current alu_reg (has target from S_DECODE)
                    pc_update = 1;
                end
                
                next_state = S_FETCH;
            end

            S_JAL: begin
                // JAL: Write PC to RD (PC is already PC+4 from FETCH)
                // Use ALU to pass PC through: PC + 0
                sel_alu_src_a = 2'b00; // PC
                sel_alu_src_b = 2'b01; // Imm (will be 0 effectively, but we use existing path)
                alu_op = 2'b00;        // Add
                // Actually, PC is already in pc_reg, but we can't route it directly
                // Instead: use result_mux case 2'b10 (direct alu_result) or 2'b11 for PC
                sel_result = 2'b10;    // Direct ALU result (PC+0 = PC)
                we_rf = 1;             // Write to RD
                next_state = S_JAL_WB;
            end
            
            S_JAL_WB: begin
                // JAL Part 2: Update PC to target (which is in alu_reg from S_DECODE)
                sel_result = 2'b00;    // Use alu_reg (target from S_DECODE)
                pc_update = 1;
                next_state = S_FETCH;
            end
            
            S_LUI: begin
                // LUI: RD = Imm. ALU = 0 + Imm.
                sel_alu_src_a = 2'b11; // Zero (Added for LUI)
                sel_alu_src_b = 2'b01; // Imm
                alu_op = 2'b00;        // Add
                next_state = S_WB_ALU;
            end
        endcase
    end
endmodule

// ==============================================================================
// ALU Decoder Module
// ==============================================================================
module alu_decoder(
    input [1:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,
    input [6:0] op,
    output reg [3:0] alu_control
);
    // --------------------------------------------------------------------------
    // ALU Decoder
    // --------------------------------------------------------------------------
    always @(*) begin
        // default
        alu_control = 4'b0000; // ADD
        
        case (alu_op)
            2'b00: alu_control = 4'b0000; // ADD (LW, SW, Fetch)
            2'b01: alu_control = 4'b0001; // SUB (BEQ)
            2'b10: begin // R-type or I-type
                if (funct3 == 3'b000) begin
                    if (op == 7'b0110011 && funct7 == 7'b0100000)
                        alu_control = 4'b0001; // SUB
                    else
                        alu_control = 4'b0000; // ADD
                end
                else if (funct3 == 3'b111) alu_control = 4'b0010; // AND
                else if (funct3 == 3'b110) alu_control = 4'b0011; // OR
                else if (funct3 == 3'b010) alu_control = 4'b0101; // SLT
            end
            default: alu_control = 4'b0000;
        endcase
    end
endmodule

// ==============================================================================
// Instruction Decoder Module
// ==============================================================================
module instr_decoder(
    input [6:0] op,
    output reg [2:0] imm_type
);
    // --------------------------------------------------------------------------
    // Instruction Decoder (Immediate Selection)
    // --------------------------------------------------------------------------
    always @(*) begin
        case (op)
            7'b0000011: imm_type = 3'd0; // I-type (LW)
            7'b0010011: imm_type = 3'd0; // I-type (ALU)
            7'b0100011: imm_type = 3'd1; // S-type (SW)
            7'b1100011: imm_type = 3'd2; // B-type (Branch)
            7'b1101111: imm_type = 3'd3; // J-type (JAL)
            7'b0110111: imm_type = 3'd4; // U-type (LUI)
            default:    imm_type = 3'd0;
        endcase
    end
endmodule


// ==============================================================================
// Datapath Module
// ==============================================================================
module datapath(
    input clk,
    input rst,
    input pc_update,
    input ir_we,
    input we_rf,
    input [1:0] sel_mem_addr,
    input [1:0] sel_alu_src_a,
    input [1:0] sel_alu_src_b,
    input [1:0] sel_result,
    input [3:0] alu_control,
    input [2:0] imm_type,
    
    // Memory Interface
    input [31:0] mem_rdata,
    output reg [31:0] mem_addr,
    output [31:0] mem_wdata,
    
    // To Controller
    output [6:0] op,
    output [2:0] funct3,
    output [6:0] funct7,
    output zero
);

    // Registers
    reg [31:0] pc_reg;
    reg [31:0] instr_reg;
    reg [31:0] data_reg;
    reg [31:0] rd1_reg, rd2_reg;
    reg [31:0] alu_reg;
    
    // Wires
    wire [31:0] rf_rd1, rf_rd2;
    wire [31:0] imm_ext;
    wire [31:0] alu_src_a, alu_src_b;
    wire [31:0] alu_result;
    wire [31:0] result_mux;
    
    // --------------------------------------------------------------------------
    // PC Register
    // --------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) 
            pc_reg <= 0;
        else if (pc_update) begin
            // PC Input Mux logic (simplified based on S0/JAL logic)
            // If sel_result == 10, typically PC+4 (ALU Direct)
            // If sel_result == 00, typically Target (ALU Reg)
            if (sel_result == 2'b10)      pc_reg <= alu_result;
            else if (sel_result == 2'b00) pc_reg <= alu_reg;
            else                          pc_reg <= alu_result; // default
        end
    end

    // --------------------------------------------------------------------------
    // Memory Address Mux
    // --------------------------------------------------------------------------
    always @(*) begin
        case (sel_mem_addr)
            2'b00: mem_addr = pc_reg;
            2'b01: mem_addr = alu_reg;
            default: mem_addr = pc_reg;
        endcase
    end

    // --------------------------------------------------------------------------
    // Instruction Register
    // --------------------------------------------------------------------------
    always @(posedge clk) begin
        if (ir_we) instr_reg <= mem_rdata;
    end
    
    assign op = instr_reg[6:0];
    assign funct3 = instr_reg[14:12];
    assign funct7 = instr_reg[31:25];

    // --------------------------------------------------------------------------
    // Data Register (MDR)
    // --------------------------------------------------------------------------
    always @(posedge clk) begin
        data_reg <= mem_rdata;
    end

    // --------------------------------------------------------------------------
    // Register File
    // --------------------------------------------------------------------------
    reg [31:0] rf [31:0];
    integer i;
    
    // Sync Write, Async Read (Standard for this type of design)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                rf[i] <= 32'b0;
        end
        else if (we_rf && instr_reg[11:7] != 0)
            rf[instr_reg[11:7]] <= result_mux;
    end
    
    assign rf_rd1 = (instr_reg[19:15] == 0) ? 0 : rf[instr_reg[19:15]];
    assign rf_rd2 = (instr_reg[24:20] == 0) ? 0 : rf[instr_reg[24:20]];

    // --------------------------------------------------------------------------
    // A and B Registers
    // --------------------------------------------------------------------------
    always @(posedge clk) begin
        rd1_reg <= rf_rd1;
        rd2_reg <= rf_rd2;
    end
    
    assign mem_wdata = rd2_reg; // Store data comes from B reg

    // --------------------------------------------------------------------------
    // Sign Extension
    // --------------------------------------------------------------------------
    reg [31:0] imm_gen;
    always @(*) begin
        case (imm_type)
            3'd0: imm_gen = {{20{instr_reg[31]}}, instr_reg[31:20]}; // I-type
            3'd1: imm_gen = {{20{instr_reg[31]}}, instr_reg[31:25], instr_reg[11:7]}; // S-type
            3'd2: imm_gen = {{20{instr_reg[31]}}, instr_reg[7], instr_reg[30:25], instr_reg[11:8], 1'b0}; // B-type
            3'd3: imm_gen = {{12{instr_reg[31]}}, instr_reg[19:12], instr_reg[20], instr_reg[30:21], 1'b0}; // J-type
            3'd4: imm_gen = {instr_reg[31:12], 12'b0}; // U-type
            default: imm_gen = 0;
        endcase
    end
    assign imm_ext = imm_gen;

    // --------------------------------------------------------------------------
    // ALU Input Muxes
    // --------------------------------------------------------------------------
    assign alu_src_a = (sel_alu_src_a == 2'b00) ? pc_reg : 
                       (sel_alu_src_a == 2'b10) ? rd1_reg : 
                       (sel_alu_src_a == 2'b11) ? 32'b0 : // Zero for LUI
                       pc_reg;

    assign alu_src_b = (sel_alu_src_b == 2'b00) ? rd2_reg :
                       (sel_alu_src_b == 2'b01) ? imm_ext :
                       (sel_alu_src_b == 2'b10) ? 32'd4 :
                       rd2_reg;

    // --------------------------------------------------------------------------
    // ALU
    // --------------------------------------------------------------------------
    reg [31:0] alu_res_comb;
    always @(*) begin
        case (alu_control)
            4'b0000: alu_res_comb = alu_src_a + alu_src_b;
            4'b0001: alu_res_comb = alu_src_a - alu_src_b;
            4'b0010: alu_res_comb = alu_src_a & alu_src_b;
            4'b0011: alu_res_comb = alu_src_a | alu_src_b;
            4'b0101: alu_res_comb = ($signed(alu_src_a) < $signed(alu_src_b)) ? 32'd1 : 32'd0;
            default: alu_res_comb = 0;
        endcase
    end
    assign alu_result = alu_res_comb;
    assign zero = (alu_result == 0);

    // --------------------------------------------------------------------------
    // ALU Register
    // --------------------------------------------------------------------------
    always @(posedge clk) begin
        alu_reg <= alu_result;
    end

    // --------------------------------------------------------------------------
    // Result Mux (for RegFile Write)
    // --------------------------------------------------------------------------
    assign result_mux = (sel_result == 2'b00) ? alu_reg :
                        (sel_result == 2'b01) ? data_reg :
                        (sel_result == 2'b11) ? pc_reg :   // PC for JAL return address
                        alu_result; // Case 10: direct ALU result

endmodule


// ==============================================================================
// Memory Module Definition
// ==============================================================================
module mem(
    input clk,
    input we,
    input [31:0] addr,
    input [31:0] wd,
    output [31:0] rd
);
    // 1KB Memory for simulation
    parameter MEM_DEPTH = 256; 
    reg [31:0] RAM [0:MEM_DEPTH-1];

    // Async Read
    assign rd = RAM[addr[31:2]];

    // Sync Write
    always @(posedge clk) begin
        if (we)
            RAM[addr[31:2]] <= wd;
    end

endmodule