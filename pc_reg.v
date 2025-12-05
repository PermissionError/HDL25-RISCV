module pc_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);
    // Reset to 0 as per typical simulation start
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pc <= 32'b0;
        else        pc <= pc_next;
    end
endmodule