class driver extends uvm_component;
	`uvm_component_utils(driver)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	protected virtual mult_bfm bfm;
	uvm_get_port #(random_command_transaction) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
	function void build_phase(uvm_phase phase);

		if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
			`uvm_fatal("DRIVER", "Failed to get BFM");

		command_port = new("command_port",this);

	endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);

		shortint              arg_a;
		bit                   arg_a_parity;
		shortint              arg_b;
		bit                   arg_b_parity;
		random_command_transaction   command;

		forever
		begin : command_loop

			command_port.get(command);

			bfm.send_op(command.arg_a,command.arg_b, command.op, command.arg_a_parity, command.arg_b_parity);

		end : command_loop
	endtask : run_phase


endclass : driver