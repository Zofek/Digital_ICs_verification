package mult_pkg;
	
	typedef enum bit[2:0] {
		RST_OP        = 3'b000,
		CORR_INPUT    = 3'b001,
		INCORRECT_A   = 3'b010,
		INCORRECT_B   = 3'b011,
		INCORRECT_A_B = 3'b100
	} operation_t;
	
	`include "coverage.svh"
	`include "tpgen.svh"
	`include "scoreboard.svh"
	`include "testbench.svh"

endpackage : mult_pkg
