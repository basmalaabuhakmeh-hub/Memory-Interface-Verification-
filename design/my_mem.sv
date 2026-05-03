// sync 8b x 64K RAM; even parity stored in internal bit [8]
module my_mem (mem_if.DUT m);
  logic [8:0] ram[0:65535];

  always_ff @(posedge m.clk) begin
    if (m.write && m.read) begin
    end else if (m.write) begin
      ram[m.addr] <= {^{m.data_in}, m.data_in};
    end else if (m.read) begin
      m.data_out <= ram[m.addr][7:0];
    end
  end
endmodule : my_mem

