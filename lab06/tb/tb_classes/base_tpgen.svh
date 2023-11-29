virtual class base_tpgen extends uvm_component;

//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
    uvm_put_port #(command_s) command_port;

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
	    
        command_port = new("command_port", this);
	    
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);
		
        command_s command;
		
		phase.raise_objection(this);
		
        command.rst_n = 1;
        command_port.put(command);
		command.rst_n = 0;

		repeat (1000)
		begin : random_loop

			command.op = get_op();
			command.arg_a  = get_data();
			command.arg_b  = get_data();
			
			command.wait_result = 1;
			command_port.put(command);
			
		end : random_loop
		
		command.wait_result = 0;
		command_port.put(command);
		command.rst_n = 1;
		command_port.put(command);
		
		phase.drop_objection(this);

	endtask : run_phase 


endclass : base_tpgen
