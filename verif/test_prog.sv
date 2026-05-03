// program TB — stimulus/checks; pins only via clocking block p.cb
program automatic test_prog (mem_if.TEST p);
  import mem_pkg::*;

  Transaction gen_q[$];
  Transaction drv_to_mon_q[$];
  Transaction mon_q[$];
  logic [7:0] shadow[logic [15:0]];
  logic [15:0] written_addrs[$];

  task generator_writes(int n);
    repeat (n) begin
      Transaction t = new();
      t.is_write = 1'b1;
      gen_q.push_back(t);
    end
  endtask

  task generator_reads(int n);
    int j;
    repeat (n) begin
      Transaction t = new();
      t.is_write = 1'b0;
      j = $urandom_range(0, written_addrs.size() - 1);
      t.addr = written_addrs[j];
      t.expected_data = shadow[t.addr];
      gen_q.push_back(t);
    end
  endtask

  task driver();
    Transaction t;
    forever begin
      wait (gen_q.size() > 0);
      t = gen_q.pop_front();
      @(p.cb);
      if (t.is_write) begin
        p.cb.write <= 1'b1;
        p.cb.read <= 1'b0;
        p.cb.addr <= t.addr;
        p.cb.data_in <= t.data_in;
        @(p.cb);
        p.cb.write <= 1'b0;
        shadow[t.addr] = t.data_in;
        written_addrs.push_back(t.addr);
      end else begin
        p.cb.write <= 1'b0;
        p.cb.read <= 1'b1;
        p.cb.addr <= t.addr;
        @(p.cb);
        p.cb.read <= 1'b0;
        drv_to_mon_q.push_back(t.copy());
      end
    end
  endtask

  task monitor();
    Transaction t;
    forever begin
      wait (drv_to_mon_q.size() > 0);
      t = drv_to_mon_q.pop_front();
      @(p.cb);
      t.data_out = p.cb.data_out;
      mon_q.push_back(t);
    end
  endtask

  task checker_task();
    Transaction t;
    forever begin
      wait (mon_q.size() > 0);
      t = mon_q.pop_front();
      t.print_data_out();
      t.check_expected();
    end
  endtask

  initial begin
    // Drive idle/control defaults through cb only; extra @(cb) settles NB drives
    @(p.cb);
    p.cb.read <= 1'b0;
    p.cb.write <= 1'b0;
    p.cb.addr <= '0;
    p.cb.data_in <= '0;
    @(p.cb);

    fork
      driver();
      monitor();
      checker_task();
    join_none

    generator_writes(40);
    while (gen_q.size() > 0) @(p.cb);

    generator_reads(40);
    while (gen_q.size() > 0) @(p.cb);

    repeat (25) @(p.cb);
    $finish;
  end

  final begin
    Transaction::print_static_error();
  end

endprogram : test_prog

