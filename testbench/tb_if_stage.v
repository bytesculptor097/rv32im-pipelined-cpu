`timescale 1ns / 1ps

module if_stage_tb;

    reg clk, rst;
    reg branch_taken, jump, jump_r, we;
    reg [31:0] pc_branch, imm, rs1value, din;
    wire [31:0] dout, next_addr, curr_addr;

    // Instantiate the module
    if_stage uut (
        .clk(clk),
        .rst(rst),
        .branch_taken(branch_taken),
        .pc_branch(pc_branch),
        .imm(imm),
        .jump(jump),
        .jump_r(jump_r),
        .rs1value(rs1value),
        .din(din),
        .we(we),
        .dout(dout),
        .next_addr(next_addr),
        .curr_addr(curr_addr)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Starting IF stage testbench...");
        $dumpfile("if_stage_tb.vcd");
        $dumpvars(0, if_stage_tb);

        // Reset
        rst = 1;
        branch_taken = 0;
        jump = 0;
        jump_r = 0;
        imm = 0;
        pc_branch = 0;
        rs1value = 0;
        we = 0;
        din = 0;
        #10;

        rst = 0;

        // Let it fetch sequentially
        #20;

        // Simulate branch taken to address 0x00000020
        branch_taken = 1;
        pc_branch = curr_addr;
        imm = 32'd16; // branch target = curr_addr + 16
        #10;
        branch_taken = 0;

        // Simulate JAL to address 0x00000040
        jump = 1;
        pc_branch = curr_addr;
        imm = 32'd32;
        #10;
        jump = 0;

        // Simulate JALR to rs1 + imm
        jump_r = 1;
        rs1value = 32'd100;
        imm = 32'd4;
        #10;
        jump_r = 0;

        // Instruction memory write test
        we = 1;
        din = 32'hDEADBEEF;
        #10;
        we = 0;

        $finish;
    end

endmodule
