// 以位为单位 进行数字输入输出的io接口
// 外部开关按钮 连接到 led 数码管等

`include "gpio.h"
`include "stddef.h"

module gpio(
    input wire                  clk,
    input wire                  reset_,

    // 总线接口
    input  wire                 cs_,
    input  wire                 as_,
    input  wire                 rw,
    input  wire [`WordAddrBus]           addr,
    input  wire [`WordDataBus]  wr_data,
    output reg  [`WordDataBus]  rd_data,
    output reg                  rdy_,

    // 通用输入输出端口
    input  wire [3:0]           gpio_in,
    output  reg [17:0]          gpio_out,
    inout  wire [15:0]          gpio_io
);

    wire [`GpioAddrBus]      gpio_addr;
    assign gpio_addr = addr[`GpioAddrLoc];

`ifdef GPIO_IO_CH
    wire    [`GPIO_IO_CH - 1:0] io_in;
    reg     [`GPIO_IO_CH - 1:0] io_out;
    reg     [`GPIO_IO_CH - 1:0] io_dir;
    reg     [`GPIO_IO_CH - 1:0] io;
    integer                     i;

    /**** 输入输出信号 的连续赋值 *****/
    assign  io_in   = gpio_io;
    assign  gpio_io = io;

    /**** 输入输出 方向控制 ****/
    always @(*) begin
        for (i = 0; i < `GPIO_IN_CH; i = i + 1) begin : IO_DIR //??
            io[i] = (io_dir[i] == `GPIO_DIR_IN) ? 1'bz : io_out[i];
        end
    end

`endif

    /**** gpio的控制 ****/
    always @(posedge clk or negedge reset_) begin
        if (reset_ == `ENABLE_) begin
            rd_data <= #1 `WORD_DATA_W'h0;
            rdy_    <= #1 `DISABLE_;
`ifdef GPIO_OUT_CH
            gpio_out <= #1 {`GPIO_OUT_CH{`LOW}};
`endif
`ifdef GPIO_IO_CH
            io_out  <= #1 {`GPIO_OUT_CH{`LOW}};
            io_dir  <= #1 {`GPIO_IO_CH{`GPIO_DIR_IN}};
`endif
        end else begin
            /* 就绪信号 生成 */
            if ((cs_ == `ENABLE_) && (as_ == `ENABLE_)) begin
                rdy_    <= #1 `ENABLE_;
            end else begin
                rdy_    <= #1 `DISABLE_;
            end
            /* 读取访问 */
            if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && (rw == `READ)) begin
                case (addr)
`ifdef GPIO_IN_CH
                    `GPIO_ADDR_IN_DATA  : begin
                        rd_data <= #1 {{`WORD_DATA_W - `GPIO_IN_CH{1'b0}}, gpio_in};
                    end
`endif
`ifdef GPIO_OUT_CH
                    `GPIO_ADDR_OUT_DATA : begin
                        rd_data <= #1 {{`WORD_DATA_W - `GPIO_OUT_CH{1'b0}}, gpio_out};
                    end
`endif
`ifdef GPIO_IO_CH
                    `GPIO_ADDR_IO_DATA  : begin
                        rd_data <= #1 {{`WORD_DATA_W - `GPIO_IO_CH{1'b0}}, io_in};
                    end
                    `GPIO_ADDR_IO_DIR   : begin
                        rd_data <= #1 {{`WORD_DATA_W - `GPIO_IO_CH{1'b0}}, io_dir};
                    end
`endif
                endcase
            end else begin
                rd_data <= #1 `WORD_DATA_W'h0;
            end
            /* 写入访问 */
            if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && (rw == `WRITE)) begin
                case (gpio_addr)
`ifdef GPIO_OUT_CH  //向输出端口写
                    `GPIO_ADDR_OUT_DATA : begin
                        gpio_out    <= #1 wr_data[`GPIO_IO_CH - 1:0];
                    end
                    `GPIO_ADDR_IO_DIR   : begin
                        io_dir      <= #1 wr_data[`GPIO_IO_CH - 1:0];
                    end
`endif
                endcase
            end
        end
    end

endmodule
