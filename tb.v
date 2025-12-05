`timescale 1ns / 1ps
`include "riscv_top.v"

module tb_riscv();

    reg clk;
    reg rst_n;
    wire [31:0] test_pc;
    wire [31:0] test_instr;

    // 1. Instantiate the Device Under Test
    riscv_top dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // 2. Generate Clock (10ns period)
    always #5 clk = ~clk;

    // 3. Simulation Control
    initial begin
        // Initialize Signals
        clk = 0;
        rst_n = 0;

        // Initialize Instruction Memory from Hex file
        $readmemh("test.hex", dut.imem);

        // Reset Sequence
        #20;
        rst_n = 1;  // Release reset
        
        // Run simulation for enough time to complete the program
        #5000;
        
        $display("-------------------------------------------------------------");
        $display("Verification Report (Updated Test)");
        $display("-------------------------------------------------------------");
        $display("Register File Content:");
        $display("x1 (Base Addr): %h (Expected: 10000000)", dut.rf.rf[1]);
        $display("x2 (10):        %h (Expected: 0000000a)", dut.rf.rf[2]);
        $display("x3 (-5):        %h (Expected: fffffffb)", dut.rf.rf[3]);
        $display("x4 (ADDI):      %h (Expected: 0000001e)", dut.rf.rf[4]);
        $display("x5 (XORI):      %h (Expected: fffffff5)", dut.rf.rf[5]);
        $display("x6 (ANDI):      %h (Expected: 00000005)", dut.rf.rf[6]);
        $display("x7 (ORI):       %h (Expected: 00000015)", dut.rf.rf[7]);
        $display("x8 (SLLI):      %h (Expected: 00000028)", dut.rf.rf[8]);
        $display("x9 (SRLI):      %h (Expected: 3ffffffe)", dut.rf.rf[9]);
        $display("x10 (SRAI):     %h (Expected: fffffffe)", dut.rf.rf[10]);
        $display("x11 (SLTI):     %h (Expected: 00000001)", dut.rf.rf[11]);
        $display("x12 (SLTIU):    %h (Expected: 00000000)", dut.rf.rf[12]);
        $display("x13 (ADD):      %h (Expected: 00000005)", dut.rf.rf[13]);
        $display("x14 (SUB):      %h (Expected: 0000000f)", dut.rf.rf[14]);
        $display("x15 (AND):      %h (Expected: 0000000a)", dut.rf.rf[15]);
        $display("x16 (OR):       %h (Expected: fffffffb)", dut.rf.rf[16]);
        $display("x17 (XOR):      %h (Expected: fffffff1)", dut.rf.rf[17]);
        $display("x18 (1):        %h (Expected: 00000001)", dut.rf.rf[18]);
        $display("x19 (SLL):      %h (Expected: 00000014)", dut.rf.rf[19]);
        $display("x20 (SRL):      %h (Expected: 7ffffffd)", dut.rf.rf[20]);
        $display("x21 (SRA):      %h (Expected: fffffffd)", dut.rf.rf[21]);
        $display("x22 (SLT):      %h (Expected: 00000001)", dut.rf.rf[22]);
        $display("x23 (SLTU):     %h (Expected: 00000000)", dut.rf.rf[23]);
        $display("x24 (LW):       %h (Expected: 00000001)", dut.rf.rf[24]);
        $display("x25 (PASS):     %h (Expected: 00000001)", dut.rf.rf[25]);
        $display("-------------------------------------------------------------");

        $display("Simulation finished.");
        $finish;
    end

    // 4. Monitoring 
    initial begin
        $monitor("Time: %t | PC: %h | Instr: %h | Result: %h | RegWrite: %b", 
                 $time, dut.pc, dut.instr, dut.result, dut.reg_write);
    end

    // 5. Waveform Dump
    initial begin
        $dumpfile("riscv_wave.vcd");
        $dumpvars(0, tb_riscv);
        // Dump the registers specifically to see data changes
        for (integer i = 0; i < 32; i = i + 1) begin
            $dumpvars(0, dut.rf.rf[i]);
        end
    end

endmodule