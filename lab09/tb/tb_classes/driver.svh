class driver extends uvm_driver #(sequence_item);
	`uvm_component_utils(driver)

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
// build phase
//------------------------------------------------------------------------------
	function void build_phase(uvm_phase phase);

		if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
			`uvm_fatal("DRIVER", "Failed to get BFM");

	endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);

		sequence_item   command;
		command	= new("command");
		
		void'(begin_tr(command));
		
		forever
		begin : command_loop

			seq_item_port.get_next_item(command);
			
			bfm.send_op(command.arg_a,command.arg_b, command.op, command.arg_a_parity, command.arg_b_parity);
			
			seq_item_port.item_done();
			
		end : command_loop
		
		end_tr(command);

    endtask : run_phase

endclass : driver