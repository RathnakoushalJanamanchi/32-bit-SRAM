module Day_50_tb();
  reg clk, wr, rd, rst;
  reg [31:0] data_in;
  wire [31:0] data_out;
  reg [8:0] addr;
  integer i;

  Day_50 uut(clk, wr, rd, rst, data_in, addr, data_out);

  always #5 clk = ~clk;

  initial clk = 0;

  initial begin
    $dumpfile("dump.vcd");       // Create VCD file
    $dumpvars(0, Day_50_tb);
    wr = 1'b1;
    rd = 1'b0;
    rst = 1'b1;
    #10;
    rst = 1'b0;

    for (i = 0; i < 15; i = i + 1) begin
      wr = 1'b1;
      data_in = $random();
      addr = i;
      $display("wr=%b, data_in=%d, addr=%d", wr, data_in, addr);
      #10;
    end

    wr = 1'b0;
    rd = 1'b1;

    for (i = 0; i < 15; i = i + 1) begin
      addr = i;
      $display("rd=%b, addr=%d, data_out=%d", wr, addr, data_out);
      #10;
    end

    #400;
    $finish();
  end
endmodule