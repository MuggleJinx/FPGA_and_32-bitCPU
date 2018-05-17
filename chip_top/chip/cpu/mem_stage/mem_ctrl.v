//`include "..\..\..\stddef.h"
//`include "..\cpu.h"
//`include "..\isa.h"

module mem_ctrl(
    input wire                  ex_en,
    input wire  [`MemOpBus]     ex_mem_op,
    input wire  [`WordDataBus]  ex_mem_wr_data,
    input wire  [`WordDataBus]  ex_out,

    // 内存访问接口
    input  wire [`WordDataBus]  rd_data,
    output wire [`WordAddrBus]  addr,
    output reg                  as_,
    output reg                  rw,
    output wire [`WordDataBus]  wr_data,

    // 内存访问结果
    output reg  [`WordDataBus]  out,
    output reg                  miss_align
);
    wire    [`ByteOffsetBus]    offset;

    assign wr_data  = ex_mem_wr_data;
    assign addr     = ex_out[`WordAddrLoc];
    assign offset   = ex_out[`ByteOffsetLoc];

    /*********** 内存访问的控制 ************/
    always @(*) begin
        miss_align  = `DISABLE;
        out         = `WORD_DATA_W'h0;
        as_         = `DISABLE_;
        rw          = `READ;
        // 内存访问
        if (ex_en == `ENABLE) begin
            case (ex_mem_op)
                `MEM_OP_LDW : begin
                    // 字节偏移的检测
                    if (offset == `BYTE_OFFSET_WORD) begin
                        out         = rd_data;
                        as_         = `ENABLE_;
                    end else begin
                        miss_align  = `ENABLE;
                    end
                end
                `MEM_OP_STW :  begin
                    if (offset == `BYTE_OFFSET_WORD) begin
                        rw          = `WRITE;
                        as_         = `ENABLE_;
                    end else begin
                        miss_align  = `ENABLE;
                    end
                end
                default : begin
                    out         = ex_out;
                end
            endcase
        end
    end

endmodule
