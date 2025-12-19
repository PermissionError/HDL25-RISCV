`timescale 1ns / 1ps
`include "rv_mc.v"

module tb_rv_mc;

    // ==========================================================================
    // 1. Inputs and Signal Declarations
    // ==========================================================================
    reg clk;
    reg rst;

    // ==========================================================================
    // 2. Instantiate the Unit Under Test (UUT)
    // ==========================================================================
    rv_mc uut (
        .clk(clk),
        .rst(rst)
    );

    // ==========================================================================
    // 3. Clock Generation
    // ==========================================================================
    // 10ns period -> 100MHz clock
    always #5 clk = ~clk; 

    // ==========================================================================
    // 4. Test Sequence & Memory Loading
    // ==========================================================================
    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;

        // ----------------------------------------------------------------------
        // Load Program via Hierarchical Reference 
        // ----------------------------------------------------------------------
        // Ensure you have a file named "program.hex" in your simulation directory.
        // The path points to: uut (processor) -> MEM (memory instance) -> RAM (array)
        $display("Loading program into memory...");
        $readmemh("test.hex", uut.MEM.RAM);

        // Wait 100 ns for global reset to finish
        #100;
        rst = 0;
        $display("Reset de-asserted. Processor starting...");

        // ----------------------------------------------------------------------
        // Simulation Runtime
        // ----------------------------------------------------------------------
        // Run for 5000ns or until manual stop. 
        // Adjust this duration based on your program length.
        #5000;
        
        $display("Simulation finished by timeout.");
        $finish;
    end

    // ==========================================================================
    // 5. Waveform Dump & Debugging
    // ==========================================================================
    initial begin
        $dumpfile("rv_mc_wave.vcd");
        // Dump all signals in the testbench and sub-modules
        $dumpvars(0, tb_rv_mc);
    end

    // ==========================================================================
    // 6. Optional: Monitor Key Signals
    // ==========================================================================
    // This block prints changes in the PC and ALU Result to the console
    // to help track execution without opening the waveform viewer immediately.
    always @(posedge clk) begin
        if (!rst) begin
            // Access internal signals for debug printing
            // Note: These paths must match the instance names in rv_mc.v
            // S_FETCH is state 0. We print when an instruction is being fetched.
            if (uut.CTR.FSM_INST.current_state == 4'd0) begin
                $display("Time: %0t | Fetching at PC: %h", $time, uut.DP.pc_reg);
            end
            
            // Print when writing to Register File (Writeback stage)
            if (uut.we_rf) begin
                 $display("Time: %0t | RegFile Write: Data=%h", $time, uut.DP.result_mux);
            end
        end
    end

endmodule