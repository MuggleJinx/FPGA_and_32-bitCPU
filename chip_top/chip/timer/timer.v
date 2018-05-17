`include "timer.h"
`include "stddef.h"

module timer(
    input   wire        clk,
    input   wire        reset_,

    // 总线接口
    input  wire                 cs_,
    input  wire                 as_,
    input  wire                 rw,
    input  wire [`WordAddrBus] addr,
    input  wire [`WordDataBus]  wr_data,
    output reg  [`WordDataBus]  rd_data,
    output reg                  rdy_,

    //控制寄存器1
    output reg                  irq
);

    wire [`TimerAddrBus]      timer_addr;
    assign timer_addr = addr[`TimerAddrLoc];

    // 0
    reg                         mode;
    reg                         start;
    // 2
    reg     [`WordAddrBus]      expr_val;
    // 3
    reg     [`WordAddrBus]      counter;

//    wire  expr_flag;
    /****** 计时完成标志位 ********/
    wire expr_flag  = ((start == `ENABLE) && (counter == expr_val)) ?
                      `ENABLE : `DISABLE;

    /******* 定时器控制 ********/
    always @ (posedge clk or negedge reset_) begin
        if (reset_ == `ENABLE_) begin
            rd_data     <= #1 `WORD_DATA_W'h0;
            rdy_        <= #1 `DISABLE_;
            start       <= #1 `DISABLE;
            mode        <= #1 `TIMER_MODE_ONE_SHOT;
            irq         <= #1 `DISABLE;
            expr_val    <= #1 `WORD_DATA_W'h0;
            counter     <= #1 `WORD_DATA_W'h0;
        end else begin
            if ((cs_ == `ENABLE_) && (as_ == `ENABLE_)) begin
                rdy_        <= #1 `ENABLE_;
            end else begin
                rdy_        <= #1 `DISABLE_;
            end
            /***** 读取访问 ****/
            if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && (rw == `READ)) begin
                case (addr)
                    `TIMER_ADDR_CTRL    : begin
                        rd_data <= #1 {{`WORD_DATA_W-2{1'b0}}, mode, start};
                    end
                    `TIMER_ADDR_INTR    : begin
                        rd_data <= #1 {{`WORD_DATA_W-1{1'b0}}, irq};
                    end
                    `TIMER_ADDR_EXPR    : begin
                        rd_data <= #1 expr_val;
                    end
                    `TIMER_ADDR_COUNTER : begin
                        rd_data <= #1 counter;
                    end
                endcase
            end else begin
                rd_data <= #1 `WORD_DATA_W'h0;
            end
            /**** 写入访问 ****/
            // 控制寄存器0
            if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) &&
                (rw == `WRITE) && (timer_addr == `TIMER_ADDR_CTRL) ) begin
                start   <= #1 wr_data[`TimerStartLoc];
                mode    <= #1 wr_data[`TimerModeLoc];
            end else if ((expr_flag == `ENABLE) &&
                         (mode == `TIMER_MODE_ONE_SHOT)) begin
                start    <= #1 `DISABLE;
            end
            // 控制寄存器1
            if (expr_flag == `ENABLE) begin
                irq     <= #1 `ENABLE;
            end else if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) &&
                         (rw == `WRITE) && (timer_addr == `TIMER_ADDR_INTR)) begin
                irq     <= #1 wr_data[`TimerlrqLoc];
            end
            // 控制寄存器2
            if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) &&
                (rw == `WRITE) && (timer_addr == `TIMER_ADDR_EXPR)) begin
                expr_val <= #1 wr_data;
            end
            // 控制寄存器3
            if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) &&
                (rw == `WRITE) && (timer_addr == `TIMER_ADDR_COUNTER)) begin
                counter <= #1 wr_data;
            end else if (expr_flag == `ENABLE) begin
                counter <= #1 `WORD_DATA_W'h0;
            end else if (start == `ENABLE) begin
                counter <= #1 counter + 1'd1;
            end
        end
    end

endmodule
