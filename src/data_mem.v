module data_ram (
    input wire        clk,
    input wire        we,            // Write enable
    input wire [31:0] addr,          // Byte address
    input wire [31:0] din,           // Data to write
    output wire [31:0] dout          // Data read
);

    // 256 words = 1 KB of memory
    reg [31:0] mem [0:255];

    // Word-aligned read
    assign dout = mem[addr[9:2]];

    // Word-aligned write (synchronous)
    always @(posedge clk) begin
        if (we) begin
            mem[addr[9:2]] <= din;
            $display("Memory Write: Addr = %d, Data = %d", addr, dout);
            $strobe("mem[100] = %0d", mem[100]);
        end
    end



endmodule