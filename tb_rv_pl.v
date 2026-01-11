`include "rv_pl.v"
`timescale 1ns / 1ps

module tb_rv_pl;

    // =========================================================================
    // 1. Signals & Configuration
    // =========================================================================
    reg clk;
    reg rst_n;
    
    integer i;
    parameter MAX_CYCLES = 150; // Increased to accommodate the longer test program

    // =========================================================================
    // 2. DUT Instantiation
    // =========================================================================
    rv_pl dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // =========================================================================
    // 3. Clock Generation (100MHz -> 10ns period)
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // 4. Main Test Procedure
    // =========================================================================
    initial begin
        // Setup Waveform dumping
        $dumpfile("rv_pl_waveform.vcd");
        $dumpvars(0, tb_rv_pl);
        
        // Initialize signals
        clk = 0;
        rst_n = 0;

        // --- Memory Initialization ---
        // Ensure you compile the assembly to 'program.hex' before running
        $display("Loading program.hex...");
        // Note: Make sure the file exists or this will warning
        $readmemh("program.hex", dut.IMEM.RAM);

        // Initialize Data Memory and Registers for clean logs
        for (i = 0; i < 1024; i = i + 1) dut.DMEM.RAM[i] = 32'h0;
        for (i = 0; i < 32; i = i + 1) dut.RF.registers[i] = 32'h0;

        // --- Reset Sequence ---
        $display("Resetting Processor...");
        #20;
        rst_n = 1;
        $display("Processor Running...");

        // --- Run Simulation ---
        # (MAX_CYCLES * 10); 

        // --- End Simulation ---
        $display("\n--- Simulation Time Limit Reached ---");
        print_registers();
        $finish;
    end

    // =========================================================================
    // 5. Monitoring & Debugging (FIXED)
    // =========================================================================
    
    always @(posedge clk) begin
        if (rst_n) begin
            // 1. Check Write Back (WB) Stage for Register Writes
            // These instructions have effectively retired.
            if (dut.W_regwrite && dut.W_rd != 0) begin
                 $display("[%0t ns] WB: Reg x%0d <= 0x%h", $time, dut.W_rd, dut.W_result);
            end 
            
            // 2. Check Memory Access (MA) Stage for Store Completions
            // Stores retire at MA, so we check M_memwrite here.
            else if (dut.M_memwrite) begin
                 $display("[%0t ns] MA: Memory Store [Addr: 0x%h] <= Data: 0x%h", 
                          $time, dut.M_alu_res, dut.M_rs2_data);
            end 
            
            // 3. Check Jumps (Retired at WB for PC update context, though typically handled earlier)
            else if (dut.W_jump) begin
                 $display("[%0t ns] WB: Jump Link Addr Saved", $time);
            end

            // 4. Hazard Debugging
            if (dut.HAZARD.D_stall) 
                $display("\t\t>> STALL (Load-Use) <<");
            
            if (dut.HAZARD.E_flush) 
                $display("\t\t>> FLUSH (Control/Branch) <<");
        end
    end

    // Task to print register file contents
    task print_registers;
        begin
            $display("\n==========================================");
            $display(" Final Register File State");
            $display("==========================================");
            for (i = 0; i < 32; i = i + 1) begin
                if (i % 4 == 0) $write("\n x%02d: ", i);
                $write("%h ", dut.RF.registers[i]);
            end
            $display("\n==========================================\n");
            $display("Final Memory[0]: %h", dut.DMEM.RAM[0]);
        end
    endtask

endmodule