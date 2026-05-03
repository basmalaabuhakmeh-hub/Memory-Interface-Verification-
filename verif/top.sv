// Top: 10 MHz clk (starts after short delay), interface, DUT, program TB
module top;
  initial begin
    $fsdbDumpfile("waves.fsdb");
    $fsdbDumpvars(0, top);
  end

  logic clk;
  initial clk = 1'b0;

  // Hold clk low briefly before toggling so TB can sync via cb before 1st edge matters
  initial begin
    #100;
    forever #50 clk = ~clk;
  end

  mem_if mem_bus (.clk(clk));

  my_mem dut (mem_bus);

  test_prog u_tb (mem_bus);
endmodule : top

