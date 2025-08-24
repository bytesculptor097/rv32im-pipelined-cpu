module tb_core;
    reg clk;
    reg rst;
    wire [31:0] x5_debug;

    // Instantiate your core
    core uut (
        .clk(clk),
        .rst(rst)
        // .x5_debug(x5_debug) // Uncomment if needed for debug
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units per cycle
    end

    // Simulation control
    initial begin
        rst = 1;
        #3 rst = 0; // Deassert reset BEFORE first rising edge at time 5

        // Run for a few cycles
        #150;

        $finish;
    end
endmodule