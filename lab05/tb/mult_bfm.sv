interface mult_bfm;

import mult_pkg::*;

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
// clock generator
//------------------------------------------------------------------------------
	initial begin
		clk = 0;
		forever begin
			#10;
			clk = ~clk;
		end
	end


//------------------------------------------------------------------------------
// reset_mult
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
// send_op
//------------------------------------------------------------------------------

	task send_op(

			input shortint iarg_a,
			input shortint iarg_b,
			input operation_t iop,
			
			output bit oarg_a_parity,
			output bit oarg_b_parity,
			output bit oarg_parity_error,
			output int oresult,
			output bit oresult_parity);

		op_set = iop;
		arg_a  = iarg_a;
		arg_a_parity = oarg_a_parity;
		arg_b  = iarg_b;
		arg_b_parity = oarg_b_parity;

		case(op_set)

			RST_OP :
			begin
				reset_mult();
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

	endtask : send_op

endinterface : mult_bfm


