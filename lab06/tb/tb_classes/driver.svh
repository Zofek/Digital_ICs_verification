class driver extends uvm_component;
    `uvm_component_utils(driver)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    uvm_get_port #(command_s) command_port;
    
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
            $fatal(1, "Failed to get BFM");
        
        command_port = new("command_port",this);
        
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
	    
        command_s command;

        forever 
	        begin : command_loop
		        
            command_port.get(command);
		        
            bfm.send_op(command.rst_n, command.arg_a,command.arg_b);
	        
	        $display("DRIVER: arg_a=%0d, arg_b=%0d, rst_n=%0d wait_result=%0d", command.arg_a, command.arg_b, command.rst_n, command.wait_result);
	       
	        if(command.wait_result == 1) 
	        begin
	        	bfm.wait_result();
	        end
	        
	        else begin
		       $display("Couldn't get data in driver!!!"); 
		    end
        end : command_loop
    endtask : run_phase
    

endclass : driver