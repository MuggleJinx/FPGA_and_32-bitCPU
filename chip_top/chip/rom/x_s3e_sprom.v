//`include "..\..\stddef.h"
//`include "rom.h"

module x_s3e_sprom(
    input wire                  clka,
    input wire [`RomAddrBus]    addra,
    output reg [`WordDataBus]   douta
);
    reg     [`WordDataBus]      mem [2047:0];

    always @(posedge clka) begin
        douta <= #1 mem[addra];
    end

endmodule
