module core (
    input wire clk,
    input wire rst
);
    // Internal signals
    wire [31:0] din;    
    wire branch;
    wire [31:0] ram_out;
    wire [6:0] opcode, funct7;
    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [2:0] funct3;
    wire [31:0] imm;
    wire regwrite, alusrc, memread, memwrite, jump, jump_r;
    wire [1:0] aluop;
    wire memtoreg;
    wire [3:0] alu_control;
    wire [31:0] rs1value, rs2value;
    wire [31:0] alu_result;
    wire [31:0] mem_data;
    wire [31:0] x3_debug;
    wire [31:0] x5_debug;
    wire zero;
    wire csr_read_en, csr_write_en, is_csr;
    wire [31:0] x10_debug;
    wire [31:0] x7_debug;
    wire [31:0] x4_debug;
    wire [2:0] branch_type;
    wire [31:0] x2_debug;
    wire [3:0] alu_control_wire;
    wire [31:0] pc_next;
    wire [31:0] pc_curr;
    wire stall; 
    wire flush;
    wire is_auipc, is_lui;

// ==================================
// Pipeline register declarations
// ==================================

// ==================================
// IF/ID pipeline Register
// ==================================

reg [31:0] instr_ID;
assign flush = branch_taken_EX || jump_EX || jump_r_EX;
reg [31:0] pc_ID;

localparam [31:0] NOP = 32'h0000_0013;

always @(posedge clk or posedge rst) begin
  if (rst || flush) begin
    instr_ID <= NOP;
    pc_ID <= 32'd0;
  end else if(!stall) begin
    instr_ID <= ram_out; // fetched instruction advances every cycle
    pc_ID <= pc_curr;
  end
end

// ==================================
// ID/EX pipeline Register
// ==================================

wire[3:0]  alu_control_EX_next;
reg [4:0]  rd_EX;
reg        memtoreg_EX;
reg [31:0] rs1_val_EX;
reg [31:0] rs2_val_EX;
reg        regwrite_EX;
reg        alusrc_EX;
reg        memread_EX;
reg        memwrite_EX;
reg [2:0]  funct3_EX;
reg [6:0]  funct7_EX;
reg [4:0] rs1_idx_EX;
reg [4:0] rs2_idx_EX;
reg [31:0] pc_ID_EX;
reg [2:0] branch_type_EX;
reg        branch_EX;
reg [1:0]  aluop_EX;
reg [31:0] imm_EX;
reg jump_EX;
reg jump_r_EX;
reg is_auipc_EX;
reg is_lui_EX;

always @(posedge clk or posedge rst) begin
  if (rst || flush) begin         // flush must also bubble ID/EX
    rd_EX          <= 5'd0;
    memtoreg_EX    <= 1'b0;
    rs1_val_EX     <= 32'd0;
    rs2_val_EX     <= 32'd0;
    regwrite_EX    <= 1'b0;
    alusrc_EX      <= 1'b0;
    memread_EX     <= 1'b0;
    memwrite_EX    <= 1'b0;
    funct3_EX      <= 3'd0;
    funct7_EX      <= 7'd0;
    aluop_EX       <= 2'b0;
    imm_EX         <= 32'd0;
    rs1_idx_EX     <= 5'd0;
    rs2_idx_EX     <= 5'd0;
    pc_ID_EX       <= 32'd0;
    branch_EX      <= 1'b0;       // bubble branch
    branch_type_EX <= 3'd0;
    jump_EX        <= 1'b0;
    jump_r_EX      <= 1'b0;
    is_auipc_EX    <= 1'b0;
    is_lui_EX      <= 1'b0;
  end else if (stall) begin
    // Insert bubble on stall (hold IF/ID externally)
    rd_EX          <= 5'd0;
    memtoreg_EX    <= 1'b0;
    rs1_val_EX     <= 32'd0;
    rs2_val_EX     <= 32'd0;
    regwrite_EX    <= 1'b0;
    alusrc_EX      <= 1'b0;
    memread_EX     <= 1'b0;
    memwrite_EX    <= 1'b0;
    funct3_EX      <= 3'd0;
    funct7_EX      <= 7'd0;
    aluop_EX       <= 2'b0;
    imm_EX         <= 32'd0;
    rs1_idx_EX     <= 5'd0;
    rs2_idx_EX     <= 5'd0;
    pc_ID_EX       <= 32'd0;
    branch_EX      <= 1'b0;
    branch_type_EX <= 3'd0;
    jump_EX        <= 1'b0;
    jump_r_EX      <= 1'b0;
    is_auipc_EX    <= 1'b0;
    is_lui_EX      <= 1'b0;
    
  end else begin
    aluop_EX       <= aluop;
    rd_EX          <= rd;
    memtoreg_EX    <= memtoreg;
    rs1_val_EX     <= rs1value;
    rs2_val_EX     <= rs2value;
    regwrite_EX    <= regwrite;
    alusrc_EX      <= alusrc;
    memread_EX     <= memread;
    memwrite_EX    <= memwrite;
    funct3_EX      <= funct3;
    funct7_EX      <= funct7;
    imm_EX         <= imm;
    rs1_idx_EX     <= rs1;
    rs2_idx_EX     <= rs2;
    pc_ID_EX       <= pc_ID;
    branch_EX      <= branch;
    branch_type_EX <= branch_type;
    jump_EX        <= jump;
    jump_r_EX      <= jump_r;
    is_auipc_EX    <= is_auipc;
    is_lui_EX      <= is_lui;
  end
end

wire [31:0] alu_A =
    is_lui_EX   ? 32'd0 :
    is_auipc_EX ? pc_ID_EX :
    (forwardA == 2'b10) ? alu_result_MEM :
    (forwardA == 2'b01) ? write_data_core :
                          rs1_val_EX;

wire [31:0] alu_B =
    alusrc_EX ? imm_EX :
    (forwardB == 2'b10) ? alu_result_MEM :
    (forwardB == 2'b01) ? write_data_core :
                          rs2_val_EX;

wire [31:0] branch_B =
    (forwardB == 2'b10) ? alu_result_MEM :
    (forwardB == 2'b01) ? write_data_core :
                          rs2_val_EX;



reg branch_taken_EX;

always @* begin
  branch_taken_EX = 1'b0;
  if (branch_EX) begin
    case (branch_type_EX)
      3'b000: branch_taken_EX = (alu_A == branch_B);                      // BEQ
      3'b001: branch_taken_EX = (alu_A != branch_B);                      // BNE
      3'b100: branch_taken_EX = ($signed(alu_A) <  $signed(branch_B));    // BLT
      3'b101: branch_taken_EX = ($signed(alu_A) >= $signed(branch_B));    // BGE
      3'b110: branch_taken_EX = (alu_A <  branch_B);                      // BLTU
      3'b111: branch_taken_EX = (alu_A >= branch_B);                      // BGEU
    endcase
  end
end



// ==================================
// EX/MEM pipeline Register
// ==================================

reg [31:0] alu_result_EX;   // ALU output from EX
reg [4:0]  rd_MEM;
reg        memtoreg_MEM;
reg        memread_MEM;
reg        memwrite_MEM;
reg        regwrite_MEM;
reg [31:0] alu_result_MEM;
reg zero_EX;



always @(posedge clk or posedge rst) begin
  if (rst) begin
    alu_result_EX <= 32'd0;
    rd_MEM        <= 5'd0;
    memtoreg_MEM  <= 1'b0;
    memread_MEM   <= 1'b0;
    memwrite_MEM  <= 1'b0;
    regwrite_MEM  <= 1'b0;
    alu_result_MEM <= 32'd0;
    zero_EX       <= 1'b0;
   
  end else begin
    alu_result_EX <= alu_result;
    rd_MEM        <= rd_EX;
    memtoreg_MEM  <= memtoreg_EX;
    memread_MEM   <= memread_EX;
    memwrite_MEM  <= memwrite_EX;
    regwrite_MEM  <= regwrite_EX;
    alu_result_MEM <= alu_result;
    zero_EX       <= zero;
    
  end
end

// ==================================
// MEM/WB pipeline Register
// ==================================


reg [4:0]  rd_WB;
reg        memtoreg_WB;
reg [31:0] mem_data_WB;
reg [31:0] alu_result_WB;
reg        is_csr_WB;
reg        regwrite_WB; 

always @(posedge clk or posedge rst) begin
  if (rst) begin
    rd_WB         <= 5'd0;
    memtoreg_WB   <= 1'b0;
    mem_data_WB   <= 32'd0;
    alu_result_WB <= 32'd0;
    is_csr_WB     <= 1'b0;
    regwrite_WB   <= 1'b0;
  end else begin
    rd_WB         <= rd_MEM;
    memtoreg_WB   <= memtoreg_MEM;
    mem_data_WB   <= mem_data;
    alu_result_WB <= alu_result_MEM;
    regwrite_WB   <= regwrite_MEM;
  end
end

// Choose rs2 value with forwarding for stores
wire [31:0] rs2_for_store_EX =
    (forwardB == 2'b10) ? alu_result_MEM :
    (forwardB == 2'b01) ? write_data_core :
                          rs2_val_EX;
reg [31:0] rs2_val_MEM;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    rs2_val_MEM <= 32'd0;
  end else begin
    rs2_val_MEM <= rs2_for_store_EX;
  end
end

// Final gated regfile write enable
wire reg_write = regwrite_WB;
wire [31:0] write_data_core = (memtoreg_WB   ?  mem_data_WB   : alu_result_WB);



// -------------------------
// Module instatiations
// -------------------------
  
wire [1:0] forwardA, forwardB;

forwarding_unit fwd (
  .EX_rs1(rs1_idx_EX),
  .EX_rs2(rs2_idx_EX),
  .MEM_rd(rd_MEM),
  .MEM_regwrite(regwrite_MEM),
  .WB_rd(rd_WB),
  .WB_regwrite(reg_write),
  .forwardA(forwardA),
  .forwardB(forwardB)
);


hazard_detection_unit hdu (
    .ID_rs1(rs1),
    .ID_rs2(rs2),
    .EX_rd(rd_EX),
    .EX_memRead(memread_EX),
    .stall(stall)
);

if_stage pc_if_imem (
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .branch_taken(branch_taken_EX),
    .pc_branch(pc_ID_EX),
    .imm(imm_EX),
    .jump(jump_EX),
    .jump_r(jump_r_EX),
    .rs1value( (forwardA == 2'b10) ? alu_result_MEM : (forwardA == 2'b01) ? write_data_core : rs1_val_EX),
    .din(din),
    .we(1'b0),
    .dout(ram_out),
    .next_addr(pc_next),
    .curr_addr(pc_curr)
);


  

    id_stage id_stage_inst (
        .clk(clk),
        .instr(instr_ID),
        .reg_write(reg_write),
        .rd_wb(rd_WB),
        .wd(write_data_core),

        // Decoded outputs
        .opcode(opcode),
        .funct7(funct7),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .imm(imm),

        // Control signals
        .RegWrite(regwrite),
        .ALUSrc(alusrc),
        .MemRead(memread),
        .MemWrite(memwrite),
        .Branch(branch),
        .Jump(jump),
        .Jump_r(jump_r),
        .memtoreg(memtoreg),
        .ALUOp(aluop),
        .branch_type(branch_type),
        .AUIPC(is_auipc),
        .LUI(is_lui),
        .rs1_val(rs1value),
        .rs2_val(rs2value)
    );


    // ALU 
    ex_stage alu_inst (
        .ALUOp(aluop_EX),
        .funct3(funct3_EX),
        .funct7(funct7_EX),
        .ALUControl(alu_control),
        .A(alu_A),
        .B(alu_B),
        .Result(alu_result),
        .zero(zero)
    );



    // Data RAM
    data_ram data_ram_inst (
        .clk(clk),
        .we(memwrite_MEM), // Write in MEM stage
        .addr(alu_result_MEM),
        .din(rs2_val_MEM),
        .dout(mem_data)
    );

    // Cycle counter and debug display
    reg [31:0] cycle = 0;
    always @(posedge clk) begin
        cycle <= cycle + 1;
    end


// ===========================================================
// Pipeline debug monitor
// ===========================================================

wire sum;
assign sum = pc_ID_EX + imm_EX;
// One-line snapshot per cycle, single quoted string
always @(posedge clk) begin
    if (!rst) begin
        $strobe("C%0d | %08x | %08x | %08x | ID: x%0d x%0d x%0d %02x %01x %02x %08x | CTRL: %1b %1b %1b %1b %1b %1b %1b %1b %02b %03b | EX: %08x %08x %04b %08x %1b | MEM: %08x %08x %1b %08x | WB: x%0d %1b %08x",
            cycle, pc_curr, pc_next, instr_ID,
            rs1, rs2, rd, opcode, funct3, funct7, imm,
            regwrite, alusrc, memread, memwrite, memtoreg,
            branch, jump, jump_r, aluop, branch_type,
            alu_A, alu_B, alu_control, alu_result, zero,
            alu_result_EX, rs2_val_EX, memwrite_MEM, mem_data,
            rd_WB, reg_write, write_data_core
        );

    end
    $display("BT_EX=%b | pc_ID_EX=%h | imm_EX=%h | target=%h",
         branch_taken_EX, pc_ID_EX, imm_EX, pc_ID_EX + imm_EX);

    $display("branch_EX=%b | taken_EX=%b | taken&branch=%b",
         branch_EX, branch_taken_EX, (branch_EX && branch_taken_EX));

end



endmodule