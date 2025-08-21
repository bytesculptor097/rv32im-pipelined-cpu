`timescale 1ns / 1ps

module data_ram_tb;

    reg clk;
    reg we;
    reg [31:0] addr;
    reg [31:0] din;
    wire [31:0] dout;

    // Instantiate the data_ram module
    data_ram uut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns clock period

    initial begin
        $display("Starting data_ram testbench...");
        $dumpfile("data_ram_tb.vcd");
        $dumpvars(0, data_ram_tb);

        // Initialize inputs
        we   = 0;
        addr = 0;
        din  = 0;

        // Wait for a few cycles
        #10;

        // Write to address 0x00000010 (word-aligned)
        addr = 32'h00000010;
        din  = 32'hDEADBEEF;
        we   = 1;
        #10;

        // Write to address 0x00000020
        addr = 32'h00000020;
        din  = 32'hCAFEBABE;
        #10;

        // Disable write
        we = 0;

        // Read from address 0x00000010
        addr = 32'h00000010;
        #10;
        $display("Read from 0x10: %h", dout);

        // Read from address 0x00000020
        addr = 32'h00000020;
        #10;
        $display("Read from 0x20: %h", dout);

        // Read from address 0x00000000 (should be 0)
        addr = 32'h00000000;
        #10;
        $display("Read from 0x00: %h", dout);

        $finish;
    end

endmodule
