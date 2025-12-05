`include "definitions.v"
`include "controller.v"
`include "alu.v"
`include "reg_file.v"
`include "pc_reg.v"
`include "sign_extend.v"

module riscv_top (
    input wire clk,
    input wire rst_n
);

    // Wires
    wire [31:0] pc, pc_next, pc_plus4, pc_target;
    wire [31:0] instr;
    wire [31:0] rd1, rd2;
    wire [31:0] imm_ext;
    wire [31:0] src_b;
    wire [31:0] alu_result;
    wire [31:0] read_data; // From Data Memory
    wire [31:0] result;    // Final write back data
    wire        zero;
    
    // Control Signals
    wire        reg_write;
    wire        alu_src;
    wire        mem_write;
    wire [1:0]  result_src;
    wire [2:0]  imm_src;
    wire [3:0]  alu_control;
    wire        branch;
    wire        jump;
    wire        pc_src;

    // ---------------------------------------------
    // Instruction Memory
    // ---------------------------------------------
    // Note: Simulating behavior. In real HW this is often a separate IP block.
    // Address is byte addressed, but we fetch words (align by 4)
    reg [31:0] imem [0:255]; 
    assign instr = imem[pc[9:2]]; 

    // ---------------------------------------------
    // Data Memory
    // ---------------------------------------------
    reg [31:0] dmem [0:255];
    always @(posedge clk) begin
        if (mem_write) dmem[alu_result[9:2]] <= rd2;
    end
    assign read_data = dmem[alu_result[9:2]];

    // ---------------------------------------------
    // Datapath Components
    // ---------------------------------------------
    
    // Program Counter
    pc_reg pcreg (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(pc)
    );

    // PC Adder (PC + 4)
    assign pc_plus4 = pc + 4;

    // Branch Target Adder (PC + Imm)
    assign pc_target = pc + imm_ext;

    // PC Mux Logic (Branching and Jumping)
    // pc_src is true if (Branch taken) OR (Jump)
    assign pc_src = (branch & zero) | jump;
    assign pc_next = (pc_src) ? pc_target : pc_plus4;

    // Register File
    reg_file rf (
        .clk(clk),
        .we3(reg_write),
        .a1(instr[19:15]),
        .a2(instr[24:20]),
        .a3(instr[11:7]),
        .wd3(result),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Sign Extender
    sign_extend ext (
        .instr(instr),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

    // ALU Source Mux 
    assign src_b = (alu_src) ? imm_ext : rd2;

    // ALU
    alu alu_unit (
        .src_a(rd1),
        .src_b(src_b),
        .alu_control(alu_control),
        .alu_result(alu_result),
        .zero(zero)
    );

    // Result Mux (Write Back)
    // Selects between ALU Result, Data Memory, or PC+4 (for JAL)
    assign result = (result_src == 2'b00) ? alu_result :
                    (result_src == 2'b01) ? read_data :
                    (result_src == 2'b10) ? pc_plus4 : 32'b0;

    // ---------------------------------------------
    // Controller
    // ---------------------------------------------
    controller c (
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .result_src(result_src),
        .imm_src(imm_src),
        .alu_control(alu_control),
        .pc_src(branch),
        .jump(jump)
    );
endmodule