module scoreboard(mult_bfm bfm);

	import mult_pkg::*;

//------------------------------------------------------------------------------
// local typdefs
//------------------------------------------------------------------------------
	typedef enum bit {
		TEST_PASSED,
		TEST_FAILED
	} test_result;

	typedef enum {
		COLOR_BOLD_BLACK_ON_GREEN,
		COLOR_BOLD_BLACK_ON_RED,
		COLOR_BOLD_BLACK_ON_YELLOW,
		COLOR_BOLD_BLUE_ON_WHITE,
		COLOR_BLUE_ON_WHITE,
		COLOR_DEFAULT
	} print_color;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

	test_result   tr = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

	task get_expected(

			input shortint   arg_a,
			input shortint   arg_b,
			input operation_t op_set,

			output int        result,
			output bit        result_parity,
			output bit        arg_parity_error);

		`ifdef DEBUG
		$display("%0t DEBUG: get_expected(%0d,%0d)",$time, arg_a, arg_b);
		`endif

		case(op_set)

			CORR_INPUT :

			begin
				result           = arg_a * arg_b;
				arg_parity_error = 1'b0;
				result_parity    = ^result;
			end

			INCORRECT_A, INCORRECT_B, INCORRECT_A_B:

			begin
				result           = 32'b0;
				arg_parity_error = 1'b1;
				result_parity    = ^result;
			end

			RST_OP :

			begin
				result           = 32'b0;
				arg_parity_error = 1'b0;
				result_parity    = 1'b0;
			end

			default
			begin
				$display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
				tr = TEST_FAILED;
			end

		endcase

	endtask : get_expected


//------------------------------------------------------------------------------
// data registering and checking
//------------------------------------------------------------------------------

	typedef struct packed {
		shortint             arg_a;
		shortint             arg_b;
		operation_t          op_set;
		int                  result;
		bit                  result_parity;
		bit                  arg_parity_error;
	} data_packet_t;

	data_packet_t sb_data_q  [$];

	int                  result_scoreboard;
	bit                  result_parity_scoreboard;
	bit                  arg_parity_error_scoreboard;

	always @(posedge bfm.clk)

	begin:scoreboard_fe_blk

		if(bfm.req == 1)
		begin
			case(bfm.op_set)
				CORR_INPUT, INCORRECT_A, INCORRECT_B, INCORRECT_A_B :
				begin
					get_expected(bfm.arg_a, bfm.arg_b, bfm.op_set,
						result_scoreboard,
						result_parity_scoreboard,
						arg_parity_error_scoreboard);
					sb_data_q.push_front(data_packet_t'({bfm.arg_a,bfm.arg_b,bfm.op_set,
								result_scoreboard,result_parity_scoreboard,arg_parity_error_scoreboard}));
				end
			endcase
		end

	end

	always @(negedge bfm.clk)

	begin : scoreboard_be_blk

		if(bfm.result_rdy)

		begin : verify_result

			data_packet_t dp;

			dp = sb_data_q.pop_back();

			CHK_RESULT: if  ((bfm.result  == dp.result)          &&
					(bfm.result_parity    == dp.result_parity)   &&
					(bfm.arg_parity_error == dp.arg_parity_error))


			begin
		   `ifdef DEBUG
				$display("Test passed for A=%0d A_parity=%0d, B=%0d b_parity=%0d,", dp.arg_a, dp.arg_a_parity,
					dp.arg_b, dp.arg_b_parity);
		   `endif
			end

			else

			begin
				tr = TEST_FAILED;
				$error("%0t Test FAILED for A=%0d, B=%0d, expected: result=%0d  result_parity=%0d arg_parity_error=%0d,",
					$time, dp.arg_a, dp.arg_b, dp.result, dp.result_parity, dp.arg_parity_error);
			end;

		end
	end : scoreboard_be_blk


//------------------------------------------------------------------------------
// used to modify the color printed on the terminal
//------------------------------------------------------------------------------

	function void set_print_color ( print_color c );
		string ctl;
		case(c)
			COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
			COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
			COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
			COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
			COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
			COLOR_DEFAULT : ctl              = "\033\[0m\n";
			default : begin
				$error("set_print_color: bad argument");
				ctl                          = "";
			end
		endcase
		$write(ctl);
	endfunction

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
	function void print_test_result (test_result r);
		if(tr == TEST_PASSED) begin
			set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
			$write ("-----------------------------------\n");
			$write ("----------- Test PASSED -----------\n");
			$write ("-----------------------------------");
			set_print_color(COLOR_DEFAULT);
			$write ("\n");
		end
		else begin
			set_print_color(COLOR_BOLD_BLACK_ON_RED);
			$write ("-----------------------------------\n");
			$write ("----------- Test FAILED -----------\n");
			$write ("-----------------------------------");
			set_print_color(COLOR_DEFAULT);
			$write ("\n");
		end
	endfunction

//------------------------------------------------------------------------------
// print the test result at the simulation end
//------------------------------------------------------------------------------
	final begin : finish_of_the_test
		print_test_result(tr);
	end

endmodule : scoreboard






