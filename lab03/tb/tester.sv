/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
module tester(mult_bfm bfm);

	import mult_pkg::*;

//---------------------------------
//
//---------------------------------
	function operation_t get_op();
		bit [2:0] op_choice;
		op_choice = 3'($random);
		case (op_choice)
			3'b000  : return RST_OP;
			3'b001  : return CORR_INPUT;
			3'b010  : return INCORRECT_A;
			3'b011  : return INCORRECT_B;
			3'b100  : return INCORRECT_A_B;
			default : return RST_OP;
		endcase // case (op_choice)
	endfunction : get_op

//---------------------------------
// Random data generation functions
//---------------------------------

	function shortint get_data();

		bit     [2:0] zero_ones;

		zero_ones = 3'($random);

		if      (zero_ones == 3'b000)  return 16'sh0000; //zero
		else if (zero_ones == 3'b001) return 16'sh7FFF; //MAX
		else if (zero_ones == 3'b010) return 16'sh8000; //MIN
		else if (zero_ones == 3'b011) return 16'shFFFF; //-1
		else if (zero_ones == 3'b100) return 16'sh0001; //1
		else                          return 16'($random);

	endfunction : get_data


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

//---------------------------------
	initial begin

		shortint arg_a;
		bit arg_a_parity;
		shortint arg_b;
		bit arg_b_parity;
		bit req;
		operation_t op_set;

		bit ack;
		bit result_rdy;
		bit arg_parity_error;
		int result;
		bit result_parity;

		reset_mult();

		repeat (1000)

		begin : random_loop

			@(negedge bfm.clk);

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

			send_op(iarg_a(iarg_a),iarg_a_parity(arg_a_parity),iarg_b(arg_b),iarg_b_parity(arg_b_parity),
				ireq(req),iop(op_set),
				iack(ack),iresult_rdy(result_rdy),
				iarg_parity_error(arg_parity_error),iresult(result),iresult_parity(result_parity));

		end : random_loop
		$finish;

	end // initial begin


endmodule : tester
