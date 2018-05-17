`include "stddef.h"
`include "x_s3e_dcm.v"

module clk_gen(
    input   wire            clk_ref,
    input   wire            reset_sw,
    output  wire            clk,
    output  wire            clk_,
    output  wire            chip_reset_ // chip_reset_
);
    wire                    dcm_reset_;

    // DCM复位
    assign  dcm_reset_ = (reset_sw == `ENABLE) ? `ENABLE_ : `DISABLE_;
    // 芯片复位
    assign  chip_reset_ = ((reset_sw == `ENABLE)) ? `ENABLE_ : `DISABLE_;

    x_s3e_dcm x_s3e_dcm(
        .CLKIN_IN       (clk_ref),
        .RST_IN         (dcm_reset),
        .CLK0_OUT       (clk),
        .CLK180_OUT     (clk_),
        .LOCKED_OUT     (locked)
    );

endmodule
