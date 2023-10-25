module top;

//------------------------------------------------------------------------------
// Type definitions
//------------------------------------------------------------------------------
	typedef enum bit {
		TEST_PASSED,
		TEST_FAILED
	} test_result_t;

	typedef enum {
		COLOR_BOLD_BLACK_ON_GREEN,
		COLOR_BOLD_BLACK_ON_RED,
		COLOR_BOLD_BLACK_ON_YELLOW,
		COLOR_BOLD_BLUE_ON_WHITE,
		COLOR_BLUE_ON_WHITE,
		COLOR_DEFAULT
	} print_color_t;

	typedef enum bit[2:0] {
		RST_OP        = 3'b000,
		CORR_INPUT    = 3'b001,
		INCORRECT_A   = 3'b010,
		INCORRECT_B   = 3'b011,
		INCORRECT_A_B = 3'b100
	} operation_t;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

	test_result_t        test_result = TEST_PASSED;

	bit                   clk;
	bit                   rst_n;
	shortint              arg_a;
	bit                   arg_a_parity;
	shortint              arg_b;
	bit                   arg_b_parity;
	bit                   req;

	wire                 ack;
	int                  result;
	wire                 result_parity;
	wire                 result_rdy;
	wire                 arg_parity_error;

	operation_t          op_set;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------
	vdic_dut_2023 DUT (.clk, .rst_n, .arg_a, .arg_a_parity, .arg_b, .arg_b_parity, .req,
		.ack, .result, .result_parity, .result_rdy, .arg_parity_error);


//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

	// Covergroup checking the op codes and their sequences
	covergroup op_cov;

		option.name = "cg_op_cov";

		coverpoint op_set 
		{
			// #A1 Check the result when data and parity values are valid for both inputs.
			bins A1_correct_inputs   = CORR_INPUT;

			// #A2 Check the result when input parity value is valid for A input and invalid for B input.
			bins A2_incorrect_B      = INCORRECT_B;

			// #A3 Check the result when input parity value is valid for B input and invalid for A input.
			bins A3_incorrect_A      = INCORRECT_A;

			// #A4 Check the result when input parity is invalid for both inputs.
			bins A4_incorrect_AB     = INCORRECT_A_B;
		}

	endgroup

// Covergroup checking for specific data corners on arguments of the ALU
	covergroup zeros_plus_and_minus_one_max_min_on_ops;

		option.name = "cg_zeros_plus_and_minus_one_max_or_min_on_ops";

		all_ops : coverpoint op_set 
		{
			ignore_bins null_ops = {RST_OP};
		}

		a_leg: coverpoint arg_a 
		{
			bins zeros     = {'h0000};
			bins max       = {'h7FFF};
			bins min       = {'h8000};
			bins minus_one = {'hFFFF};
			bins plus_one  = {'h0001};
			bins others    = {['h0002:'h7FFE],['h8001:'hFFFE]};
		}

		b_leg: coverpoint arg_b 
		{
			bins zeros     = {'h0000};
			bins max       = {'h7FFF};
			bins min       = {'h8000};
			bins minus_one = {'hFFFF};
			bins plus_one  = {'h0001};
			bins others    = {['h0002:'h7FFE],['h8001:'hFFFE]};
		}

		B_op_data_corners: cross a_leg, b_leg, all_ops 
		{

			// #B1 Simulate all zeros on an input.

			bins B1_correct_zeros      = binsof (all_ops) intersect {CORR_INPUT}    &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_incorrect_a_zeros  = binsof (all_ops) intersect {INCORRECT_A}   &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_incorrect_b_zeros  = binsof (all_ops) intersect {INCORRECT_B}   &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_incorrect_ab_zeros = binsof (all_ops) intersect {INCORRECT_A_B} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			// #B2 Simulate value -1 on an input.

			bins B2_correct_minusone      = binsof (all_ops) intersect {CORR_INPUT}    &&
			(binsof (a_leg.minus_one) || binsof (b_leg.minus_one));

			bins B2_incorrect_a_minusone  = binsof (all_ops) intersect {INCORRECT_A}   &&
			(binsof (a_leg.minus_one) || binsof (b_leg.minus_one));

			bins B2_incorrect_b_minusone  = binsof (all_ops) intersect {INCORRECT_B}   &&
			(binsof (a_leg.minus_one) || binsof (b_leg.minus_one));

			bins B2_incorrect_ab_minusone = binsof (all_ops) intersect {INCORRECT_A_B} &&
			(binsof (a_leg.minus_one) || binsof (b_leg.minus_one));

			// #B3 Simulate value 1 on an input.

			bins B3_correct_one      = binsof (all_ops) intersect {CORR_INPUT}    &&
			(binsof (a_leg.plus_one) || binsof (b_leg.plus_one));

			bins B3_incorrect_a_one  = binsof (all_ops) intersect {INCORRECT_A}   &&
			(binsof (a_leg.plus_one) || binsof (b_leg.plus_one));

			bins B3_incorrect_b_one  = binsof (all_ops) intersect {INCORRECT_B}   &&
			(binsof (a_leg.plus_one) || binsof (b_leg.plus_one));

			bins B3_incorrect_ab_one = binsof (all_ops) intersect {INCORRECT_A_B} &&
			(binsof (a_leg.plus_one) || binsof (b_leg.plus_one));

			// #B4 Simulate max value on an input.

			bins B4_correct_max      = binsof (all_ops) intersect {CORR_INPUT}    &&
			(binsof (a_leg.max) || binsof (b_leg.max));

			bins B4_incorrect_a_max  = binsof (all_ops) intersect {INCORRECT_A}   &&
			(binsof (a_leg.max) || binsof (b_leg.max));

			bins B4_incorrect_b_max  = binsof (all_ops) intersect {INCORRECT_B}   &&
			(binsof (a_leg.max) || binsof (b_leg.max));

			bins B4_incorrect_ab_max = binsof (all_ops) intersect {INCORRECT_A_B} &&
			(binsof (a_leg.max) || binsof (b_leg.max));

			// #B5 Simulate min value on an input.

			bins B5_correct_min      = binsof (all_ops) intersect {CORR_INPUT}    &&
			(binsof (a_leg.max) || binsof (b_leg.max));

			bins B5_incorrect_a_min  = binsof (all_ops) intersect {INCORRECT_A}   &&
			(binsof (a_leg.max) || binsof (b_leg.max));

			bins B5_incorrect_b_min  = binsof (all_ops) intersect {INCORRECT_B}   &&
			(binsof (a_leg.max) || binsof (b_leg.max));

			bins B5_incorrect_ab_min = binsof (all_ops) intersect {INCORRECT_A_B} &&
			(binsof (a_leg.max) || binsof (b_leg.max));

			ignore_bins others_only =
			binsof(a_leg.others) && binsof(b_leg.others);
		}

	endgroup

	op_cov oc;
	zeros_plus_and_minus_one_max_min_on_ops c_00_FF;

	initial

	begin : coverage

		oc      = new();
		c_00_FF = new();

		forever

		begin : sample_cov

			@(posedge clk);

			if(req || !rst_n)

			begin
				oc.sample();
				c_00_FF.sample();

				/* #1step delay is necessary before checking for the coverage
				 * as the .sample methods run in parallel threads
				 */
				#1step;

				if($get_coverage() == 100) break; //disable, if needed

			// you can print the coverage after each sample
			//$strobe("%0t coverage: %.4g\%",$time, $get_coverage());
			end

		end

	end : coverage

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
//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions
//---------------------------------

	function shortint get_data();

		bit     [2:0] zero_ones;

		zero_ones = 3'($random);

		if      (zero_ones == 3'b00)  return 16'h0000; //zero
		else if (zero_ones == 3'b001) return 16'h7FFF; //MAX
		else if (zero_ones == 3'b010) return 16'h8000; //MIN
		else if (zero_ones == 3'b011) return 16'hFFFF; //-1
		else if (zero_ones == 3'b100) return 16'h0001; //1
		else                          return 16'($random);

	endfunction : get_data

//---------------------------------
	function operation_t get_op();
		bit [2:0] op_choice;
		op_choice = 3'($random);
		case (op_choice)
			3'b000  : return RST_OP;
			3'b001  : return CORR_INPUT;
			3'b010  : return INCORRECT_A;
			3'b011  : return INCORRECT_A;
			3'b100  : return INCORRECT_A_B;
			default : return RST_OP;
		endcase // case (op_choice)
	endfunction : get_op

//---------------------------------
// Parity calculation task with parameter to return correct or incorrect parity
//---------------------------------

	task get_parity(

			input shortint  data,
			input bit       ret_incorrect_parity,
			output bit      parity);

		parity = ^data;

		if (ret_incorrect_parity)
			parity = !parity;

	endtask : get_parity

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------

	task reset_mult();

	`ifdef DEBUG
		$display("%0t DEBUG: reset_mult", $time);
	`endif

		req     = 1'b0;
		rst_n   = 1'b0;

		@(negedge clk);
		rst_n   = 1'b1;

	endtask : reset_mult

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
			test_result = TEST_FAILED;
		end
		
		endcase
		
	endtask : get_expected

//------------------------
// Tester main

	initial begin : tester

		reset_mult();

		repeat (1000)

		begin : tester_main_blk

			@(negedge clk);

			op_set = get_op();
			arg_a  = get_data();
			arg_b  = get_data();

			case(op_set)

				RST_OP :
				begin
					reset_mult();
					continue;
				end

				CORR_INPUT :
				begin
					get_parity(arg_a, 1'b0, arg_a_parity);
					get_parity(arg_b, 1'b0, arg_b_parity);
				end

				INCORRECT_A :
				begin
					get_parity(arg_a, 1'b1, arg_a_parity);
					get_parity(arg_b, 1'b0, arg_b_parity);
				end

				INCORRECT_B :
				begin
					get_parity(arg_a, 1'b0, arg_a_parity);
					get_parity(arg_b, 1'b1, arg_b_parity);
				end

				INCORRECT_A_B :
				begin
					get_parity(arg_a, 1'b1, arg_a_parity);
					get_parity(arg_b, 1'b1, arg_b_parity);
				end
			endcase // case (op_set)

			req = 1'b1;

			wait(ack);

			@(negedge clk);

			req = 1'b0;

			wait(result_rdy);

		end : tester_main_blk

		$finish;
	end : tester

//------------------------------------------------------------------------------
// Temporary. The scoreboard will be later used for checking the data
	final begin : finish_of_the_test
		print_test_result(test_result);
	end

//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------

// used to modify the color of the text printed on the terminal
	function void set_print_color ( print_color_t c );
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

	function void print_test_result (test_result_t r);
		if(r == TEST_PASSED) begin
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
// Scoreboard
//------------------------------------------------------------------------------
	bit req_prev;

	typedef struct packed {
		shortint             arg_a;
		shortint             arg_b;
		operation_t          op_set;
		int                  result;
		bit                  result_parity;
		bit                  arg_parity_error;
	} data_packet_t;

	int                  result_scoreboard;
	bit                  result_parity_scoreboard;
	bit                  arg_parity_error_scoreboard;

	data_packet_t            sb_data_q   [$];

	always @(posedge clk)

	begin:scoreboard_fe_blk

		if(req == 1 && req_prev == 0)
		begin
			case(op_set)
				CORR_INPUT, INCORRECT_A, INCORRECT_B, INCORRECT_A_B :
				begin
					get_expected(arg_a, arg_b, op_set,
						result_scoreboard,
						result_parity_scoreboard,
						arg_parity_error_scoreboard);
					sb_data_q.push_front(data_packet_t'({arg_a,arg_b,op_set,
								result_scoreboard,result_parity_scoreboard,arg_parity_error_scoreboard}));
				end
			endcase
		end
		req_prev = req;
	end

	always @(negedge clk)

	begin : scoreboard_be_blk

		if(result_rdy)

		begin : verify_result

			data_packet_t dp;

			dp = sb_data_q.pop_back();

			CHK_RESULT: if  ((result  == dp.result)          &&
					(result_parity    == dp.result_parity)   &&
					(arg_parity_error == dp.arg_parity_error))


			begin
		   `ifdef DEBUG
				$display("Test passed for A=%0d A_parity=%0d, B=%0d b_parity=%0d,", dp.arg_a, dp.arg_a_parity,
					dp.arg_b, dp.arg_b_parity);
		   `endif
			end

			else

			begin
				test_result = TEST_FAILED;
				$error("%0t Test FAILED for A=%0d, B=%0d, expected: result=%0d  result_parity=%0d arg_parity_error=%0d,",
					$time, dp.arg_a, dp.arg_b,result, result_parity, arg_parity_error);
			end;

		end
	end : scoreboard_be_blk

endmodule : top
