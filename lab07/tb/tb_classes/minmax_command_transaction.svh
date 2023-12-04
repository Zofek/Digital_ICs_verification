class minmax_command_transaction extends random_command_transaction;
    `uvm_object_utils(minmax_command_transaction)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// constraints max - 0x7FFF = dec32767; min 0x8000 = dec - 32768
//------------------------------------------------------------------------------

    constraint data {
	    
        arg_a dist {16'h0000:=2, 16'h0001:=2, 16'h7FFF:=2,  16'hFFFF:=2, 16'h8000:=2};
        arg_b dist {16'h0000:=2, 16'h0001:=2, 16'h7FFF:=2,  16'hFFFF:=2, 16'h8000:=2};
    
    }

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name = "");
	    
        super.new(name);
	    
    endfunction : new

endclass : minmax_command_transaction
