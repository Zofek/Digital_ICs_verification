class scoreboard extends uvm_subscriber #(result_s);
	`uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typedefs
//------------------------------------------------------------------------------
	protected typedef struct packed {
		shortint             arg_a;
		shortint             arg_b;
		operation_t          op_set;
		int                  result;
		bit                  result_parity;
		bit                  arg_parity_error;
	} data_packet_t;

	protected typedef enum bit {
		TEST_PASSED,
		TEST_FAILED
	} test_result;

	protected typedef enum {
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
	uvm_tlm_analysis_fifo #(command_s) cmd_f;

	protected test_result   tr = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new (string name, uvm_component parent);

		super.new(name, parent);

	endfunction : new

//------------------------------------------------------------------------------
// used to modify the color printed on the terminal
//------------------------------------------------------------------------------

	protected function void set_print_color ( print_color c );
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
	protected function void print_test_result (test_result r);
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
// calculate expected result
//------------------------------------------------------------------------------

	protected task get_expected(

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
// build phase
//------------------------------------------------------------------------------
	function void build_phase(uvm_phase phase);
		cmd_f = new ("cmd_f", this);
	endfunction : build_phase


//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
	function void write(result_s t);
		
		int result_scoreboard;
		bit result_parity_scoreboard;
		bit arg_parity_error_scoreboard;
		
		
		command_s cmd;
		cmd.rst_n = 0;
		cmd.arg_a = 0;
		cmd.arg_b = 0;
		cmd.op    = 0;

		do
			if (!cmd_f.try_get(cmd))
				$fatal(1, "Missing command in self checker");
		while (cmd.rst_n == 0); // get commands until rst_n == 0


		case(cmd.op)
			CORR_INPUT, INCORRECT_A, INCORRECT_B, INCORRECT_A_B :
			begin
				get_expected(cmd.arg_a, cmd.arg_b, cmd.op,
					result_scoreboard, result_parity_scoreboard, arg_parity_error_scoreboard);
			end
		endcase

				if (cmd.op !== RST_OP)
				begin
					CHK_RESULT: if  ((t.result  == result_scoreboard)          &&
							(t.result_parity    == result_parity_scoreboard)   &&
							(t.arg_parity_error == arg_parity_error_scoreboard))

					begin
		   `ifdef DEBUG
						$display("Test passed for A=%0d A_parity=%0d, B=%0d b_parity=%0d,", cmd.arg_a, cmd.arg_a_parity,
							cmd.arg_b, cmd.arg_b_parity);
		   `endif
					end

					else

					begin
						tr = TEST_FAILED;
						$error("%0t Test FAILED for A=%0d, B=%0d, expected: result=%0d  result_parity=%0d arg_parity_error=%0d,",
							$time, cmd.arg_a, cmd.arg_b, result_scoreboard, result_parity_scoreboard, arg_parity_error_scoreboard);
					end;

				end

	endfunction : write

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
function void report_phase(uvm_phase phase);
	
	super.report_phase(phase);
	print_test_result(tr);
	
endfunction : report_phase

endclass : scoreboard
