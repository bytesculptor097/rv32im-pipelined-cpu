module forwarding_unit (
    input  wire [4:0] EX_rs1,
    input  wire [4:0] EX_rs2,
    input  wire [4:0] MEM_rd,
    input  wire       MEM_regwrite,
    input  wire [4:0] WB_rd,
    input  wire       WB_regwrite,
    output reg  [1:0] forwardA,
    output reg  [1:0] forwardB
);
// 00: use rs*_val_EX
// 10: forward from EX/MEM (alu_result_MEM)
// 01: forward from MEM/WB (write_data_core)
always @(*) begin
  forwardA = 2'b00;
  forwardB = 2'b00;

  // A
  if (MEM_regwrite && (MEM_rd != 0) && (MEM_rd == EX_rs1))
    forwardA = 2'b10;
  else if (WB_regwrite && (WB_rd != 0) && (WB_rd == EX_rs1))
    forwardA = 2'b01;

  // B
  if (MEM_regwrite && (MEM_rd != 0) && (MEM_rd == EX_rs2))
    forwardB = 2'b10;
  else if (WB_regwrite && (WB_rd != 0) && (WB_rd == EX_rs2))
    forwardB = 2'b01;
end
endmodule