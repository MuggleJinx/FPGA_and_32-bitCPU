//`include "..\..\..\stddef.h"
//`include "..\cpu.h"
//`include "..\isa.h"

module mem_reg(
    input wire                  clk,
    input wire                  reset_,

    // 内存访问结果
    input  wire [`WordDataBus]  out,
    input wire                  miss_align,

    input  wire                 stall,
    input  wire                 flush,

    input wire  [`WordAddrBus]  ex_pc,
    input wire                  ex_en,
    input wire                  ex_br_flag,
    input wire  [`CtrlOpBus]    ex_ctrl_op,
    input wire  [`RegAddrBus]   ex_dst_addr,
    input wire                  ex_gpr_we_,
    input wire  [`IsaExpBus]    ex_exp_code,

    output reg  [`WordAddrBus]  mem_pc,
    output reg                  mem_en,
    output reg                  mem_br_flag,
    output reg  [`CtrlOpBus]    mem_ctrl_op,
    output reg  [`RegAddrBus]   mem_dst_addr,
    output reg                  mem_gpr_we_,
    output reg  [`IsaExpBus]    mem_exp_code,
    output reg  [`WordDataBus]  mem_out
);

    /**** 流水线寄存器 ******/
    always @ (posedge clk or negedge reset_) begin
        if (reset_ == `ENABLE_) begin
            mem_pc           <= #1 `WORD_ADDR_W'h0;
            mem_en           <= #1 `DISABLE;
            mem_br_flag      <= #1 `DISABLE;
            mem_ctrl_op      <= #1 `CTRL_OP_NOP;
            mem_dst_addr     <= #1 `REG_ADDR_W'h0;
            mem_gpr_we_      <= #1 `DISABLE_;
            mem_exp_code     <= #1 `ISA_EXP_NO_EXP;
            mem_out          <= #1 `WORD_DATA_W'h0;
        end else begin
            if (stall == `DISABLE) begin
                if (flush == `ENABLE) begin
                    mem_pc           <= #1 `WORD_ADDR_W'h0;
                    mem_en           <= #1 `DISABLE;
                    mem_br_flag      <= #1 `DISABLE;
                    mem_ctrl_op      <= #1 `CTRL_OP_NOP;
                    mem_dst_addr     <= #1 `REG_ADDR_W'h0;
                    mem_gpr_we_      <= #1 `DISABLE_;
                    mem_exp_code     <= #1 `ISA_EXP_NO_EXP;
                    mem_out          <= #1 `WORD_DATA_W'h0;
                end else if (miss_align == `ENABLE) begin
                    mem_pc           <= #1 ex_pc;
                    mem_en           <= #1 ex_en;
                    mem_br_flag      <= #1 ex_br_flag;
                    mem_ctrl_op      <= #1 `CTRL_OP_NOP;
                    mem_dst_addr     <= #1 `REG_ADDR_W'h0;
                    mem_gpr_we_      <= #1 `DISABLE_;
                    mem_exp_code     <= #1 `ISA_EXP_MISS_ALIGN;
                    mem_out          <= #1 `WORD_DATA_W'h0;
                end else begin
                    mem_pc           <= #1 ex_pc;
                    mem_en           <= #1 ex_en;
                    mem_br_flag      <= #1 ex_br_flag;
                    mem_ctrl_op      <= #1 ex_ctrl_op;
                    mem_dst_addr     <= #1 ex_dst_addr;
                    mem_gpr_we_      <= #1 ex_gpr_we_;
                    mem_exp_code     <= #1 ex_exp_code;
                    mem_out          <= #1 out;
                end
            end
        end
    end
endmodule
