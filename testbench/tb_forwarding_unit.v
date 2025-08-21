`timescale 1ns / 1ps

module forwarding_unit_tb;

    reg [4:0] EX_rs1, EX_rs2;
    reg [4:0] MEM_rd;
    reg       MEM_regwrite;
    reg [4:0] WB_rd;
    reg       WB_regwrite;
    wire [1:0] forwardA, forwardB;

    // Instantiate the forwarding unit
    forwarding_unit uut (
        .EX_rs1(EX_rs1),
        .EX_rs2(EX_rs2),
        .MEM_rd(MEM_rd),
        .MEM_regwrite(MEM_regwrite),
        .WB_rd(WB_rd),
        .WB_regwrite(WB_regwrite),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    initial begin
        $display("Starting forwarding unit testbench...");
        $dumpfile("forwarding_unit_tb.vcd");
        $dumpvars(0, forwarding_unit_tb);

        // Case 1: No forwarding
        EX_rs1 = 5'd1; EX_rs2 = 5'd2;
        MEM_rd = 5'd3; MEM_regwrite = 1;
        WB_rd  = 5'd4; WB_regwrite  = 1;
        #10;
        $display("Case 1: forwardA = %b, forwardB = %b", forwardA, forwardB);

        // Case 2: Forward A from EX/MEM
        MEM_rd = 5'd1;
        #10;
        $display("Case 2: forwardA = %b", forwardA);

        // Case 3: Forward B from MEM/WB
        WB_rd = 5'd2;
        #10;
        $display("Case 3: forwardB = %b", forwardB);

        // Case 4: Forward both from EX/MEM
        MEM_rd = 5'd1; WB_rd = 5'd2;
        #10;
        $display("Case 4: forwardA = %b, forwardB = %b", forwardA, forwardB);

        // Case 5: Forward both from MEM/WB
        MEM_regwrite = 0;
        WB_rd = 5'd1; WB_regwrite = 1;
        EX_rs2 = 5'd1;
        #10;
        $display("Case 5: forwardA = %b, forwardB = %b", forwardA, forwardB);

        $finish;
    end

endmodule
