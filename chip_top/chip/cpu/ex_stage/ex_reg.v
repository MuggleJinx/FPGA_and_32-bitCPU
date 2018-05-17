//`include "..\..\..\stddef.h"
//`include "..\cpu.h"
//`include "..\isa.h"

module ex_reg(
    input wire                  clk,
    input wire                  reset_,

    input wire  [`WordDataBus]  alu_out,
    input wire                  alu_of,

    input wire                  stall,
    input wire                  flush,
    input wire                  int_detect,

    input wire  [`WordAddrBus]  id_pc,
    input wire                  id_en,
    input wire                  id_br_flag,
    input wire  [`MemOpBus]     id_mem_op,
    input wire  [`WordDataBus]  id_mem_wr_data,
    input wire  [`CtrlOpBus]    id_ctrl_op,
    input wire  [`RegAddrBus]   id_dst_addr,
    input wire                  id_gpr_we_,
    input wire  [`IsaExpBus]    id_exp_code,

    output reg  [`WordAddrBus]  ex_pc,
    output reg                  ex_en,
    output reg                  ex_br_flag,
    output reg  [`MemOpBus]     ex_mem_op,
    output reg  [`WordDataBus]  ex_mem_wr_data,
    output reg  [`CtrlOpBus]    ex_ctrl_op,
    output reg  [`RegAddrBus]   ex_dst_addr,
    output reg                  ex_gpr_we_,
    output reg  [`IsaExpBus]    ex_exp_code,
    output reg  [`WordDataBus]  ex_out
);
    always @ (posedge clk or negedge reset_) begin
        if (reset_ == `ENABLE_) begin
            ex_pc           <= #1 `WORD_ADDR_W'h0;
            ex_en           <= #1 `DISABLE;
            ex_br_flag      <= #1 `DISABLE;
            ex_mem_op       <= #1 `MEM_OP_NOP;
            ex_mem_wr_data  <= #1 `WORD_DATA_W'h0;
            ex_ctrl_op      <= #1 `CTRL_OP_NOP;
            ex_dst_addr     <= #1 `REG_ADDR_W'd0;
            ex_gpr_we_      <= #1 `DISABLE_;
            ex_exp_code     <= #1 `ISA_EXP_NO_EXP;
            ex_out          <= #1 `WORD_DATA_W'h0;
        end else begin
            if (stall == `DISABLE) begin
                if (flush == `ENABLE) begin
                    ex_pc           <= #1 `WORD_ADDR_W'h0;
                    ex_en           <= #1 `DISABLE;
                    ex_br_flag      <= #1 `DISABLE;
                    ex_mem_op       <= #1 `MEM_OP_NOP;
                    ex_mem_wr_data  <= #1 `WORD_DATA_W'h0;
                    ex_ctrl_op      <= #1 `CTRL_OP_NOP;
                    ex_dst_addr     <= #1 `REG_ADDR_W'd0;
                    ex_gpr_we_      <= #1 `DISABLE_;
                    ex_exp_code     <= #1 `ISA_EXP_NO_EXP;
                    ex_out          <= #1 `WORD_DATA_W'h0;
                end else if (int_detect == `ENABLE) begin //中断检测
                    ex_pc           <= #1 id_pc;
                    ex_en           <= #1 id_en;
                    ex_br_flag      <= #1 id_br_flag;
                    ex_mem_op       <= #1 `MEM_OP_NOP;
                    ex_mem_wr_data  <= #1 `WORD_DATA_W'h0;
                    ex_ctrl_op      <= #1 `CTRL_OP_NOP;
                    ex_dst_addr     <= #1 `REG_ADDR_W'd0;
                    ex_gpr_we_      <= #1 `DISABLE_;
                    ex_exp_code     <= #1 `ISA_EXP_EXT_INT;
                    ex_out          <= #1 `WORD_DATA_W'h0;
                end else if (alu_of == `ENABLE) begin // 算术溢出
                    ex_pc           <= #1 id_pc;
                    ex_en           <= #1 id_en;
                    ex_br_flag      <= #1 id_br_flag;
                    ex_mem_op       <= #1 `MEM_OP_NOP;
                    ex_mem_wr_data  <= #1 `WORD_DATA_W'h0;
                    ex_ctrl_op      <= #1 `CTRL_OP_NOP;
                    ex_dst_addr     <= #1 `REG_ADDR_W'd0;
                    ex_gpr_we_      <= #1 `DISABLE_;
                    ex_exp_code     <= #1 `ISA_EXP_OVERFLOW;
                    ex_out          <= #1 `WORD_DATA_W'h0;
                end else begin
                    ex_pc           <= #1 id_pc;
                    ex_en           <= #1 id_en;
                    ex_br_flag      <= #1 id_br_flag;
                    ex_mem_op       <= #1 id_mem_op;
                    ex_mem_wr_data  <= #1 id_mem_wr_data;
                    ex_ctrl_op      <= #1 id_ctrl_op;
                    ex_dst_addr     <= #1 id_dst_addr;
                    ex_gpr_we_      <= #1 id_gpr_we_;
                    ex_exp_code     <= #1 id_exp_code;
                    ex_out          <= #1 alu_out;
                end
            end
        end
    end

endmodule
