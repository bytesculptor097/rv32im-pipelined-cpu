module if_stage (
    input  wire        clk,
    input  wire        rst,

    // Control from EX stage (already resolved)
    input  wire        branch_taken, // NEW: from EX stage compare
    input  wire [31:0] pc_branch,    // PC of the branch/jump instr in EX
    input  wire [31:0] imm,          // Sign-extended immediate from EX
    input  wire        jump,         // JAL
    input  wire        jump_r,       // JALR
    input  wire [31:0] rs1value,     // For JALR

    // Instruction memory write port (init / load)
    input  wire [31:0] din,
    input  wire        we,

    // Outputs
    output reg  [31:0] dout,         // fetched instruction
    output reg  [31:0] next_addr,    // next PC
    output reg  [31:0] curr_addr     // current PC
);

    // Branch/jump target calculation
    wire [31:0] branch_target = pc_branch + imm;
    wire [31:0] jalr_target   = (rs1value + imm) & ~32'h1;

    // Next PC selection — trust EX decision
    always @(*) begin
        if (jump_r)          next_addr = jalr_target;
        else if (jump)       next_addr = branch_target;
        else if (branch_taken) next_addr = branch_target;
        else                 next_addr = curr_addr + 32'd4;
    end

    // PC register
    always @(posedge clk or posedge rst) begin
        if (rst)
            curr_addr <= 32'h0;
        else
            curr_addr <= next_addr;
    end

    // Instruction memory (simple sync-read)
    reg [31:0] mem [0:1023];
    always @(posedge clk) begin
        if (we)
            mem[curr_addr[11:2]] <= din;
        dout <= mem[curr_addr[11:2]];
    end

initial begin
  mem[0] = 32'h0062a023;
  mem[1] = 32'h0002a383; 
  mem[2] = 32'h002384b3;
end


    // Debug probes
    always @(posedge clk) begin
        $display("IF: PC=%h, instr=%h", curr_addr, dout);
        if (branch_taken)
         $display("Redirect to %h (pc_branch=%h imm=%h)", branch_target, pc_branch, imm);
        if (jump)
         $display("JAL redirect to %h (pc_branch=%h imm=%h)", branch_target, pc_branch, imm);
        if (jump_r)
         $display("JALR redirect to %h (rs1value=%h imm=%h)", jalr_target, rs1value, imm);
    end

endmodule
