//`include "..\..\..\stddef.h"
//`include "..\cpu.h"
//`include "..\isa.h"

module id_reg(
    input wire                  clk,
    input wire                  reset_,

    // 解码结果
    input wire  [`AluOpBus]     alu_op,
    input wire  [`WordDataBus]  alu_in_0,
    input wire  [`WordDataBus]  alu_in_1,
    input wire                  br_flag,
    input wire  [`MemOpBus]     mem_op,
    input wire  [`WordDataBus]  mem_wr_data,
    input wire  [`CtrlOpBus]    ctrl_op,
    input wire  [`RegAddrBus]   dst_addr,
    input wire                  gpr_we_,
    input wire  [`IsaExpBus]    exp_code,

    // 流水线控制信号
    input wire                  stall,
    input wire                  flush,

    // IF/ID 流水线寄存器
    input wire  [`WordAddrBus]  if_pc,
    input wire                  if_en,

    // ID/EX 流水线寄存器
    output reg  [`WordAddrBus]  id_pc,
    output reg                  id_en,
    output reg  [`AluOpBus]     id_alu_op,
    output reg  [`WordDataBus]  id_alu_in_0,
    output reg  [`WordDataBus]  id_alu_in_1,
    output reg                  id_br_flag,
    output reg  [`MemOpBus]     id_mem_op,
    output reg  [`WordDataBus]  id_mem_wr_data,
    output reg  [`CtrlOpBus]    id_ctrl_op,
    output reg  [`RegAddrBus]   id_dst_addr,
    output reg                  id_gpr_we_,
    output reg  [`IsaExpBus]    id_exp_code
);

    always @ (posedge clk or negedge reset_) begin
        if (reset_ == `ENABLE_) begin
            id_pc           <= #1 `WORD_ADDR_W'h0;
            id_en           <= #1 `DISABLE;
            id_alu_op       <= #1 `ALU_OP_NOP;
            id_alu_in_0     <= #1 `WORD_DATA_W'h0;
            id_alu_in_1     <= #1 `WORD_DATA_W'h0;
            id_br_flag      <= #1 `DISABLE;
            id_mem_op       <= #1 `MEM_OP_NOP;
            id_mem_wr_data  <= #1 `WORD_DATA_W'h0;
            id_ctrl_op      <= #1 `CTRL_OP_NOP;
            id_dst_addr     <= #1 `REG_ADDR_W'h0;
            id_gpr_we_      <= #1 `DISABLE_;
            id_exp_code     <= #1 `ISA_EXP_NO_EXP;
        end else begin
            // 流水线寄存器的更新
            if (stall == `DISABLE) begin
                if (flush == `ENABLE) begin
                    id_pc           <= #1 `WORD_ADDR_W'h0;
                    id_en           <= #1 `DISABLE;
                    id_alu_op       <= #1 `ALU_OP_NOP;
                    id_alu_in_0     <= #1 `WORD_DATA_W'h0;
                    id_alu_in_1     <= #1 `WORD_DATA_W'h0;
                    id_br_flag      <= #1 `DISABLE;
                    id_mem_op       <= #1 `MEM_OP_NOP;
                    id_mem_wr_data  <= #1 `WORD_DATA_W'h0;
                    id_ctrl_op      <= #1 `CTRL_OP_NOP;
                    id_dst_addr     <= #1 `REG_ADDR_W'h0;
                    id_gpr_we_      <= #1 `DISABLE_;
                    id_exp_code     <= #1 `ISA_EXP_NO_EXP;
                end else begin
                    id_pc           <= #1 if_pc;
                    id_en           <= #1 if_en;
                    id_alu_op       <= #1 alu_op;
                    id_alu_in_0     <= #1 alu_in_0;
                    id_alu_in_1     <= #1 alu_in_1;
                    id_br_flag      <= #1 br_flag;
                    id_mem_op       <= #1 mem_op;
                    id_mem_wr_data  <= #1 mem_wr_data;
                    id_ctrl_op      <= #1 ctrl_op;
                    id_dst_addr     <= #1 dst_addr;
                    id_gpr_we_      <= #1 gpr_we_;
                    id_exp_code     <= #1 exp_code;
                end
            end
        end
    end

endmodule
