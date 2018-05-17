`
`

module chip_top_test(
);
    reg                     clk_ref;
    reg                     reset_sw;

    wire                    uart_rx;
    wire                    uart_rx;

    wire    [3:0]           gpio_in;
    wire    [17:0]          gpio_out;
    wire    [15:0]          gpio_io;

    wire                    rx_busy;
    wire                    rx_end;
    wire    [7:0]           rx_data;

    paramter [31:0]         STEP;

    `ifdef  IMPLE
endmodule
