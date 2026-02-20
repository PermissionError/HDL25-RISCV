`timescale 1ns/1ps

module tb_rv_sc();

    // 1. Clock and Reset Generation
    reg clk;
    reg resetn;

    always #5 clk = ~clk; // 100 MHz clock

    // 2. DUT Signals & Instantiation
    // I-BRAM ports
    wire        i_clkb;
    wire        i_enb;
    wire [3:0]  i_web;
    wire [31:0] i_addrb;
    wire [31:0] i_dinb;
    reg  [31:0] i_doutb;

    // D-BRAM ports
    wire        d_clkb;
    wire        d_enb;
    wire [3:0]  d_web;
    wire [31:0] d_addrb;
    wire [31:0] d_dinb;
    reg  [31:0] d_doutb;

    rv_sc_ip #(.ADDR_WIDTH(12)) DUT (
        .clk(clk),
        .resetn(resetn),

        .i_clkb(i_clkb),
        .i_enb(i_enb),
        .i_web(i_web),
        .i_addrb(i_addrb),
        .i_dinb(i_dinb),
        .i_doutb(i_doutb),

        .d_clkb(d_clkb),
        .d_enb(d_enb),
        .d_web(d_web),
        .d_addrb(d_addrb),
        .d_dinb(d_dinb),
        .d_doutb(d_doutb)
    );


    // 3. Simulated Synchronous BRAMs
    reg [31:0] i_bram [0:4095]; // 16KB Instruction Memory
    reg [31:0] d_bram [0:4095]; // 16KB Data Memory

    always @(posedge i_clkb) begin
        if (i_enb) begin
            i_doutb <= i_bram[i_addrb[13:2]];
        end
    end

    always @(posedge d_clkb) begin
        if (d_enb) begin
            if (d_web == 4'b1111) begin
                d_bram[d_addrb[13:2]] <= d_dinb;
            end
            d_doutb <= d_bram[d_addrb[13:2]];
        end
    end

    // 4. Jupyter Notebook PS Simulation
    
    // Test Parameters
    localparam NUM_ELEMENTS = 32;
    localparam DATA_BASE_ADDR = 32'h00000040;
    localparam STATUS_ADDR = 32'h0000200; // Status Flag Address
    localparam MAGIC_NUM_1 = 32'hCAFEBABE;
    localparam MAGIC_NUM_2 = 32'hDEADBEAF;

    reg signed [31:0] golden_array [0:NUM_ELEMENTS-1];
    reg signed [31:0] temp;
    integer i, j, errors;

    initial begin
        // Initialize signals
        clk = 0;
        resetn = 0;
        errors = 0;

        $display("--------------------------------------------------");
        $display("[PS HOST] Phase 1: Initialization & Injection");
        
        $readmemh("test-program.hex", i_bram);
        $display("[PS HOST] Loaded sort.hex into I-BRAM.");

        $display("[PS HOST] Generating 32 random signed integers...");
        for (i = 0; i < NUM_ELEMENTS; i = i + 1) begin
            golden_array[i] = $random;
            d_bram[(DATA_BASE_ADDR >> 2) + i] = golden_array[i];
        end

        for (i = NUM_ELEMENTS - 1; i > 0; i = i - 1) begin
            for (j = 0; j < i; j = j + 1) begin
                if (golden_array[j] > golden_array[j+1]) begin
                    temp = golden_array[j];
                    golden_array[j] = golden_array[j+1];
                    golden_array[j+1] = temp;
                end
            end
        end
        
        d_bram[STATUS_ADDR >> 2] = 32'h00000000;

        $display("--------------------------------------------------");
        $display("[PS HOST] Phase 2: Execution");
        
        #100;
        resetn = 1; 
        $display("[PS HOST] Released Reset. RISC-V Core is now running...");

        // 5. Polling & Verification
        $display("[PS HOST] Phase 3: Verification (Polling Status Flag...)");
        
        // Polling loop
        while (d_bram[STATUS_ADDR >> 2] !== MAGIC_NUM_1 && d_bram[STATUS_ADDR >> 2] !== MAGIC_NUM_2) begin
    @(posedge clk); // Wait for the next clock edge before checking again
end
        
        $display("--------------------------------------------------");
        $display("[PS HOST] Magic Number Detected! Core execution finished.");
        $display("[PS HOST] Retrieving results and performing Automated Checking...");

        // Retrieve Results and Compare
        for (i = 0; i < NUM_ELEMENTS; i = i + 1) begin
            $display("DRAM: %0d, Golden: %0d", $signed(d_bram[(DATA_BASE_ADDR >> 2) + i]), golden_array[i]);
            if ($signed(d_bram[(DATA_BASE_ADDR >> 2) + i]) !== golden_array[i]) begin
                $display("FAILURE: Mismatch at index %0d. Expected: %0d, Got: %0d", 
                         i, golden_array[i], $signed(d_bram[(DATA_BASE_ADDR >> 2) + i]));
                errors = errors + 1;
            end
        end

        if (errors == 0) begin
            $display("----------------------------------------");
            $display("                SUCCESS!                ");
            $display("----------------------------------------");
        end else begin
            $display("----------------------------------------");
            $display("        TEST FAILED WITH %0d ERRORS       ", errors);
            $display("----------------------------------------");
        end

        #100 $finish;
    end

    initial begin
        $dumpfile("rv_sc.vcd");
        $dumpvars(0, tb_rv_sc);
    end

endmodule