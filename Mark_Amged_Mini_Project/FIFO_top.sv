module FIFO_top();
	bit clk;

	//clock generation
	initial begin
		clk = 0;
		forever
			#5 clk = ~clk;
	end

	FIFO_interface fifo_if (clk);
	FIFO           dut     (fifo_if);
	FIFO_tb        tb      (fifo_if);
	FIFO_monitor   mon     (fifo_if);

endmodule