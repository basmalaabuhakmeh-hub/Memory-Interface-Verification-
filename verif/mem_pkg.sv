// Transaction class in a package
package automatic mem_pkg;

  class Transaction;
    logic [15:0] addr;
    logic [7:0] data_in;
    bit is_write = 1'b1;
    logic [7:0] data_out;
    logic [7:0] expected_data;
    static int error;

    // (a) random addr / data_in
    function new();
      is_write = 1'b1;
      addr = 16'($random);
      data_in = 8'($random);
    endfunction

    // (b)
    function void print_data_out();
      $display("@%0t  Transaction.print_data_out: data_out = %02h", $time, data_out);
    endfunction

    // (d)
    static function void print_static_error();
      $display("@%0t  Transaction.print_static_error: error = %0d", $time, error);
    endfunction

    // (e)
    function void check_expected();
      if (expected_data !== data_out) begin
        error++;
        $display("@%0t  CHECK FAIL addr=%04h expected=%02h got=%02h (errors=%0d)",
                 $time, addr, expected_data, data_out, error);
      end else begin
        $display("@%0t  CHECK PASS addr=%04h data=%02h", $time, addr, data_out);
      end
    endfunction

    // (f) deep copy
    function Transaction copy();
      copy = new();
      copy.addr = addr;
      copy.data_in = data_in;
      copy.is_write = is_write;
      copy.data_out = data_out;
      copy.expected_data = expected_data;
    endfunction
  endclass

endpackage : mem_pkg

