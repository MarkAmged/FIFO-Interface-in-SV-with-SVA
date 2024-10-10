import shared_pkg::*;
import FIFO_transaction_pkg::*;

module FIFO_tb(FIFO_interface.TEST fifo_if);
	
	/*The tb will reset the DUT and then randomize the inputs. At the end of 
    the test, the tb will assert a signal named test_finished.*/
    FIFO_transaction trans ;
    integer i;
    logic clk;
    initial begin
        trans = new();

        assert_rst();
        

        for (i = 0; i < 20000; i = i + 1) begin
            assert(trans.randomize());

            fifo_if.rst_n   = trans.rst_n;
            fifo_if.wr_en   = trans.wr_en;
            fifo_if.rd_en   = trans.rd_en;
            fifo_if.data_in = trans.data_in;
            @(negedge fifo_if.clk);#0;
        end

        assert_rst();

        shared::test_finished = 1;
        
    end

    // Reset task
    task assert_rst;
        fifo_if.rst_n   = 0;
        fifo_if.wr_en   = 0;
        fifo_if.rd_en   = 0;
        fifo_if.data_in = 0;
        @(negedge fifo_if.clk);
        @(negedge fifo_if.clk);
        fifo_if.rst_n   = 1;
    endtask
endmodule