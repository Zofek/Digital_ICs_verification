
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
	wire           [2:0] op;

	operation_t          op_set;

	assign op = op_set;

	modport tlm (import reset_mult, send_op);

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


//------------------------------------------------------------------------------
// send_op
//------------------------------------------------------------------------------

	task send_op(

			input shortint iarg_a,
			input bit iarg_a_parity,
			input shortint iarg_b,
			input bit iarg_b_parity,
			input bit req,
			input operation_t iop,

			output bit iack,
			output bit iresult_rdy,
			output bit iarg_parity_error,
			output int iresult,
			output bit iresult_parity);

		op_set = iop;
		arg_a  = iarg_a;
		arg_a_parity = iarg_a_parity;
		arg_b  = iarg_b;
		arg_b_parity = iarg_b_parity;

		req = 1'b1;

		wait(ack);

		@(negedge clk);

		req = 1'b0;

		wait(result_rdy);

	endtask : send_op

endinterface : mult_bfm


