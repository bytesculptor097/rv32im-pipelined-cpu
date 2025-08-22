module if_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,        // From hazard unit

    // Control from EX stage (already resolved)
    input  wire        branch_taken, // from EX stage compare
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

    // Branch/jump targets
    wire [31:0] branch_target = pc_branch + imm;
    wire [31:0] jalr_target   = (rs1value + imm) & ~32'h1;

    // Next PC selection — EX decision wins
    always @(*) begin
        if (jump_r)            next_addr = jalr_target;
        else if (jump)         next_addr = branch_target;
        else if (branch_taken) next_addr = branch_target;
        else                   next_addr = curr_addr + 32'd4;
    end

    // PC register with stall support; redirect overrides stall
    always @(posedge clk or posedge rst) begin
        if (rst)
            curr_addr <= 32'h0;
        else if (!stall || branch_taken || jump || jump_r)
            curr_addr <= next_addr;
        // else: hold curr_addr during stall
    end

    // Simple synchronous-read IMEM
    reg [31:0] mem [0:1023];
    always @(posedge clk) begin
        if (we)
            mem[curr_addr[11:2]] <= din;

        if (rst)
            dout <= 32'h00000013;           // NOP on reset
        else if (!stall)
            dout <= mem[curr_addr[11:2]];   // fetch at current PC
        // else: hold dout during stall
    end

    initial begin
        mem[0] = 32'h123452b7; // addi x1, x0, 4
        mem[1] = 32'h67828313; // addi x2, x0, 5
        mem[2] = 32'h00001397; // mul  x3, x1, x2
        mem[3] = 32'h00438413; // add  x4, x1, x2
        mem[4] = 32'h007284b3; // mul  x7, x1, x2
        mem[5] = 32'h40740533; 
    end

    // Debug probes (use $strobe to align with NBA updates)
    always @(posedge clk) begin
        $strobe("IF: PC=%h, instr=%h", curr_addr, dout);
        if (branch_taken)
            $strobe("Redirect to %h (pc_branch=%h imm=%h)", branch_target, pc_branch, imm);
        if (jump)
            $strobe("JAL redirect to %h (pc_branch=%h imm=%h)", branch_target, pc_branch, imm);
        if (jump_r)
            $strobe("JALR redirect to %h (rs1value=%h imm=%h)", jalr_target, rs1value, imm);
    end
endmodule
