class scoreboard extends uvm_subscriber #(result_transaction);
	`uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typedefs
//------------------------------------------------------------------------------
	typedef enum bit {
		TEST_PASSED,
		TEST_FAILED
	} test_result;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	uvm_tlm_analysis_fifo #(sequence_item) cmd_f;

	local test_result   tr = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new (string name, uvm_component parent);

		super.new(name, parent);

	endfunction : new

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
// report phase
//------------------------------------------------------------------------------

    function void report_phase(uvm_phase phase);
	    
        super.report_phase(phase);
	    
        `uvm_info("SELF CHECKTER", "Reporting test result below", UVM_LOW)
        
        print_test_result(tr);
	    
    endfunction : report_phase

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------
	local function result_transaction predict_result(sequence_item cmd);

		result_transaction predicted;

		predicted = new("predicted");

		case(cmd.op)

			CORR_INPUT :

			begin
				predicted.result           = cmd.arg_a * cmd.arg_b;
				predicted.arg_parity_error = 1'b0;
				predicted.result_parity    = ^(cmd.arg_a * cmd.arg_b);
			end

			INCORRECT_A, INCORRECT_B, INCORRECT_A_B:

			begin
				predicted.result           = 32'b0;
				predicted.arg_parity_error = 1'b1;
				predicted.result_parity    = ^(32'b0);
			end

			default:
				tr = TEST_FAILED;

		endcase

		return predicted;

	endfunction : predict_result

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
	function void write(result_transaction t);

		string data_str;
		
		result_transaction predicted;
		sequence_item cmd;
		
		predicted = new("predicted");
		cmd = new("cmd");

		case(cmd.op)
			CORR_INPUT, INCORRECT_A, INCORRECT_B, INCORRECT_A_B :
			begin
				predicted = predict_result(cmd);
			end
		endcase

		if (cmd.op !== RST_OP)
		begin
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
		end
	endfunction : write

endclass : scoreboard
