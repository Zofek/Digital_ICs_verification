class coverage extends uvm_component;
`uvm_component_utils(coverage)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	protected virtual mult_bfm bfm;

	protected shortint              arg_a;
	protected bit                   arg_a_parity;
	protected shortint              arg_b;
	protected bit                   arg_b_parity;
	protected operation_t           op_set;

//------------------------------------------------------------------------------
// covergroups
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

// Covergroup checking for specific data corners on arguments of the MULT
	covergroup zeros_plus_and_minus_one_max_min_on_ops;

		option.name = "cg_zeros_plus_and_minus_one_max_or_min_on_ops";

		all_ops : coverpoint op_set
		{
			bins correct_inputs   = CORR_INPUT;
			bins incorrect_B      = INCORRECT_B;
			bins incorrect_A      = INCORRECT_A;
			bins incorrect_AB     = INCORRECT_A_B;
		}

		a_leg: coverpoint arg_a
		{
			bins zeros     = {16'sh0000};
			bins max       = {16'sh7FFF};
			bins min       = {16'sh8000};
			bins minus_one = {16'shFFFF};
			bins plus_one  = {16'sh0001};
			bins others    = {[16'sh0002:16'sh7FFE],[16'sh8001:16'shFFFE]};
		}

		b_leg: coverpoint arg_b
		{
			bins zeros     = {16'sh0000};
			bins max       = {16'sh7FFF};
			bins min       = {16'sh8000};
			bins minus_one = {16'shFFFF};
			bins plus_one  = {16'sh0001};
			bins others    = {[16'sh0002:16'sh7FFE],[16'sh8001:16'shFFFE]};
		}

		B_op_data_corners: cross a_leg, b_leg, all_ops
		{

			// #B1 Simulate all zeros on an input.

			bins B1_correct_zeros      = binsof (all_ops.correct_inputs) && (binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_incorrect_b_zeros  = binsof (all_ops.incorrect_B) && (binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_incorrect_a_zeros  = binsof (all_ops.incorrect_A) && (binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_incorrect_ab_zeros = binsof (all_ops.incorrect_AB) && (binsof (a_leg.zeros) || binsof (b_leg.zeros));

			// #B2 Simulate value -1 on an input.

			bins B2_correct_minusone      = binsof (all_ops.correct_inputs) && (binsof (a_leg.minus_one) || binsof (b_leg.minus_one));

			bins B2_incorrect_b_minusone  = binsof (all_ops.incorrect_B) && (binsof (a_leg.minus_one) || binsof (b_leg.minus_one));

			bins B2_incorrect_a_minusone  = binsof (all_ops.incorrect_A) && (binsof (a_leg.minus_one) || binsof (b_leg.minus_one));

			bins B2_incorrect_ab_minusone = binsof (all_ops.incorrect_AB) && (binsof (a_leg.minus_one) || binsof (b_leg.minus_one));

			// #B3 Simulate value 1 on an input.

			bins B3_correct_one      = binsof (all_ops.correct_inputs) && (binsof (a_leg.plus_one) || binsof (b_leg.plus_one));

			bins B3_incorrect_b_one  = binsof (all_ops.incorrect_B) && (binsof (a_leg.plus_one) || binsof (b_leg.plus_one));

			bins B3_incorrect_a_one  = binsof (all_ops.incorrect_A) && (binsof (a_leg.plus_one) || binsof (b_leg.plus_one));

			bins B3_incorrect_ab_one = binsof (all_ops.incorrect_AB) && (binsof (a_leg.plus_one) || binsof (b_leg.plus_one));

			// #B4 Simulate max value on an input.

			bins B4_correct_max      = binsof (all_ops.correct_inputs) && (binsof (a_leg.max) || binsof (b_leg.max));

			bins B4_incorrect_b_max  = binsof (all_ops.incorrect_B) && (binsof (a_leg.max) || binsof (b_leg.max));

			bins B4_incorrect_a_max  = binsof (all_ops.incorrect_A) && (binsof (a_leg.max) || binsof (b_leg.max));

			bins B4_incorrect_ab_max = binsof (all_ops.incorrect_AB) && (binsof (a_leg.max) || binsof (b_leg.max));

			// #B5 Simulate min value on an input.

			bins B5_correct_min      = binsof (all_ops.correct_inputs) && (binsof (a_leg.min) || binsof (b_leg.min));

			bins B5_incorrect_b_min  = binsof (all_ops.incorrect_B) && (binsof (a_leg.min) || binsof (b_leg.min));

			bins B5_incorrect_a_min  = binsof (all_ops.incorrect_A) && (binsof (a_leg.min) || binsof (b_leg.min));

			bins B5_incorrect_ab_min = binsof (all_ops.incorrect_AB) && (binsof (a_leg.min) || binsof (b_leg.min));

			ignore_bins others_only =
			binsof(a_leg.others) && binsof(b_leg.others);
		}

	endgroup

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
	    
        super.new(name, parent);
		op_cov = new();
		zeros_plus_and_minus_one_max_min_on_ops = new();
			
	endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
	    
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
        
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);
		
		forever begin : sampling_block

			@(negedge bfm.clk);

			arg_a        = bfm.arg_a;
			arg_a_parity = bfm.arg_a_parity;
			arg_b        = bfm.arg_b;
			arg_b_parity = bfm.arg_b_parity;
			op_set       = bfm.op_set;

			op_cov.sample();
			zeros_plus_and_minus_one_max_min_on_ops.sample();

		end : sampling_block
		
	endtask : run_phase

endclass : coverage
