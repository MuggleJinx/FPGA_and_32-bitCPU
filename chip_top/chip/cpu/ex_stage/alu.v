//`include "..\..\..\stddef.h"
//`include "..\cpu.h"
//`include "..\isa.h"

module alu(
    input wire  [`WordDataBus]  in_0,
    input wire  [`WordDataBus]  in_1,
    input wire  [`AluOpBus]     op,

    output reg  [`WordDataBus]  out,
    output reg                  of
);
    /****** 有符号输入输出信号 ******/
    wire signed [`WordDataBus]  s_in_0 = $signed(in_0);
    wire signed [`WordDataBus]  s_in_1 = $signed(in_1);
    wire signed [`WordDataBus]  s_out  = $signed(out);

    /****** 算数逻辑运算 ********/
    always @(*) begin
        case (op)
            `ALU_OP_AND : begin
                out     = in_0 & in_1;
            end
            `ALU_OP_OR : begin
                out     = in_0 | in_1;
            end
            `ALU_OP_XOR : begin
                out     = in_0 ^ in_1;
            end
            `ALU_OP_ADDS : begin
                out     = in_0 + in_1;
            end
            `ALU_OP_ADDU : begin
                out     = in_0 + in_1;
            end
            `ALU_OP_SUBS : begin
                out     = in_0 - in_1;
            end
            `ALU_OP_SUBU : begin
                out     = in_0 - in_1;
            end
            `ALU_OP_SHRL : begin
                out     = in_0 >> in_1[`ShAmountLoc];
            end
            `ALU_OP_SHLL : begin
                out     = in_0 << in_1[`ShAmountLoc];
            end
            default      : begin
                out     = in_0;
            end
        endcase
    end

    /********* 溢出检测 ********/
    always @(*) begin
        case (op)
            `ALU_OP_ADDS : begin
                if (((s_in_0 > 0) && (s_in_1 > 0) && (s_out < 0)) ||
                    ((s_in_0 < 0) && (s_in_1 < 0) && (s_out > 0))) begin
                    of  = `ENABLE;
                end else begin
                    of  = `DISABLE;
                end
            end
            `ALU_OP_SUBS : begin
                if (((s_in_0 < 0) && (s_in_1 > 0) && (s_out > 0)) ||
                    ((s_in_0 > 0) && (s_in_1 < 0) && (s_out < 0))) begin
                    of  = `ENABLE;
                end else begin
                    of  = `DISABLE;
                end
            end
            default     : begin
                of  = `DISABLE;
            end
        endcase
    end

endmodule
