//`include "..\..\..\stddef.h"
//`include "spm.h"

module x_s3e_dpram(
    input wire                  clka,
    input wire                  wea,
    input wire [`SpmAddrBus]    addra,
    input wire [31:0]           dina,
    output reg [`WordDataBus]   douta,

    input wire                  clkb,
    input wire                  web,
    input wire [`SpmAddrBus]    addrb,
    input wire [31:0]           dinb,
    output reg [`WordDataBus]   doutb
);
    reg [`WordDataBus]      mem [4095:0];

    // port A
    always @(posedge clka) begin
        // READ
        if ((web == `ENABLE) && (addra == addrb)) begin
            douta   <= #1 dinb;
        end else begin
            douta   <= #1 mem[addra];
        end
        // WRITE
        if (wea == `ENABLE) begin
            mem[addra]  <= #1 dina;
        end
    end

    //porb B
    always @(posedge clkb) begin
        if ((wea == `ENABLE) && (addrb == addra)) begin
            doutb   <= #1 dina;
        end else begin
            doutb   <= #1 mem[addrb];
        end

        if (web == `ENABLE) begin
            mem[addrb]  <= #1 dinb;
        end
    end

endmodule
