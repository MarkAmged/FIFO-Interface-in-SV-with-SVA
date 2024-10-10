import FIFO_transaction_pkg::*;
import FIFO_scoreboard_pkg::*;
import FIFO_coverage_pkg::*;
import shared_pkg::*;
module FIFO_monitor(FIFO_interface.MONITOR fifo_if);
	// Declare objects for the classes
	FIFO_transaction fifo_trans;
  	FIFO_scoreboard fifo_scoreboard = new();
  	FIFO_coverage fifo_coverage = new();

	initial begin
		fifo_trans      = new();

		/*It will have an initial block and inside it a forever loop that waits for negedge clock at the start of 
		the loop and then sample the data of the interface and assign it to the data variables of the 
		object of class FIFO_transaction.*/

		forever begin  
      		fifo_trans.data_in     = fifo_if.data_in;
			fifo_trans.wr_en       = fifo_if.wr_en;
			fifo_trans.rd_en       = fifo_if.rd_en;
			fifo_trans.rst_n       = fifo_if.rst_n; 
			@(negedge fifo_if.clk);     		
      		fifo_trans.data_out    = fifo_if.data_out;
      		fifo_trans.wr_ack      = fifo_if.wr_ack;
      		fifo_trans.overflow    = fifo_if.overflow;
      		fifo_trans.full        = fifo_if.full;
      		fifo_trans.empty       = fifo_if.empty;
      		fifo_trans.almostfull  = fifo_if.almostfull;
      		fifo_trans.almostempty = fifo_if.almostempty;
      		fifo_trans.underflow   = fifo_if.underflow;
      		@(posedge fifo_if.clk);

      		/* And then after that there will be fork join, where 2 processes 
			will run, the first one is calling a method named sample_data of the object of class 
			FIFO_coverage and the second process is calling a method named check_data of the object of 
			class FIFO_scoreboard.*/

      		fork begin
          		fifo_coverage.sample_data(fifo_trans); // Call the coverage sampling method
            end
        	begin
          		fifo_scoreboard.check_data(fifo_trans); // Call the scoreboard checking method
        	end
        	/*After the fork join ends, you will check for the signal test_finished if it is high or not. If it high, 
			then stop the simulation and display a message with summary of correct and error counts. */
      		join
      			if (shared::test_finished) begin
        			$display("Simulation finished.");
        			$display("Test Finished ! error_count is %d, correct_count is %d", shared::error_count , shared::correct_count);
        			$stop;
      			end
        end
    end
endmodule