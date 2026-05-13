///Day-50
///DATE:-19/02/2024
///32-BIT RAM

module Day_50(input clk, wr, rd, rst,
              input [31:0] data_in,
              input [5:0] addr,
              output [31:0] data_out);
  reg [31:0] ram [0:31];

    always @(posedge clk) begin
        if(rst) begin
          ram[addr] <= 32'd0;
        end
        else begin
            if(wr)
                ram[addr] <= data_in;
        end
    end

  assign data_out = rd ? ram[addr] : 64'dz;
endmodule