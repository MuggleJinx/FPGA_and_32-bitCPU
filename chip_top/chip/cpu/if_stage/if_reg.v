//`include "..\..\..\stddef.h"
//`include "..\cpu.h"
//`include "..\isa.h"

// 内存访问控制
module if_reg(
    input wire                  clk,
    input wire                  reset_,

    input wire  [`WordDataBus]  insn,

    //流水线控制信号
    input  wire                 stall,
    input  wire                 flush,
    input  wire [`WordAddrBus]  new_pc,
    input  wire                 br_taken,
    input  wire [`WordAddrBus]  br_addr,

    //IF/ID 流水线寄存器
    output reg  [`WordAddrBus]  if_pc,
    output reg  [`WordDataBus]  if_insn,
    output reg                  if_en
);

    always @(posedge clk or negedge reset_) begin
        if (reset_ == `ENABLE_) begin
            if_pc       <=  #1 `RESET_VECTOR;
            if_insn     <=  #1 `ISA_NOP;
            if_en       <=  #1 `DISABLE;
        end else begin
            // 更新流水线寄存器
            if (stall == `DISABLE) begin
                if (flush == `ENABLE) begin
                    if_pc       <=  #1 new_pc;
                    if_insn     <=  #1 `ISA_NOP;
                    if_en       <=  #1 `DISABLE;
                end else if (br_taken == `ENABLE) begin
                    if_pc       <=  #1 br_addr;
                    if_insn     <=  #1 insn;
                    if_en       <=  #1 `ENABLE;
                end else begin
                    if_pc       <=  #1 if_pc + 1'd1;
                    if_insn     <=  #1 insn;
                    if_en       <=  #1 `ENABLE;
                end
            end
        end
    end

endmodule
