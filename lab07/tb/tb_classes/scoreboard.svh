class scoreboard extends uvm_subscriber #(result_transaction);
	`uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typedefs
//------------------------------------------------------------------------------
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
	uvm_tlm_analysis_fifo #(random_command_transaction) cmd_f;

	local test_result   tr = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new (string name, uvm_component parent);

		super.new(name, parent);

	endfunction : new

//------------------------------------------------------------------------------
// used to modify the color printed on the terminal
//------------------------------------------------------------------------------

	local function void set_print_color ( print_color c );
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
	local function void print_test_result (test_result r);
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
// build phase
//------------------------------------------------------------------------------
	function void build_phase(uvm_phase phase);

		cmd_f = new ("cmd_f", this);

	endfunction : build_phase

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------
	local function result_transaction predict_result(random_command_transaction cmd);

		result_transaction predicted;

		predicted = new("predicted");

		case(cmd.op)

			CORR_INPUT :

			begin
				predicted.result           = cmd.arg_a * cmd.arg_b;
				predicted.arg_parity_error = 1'b0;
				predicted.result_parity    = ^cmd.arg_a * cmd.arg_b;
			end

			INCORRECT_A, INCORRECT_B, INCORRECT_A_B:

			begin
				predicted.result           = 32'b0;
				predicted.arg_parity_error = 1'b1;
				predicted.result_parity    = ^32'b0;
			end

			RST_OP :

			begin
				predicted.result           = 32'b0;
				predicted.arg_parity_error = 1'b0;
				predicted.result_parity    = 1'b0;
			end

		endcase

		return predicted;

	endfunction : predict_result

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
	function void write(result_transaction t);

		int result_scoreboard;
		bit result_parity_scoreboard;
		bit arg_parity_error_scoreboard;

		string data_str;
		random_command_transaction cmd;
		result_transaction predicted;

		case(cmd.op)
			CORR_INPUT, INCORRECT_A, INCORRECT_B, INCORRECT_A_B :
			begin
				predicted = predict_result(cmd);
			end
		endcase

		if (cmd.op !== RST_OP)
			
			data_str  = { cmd.convert2string(),
						" ==>  Actual " , t.convert2string(),
						"/Predicted ",predicted.convert2string()};
					
		if (!predicted.compare(t))
			
		begin
			`uvm_error("SELF CHECKER", {"FAIL: ",data_str})
			tr = TEST_FAILED;
		end
		
		else
			
		begin
			`uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)
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
