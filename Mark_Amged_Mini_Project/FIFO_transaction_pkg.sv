package FIFO_transaction_pkg;
	class FIFO_transaction;
	parameter FIFO_WIDTH = 16;
	parameter FIFO_DEPTH = 8;
	logic clk;
	rand logic [FIFO_WIDTH-1:0] data_in;
	rand logic rst_n;
	rand logic wr_en;
	rand logic rd_en;
	logic [FIFO_WIDTH-1:0] data_out;
	logic wr_ack, overflow, full, empty, almostfull, almostempty, underflow;

	//Inside of this class add the FIFO inputs and outputs as class variables of the class as well as adding 2 integers (RD_EN_ON_DIST & WR_EN_ON_DIST) 
	int RD_EN_ON_DIST , WR_EN_ON_DIST ;

	//Add a constructor that takes 2 inputs and override the values of RD_EN_ON_DIST and WR_EN_ON_DIST, let the default of RD_EN_ON_DIST be 30 and WR_EN_ON_DIST be 70
	function new(int RD_EN_ON_DIST = 30 ,int WR_EN_ON_DIST = 70);
		this.RD_EN_ON_DIST = RD_EN_ON_DIST;
		this.WR_EN_ON_DIST = WR_EN_ON_DIST;
	endfunction

	//Assert reset less often
	constraint reset_c {rst_n dist {1:/98 , 0:/2};}

	// Constraint the write enable to be high with distribution of the value WR_EN_ON_DIST & to be low with 100-WR_EN_ON_DIST
	constraint wr_en_c { wr_en dist {1 := WR_EN_ON_DIST, 0 := 100-WR_EN_ON_DIST}; }

	// Constraint the read enable the same as write enable but using RD_EN_ON_DIST
	constraint rd_en_c { rd_en dist {1 := RD_EN_ON_DIST, 0 := 100-RD_EN_ON_DIST}; }

	endclass
endpackage