module hazard_detection_unit (
    input wire [4:0] ID_rs1, // Source register 1 of ID stage
    input wire [4:0] ID_rs2, // Source register 2 of ID stage
    input wire [4:0] EX_rd,  // Destination register of EX stage
    input wire       EX_memRead,
    output reg       stall
);

always @(*) begin
    if (EX_memRead &&
       ((EX_rd == ID_rs1) || (EX_rd == ID_rs2)) &&
       (EX_rd != 0)) begin
        stall = 1;
    end else begin
        stall = 0;
    end
end

endmodule