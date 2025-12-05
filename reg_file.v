module reg_file (
    input  wire        clk,
    input  wire        we3,      // Write Enable
    input  wire [4:0]  a1,       // Read Address 1 (rs1)
    input  wire [4:0]  a2,       // Read Address 2 (rs2)
    input  wire [4:0]  a3,       // Write Address (rd)
    input  wire [31:0] wd3,      // Write Data
    output wire [31:0] rd1,      // Read Data 1
    output wire [31:0] rd2       // Read Data 2
);
    reg [31:0] rf [31:0];

    // Combinational Read (x0 is always 0)
    assign rd1 = (a1 != 0) ? rf[a1] : 32'b0;
    assign rd2 = (a2 != 0) ? rf[a2] : 32'b0;

    // Sequential Write
    always @(posedge clk) begin
        if (we3 && a3 != 0) begin
            rf[a3] <= wd3;
        end
    end
endmodule