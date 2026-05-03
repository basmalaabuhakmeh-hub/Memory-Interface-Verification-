// Memory interface + RW checker + clocking block (cb only on TEST modport, not DUT)
interface mem_if (input bit clk);
  logic read;
  logic write;
  logic [15:0] addr;
  logic [7:0] data_in;
  logic [7:0] data_out;

  // forbid read and write in the same cycle (skip until strobes are 2-state)
  always @(posedge clk) begin
    if (!$isunknown({read, write}))
      no_rw_same_cycle: assert (!(read && write));
  end

  // TB drives/samples pins through cb @posedge clk
  clocking cb @(posedge clk);
    output read, write, addr, data_in;
    input data_out;
  endclocking

  modport DUT (
      input clk,
      input read,
      input write,
      input addr,
      input data_in,
      output data_out
  );

  modport TEST (clocking cb);
endinterface : mem_if

