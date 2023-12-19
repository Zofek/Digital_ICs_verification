class minmax_sequence_item extends sequence_item;
    `uvm_object_utils(minmax_sequence_item)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint minmax {
	    
        arg_a dist {16'h0000:=1, 16'h0001:=1, 16'h7FFF:=1,  16'hFFFF:=1, 16'h8000:=1};
        arg_b dist {16'h0000:=1, 16'h0001:=1, 16'h7FFF:=1,  16'hFFFF:=1, 16'h8000:=1};
    
    }
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "minmax_sequence_item");
	    
        super.new(name);
	    
    endfunction : new

endclass : minmax_sequence_item


