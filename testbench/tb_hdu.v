`timescale 1ns / 1ps

module hazard_detection_unit_tb;

    reg [4:0] ID_rs1, ID_rs2;
    reg [4:0] EX_rd;
    reg       EX_memRead;
    wire      stall;

    // Instantiate the hazard detection unit
    hazard_detection_unit uut (
        .ID_rs1(ID_rs1),
        .ID_rs2(ID_rs2),
        .EX_rd(EX_rd),
        .EX_memRead(EX_memRead),
        .stall(stall)
    );

    initial begin
        $display("Starting hazard detection unit testbench...");
        $dumpfile("hazard_detection_unit_tb.vcd");
        $dumpvars(0, hazard_detection_unit_tb);

        // Case 1: No hazard
        ID_rs1 = 5'd1; ID_rs2 = 5'd2;
        EX_rd  = 5'd3; EX_memRead = 1;
        #10;
        $display("Case 1: stall = %b", stall);

        // Case 2: Hazard on rs1
        EX_rd = 5'd1;
        #10;
        $display("Case 2: stall = %b", stall);

        // Case 3: Hazard on rs2
        EX_rd = 5'd2;
        #10;
        $display("Case 3: stall = %b", stall);

        // Case 4: Hazard on both rs1 and rs2
        ID_rs1 = 5'd4; ID_rs2 = 5'd4;
        EX_rd  = 5'd4;
        #10;
        $display("Case 4: stall = %b", stall);

        // Case 5: EX_memRead is 0 (no stall even if match)
        EX_memRead = 0;
        #10;
        $display("Case 5: stall = %b", stall);

        // Case 6: EX_rd is x0 (should not stall)
        EX_memRead = 1;
        EX_rd = 5'd0;
        ID_rs1 = 5'd0;
        ID_rs2 = 5'd0;
        #10;
        $display("Case 6: stall = %b", stall);

        $finish;
    end

endmodule
