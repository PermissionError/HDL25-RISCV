//==============================================================================
// mux2 - 2:1 multiplexer
//==============================================================================
module mux2 #(parameter WIDTH = 32) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             sel,
    output wire [WIDTH-1:0] y
);
    assign y = sel ? b : a;
endmodule

//==============================================================================
// adder - 32-bit adder
//==============================================================================
module adder (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] y
);
    assign y = a + b;
endmodule

//==============================================================================
// alu - Arithmetic/Logic Unit
//==============================================================================
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_control,
    output reg  [31:0] y,
    output wire        zero
);
    assign zero = (y == 32'b0);

    always @(*) begin
        case (alu_control)
            4'b0000: y = a + b;                   // add
            4'b0001: y = a - b;                   // sub
            4'b0010: y = a << b[4:0];             // sll
            4'b0011: y = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // slt
            4'b0100: y = (a < b) ? 32'b1 : 32'b0; // sltu
            4'b0101: y = a ^ b;                   // xor
            4'b0110: y = a >> b[4:0];             // srl (logical)
            4'b0111: y = $signed(a) >>> b[4:0];   // sra (arithmetic)
            4'b1000: y = a | b;                   // or
            4'b1001: y = a & b;                   // and
            default: y = 32'b0;
        endcase
    end

endmodule

//==============================================================================
// sign_ext - Sign/zero extension for immediates
//==============================================================================
module sign_ext (
    input  wire [31:0] instr,
    input  wire [2:0]  imm_sel,
    output reg  [31:0] imm
);

    always @(*) begin
        case (imm_sel)

            // I-type
            3'b000: imm = {{20{instr[31]}}, instr[31:20]};

            // S-type
            3'b001: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type (branch)
            3'b010: imm = {{19{instr[31]}},
                           instr[31],
                           instr[7],
                           instr[30:25],
                           instr[11:8],
                           1'b0};

            // U-type (lui)
            3'b011: imm = {instr[31:12], 12'b0};

            // J-type (jal)
            3'b100: imm = {{11{instr[31]}},
                           instr[31],
                           instr[19:12],
                           instr[20],
                           instr[30:21],
                           1'b0};

            default: imm = 32'b0;

        endcase
    end

endmodule

//==============================================================================
// pc - Program counter
//==============================================================================
module pc (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);

    always @(posedge clk) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= next_pc;
    end

endmodule

//==============================================================================
// regfile - Register file
//==============================================================================
module regfile (
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  rs1, rs2, rd,
    input  wire [31:0] wd,
    output wire [31:0] rd1, rd2
);
    reg [31:0] regs [31:0];

    // write
    always @(posedge clk) begin
        if (we && rd != 0)
            regs[rd] <= wd;
    end

    // read
    assign rd1 = (rs1 == 0) ? 0 : regs[rs1];
    assign rd2 = (rs2 == 0) ? 0 : regs[rs2];

endmodule

//==============================================================================
// controller - Main control and ALU control
//==============================================================================
module controller (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    output reg        rf_we,
    output reg [2:0]  imm_sel,
    output reg        sel_alu_src_b,
    output reg        dmem_we,
    output reg [1:0]  sel_result,
    output reg [1:0]  alu_op,
    output reg [3:0]  alu_control,
    output reg        branch,
    output reg        jump
);

    always @(*) begin
        rf_we         = 0;
        imm_sel       = 3'b000;
        sel_alu_src_b = 0;
        dmem_we       = 0;
        sel_result    = 2'b00;
        alu_op        = 2'b00;
        branch        = 0;
        jump          = 0;

        case (opcode)
            7'b0110011: begin
                rf_we         = 1;
                sel_alu_src_b = 0;
                sel_result    = 2'b00;
                alu_op        = 2'b01;
            end
            7'b0010011: begin
                rf_we         = 1;
                imm_sel       = 3'b000;
                sel_alu_src_b = 1;
                sel_result    = 2'b00;
                alu_op        = 2'b10;
            end
            7'b0000011: begin
                rf_we         = 1;
                imm_sel       = 3'b000;
                sel_alu_src_b = 1;
                sel_result    = 2'b01;
                alu_op        = 2'b00;
            end
            7'b0100011: begin
                imm_sel       = 3'b001;
                sel_alu_src_b = 1;
                dmem_we       = 1;
                alu_op        = 2'b00;
            end
            7'b1100011: begin
                branch        = 1;
                imm_sel       = 3'b010;
                sel_alu_src_b = 0;
                alu_op        = 2'b11;
            end
            7'b1101111: begin
                jump          = 1;
                rf_we         = 1;
                imm_sel       = 3'b100;
                sel_result    = 2'b10;
            end
            7'b0110111: begin
                rf_we         = 1;
                imm_sel       = 3'b011;
                sel_result    = 2'b11;
            end
        endcase
    end

    always @(*) begin
        alu_control = 4'b0000;

        case (alu_op)

            2'b00: alu_control = 4'b0000;

            2'b01: begin
                case (funct3)
                    3'b000: alu_control = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000;
                    3'b001: alu_control = 4'b0010;
                    3'b010: alu_control = 4'b0011;
                    3'b011: alu_control = 4'b0100;
                    3'b100: alu_control = 4'b0101;
                    3'b101: alu_control = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110;
                    3'b110: alu_control = 4'b1000;
                    3'b111: alu_control = 4'b1001;
                endcase
            end

            2'b10: begin
                case (funct3)
                    3'b000: alu_control = 4'b0000;
                    3'b010: alu_control = 4'b0011;
                    3'b011: alu_control = 4'b0100;
                    3'b100: alu_control = 4'b0101;
                    3'b110: alu_control = 4'b1000;
                    3'b111: alu_control = 4'b1001;
                    3'b001: alu_control = 4'b0010;
                    3'b101: alu_control = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110;
                endcase
            end

            2'b11: begin
                case (funct3)
                    3'b000: alu_control = 4'b0001;
                    default: alu_control = 4'b0000;
                endcase
            end

        endcase
    end

endmodule

//==============================================================================
// rv_sc_ip - Top-level CPU adapted for BRAM testbench integration
//==============================================================================
module rv_sc_ip #(
    parameter ADDR_WIDTH = 12
)(
    input  wire        clk,
    input  wire        resetn,

    // Instruction BRAM Interface
    output wire        i_clkb,
    output wire        i_enb,
    output wire [3:0]  i_web,
    output wire [31:0] i_addrb,
    output wire [31:0] i_dinb,
    input  wire [31:0] i_doutb,

    // Data BRAM Interface
    output wire        d_clkb,
    output wire        d_enb,
    output wire [3:0]  d_web,
    output wire [31:0] d_addrb,
    output wire [31:0] d_dinb,
    input  wire [31:0] d_doutb
);

    // 1. Core Signals & Active-High Reset Conversion
    wire reset = ~resetn; 
    
    // 2. Internal Datapath Wires
    wire [31:0] pc, next_pc, pc_plus_4, pc_target;
    
    // Incoming BRAM data
    wire [31:0] instr   = i_doutb;
    wire [31:0] dmem_rd = d_doutb;
    
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [6:0] funct7 = instr[31:25];

    wire        rf_we, sel_alu_src_b, dmem_we;
    wire [2:0]  imm_sel;
    wire [1:0]  sel_result;
    wire [1:0]  alu_op;
    wire [3:0]  alu_control;
    wire        branch, jump;

    wire [31:0] rd1, rd2;
    wire [31:0] imm;
    wire [31:0] alu_b_src;
    wire [31:0] alu_y;
    wire        alu_zero;
    wire [31:0] result;
    wire        take_branch;

    // 3. BRAM Interface Mapping
    // We invert the BRAM clock so synchronous reads happen mid-cycle. 
    // This perfectly emulates asynchronous memory behavior for a single-cycle core.
    assign i_clkb  = ~clk;
    assign i_enb   = 1'b1;
    assign i_web   = 4'b0000;
    assign i_addrb = pc;
    assign i_dinb  = 32'b0;

    assign d_clkb  = ~clk;
    assign d_enb   = 1'b1;
    // Write-enable needs to be broadcast to all 4 byte-enables if dmem_we is high
    assign d_web   = dmem_we ? 4'b1111 : 4'b0000;
    assign d_addrb = alu_y;
    assign d_dinb  = rd2;

    

    

    // 4. Sub-Module Instantiations
    pc u_pc (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    adder u_pc_adder (
        .a(pc),
        .b(32'd4),
        .y(pc_plus_4)
    );

    controller u_controller (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .rf_we(rf_we),
        .imm_sel(imm_sel),
        .sel_alu_src_b(sel_alu_src_b),
        .dmem_we(dmem_we),
        .sel_result(sel_result),
        .alu_control(alu_control),
        .branch(branch),
        .jump(jump)
    );

    regfile u_regfile (
        .clk(clk),
        .we(rf_we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(result),
        .rd1(rd1),
        .rd2(rd2)
    );

    sign_ext u_sign_ext (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    mux2 #(32) u_alu_src_mux (
        .a(rd2),
        .b(imm),
        .sel(sel_alu_src_b),
        .y(alu_b_src)
    );

    alu u_alu (
        .a(rd1),
        .b(alu_b_src),
        .alu_control(alu_control),
        .y(alu_y),
        .zero(alu_zero)
    );

    // Write-back Muxes
    wire [31:0] sel_res0 = (sel_result == 2'b00) ? alu_y   :
                           (sel_result == 2'b01) ? dmem_rd : 32'b0;

    wire [31:0] sel_res1 = (sel_result == 2'b10) ? pc_plus_4 :
                           (sel_result == 2'b11) ? imm       : 32'b0;

    assign result = (sel_result[1] == 1'b0) ? sel_res0 : sel_res1;

    // Branch Logic
    adder u_branch_adder (
        .a(pc),
        .b(imm),
        .y(pc_target)
    );

    assign take_branch = branch && alu_zero;

    // Next PC Selection
    assign next_pc = jump        ? pc_target :
                     take_branch ? pc_target :
                                   pc_plus_4;

endmodule