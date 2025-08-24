module id_stage (
    input  wire        clk,
    input  wire [31:0] instr,
    input  wire        reg_write,
    input  wire [4:0]  rd_wb,
    input  wire [31:0] wd,

    // Decoded outputs
    output wire  [6:0] opcode,
    output wire  [6:0] funct7,
    output wire  [4:0] rd,
    output wire  [4:0] rs1,
    output wire  [4:0] rs2,
    output wire  [2:0] funct3,
    output wire [31:0] imm,

    // Control signals
    output reg         RegWrite,
    output reg         ALUSrc,
    output reg         MemRead,
    output reg         MemWrite,
    output reg         Branch,
    output reg         Jump,
    output reg         Jump_r,
    output reg         memtoreg,
    output reg   [1:0] ALUOp,
    output reg   [2:0] branch_type,
    output reg         AUIPC,
    output reg         LUI,

    // Register values
    output wire [31:0] rs1_val,
    output wire [31:0] rs2_val
);

    //----------------------------------------------------------------------  
    // 1. Combinational Decode
    //----------------------------------------------------------------------  
    reg [6:0]  opcode_r, funct7_r;
    reg [4:0]  rd_r, rs1_r, rs2_r;
    reg [2:0]  funct3_r;
    reg [31:0] imm_r;


    assign opcode  = opcode_r;
    assign funct7  = funct7_r;
    assign rd      = rd_r;
    assign rs1     = rs1_r;
    assign rs2     = rs2_r;
    assign funct3  = funct3_r;
    assign imm     = imm_r;

    always @(*) begin
        // defaults
        opcode_r = instr[6:0];
        rd_r     = 5'd0;
        rs1_r    = 5'd0;
        rs2_r    = 5'd0;
        funct3_r = 3'd0;
        funct7_r = 7'd0;
        imm_r    = 32'd0;

        case (opcode_r)
            7'b0110011: begin  // R-Type
                rd_r     = instr[11:7];
                funct3_r = instr[14:12];
                rs1_r    = instr[19:15];
                rs2_r    = instr[24:20];
                funct7_r = instr[31:25];
            end

            7'b0010011,
            7'b0000011,
            7'b1100111: begin  // I-Type
                rd_r     = instr[11:7];
                funct3_r = instr[14:12];
                rs1_r    = instr[19:15];
                imm_r    = {{20{instr[31]}}, instr[31:20]};
            end

            7'b0100011: begin  // S-Type
                funct3_r = instr[14:12];
                rs1_r    = instr[19:15];
                rs2_r    = instr[24:20];
                imm_r    = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            7'b1100011: begin  // B-Type
                funct3_r = instr[14:12];
                rs1_r    = instr[19:15];
                rs2_r    = instr[24:20];
                imm_r    = {{19{instr[31]}}, instr[31], instr[7],
                            instr[30:25], instr[11:8], 1'b0};
            end

            7'b0110111,
            7'b0010111: begin  // U-Type
                rd_r   = instr[11:7];
                imm_r  = {instr[31:12], 12'd0};
            end

            7'b1101111: begin  // J-Type
                rd_r   = instr[11:7];
                imm_r  = {{11{instr[31]}}, instr[31], instr[19:12],
                          instr[20], instr[30:21], 1'b0};
            end

            default: begin
                // leave defaults
            end
        endcase
    end

    //----------------------------------------------------------------------  
    // 2. Control Unit 
    //----------------------------------------------------------------------  
    always @(*) begin
        // Default safe values
        ALUSrc      = 1'b0;
        ALUOp       = 2'b00;
        Branch      = 1'b0;
        branch_type = 3'b000;
        MemRead     = 1'b0;
        MemWrite    = 1'b0;
        RegWrite    = 1'b0;
        memtoreg    = 1'b0;
        Jump        = 1'b0;
        Jump_r      = 1'b0;
        AUIPC       = 1'b0;
        LUI         = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type
                ALUSrc   = 1'b0;
                ALUOp    = 2'b10;
                RegWrite = 1'b1;
                memtoreg = 1'b0;
            end

            7'b0010011: begin // I-type
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
                RegWrite = 1'b1;
                memtoreg = 1'b0;
            end

            7'b0000011: begin // LW
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
                MemRead  = 1'b1;
                RegWrite = 1'b1;
                memtoreg = 1'b1;
            end

            7'b0100011: begin // SW
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
                MemWrite = 1'b1;
            end

            7'b1100011: begin // Branch
                ALUSrc      = 1'b0;
                ALUOp       = 2'b01;
                Branch      = 1'b1;
                branch_type = funct3;
            end

            7'b0110111: begin // LUI
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
                RegWrite = 1'b1;
                memtoreg = 1'b0;
                LUI      = 1'b1;
            end

            7'b1101111: begin // JAL
                Jump     = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b00;
                RegWrite = 1'b1;
                memtoreg = 1'b0;
            end

            7'b1100111: begin // JALR
                Jump_r   = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
                RegWrite = 1'b1;
                memtoreg = 1'b0;
            end

            7'b0010111: begin // AUIPC
                ALUSrc   = 1'b1;
                ALUOp    = 2'b11;
                RegWrite = 1'b1;
                memtoreg = 1'b0;
                AUIPC    = 1'b1;
            end
        endcase
    end

//-----------------------------------------------------
// Register File 
//-----------------------------------------------------  
reg [31:0] regs [0:31];

// Combinational read with write-through bypass
assign rs1_val = (rs1 == 5'd0) ? 32'd0 :
                 ((reg_write && rd_wb == rs1 && rd_wb != 5'd0) ? wd : regs[rs1]);

assign rs2_val = (rs2 == 5'd0) ? 32'd0 :
                 ((reg_write && rd_wb == rs2 && rd_wb != 5'd0) ? wd : regs[rs2]);

// Synchronous write
always @(posedge clk) begin
    if (reg_write && rd_wb != 5'd0) begin
        regs[rd_wb] <= wd;
        $display("%0t | x%0d <= %h", $time, rd_wb, wd);
    end
end

// Initialization
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        regs[i] = 32'b0;
    end 
     regs[1] = 32'd3; 
     //regs[2] = 32'd20;
    // regs[5] = 32'd31; 
    // regs[6] = 32'd5; 
end

// Debug probe
always @(posedge clk) begin
    #100
    $strobe("x1 = %d, x2 = %d, x9 = %d", regs[1], regs[2], regs[9]);
end
  


endmodule