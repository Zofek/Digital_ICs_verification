virtual class base_tpgen extends uvm_component;

// The macro is not there as we never instantiate/use the base_tpgen
//    `uvm_component_utils(base_tpgen)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    pure virtual protected function operation_t get_op();
    pure virtual protected function shortint get_data();

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

		shortint arg_a;
		shortint arg_b;

		operation_t op_set;
		
		bit arg_a_parity;
		bit arg_b_parity;
		bit arg_parity_error;
		int result;
		bit result_parity;
		
		phase.raise_objection(this);
		
		bfm.reset_mult();

		repeat (1000)

		begin : random_loop

			op_set = get_op();
			arg_a  = get_data();
			arg_b  = get_data();

			bfm.send_op(arg_a, arg_b, op_set, arg_a_parity, arg_b_parity, arg_parity_error, result, result_parity);

			bfm.req = 1'b1;

			while(!bfm.ack) @(negedge bfm.clk);

			bfm.req = 1'b0;

			while(!bfm.result_rdy) @(negedge bfm.clk);

		end : random_loop
		
		phase.drop_objection(this);

	endtask : run_phase 


endclass : base_tpgen
