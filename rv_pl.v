// =============================================================================
// Top-Level Module: rv_pl
// =============================================================================
module rv_pl(
    input clk,
    input rst_n
);

    // =========================================================================
    // Internal Wires & Pipeline Signals
    // =========================================================================

    // --- IF Stage Signals ---
    wire [31:0] F_PC, F_PC_next, F_PC_plus_4, F_instr;
    wire        PC_en;  // From Hazard Unit

    // --- IF/ID Pipeline Register (PLR1) Outputs ---
    reg [31:0] D_PC, D_instr, D_PC_plus_4;
    wire       D_stall, D_flush; 

    // --- ID Stage Signals ---
    wire [31:0] D_imm, D_rs1_data, D_rs2_data;
    wire [4:0]  D_rs1, D_rs2, D_rd;
    wire [2:0]  D_funct3;
    wire [6:0]  D_funct7, D_opcode;
    
    // Control Signals (ID)
    wire       D_regwrite, D_memwrite, D_memread, D_branch, D_alusrc, D_memtoreg, D_jump, D_lui;
    wire [3:0] D_alucontrol;

    // --- ID/EX Pipeline Register (PLR2) Outputs ---
    reg [31:0] E_PC, E_rs1_data, E_rs2_data, E_imm, E_PC_plus_4;
    reg [4:0]  E_rs1, E_rs2, E_rd;
    reg [3:0]  E_alucontrol;
    reg        E_regwrite, E_memwrite, E_memread, E_branch, E_alusrc, E_memtoreg, E_jump, E_lui;
    wire       E_flush; 

    // --- EX Stage Signals ---
    wire [31:0] E_alu_res, E_op1, E_op2, E_target_PC;
    wire [31:0] E_forwarded_rs1, E_forwarded_rs2; 
    wire        E_zero;
    wire        E_branch_taken;
    wire [1:0]  ForwardA, ForwardB; 

    // --- EX/MA Pipeline Register (PLR3) Outputs ---
    reg [31:0] M_alu_res, M_rs2_data, M_PC_plus_4;
    reg [4:0]  M_rd;
    reg        M_regwrite, M_memwrite, M_memread, M_memtoreg, M_jump;

    // --- MA Stage Signals ---
    wire [31:0] M_mem_data;

    // --- MA/WB Pipeline Register (PLR4) Outputs ---
    reg [31:0] W_mem_data, W_alu_res, W_PC_plus_4;
    reg [4:0]  W_rd;
    reg        W_regwrite, W_memtoreg, W_jump;

    // --- WB Stage Signals ---
    wire [31:0] W_result;

    // =========================================================================
    // 1. Instruction Fetch (IF) Stage
    // =========================================================================

    // PC Register (Synchronous Reset) 
    reg [31:0] PC;
    always @(posedge clk) begin
        if (!rst_n) 
            PC <= 32'b0;
        else if (PC_en) 
            PC <= F_PC_next;
    end

    assign F_PC = PC;
    assign F_PC_plus_4 = F_PC + 4;
    
    // PC Mux 
    // Branch taken or Jump taken (calculated in EX stage)
    assign F_PC_next = (E_branch_taken) ? E_target_PC : F_PC_plus_4;

    // Instruction Memory Instance
    instruction_memory IMEM (
        .addr(F_PC),
        .instr(F_instr)
    );

    // =========================================================================
    // IF/ID Pipeline Register (PLR1)
    // =========================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            D_PC <= 0;
            D_instr <= 0;
            D_PC_plus_4 <= 0;
        end else if (D_flush) begin 
            D_PC <= 0;
            D_instr <= 0; // NOP
            D_PC_plus_4 <= 0;
        end else if (!D_stall) begin 
            D_PC <= F_PC;
            D_instr <= F_instr;
            D_PC_plus_4 <= F_PC_plus_4;
        end
    end

    // =========================================================================
    // 2. Instruction Decode (ID) Stage
    // =========================================================================

    assign D_opcode = D_instr[6:0];
    assign D_rd     = D_instr[11:7];
    assign D_funct3 = D_instr[14:12];
    assign D_rs1    = D_instr[19:15];
    assign D_rs2    = D_instr[24:20];
    assign D_funct7 = D_instr[31:25];

    // Controller
    control_unit CTRL (
        .opcode(D_opcode),
        .funct3(D_funct3),
        .funct7(D_funct7),
        .regwrite(D_regwrite),
        .memwrite(D_memwrite),
        .memread(D_memread),
        .branch(D_branch),
        .alusrc(D_alusrc),
        .memtoreg(D_memtoreg),
        .alucontrol(D_alucontrol),
        .jump(D_jump),
        .lui(D_lui)
    );

    // Register File Instance
    register_file RF (
        .clk(clk),
        .rst_n(rst_n),
        .ra1(D_rs1),
        .ra2(D_rs2),
        .wa(W_rd),
        .wd(W_result),
        .we(W_regwrite),
        .rd1(D_rs1_data),
        .rd2(D_rs2_data)
    );

    // Immediate Generator
    imm_gen EXT (
        .instr(D_instr),
        .imm_out(D_imm)
    );

    // =========================================================================
    // ID/EX Pipeline Register (PLR2)
    // =========================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            E_PC <= 0; E_rs1_data <= 0; E_rs2_data <= 0; E_imm <= 0; E_PC_plus_4 <= 0;
            E_rs1 <= 0; E_rs2 <= 0; E_rd <= 0; E_alucontrol <= 0;
            E_regwrite <= 0; E_memwrite <= 0; E_memread <= 0; 
            E_branch <= 0; E_alusrc <= 0; E_memtoreg <= 0; E_jump <= 0; E_lui <= 0;
        end else if (E_flush) begin
            E_regwrite <= 0; E_memwrite <= 0; E_memread <= 0; E_branch <= 0; E_jump <= 0;
            E_PC <= 0; E_rd <= 0; // Clear datapath elements relevant to hazards
        end else begin
            E_PC <= D_PC;
            E_rs1_data <= D_rs1_data;
            E_rs2_data <= D_rs2_data;
            E_imm <= D_imm;
            E_PC_plus_4 <= D_PC_plus_4;
            E_rs1 <= D_rs1;
            E_rs2 <= D_rs2;
            E_rd <= D_rd;
            E_alucontrol <= D_alucontrol;
            E_regwrite <= D_regwrite;
            E_memwrite <= D_memwrite;
            E_memread <= D_memread;
            E_branch <= D_branch;
            E_alusrc <= D_alusrc;
            E_memtoreg <= D_memtoreg;
            E_jump <= D_jump;
            E_lui <= D_lui;
        end
    end

    // =========================================================================
    // 3. Execution (EX) Stage
    // =========================================================================

    // Forwarding MUX A
    assign E_forwarded_rs1 = (ForwardA == 2'b10) ? M_alu_res :
                             (ForwardA == 2'b01) ? W_result :
                             E_rs1_data;

    // Forwarding MUX B
    assign E_forwarded_rs2 = (ForwardB == 2'b10) ? M_alu_res :
                             (ForwardB == 2'b01) ? W_result :
                             E_rs2_data;

    // ALU Source Selection
    // LUI Logic: If LUI is active, we ignore rs1 (treat as 0) or simply pass Imm through ALU.
    // The ALU Control 'PASS_B' (4'b1011) handles LUI by passing src_b.
    assign E_op1 = E_forwarded_rs1;
    assign E_op2 = (E_alusrc) ? E_imm : E_forwarded_rs2;

    // ALU
    alu ALU_UNIT (
        .src_a(E_op1),
        .src_b(E_op2),
        .alu_control(E_alucontrol),
        .alu_result(E_alu_res),
        .zero(E_zero)
    );

    // Branch/Jump Logic
    // Branch taken if (Branch & Zero) OR Unconditional Jump
    // For BEQ: taken if zero==1.
    // Note: If you need BNE, BLT etc., you need more branch logic. 
    // The prompt only lists "beq", "jal".
    assign E_branch_taken = (E_branch & E_zero) | E_jump; 
    assign E_target_PC = E_PC + E_imm;

    // =========================================================================
    // EX/MA Pipeline Register (PLR3)
    // =========================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            M_alu_res <= 0; M_rs2_data <= 0; M_rd <= 0; M_PC_plus_4 <= 0;
            M_regwrite <= 0; M_memwrite <= 0; M_memread <= 0; M_memtoreg <= 0; M_jump <= 0;
        end else begin
            M_alu_res <= E_alu_res;
            M_rs2_data <= E_forwarded_rs2; 
            M_rd <= E_rd;
            M_PC_plus_4 <= E_PC_plus_4;
            M_regwrite <= E_regwrite;
            M_memwrite <= E_memwrite;
            M_memread <= E_memread;
            M_memtoreg <= E_memtoreg;
            M_jump <= E_jump;
        end
    end

    // =========================================================================
    // 4. Memory Access (MA) Stage
    // =========================================================================

    // Data Memory Instance
    data_memory DMEM (
        .clk(clk),
        .addr(M_alu_res),
        .write_data(M_rs2_data),
        .mem_write(M_memwrite),
        .read_data(M_mem_data)
    );

    // =========================================================================
    // MA/WB Pipeline Register (PLR4)
    // =========================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            W_mem_data <= 0; W_alu_res <= 0; W_rd <= 0; W_PC_plus_4 <= 0;
            W_regwrite <= 0; W_memtoreg <= 0; W_jump <= 0;
        end else begin
            W_mem_data <= M_mem_data;
            W_alu_res <= M_alu_res;
            W_rd <= M_rd;
            W_PC_plus_4 <= M_PC_plus_4;
            W_regwrite <= M_regwrite;
            W_memtoreg <= M_memtoreg;
            W_jump <= M_jump;
        end
    end

    // =========================================================================
    // 5. Write Back (WB) Stage
    // =========================================================================

    // Mux supporting Mem, ALU, and Link Address (PC+4 for JAL)
    assign W_result = (W_jump)     ? W_PC_plus_4 : 
                      (W_memtoreg) ? W_mem_data : 
                                     W_alu_res;


    // =========================================================================
    // Hazard Handling Units
    // =========================================================================

    hazard_detection_unit HAZARD (
        .D_rs1(D_rs1),
        .D_rs2(D_rs2),
        .E_rd(E_rd),
        .E_memread(E_memread),
        .E_branch_taken(E_branch_taken),
        .PC_en(PC_en),      
        .D_stall(D_stall),   
        .D_flush(D_flush),   
        .E_flush(E_flush)    
    );

    forwarding_unit FWD (
        .E_rs1(E_rs1),
        .E_rs2(E_rs2),
        .M_rd(M_rd),
        .M_regwrite(M_regwrite),
        .W_rd(W_rd),
        .W_regwrite(W_regwrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

endmodule


// =============================================================================
// Module: Hazard Detection Unit
// =============================================================================
module hazard_detection_unit(
    input [4:0] D_rs1, D_rs2,
    input [4:0] E_rd,
    input       E_memread,
    input       E_branch_taken, // Includes Jump
    
    output reg  PC_en,
    output reg  D_stall,
    output reg  D_flush,
    output reg  E_flush
);
    always @(*) begin
        // Defaults
        PC_en = 1'b1;
        D_stall = 1'b0;
        D_flush = 1'b0;
        E_flush = 1'b0;

        // 1. Control Hazard (Branch/Jump Taken)
        // Flushes pipeline when branch is taken or JAL executes
        if (E_branch_taken) begin
            D_flush = 1'b1; // Flush IF/ID
            E_flush = 1'b1; // Flush ID/EX
        end
        // 2. Load-Use Hazard
        // If instruction in EX is Load and destination matches Source in ID
        else if (E_memread && (E_rd != 0) && ((E_rd == D_rs1) || (E_rd == D_rs2))) begin
            PC_en = 1'b0;   // Stall PC
            D_stall = 1'b1; // Stall IF/ID
            E_flush = 1'b1; // Flush ID/EX (bubble)
        end
    end
endmodule


// =============================================================================
// Module: Forwarding Unit
// =============================================================================
module forwarding_unit(
    input [4:0] E_rs1, E_rs2,
    input [4:0] M_rd, W_rd,
    input       M_regwrite, W_regwrite,
    output reg [1:0] ForwardA, ForwardB
);
    always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // EX Hazard (Forward from MA stage)
        if (M_regwrite && (M_rd != 0) && (M_rd == E_rs1))
            ForwardA = 2'b10;
        // MEM Hazard (Forward from WB stage)
        else if (W_regwrite && (W_rd != 0) && (W_rd == E_rs1))
            ForwardA = 2'b01;

        // EX Hazard (Forward from MA stage)
        if (M_regwrite && (M_rd != 0) && (M_rd == E_rs2))
            ForwardB = 2'b10;
        // MEM Hazard (Forward from WB stage)
        else if (W_regwrite && (W_rd != 0) && (W_rd == E_rs2))
            ForwardB = 2'b01;
    end
endmodule


// =============================================================================
// Module: Register File
// =============================================================================
module register_file(
    input clk,
    input rst_n,
    input [4:0] ra1, ra2, wa,
    input [31:0] wd,
    input we,
    output [31:0] rd1, rd2
);
    reg [31:0] registers [0:31];

    // Asynchronous Read
    assign rd1 = (ra1 == 0) ? 32'b0 : registers[ra1];
    assign rd2 = (ra2 == 0) ? 32'b0 : registers[ra2];

    // Write on Negative Edge (Half-cycle write) [cite: 170]
    // No initial block 
    always @(negedge clk) begin
        if (we && wa != 0) begin
            registers[wa] <= wd;
        end
    end
endmodule


// =============================================================================
// Module: Instruction Memory
// =============================================================================
module instruction_memory(
    input [31:0] addr,
    output [31:0] instr
);
    parameter MEM_DEPTH = 1024;
    reg [31:0] RAM [0:MEM_DEPTH-1];

    // Word Aligned Read
    assign instr = RAM[addr[31:2]]; 

endmodule


// =============================================================================
// Module: Data Memory
// =============================================================================
module data_memory(
    input clk,
    input [31:0] addr,
    input [31:0] write_data,
    input mem_write,
    output [31:0] read_data
);
    parameter MEM_DEPTH = 1024;
    reg [31:0] RAM [0:MEM_DEPTH-1];

    assign read_data = RAM[addr[31:2]];

    always @(posedge clk) begin
        if (mem_write)
            RAM[addr[31:2]] <= write_data;
    end
endmodule


// =============================================================================
// Module: Immediate Generator
// =============================================================================
module imm_gen(
    input [31:0] instr,
    output reg [31:0] imm_out
);
    wire [6:0] opcode = instr[6:0];
    
    always @(*) begin
        case (opcode)
            7'b0010011: imm_out = {{20{instr[31]}}, instr[31:20]}; // I-type (ADDI, etc)
            7'b0000011: imm_out = {{20{instr[31]}}, instr[31:20]}; // I-type (LW)
            7'b0100011: imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type (SW)
            7'b1100011: imm_out = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type (BEQ)
            7'b1101111: imm_out = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type (JAL)
            7'b0110111: imm_out = {instr[31:12], 12'b0}; // U-type (LUI)
            default:    imm_out = 32'b0;
        endcase
    end
endmodule


// =============================================================================
// Module: ALU
// =============================================================================
module alu(
    input [31:0] src_a, src_b,
    input [3:0] alu_control,
    output reg [31:0] alu_result,
    output zero
);
    wire signed [31:0] signed_a = src_a;
    wire signed [31:0] signed_b = src_b;
    wire [4:0] shamt = src_b[4:0];

    always @(*) begin
        case (alu_control)
            4'b0000: alu_result = src_a & src_b; // AND
            4'b0001: alu_result = src_a | src_b; // OR
            4'b0010: alu_result = src_a + src_b; // ADD
            4'b0011: alu_result = src_a - src_b; // SUB
            4'b0100: alu_result = (signed_a < signed_b) ? 32'b1 : 32'b0; // SLT
            4'b0101: alu_result = (src_a < src_b) ? 32'b1 : 32'b0;       // SLTU
            4'b0110: alu_result = src_a ^ src_b; // XOR
            4'b0111: alu_result = src_a << shamt; // SLL
            4'b1000: alu_result = src_a >> shamt; // SRL
            4'b1001: alu_result = signed_a >>> shamt; // SRA
            4'b1011: alu_result = src_b; // PASS_B (for LUI)
            default: alu_result = 32'b0;
        endcase
    end
    assign zero = (alu_result == 0);
endmodule


// =============================================================================
// Module: Control Unit
// =============================================================================
module control_unit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg regwrite, memwrite, memread, branch, alusrc, memtoreg, jump, lui,
    output reg [3:0] alucontrol
);
    reg [2:0] aluop; // Expanded to 3 bits

    always @(*) begin
        // Defaults
        regwrite = 0; memwrite = 0; memread = 0; branch = 0; 
        alusrc = 0; memtoreg = 0; jump = 0; lui = 0;
        aluop = 3'b000;

        case (opcode)
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
                regwrite = 1; aluop = 3'b010;
            end
            7'b0010011: begin // I-type (ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI)
                regwrite = 1; alusrc = 1; aluop = 3'b010; // Use R-type encoding logic
            end
            7'b0000011: begin // LW
                regwrite = 1; alusrc = 1; memread = 1; memtoreg = 1; aluop = 3'b000;
            end
            7'b0100011: begin // SW
                memwrite = 1; alusrc = 1; aluop = 3'b000;
            end
            7'b1100011: begin // BEQ
                branch = 1; aluop = 3'b001;
            end
            7'b0110111: begin // LUI
                regwrite = 1; alusrc = 1; lui = 1; aluop = 3'b011; 
            end
            7'b1101111: begin // JAL
                regwrite = 1; jump = 1; aluop = 3'b100; // ALU not critical for PC calc here, handled by immediate
            end
        endcase
    end

    // ALU Control Decode
    always @(*) begin
        case (aluop)
            3'b000: alucontrol = 4'b0010; // ADD (LW/SW)
            3'b001: alucontrol = 4'b0011; // SUB (BEQ comparison)
            3'b011: alucontrol = 4'b1011; // LUI (Pass B)
            3'b100: alucontrol = 4'b0010; // JAL (Don't care, but can keep ADD)
            3'b010: begin // R-Type and I-Type Arithmetic
                case (funct3)
                    3'b000: begin // ADD/SUB/ADDI
                        if (opcode == 7'b0110011 && funct7 == 7'b0100000) 
                             alucontrol = 4'b0011; // SUB
                        else alucontrol = 4'b0010; // ADD, ADDI
                    end
                    3'b001: alucontrol = 4'b0111; // SLL, SLLI
                    3'b010: alucontrol = 4'b0100; // SLT, SLTI
                    3'b011: alucontrol = 4'b0101; // SLTU, SLTIU
                    3'b100: alucontrol = 4'b0110; // XOR, XORI
                    3'b101: begin // SRL/SRA, SRLI/SRAI
                        if (funct7 == 7'b0100000) alucontrol = 4'b1001; // SRA, SRAI
                        else                      alucontrol = 4'b1000; // SRL, SRLI
                    end
                    3'b110: alucontrol = 4'b0001; // OR, ORI
                    3'b111: alucontrol = 4'b0000; // AND, ANDI
                    default: alucontrol = 4'b0000;
                endcase
            end
            default: alucontrol = 4'b0000;
        endcase
    end
endmodule