package FIFO_coverage_pkg;

	import FIFO_transaction_pkg::*;
	
	class FIFO_coverage;
		
		//The class will have an object of the class FIFO_transaction named F_cvg_txn.

		FIFO_transaction F_cvg_txn;

		/* Create a covergroup. The coverage needed is cross coverage between 3 signals which are 
		   write enable, read enable and each output control signals (outputs except data_out) to 
		   make sure that all combinations of write and read enable took place in all state of the FIFO */

		covergroup read_write_cg;
			wr_en_cp:          coverpoint F_cvg_txn.wr_en      {option.weight         = 0;}
			rd_en_cp:          coverpoint F_cvg_txn.rd_en      {option.weight         = 0;}
			full_cp:           coverpoint F_cvg_txn.full        {bins full_HIGH        = {1}; option.weight = 0;}
			empty_cp:          coverpoint F_cvg_txn.empty       {bins empty_HIGH       = {1}; option.weight = 0;}
			overflow_cp:       coverpoint F_cvg_txn.overflow    {bins overflow_HIGH    = {1}; option.weight = 0;}
			underflow_cp:      coverpoint F_cvg_txn.underflow   {bins underflow_HIGH   = {1}; option.weight = 0;}
			wr_ack_cp:         coverpoint F_cvg_txn.wr_ack      {bins wr_ack_HIGH      = {1}; option.weight = 0;}
			almostfull_cp:     coverpoint F_cvg_txn.almostfull  {bins almostfull_HIGH  = {1}; option.weight = 0;}
			almostempty_cp:    coverpoint F_cvg_txn.almostempty {bins almostempty_HIGH = {1}; option.weight = 0;}	



			almostfull_cross: 	cross wr_en_cp, rd_en_cp, almostfull_cp;
			almostempty_cross:  cross wr_en_cp, rd_en_cp, almostempty_cp;


			// empty shouldn't be HIGH if write enable is 1 whatever read
			empty_cross:cross wr_en_cp,rd_en_cp,empty_cp iff(F_cvg_txn.rst_n)        {
                illegal_bins empty_and_wr     =  binsof(wr_en_cp)intersect {1} && (binsof(rd_en_cp) intersect{0}  || binsof(rd_en_cp)     intersect{1}) && binsof(empty_cp) intersect{1};
            }
			// full shouldn't be HIGH if read enable is 1 whatever write
			full_cross:cross wr_en_cp , rd_en_cp , full_cp       {
                illegal_bins full_wr_rd       = (binsof(wr_en_cp)intersect {0} || binsof(wr_en_cp) intersect {1}) && binsof(rd_en_cp)     intersect{1} &&  binsof (full_cp) intersect{1};
            }
			// overflow shouldn't be HIGH if write enable is 0 
			overflow_cross:cross wr_en_cp ,rd_en_cp, overflow_cp {
                illegal_bins wr_and_over      = binsof(wr_en_cp)intersect {0} && binsof(overflow_cp)  intersect{1};
            }
			// underflow shouldn't be HIGH if read enable is 0 
			underflow_cross:cross wr_en_cp,rd_en_cp,underflow_cp {
                illegal_bins underflow_and_rd = binsof(rd_en_cp)intersect {0} && binsof(underflow_cp) intersect{1};
            }
			// write ack shouldn't be HIGH if write enable is 0
			 wr_ack_cross:cross wr_en_cp , rd_en_cp , wr_ack_cp  {
                illegal_bins wr_and_wr_ack    = binsof(wr_en_cp)intersect {0} && binsof(wr_ack_cp)    intersect{1};
            }
		endgroup

		/*Create a void function inside it named sample_data that takes one input named F_txn.
		This input is an object of class FIFO_transaction. This function will do the following 
		1. Assign F_txn to F_cvg_txn 
		2. Trigger the sampling of the covergroup using the .sample method*/

		function new();
        	// Create an instance of the covergroup
        	read_write_cg = new();
    	endfunction
		
		function void sample_data(FIFO_transaction F_txn);
			F_cvg_txn = F_txn;
			read_write_cg.sample();
		endfunction

	endclass

endpackage