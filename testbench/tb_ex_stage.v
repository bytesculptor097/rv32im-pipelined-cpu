`timescale 1ns / 1ps

module ex_stage_tb;

    reg [1:0]  ALUOp;
    reg [2:0]  funct3;
    reg [6:0]  funct7;
    reg [31:0] A, B;
    wire [3:0] ALUControl;
    wire [31:0] Result;
    wire       zero;

    // Instantiate the module
    ex_stage uut (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .Result(Result),
        .zero(zero)
    );

    initial begin
        $display("Starting EX stage testbench...");
        $dumpfile("ex_stage_tb.vcd");
        $dumpvars(0, ex_stage_tb);

        // Test ADD (lw/sw/addi)
        ALUOp   = 2'b00;
        funct3  = 3'b000;
        funct7  = 7'b0000000;
        A       = 32'd10;
        B       = 32'd5;
        #10;
        $display("ADD: Result = %d, Zero = %b", Result, zero);

        // Test SUB (branch)
        ALUOp   = 2'b01;
        A       = 32'd10;
        B       = 32'd10;
        #10;
        $display("SUB: Result = %d, Zero = %b", Result, zero);

        // Test R-type MUL
        ALUOp   = 2'b10;
        funct3  = 3'b000;
        funct7  = 7'b0000001;
        A       = 32'd6;
        B       = 32'd7;
        #10;
        $display("MUL: Result = %d", Result);

        // Test R-type DIV
        funct3  = 3'b100;
        funct7  = 7'b0000001;
        A       = -32'd20;
        B       = 32'd4;
        #10;
        $display("DIV: Result = %d", Result);

        // Test SLT
        funct3  = 3'b010;
        funct7  = 7'b0000000;
        A       = -32'd1;
        B       = 32'd1;
        #10;
        $display("SLT: Result = %d", Result);

        // Test REMU
        ALUOp   = 2'b10;
        funct3  = 3'b110;
        funct7  = 7'b0000001;
        A       = 32'd10;
        B       = 32'd3;
        #10;
        $display("REMU: Result = %d", Result);

        // Test LUI/AUIPC
        ALUOp   = 2'b11;
        A       = 32'd123;
        B       = 32'd456;
        #10;
        $display("LUI/AUIPC: Result = %d", Result);

        $finish;
    end

endmodule
