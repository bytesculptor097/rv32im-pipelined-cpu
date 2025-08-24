module if_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,        // From hazard unit
    input  wire        flush,
    input  wire [31:0] jalr_target,  // From EX stage (for JALR)

    // Control from EX stage (already resolved)
    input  wire        branch_taken, // from EX stage compare
    input  wire [31:0] pc_branch,    // PC of the branch/jump instr in EX
    input  wire [31:0] imm,          // Sign-extended immediate from EX
    input  wire        jump,         // JAL
    input  wire        jump_r,       // JALR
    input  wire [31:0] rs1value,     // For JALR
    input  wire [31:0] jump_target,  // Target address from EX (pc_branch + imm)

    // Instruction memory write port (init / load)
    input  wire [31:0] din,
    input  wire        we,

    // Outputs
    output reg  [31:0] dout,         // fetched instruction
    output reg  [31:0] next_addr,    // next PC
    output reg  [31:0] curr_addr     // current PC
);

    // Next PC selection — EX decision wins
    always @(*) begin
        if (jump_r)            next_addr = jalr_target;
        else if (jump)         next_addr = jump_target;
        else if (branch_taken) next_addr = jump_target;
        else                   next_addr = curr_addr + 32'd4;
    end

    // PC register with stall support; redirect overrides stall
 always @(posedge clk or posedge rst) begin
    if (rst)
        curr_addr <= 32'h0;
    else if (redirect)
        curr_addr <= next_addr; // redirect wins
    else if (!stall)
        curr_addr <= next_addr;
 end

    wire redirect = branch_taken || jump || jump_r;
    // Simple synchronous-read IMEM
    reg [31:0] mem [0:1023];
  always @(posedge clk) begin
    if (we)
        mem[curr_addr[11:2]] <= din;

    if (redirect) begin
        dout <= mem[next_addr[11:2]]; // fetch from target immediately
    end else if (flush) begin
        dout <= 32'h00000013;         // squash wrong-path instr
    end else if (!stall) begin
        dout <= mem[curr_addr[11:2]];
    end
    // else: hold dout during stall
  end

    initial begin
        $readmemh("instr.hex", mem);
    end

    // Debug probes (use $strobe to align with NBA updates)
    always @(posedge clk) begin
        $strobe("IF: PC=%h, instr=%h", curr_addr, dout);
         if (branch_taken || jump)
            $display("Redirect to %h due to %s (pc_branch=%h imm=%h)",
            jump_target,
            jump ? "JAL" : "Branch",
            pc_branch, imm);
    end
endmodule

