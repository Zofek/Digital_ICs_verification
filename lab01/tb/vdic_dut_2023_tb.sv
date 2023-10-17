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
		RST_OP       = 3'b000,
		CORR_INPUT   = 3'b001,
		INCORR_INPUT = 3'b010
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

	int                  result_expected ;
	bit                  result_parity_expected;
	bit                  arg_parity_error_expected;

	bit            [2:0] op;

	operation_t          op_set;
	assign op = op_set;


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

	function shortint get_data();

		bit     [1:0] zero_ones;

		zero_ones = 2'($random);

		if (zero_ones == 2'b00)
			return 16'h0000;
		else if (zero_ones == 2'b11)
			return 16'hFF;
		else
			return 16'($random);

	endfunction : get_data

//---------------------------------
	function operation_t get_op();
		bit [2:0] op_choice;
		op_choice = 3'($random);
		case (op_choice)
			3'b000 : return RST_OP;
			3'b001 : return CORR_INPUT;
			3'b010 : return INCORR_INPUT;
			3'b011 : return RST_OP;
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

			INCORR_INPUT :
			begin
				result           = 32'b0;;
				arg_parity_error = 1'b1;
				result_parity    = ^result;
			end

			default: begin
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

			case (op_set)
				
				RST_OP :
				begin
					reset_mult();
				end
				
				CORR_INPUT : 
				begin  
					arg_a  = get_data();
					get_parity(arg_a, 1'b0, arg_a_parity);
					arg_b  = get_data();
					get_parity(arg_b, 1'b0, arg_b_parity);
					req    = 1'b1;
				end
				
				INCORR_INPUT : 
				begin  
					arg_a  = get_data();
					get_parity(arg_a, 1'b1, arg_a_parity);
					arg_b  = get_data();
					get_parity(arg_b, 1'b0, arg_b_parity);
					req    = 1'b1;

				get_expected(arg_a, arg_b, INCORR_INPUT,
					result_expected,
					result_parity_expected,
					arg_parity_error_expected);
				end
			endcase // case (op_set)
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


endmodule : top