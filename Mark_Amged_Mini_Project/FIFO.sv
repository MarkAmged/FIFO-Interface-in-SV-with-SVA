module FIFO(FIFO_interface.DUT fifo_if);

	logic [fifo_if.FIFO_WIDTH-1:0] data_in;
	logic clk, rst_n, wr_en, rd_en;
	logic [fifo_if.FIFO_WIDTH-1:0] data_out;
	logic wr_ack, overflow, full, empty, almostfull, almostempty, underflow;

	assign clk         = fifo_if.clk;
	assign rst_n       = fifo_if.rst_n;
	assign wr_en       = fifo_if.wr_en;
	assign rd_en       = fifo_if.rd_en;
	assign data_in     = fifo_if.data_in;
	assign data_out    = fifo_if.data_out;
	assign wr_ack      = fifo_if.wr_ack;
	assign overflow    = fifo_if.overflow;
	assign full        = fifo_if.full;
	assign empty       = fifo_if.empty;
	assign almostfull  = fifo_if.almostfull;
	assign almostempty = fifo_if.almostempty;
	assign underflow   = fifo_if.underflow;

	reg [fifo_if.FIFO_WIDTH-1    :0] mem [fifo_if.FIFO_DEPTH-1:0];
	reg [fifo_if.max_fifo_addr-1 :0] wr_ptr, rd_ptr;
	reg [fifo_if.max_fifo_addr   :0] count;

	always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin //////write operation////////
		if (!fifo_if.rst_n) begin
			wr_ptr           <= 0;
			fifo_if.wr_ack   <= 0;
			fifo_if.overflow <= 0;
		end

		else if (fifo_if.wr_en && count < fifo_if.FIFO_DEPTH) begin
			mem[wr_ptr]      <= fifo_if.data_in;
			fifo_if.wr_ack   <= 1;
			wr_ptr           <= wr_ptr + 1;
			fifo_if.overflow <= 0;
		end

		else begin 
			fifo_if.wr_ack <= 0;

			if (fifo_if.wr_en && fifo_if.full)
				fifo_if.overflow <= 1;
			else
				fifo_if.overflow <= 0; 
			end
	end

	always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin ///////read operation///////
		if (!fifo_if.rst_n) begin
			rd_ptr            <= 0;
			fifo_if.underflow <= 0;
			//fifo_if.data_out  <= 0;
		end

		else if (fifo_if.rd_en && count != 0) begin
			fifo_if.data_out  <= mem[rd_ptr];
			rd_ptr            <= rd_ptr + 1;
			fifo_if.underflow <= 0;
		end

		else begin

			if (fifo_if.rd_en && fifo_if.empty) 
				fifo_if.underflow <= 1;
			else
				fifo_if.underflow <= 0;

		end
	end

	always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
		if (!fifo_if.rst_n) begin
			count <= 0;
		end
		else begin
			if	    ( ({fifo_if.wr_en, fifo_if.rd_en} == 2'b10) && !fifo_if.full) 
				    count <= count + 1;

			else if ( ({fifo_if.wr_en, fifo_if.rd_en} == 2'b01) && !fifo_if.empty)
				    count <= count - 1;

			else if   ({fifo_if.wr_en, fifo_if.rd_en} == 2'b11) begin

				if (fifo_if.full) 
					count <= count - 1; 
				else if (fifo_if.empty) 
					count <= count + 1;
				//else 
					//count <= count;
	
			end
		end
	end

	assign fifo_if.full        = (count == fifo_if.FIFO_DEPTH)   ? 1 : 0;
	assign fifo_if.empty       = (count == 0)                    ? 1 : 0;
	assign fifo_if.almostfull  = (count == fifo_if.FIFO_DEPTH-1) ? 1 : 0; 
	assign fifo_if.almostempty = (count == 1)                    ? 1 : 0;

	

	`ifdef SIM

	//assertions and cover of sequential outputs
	overflow_assert_1    :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count==fifo_if.FIFO_DEPTH)&&fifo_if.wr_en)   |=>(fifo_if.overflow));
	underflow_assert_1   :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count==0)&&fifo_if.rd_en)                    |=>(fifo_if.underflow));
	wr_ack_assert_1      :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count!=fifo_if.FIFO_DEPTH)&&fifo_if.wr_en)   |=>(fifo_if.wr_ack));
	overflow_cover_1     :cover property  (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count==fifo_if.FIFO_DEPTH)&&fifo_if.wr_en)   |=>(fifo_if.overflow));
	underflow_cover_1    :cover property  (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count==0)&&fifo_if.rd_en)                    |=>(fifo_if.underflow));
	wr_ack_cover_1       :cover property  (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count!=fifo_if.FIFO_DEPTH)&&fifo_if.wr_en)   |=>(fifo_if.wr_ack));

	overflow_assert_2    :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count!=fifo_if.FIFO_DEPTH) && fifo_if.wr_en) |=>(fifo_if.overflow   == 0));
	underflow_assert_2   :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count!=0) && fifo_if.rd_en)                  |=>(fifo_if.underflow) == 0);
	wr_ack_assert_2      :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count==fifo_if.FIFO_DEPTH)&&fifo_if.wr_en)   |=>(fifo_if.wr_ack)    == 0);
	overflow_cover_2     :cover property  (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count!=fifo_if.FIFO_DEPTH)&&fifo_if.wr_en)   |=>(fifo_if.overflow)  == 0);
	underflow_cover_2    :cover property  (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count!=0) && fifo_if.rd_en)                  |=>(fifo_if.underflow  == 0));
	wr_ack_cover_2       :cover property  (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) ((count==fifo_if.FIFO_DEPTH)&&fifo_if.wr_en)   |=>(fifo_if.wr_ack)    == 0);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//assertions and cover of combinational outputs
	full_assert_1        :assert property (@(posedge fifo_if.clk)  (count==fifo_if.FIFO_DEPTH)   |-> fifo_if.full);
	empty_assert_1       :assert property (@(posedge fifo_if.clk)  (count==0)                    |-> fifo_if.empty);
	almostfull_assert_1  :assert property (@(posedge fifo_if.clk)  (count==fifo_if.FIFO_DEPTH-1) |-> fifo_if.almostfull);
	almostempty_assert_1 :assert property (@(posedge fifo_if.clk)  (count==1)                    |-> fifo_if.almostempty);
	full_cover_1         :cover  property (@(posedge fifo_if.clk)  (count==fifo_if.FIFO_DEPTH)   |-> fifo_if.full);
	empty_cover_1        :cover  property (@(posedge fifo_if.clk)  (count==0)                    |-> fifo_if.empty);
	almostfull_cover_1   :cover  property (@(posedge fifo_if.clk)  (count==fifo_if.FIFO_DEPTH-1) |-> fifo_if.almostfull);
	almostempty_cover_1  :cover  property (@(posedge fifo_if.clk)  (count==1)                    |-> fifo_if.almostempty);

	full_assert_2        :assert property (@(posedge fifo_if.clk)  (count!=fifo_if.FIFO_DEPTH)   |-> fifo_if.full        == 0);
	empty_assert_2       :assert property (@(posedge fifo_if.clk)  (count!=0)                    |-> fifo_if.empty       == 0);
	almostfull_assert_2  :assert property (@(posedge fifo_if.clk)  (count!=fifo_if.FIFO_DEPTH-1) |-> fifo_if.almostfull  == 0);
	almostempty_assert_2 :assert property (@(posedge fifo_if.clk)  (count!=1)                    |-> fifo_if.almostempty == 0);
	full_cover_2         :cover  property (@(posedge fifo_if.clk)  (count!=fifo_if.FIFO_DEPTH)   |-> fifo_if.full        == 0);
	empty_cover_2        :cover  property (@(posedge fifo_if.clk)  (count!=0)                    |-> fifo_if.empty       == 0);
	almostfull_cover_2   :cover  property (@(posedge fifo_if.clk)  (count!=fifo_if.FIFO_DEPTH-1) |-> fifo_if.almostfull  == 0);
	almostempty_cover_2  :cover  property (@(posedge fifo_if.clk)  (count!=1)                    |-> fifo_if.almostempty == 0);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//assertions on counter
	rd_count_assert    :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.rd_en  && !fifo_if.wr_en && count !=0)                              |=>($past(count)-1'b1 == count));
	wr_count_assert    :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (!fifo_if.rd_en && fifo_if.wr_en  && count !=fifo_if.FIFO_DEPTH)             |=>($past(count)+1'b1 == count));
	rd_wr_count_assert :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.rd_en  && fifo_if.wr_en  && count !=0 && count!=fifo_if.FIFO_DEPTH) |=>($past(count)      == count));		
	rd_count_cover     :cover property  (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.rd_en  &&!fifo_if.wr_en  && count !=0)                              |=>($past(count)-1'b1 == count));
	wr_count_cover     :cover property  (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (!fifo_if.rd_en &&fifo_if.wr_en   && count !=fifo_if.FIFO_DEPTH)             |=>($past(count)+1'b1 == count));
	rd_wr_count_cover  :cover property  (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.rd_en  &&fifo_if.wr_en   &&count  !=0 && count!=fifo_if.FIFO_DEPTH) |=>($past(count)      == count));

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//assertions on pointers
	rd_ptr_assert      :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.rd_en  && count!=0)                   |=>($past(rd_ptr)+1'b1==rd_ptr));
	wr_ptr_assert      :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.wr_en  && count!=fifo_if.FIFO_DEPTH)  |=>($past(wr_ptr)+1'b1==wr_ptr));	
	rd_ptr_cover       :cover property  (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.rd_en  && count!=0)                   |=>($past(rd_ptr)+1'b1==rd_ptr));
	wr_ptr_cover       :cover property  (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.wr_en  && count!=fifo_if.FIFO_DEPTH)  |=>($past(wr_ptr)+1'b1==wr_ptr));


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//more assertions
	// if almostfull is HIGH and wr_en only is HIGH then the next cycle full will be HIGH
	almostfull_full_assert   :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.almostfull  && fifo_if.wr_en && !fifo_if.rd_en) |=> fifo_if.full);

	// if almostempty is HIGH and rd_en only is HIGH then the next cycle empty will be HIGH
	almostempty_empty_assert :assert property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.almostempty && fifo_if.rd_en && !fifo_if.wr_en) |=> fifo_if.empty);

	almostfull_full_cover   :cover property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.almostfull  && fifo_if.wr_en && !fifo_if.rd_en) |=> fifo_if.full);
	almostempty_empty_cover :cover property (@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) (fifo_if.almostempty && fifo_if.rd_en && !fifo_if.wr_en) |=> fifo_if.empty);


	always_comb begin  
		if(!rst_n)begin
			rst_count_assert       :assert final (count       == 0);
			rst_rd_ptr_assert      :assert final (rd_ptr      == 0);
			rst_wr_ptr_assert      :assert final (wr_ptr      == 0);
			rst_full_assert        :assert final (full        == 0);
			rst_empty_assert       :assert final (empty       == 1);
			rst_almostfull_assert  :assert final (almostfull  == 0);
			rst_almostempty_assert :assert final (almostempty == 0);
			//rst_data_out_assert    :assert final (data_out    == 0);
			rst_overflow_assert    :assert final (overflow    == 0);
			rst_underflow_assert   :assert final (underflow   == 0);
			rst_wr_ack_assert      :assert final (wr_ack      == 0);
			rst_count_cover        :cover final  (count       == 0);
			rst_rd_ptr_cover       :cover final  (rd_ptr      == 0);
			rst_wr_ptr_cover       :cover final  (wr_ptr      == 0);
			rst_full_cover         :cover final  (full        == 0);
			rst_empty_cover        :cover final  (empty       == 1);
			rst_almostfull_cover   :cover final  (almostfull  == 0);
			rst_almostempty_cover  :cover final  (almostempty == 0);
			//rst_data_out_cover     :cover final  (data_out    == 0);
			rst_overflow_cover     :cover final  (overflow    == 0);
			rst_underflow_cover    :cover final  (underflow   == 0);
			rst_wr_ack_cover       :cover final  (wr_ack      == 0);
		end
	end
`endif


endmodule