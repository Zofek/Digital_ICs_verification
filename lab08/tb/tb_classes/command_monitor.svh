class command_monitor extends uvm_component;
	`uvm_component_utils(command_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	protected virtual mult_bfm bfm;
	uvm_analysis_port #(random_command_transaction) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
	function new (string name, uvm_component parent);
		
		super.new(name,parent);
		
	endfunction

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);

        mult_agent_config agent_config_h;

        // get the BFM
        if(!uvm_config_db #(mult_agent_config)::get(this, "","config", agent_config_h))
            `uvm_fatal("COMMAND MONITOR", "Failed to get CONFIG");

        // pass the command_monitor handler to the BFM
        agent_config_h.bfm.command_monitor_h = this;

        ap = new("ap",this);
        
    endfunction : build_phase

//------------------------------------------------------------------------------
// access function for BFM
//------------------------------------------------------------------------------
	function void write_to_monitor(

			shortint    arg_a,
			shortint    arg_b,
			bit         arg_a_parity,
			bit         arg_b_parity,
			operation_t	op);
			
		random_command_transaction cmd;
		
		cmd    = new("cmd");
		
		cmd.arg_a  		 = arg_a;
		cmd.arg_b  		 = arg_b;
		cmd.arg_a_parity = arg_a_parity;
		cmd.arg_b_parity = arg_b_parity;
		cmd.op 			 = op;
		ap.write(cmd);
		
		`uvm_info("COMMAND MONITOR",$sformatf("MONITOR: arg_a=%0d, arg_b=%0d, arg_a_parity=%0d, arg_b_parity=%0d, operation=%0d",
				arg_a, arg_b, arg_a_parity, arg_b_parity, op), UVM_HIGH);
		
	endfunction : write_to_monitor

	endclass : command_monitor

