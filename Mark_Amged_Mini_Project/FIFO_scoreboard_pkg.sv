package FIFO_scoreboard_pkg;
	import FIFO_transaction_pkg::*;
	import shared_pkg::*;
	
	class FIFO_scoreboard;

		parameter FIFO_WIDTH = 16;
		parameter FIFO_DEPTH = 8;

		//Add variables for the data_out_ref to be used in the reference_model function 
		logic [FIFO_WIDTH-1:0] data_out_ref;

		// declare queue to use for golden model
		logic [FIFO_WIDTH-1:0] FIFO_queue[$];
		

		/*---Create a function named check_data that takes one input which of type FIFO_transaction 
		---Inside this function, call another function named reference_model that you will 
		create and pass to it the same object that you have received.*/

		function void check_data(FIFO_transaction FIFO_trans);
			reference_model(FIFO_trans);

		/*---After the reference_model function returns, you will compare the reference 
		outputs calculated with the outputs of the object received. Increment the 
		error_count or correct_count. Also, display a message if error occurs. */

			if( data_out_ref != FIFO_trans.data_out) begin 
			   	shared::error_count++;
			   	$display("Error occurs");
			end   		
			else begin
				shared::correct_count++;
			end			
		endfunction

		/*---Reference_model--- */

		function void reference_model(FIFO_transaction FIFO_ref);

			if(!FIFO_ref.rst_n) begin
				FIFO_queue.delete();
				//data_out_ref = 0;
			end

			else begin

				if ( (!FIFO_ref.wr_en) && (FIFO_ref.rd_en) && (FIFO_queue.size() != 0) ) begin
					data_out_ref = FIFO_queue.pop_front();
				end

				else if ( (FIFO_ref.wr_en) && (!FIFO_ref.rd_en) && (FIFO_queue.size() != FIFO_DEPTH) ) begin
					FIFO_queue.push_back(FIFO_ref.data_in);
				end

				else if ( (FIFO_ref.wr_en) && (FIFO_ref.rd_en) )begin

					if(FIFO_queue.size() == 0)begin
						FIFO_queue.push_back(FIFO_ref.data_in);
					end

					else if(FIFO_queue.size() == FIFO_DEPTH) begin
						data_out_ref = FIFO_queue.pop_front();
					end

					else begin
						// pop the front and push the back
						data_out_ref = FIFO_queue.pop_front(); 
						FIFO_queue.push_back(FIFO_ref.data_in);
					end
				end
				else begin
				end
			end	
		endfunction	

	endclass	
endpackage