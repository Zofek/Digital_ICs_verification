module top;

bit                   clk;
bit                   rst_n;
shortint 			  arg_a;
bit 				  arg_a_parity;
shortint  			  arg_b;
bit 				  arg_b_parity;
bit 				  req;

wire 				 ack;
int 				 result;
wire				 result_parity;
wire 				 result_rdy;		
wire 				 arg_parity_error;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------
vdic_dut_2023 DUT (.clk, .rst_n, .arg_a, .arg_a_parity, .arg_b, .arg_b_parity, .req,
				.ack, .result, .result_parity, .result_rdy, .arg_parity_error);

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end

// timestamp monitor
initial begin
    longint clk_counter;
    clk_counter = 0;
    forever begin
        @(posedge clk) clk_counter++;
        if(clk_counter % 1000 == 0) begin
            $display("%0t Clock cycles elapsed: %0d", $time, clk_counter);
        end
    end
end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions
//---------------------------------

task get_data(input bit ret_parity_OK, 
			  output shortint data, 
			  output 	  bit parity);
	
    bit 	[1:0] zero_ones;
	
    zero_ones = 2'($random);

    if (zero_ones == 2'b00)
        data = 16'h0000;
    else if (zero_ones == 2'b11)
        data = 16'hFF;
    else
        data = 16'($random);
    
    parity = ^data;
    
    if (!ret_parity_OK)
    	parity = !parity;
    
endtask : get_data

//------------------------
// Tester main

initial begin : tester
	repeat (1000) begin : tester_main_blk
        @(negedge clk);
		get_data(.ret_parity_OK(1'b0), .data(arg_a), .parity(arg_a_parity));
	end : tester_main_blk
    $finish;
end : tester

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------

endmodule : top
