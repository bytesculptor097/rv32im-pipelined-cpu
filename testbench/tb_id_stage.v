`timescale 1ns / 1ps

module id_stage_tb;

    reg clk;
    reg reg_write;
    reg [4:0] rd_wb;
    reg [31:0] wd;
    reg [31:0] instr;

    wire [6:0] opcode, funct7;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [31:0] imm;
    wire RegWrite, ALUSrc, MemRead, MemWrite, Branch, Jump, Jump_r, memtoreg;
    wire [1:0] ALUOp;
    wire [2:0] branch_type;
    wire [31:0] rs1_val, rs2_val;

    // Instantiate the module
    id_stage uut (
        .clk(clk),
        .instr(instr),
        .reg_write(reg_write),
        .rd_wb(rd_wb),
        .wd(wd),
        .opcode(opcode),
        .funct7(funct7),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .imm(imm),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .Jump(Jump),
        .Jump_r(Jump_r),
        .memtoreg(memtoreg),
        .ALUOp(ALUOp),
        .branch_type(branch_type),
        .rs1_val(rs1_val),
        .rs2_val(rs2_val)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Starting ID stage testbench...");
        $dumpfile("id_stage_tb.vcd");
        $dumpvars(0, id_stage_tb);

        // Write to x1
        reg_write = 1;
        rd_wb     = 5'd1;
        wd        = 32'd123;
        #10;

        // Test R-type ADD: add x9, x2, x5
        instr = 32'b0000000_00101_00010_000_01001_0110011; // funct7 rs2 rs1 funct3 rd opcode
        #10;
        $display("R-type ADD: rs1_val = %d, rs2_val = %d, rd = %d", rs1_val, rs2_val, rd);
        $display("Control: RegWrite=%b, ALUOp=%b", RegWrite, ALUOp);

        // Test I-type ADDI: addi x9, x2, 10
        instr = 32'b000000000010_00010_000_01001_0010011;
        #10;
        $display("I-type ADDI: rs1_val = %d, imm = %d, rd = %d", rs1_val, imm, rd);
        $display("Control: RegWrite=%b, ALUSrc=%b", RegWrite, ALUSrc);

        // Test LW: lw x9, 4(x2)
        instr = 32'b000000000100_00010_010_01001_0000011;
        #10;
        $display("LW: rs1_val = %d, imm = %d, MemRead = %b", rs1_val, imm, MemRead);

        // Test SW: sw x6, 8(x2)
        instr = 32'b0000000_00110_00010_010_00100_0100011;
        #10;
        $display("SW: rs1_val = %d, rs2_val = %d, imm = %d, MemWrite = %b", rs1_val, rs2_val, imm, MemWrite);

        // Test BEQ: beq x2, x5, offset
        instr = 32'b0000000_00101_00010_000_00010_1100011;
        #10;
        $display("BEQ: rs1_val = %d, rs2_val = %d, Branch = %b, branch_type = %b", rs1_val, rs2_val, Branch, branch_type);

        // Test JAL: jal x1, offset
        instr = 32'b000000000001_00000000001_00001_1101111;
        #10;
        $display("JAL: Jump = %b, rd = %d", Jump, rd);

        $finish;
    end

endmodule
