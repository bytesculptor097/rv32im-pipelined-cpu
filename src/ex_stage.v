module ex_stage (
    input wire  [1:0] ALUOp,
    input wire  [2:0] funct3,
    input wire  [6:0] funct7,
    input wire  [31:0] A,
    input wire  [31:0] B,
    output reg  [3:0] ALUControl,
    output reg  [31:0] Result,
    output reg         zero
);

always @(*) begin
    case (ALUOp)
    
        2'b00: ALUControl = 4'b0010; // ADD for lw/sw/addi
        2'b01: ALUControl = 4'b0110; // SUB for branches (e.g., beq)

        2'b10: begin // R-type
            case (funct3)
                3'b000: begin
                    if (funct7 == 7'b0100000)
                        ALUControl = 4'b0110; // SUB
                    else if (funct7 == 7'b0000001)
                        ALUControl = 4'b1010; // MUL
                    else
                        ALUControl = 4'b0010; // ADD
                end
                3'b100: begin
                    if (funct7 == 7'b0000001)
                        ALUControl = 4'b1011; // DIV
                    else
                        ALUControl = 4'b0011; // XOR
                end
                3'b101: begin
                    if (funct7 == 7'b0000001)
                        ALUControl = 4'b1100; // DIVU
                    else if (funct7 == 7'b0100000)
                        ALUControl = 4'b0101; // SRA
                    else
                        ALUControl = 4'b1001; // SRL
                end
                3'b110: begin
                    if (funct7 == 7'b0000001)
                        ALUControl = 4'b1101; // REM
                    else
                        ALUControl = 4'b0001; // OR
                end
                3'b111: begin
                    if (funct7 == 7'b0000001)
                        ALUControl = 4'b1110; // REMU
                    else
                        ALUControl = 4'b0000; // AND
                end
                3'b010: ALUControl = 4'b0111; // SLT
                3'b001: ALUControl = 4'b1000; // SLL
                3'b011: ALUControl = 4'b0100; // SLTU
                default: ALUControl = 4'b1111; // Invalid
            endcase
        end

        2'b11: ALUControl = 4'b1110; // LUI or AUIPC

        default: ALUControl = 4'b1111; // Unknown
    endcase

  //$display("ALUControl: ALUOp=%b, funct3=%b, funct7=%b => ALUControl=%b", ALUOp, funct3, funct7, ALUControl);     

    
end

    // Signed and Unsigned numbers logic
    wire signed [31:0] A_signed = $signed(A);
    wire signed [31:0] B_signed = $signed(B);

    wire [31:0] abs_A = A_signed[31] ? (~A_signed + 1) : A_signed;
    wire [31:0] abs_B = B_signed[31] ? (~B_signed + 1) : B_signed;

    wire [31:0] unsigned_mul = abs_A * abs_B;
    wire [31:0] unsigned_div = (abs_B != 0) ? abs_A / abs_B : 32'hFFFFFFFF;
    wire [31:0] unsigned_rem = (abs_B != 0) ? abs_A % abs_B : abs_A;

    wire mul_sign = A_signed[31] ^ B_signed[31];
    wire div_sign = A_signed[31] ^ B_signed[31];

    wire [31:0] signed_mul = mul_sign ? (~unsigned_mul + 1) : unsigned_mul;
    wire [31:0] signed_div = div_sign ? (~unsigned_div + 1) : unsigned_div;
    wire [31:0] signed_rem = A_signed[31] ? (~unsigned_rem + 1) : unsigned_rem;
    
//-----------------------------------------------------
// Arithmetic Logic Unit
//----------------------------------------------------- 

    always @(*) begin
        case (ALUControl)
            4'b0000: Result = A & B;                           // AND
            4'b0001: Result = A | B;                           // OR
            4'b0010: Result = A + B;                           // ADD
            4'b0110: Result = A - B;                           // SUB
            4'b0011: Result = A ^ B;                           // XOR
            4'b1000: Result = A << B[4:0];                     // SLL
            4'b1001: Result = A >> B[4:0];                     // SRL
            4'b0101: Result = A >>> B[4:0];                    // SRA
            4'b0111: Result = (A_signed < B_signed) ? 32'b1 : 32'b0; // SLT
            4'b0100: Result = (A < B) ? 32'b1 : 32'b0;         // SLTU

            // Signed MUL/DIV/REM
            4'b1010: Result = signed_mul;                      // MUL
            4'b1011: Result = (B == 0) ? 32'hFFFFFFFF : signed_div; // DIV
            4'b1101: Result = (B == 0) ? A : signed_rem;       // REM

            // Unsigned DIV/REM
            4'b1100: Result = (B == 0) ? 32'hFFFFFFFF : A / B; // DIVU
            4'b1110: Result = (B == 0) ? A : A % B;            // REMU

            default: Result = 32'b0;                           // Invalid
        endcase
        

        zero = (Result == 32'b0);    
    
    end

endmodule
